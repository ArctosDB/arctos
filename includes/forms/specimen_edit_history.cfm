<cfinclude template="/includes/_frameHeader.cfm">
<cfoutput>
	<cfquery name="eh" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from flat_edit_history where collection_object_id=#collection_object_id# order by EDIT_DATE desc
	</cfquery>
	<cfdump var=#eh#>
	<table border>
		<tr>
			<th>Source</th>
			<th>User</th>
			<th>Date</th>
		</tr>
		<cfloop query="eh">
			<tr>
				<td>#EDITED_TABLE#</td>
				<td>#USER_P_NAME#</td>
				<td>#EDIT_DATE#</td>
			</tr>
		</cfloop>
	</table>
</cfoutput>
