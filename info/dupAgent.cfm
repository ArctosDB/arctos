<cfinclude template="/includes/_header.cfm">

<cfif not isdefined("noFNAbbr")>
	<cfset noFNAbbr=''>
</cfif>

<cfif not isdefined("exclRelated")>
	<cfset exclRelated=''>
</cfif>

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
		(in the sense of one individual with multiple agent_ids). There really are two people named Robert Rausch, for example.
		Please note this in agent remarks or elsewhere should you
		discover it.
	</p>
	<p>
		"Whodunit" links, when provided, simply search the SQL logs
		(Reports/Audit SQL) for the relevant term. Log data is incomplete, and the suggested search
		may not make sense.
	</p>
	<p>
		It may also be possible to determine who created duplicates by examining Agent Activity. Please do so; they need remedial training.
	</p>
	<p>Each agent will appear only one time in the resulting table, so given agents:</p>
	<ul>
		<li>Bob Jones (1)</li>
		<li>Bob Jones (2)</li>
		<li>Bob Jones (3)</li>
	</ul>
	you will see only
	<table border>
		<tr>
			<td>Bob Jones (1)</td>
			<td>Bob Jones (2)</td>
		</tr>
	</table>
	<p>rather than all possibilities, e.g.,</p>
	<table border>
		<tr>
			<td>Bob Jones (1)</td>
			<td>Bob Jones (2)</td>
		</tr>
		<tr>
			<td>Bob Jones (2)</td>
			<td>Bob Jones (1)</td>
		</tr>

		<tr>
			<td>Bob Jones (1)</td>
			<td>Bob Jones (3)</td>
		</tr>
		<tr>
			<td colspan="2" align="center">.....</td>
		</tr>
	</table>
	<p>
		Merge agents and return to this form to see agents excluded by the "appears only once" rule.
	</p>
	<p>Format is:</p>
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
	<p>
		agent_relations flag excludes relationships of "bad duplicate of"
	</p>
	<p>
		Some guidelines, which are only guidelines and may be mutually exclusive or self-defeating:
		<ul>
			<li>Flag "badDupOf" for the agent with the least activity. Agents who have addresses, produce publications,
				have relationships, etc. are difficult to deal with. Keep them if you can.
			</li>
			<li>
				Don't even try to use this form if both duplicates have activity. Clean those up manually. Agent Actiity
				is a good place to start.
			</li>
			<li>
				Don't keep superflous junk. Given two agents representing the same person, both with no activity:
				<ul>
					<li>Bob Jones (preferred)</li>
				</ul>
				and
				<ul>
					<li>Bob Jones (preferred)</li>
					<li>Bob Jones (full)</li>
					<li>Jones, B. (last plus initials)</li>
					<li>Jones, B. (AKA)</li>
				</ul>
				keep the simple one and ditch the more complex variant.
			</li>
		</ul>
	</p>



	<a href="dupAgent.cfm?action=fullDup">Find Agents that share a name</a>
	<br><a href="dupAgent.cfm?action=shareFL">Find Person agents that share first and last name</a>
	<br><a href="dupAgent.cfm?action=shareFL&noFNAbbr=true">Find Person agents that share first and last name, no dots in first name</a>
	<br><a href="dupAgent.cfm?action=shareFL&noFNAbbr=true&exclRelated=true">Find Person agents that share first and last name, no dots in first name, no relationships</a>
	<br><a href="dupAgent.cfm?action=nameVariants">Find Agents by name variations</a>



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
<cfif action is "nameVariants">


<!--- make any changes here to component/agent as well ---->
	<cfset nvars=ArrayNew(1)>

	<cfquery name="ds_ct_namesynonyms" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select names from ds_ct_namesynonyms
	</cfquery>
	<cfloop query="ds_ct_namesynonyms">
		<cfset ArrayAppend(nvars, names)>
	</cfloop>

	<cfset numberOfRows=arraylen(nvars)>
	<cfif not isdefined("thisrow") or len(thisrow) is 0>
		<cfset thisrow=1>
	</cfif>
	<p>
		You are on <strong>#thisrow#</strong> of <strong>#numberOfRows#</strong> agent variation groupings.
		<cfif thisrow gt 1>
			<cfset prev=thisrow-1>
			<a href="/info/dupAgent.cfm?action=nameVariants&thisrow=#prev#">previous</a>
		</cfif>
		<cfif thisrow lt numberOfRows>
			<cfset next=thisrow+1>
			<a href="/info/dupAgent.cfm?action=nameVariants&thisrow=#next#">next</a>
		</cfif>
	</p>

	<cfset p=nvars[thisrow]>

	<p>
		Running for agent group #p#
	</p>
	<p>
		It will almost always be worthwhile to edit the "good" agent and add the "bad" name variant as a synonym.
	</p>
	<cfset thesql="">
	<cfset numVarnts=listlen(p)>
	<cfset lt1=numVarnts-1>
	<cfloop from="1" to="#lt1#" index="a1">
		<cfloop from="2" to="#numVarnts#" index="a2">
			<cfset agent1=listgetat(p,a1)>
			<cfset agent2=listgetat(p,a2)>
			<cfset thisstmt="select
				a.preferred_agent_name name1,
				a.agent_id id1,
				b.agent_id id2,
				b.preferred_agent_name name2
			from
				agent a,
				agent b
			where
				a.agent_id!=b.agent_id and
				a.preferred_agent_name=replace(b.preferred_agent_name,'#agent1#','#agent2#')">
			<cfif len(thesql) is 0>
				<cfset thesql=thisstmt>
			<cfelse>
				<cfset thesql=thesql & ' UNION ' & thisstmt>
			</cfif>
		</cfloop>
	</cfloop>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		#preservesinglequotes(thesql)#
	</cfquery>
	<cfif d.recordcount is 0>
		<p>nothing found - yay - use the links above</p>
	</cfif>
