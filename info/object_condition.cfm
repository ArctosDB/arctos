<cfinclude template="/includes/_pickHeader.cfm">
<cfoutput>
<!---- see what we're getting a condition of ---->
<cfquery name="itemDetails" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
		'cataloged item' part_name,
		cat_num,
		collection.collection,
		scientific_name
	FROM
		cataloged_item,
		collection,
		identification
	WHERE
		cataloged_item.collection_object_id = identification.collection_object_id AND
		accepted_id_fg=1 AND
		cataloged_item.collection_id = collection.collection_id AND
		cataloged_item.collection_object_id = #collection_object_id#
	UNION
	select 
			part_name,
			cat_num,
			collection.collection,
			scientific_name
		FROM
			cataloged_item,
			collection,
			identification,
			specimen_part
		WHERE
			cataloged_item.collection_object_id = identification.collection_object_id AND
			accepted_id_fg=1 AND
			cataloged_item.collection_id = collection.collection_id AND
			cataloged_item.collection_object_id = specimen_part.derived_from_cat_item AND
			specimen_part.collection_object_id = #collection_object_id#
</cfquery>

<strong>Condition History of #itemDetails.collection# #itemDetails.cat_num#
(<i>#itemDetails.scientific_name#</i>) #itemDetails.part_name#</strong>
<cfquery name="cond" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
		object_condition_id,
		determined_agent_id,
		agent_name,
		determined_date,
		condition
	from object_condition,preferred_agent_name
		where determined_agent_id = agent_id and
		collection_object_id = #collection_object_id#
		group by
		object_condition_id,
		determined_agent_id,
		agent_name,
		 determined_date,
		 condition
		order by determined_date DESC
</cfquery>




<table border>
	<tr>
		<td><strong>Determined By</strong></td>
		<td><strong>Date</strong></td>
		<td><strong>Condition</strong></td>
	</tr>
	
	<cfloop query="cond">
		<tr>
			<td>
				#agent_name#
			</td>
			<td>
				<cfset thisDate = #dateformat(determined_date,"dd mmm yyyy")#>
				#thisDate#
			</td>
			<td>
				#condition#
			</td>
		</tr>
	</cfloop>
</table>
</cfoutput>
<cfinclude template="/includes/_pickFooter.cfm">