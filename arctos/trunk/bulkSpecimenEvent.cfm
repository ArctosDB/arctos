<cfinclude template="includes/_header.cfm">
<Cfset title="Bulk Specimen Event">
<!----------------------------------------------------------------------------------->
<cfif action is "updateAll">
<cfoutput>
	<cfset sql="">
	<cfif len(collecting_event_id) gt 0>
		<cfset sql=sql & " collecting_event_id=#collecting_event_id# ">
	</cfif>
	
	<cfif len(specimen_event_type) gt 0>
		<cfif len(sql) gt 0>
			<cfset sql=sql & " , ">
		</cfif>
		
		
		<cfset sql=sql & " specimen_event_type='#specimen_event_type#' ">
	</cfif>
	
	<cfif len(verificationstatus) gt 0>
		<cfif len(sql) gt 0>
			<cfset sql=sql & " , ">
		</cfif>
		<cfset sql=sql & " verificationstatus='#verificationstatus#' ">
	</cfif>
	
	<cfif len(specimen_event_remark) gt 0>
		<cfif len(sql) gt 0>
			<cfset sql=sql & " , ">
		</cfif>
		<cfif specimen_event_remark is "NULL">
			<cfset sql=sql & " specimen_event_remark=NULL ">
		<cfelse>
			<cfset sql=sql & " specimen_event_remark='#escapeQuotes(specimen_event_remark)#' ">
		</cfif>
	</cfif>
	
	<cfif len(collecting_method) gt 0>
		<cfif len(sql) gt 0>
			<cfset sql=sql & " , ">
		</cfif>
		<cfif collecting_method is "NULL">
			<cfset sql=sql & " collecting_method=NULL ">
		<cfelse>
			<cfset sql=sql & " collecting_method='#escapeQuotes(collecting_method)#' ">
		</cfif>
	</cfif>
	
	
	<cfif len(collecting_source) gt 0>
		<cfif len(sql) gt 0>
			<cfset sql=sql & " , ">
		</cfif>
		<cfif collecting_source is "NULL">
			<cfset sql=sql & " collecting_source=NULL ">
		<cfelse>
			<cfset sql=sql & " collecting_source='#escapeQuotes(collecting_source)#' ">
		</cfif>
	</cfif>
	
	
	<cfif len(habitat) gt 0>
		<cfif len(sql) gt 0>
			<cfset sql=sql & " , ">
		</cfif>
		<cfif habitat is "NULL">
			<cfset sql=sql & " habitat=NULL ">
		<cfelse>
			<cfset sql=sql & " habitat='#escapeQuotes(habitat)#' ">
		</cfif>
	</cfif>
	
	<cfif len(sql) is 0>
		nothing to update....
		<p>
			Use your back button.
		</p>
	<cfelse>
		<cfquery name="upSE" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update specimen_event set #preservesinglequotes(sql)#  where specimen_event_id in (#specimen_event_id#)
		</cfquery>
		<cflocation url="bulkSpecimenEvent.cfm?table_name=#table_name#" addtoken="false">
	</cfif>
