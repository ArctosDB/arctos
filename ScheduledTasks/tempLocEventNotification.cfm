<!--- sends email to everyone in the archives for temp_{id} localities and events. Run ~monthly. --->
<cfoutput>
	<cfquery name="l" datasource="uam_god">
		select distinct get_address(CHANGED_AGENT_ID,'email') address from locality_archive where locality_id in (
			select locality_id from locality where locality_name='temp_'||locality_id
		)
	</cfquery>
	<cfquery name="c" datasource="uam_god">
		select distinct get_address(CHANGED_AGENT_ID,'email') address from collecting_event_archive where collecting_event_id in (
			select collecting_event_id from collecting_event where collecting_event_name='temp_'||collecting_event_id
		)
	</cfquery>
	<cfif l.recordcount gt 1 or c.recordcount gt 1>
		<cfquery name="ua" dbtype="query">
			select address from l union select address from c
		</cfquery>
		<cfmail to="#valuelist(ua.address)#" bcc="#Application.LogEmail#" subject="temp locality/events" from="loc_evt_tmp@#Application.fromEmail#" type="html">
			Temp localities or events have been detected. You may find these by searching locality or event name "temp_." Please un-name any
			temporarily-named localities or events for which you no longer need a name.
		</cfmail>
	</cfif>
</cfoutput>