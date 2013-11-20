<cfinclude template="/includes/_header.cfm">
	<cfoutput>
		<cfset allChanges="">
		<cfset geogChanges="">
		<cfset today = Now()>
		<cfset yesterday = CreateDate(Year(Now()),Month(Now()),Day(Now()-1))>
		<cfparam name="start" default="#dateformat(yesterday,'yyyy-mm-dd')#" type="string">
		
		
		<cfparam name="stop" default="#dateformat(now(),'yyyy-mm-dd')#" type="string">
		DEFAULT is last 24 hours. You can change that by adding a URL parameter. Example:
		
		<a href="authority_change.cfm?hours=36">authority_change.cfm?start=#start#&stop=#stop#</a>
		<cfquery name="geog" datasource="uam_god">
			select 
				*
			FROM 
				log_geog_auth_rec
			WHERE
				WHEN between to_date('#start#') and to_date('#stop#')> SYSDATE - (#hours#/24)
		</cfquery>
		
		<p>
			There have been #geog.recordcount# GEOG_AUTH_REC changes in the last #hours# hours.
		</p>
		<cfif geog.recordcount gt 0>
			<cfsavecontent variable="geogChanges">
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
			</cfsavecontent>
			#geogChanges#
		</cfif>
		<!--- append everything together ---->
		
		<cfset allChanges=geogChanges>
		
		<cfif action is "sendEmail">
			<cfif len(geogChanges) gt 0>
				<cfquery name="gids" dbtype="query">
					select geog_auth_rec_id from geog group by geog_auth_rec_id
				</cfquery>
				<cfquery name="cc" datasource="uam_god">
					select 
						electronic_address.address
					FROM 
						locality,
						collecting_event,
						specimen_event,
						cataloged_item,
						collection,
						collection_contacts,
						preferred_agent_name,
						electronic_address
					where
						locality.locality_id=collecting_event.locality_id and
						collecting_event.collecting_event_id=specimen_event.collecting_event_id and
						specimen_event.collection_object_id=cataloged_item.collection_object_id and
						cataloged_item.collection_id=collection.collection_id and
						collection.collection_id=collection_contacts.collection_id and
						collection_contacts.CONTACT_AGENT_ID=preferred_agent_name.agent_id and
						preferred_agent_name.agent_id=electronic_address.agent_id and
						locality.GEOG_AUTH_REC_ID in (#valuelist(gids.geog_auth_rec_id)#) and
						electronic_address.address_type='e-mail' and
						collection_contacts.contact_role='data quality'
					group by 
						electronic_address.address
				</cfquery>
			</cfif>
			
			<cfsavecontent variable="emailChanges">
				Geography used by a collection for which you are a "data quality" contact has changed.
				<p>#geogChanges#</p>
			</cfsavecontent>
			email to: #valuelist(cc.address)#
			<br>#emailChanges#
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