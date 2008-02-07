<cfabort>
<cfquery name="getColls" datasource="#uam_dbo#">
	SELECT 
		collector.collection_object_id,
		agent_name,
		coll_order
	FROM
		collector,
		preferred_agent_name,
		cataloged_item
	WHERE
		collector.agent_id = preferred_agent_name.agent_id AND
		collector_role='c' AND
		collection_id <> 2
</cfquery>
<cfquery name="uCollObjId" dbtype="query">
	SELECT DISTINCT(collection_object_id) FROM getColls ORDER BY collection_object_id
</cfquery>
<cfoutput>
	<cfloop query="uCollObjId">
		<cfquery name="one" dbtype="query">
			SELECT * FROM getColls WHERE
			collection_object_id = #uCollObjId.collection_object_id#
		</cfquery>
		<cfset thisColl = "">
		<cfloop query="one">
			<cfif len(#thisColl#) is 0>
				<cfset thisColl = "#agent_name#">
			<cfelse>
				<cfset thisColl = "#thisColl#, #agent_name#">
			</cfif>
		</cfloop>
		<cfquery name="ins" datasource="#uam_dbo#">
			INSERT INTO manis_collector (
				collection_object_id,
				collector )
			VALUES (
				#uCollObjId.collection_object_id#,
				'#thisColl#')
		</cfquery>
	
	</cfloop>
</cfoutput>