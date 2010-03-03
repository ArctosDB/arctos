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
	<script>
		function makeNewName(name,id) {
			var a = prompt("Enter a new name (type=AKA) for " + name);
			if(a) {
				jQuery.getJSON("/component/functions.cfc",
					{
						method : "insertAgentName",
						name : a,
						id : id,
						returnformat : "json",
						queryformat : 'column'
					},
					function (result) {
						alert(result);
					}
				);
				
				
				alert('y');
			}
		}
	</script>
		<cfquery name="getAgentId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT 
				dispNames.agent_id,
				dispNames.agent_name_id,
				dispNames.agent_name_type,
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
				dispNames.agent_name_type,
				dispNames.agent_name
			ORDER BY
				dispNames.agent_id,
				dispNames.agent_name
		</cfquery>
		
		<cfdump var=#getAgentId#>
				
				
				
				
		<cfif getAgentId.recordcount is 0>
			Nothing matched #agentname#.
			---#session.roles#----------
			<cfif listfindnocase(session.roles,"manage_agents")>
				If you're really sure that agent doesn't exist, you can
				create a <a target="blank" href="/editAllAgent.cfm?action=newPerson">new person</a> or a 
				<a  target="blank" href="/editAllAgent.cfm?action=newOtherAgent">new non-person agent.</a>
				Reload or requery after you do so to get the new entry.
			<cfelse>no
			</cfif>

		<cfelse>
	<table border>
		<tr>
			<td>Name</td>
			<td><font size="-2">Name ID</font></td>
			<td><font size="-2">ID</font></td>
		</tr>
	<cfset i=0>
	<cfset laid=0>
	<cfloop query="getAgentId">
		<cfset thisName = jsescape(agent_name)>
	    <cfif agent_id neq laid>
			<cfset i=i+1>
		</cfif>
		<cfset laid=agent_id>
	    <tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
			<td><a href="##" onClick="javascript: 
				opener.document.getElementById('#agentIdFld#').value='#agent_name_id#';
				opener.document.getElementById('#agentNameFld#').value='#thisName#';
				opener.document.getElementById('#agentNameFld#').style.background='##8BFEB9';
				self.close();
				">#agent_name#</a></td>
			<td><font size="-2">#agent_name_id#</font></td>
			<td><font size="-2">#agent_id#</font></td>
			<td><font size="-2"><a target="blank" href="/agents.cfm?agent_id=#agent_id#">Edit</a></font></td>
			<td>
				<cfif agent_name_type is "preferred">
					<span class="infoLink" onclick="makeNewName('#thisName#','#agent_id#')">Add Name</span>
				</cfif>
			</td>
		</tr>
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