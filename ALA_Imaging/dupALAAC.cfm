<cfinclude template="/includes/_header.cfm">
	<cfoutput>
		<cfquery name="dupRec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				count(*) cnt,
				display_value 
			from 
				coll_obj_other_id_num
			where
				other_id_type='ALAAC'
			having
				count(*) > 1
			group by
				display_value
		</cfquery>
		<table border>
		<cfloop query="dupRec">
			<tr>
				<td>#display_value#</td>
				<td>#cnt#</td>
			</tr>
		</cfloop>
		</table>

	</cfoutput>

<cfinclude template="/includes/_footer.cfm">