</cfif>

<cfif action is "shareFL">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		Select * from (
	      Select a.*, rownum rnum From (
	        select
	          p1_first_name.agent_name || ' ' || p1_last_name.agent_name name1,
	          p2_first_name.agent_name || ' ' || p2_last_name.agent_name name2,
	          p1_first_name.agent_id id1,
	          p2_first_name.agent_id id2,
	          rownum r
	        from
	          agent_name p1_first_name,
	          agent_name p1_last_name,
	          agent_name p2_first_name,
	          agent_name p2_last_name
	        where
	          p1_first_name.agent_name_type='first name' and
	          p2_first_name.agent_name_type='first name' and
	          p1_last_name.agent_name_type='last name' and
	          p2_last_name.agent_name_type='last name' and
	          p1_first_name.agent_id=p1_last_name.agent_id and
	          p2_first_name.agent_id=p2_last_name.agent_id and
	          p1_first_name.agent_id != p2_first_name.agent_id and
	          p1_first_name.agent_name = p2_first_name.agent_name and
	          p1_last_name.agent_name = p2_last_name.agent_name
			<cfif noFNAbbr is "true">
				and p1_first_name.agent_name not like '%.%'
				and p2_first_name.agent_name not like '%.%'
			</cfif>
			<cfif exclRelated is "true">
				and p1_first_name.agent_id not in (select agent_id from agent_relations union select related_agent_id agent_id from agent_relations)
				and p2_first_name.agent_id not in (select agent_id from agent_relations union select related_agent_id agent_id from agent_relations)
			</cfif>
	        order by
	          name1
	      ) a where rownum <= #stop#
	    ) where rnum >= #start#
	</cfquery>
	#start# to #stop# Persons that share first and last name.
</cfif>

<cfif action is "fullDup">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		Select * from (
			Select a.*, rownum rnum From (
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
				group by
					a.agent_id,
					b.agent_id,
					a.agent_name,
					b.agent_name
				order by
					a.agent_name
			) a where rownum <= #stop#
		) where rnum >= #start#
	</cfquery>
	#start# to #stop# Agents that fully share a namestring.
