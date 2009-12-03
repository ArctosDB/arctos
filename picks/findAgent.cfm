<cfinclude template="/includes/_pickHeader.cfm">
<cfif actions is "nothing">
	<!--- make sure we're searching for something --->
	<cfif len(#agent_name#) is 0>
		<form name="searchForAgent" action="findAgent.cfm" method="post">
			<label for="agent_name">Agent Name</label>
			<input type="text" name="agent_name" id="agent_name">
			<input type="submit" 
				value="Search" 
				class="lnkBtn"
				onmouseover="this.className='lnkBtn btnhov'"
				onmouseout="this.className='lnkBtn'">
			<cfoutput>
				<input type="hidden" name="agentIdFld" value="#agentIdFld#">
				<input type="hidden" name="agentNameFld" value="#agentNameFld#">
				<input type="hidden" name="formName" value="#formName#">
			</cfoutput>
		</form>
		<cfabort>
	</cfif>
	
		<cfquery name="getAgentId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT 
				preferred_agent_name.agent_name, agent.agent_id 
			from 
				preferred_agent_name,agent_name, agent
			where
				preferred_agent_name.agent_id = agent_name.agent_id AND
				agent_name.agent_id = agent.agent_id AND
				UPPER(agent_name.agent_name) LIKE '%#ucase(agent_name)#%'
				<cfif not isdefined("allowCreation") OR  #allowCreation# is not "true">
					AND agent_type != 'verbatim agent'
				</cfif>				
				group by preferred_agent_name.agent_name, agent.agent_id 
				order by preferred_agent_name.agent_name
		</cfquery>
		
	<cfif #getAgentId.recordcount# is 1>
	<cfoutput>
		<cfset thisName = #replace(getAgentId.agent_name,"'","\'","all")#>
		<script>
			opener.document.#formName#.#agentIdFld#.value='#getAgentId.agent_id#';
			opener.document.#formName#.#agentNameFld#.value='#thisName#';
			opener.document.#formName#.#agentNameFld#.style.background='##8BFEB9';
			self.close();
		</script>
	 </cfoutput>
	<cfelseif #getAgentId.recordcount# is 0>
		<cfoutput>
			Nothing matched <strong>#agent_name#</strong>. 
			<br>
			<a href="findAgent.cfm?formName=#formName#&agentIdFld=#agentIdFld#&agentNameFld=#agentNameFld#&agent_name=">Search again.</a>
			<cfif isdefined("allowCreation") and #allowCreation# is "true">
				<p>
					Use the Agents tab to create a new agent, or create new verbatim agent here if the
					following conditions are met:
				</p>
				<ul>
					<li>You are sure you haven't mis-spelled the agent name.</li>
					<li>You have searched for variants.</li>
					<li>You are authorized to create agents.</li>
					<li>The agent will not have any roles other than Collector.</li>
				</ul>
				<form name="newAgent" method="post" action="findAgent.cfm">
					<input type="hidden" name="action" value="createAgent">
					<input type="hidden" name="formName" value="#formName#">
					<input type="hidden" name="agentIdFld" value="#agentIdFld#">
					<input type="hidden" name="agentNameFld" value="#agentNameFld#">
					
					<label for="newName">Verbatim Agent Name</label>
					<input type="text" name="newName" id="newName" value="#agent_name#">
					<input type="submit" value="Create Verbatim Agent" class="insBtn"
					   onmouseover="this.className='insBtn btnhov'" onmouseout="this.className='insBtn'"/>
					
				</form>
			</cfif>

		</cfoutput>
		
	<cfelse>
		<cfoutput query="getAgentId">
		<br>
		<cfset thisName = #replace(agent_name,"'","\'","all")#>

		<a href="##" onClick="javascript: opener.document.#formName#.#agentIdFld#.value='#agent_id#';opener.document.#formName#.#agentNameFld#.value='#thisName#';opener.document.#formName#.#agentNameFld#.style.background='##8BFEB9';self.close();">#agent_name# (#agent_id#)</a>
	</cfoutput>
	</cfif>
</cfif>
<cfif #action# is "createAgent">
	<cftransaction>
		<cfquery name="aid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select sq_agent_id.nextval agent_id from dual
		</cfquery>
		<cfquery name="newAgnt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			insert into agent (
				AGENT_ID,
				AGENT_TYPE,
				AGENT_REMARKS,
				PREFERRED_AGENT_NAME_ID
			) values (
				#aid.agent_id#,
				'verbatim agent',
				'Created #dateformat(now(),"dd-mmm-yyyy")# by login #session.username#.',
				#anid.agent_name_id#)
		</cfquery>
		<cfquery name="newAgntName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			INSERT INTO agent_name (
				AGENT_NAME_ID,
				AGENT_ID,
				AGENT_NAME_TYPE,
				AGENT_NAME
			) values (
				sq_agent_name_id.nextval,
				#aid.agent_id#,
				'preferred',
				'#replace(newName,"'","''","all")#')                                 
		</cfquery>
	</cftransaction>
	<cfoutput>
	<script>
		opener.document.#formName#.#agentIdFld#.value='#aid.agent_id#';
		opener.document.#formName#.#agentNameFld#.value='#replace(newName,"'","\'","all")#';
		opener.document.#formName#.#agentNameFld#.style.background='##8BFEB9';
		self.close();
	</script>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_pickFooter.cfm">