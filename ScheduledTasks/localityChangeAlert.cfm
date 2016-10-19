<cfinclude template="/includes/_header.cfm">
	<cfoutput>
		<cfset title="locality changes">

		<cfquery name="d" datasource="uam_god">
			select
				collection.collection_id,
				collection.guid_prefix,
				whodunit
			from
				locality_archive,
				collecting_event,
				specimen_event,
				cataloged_item,
				collection
			where
				locality_archive.locality_id=collecting_event.locality_id and
				collecting_event.collecting_event_id=specimen_event.collecting_event_id and
				specimen_event.collection_object_id=cataloged_item.collection_object_id and
				cataloged_item.collection_id=collection.collection_id
			group by
				collection.collection_id,
				collection.guid_prefix,
				whodunit
		</cfquery>

		<cfif d.recordcount is 0>
			no changes<cfabort>
		</cfif>


		<cfdump var=#d#>


		<cfabort>





		<cfset allChanges="">
		<cfset geogChanges="">
		<cfset ctChanges="">
		<cfset today = Now()>
		<cfset yesterday = dateformat(today-1,'yyyy-mm-dd') >
		<cfparam name="start" default="#dateformat(yesterday,'yyyy-mm-dd')#" type="string">
		<cfparam name="stop" default="#dateformat(now(),'yyyy-mm-dd')#" type="string">
		DEFAULT is last 24 hours. You can change that by manipulating URL parameters. Example:
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
			<cfquery name="cc" datasource="uam_god">
				select
					get_address(collection_contacts.CONTACT_AGENT_ID,'email') address
				FROM
					collection_contacts
				where
					collection_contacts.contact_role='data quality'
				group by
					get_address(collection_contacts.CONTACT_AGENT_ID,'email')
			</cfquery>
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
			<cfif isdefined("Application.version") and  Application.version is "prod">
				<cfset subj="Arctos Authority Change Notification">
				<cfset maddr="#valuelist(cc.address)#, arctos.database@gmail.com">
			<cfelse>
				<cfset maddr=application.bugreportemail>
				<cfset subj="TEST PLEASE IGNORE: Arctos Authority Change Notification">
			</cfif>
			<cfmail to="#maddr#" subject="#subj#" from="authority_notification@#Application.fromEmail#" type="html">
				#emailChanges#
			</cfmail>
		<cfelse>
			<!--- just display ---->
			#allChanges#
		</cfif>
	</cfoutput>
<cfinclude template="/includes/_footer.cfm">