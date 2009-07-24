<cfoutput>
	<span style="position:absolute;top:0px;right:0px; border:1px solid black;" class="likeLink" onclick="removePick()">X</span>
	<cfquery name="agnt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select agent_name from preferred_agent_name where agent_id=#agent_id#
	</cfquery>
	<cfquery name="pr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from agent_rank where agent_id=#agent_id#
	</cfquery>
	<cfquery name="ctagent_rank" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select agent_rank from ctagent_rank order by agent_rank
	</cfquery>
	
	Agent #agnt.agent_name# has been ranked #pr.recordcount# times.
	<cfif pr.recordcount gt 0>
		more stuff here.....
	</cfif>
	Add a ranking:
	<form name="a" method="post" action="agentrank.cfm">
		<label for="Rank">Rank</label>
		<select name="" id="">
			<cfloop query="ctagent_rank">
				<option value="#agent_rank#">#agent_rank#</option>
			</cfloop>
		</select>
	</form>
</cfoutput>