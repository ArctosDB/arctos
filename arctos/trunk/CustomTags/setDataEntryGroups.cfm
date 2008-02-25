<cfquery name="get_admin_group" datasource="#Application.web_user#">
	select 
			grp.agent_name,
			grp.agent_id
		from
			preferred_agent_name grp,
			agent_name usr,
			group_member
		where
			grp.agent_id=group_member.GROUP_AGENT_ID and
			group_member.MEMBER_AGENT_ID = usr.agent_id and
			usr.agent_name='#client.username#' and
			grp.agent_name like '% Data Admin Group'
</cfquery>
<cfset admGrps = "">
<cfloop query="get_admin_group">
	<cfif len(#admGrps#) is 0>
		<cfset admGrps = "'#agent_name#'">
	<cfelse>
		<cfset admGrps = "#admGrps#,'#agent_name#'">
	</cfif>
</cfloop>
<cfset admGrps = replace(admGrps," Data Admin Group"," Data Entry Group","all")>
<cfquery name="get_entry_group" datasource="#Application.web_user#">
	select 
			grp.agent_name,
			grp.agent_id
		from
			preferred_agent_name grp,
			agent_name usr,
			group_member
		where
			grp.agent_id=group_member.GROUP_AGENT_ID and
			group_member.MEMBER_AGENT_ID = usr.agent_id and
			usr.agent_name='#client.username#' and
			grp.agent_name like '% Data Entry Group'
</cfquery>
<cfif len(#valuelist(get_admin_group.agent_id)#) gt 0>
	<cfquery name="admin_for_users" datasource="#Application.web_user#">
		select 
			entry.agent_name 
		FROM
			group_member,
			agent_name admin,
			agent_name entry
		where 
			group_member.member_agent_id = entry.agent_id AND
			entry.agent_name_type='login' AND
			group_member.group_agent_id = admin.agent_id AND
			admin.agent_name IN (#preservesinglequotes(admGrps)#) 			
		GROUP BY
			entry.agent_name
	</cfquery>
	<cfset caller.adminForUsers = valuelist(admin_for_users.agent_name)>
<cfelse>
	<cfset caller.adminForUsers = "">
</cfif>

<cfset caller.inAdminGroups = valuelist(get_admin_group.agent_name)>
<cfset caller.inEntryGroups = valuelist(get_entry_group.agent_name)>

<cfset caller.adminForGroups = replace(valuelist(get_admin_group.agent_name)," Data Admin Group"," Data Entry Group","all")>
