<cfquery name="bulk" datasource="#Application.uam_dbo#">
	select * from bulkloader
</cfquery>
<cfform action="editBulkloader.cfm" enablecab="yes" name="bl" enctype="application/x-www-form-urlencoded">
	<cfgrid name="bulkdata" height="250" width="600" query="bulk" sort="yes" griddataalign="left" gridlines="yes" rowheaders="yes" selectmode="edit">
	</cfgrid>

</cfform>