<cfinclude template="/includes/_header.cfm">
<cfoutput>

<a href="agentMagic.cfm?action=dealWithDuplicates">dealWithDuplicates</a>
	<cfif action is "dealWithDuplicates">
		<cfquery name="d" datasource="uam_god">
			select name from agent_failures group by name
		</cfquery>
		<cfloop query="d">
			<!--- try to guess at an existing agent ---->
			<!----
			<hr>
			
			<br>name: #name#
			
			---->
			<cfset sname=name>
			
			<cfset sname=replace(sname,"(","","all")>
			<cfset sname=replace(sname,")","","all")>
			<cfset sname=replace(sname,"?","","all")>
			<cfset sname=replace(sname,"  "," ","all")>
			<cfset sname=trim(sname)>
				<!----
			<br>sname: #sname#
			---->
			<cfquery name="iva" datasource="uam_god">
				select isValidAgent('#name#') nva from dual
			</cfquery>
			<cfif iva.nva gt 1>
				<cfquery name="t" datasource="uam_god">
					select preferred_agent_name from agent,agent_name where agent.agent_id=agent_name.agent_id and agent_name='#name#' and agent.agent_id not in (
					select agent_id from agent_relations where agent_relationship='bad duplicate of')
				</cfquery>
				<cfif t.recordcount is 1>
					<cfquery name="rc" datasource="uam_god">
						select isValidAgent('#name#') nva from dual
					</cfquery>
					<cfif rc.nva is 1>
						<cfset sname=replace(d.name,'&','%26','all')>
						<a href="agentMagic.cfm?action=makelookup&new=#t.preferred_agent_name#&old=#sname#">map to--->#t.preferred_agent_name#</a>
					</cfif>
				<cfelseif t.recordcount is 0>
					nomatch
				<cfelse>
					<cfquery name="t" datasource="uam_god">
						select preferred_agent_name from agent,agent_name where agent.agent_id=agent_name.agent_id and agent_name='#name#' and agent.agent_id not in (
						select agent_id from agent_relations where agent_relationship='bad duplicate of')
						and agent_name_type not in ('first name','middle name','last name','Kew abbr.')
					</cfquery>
					<cfif t.recordcount is 1>
						<cfset sname=replace(d.name,'&','%26','all')>
						<a href="agentMagic.cfm?action=makelookup&new=#t.preferred_agent_name#&old=#sname#">map to--->#t.preferred_agent_name#</a>

					<cfelse>
					
					no can find:
					#sname#
					<cfdump var=#t#>
					</cfif>
					
				
				</cfif>

			</cfif>
			
		</cfloop>

	</cfif>
	<!--------------------------->
	<cfif action is "nothing">
	<cfquery name="d" datasource="uam_god">
		select name from agent_failures group by name
	</cfquery>
	<cfloop query="d">
		<hr>
		<form name="x" method="post" action="agentMagic.cfm">
			<input type="hidden" name="action" value="makelookup">
			<input type="text" name="old" value="#name#">
			<input type="text" name="new">
			<input type="submit" value="create lookup">
		</form>
		<cfquery name="iva" datasource="uam_god">
			select 	isValidAgent('#name#') nva from dual
		</cfquery>
		
		
		<cfif iva.nva is 1>
			<p>
				one match no problem - purging
			</p>
			
			<cfquery name="ulu" datasource="uam_god">
				delete from agent_failures where name='#name#'
			</cfquery>
		<cfelseif iva.nva gt 1>
			<p>
				multiple matches
				
				<cfquery name="nbd" datasource="uam_god">
					select 
						preferred_agent_name,
						agent.agent_id 
					from 
						agent,
						agent_name 
					where 
						agent.agent_id=agent_name.agent_id and 
						agent_name='#name#' and 
						agent.agent_id not in (select agent_id from agent_relations where agent_relationship='bad duplicate of') and 
						agent_name_type not in ('first name','middle name','last name','Kew abbr.')
				</cfquery>
				
				<cfloop query="nbd">
					<cfset sname=replace(d.name,'&','%26','all')>
					<a href="/agents.cfm?agent_id=#nbd.agent_id#">#nbd.preferred_agent_name# (agent record)</a> is not a bad dup
					<br><a href="agentMagic.cfm?action=makelookup&new=#nbd.preferred_agent_name#&old=#sname#">map to--->#nbd.preferred_agent_name#</a>
				</cfloop>
				
				<!----
				<cfquery name="nfml" datasource="uam_god">
					select 
						preferred_agent_name,
						agent.agent_id 
					from 
						agent,
						agent_name where agent.agent_id=agent_name.agent_id and agent_name='#name#' and 
					and agent_name_type not in ('first name','middle name','last name','Kew abbr.')
				</cfquery>
				<cfloop query="nfml">
					<cfset sname=replace(d.name,'&','%26','all')>
					<a href="/agents.cfm?agent_id=#nfml.agent_id#">#nfml.preferred_agent_name# (agent record)</a> is not a F/M/L name
					<br><a href="agentMagic.cfm?action=makelookup&new=#nfml.preferred_agent_name#&old=#sname#">map to>#nfml.preferred_agent_name#</a>
				</cfloop>
				---->
			</p>
		<cfelseif iva.nva is 0>
			<p>
				nomatch <a target="_blank" href="/editAllAgent.cfm?action=makeNewAgent&preferred_agent_name=#trim(d.name)#&agent_type=person&agent_remarks=&forceOverride=true">
					force create person - CUIDADO!!
				</a>
				



			</p>
			<cfquery name="haslookup" datasource="uam_god">
				select NAMESHOULDBE1  from cumv_agent_repatriation where name='#name#' and NAMESHOULDBE1 != '#name#' group by NAMESHOULDBE1
			</cfquery>
			<cfif haslookup.recordcount is 1>
			
				<p>
				
					<!---
					try this:<a href="agentMagic.cfm?action=makelookup&new=#haslookup.NAMESHOULDBE1#&old=#name#">force match: #d.name#--->#haslookup.NAMESHOULDBE1#</a>
					--->
					already mapped to #haslookup.NAMESHOULDBE1#....
					<cfquery name="n1v" datasource="uam_god">
						select 	isValidAgent('#haslookup.NAMESHOULDBE1#') nva from dual
					</cfquery>
					n1v.nva=#n1v.nva# <-- if that isn't 1 there's a problem
				</p>
			<cfelseif haslookup.recordcount gt 1>
				<p>
					multiple matches - run cleanup script
				</p>
			<cfelse>
				<cfset parentStrip=replace(name,"(","","all")>
				<cfset parentStrip=replace(parentStrip,")","","all")>
				<cfset parentStrip=replace(parentStrip,"?","","all")>
				<cfset parentStrip=replace(parentStrip,"  "," ","all")>
				<cfset parentStrip=trim(parentStrip)>

				<cfquery name="t1" datasource="uam_god">
					select agent_id,preferred_agent_name from (
						select agent.agent_id,preferred_agent_name, 'fullmatch' type from agent,agent_name where agent.agent_id=agent_name.agent_id and
						agent_name='#name#' 
						UNION
						select agent.agent_id,preferred_agent_name, 'space-split' type from agent,agent_name where agent.agent_id=agent_name.agent_id and
						upper(SUBSTR(agent_name, INSTR(agent_name,' ', -1, 1)+1))='#ucase(listlast(name,' '))#' and agent_name not like '%Jr.%'
						UNION
						select agent.agent_id,preferred_agent_name, 'dot-split' type from agent,agent_name where agent.agent_id=agent_name.agent_id and
						upper(SUBSTR(agent_name, INSTR(agent_name,'.', -1, 1)+1))='#ucase(listlast(name,'.'))#' and agent_name not like '%Jr.%'
						UNION
						select agent.agent_id,preferred_agent_name, 'comma-strip' type from agent,agent_name where agent.agent_id=agent_name.agent_id and
						upper(agent_name)='#ucase(trim(replace(replace(name,',','','all'),'  ',' ','all')))#'
						UNION
						select agent.agent_id,preferred_agent_name, 'paren-strip' type from agent,agent_name where agent.agent_id=agent_name.agent_id and
						upper(agent_name)='#ucase(parentStrip)#'
					)	
					where rownum<30				
					group by agent_id,preferred_agent_name order by preferred_agent_name
				</cfquery>
				<cfif t1.recordcount gt 0>
					<table border>
						<cfloop query="t1">
						<tr>
							
							<td>#d.name#</td>
							<td>
								<cfset sname=replace(d.name,'&','%26','all')>
								<a href="agentMagic.cfm?action=makelookup&new=#t1.preferred_agent_name#&old=#sname#">map to--->#t1.preferred_agent_name#</a>
							</td>
							<td>
							<a href="/agents.cfm?agent_id=#t1.agent_id#"> open agent record </a>
							</td>
						</tr>
						</cfloop> 
					</table>
				</cfif>


			</cfif>

		</cfif>

	</cfloop>
	</cfif>
	<cfif action is "makelookup">
		<cfif len(new) is 0 or len(old) is 0>
			didn't get old and new<cfabort>
		</cfif>
		<cfquery name="t2" datasource="uam_god">
			select count(*) c from cumv_agent_repatriation where name='#trim(old)#'
		</cfquery>
		<cfdump var=#t2#>
		<cfif t2.c gte 1>
			updating
			<cfquery name="ulu" datasource="uam_god">
				update cumv_agent_repatriation set NAMESHOULDBE1='#trim(new)#' where trim(name)='#trim(old)#'
			</cfquery>
				update cumv_agent_repatriation set NAMESHOULDBE1='#trim(new)#' where trim(name)='#trim(old)#'
		<cfelse>
			inserting
			<cfquery name="ulu" datasource="uam_god">
				insert into cumv_agent_repatriation (name,NAMESHOULDBE1) values ('#trim(old)#','#trim(new)#')
			</cfquery>
				insert into cumv_agent_repatriation (name,NAMESHOULDBE1) values ('#trim(old)#','#trim(new)#')
		</cfif>
		<cfquery name="ulu" datasource="uam_god">
			delete from agent_failures where name='#trim(old)#'
		</cfquery>
		deleting
		
			delete from agent_failures where name='#trim(old)#'
		<cflocation url="agentMagic.cfm" addtoken="false">
		<!----
		
		
		--->
		
		<cfquery name="x" datasource="uam_god">
			select * from cumv_agent_repatriation where name='#old#'
		</cfquery>
		<cfdump var=#x#>
	</cfif>
</cfoutput>

