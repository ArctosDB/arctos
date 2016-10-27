<cfinclude template="/includes/_header.cfm">
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
		<cfset title="locality changes">
		<cfquery name="d" datasource="uam_god">
			select
				collection.collection_id,
				collection.guid_prefix,
				whodunit,
				locality_archive.locality_id,
				count(distinct(locality_archive.locality_id)) numChanges
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
				cataloged_item.collection_id=collection.collection_id and
				CHANGEDATE >= SYSDATE - 1
			group by
				collection.collection_id,
				collection.guid_prefix,
				whodunit,
				locality_archive.locality_id
		</cfquery>


		<cfif d.recordcount is 0>
			no changes<cfabort>
		</cfif>
		<cfquery name="totLC" dbtype="query">
			select distinct(locality_id) locality_id from d
		</cfquery>
		<cfquery name="cln" dbtype="query">
			select guid_prefix from d group by guid_prefix order by guid_prefix
		</cfquery>
		<cfquery name="chgcnt" dbtype="query">
			select sum(numChanges) c from d
		</cfquery>
		<cfquery name="allusr" dbtype="query">
			select whodunit from d group by whodunit order by whodunit
		</cfquery>
		<cfsavecontent variable="bdy">
			Localities used by a collection for which you are a contact have changed.
			<table border>
				<tr>
					<th>Collection</th>
					<th>Change##</th>
					<th>Locality##</th>
					<th>User(s)</th>
					<th>Link</th>
				</tr>
				<tr>
					<td>all below</td>
					<td>#chgcnt.c#</td>
					<td>#totLC.recordcount#</td>
					<td>#valuelist(allusr.whodunit)#</td>
					<td>
						<a href="#Application.serverRootURL#/info/localityArchive.cfm?locality_id=#valuelist(totLC.locality_id)#">
							click
						</a>
					</td>
				</tr>
				<cfloop query="cln">
					<cfquery name="rc" dbtype="query">
						select
							locality_id,
							numChanges,
							whodunit
						from
							d
						where
							guid_prefix='#guid_prefix#'
					</cfquery>
					<cfquery name="cchgcnt" dbtype="query">
						select sum(numChanges) c from rc
					</cfquery>
					<cfquery name="callusr" dbtype="query">
						select whodunit from rc group by whodunit order by whodunit
					</cfquery>
					<cfquery name="ctotLC" dbtype="query">
						select distinct(locality_id) locality_id from rc
					</cfquery>
					<tr>
						<td>#guid_prefix#</td>
						<td>#cchgcnt.c#</td>
						<td>#ctotLC.recordcount#</td>
						<td>#valuelist(callusr.whodunit)#</td>
						<td>
							<a href="#Application.serverRootURL#/info/localityArchive.cfm?locality_id=#valuelist(ctotLC.locality_id)#">
								click
							</a>
						</td>
					</tr>
				</cfloop>


			</table>
			<p>
				This report reflects changes made in the last 24 hours to localities your specimens use at the end of the period.
			</p>
			<p>
				The inclusion of <strong>Collection</strong> indicates that at least one locality linked to a specimen used by the
					collection has changed. The affected locality or localities may contain specimens from several collections.
			</p>
			<p>
				Changes may have been reversed. For example, locality=here changed to locality=there changed to locality=here
				would be counted as two changes even though the end result is effectively zero changes. <strong>Change##</strong>
				indicates the cumulative change count - 2, in this example.
			</p>
			<p>
				Click the links and examine individual locality history. A complete history for each locality will be reported, not
				only the events that triggered this report.
			</p>

<!----------
			<p>

			</p>
			<cfloop query="cln">
				<cfquery name="rc" dbtype="query">
					select
						locality_id,
						numChanges,
						whodunit
					from
						d
					where
						guid_prefix='#guid_prefix#'
				</cfquery>
				<cfdump var=#rc#>
			</cfloop>
		<cfdump var=#cln#>
			<p>
				Summary:
			</p>
			<table border>
				<tr>
					<th>Collection</th>
					<th>ChangeCount</th>
					<th>User</th>
				</tr>
				<cfloop query="d">
					<tr>
						<td>#guid_prefix#</td>
						<td>#numChanges#</td>
						<td>#whodunit#</td>
					</tr>
				</cfloop>
			</table>
			---------->
		</cfsavecontent>
		<cfquery name="cc" datasource="uam_god">
			select
				get_address(collection_contacts.CONTACT_AGENT_ID,'email') address
			FROM
				collection_contacts
			where
				collection_contacts.contact_role='data quality' and
				collection_contacts.collection_id in (#valuelist(d.collection_id)#) and
				get_address(collection_contacts.CONTACT_AGENT_ID,'email') is not null
			group by
				get_address(collection_contacts.CONTACT_AGENT_ID,'email')
		</cfquery>


		<cfif isdefined("Application.version") and  Application.version is "prod">
			<cfset subj="Arctos Locality Change Notification">
			<cfset maddr=valuelist(cc.collection_contact_email)>
		<cfelse>
			<cfset maddr=application.bugreportemail>
			<cfset subj="TEST PLEASE IGNORE: Arctos Locality Change Notification">
		</cfif>
		<cfmail to="#maddr#" bcc="#Application.LogEmail#" subject="#subj#" from="locality_change@#Application.fromEmail#" type="html">
			<cfif isdefined("Application.version") and  Application.version is not "prod">
				<hr>
					prodemaillist: #valuelist(cc.address)#
				<hr>
			</cfif>

			#bdy#
			#emailFooter#
		</cfmail>



#bdy#

































		<cfabort>





		<cfset allChanges="">
		<cfset geogChanges="">
		<cfset ctChanges="">
		<cfset today = Now()>
		<cfset yesterday = dateformat(today-1,'yyyy-mm-dd') >
		<cfparam name="start" default="#dateformat(yesterday,'yyyy-mm-dd')#" type="string">
		<cfparam name="stop" default="#dateformat(now(),'yyyy-mm-dd')#" type="string">

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