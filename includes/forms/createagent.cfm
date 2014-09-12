
<cfquery name="ctAgent_Type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select agent_type from ctagent_type order by agent_type
</cfquery>

	<cfoutput>
		<strong>Create Agent</strong>
		<form name="prefdName" action="editAllAgent.cfm" method="post" target="_person" id="createAgent" onsubmit="return preCreateCheck()">
			<input type="hidden" name="action" value="makeNewAgent">
			<input type="hidden" name="forceOverride" id="forceOverride" value="">
			<label for="agent_type">Agent Type</label>
			<select name="agent_type" id="agent_type" size="1" class="reqdClr" onchange="togglePerson(this.value);">
				<option value=""></option>
				<cfloop query="ctAgent_Type">
					<option value="#ctAgent_Type.agent_type#">#ctAgent_Type.agent_type#</option>
				</cfloop>
			</select>
			<input type="hidden" name="agent_name_type" value="preferred">
			<label for="preferred_agent_name">Preferred Name</label>
			<input type="text" name="preferred_agent_name" id="preferred_agent_name" size="50" class="reqdClr">
			<div id="newPersonAttrs" style="display:none;">
				<br><span class="likeLink" onclick="autosuggestNameComponents();">Autogenerate name components from preferred name</span>
				<label for="first_name">First Name</label>
				<input type="text" name="first_name" id="first_name">
				<label for="middle_name">Middle Name</label>
				<input type="text" name="middle_name" id="middle_name">
				<label for="last_name">Last Name</label>
				<input type="text" name="last_name" id="last_name">
				<br><span class="likeLink" onclick="autosuggestPreferredName();">Autogenerate preferred name from first/middle/last</span>
			</div>
			<label for="agent_remarks">Remarks</label>
			<input type="text"  size="80" name="agent_remarks" id="agent_remarks">
			<br>
			<input type="submit" value="Create Agent" class="savBtn">
			<div id="preCreateErrors" style="display:none;">
			</div>
		</form>
		<div class="importantNotification">
			Read <a href="http://arctosdb.org/documentation/agent/##create" class="external" target="_blank">documentation</a> BEFORE clicking buttons!
		</div>
		<cfif isdefined("agent_type") and agent_type is "person">
			<script>
				$("##agent_type").val('person');
				togglePerson('person');
			</script>
		</cfif>
	</cfoutput>