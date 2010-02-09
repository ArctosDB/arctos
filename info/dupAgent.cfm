<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>

<cfoutput>
<cfset title="Agent Duplicates">
<cfif action is "nothing">
	<a href="dupAgent.cfm?action=fullDup">Agents that share a name</a>
	<a href="dupAgent.cfm?action=shareFL">Person agents that share first and last name</a>
</cfif>

<cfif action is "shareFL">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select
			per1.first_name f1,
			per1.last_name l1,
			per2.first_name f2,
			per2.last_name l2,
			per1.person_id id1,
			per2.person_id id2,
			p1.agent_name pn1,
			p2.agent_name pn2
		from
			person per1,
			person per2,
			preferred_agent_name p1,
			preferred_agent_name p2
		where 
			per1.first_name=per2.first_name and
			per1.last_name=per2.last_name and
			per1.person_id != per1.person_id and
			per1.person_id=p1.agent_id and
			per2.person_id=p2.agent_id
	</cfquery>
	Persons that share first and last name.
	<br>
	"Whodunit" links search the SQL logs for an insert of the relevant name, and will not be complete for legacy data.
	Removing "Object" may find more results.
	<table border id="t" class="sortable">
		<tr>
			<th>F/L 1</th>
			<th>F/L 2</th>
			<th>Preferred1</th>
			<th>Preferred2</th>
		</tr>
	<cfloop query="d">
		<tr>
			<td>
				#f1# #l1# (#t1#)
				[<a class="infoLink" href="/agents.cfm?agent_id=#id1#">Edit</a>]
				[<a class="infoLink" href="/Admin/ActivityLog.cfm?action=search&object=person&sql=#l1#">Whodunit</a>]
				[<a class="infoLink" href="http://arctos-test.arctos.database.museum/info/agentActivity.cfm?agent_id=#id1#">Activity</a>]
			</td>
			<td>
				#f2# #l2# (#t2#)
				[<a class="infoLink" href="/agents.cfm?agent_id=#id2#">Edit</a>]
				[<a class="infoLink" href="/Admin/ActivityLog.cfm?action=search&object=person&sql=#l2#">Whodunit</a>]	
				[<a class="infoLink" href="http://arctos-test.arctos.database.museum/info/agentActivity.cfm?agent_id=#id2#">Activity</a>]			
			</td>
			<td>#pn1#</td>
			<td>#pn2#</td>
		</tr>
	</cfloop>
	</table>
	
	</cfif>

<cfif action is "fullDup">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select
			a.agent_name name1,
			b.agent_name name2,
			a.agent_name_type t1,
			b.agent_name_type t2,
			a.agent_id id1,
			b.agent_id id2,
			p1.agent_name pn1,
			p2.agent_name pn2
		from
			agent_name a,
			agent_name b,
			preferred_agent_name p1,
			preferred_agent_name p2
		where 
			a.agent_name=b.agent_name and
			a.agent_id != b.agent_id and
			a.agent_id=p1.agent_id and
			b.agent_id=p2.agent_id
	</cfquery>
	Agents that fully share a namestring.
	<br>
	"Whodunit" links search the SQL logs for an insert of the relevant name, and will not be complete for legacy data.
	Removing "Object" may find more results.
	<table border id="t" class="sortable">
		<tr>
			<th>Name1</th>
			<th>Name2</th>
			<th>Preferred1</th>
			<th>Preferred2</th>
		</tr>
	<cfloop query="d">
		<tr>
			<td>
				#name1# (#t1#)
				[<a class="infoLink" href="/agents.cfm?agent_id=#id1#">Edit</a>]
				[<a class="infoLink" href="/Admin/ActivityLog.cfm?action=search&object=agent_name&sql=#name1#">Whodunit</a>]
				[<a class="infoLink" href="http://arctos-test.arctos.database.museum/info/agentActivity.cfm?agent_id=#id1#">Activity</a>]
			</td>
			<td>
				#name2# (#t2#)
				[<a class="infoLink" href="/agents.cfm?agent_id=#id2#">Edit</a>]
				[<a class="infoLink" href="/Admin/ActivityLog.cfm?action=search&object=agent_name&sql=#name2#">Whodunit</a>]	
				[<a class="infoLink" href="http://arctos-test.arctos.database.museum/info/agentActivity.cfm?agent_id=#id2#">Activity</a>]			
			</td>
			<td>#pn1#</td>
			<td>#pn2#</td>
		</tr>
	</cfloop>
	</table>
	
	</cfif>


</cfoutput>

<cfinclude template="/includes/_footer.cfm">
