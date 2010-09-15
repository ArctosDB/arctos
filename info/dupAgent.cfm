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
<cfif not isdefined("start")>
	<cfset start=1>
</cfif>
<cfif not isdefined("stop")>
	<cfset stop=100>
</cfif>
<cfif isdefined("int")>
	<cfif int is "next">
		<cfset start=start+100>
		<cfset stop=stop+100>
	<cfelseif int is "prev">
		<cfset start=start-100>
		<cfset stop=stop-100>
	</cfif>
</cfif>
<cfif action is "shareFL">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		Select * from (
			Select a.*, rownum rnum From (
				select
					per1.first_name || ' ' || per1.last_name name1,
					per2.first_name || ' ' || per2.last_name name2,
					per1.person_id id1,
					per2.person_id id2,
					rownum r
				from
					person per1,
					person per2
				where 
					per1.first_name=per2.first_name and
					per1.last_name=per2.last_name and
					per1.person_id != per2.person_id  
				order by
					per1.first_name,per1.last_name
			) a where rownum <= #stop#
		) where rnum >= #start#
	</cfquery>
	#start# to #stop# Persons that share first and last name.
	<br><a href="dupAgent.cfm?action=#action#&int=next">[ next 100 ]</a>
	<br><a href="dupAgent.cfm?action=#action#&int=prev">[ previous 100 ]</a>
	<!----
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
	---->
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
			a.agent_id != b.agent_id and
			rownum<100
		group by
			a.agent_id,
			b.agent_id,
			a.agent_name,
			b.agent_name
	</cfquery>
	First 100 Agents that fully share a namestring.
	
