<cfquery name="a" datasource="uam_god">
	select getJsonMediaUriBySpecimen(11470) x from dual
</cfquery>
<cfdump var=#a#>

<cfset tf=IsJSON(a.x)>
<cfdump var="#TF#">