<cfinclude template="../includes/_pickHeader.cfm">

<cfoutput>

	<script>
	function useThis(pn,pi){
		opener.document.#formName#.#projIdFld#.value=pi;
		opener.document.#formName#.#projNameFld#.value=pn;
		opener.document.#formName#.#projNameFld#.className='goodPick';
		self.close();
	}
</script>


	<form name="p" method="post" action="findProject.cfm">
		<input type="hidden" name="formName" value="#formName#">
		<input type="hidden" name="projIdFld" value="#projIdFld#">
		<input type="hidden" name="projNameFld" value="#projNameFld#">
		<label for="project_name">Project Name</label>
		<input type="text" name="project_name" id="project_name">
		<input type="submit" value="search" class="lnkBtn">
	</form>
	<!--- make sure we're searching for something --->
	<cfif len(#project_name#) is 0 or project_name is "undefined">
		<cfabort>
	</cfif>
	<cfquery name="raw" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		SELECT
      project.project_name,
      project.project_id,
	getPreferredAgentName(project_agent.agent_id) agent
    from
      project,
      project_agent,
      agent,
      agent_name
    where
      project.project_id=project_agent.project_id (+) and
      project_agent.agent_id=agent.agent_id (+) and
      agent.agent_id=agent_name.agent_id (+) and (
        UPPER(project_name) LIKE '%#ucase(project_name)#%' or
        UPPER(agent.preferred_agent_name) LIKE '%#ucase(project_name)#%'or
        UPPER(agent_name.agent_name) LIKE '%#ucase(project_name)#%'
	)
	</cfquery>
	<cfif raw.recordcount is 0>
			Nothing matched #project_name#.
	<cfelse>
		<cfquery name="getProj" dbtype="query">
			select project_name,project_id from raw order by project_name
		</cfquery>
		<cfloop query="getProj">
			<div>
				<a href="##" onClick="useThis('#jsescape(getProj.project_name)#','#project_id#');">
					#getProj.project_name#
				</a>
			</div>
			<!----
			<br>
			<a href="##" onClick="javascript: opener.document.#formName#.#projIdFld#.value='';
				opener.document.#formName#.#projNameFld#.value='';opener.document.#formName#.#projNameFld#.className='goodPick';self.close();">#project_name# (#project_id#)</a>
				---->
		</cfloop>
	</cfif>
</cfoutput>
<cfinclude template="../includes/_pickFooter.cfm">