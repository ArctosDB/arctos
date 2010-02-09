<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>

<cfoutput>
<cfset title="Agent Duplicates">
<cfif action is "nothing">
	<a href="dupAgent.cfm?action=fullDup">Agents that share a name</a>
</cfif>


<cfif action is "fullDup">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select
			a.agent_name name1,
			a.agent_id id1,
			b.agent_id id2
		from
			agent_name a,
			agent_name b
		where 
			a.agent_name=b.agent_name and
			a.agent_id != b.agent_id
	</cfquery>
	Citations by Taxonomy:
	<table border id="t" class="sortable">
		<th>
			<td>Agent1</td>
			<td>Agent2</td>
		</th>
	<cfloop query="d">
		<tr>
			<td>#name1#</td>
			<td>
				#id1# - #id2#
			</td>
			
		</tr>
	</cfloop>
	</table>
	
	</cfif>


</cfoutput>

<cfinclude template="/includes/_footer.cfm">
