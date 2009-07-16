<cfinclude template="../includes/_pickHeader.cfm">
	<!--- make sure we're searching for something --->
	<cfif len(#agentname#) is 0>
		You must enter search criteria.
		<cfabort>
	</cfif>
	
	<script>
		
		function pickThis (fld,idfld,display,aid) {
			console.log('fld: ' + fld);
			console.log('idfld: ' + idfld);
			document.getElementById(fld).value=display;
			document.getElementById(idfld).value=aid;
			console.log('spiffy');
			/*
				
			jQuery('#' + fld).value=display;
			jQuery('#' + ).value=;
			
			opener.document.#formName#.#agentIdFld#.value='#agent_name_id#';
				opener.document.#formName#.#agentNameFld#.value='#thisName#';
				opener.document.#formName#.#agentNameFld#.style.background='##8BFEB9';
			*/
		}
	</script>
	<cfoutput>
		#cgi.QUERY_STRING#
		<cfquery name="getAgentId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT 
				dispNames.agent_id,
				dispNames.agent_name_id ,
				dispNames.agent_name 
			FROM
				agent_name dispNames,
				agent_name searchNames
			WHERE
				searchNames.agent_id = dispNames.agent_id (+)
				AND UPPER(searchNames.agent_name) LIKE '%#ucase(agentname)#%'
			GROUP BY
				dispNames.agent_id,
				dispNames.agent_name_id,
				dispNames.agent_name
			ORDER BY
				dispNames.agent_id,
				dispNames.agent_name
		</cfquery>
		<cfif #getAgentId.recordcount# is 0>
			Nothing matched #agentname#. 
			<!---<a href="javascript:void(0);" onClick="opener.document.#formName#.#agentIdFld#.value='';opener.document.#formName#.#agentNameFld#.value='';opener.document.#formName#.#agentNameFld#.focus();self.close();">Try again.</a>
			--->
		<cfelse>
	<table border>
		<tr>
			<td>Name</td>
			<td><font size="-2">Name ID</font></td>
			<td><font size="-2">ID</font></td>
		</tr>
		#getAgentId.recordcount#
	<cfloop query="getAgentId">
		<cfset thisName = #replace(agent_name,"'","`","all")#>
		<cfif #getAgentId.recordcount# is 1>
			<script>
				pickThis ('#fld#','#idfld#','#thisName#', '#agent_name_id#');
				
			
			</script>
		<cfelse>
			<tr>
				<td><a href="##" onClick="pickThis ('#fld#','#idfld#','#thisName#', '#agent_name_id#');">#agent_name#</a></td>
				<td><font size="-2">#agent_name_id#</font></td>
				<td><font size="-2">#agent_id#</font></td>
			</tr>
		</cfif>
	</cfloop>
	</table>
</cfif>
	</cfoutput>
	
	
<!----	
	
	<!--------------------------------------------------->
	<cfif #getAgentId.recordcount# is 1>
	<cfoutput>
		<cfset thisName = #replace(getAgentId.agent_name,"'","`","all")#>
		<script>
			opener.document.#formName#.#agentIdFld#.value='#getAgentId.agent_id#';
			opener.document.#formName#.#agentNameFld#.value='#thisName#';
			opener.document.#formName#.#agentNameFld#.style.background='##8BFEB9';
			self.close();
		</script>
	 </cfoutput>
	<cfelseif #getAgentId.recordcount# is 0>
		<cfoutput>
			Nothing matched #agent_name#. <a href="javascript:void(0);" onClick="opener.document.#formName#.#agentIdFld#.value='';opener.document.#formName#.#agentNameFld#.value='';opener.document.#formName#.#agentNameFld#.focus();self.close();">Try again.</a>
		</cfoutput>
		
	<cfelse>
		<cfoutput query="getAgentId">
		
<br>
<cfset thisName = #replace(agent_name,"'","`","all")#>
<a href="##" onClick="javascript: opener.document.#formName#.#agentIdFld#.value='#agent_id#';opener.document.#formName#.#agentNameFld#.value='#thisName#';opener.document.#formName#.#agentNameFld#.style.background='##8BFEB9';self.close();">#agent_name# (#agent_id#)</a>
	</cfoutput>
	</cfif>
	
	<!--------------------------------------------------->
	
	---->
<cfinclude template="../includes/_pickFooter.cfm">