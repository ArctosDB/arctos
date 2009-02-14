<cfinclude template="/includes/_header.cfm">
	<cfoutput>
		<cfquery name="coll" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select
				*
			from
				collection
		</cfquery>
		<cfloop query="coll">
			<cfquery name="members" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select
					mem.agent_name
				from
					agent_name mem,
					group_member,
					agent_name grp
				where
					mem.agent_id = group_member.member_agent_id and
					mem.agent_name_type='login' and
					group_member.group_agent_id = grp.agent_id and
					grp.agent_name = '#institution_acronym# #collection_cde# Data Entry Group'
			</cfquery>
			<cfquery name="admins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select
					mem.agent_name
				from
					agent_name mem,
					group_member,
					agent_name grp
				where
					mem.agent_id = group_member.member_agent_id and
					mem.agent_name_type='login' and
					group_member.group_agent_id = grp.agent_id and
					grp.agent_name = '#institution_acronym# #collection_cde# Data Admin Group'
			</cfquery>
			<cfset users = ''>
			<cfloop query="members">
				<cfif len(#users#) is 0>
					<cfset users = "'#agent_name#'">
				<cfelse>
					<cfset users = "#users#,'#agent_name#'">
				</cfif>
			</cfloop>
			<cfloop query="admins">
				<cfif len(#users#) is 0>
					<cfset users = "'#agent_name#'">
				<cfelse>
					<cfset users = "#users#,'#agent_name#'">
				</cfif>
			</cfloop>
			<cfif len(#users#) gt 0>
				<cfquery name="bl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select 
						loaded,
						collection_object_id,
						enteredby
					from bulkloader
					where loaded is not null and loaded !='waiting approval' and
					enteredby in (#preservesinglequotes(users)#)
					order by enteredby, loaded, collection_object_id
				</cfquery>
				<cfquery name="addrs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select address 
					from
						electronic_address,
						agent_name
					where address_type='e-mail' and
					electronic_address.agent_id = agent_name.agent_id and
					agent_name in (#preservesinglequotes(users)#)
					group by address
				</cfquery>
				<hr>
				To: #valuelist(addrs.address)#<br>
				<table border>
					<tr>
						<th>Collection_Object_Id</th>
						<th>EnteredBy</th>
						<th>Problem</th>
					</tr>
				<cfloop query="bl">
					<tr>
						<td>#collection_object_id#</td>
						<td>#enteredby#</td>
						<td>#loaded#</td>
					</tr>
				</cfloop>
				</table>
			</cfif>
		</cfloop>
	</cfoutput>
<cfinclude template="/includes/_footer.cfm">
