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
				getPreferredAgentName(locality_archive.changed_agent_id) whodunit,
				locality_archive.locality_id,
				count(distinct(locality_archive.locality_archive_id)) numChanges
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
				cataloged_item.collection_id=collection.collection_id and (
					CHANGEDATE >= SYSDATE - 1 or
					locality_archive.locality_id in (select locality_id from geology_archive where CHANGEDATE >= SYSDATE - 1)
				)
			group by
				collection.collection_id,
				collection.guid_prefix,
				getPreferredAgentName(locality_archive.changed_agent_id),
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
			<cfset maddr=valuelist(cc.address)>
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