</cfif>
<cfif isdefined("d")>
	<cfif action is not "nameVariants">
		<cfif start gt 1>
			<a href="dupAgent.cfm?action=#action#&start=#start#&stop=#stop#&int=prev&noFNAbbr=#noFNAbbr#&exclRelated=#exclRelated#">[ previous 100 ]</a>
		</cfif>
		<a href="dupAgent.cfm?action=#action#&start=#start#&stop=#stop#&int=next&noFNAbbr=#noFNAbbr#&exclRelated=#exclRelated#">[ next 100 ]</a>
		<a href="dupAgent.cfm">[ start over ]</a>
	</cfif>

	<table border id="t" class="sortable">
		<tr>
			<th>Agent1</th>
			<th>Agent2</th>
		</tr>
		<cfset usedAgentIdList="">
	<cfloop query="d">
		<cfif not listcontains(usedAgentIdList,id1) and not listcontains(usedAgentIdList,id2)>
			<cfset usedAgentIdList=listappend(usedAgentIdList,id1)>
			<cfset usedAgentIdList=listappend(usedAgentIdList,id2)>
			<tr>
				<td valign="top">
					<cfquery name="one" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
							#agent_name# (#agent_type#)
						</div>
					</cfloop>
					<cfquery name="project_agent" datasource="uam_god">
						select
							count(*) c
						from
							project_agent
						where
							project_agent.agent_id=#id1#
					</cfquery>
					<cfif project_agent.c gt 0>
						<div style="color:red;">project agent</div>
					</cfif>
					<cfquery name="publication_agent" datasource="uam_god">
						select
							count(*) c
						from
							publication_agent
						where
							publication_agent.agent_id =#id1#
					</cfquery>
					<cfif publication_agent.c gt 0>
						<div style="color:red;">publication agent</div>
					</cfif>
					<cfquery name="address" datasource="uam_god">
						select count(*) c from address where agent_id=#id1#
					</cfquery>
					<cfif address.c gt 0>
						<div style="color:red;">address</div>
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
							address
						where
							shipment.SHIPPED_TO_ADDR_ID=address.address_id and
							address.agent_id=#id1#
					</cfquery>
					<cfif ship_to.c gt 0>
						<div style="color:red;">ship_to</div>
					</cfif>
					<cfquery name="ship_from" datasource="uam_god">
						select
							count(*) c
						from
							shipment,
							address
						where
							shipment.SHIPPED_FROM_ADDR_ID=address.address_id and
							address.agent_id=#id1#
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
					<cfquery name="coll" datasource="uam_god">
						select
							guid_prefix
						from
							collection,
							cataloged_item,
							collector
						where
							collection.collection_id=cataloged_item.collection_id and
							cataloged_item.collection_object_id=collector.collection_object_id and
							collector.agent_id=#id1#
						group by guid_prefix
					</cfquery>
					<cfif coll.recordcount gt 0>
						<cfquery name="dates" datasource="uam_god">
							select
								min(substr(began_date,1,4)) edate,
								max(substr(ended_date,1,4)) ldate
							from
								flat,
								cataloged_item,
								collector
							where
								collecting_event.collection_object_id=cataloged_item.collection_object_id and
								cataloged_item.collection_object_id=collector.collection_object_id and
								collector.agent_id=#id1#
						</cfquery>
						<div style="font-size:smaller;">
							#valuelist(coll.guid_prefix)#
							<br>#dates.edate#<cfif dates.edate is not dates.ldate>-#dates.ldate#</cfif>
						<div>
					</cfif>
					<div>
						[<a class="likeLink" href="/agents.cfm?agent_id=#id1#">Edit</a>]
						[<a class="likeLink" href="/Admin/ActivityLog.cfm?action=search&object=agent_name&sql=#name1#">Whodunit</a>]
						[<a class="likeLink" href="/info/agentActivity.cfm?agent_id=#id1#">Activity</a>]
						[<span id="fg_#id1#" class="likeLink" onclick="flagDupAgent(#id1#,#id2#)">IsBadDupOf--></span>]
					</div>
				</td>
				<td valign="top">
					<cfquery name="two" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
							project_agent.agent_id=#id2#
					</cfquery>
					<cfif project_agent.c gt 0>
						<div style="color:red;">project agent</div>
					</cfif>
					<cfquery name="publication_agent" datasource="uam_god">
						select
							count(*) c
						from
							publication_agent
						where
							publication_agent.agent_id=#id2#
					</cfquery>
					<cfif publication_agent.c gt 0>
						<div style="color:red;">publication agent</div>
					</cfif>
					<cfquery name="address" datasource="uam_god">
						select count(*) c from address where agent_id=#id2#
					</cfquery>
					<cfif address.c gt 0>
						<div style="color:red;">address</div>
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
							address
						where
							shipment.SHIPPED_TO_ADDR_ID=address.address_id and
							address.agent_id=#id2#
					</cfquery>
					<cfif ship_to.c gt 0>
						<div style="color:red;">ship_to</div>
					</cfif>
					<cfquery name="ship_from" datasource="uam_god">
						select
							count(*) c
						from
							shipment,
							address
						where
							shipment.SHIPPED_FROM_ADDR_ID=address.address_id and
							address.agent_id=#id2#
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
					<cfquery name="coll" datasource="uam_god">
						select
							guid_prefix
						from
							collection,
							cataloged_item,
							collector
						where
							collection.collection_id=cataloged_item.collection_id and
							cataloged_item.collection_object_id=collector.collection_object_id and
							collector.agent_id=#id2#
						group by guid_prefix
					</cfquery>
					<cfif coll.recordcount gt 0>
						<cfquery name="dates" datasource="uam_god">
							select
								min(substr(began_date,1,4)) edate,
								max(substr(ended_date,1,4)) ldate
							from
								flat,
								cataloged_item,
								collector
							where
								flat.collection_object_id=cataloged_item.collection_object_id and
								cataloged_item.collection_object_id=collector.collection_object_id and
								collector.agent_id=#id2#
						</cfquery>
						<div style="font-size:smaller;">
							#valuelist(coll.guid_prefix)#
							<br>#dates.edate#<cfif dates.edate is not dates.ldate>-#dates.ldate#</cfif>
						<div>
					</cfif>

					<div>
						[<a class="likeLink" href="/agents.cfm?agent_id=#id2#">Edit</a>]
						[<a class="likeLink" href="/Admin/ActivityLog.cfm?action=search&object=agent_name&sql=#name2#">Whodunit</a>]
						[<a class="likeLink" href="/info/agentActivity.cfm?agent_id=#id2#">Activity</a>]
						[<span id="fg_#id2#" class="likeLink" onclick="flagDupAgent(#id2#,#id1#)"><---IsBadDupOf</span>]
					</div>
				</td>
			</tr>
		</cfif>
	</cfloop>
	</table>
</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">