</cfoutput>	
</cfif>
<!----------------------------------------------------------------------------------->
<cfif action is "nothing">
	<script>
		function useThisEvent () {
			$("#collecting_event").val($('#__existingEvent option:selected').html());
			$("#collecting_event_id").val($('#__existingEvent').val());
		}
		function depickEvent() {
			$("#collecting_event").val('');
			$("#collecting_event_id").val('');
		}
	</script>
	<style>
		.highlight { background-color: yellow }
	</style>
	<cfoutput>
	<cfset title = "Change Specimen Event">
	<script src="/includes/sorttable.js"></script>
	<h2>Bulk-update specimen events</h2>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			 #table_name#.guid,
			 specimen_event.SPECIMEN_EVENT_ID,
			 specimen_event.COLLECTION_OBJECT_ID,
			 specimen_event.COLLECTING_EVENT_ID,
			 specimen_event.ASSIGNED_BY_AGENT_ID,
			 specimen_event.ASSIGNED_DATE,
			 specimen_event.SPECIMEN_EVENT_REMARK,
			 specimen_event.SPECIMEN_EVENT_TYPE,
			 specimen_event.COLLECTING_METHOD,
			 specimen_event.COLLECTING_SOURCE,
			 specimen_event.VERIFICATIONSTATUS,
			 specimen_event.HABITAT,
			 collecting_event.VERBATIM_DATE,
			 collecting_event.VERBATIM_LOCALITY,
			 collecting_event.BEGAN_DATE,
			 collecting_event.ENDED_DATE,
			 collecting_event.VERBATIM_COORDINATES,
			 collecting_event.COLLECTING_EVENT_NAME,
			 locality.spec_locality,
			 geog_auth_rec.higher_geog
		from
			#table_name#,
			specimen_event,
			collecting_event,
			locality,
			geog_auth_rec
		where
			#table_name#.collection_object_id=specimen_event.collection_object_id (+) and
			specimen_event.collecting_event_id=collecting_event.collecting_event_id (+) and
			collecting_event.locality_id=locality.locality_id (+) and
			locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id (+) 
			<cfif isdefined("exclSEID") and len(exclSEID) gt 0>
				and specimen_event.specimen_event_id not in (#exclSEID#)
			</cfif>
		order by
			#table_name#.guid,
			specimen_event.SPECIMEN_EVENT_TYPE
	</cfquery>
	
	<cfquery name="seid" dbtype="query">
		select SPECIMEN_EVENT_ID from d group by SPECIMEN_EVENT_ID
	</cfquery>
	<cfif seid.recordcount gt 999>
		This form works on a maximum of 1000 specimen-events.
		<cfabort>
	</cfif>
	<cfquery name="collevent" dbtype="query">
		select
			COLLECTING_EVENT_ID,
			VERBATIM_DATE,
			VERBATIM_LOCALITY
		from
			d
		group by
			COLLECTING_EVENT_ID,
			VERBATIM_DATE,
			VERBATIM_LOCALITY
		order by
			collecting_event_id
	</cfquery>

	<cfquery name="ctspecimen_event_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select specimen_event_type from ctspecimen_event_type order by specimen_event_type
	</cfquery>
	<cfquery name="ctverificationstatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select verificationstatus from ctverificationstatus order by verificationstatus
	</cfquery>
	<cfquery name="ctcollecting_source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select collecting_source from ctcollecting_source order by collecting_source
	</cfquery>
	
	
	
	Specimen-events
	<br>Note that this table is one row per specimen-event; specimens may be in this table multiple times.
	<br>Check boxes and click button to remove specimen-events from the update.
	<br>When this table contains only the specimen-events you want to update, use the <a href="##editForm">form below</a>.
	<form method="post" action="bulkSpecimenEvent.cfm">
		<input type="hidden" name="table_name" value="#table_name#">
		<table border id="t" class="sortable">
			<tr>
				<th>Remove</th>
				<th>GUID</th>
				<th>Specimen-Event Type</th>
				<th>Geography</th>
				<th>Spec. Locality</th>
				<th>Collecting Method</th>
				<th>Collecting Source</th>
				<th>Verification Status</th>
				<th>Habitat</th>
				<th>Verbatim Date</th>
				<th>Verbatim Locality</th>
				<th>verbatim Coordinates</th>
				<th>Event Nickname</th>
				<th>Specimen-Event Remark</th>
			</tr>
			<cfloop query="d">
				<tr>
					<td>
						<input type="checkbox" name="exclSEID" value="#specimen_event_id#">
					</td>
					<td>#GUID#</td>
					<td>#SPECIMEN_EVENT_TYPE#</td>
					<td>#higher_geog#</td>
					<td>#spec_locality#</td>
					<td>#COLLECTING_METHOD#</td>
					<td>#COLLECTING_SOURCE#</td>
					<td>#VERIFICATIONSTATUS#</td>
					<td>#HABITAT#</td>
					<td>#VERBATIM_DATE#</td>
					<td>#VERBATIM_LOCALITY#</td>
					<td>#VERBATIM_COORDINATES#</td>
					<td>#COLLECTING_EVENT_NAME#</td>
					<td>#SPECIMEN_EVENT_REMARK#</td>
				</tr>
			</cfloop>
		</table>	
		<input class="savBtn" type="submit" value="Remove Checked Rows">
	</form>
	<hr>
	<a name="editForm"></a>
	Update all records in the table above....
	<form name="se" method="post" action="bulkSpecimenEvent.cfm">
		<input type="hidden" name="specimen_event_id" value="#valuelist(seid.specimen_event_id)#">
		<input type="hidden" name="action" id="action" value="updateAll">
		<input type="hidden" name="table_name" value="#table_name#">
		<label for="collecting_event_id">Collecting Event (type Name, click button, or use the dropdown below)</label>
		<input type="hidden" name="collecting_event_id" id="collecting_event_id">
		<input type="text" size="80" name="collecting_event" id="collecting_event" onchange="findCollEvent('collecting_event_id','se','collecting_event');">
		<input type="button" class="picBtn" onclick="findCollEvent('collecting_event_id','se','collecting_event');" value="pick event">
		<input type="button" onclick="depickEvent();" value="reset/do not change event">
		<br>
		<select name="__existingEvent" id="__existingEvent" onchange="useThisEvent();">
			<option value="">Event Pick Shortcut</option>
			<cfloop query="collevent">
				<option value="#COLLECTING_EVENT_ID#">#collecting_event_id#: #VERBATIM_DATE# @ #VERBATIM_LOCALITY#</option>
			</cfloop>
		</select>
		<label for="specimen_event_type">Specimen Event Type</label>
		<select name="specimen_event_type" id="specimen_event_type">
			<option value="">Do Not Update</option>
			<cfloop query="ctspecimen_event_type">
				<option value="#specimen_event_type#">#specimen_event_type#</option>
			</cfloop>
		</select>
		<label for="verificationstatus">Verification Status (leave blank to not update; enter "NULL" to update to null)</label>
		<select name="verificationstatus" id="verificationstatus">
			<option value="">Do Not Update</option>
			<cfloop query="ctverificationstatus">
				<option value="#verificationstatus#">#verificationstatus#</option>
			</cfloop>
		</select>
		<label for="specimen_event_remark">Specimen Event Remark (leave blank to not update; enter "NULL" to update to null)</label>
		<input type="text" size="80" name="specimen_event_remark" id="specimen_event_remark">
		<label for="collecting_method">Collecting Method (leave blank to not update; enter "NULL" to update to null)</label>
		<input type="text" size="80" name="collecting_method" id="collecting_method">
		<label for="collecting_source">Collecting Source (leave blank to not update; enter "NULL" to update to null)</label>
		<select name="collecting_source" id="collecting_source">
			<option value="">Do Not Update</option>
			<cfloop query="ctcollecting_source">
				<option value="#collecting_source#">#collecting_source#</option>
			</cfloop>
		</select>
		<label for="habitat">Habitat (leave blank to not update; enter "NULL" to update to null)</label>
		<input type="text" size="80" name="habitat" id="habitat">
		<br>
		<input type="submit" class="savBtn" value="update all listed specimen events to the values in this form">
	</form>
	</cfoutput>
</cfif>
<cfinclude template="includes/_footer.cfm">