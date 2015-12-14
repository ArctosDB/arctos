<cfinclude template="/includes/_header.cfm">
<cfset functions = CreateObject("component","component.functions")>
<cfoutput>

	<!---- slip a DOI report in here - does anyone use the crap we build? ---->
	<!----
	create table cf_doi_report (
		publication_type varchar2(255),
		hascount number,
		nopecount number,
		checkdate date
	);
	---->

	<cfquery name="dailyrefresh" datasource="uam_god">
		insert into cf_doi_report (publication_type,hascount,nopecount,checkdate) (
		 select
  			publication_type,
	 		count(doi) ,
  	 		count(*) - count(doi),
			sysdate
		from publication group by publication_type)
	</cfquery>
	<cfquery name="doireport" datasource="uam_god">
		select * from cf_doi_report where checkdate > sysdate-11 order by checkdate desc,publication_type
	</cfquery>
	<cfif isdefined("Application.version") and  Application.version is "prod">
		<cfset subj="Arctos DOI Report">
		<cfset maddr="arctos.database@gmail.com">
	<cfelse>
		<cfset maddr=application.bugreportemail>
		<cfset subj="TEST PLEASE IGNORE: Arctos DOI Report">
	</cfif>
	<cfmail to="#maddr#" subject="#subj#" from="doireport@#Application.fromEmail#" type="html">
		Most recent DOI status of Arctos publications
		<table border>
			<tr>
				<th>Date</th>
				<th>Type</th>
				<th>HasDOI</th>
				<th>NoDOI</th>
			</tr>
			<cfloop query="doireport">
				<tr>
					<td>#dateformat(checkdate,'YYYY-MM-DD')#</td>
					<td>#publication_type#</td>
					<td>#hascount#</td>
					<td>#nopecount#</td>
				</tr>
			</cfloop>
		</table>
		<p>
			See ScheduledTasks.cfm to stop this report of get the SQL.
		</p>
	</cfmail>
	<!---- /slip a DOI report in here for now.... ---->

		<cfsavecontent variable="emailFooter">
			<div style="font-size:smaller;color:gray;">
				--
				<br>Don't want these messages? Update Collection Contacts.
				<br>Want these messages? Update Collection Contacts, make sure you have a valid email address.
				<br>Links not working? Log in, log out, or check encumbrances.
				<br>Need help? Send email to arctos.database@gmail.com
			</div>
		</cfsavecontent>
	<!--- start of loan code --->
	<!--- days after and before return_due_date on which to send email. Negative is after ---->
	<cfset eid="-365,-180,-150,-120,-90,-60,-30,-7,0,7,30">
	<!---
		Query to get all loan data from the server. Use GOD query so we can ignore collection partitions.
		This form has no output and relies on system time to run, so only danger is in sending multiple copies
		of notification to loan folks. No real risk in not using a lesser agent for the queries.
	--->
	<cfquery name="expLoan" datasource="uam_god">
		select
			loan.transaction_id,
			to_char(RETURN_DUE_DATE,'yyyy-mm-dd') return_due_date,
			LOAN_NUMBER,
			get_address(collection_contacts.contact_agent_id,'email') collection_contact_email,
			getPreferredAgentName(collection_contacts.contact_agent_id) collection_contact_name,
			get_address(trans_agent.AGENT_ID,'email') trans_agent_email,
			getPreferredAgentName(trans_agent.AGENT_ID) trans_agent_name,
			round(RETURN_DUE_DATE - sysdate)+1 expires_in_days,
			trans_agent.trans_agent_role,
			guid_prefix,
			collection.collection_id,
			nature_of_material
		FROM
			loan,
			trans,
			collection,
			trans_agent,
			(select * from collection_contacts where contact_role='loan request') collection_contacts
		WHERE
			loan.transaction_id = trans.transaction_id AND
			trans.collection_id=collection_contacts.collection_id (+) and
			trans.collection_id=collection.collection_id and
			trans.transaction_id=trans_agent.transaction_id and
			round(RETURN_DUE_DATE - sysdate) +1 in (#eid#) and
			LOAN_STATUS != 'closed'
	</cfquery>


	<cfdump var=#expLoan#>



	<!--- local query to organize and flatten loan data --->
	<cfquery name="loan" dbtype="query">
		select
			transaction_id,
			RETURN_DUE_DATE,
			LOAN_NUMBER,
			expires_in_days,
			guid_prefix,
			nature_of_material,
			collection_id
		from
			expLoan
		group by
			transaction_id,
			RETURN_DUE_DATE,
			LOAN_NUMBER,
			expires_in_days,
			guid_prefix,
			nature_of_material,
			collection_id
	</cfquery>
	<!--- loop once for each loan --->
	<cfloop query="loan">
		<!--- local queries to organize and flatten loan data --->
		<cfquery name="inhouseAgents" dbtype="query">
			select
				trans_agent_email address,
				trans_agent_name agent_name
			from
				expLoan
			where
				transaction_id=#transaction_id# and
				trans_agent_role='in-house contact' and
				trans_agent_email is not null
			group by
				trans_agent_email,
				trans_agent_name
		</cfquery>
		<cfquery name="notificationAgents" dbtype="query">
			select
				trans_agent_email address,
				trans_agent_name agent_name
			from
				expLoan
			where
				transaction_id=#transaction_id# and
				trans_agent_role='notification contact' and
				trans_agent_email is not null
			group by
				trans_agent_email,
				trans_agent_name
		</cfquery>
		<cfquery name="collectionAgents" dbtype="query">
			select
				collection_contact_name agent_name,
				collection_contact_email address
			from
				expLoan
			where
				transaction_id=#transaction_id# and
				collection_contact_email is not null and
				trans_agent_role in ('in-house contact','authorized by')
			group by
				collection_contact_name,
				collection_contact_email
		</cfquery>
		<cfquery name="toAgents" dbtype="query">
			select
				collection_contact_name agent_name,
				collection_contact_email address,
				trans_agent_role
			from
				expLoan
			where
				transaction_id=#transaction_id# and
				trans_agent_role in ('outside contact','received by')
			group by
				collection_contact_name,
				collection_contact_email,
				trans_agent_role
		</cfquery>


	<cfdump var=#toAgents#>


		<!--- the "contact if" section of the form we'll send to notification agents --->
		<cfsavecontent variable="contacts">
			<p>
				<cfif inhouseAgents.recordcount is 1>
					<!--- there is one in-house contact --->
					Contact #inhouseAgents.agent_name# at #inhouseAgents.address# with any questions or concerns.
				<cfelseif inhouseAgents.recordcount gt 1>
					<!--- there are multiple in-house contacts --->
					Contact the following with any questions or concern:
					<ul>
					<cfloop query="inhouseAgents">
						<li>#agent_name#: #address#</li>
					</cfloop>
					</ul>
				<cfelseif collectionAgents.recordcount is 1>
					<!--- there are no in-house contacts, but there is one "loan request" agent for the collection --->
					Contact #collectionAgents.agent_name# at #collectionAgents.address# with any questions or concerns.
				<cfelseif collectionAgents.recordcount gt 1>
					<!--- there are no in-house contacts, but there are multipls "loan request" agents for the collection --->
					Contact the following with any questions or concern:
					<ul>
					<cfloop query="collectionAgents">
						<li>#agent_name#: #address#</li>
					</cfloop>
					</ul>
				<cfelse>
					<!--- there are no curatorial contacts given - send them to the Arctos contact form --->
					Please contact the Arctos folks with any questions or concerns by visiting
					<a href="#application.serverRootUrl#/contact.cfm">#application.serverRootUrl#/contact.cfm</a>
				</cfif>
			</p>
		</cfsavecontent>
		<!--- the data we'll send to everyone --->
		<cfsavecontent variable="common">
			<p>The nature of the loaned material is:
				<blockquote>#loan.nature_of_material#</blockquote>
			</p>
			<p>Specimen data for this loan, unless restricted, may be accessed at
				<a href="#application.serverRootUrl#/SpecimenResults.cfm?collection_id=#loan.collection_id#&loan_number=#loan.loan_number#">
					#application.serverRootUrl#/SpecimenResults.cfm?collection_id=#loan.collection_id#&loan_number=#loan.loan_number#
				</a>
			</p>
			<p>
				<cfif toAgents.recordcount gt 0>
					Loan Contacts are listed as follows.
					<ul>
					<cfloop query="toAgents">
						<li>#agent_name#: #address# (#trans_agent_role#)</li>
					</cfloop>
					</ul>
				</cfif>
			</p>
		</cfsavecontent>


		<cfdump var=#common#>
		<cfif notificationAgents.recordcount gt 0 and expires_in_days gte 0>
			<!---
				there's at least one noticifation agent, and the loan expires on or after today
				Loop through the list of notification agents and email each of them. Blind copy
				Dusty for a while, since it's pretty much impossible to actually test a form that
				sends email and something somewhere is probably misspelled or something
			 --->
			<cfloop query="notificationAgents">

				<br>mailto:#notificationAgents.address#
				<cfif isdefined("Application.version") and  Application.version is "prod">
					<cfset subj="Arctos Loan Notification">
					<cfset maddr=notificationAgents.address>
				<cfelse>
					<cfset maddr=application.bugreportemail>
					<cfset subj="TEST PLEASE IGNORE: Arctos Loan Notification">
				</cfif>

				<cfmail to="#maddr#" bcc="#Application.LogEmail#" subject="#subj#" from="loan_notification@#Application.fromEmail#" type="html">
					Dear #agent_name#,
					<p>
						You are receiving this message because you are listed as a contact for loan
						#loan.guid_prefix# #loan.loan_number#, due date #loan.return_due_date#.
					</p>
					#contacts#<!--- from cfsavecontent above ---->
					#common#<!--- from cfsavecontent above ---->
					#emailFooter#
				</cfmail>
			</cfloop>
		</cfif>
		<!--- and an email for each in-house contact --->
		<cfloop query="inhouseAgents">
			<cfif isdefined("Application.version") and  Application.version is "prod">
				<cfset subj="Arctos Loan Notification">
				<cfset maddr=inhouseAgents.address>
			<cfelse>
				<cfset maddr=application.bugreportemail>
				<cfset subj="TEST PLEASE IGNORE: Arctos Loan Notification">
			</cfif>
			<cfmail to="#maddr#" bcc="#Application.LogEmail#" subject="#subj#" from="loan_notification@#Application.fromEmail#" type="html">
				Dear #agent_name#,
				<p>
					You are receiving this message because you are listed as in-house contact for loan
					#loan.guid_prefix# #loan.loan_number#, due date #loan.return_due_date#.
				</p>
				<p>
					You may edit the loan, after signing in to Arctos, at
					<a href="#application.serverRootUrl#/Loan.cfm?Action=editLoan&transaction_id=#loan.transaction_id#">
						#application.serverRootUrl#/Loan.cfm?Action=editLoan&transaction_id=#loan.transaction_id#
					</a>
				</p>
				#common#
				#emailFooter#
			</cfmail>
			</cfloop>
			<cfif expires_in_days lte 0>
				<!--- the loan expires on or BEFORE today; also email the collection's loan request agent, if there is one --->
				<cfloop query="collectionAgents">
					<cfif isdefined("Application.version") and  Application.version is "prod">
						<cfset subj="Arctos Loan Notification">
						<cfset maddr=collectionAgents.address>
					<cfelse>
						<cfset maddr=application.bugreportemail>
						<cfset subj="TEST PLEASE IGNORE: Arctos Loan Notification">
					</cfif>
					<cfmail to="#maddr#" bcc="#Application.LogEmail#" subject="#subj#" from="loan_notification@#Application.fromEmail#" type="html">
						Dear #agent_name#,
						<p>
							You are receiving this message because you are listed as a #loan.guid_prefix# loan request collection contact.
							Loan #loan.guid_prefix# #loan.loan_number# due date #loan.return_due_date# is not listed as "closed."
						</p>
						<p>
							You may edit the loan, after signing in to Arctos, at
							<a href="#application.serverRootUrl#/Loan.cfm?Action=editLoan&transaction_id=#loan.transaction_id#">
								#application.serverRootUrl#/Loan.cfm?Action=editLoan&transaction_id=#loan.transaction_id#
							</a>
						</p>
						#common#
						#emailFooter#
					</cfmail>
				</cfloop>
			</cfif>
		</cfloop>
		<!--- end of loan code --->
		<!----------- permit ------------>
		<cfset cInt = "365,180,30,0">
		<!---
			permits have one (optional) contact address
			just get the stuff that's not NULL and loop with it
		---->
		<cfquery name="permit" datasource="uam_god">
			select
				permit_id,
				EXP_DATE,
				PERMIT_NUM,
				get_address(contact_agent_id,'email') ADDRESS,
				round(EXP_DATE - sysdate) expires_in_days,
				EXP_DATE
			FROM
				permit
			WHERE
				get_address(contact_agent_id,'email') is not null and
				round(EXP_DATE - sysdate) IN (#cInt#)
		</cfquery>
		<cfloop query="permit">
			<cfif isdefined("Application.version") and  Application.version is "prod">
				<cfset subj="Expiring Permits">
				<cfset maddr=permit.ADDRESS>
				<cfset ft="">
			<cfelse>
				<cfset maddr=application.bugreportemail>
				<cfset subj="TEST PLEASE IGNORE: Expiring Permits">
				<cfset ft=permit.ADDRESS>
			</cfif>
			<cfmail to="#maddr#" bcc="#Application.LogEmail#" subject="#subj#" from="reminder@#Application.fromEmail#" type="html">
				You are receiving this message because you are the contact person for a permit which expires in #expires_in_days# days.
				<p>
					<a href="#Application.ServerRootUrl#/Permit.cfm?Action=search&permit_id=#permit_id#">Permit##: #PERMIT_NUM#</a> expires on #dateformat(exp_date,'yyyy-mm-dd')#<br>
				</p>
				<br>#ft#
				#emailFooter#
			</cfmail>
		</cfloop>
		<!---- year=old accessions with no specimens ---->
		<cfquery name="yearOldAccn" datasource="uam_god">
			select
			  accn.transaction_id,
			  collection.guid_prefix,
			  collection.collection_id,
			  accn_number,
			  RECEIVED_DATE
			from
			  accn,
			  trans,
			  collection,
			  cataloged_item
			where
			  accn.accn_status != 'complete' and
			  accn.transaction_id=trans.transaction_id and
			  trans.collection_id=collection.collection_id and
			  accn.transaction_id=cataloged_item.accn_id (+) and
			  cataloged_item.accn_id is null and
			  length(RECEIVED_DATE)=10 and
			  to_char(sysdate,'YYYY-MM')=substr(RECEIVED_DATE,0,7) and
			  to_number(to_char(sysdate,'YYYY'))-to_number(substr(RECEIVED_DATE,0,4))>=1
		</cfquery>
		<cfquery name="colns" dbtype="query">
			select guid_prefix,collection_id from yearOldAccn group by guid_prefix,collection_id
		</cfquery>
		<cfloop query="colns">
			<cfset contact = functions.getCollectionContactEmail(collection_id=collection_id,contact_role="data quality")>
			<cfquery name="data" dbtype="query">
				select
					transaction_id,
					guid_prefix,
					accn_number,
					received_date
				from
					yearOldAccn
				where collection_id=#collection_id#
				group by
					transaction_id,
					guid_prefix,
					accn_number,
					received_date
			</cfquery>
			<cfif len(valuelist(contact.ADDRESS)) gt 0>
				<cfsavecontent variable="msg">
					You are receiving this message because you are the data quality contact for collection #guid_prefix#.
					<p>
						The following accessions are one or more years old and have no specimens attached.
					</p>
					<p>
						<cfloop query="data">
							<a href="#Application.ServerRootUrl#/editAccn.cfm?Action=edit&transaction_id=#transaction_id#">
								#guid_prefix# #accn_number#
							</a>
							<br>
						</cfloop>
					</p>
					#emailFooter#
				</cfsavecontent>
				<cfif isdefined("Application.version") and  Application.version is "prod">
					<cfset maddr=valuelist(contact.ADDRESS)>
					<cfset subj="Bare Accession">
				<cfelse>
					<cfset maddr=application.bugreportemail>
					<cfset subj="TEST PLEASE IGNORE:Bare Accession">
				</cfif>
				<cfmail to="#maddr#" bcc="#Application.LogEmail#" subject="#subj#" from="bare_accession@#Application.fromEmail#" type="html">
					#msg#
				</cfmail>
			</cfif>
		</cfloop>
		<!---- pending reciprocal relationships ---->
		<cfquery name="ff" datasource="uam_god">
			select
				COLLECTION_ID,
				GUID_PREFIX,
				COLLECTION_ID,
				NEW_OTHER_ID_REFERENCES,
				count(*) numRecs
			from
				cf_temp_recip_oids
			group by
				COLLECTION_ID,
				GUID_PREFIX,
				COLLECTION_ID,
				NEW_OTHER_ID_REFERENCES
		</cfquery>
		<cfquery name="collection" dbtype="query">
			select GUID_PREFIX,collection_id,sum(numRecs) totalrecs from ff group by GUID_PREFIX,collection_id
		</cfquery>
		<cfloop query="collection">
			<cfquery name="r" dbtype="query">
				select NEW_OTHER_ID_REFERENCES,numRecs from ff where collection_id=#collection_id# order by NEW_OTHER_ID_REFERENCES
			</cfquery>
			<cfset contacts = functions.getCollectionContactEmail(collection_id=collection.collection_id,contact_role="data quality")>
			<cfif contacts.recordcount gt 0>
				<cfsavecontent variable="msg">
					You are receiving this message because you are a data quality contact for collection #collection.GUID_PREFIX#.
					<p>
						There are specimens with unreciprocated relationships to your collection.
					</p>
					<p>
						You may create reciprocal relationships by going to the OtherID/Relationship bulkloader, clicking Manage,
						then following the link to reciprocal relationships or, after logging in to Arctos, by using the links below.
					</p>
					<p>Pending Relationships:</p>
					<ul>
						<li><a href="#Application.serverRootUrl#/tools/BulkloadOtherId.cfm?action=getRecip">All unreciprocated relationships to your collection(s)</a></li>
						<li><a href="#Application.serverRootUrl#/tools/BulkloadOtherId.cfm?action=getRecip&gp=#collection.GUID_PREFIX#">
							All unreciprocated relationships ---> #collection.GUID_PREFIX# (#collection.totalrecs# relationships)</a>
						</li>
						<cfloop query="r">
							<li><a href="#Application.serverRootUrl#/tools/BulkloadOtherId.cfm?action=getRecip&gp=#collection.GUID_PREFIX#&ref=#NEW_OTHER_ID_REFERENCES#">
								#NEW_OTHER_ID_REFERENCES# ---> #collection.GUID_PREFIX#  (#numRecs# relationships)</a>
							</li>
						</cfloop>
					</ul>
					<p>
						Specimens in collections to which you do not have access may not be
						visible while you're logged in; encumbered specimens may not be visible at all.
						Contact the appropriate Curators (contact information is under the <a href="#Application.serverRootUrl#/home.cfm">Portals tab</a>) with questions or concerns.
					</p>
					#emailfooter#
				</cfsavecontent>
				<cfif isdefined("Application.version") and  Application.version is "prod">
					<cfset subj="Reciprocal Relationship Notification">
					<cfset maddr=valuelist(contacts.address)>
				<cfelse>
					<cfset maddr=application.bugreportemail>
					<cfset subj="TEST PLEASE IGNORE: Reciprocal Relationship Notification">
				</cfif>
				<cfmail to="#maddr#" bcc="#Application.LogEmail#" subject="#subj#" from="relationship_notification@#Application.fromEmail#" type="html">
					#msg#
				</cfmail>
			</cfif>
		</cfloop>
	</cfoutput>
<cfinclude template="/includes/_footer.cfm">