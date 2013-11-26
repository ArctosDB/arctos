<cfinclude template="/includes/_header.cfm">
	<cfoutput>
		<cfset title="authority file changes">
		<cfset allChanges="">
		<cfset geogChanges="">
		<cfset ctChanges="">
		<cfset today = Now()>
		<cfset yesterday = CreateDate(Year(Now()),Month(Now()),Day(Now()-1))>
		<cfparam name="start" default="#dateformat(yesterday,'yyyy-mm-dd')#" type="string">
		
		
		<cfparam name="stop" default="#dateformat(now(),'yyyy-mm-dd')#" type="string">
		DEFAULT is last 24 hours. You can change that by adding a URL parameter. Example:
		
		<a href="authority_change.cfm?start=#start#&stop=#stop#">authority_change.cfm?start=#start#&stop=#stop#</a>
		
		
		
		<cfquery name="ctlogtbl" datasource="uam_god">
			select 
				table_name
			FROM 
				user_tables
			WHERE
				table_name like 'LOG_CT%'
		</cfquery>
		
		<cfloop query="ctlogtbl">
			<cfquery name="ctab" datasource="uam_god">
				select * from #table_name# where WHEN between to_date('#start#') and to_date('#stop#') order by when
			</cfquery>
			<cfif ctab.recordcount gt 0>
				<cfsavecontent variable="ctChanges">
					#ctChanges#
					<p>Table #replace(table_name,'LOG_','','all')#:</p>
					<table border>
						<tr>
						<cfloop list="#ctab.columnlist#" index="c">
							<th>#c#</th>	
						</cfloop>
						</tr>
						<cfloop query="#ctab#">
							<tr>
								<cfloop list="#ctab.columnlist#" index="c">
									<td>#evaluate("ctab." & c)#</td>	
								</cfloop>
							</tr>
						</cfloop>
					</table>
				</cfsavecontent>
			</cfif>
		</cfloop>
		
		
		<cfif len(ctChanges) gt 0>
			<cfsavecontent variable="ctChanges">
				<p>
					Code tables changed between #start# and #stop#.
					These data may reflect discarded changes, changes that have not been used in data, or changes that your 
					user cannot access. Contact any Arctos Advisory Group member for more information.			
					<br>Rows with only N_xxx (new) values are INSERTS.
					<br>Rows with only O_xxx (old) values are DELETES.
					<br>Rows with N_xxx and O_xxx values are UPDATES.
				</p>
				#ctChanges#
			</cfsavecontent>
		</cfif>
		
		<cfquery name="geog" datasource="uam_god">
			select 
				*
			FROM 
				log_geog_auth_rec
			WHERE
				WHEN between to_date('#start#') and to_date('#stop#')
		</cfquery>
		
		
		<cfif geog.recordcount gt 0>
			<cfsavecontent variable="geogChanges">
				<p>
					GEOG_AUTH_REC changed between #start# and #stop#.
					<br>(o_XXX are old values; n_XXX are new.)
				</p>
				
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
			</cfsavecontent>
		</cfif>
		<!--- append everything together ---->
		
		<cfset allChanges=geogChanges & ctChanges>
		
		
		<cfif len(allChanges) is 0>
			no changes.
			<cfabort>
		</cfif>
		
		
		
		
		
		
		
		<cfif action is "sendEmail">
			<cfif len(geogChanges) gt 0>
				<cfquery name="cc" datasource="uam_god">
					select 
						electronic_address.address
					FROM 
						collection_contacts,
						preferred_agent_name,
						electronic_address
					where
						collection_contacts.CONTACT_AGENT_ID=preferred_agent_name.agent_id and
						preferred_agent_name.agent_id=electronic_address.agent_id and
						electronic_address.address_type='e-mail' and
						collection_contacts.contact_role='data quality'
					group by 
						electronic_address.address
				</cfquery>
			</cfif>
			
			<cfsavecontent variable="emailChanges">
				<p>
					Authority values have changed.
				</p>
				<p>
					You are receiving this report because you are a collection "data quality" contact,
					or because you are receiving forwarded email from arctos.database@gmail.com.
				</p>
				<p>
					This report is available at #application.serverRootURL#/ScheduledTasks/authority_change.cfm?start=#start#&stop=#stop#
				</p>
				<p>#allChanges#</p>
			</cfsavecontent>
			
			
			<hr>
			email to: #valuelist(cc.address)#, arctos.database@gmail.com
			<br>#emailChanges#
			</hr>
		<cfelse>
			<!--- just display ---->
			#allChanges#
		</cfif>
	
<!-----		
		
		
		
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
					
					
					
					---------->
	</cfoutput>
<cfinclude template="/includes/_footer.cfm">