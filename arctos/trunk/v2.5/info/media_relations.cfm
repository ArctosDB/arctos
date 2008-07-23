<cfquery name="relns" datasource="#application.web_user#">
	select * from media_relations,
	preferred_agent_name
	where
	media_relations.created_by_agent_id = preferred_agent_name.agent_id and
	media_id=#media_id#
</cfquery>
<cfoutput>
    <table border>
        <th>Media Relationship</th>
        <cfloop query="relns">
            
        </cfloop>
    </table>
</cfoutput>