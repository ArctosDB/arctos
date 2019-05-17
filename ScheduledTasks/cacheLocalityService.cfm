<cfoutput>
	<cfquery name="d" datasource="uam_god">
		select LOCALITY_ID ,S$LASTDATE from locality where
		(S$LASTDATE is null or round(sysdate-s$lastdate)>180)
		and rownum<20
	</cfquery>
	<cfset obj = CreateObject("component","component.functions")>
	<cfset x=obj.getLocalityCacheStuff(locality_id=d.LOCALITY_ID)>
	<cfdump var=#x#>

	</cfloop>
</cfoutput>