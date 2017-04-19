unrollDynamicProperties.cfm

<cfquery name="d" datasource='prod'>
	select DYNAMICPROPERTIES,CATALOGNUMBER from temp_uwbm_mamm where rownum<100
</cfquery>
<cfoutput>
	<cfloop query="d">
		<br>#CATALOGNUMBER#: #DYNAMICPROPERTIES#
	</cfloop>
</cfoutput>