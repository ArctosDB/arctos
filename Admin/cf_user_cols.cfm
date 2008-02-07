<cfinclude template="/includes/_header.cfm">
<cfif #action# is "nothing">
	<cfquery name="d" datasource="uam_god">
		select * from cf_spec_res_cols order by DISP_ORDER, column_name
	</cfquery>
	<cfoutput>
		If you aren't a developer, go away.
		<form name="d" method="post" action="cf_user_cols.cfm">
		<input type="hidden" name="action" value="save">
		<table border>
		<tr>
			<th>COLUMN_NAME</th>
			<th>SQL_ELEMENT</th>
			<th>CATEGORY</th>
			<th>DISPLAY_VALUE</th>
			<th>DISP_ORDER</th>
		</tr>
		<cfloop query="d">
			<tr>
				<td>
					<input type="text" name="COLUMN_NAME__#cf_spec_res_cols_id#" value="#COLUMN_NAME#">
				</td>
				<td>
					<input type="text" name="SQL_ELEMENT__#cf_spec_res_cols_id#" value="#SQL_ELEMENT#">
				</td>
				<td>
					<input type="text" name="CATEGORY__#cf_spec_res_cols_id#" value="#CATEGORY#">
				</td>
				<td>
					<input type="text" name="DISPLAY_VALUE__#cf_spec_res_cols_id#" value="#DISPLAY_VALUE#">
				</td>
				<td>
					<input type="text" name="DISP_ORDER__#cf_spec_res_cols_id#" value="#DISP_ORDER#">
				</td>
			</tr>
		</cfloop>
		</table>
		<input type="submit">
		</form>
	</cfoutput>
</cfif>
<cfif #action# is "save">
		<cfquery name="d" datasource="uam_god">
			select cf_spec_res_cols_id from cf_spec_res_cols
		</cfquery>
		<cfoutput>
		<cfloop query="d">
			<cfset thisCOLUMN_NAME = evaluate("column_name__" & cf_spec_res_cols_id)>
			<cfset thisSQL_ELEMENT = evaluate("SQL_ELEMENT__" & cf_spec_res_cols_id)>
			<cfset thisCATEGORY = evaluate("CATEGORY__" & cf_spec_res_cols_id)>
			<cfset thisDISPLAY_VALUE = evaluate("DISPLAY_VALUE__" & cf_spec_res_cols_id)>
			<cfset thisDISP_ORDER = evaluate("DISP_ORDER__" & cf_spec_res_cols_id)>
			<cfquery name="u" datasource="uam_god">
				update cf_spec_res_cols set
					COLUMN_NAME = '#thisCOLUMN_NAME#',
					SQL_ELEMENT = '#thisSQL_ELEMENT#',
					CATEGORY = '#thisCATEGORY#',
					DISPLAY_VALUE = '#thisDISPLAY_VALUE#',
					DISP_ORDER = #thisDISP_ORDER#
				where cf_spec_res_cols_id = #cf_spec_res_cols_id#			
			</cfquery>
		</cfloop>
		<cflocation url="cf_user_cols.cfm">
		</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">