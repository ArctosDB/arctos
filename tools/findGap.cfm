<cfinclude template="/includes/_header.cfm">
<cfif action is "nothing">
	Find gaps in catalog numbers:
	<cfquery name="oidnum" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select distinct(other_id_type) from coll_obj_other_id_num order by other_id_type
	</cfquery>
	<cfquery name="collection_id" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select institution_acronym||' '||collection_cde CID, collection_id from collection
		group by institution_acronym||' '||collection_cde,collection_id
		order by institution_acronym||' '||collection_cde
	</cfquery>
	<form name="go" method="post" action="findGap.cfm">
		<input type="hidden" name="action" value="cat_num">
		<select name="collection_id" size="1">
			<cfoutput query="collection_id">
				<option value="#collection_id#">#CID#</option>
			</cfoutput>
		</select>
		<input type="submit"
				value="show me the gaps" 
				class="savBtn">
	</form>
</cfif>

<cfif action is "cat_num">
<cfquery name="what" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select collection from collection where collection_id=#collection_id#
</cfquery>
<cfoutput>
<b>The following catalog number gaps exist in the #what.collection# collection.</b>
<br>
<cfquery name="b" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	WITH aquery AS
 		(SELECT cat_num_integer after_gap,
 		LAG(cat_num_integer ,1,0) OVER (ORDER BY cat_num_integer) before_gap
	 	FROM 
			cataloged_item 
		where 
			collection_id=#collection_id#)
 	SELECT
 		before_gap, after_gap
 	FROM
 		aquery
 	WHERE
 		before_gap != 0
 	AND
 		after_gap - before_gap > 1
 	ORDER BY
 		before_gap
</cfquery>
	<table border>
		<tr>
			<th>##BeforeGap</th>
			<th>##AfterGap</th>
		</tr>
		<cfloop query="b">
			<tr>
				<td>#before_gap#</td>
				<td>#after_gap#</td>
			</tr>
		</cfloop>
	</table>
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">