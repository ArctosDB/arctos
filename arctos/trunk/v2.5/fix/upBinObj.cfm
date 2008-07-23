<cfquery name="s" datasource="#Application.uam_dbo#">
	select * from binary_object
</cfquery>
<cfoutput>
<cfdump var=#s#>
</cfoutput>