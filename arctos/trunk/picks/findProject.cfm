<cfinclude template="../includes/_pickHeader.cfm">


	<!--- make sure we're searching for something --->
	<cfif len(#project_name#) is 0>
		You must enter search criteria.
		<cfabort>
	</cfif>
	
		<cfquery name="getProj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT project_name, project_id from project where
				UPPER(project_name) LIKE '%#ucase(project_name)#%'
		</cfquery>
		
	<cfif #getProj.recordcount# is 1>
	<cfoutput>
		<cfset thisName = #replace(getProj.project_name,"'","`","all")#>
		<script>
			opener.document.#formName#.#projIdFld#.value='#getProj.project_id#';
			opener.document.#formName#.#projNameFld#.value='#thisName#';
			opener.document.#formName#.#projNameFld#.className='goodPick';
			self.close();
		</script>
	 </cfoutput>
	<cfelseif #getProj.recordcount# is 0>
		<cfoutput>
			Nothing matched #project_name#. <a href="javascript:void(0);" onClick="opener.document.#formName#.#projIdFld#.value='';opener.document.#formName#.#projNameFld#.value='';opener.document.#formName#.#projNameFld#.focus();self.close();">Try again.</a>
		</cfoutput>
		
	<cfelse>
		<cfoutput query="getProj">
		
<br>
<cfset thisName = #replace(getProj.project_name,"'","`","all")#>
<a href="##" onClick="javascript: opener.document.#formName#.#projIdFld#.value='#project_id#';opener.document.#formName#.#projNameFld#.value='#thisName#';opener.document.#formName#.#projNameFld#.className='goodPick';self.close();">#project_name# (#project_id#)</a>
	</cfoutput>
	</cfif>
	
<cfinclude template="../includes/_pickFooter.cfm">