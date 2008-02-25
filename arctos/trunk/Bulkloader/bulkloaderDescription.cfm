<cfif #action# is "nothing">
	<a href="bulkloaderDescription.cfm?action=descTable">Table Description</a>
	<br>
	<a href="bulkloaderDescription.cfm?action=makeAccess">Access</a>
	
</cfif>
<!----------------------------------------------->
<cfif #action# is "descTable">
	<cfquery name="desc" datasource="uam_god">
		select * from sys.user_tab_cols where table_name='BULKLOADER'
		order by column_id
	</cfquery>
	<cfoutput>
	<table border>
		<tr>
			<td>COLUMN_NAME</td>
			<td>DATA_TYPE</td>
			<td>DATA_LENGTH</td>
		</tr>
		<cfloop query="desc">
		<tr>
			<td>#COLUMN_NAME#</td>
			<td>#DATA_TYPE#</td>
			<td>#DATA_LENGTH#</td>
		</tr>
		</cfloop>
	</cfoutput>
	</table>
</cfif>
<!----------------------------------------------->
<cfif #action# is "makeAccess">
	<cfquery name="desc" datasource="uam_god">
		select * from sys.user_tab_cols where table_name='BULKLOADER'
		order by column_id
	</cfquery>
	
	<cfoutput>
	CREATE TABLE bl (
		<cfloop query="desc">
			#COLUMN_NAME# 
			
			#replace(DATA_TYPE,"VARCHAR2","CHAR")#
			<cfif #DATA_TYPE# is not "number">
				(255)
			</cfif> NULL,<br>
		</cfloop>
		)
	</cfoutput>
</cfif>