<!----
select count(*) from locality where (S$LASTDATE is null or round(sysdate-s$lastdate)>180);
505455
503899
---->
<cfoutput>
	<cfset obj = CreateObject("component","component.functions")>
	<cfquery name="d" datasource="uam_god">
		select LOCALITY_ID ,S$LASTDATE from locality where
		(S$LASTDATE is null or round(sysdate-s$lastdate)>180)
		and rownum<5
	</cfquery>
	<cfloop query="d">
		<br>#d.LOCALITY_ID#
		<cfset obj.getLocalityCacheStuff(locality_id=d.LOCALITY_ID)>
	</cfloop>
</cfoutput>