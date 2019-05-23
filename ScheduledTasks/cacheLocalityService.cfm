<!----
select count(*) from locality where (S$LASTDATE is null or round(sysdate-s$lastdate)>180);
505455
503899

		select count(*) from locality where S$LASTDATE is null;
			select count(distinct(locality.locality_id)) from locality,collecting_event,specimen_event
			 where locality.locality_id=collecting_event.locality_id and
			 collecting_event.collecting_event_id=specimen_event.collecting_event_id and
			 locality.S$LASTDATE is null;
			 -- only a few hundred, not worth paying the cost of the query

		 and rownum<25



---->


<cfoutput>
	<cfset obj = CreateObject("component","component.functions")>
	<!--- prioritize NULL ---->
	<cfquery name="d" datasource="uam_god">
		select LOCALITY_ID from locality where S$LASTDATE is null and rownum<50
	</cfquery>
	<cfif d.recordcount lt 1>
		<!--- everything has something, now refresh ---->
		<cfquery name="d" datasource="uam_god">
			select LOCALITY_ID ,S$LASTDATE from locality where round(sysdate-s$lastdate)>365 and rownum<50
		</cfquery>
	</cfif>

	<cfloop query="d">
		<br>#d.LOCALITY_ID#
		<cfset obj.getLocalityCacheStuff(locality_id=d.LOCALITY_ID)>
	</cfloop>
</cfoutput>