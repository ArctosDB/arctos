	<cfinclude template="/includes/_header.cfm">

<cfoutput>

<cfquery name="c" datasource="uam_god">
	select data from county order by data
</cfquery>

<cfloop query="c">
	#data#<br>
</cfloop>
			</cfoutput>
		<cfinclude template="/includes/_footer.cfm">

