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
	<cfquery name="cttransaction_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select transaction_type from cttransaction_type order by transaction_type
	</cfquery>
	
	Agent #agnt.agent_name# has been ranked #pr.recordcount# times.
	<cfif pr.recordcount gt 0>
		<cfquery name="s" dbtype="query">
			select agent_rank, count(*) from pr group by agent_rank
		</cfquery>
		<cfdump var=#s#>
		more stuff here.....
	</cfif>
	<div class="cellDiv">
	Add a ranking:
	<form name="a" method="post" action="agentrank.cfm">
		<input type="hidden" name="agent_id" id="agent_id" value="#agent_id#">
		<input type="hidden" name="action" id="action" value="saveRank">
		<label class="h" for="agent_rank">Rank</label>
		<select name="agent_rank" id="agent_rank">
			<cfloop query="ctagent_rank">
				<option value="#agent_rank#">#agent_rank#</option>
			</cfloop>
		</select>
		<label class="h"  for="transaction_type">Transaction Type</label>
		<select name="transaction_type" id="transaction_type">
			<cfloop query="cttransaction_type">
				<option value="#transaction_type#">#transaction_type#</option>
			</cfloop>
		</select>
		<label  class="h" for="remark">Remark</label>
		<textarea name="remark" id="remark" rows="3" columns="40"></textarea>
		<br><input type="button" class="savBtn" value="Save" onclick="saveAgentRank()">
	</form>
	</div>
</cfoutput>
