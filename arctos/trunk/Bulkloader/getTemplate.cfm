<cfinclude template="/includes/_header.cfm">
<cfif action is "nothing">
<cfquery name="blt" datasource="uam_god">
	select column_name from user_tab_cols where table_name='BULKLOADER'
	order by internal_column_id
</cfquery>
<cfoutput>
	<form name="f" method="post" action="getTemplate.cfm">
		<input type="hidden" name="action" value="getTemplate">
		<label for="format">Format</label>
		<select name="format" id="format">
			<option value="tab">Tab-delimited text</option>
		</select>
		<input type="submit" value="build template">
		<cfloop query="blt">
			#column_name# <input type="checkbox" name="fld" value="#column_name#">
		</cfloop>
	</form>
</cfoutput>
</cfif>
<cfif action is 'getTemplate'>
	<cfdump var=#form#>
</cfif>