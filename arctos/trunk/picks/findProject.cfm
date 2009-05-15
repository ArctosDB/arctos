<cfinclude template="../includes/_pickHeader.cfm">
<cfoutput>
	<form name="p" method="post" action="findProject.cfm">
		<input type="hidden" name="formName" value="#formName#">
		<input type="hidden" name="projIdFld" value="#projIdFld#">
		<input type="hidden" name="projNameFld" value="#projNameFld#">
		<label for="project_name">Project Name</label>
		<input type="text" name="project_name" id="project_name">
		<input type="submit" value="search" class="lnkBtn">
	</form>
	<!--- make sure we're searching for something --->
	<cfif len(#project_name#) is 0 pr project_name is "undefined">
		<cfabort>
	</cfif>
	<cfquery name="getProj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT project_name, project_id from project where
			UPPER(project_name) LIKE '%#ucase(project_name)#%'
	</cfquery>
	<cfif #getProj.recordcount# is 1>
		<cfset thisName = #replace(getProj.project_name,"'","`","all")#>
		<script>
			opener.document.#formName#.#projIdFld#.value='#getProj.project_id#';
			opener.document.#formName#.#projNameFld#.value='#thisName#';
			opener.document.#formName#.#projNameFld#.className='goodPick';
			self.close();
		</script>
	<cfelseif #getProj.recordcount# is 0>
			Nothing matched #project_name#.
	<cfelse>
		<cfloop query="getProj">
			<br>
			<cfset thisName = #replace(getProj.project_name,"'","`","all")#>
			<a href="##" onClick="javascript: opener.document.#formName#.#projIdFld#.value='#project_id#';opener.document.#formName#.#projNameFld#.value='#thisName#';opener.document.#formName#.#projNameFld#.className='goodPick';self.close();">#project_name# (#project_id#)</a>
		</cfloop>
	</cfif>
</cfoutput>
<cfinclude template="../includes/_pickFooter.cfm">