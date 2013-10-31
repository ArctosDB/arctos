<cfinclude template="/includes/_header.cfm">
	<cfoutput>		
		<cfparam name="hours" default="24" type="integer">
		DEFAULT is last 24 hours. Youc an change that by adding a URL parameter. Example:
		
		<a href="authority_change.cfm?hours=36">authority_change.cfm?hours=36</a>
		<cfquery name="geog" datasource="uam_god">
			select 
				*
			FROM 
				log_geog_auth_rec
			WHERE
				WHEN > SYSDATE - (1/#hours#)
		</cfquery>
		
		<cfdump var=#geog#>
		<cfif geog.recordcount gt 0>
			GEOG_AUTH_REC changes in the last #hours# hours:
			(o_XXX are old values; n_XXX are new.)
			<table border>
				<tr>
					<th>GEOG_AUTH_REC_ID</th>
					<th>username</th>
					<th>action_type</th>
					<th>when</th>
					<th>n_CONTINENT_OCEAN</th>
					<th>n_COUNTRY</th>
					<th>n_STATE_PROV</th>
					<th>n_COUNTY</th>
					<th>n_QUAD</th>
					<th>n_FEATURE</th>
					<th>n_ISLAND</th>
					<th>n_ISLAND_GROUP</th>
					<th>n_SEA</th>
					<th>o_CONTINENT_OCEAN</th>
					<th>o_COUNTRY</th>
					<th>o_STATE_PROV</th>
					<th>o_COUNTY</th>
					<th>o_QUAD</th>
					<th>o_FEATURE</th>
					<th>o_ISLAND</th>
					<th>o_ISLAND_GROUP</th>
					<th>o_SEA</th>
				</tr>
				<cfloop query="geog">
					<tr>
						<td>#GEOG_AUTH_REC_ID#</td>
						<td>#username#</td>
						<td>#action_type#</td>
						<td>#when#</td>
						<td>#n_CONTINENT_OCEAN#</td>
						<td>#n_COUNTRY#</td>
						<td>#n_STATE_PROV#</td>
						<td>#n_COUNTY#</td>
						<td>#n_QUAD#</td>
						<td>#n_FEATURE#</td>
						<td>#n_ISLAND#</td>
						<td>#n_ISLAND_GROUP#</td>
						<td>#n_SEA#</td>
						<td>#o_CONTINENT_OCEAN#</td>
						<td>#o_COUNTRY#</td>
						<td>#o_STATE_PROV#</td>
						<td>#o_COUNTY#</td>
						<td>#o_QUAD#</td>
						<td>#o_FEATURE#</td>
						<td>#o_ISLAND#</td>
						<td>#o_ISLAND_GROUP#</td>
						<td>#o_SEA#</td>
					</tr>
				</cfloop>
			</table>
			
		</cfif>
		
	
		<cfabort>
		
		
		
		
		
		<!--- local query to organize and flatten loan data --->
		
		
		<cfquery name="loan" dbtype="query">
			select
				transaction_id,
				RETURN_DUE_DATE,
				LOAN_NUMBER,
				expires_in_days,
				collection,
				nature_of_material,
				collection_id
			from
				expLoan
			group by
				transaction_id,
				RETURN_DUE_DATE,
				LOAN_NUMBER,
				expires_in_days,
				collection,
				nature_of_material,
				collection_id
		</cfquery>
		<!--- loop once for each loan --->
		<cfloop query="loan">
			<!--- local queries to organize and flatten loan data --->
			<cfquery name="inhouseAgents" dbtype="query">
				select
					address,
					agent_name
				from
					expLoan
				where
					transaction_id=#transaction_id# and
					trans_agent_role='in-house contact' and
					address is not null				
				group by
					address,
					agent_name
			</cfquery>
			<cfquery name="notificationAgents" dbtype="query">
				select
					address,
					agent_name
				from
					expLoan
				where
					transaction_id=#transaction_id# and
					trans_agent_role='notification contact' and
					address is not null
				group by
					address,
					agent_name
			</cfquery>
			<cfquery name="collectionAgents" dbtype="query">
				select
					collection_agent_name agent_name,
					collection_email address
				from
					expLoan
				where
					transaction_id=#transaction_id# and
					collection_email is not null
				group by
					collection_agent_name,
					collection_email
			</cfquery>
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
			</cfsavecontent>
			<cfif notificationAgents.recordcount gt 0 and expires_in_days gte 0>
				<!--- 
					there's at least one noticifation agent, and the loan expires on or after today
					Loop through the list of notification agents and email each of them. Blind copy
					Dusty for a while, since it's pretty much impossible to actually test a form that 
					sends email and something somewhere is probably misspelled or something
				 --->
				<cfloop query="notificationAgents">
					<cfmail to="#address#" bcc="arctos.database@gmail.com" 
						subject="Arctos Loan Notification" from="loan_notification@#Application.fromEmail#" type="html">
						Dear #agent_name#,
						<p>
							You are receiving this message because you are listed as a contact for loan 
							#loan.collection# #loan.loan_number#, due date #loan.return_due_date#.
						</p>
						#contacts#<!--- from cfsavecontent above ---->
						#common#<!--- from cfsavecontent above ---->
					</cfmail>
				</cfloop>
			</cfif>
			<!--- and an email for each in-house contact --->
			<cfloop query="inhouseAgents">
				<cfmail to="#address#" bcc="arctos.database@gmail.com" 
					subject="Arctos Loan Notification" from="loan_notification@#Application.fromEmail#" type="html">
					Dear #agent_name#,
					<p>
						You are receiving this message because you are listed as in-house contact for loan 
						#loan.collection# #loan.loan_number#, due date #loan.return_due_date#.
					</p>
					<p>
						You may edit the loan, after signing in to Arctos, at
						<a href="#application.serverRootUrl#/Loan.cfm?Action=editLoan&transaction_id=#loan.transaction_id#">
							#application.serverRootUrl#/Loan.cfm?Action=editLoan&transaction_id=#loan.transaction_id#
						</a>
					</p>
					#common#
				</cfmail>
			</cfloop>
			<cfif expires_in_days lte 0>
				<!--- the loan expires on or BEFORE today; also email the collection's loan request agent, if there is one --->
				<cfloop query="collectionAgents">
					<cfmail to="#address#" bcc="arctos.database@gmail.com" 
						subject="Arctos Loan Notification" from="loan_notification@#Application.fromEmail#" type="html">Dear #agent_name#,
						<p>
							You are receiving this message because you are listed as a #loan.collection# loan request collection contact. 
							Loan #loan.collection# #loan.loan_number# due date #loan.return_due_date# is not listed as "closed."
						</p>
						<p>
							You may edit the loan, after signing in to Arctos, at
							<a href="#application.serverRootUrl#/Loan.cfm?Action=editLoan&transaction_id=#loan.transaction_id#">
								#application.serverRootUrl#/Loan.cfm?Action=editLoan&transaction_id=#loan.transaction_id#
							</a>
						</p>
						#common#
					</cfmail>
				</cfloop>
			</cfif>
			<hr><hr>
		</cfloop>
		<!--- end of loan code --->
		<!----------- permit ------------>
		<cfset cInt = "365,180,30,0">
		<cfloop list="#cInt#" index="inDays">
			<cfquery name="permitExpOneYear" datasource="uam_god">
				select
					permit_id,
					EXP_DATE,
					PERMIT_NUM,
					ADDRESS,
					round(EXP_DATE - sysdate) expires_in_days,
					EXP_DATE,
					CONTACT_AGENT_ID
				FROM
					permit,
					electronic_address			
				WHERE
					permit.CONTACT_AGENT_ID = electronic_address.agent_id AND
					ADDRESS_TYPE='e-mail' AND
					round(EXP_DATE - sysdate) = #inDays#
			</cfquery>
			<cfquery name="expYearID" dbtype="query">
				select CONTACT_AGENT_ID from permitExpOneYear group by CONTACT_AGENT_ID
			</cfquery>
			<cfloop query="permitExpOneYear">
				<cfquery name="permitExpOneYearnames" dbtype="query">
					select ADDRESS from permitExpOneYear where CONTACT_AGENT_ID=#permitExpOneYear.CONTACT_AGENT_ID#
					group by ADDRESS
				</cfquery>
				<cfquery name="permitExpOneYearIndiv" dbtype="query">
					select * from permitExpOneYear where CONTACT_AGENT_ID=#CONTACT_AGENT_ID# order by expires_in_days
				</cfquery>
				<cfmail to="#permitExpOneYearnames.ADDRESS#" subject="Expiring Permits" from="reminder@#Application.fromEmail#" type="html">
					You are receiving this message because you are the contact person for the permits listed below, which are expiring.
					<p>
						<cfloop query="permitExpOneYearIndiv">
							<a href="#Application.ServerRootUrl#/Permit.cfm?Action=search&permit_id=#permit_id#">Permit##: #PERMIT_NUM#</a> expires on #dateformat(exp_date,'yyyy-mm-dd')# (#expires_in_days# days)<br>
						</cfloop>
					</p>
				</cfmail>
			</cfloop>
		</cfloop>
		<!---- year=old accessions with no specimens ---->
		<cfquery name="yearOldAccn" datasource="uam_god">
			select 
				accn.transaction_id,
				collection.collection,
				collection.collection_id,
				accn_number,
				to_char(RECEIVED_DATE,'yyyy-mm-dd') received_date
			from 
				accn,
				trans,
				collection,
				cataloged_item
			where 
				accn.transaction_id=trans.transaction_id and
				trans.collection_id=collection.collection_id and
				accn.transaction_id=cataloged_item.accn_id (+) and
				cataloged_item.accn_id is null and
				to_char(sysdate,'DD-Mon')=to_char(RECEIVED_DATE,'DD-Mon') and
				to_char(sysdate,'YYYY')-to_char(RECEIVED_DATE,'YYYY')>=1
		</cfquery>
		<cfquery name="colns" dbtype="query">
			select collection,collection_id from yearOldAccn group by collection,collection_id
		</cfquery>
		<cfloop query="colns">
			<cfquery name="contact" datasource="uam_god">
				select
					electronic_address.address
				from
					(select * from electronic_address where address_type='e-mail') electronic_address,
					(select * from collection_contacts where contact_role='data quality') collection_contacts
				where
					collection_contacts.CONTACT_AGENT_ID=electronic_address.AGENT_ID and
					collection_contacts.collection_id=#collection_id#
			</cfquery>
			<cfquery name="data" dbtype="query">
				select 
					transaction_id,
					collection,
					accn_number,
					received_date
				from
					yearOldAccn
				where collection_id=#collection_id#
				group by
					transaction_id,
					collection,
					accn_number,
					received_date
			</cfquery>
			<cfif len(valuelist(contact.ADDRESS)) gt 0>
			
				<cfsavecontent variable="msg">
					You are receiving this message because you are the data quality contact for collection #collection#.
					<p>
						The following accessions are one or more years old and have no specimens attached.
					</p>
					<p>
						<cfloop query="data">
							<a href="#Application.ServerRootUrl#/editAccn.cfm?Action=edit&transaction_id=#transaction_id#">
								#collection# #accn_number#
							</a>
							<br>
						</cfloop>
					</p>
				</cfsavecontent>
				<cfmail to="#valuelist(contact.ADDRESS)#" bcc="arctos.database@gmail.com" subject="Bare Accession" from="bare_accession@#Application.fromEmail#" type="html">
					#msg#
				</cfmail>
			</cfif>
		</cfloop>
	</cfoutput>
<cfinclude template="/includes/_footer.cfm">