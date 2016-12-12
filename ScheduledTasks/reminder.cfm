<cfinclude template="/includes/_header.cfm">
<cfset functions = CreateObject("component","component.functions")>
<cfsavecontent variable="emailFooter">
	<div style="font-size:smaller;color:gray;">
		--
		<br>Don't want these messages? Update Collection Contacts.
		<br>Want these messages? Update Collection Contacts, make sure you have a valid email address.
		<br>Links not working? Log in, log out, or check encumbrances.
		<br>Need help? Send email to arctos.database@gmail.com
	</div>
</cfsavecontent>
<cfoutput>

	<!--- start of encumbrance code --->
	<!----
		get encumbrances which are expiring in #mnths#
		Ignore anything without specimens
		send emails
	---->
	<cfset mnths="0,6,12,24,36,48">
	<cfquery name="raw" datasource="uam_god">
		select
			collection.guid_prefix,
			get_address(collection_contacts.contact_agent_id,'email') collection_contact_email,
			encumbrance.ENCUMBRANCE_ID,
			getPreferredAgentName(encumbrance.ENCUMBERING_AGENT_ID) encumberer,
			to_char(encumbrance.EXPIRATION_DATE,'yyyy-mm-dd') EXPIRATION_DATE,
			encumbrance.ENCUMBRANCE,
			encumbrance.REMARKS,
			to_char(encumbrance.MADE_DATE,'yyyy-mm-dd') MADE_DATE,
			encumbrance.ENCUMBRANCE_ACTION,
			count(distinct(cataloged_item.collection_object_id)) nspc
		from
			encumbrance,
			coll_object_encumbrance,
			cataloged_item,
			collection,
			collection_contacts
		where
			encumbrance.encumbrance_id=coll_object_encumbrance.encumbrance_id and
			coll_object_encumbrance.collection_object_id=cataloged_item.collection_object_id and
			cataloged_item.collection_id=collection.collection_id and
			collection.collection_id=collection_contacts.collection_id and
			to_char(EXPIRATION_DATE,'yyyy-mm-dd') in (
				<cfloop list="#mnths#" index="i">
					to_char(add_months(sysdate,#i#),'yyyy-mm-dd')
					<cfif i is not 48>
						,
					</cfif>
				</cfloop>
			)
		group by
			collection.guid_prefix,
			encumbrance.ENCUMBRANCE_ID,
			getPreferredAgentName(encumbrance.ENCUMBERING_AGENT_ID),
			encumbrance.EXPIRATION_DATE,
			encumbrance.ENCUMBRANCE,
			encumbrance.REMARKS,
			encumbrance.MADE_DATE,
			encumbrance.ENCUMBRANCE_ACTION,
			get_address(collection_contacts.contact_agent_id,'email')
	</cfquery>
	<cfquery name="enc" dbtype="query">
		select
			ENCUMBRANCE_ID,
			EXPIRATION_DATE,
			ENCUMBRANCE,
			REMARKS,
			MADE_DATE,
			ENCUMBRANCE_ACTION,
			encumberer
		from
			raw
		group by
			ENCUMBRANCE_ID,
			EXPIRATION_DATE,
			ENCUMBRANCE,
			REMARKS,
			MADE_DATE,
			ENCUMBRANCE_ACTION,
			encumberer
	</cfquery>
	<cfloop query="enc">
		<cfquery name="mt" dbtype="query">
			select
				collection_contact_email
			from
				raw
			where
				collection_contact_email is not null and
				encumbrance_id=#encumbrance_id#
			group by
				collection_contact_email
		</cfquery>
		<cfquery name="sp" dbtype="query">
			select guid_prefix,nspc from raw where encumbrance_id=#encumbrance_id# group by guid_prefix,nspc
		</cfquery>
		<cfif isdefined("Application.version") and  Application.version is "prod">
			<cfset subj="Arctos Encumbrance Notification">
			<cfset maddr=Application.logEmail>
			<cfset maddr=listappend(maddr,valuelist(mt.collection_contact_email))>
		<cfelse>
			<cfset maddr=application.bugreportemail>
			<cfset subj="TEST PLEASE IGNORE: Arctos Encumbrance Notification">
		</cfif>
		<cfmail to="#maddr#" bcc="#Application.LogEmail#" subject="#subj#" from="encumbrance_notification@#Application.fromEmail#" type="html">
			<p>
				You are receiving this message because you are a collection contact for a collection holding encumbered specimens.
			</p>
			<p>
				Please review encumbrance <strong>#enc.ENCUMBRANCE#</strong> created by <strong>#enc.encumberer#</strong> on
				<strong>#enc.MADE_DATE#</strong>, expires <strong>#enc.EXPIRATION_DATE#</strong>.
			</p>
			<p>
				Specimen data are available at
				<a href="#Application.serverRootURL#/SpecimenResults.cfm?encumbrance_id=#encumbrance_id#">
					#Application.serverRootURL#/SpecimenResults.cfm?encumbrance_id=#encumbrance_id#
				</a>
			</p>
			<p>
				The encumbrance may be accessed at
				<a href="#Application.serverRootURL#/Encumbrances.cfm?action=updateEncumbrance&encumbrance_id=#encumbrance_id#">
					#Application.serverRootURL#/Encumbrances.cfm?action=updateEncumbrance&encumbrance_id=#encumbrance_id#
				</a>
			</p>
			<p>
				Please remove specimens from and delete any un-needed encumbrances.
			</p>
			<p>
				Summary of encumbered specimens:
				<cfloop query="sp">
					<p>
					#guid_prefix#: #nspc#
					</p>
				</cfloop>
			</p>
			#emailFooter#
		</cfmail>
	</cfloop>
	<!--- end of encumbrance code --->

	<!--- start of loan code --->
	<!--- days after and before return_due_date on which to send email. Negative is after ---->
	<cfset eid="-365,-180,-150,-120,-90,-60,-30,-7,0,7,30">
	<!---
		Query to get all loan data from the server. Use GOD query so we can ignore collection partitions.
		This form has no output and relies on system time to run, so only danger is in sending multiple copies
		of notification to loan folks. No real risk in not using a lesser agent for the queries.

		v7.2.2 and before: email various people at various times
		after: email everybody always
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
		<!---- all contact agents --->

		<cfquery name="aloanAgents" dbtype="query">
			select
				TRANS_AGENT_NAME agent_name,
				TRANS_AGENT_EMAIL address,
				trans_agent_role
			from
				expLoan
			where
				transaction_id=#transaction_id#
			union all
			select
				COLLECTION_CONTACT_NAME agent_name,
				COLLECTION_CONTACT_EMAIL address,
				'collection contact agent' trans_agent_role
			from
				expLoan
			where
				transaction_id=#transaction_id# and
				COLLECTION_CONTACT_EMAIL is not null
		</cfquery>
		<!--- uniques --->
		<cfquery name="loanAgents" dbtype="query">
			select agent_name,address,trans_agent_role from aloanAgents group by agent_name,address,trans_agent_role
		</cfquery>
		<cfquery name="mailToAgentAddrs" dbtype="query">
			select distinct address from loanAgents where trans_agent_role in ('collection contact agent','in-house contact','authorized by','notification contact')
		</cfquery>
		<cfif isdefined("Application.version") and  Application.version is "prod">
			<cfset subj="Arctos Loan Notification">
			<cfset maddr=Application.logEmail>
			<cfset maddr=listappend(maddr,valuelist(mailToAgentAddrs.address))>
		<cfelse>
			<cfset maddr=application.bugreportemail>
			<cfset subj="TEST PLEASE IGNORE: Arctos Loan Notification">
		</cfif>
		<cfmail to="#maddr#" bcc="#Application.LogEmail#" subject="#subj#" from="loan_notification@#Application.fromEmail#" type="html">
			<p>
				You are receiving this message because you are listed as a contact for loan
				#loan.guid_prefix# #loan.loan_number#, due date #loan.return_due_date#.
			</p>
			<p>The nature of the loaned material is:
				<blockquote>#loan.nature_of_material#</blockquote>
			</p>
			<p>Specimen data for this loan, unless restricted, may be accessed at
				<a href="#application.serverRootUrl#/SpecimenResults.cfm?loan_trans_id=#loan.transaction_id#">
					#application.serverRootUrl#/SpecimenResults.cfm?loan_trans_id=#loan.transaction_id#
				</a>
			</p>
			<p>
				You may edit the loan, after signing in to Arctos, at
				<a href="#application.serverRootUrl#/Loan.cfm?Action=editLoan&transaction_id=#loan.transaction_id#">
					#application.serverRootUrl#/Loan.cfm?Action=editLoan&transaction_id=#loan.transaction_id#
				</a>
			</p>
			<p>
				Loan Contacts are listed as follows.
				<ul>
				<cfloop query="loanAgents">
					<li>#agent_name#: #address# (#trans_agent_role#)</li>
				</cfloop>
				</ul>
			</p>
			#emailFooter#
		</cfmail>
		</cfloop>
		<!--- end of loan code------------------------------------------------------------------------------------------ --->

	<!---- slip a DOI report in here - does anyone use the crap we build? ---->
	<!----
	create table cf_doi_report (
		publication_type varchar2(255),
		hascount number,
		nopecount number,
		checkdate date
	);


	disabling this; https://goo.gl/T2NTqO


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

	---->
	<!---- /slip a DOI report in here for now.... ---->



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
				<cfset maddr=Application.logEmail>
				<cfset maddr=listappend(maddr,permit.ADDRESS)>
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

					<cfset maddr=Application.logEmail>
					<cfset maddr=listappend(maddr,valuelist(contact.ADDRESS))>
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
					<cfset maddr=Application.logEmail>
					<cfset maddr=listappend(maddr,valuelist(contacts.address))>
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