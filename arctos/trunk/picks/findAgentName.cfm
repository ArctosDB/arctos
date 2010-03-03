<cfinclude template="../includes/_pickHeader.cfm">
	<!--- make sure we're searching for something --->
		<cfoutput>
	<form method="post" action="findAgentName.cfm">
		<input type="hidden" name="agentIdFld" id="agentIdFld" value="#agentIdFld#">
		<input type="hidden" name="agentNameFld" id="agentNameFld" value="#agentNameFld#">
		<label for="agentname">Agent Name</label>
		<input type="text" id="agentname" name="agentname" value="#agentname#">
		<br><input type="submit" class="lnkBtn" value="Search">
	</form>
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
		<cfif getAgentId.recordcount is 0>
			Nothing matched #agentname#. <a href="javascript:void(0);" onClick="opener.document.#formName#.#agentIdFld#.value='';opener.document.#formName#.#agentNameFld#.value='';opener.document.#formName#.#agentNameFld#.focus();self.close();">Try again.</a>
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
				opener.getElementById('#agentIdFld#').value='#agent_name_id#';
				opener.getElementById('#agentNameFld#').value='#thisName#';
				opener.getElementById('#agentNameFld#').style.background='##8BFEB9';
				self.close();
			</script>
		<cfelse>
			<tr>
				<td><a href="##" onClick="javascript: 
					opener.document.getElementById('#agentIdFld#').value='#agent_name_id#';
					opener.document.getElementById('#agentNameFld#').value='#thisName#';
					opener.document.getElementById('#agentNameFld#').style.background='##8BFEB9';
					self.close();
					">#agent_name#</a></td>
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