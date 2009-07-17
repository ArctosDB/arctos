<!--- make sure we're searching for something --->
	<cfif len(#agentname#) is 0>
		You must enter search criteria.
		<cfabort>
	</cfif>	
	<cfoutput>
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
	<cfloop query="getAgentId">
		<cfset thisName = #replace(agent_name,"'","`","all")#>
		<cfif #getAgentId.recordcount# is 1>
			<script>
				pickThis('#fld#','#idfld#','#thisName#', '#agent_name_id#');			
			</script>
		<cfelse>
			<tr>
				<td id="focusThis"><span class="likeLink" onClick="pickThis('#fld#','#idfld#','#thisName#', '#agent_name_id#');">#agent_name#</a></td>
				<td><font size="-2">#agent_name_id#</font></td>
				<td><font size="-2">#agent_id#</font></td>
			</tr>
		</cfif>
	</cfloop>
	<script>
		//document.getElementById('focusThis').focus();
	</script>
	</table>
</cfif>
	</cfoutput>