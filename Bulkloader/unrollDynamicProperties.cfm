unrollDynamicProperties.cfm

<cfquery name="d" datasource='prod'>
	select DYNAMICPROPERTIES,CATALOGNUMBER from temp_uwbm_mamm where rownum<100
</cfquery>
<cfoutput>
	<cfloop query="d">
		<br>#CATALOGNUMBER#: #DYNAMICPROPERTIES#
		<cfset x=DeserializeJSON(DYNAMICPROPERTIES)>
		<cfdump var=#x#>
	</cfloop>
</cfoutput>