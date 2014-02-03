<cfinclude template="/includes/_header.cfm">
<cfoutput>
	<cfquery name="t" datasource="uam_god">
		select table_name from user_tables order by table_name
	</cfquery>
	<form method="get" action="getDDL.cfm">
		<select name="table" id="#table#">
			<cfloop query="t">
				<option <cfif isdefined("table") and table is table_name> selected="selected" </cfif>value="#table_name#">#table_name#</option>
			</cfloop>
		</select>
		<input type="submit">
	</form>
	<cfif isdefined('table')>
		<cfquery name="d" datasource="uam_god">
			SELECT dbms_metadata.get_ddl('TABLE', '#table#') x FROM DUAL
		</cfquery>
		<textarea rows="80" cols="80">#d.x#</textarea>
	</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
