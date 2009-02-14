<cfif isdefined("cat_num")>
	<cfquery name="getDetails" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT
			collection_object_id,
		FROM 
			cataloged_item
		WHERE
				cat_num=#cat_num# AND
			 collection_id='#collection_id#'
	</cfquery>
	<cfset collection_object_id = #getDetails.collection_object_id#>
	<cfoutput>
		<table>
			<tr>
				<td align="right">Cat Num:</td>
				<td>#getDetails.cat_num#</td>
			</tr>
			<tr>
				<td align="right">Scientific Name</td>
				<td>#getDetails.scientific_name#</td>
			</tr>
		
		<cfloop query="getDetails">
			<tr>
				<td align="right">#getDetails.other_id_type#:</td>
				<td>#getDetails.other_id_num#</td>
			</tr>
		</cfloop>
		</table>
		<script language="JavaScript">
			parent._part.location.href="editParts.cfm?collection_object_id=#collection_object_id#"
		</script>
	</cfoutput>
	<cfelse>
		<cfabort>
</cfif>