<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<script>
	function flagDupAgent(bad,good){
		$.getJSON("/component/functions.cfc",
			{
				method : "flagDupAgent",
				bad : bad,
				good : good,
				returnformat : "json",
				queryformat : 'column'
			},
			function(r) {
				var status=r.DATA.STATUS[0];
				var good=r.DATA.GOOD[0];
				var bad=r.DATA.BAD[0];
				var msg=r.DATA.MSG[0];
				
				if (status == 'success') {
					$("#fg_" + good).html('saved');
					$("#fg_" + bad).html('saved');
				} else {
					$("#fg_" + good).addClass('red');
					$("#fg_" + bad).addClass('red');
					alert(msg);
				}	
			}
		);
	}
</script>
<cfoutput>
<cfset title="Agent Duplicates">
<cfif action is "nothing">
	<p>
		The following links perform queries that attempt to locate duplicate agents. Not all results will be duplicates
		(in the sense of one individual with multiple agent_ids). Please note this in agent remarks or elsewhere should you
		discover it. 
		<br>"Whodunit" links, when provided, simply search the SQL logs 
		(Reports/Audit SQL) for the relevant term. Log data is incomplete, and the suggested search
		may not make sense.
		<br>It may also be possible to determine who created duplicates by examining Agent Activity. Please do so.
	</p>
	<a href="dupAgent.cfm?action=fullDup">Agents that share a name</a>
	<br><a href="dupAgent.cfm?action=shareFL">Person agents that share first and last name</a>
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
				[<a class="infoLink" href="/info/agentActivity.cfm?agent_id=#id1#">Activity</a>]
				[<span id="fg_#id1#" class="infoLink" onclick="flagDupAgent(#id1#,#id2#)">IsBadDupOf--></span>]
			</td>
			<td>
				#f2# #l2# (#t2#)
				[<a class="infoLink" href="/agents.cfm?agent_id=#id2#">Edit</a>]
				[<a class="infoLink" href="/Admin/ActivityLog.cfm?action=search&object=person&sql=#l2#">Whodunit</a>]	
				[<a class="infoLink" href="/info/agentActivity.cfm?agent_id=#id2#">Activity</a>]
				[<span  id="fg_#id2#" class="infoLink" onclick="flagDupAgent(#id2#,#id1#)"><--IsBadDupOf</span>]			
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
			a.agent_id id1,
			b.agent_id id2,
			a.agent_name name1,
			b.agent_name name2
		from
			agent_name a,
			agent_name b
		where 
			a.agent_name=b.agent_name and
			a.agent_id != b.agent_id
	</cfquery>
	Agents that fully share a namestring.
	<table border id="t" class="sortable">
		<tr>
			<th>Agent1</th>
			<th>Agent2</th>
		</tr>
	<cfloop query="d">
		<tr>
			<td>
				<cfquery name="one" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select
						agent_name,
						agent_name_type,
						agent_type
					from
						agent,
						agent_name
					where
						agent.agent_id=agent_name.agent_id and
						agent.agent_id=#id1#
				</cfquery>
				<cfquery name="p1" dbtype="query">
					select agent_name,agent_name_type from one order by agent_name
				</cfquery>
				Agent ID: #id1#<br>
				<cfloop query="n1">
					<cfif n1.agent_name is name1>
						<span style="font-color:red;">
							#agent_name# (#agent_name_type#)
						</span>
					<cfelse>
						#agent_name# (#agent_name_type#)
					</cfif>
					<br>
				</cfloop>
				<!---
				#name1# (#t1#)
				[<a class="infoLink" href="/agents.cfm?agent_id=#id1#">Edit</a>]
				[<a class="infoLink" href="/Admin/ActivityLog.cfm?action=search&object=agent_name&sql=#name1#">Whodunit</a>]
				[<a class="infoLink" href="/info/agentActivity.cfm?agent_id=#id1#">Activity</a>]
					[<span id="fg_#id1#" class="infoLink" onclick="flagDupAgent(#id1#,#id2#)">IsBadDupOf--></span>]
					--->
			</td>
			<td>
				<!---#name2# (#t2#)
				[<a class="infoLink" href="/agents.cfm?agent_id=#id2#">Edit</a>]
				[<a class="infoLink" href="/Admin/ActivityLog.cfm?action=search&object=agent_name&sql=#name2#">Whodunit</a>]	
				[<a class="infoLink" href="/info/agentActivity.cfm?agent_id=#id2#">Activity</a>]
					[<span id="fg_#id2#" class="infoLink" onclick="flagDupAgent(#id2#,#id1#)"><---IsBadDupOf</span>]	
					--->	
			</td>
		</tr>
	</cfloop>
	</table>
	
	</cfif>


</cfoutput>

<cfinclude template="/includes/_footer.cfm">
