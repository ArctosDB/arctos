<cfinclude template="/includes/_pickHeader.cfm">
<cfparam name="name" default="">
<cfoutput>
	<script>
		function useAgent(id,str){
			parent.$("###agentIdFld#").val(id);
			parent.$("###agentNameFld#").val(str).removeClass('badPick').addClass('goodPick');
			parent.$(".ui-dialog-titlebar-close").trigger('click');
		}
	</script>
	<form name="searchForAgent">
		<label for="agent_name">Agent Name</label>
		<input type="text" name="name" id="name" value="#name#">
		<input type="submit" value="Search" class="lnkBtn">
		<input type="hidden" name="agentIdFld" value="#agentIdFld#">
		<input type="hidden" name="agentNameFld" value="#agentNameFld#">
	</form>
	<cfif len(name) is 0>
		<cfabort>
	</cfif>
	<cfquery name="getAgentId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		SELECT
			agent.preferred_agent_name,
			agent.agent_id
		from
			agent,
			agent_name
		where
			agent_type != 'verbatim agent' and
			agent.agent_id=agent_name.agent_id (+) AND
			(
				UPPER(agent_name.agent_name) LIKE '%#ucase(name)#%' or
				UPPER(agent.preferred_agent_name) LIKE '%#ucase(name)#%'
			)
		group by
			preferred_agent_name,
			agent.agent_id
		order by
			preferred_agent_name
	</cfquery>
	<cfif getAgentId.recordcount is 1>
	<cfoutput>
		<cfset thisName = #replace(getAgentId.preferred_agent_name,"'","\'","all")#>
		<script>
			useAgent('#getAgentId.agent_id#','#thisName#');
		</script>
	 </cfoutput>
	<cfelseif getAgentId.recordcount is 0>
		Nothing matched <strong>#name#</strong>.
	<cfelse>
		<cfloop query="getAgentId">
			<cfset thisName = #replace(preferred_agent_name,"'","\'","all")#>
			<div>
				<span onclick="useAgent('#agent_id#','#thisName#')" class="likeLink">
					#thisName# (#agent_id#)
				</span>
				<span class="infoLink" onclick="getAgentInfo(#agent_id#);">[ more info ]</span>
			</div>
		</cfloop>
	</cfif>
</cfoutput>
<cfinclude template="/includes/_pickFooter.cfm">