</cfif>
<cfif isdefined("D")>
	<blockquote>
		<div>
			preferred_name
			<span style="font-size:small"> (agent_id)</span>
		</div>
		<div style="color:red;">
			shared_name (shared_name may be the same as preferred_name for zero, one, or both agents)
		</div>
		<div>
			[ other names ]
		</div>
		<div style="color:red;">
			[ activities which might preclude automated merger ]
		</div>
	</blockquote>
	(agent_relations flag excludes relationships of "bad duplicate of")
	<table border id="t" class="sortable">
		<tr>
			<th>Agent1</th>
			<th>Agent2</th>
		</tr>
	<cfloop query="d">
		<tr>
			<td valign="top">
				<cfquery name="one" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select
						agent_name,
						agent_name_type,
						agent_type,
						agent_name_id
					from
						agent,
						agent_name
					where
						agent.agent_id=agent_name.agent_id and				
						agent.agent_id=#id1#
					group by
						agent_name,
						agent_name_type,
						agent_type,
						agent_name_id
				</cfquery>
				<cfquery name="p1" dbtype="query">
					select * from one where agent_name_type='preferred'
				</cfquery>
				<cfquery name="np1" dbtype="query">
					select * from one where agent_name_type!='preferred' and
					agent_name != '#name1#'
					order by agent_name
				</cfquery>
				<div>
					#p1.agent_name#
					<span style="font-size:small"> (#d.id1#)</span>
				</div>
				<div style="color:red;">
					#d.name1#
				</div>
				<cfloop query="np1">
					<div>
						#agent_name# (#agent_name_type#)
					</div>
				</cfloop>
				<cfquery name="project_agent" datasource="uam_god">
					select 
						count(*) c
					from 
						project_agent
					where
						project_agent.agent_name_id IN (#valuelist(one.agent_name_id)#)
				</cfquery>
				<cfif project_agent.c gt 0>
					<div style="color:red;">project agent</div>
				</cfif>
				<cfquery name="publication_author_name" datasource="uam_god">
					select 
						count(*) c
					from
						publication_author_name
					where
						publication_author_name.agent_name_id IN (#valuelist(one.agent_name_id)#)
				</cfquery>
				<cfif publication_author_name.c gt 0>
					<div style="color:red;">publication agent</div>
				</cfif>
				<cfquery name="project_sponsor" datasource="uam_god">
					select 
						count(*) c
					from 
						project_sponsor
					where
						 project_sponsor.agent_name_id IN (#valuelist(one.agent_name_id)#)
				</cfquery>
				<cfif project_sponsor.c gt 0>
					<div style="color:red;">proj sponsor agent</div>
				</cfif>
				<cfquery name="electronic_address" datasource="uam_god">
					select count(*) c from electronic_address where agent_id=#id1#
				</cfquery>
				<cfif electronic_address.c gt 0>
					<div style="color:red;">electronic_address</div>
				</cfif>
				<cfquery name="addr" datasource="uam_god">
					select count(*) c from addr where agent_id=#id1#
				</cfquery>
				<cfif addr.c gt 0>
					<div style="color:red;">addr</div>
				</cfif>
				<cfquery name="shipment" datasource="uam_god">
					select 
						count(*) c 
					from
						shipment
					where
						PACKED_BY_AGENT_ID=#id1#		
				</cfquery>
				<cfif shipment.c gt 0>
					<div style="color:red;">shipment</div>
				</cfif>
				<cfquery name="ship_to" datasource="uam_god">
					select 
						count(*) c 
					from
						shipment,
						addr
					where
						shipment.SHIPPED_TO_ADDR_ID=addr.addr_id and
						addr.agent_id=#id1#
				</cfquery>
				<cfif ship_to.c gt 0>
					<div style="color:red;">ship_to</div>
				</cfif>
				<cfquery name="ship_from" datasource="uam_god">
					select 
						count(*) c 
					from
						shipment,
						addr
					where
						shipment.SHIPPED_FROM_ADDR_ID=addr.addr_id and
						addr.agent_id=#id1#
				</cfquery>
				<cfif ship_from.c gt 0>
					<div style="color:red;">ship_from</div>
				</cfif>				
				<cfquery name="agent_relations" datasource="uam_god">
					select count(*) c 
					from agent_relations
					where 	
					( 
						agent_relations.agent_id=#id1# or 
						RELATED_AGENT_ID=#id1#
					) and
					agent_relationship != 'bad duplicate of'
				</cfquery>
				<cfif agent_relations.c gt 0>
					<div style="color:red;">agent_relations</div>
				</cfif>
				<div>
					[<a class="likeLink" href="/agents.cfm?agent_id=#id1#">Edit</a>]
					[<a class="likeLink" href="/Admin/ActivityLog.cfm?action=search&object=agent_name&sql=#name1#">Whodunit</a>]
					[<a class="likeLink" href="/info/agentActivity.cfm?agent_id=#id1#">Activity</a>]
					[<span id="fg_#id1#" class="likeLink" onclick="flagDupAgent(#id1#,#id2#)">IsBadDupOf--></span>]
				</div>
			</td>
			<td valign="top">
				<cfquery name="two" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select
						agent_name,
						agent_name_type,
						agent_type,
						agent_name_id
					from
						agent,
						agent_name
					where
						agent.agent_id=agent_name.agent_id and				
						agent.agent_id=#id2#
					group by
						agent_name,
						agent_name_type,
						agent_type,
						agent_name_id
					order by agent_name
				</cfquery>
				<cfquery name="p2" dbtype="query">
					select * from two where agent_name_type='preferred'
				</cfquery>
				<cfquery name="np2" dbtype="query">
					select * from two where agent_name_type!='preferred' and
					agent_name != '#name2#'
					order by agent_name
				</cfquery>
				<div>
					#p2.agent_name#
					<span style="font-size:small"> (#d.id2#)</span>
				</div>
				<div style="color:red;">
					#d.name2#
				</div>
				<cfloop query="np2">
					<div>
						#agent_name# (#agent_name_type#)
					</div>
				</cfloop>
				<cfquery name="project_agent" datasource="uam_god">
					select 
						count(*) c
					from 
						project_agent
					where
						project_agent.agent_name_id IN (#valuelist(two.agent_name_id)#)
				</cfquery>
				<cfif project_agent.c gt 0>
					<div style="color:red;">project agent</div>
				</cfif>
				<cfquery name="publication_author_name" datasource="uam_god">
					select 
						count(*) c
					from
						publication_author_name
					where
						publication_author_name.agent_name_id IN (#valuelist(two.agent_name_id)#)
				</cfquery>
				<cfif publication_author_name.c gt 0>
					<div style="color:red;">publication agent</div>
				</cfif>
				<cfquery name="project_sponsor" datasource="uam_god">
					select 
						count(*) c
					from 
						project_sponsor
					where
						 project_sponsor.agent_name_id IN (#valuelist(two.agent_name_id)#)
				</cfquery>
				<cfif project_sponsor.c gt 0>
					<div style="color:red;">proj sponsor agent</div>
				</cfif>
				<cfquery name="electronic_address" datasource="uam_god">
					select count(*) c from electronic_address where agent_id=#id2#
				</cfquery>
				<cfif electronic_address.c gt 0>
					<div style="color:red;">electronic_address</div>
				</cfif>
				<cfquery name="addr" datasource="uam_god">
					select count(*) c from addr where agent_id=#id2#
				</cfquery>
				<cfif addr.c gt 0>
					<div style="color:red;">addr</div>
				</cfif>
				<cfquery name="shipment" datasource="uam_god">
					select 
						count(*) c 
					from
						shipment
					where
						PACKED_BY_AGENT_ID=#id2#		
				</cfquery>
				<cfif shipment.c gt 0>
					<div style="color:red;">shipment</div>
				</cfif>
				<cfquery name="ship_to" datasource="uam_god">
					select 
						count(*) c 
					from
						shipment,
						addr
					where
						shipment.SHIPPED_TO_ADDR_ID=addr.addr_id and
						addr.agent_id=#id2#
				</cfquery>
				<cfif ship_to.c gt 0>
					<div style="color:red;">ship_to</div>
				</cfif>
				<cfquery name="ship_from" datasource="uam_god">
					select 
						count(*) c 
					from
						shipment,
						addr
					where
						shipment.SHIPPED_FROM_ADDR_ID=addr.addr_id and
						addr.agent_id=#id2#
				</cfquery>
				<cfif ship_from.c gt 0>
					<div style="color:red;">ship_from</div>
				</cfif>
				<cfquery name="agent_relations" datasource="uam_god">
					select count(*) c 
					from agent_relations
					where 	
					( 
						agent_relations.agent_id=#id2# or 
						RELATED_AGENT_ID=#id2#
					) and
					agent_relationship != 'bad duplicate of'
				</cfquery>
				<cfif agent_relations.c gt 0>
					<div style="color:red;">agent_relations</div>
				</cfif>
				<div>
					[<a class="likeLink" href="/agents.cfm?agent_id=#id2#">Edit</a>]
					[<a class="likeLink" href="/Admin/ActivityLog.cfm?action=search&object=agent_name&sql=#name2#">Whodunit</a>]	
					[<a class="likeLink" href="/info/agentActivity.cfm?agent_id=#id2#">Activity</a>]
					[<span id="fg_#id2#" class="likeLink" onclick="flagDupAgent(#id2#,#id1#)"><---IsBadDupOf</span>]	
				</div>
			</td>
		</tr>
	</cfloop>
	</table>
	
	</cfif>


</cfoutput>

<cfinclude template="/includes/_footer.cfm">
