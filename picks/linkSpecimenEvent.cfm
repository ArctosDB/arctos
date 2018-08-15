<!--- no security --->
<cfinclude template="../includes/_pickHeader.cfm">
<cfset title = "Specimen Event Pick">

<!--- get events for this specimen --->
<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select
		specimen_event.SPECIMEN_EVENT_ID,
		specimen_event.SPECIMEN_EVENT_REMARK,
		specimen_event.SPECIMEN_EVENT_TYPE,
		specimen_event.COLLECTING_METHOD,
		specimen_event.COLLECTING_SOURCE,
		specimen_event.VERIFICATIONSTATUS,
		getPreferredAgentName(specimen_event.VERIFIED_BY_AGENT_ID) verified_by,
		collecting_event.verbatim_date,
		collecting_event.VERBATIM_LOCALITY,
		collecting_event.BEGAN_DATE,
		collecting_event.ENDED_DATE,
		collecting_event.COLLECTING_EVENT_NAME,
		locality.SPEC_LOCALITY,
		locality.DEC_LAT,
		locality.DEC_LONG,
		locality.LOCALITY_NAME,
		geog_auth_rec.higher_geog
	from
		specimen_event,
		collecting_event,
		locality,
		geog_auth_rec
	where
		specimen_event.collecting_event_id=collecting_event.collecting_event_id and
		collecting_event.locality_id=locality.locality_id and
		locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
		specimen_event.COLLECTION_OBJECT_ID=#COLLECTION_OBJECT_ID#
</cfquery>

<cfoutput>

<table border>
	<tr>
		<th>SpecimenEventType</th>
		<th>Date</th>
		<th>VerbatimLocality</th>
		<th>CollMeth</th>
		<th>CollSource</th>
		<th>Verification</th>
		<th>HigherGeog</th>
		<th>EventName</th>
		<th>LocalityName</th>
		<th>SpecLocality</th>
		<th>Coordinates</th>
		<th>EventRemark</th>
		<th>control</th>
	</tr>
	<cfloop query="d">
		<tr>
			<td>#SPECIMEN_EVENT_TYPE#</td>
			<td>#verbatim_date# (#BEGAN_DATE#-#ENDED_DATE#)</td>
			<td>#VERBATIM_LOCALITY#</td>
			<td>#COLLECTING_METHOD#</td>
			<td>#COLLECTING_SOURCE#</td>
			<td>#VERIFICATIONSTATUS# (#verified_by#)</td>
			<td>#higher_geog#</td>
			<td>#COLLECTING_EVENT_NAME#</td>
			<td>#LOCALITY_NAME#</td>
			<td>#SPEC_LOCALITY#</td>
			<td>#DEC_LAT#/#DEC_LONG#</td>
			<td>#SPECIMEN_EVENT_REMARK#</td>
			<td>#SPECIMEN_EVENT_ID#</td>
		</tr>
	</cfloop>
</table>
</cfoutput>
<cfinclude template="../includes/_pickFooter.cfm">