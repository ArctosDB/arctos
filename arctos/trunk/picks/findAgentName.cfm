<cfinclude template="../includes/_pickHeader.cfm">
	<!--- make sure we're searching for something --->
	<cfoutput>
	<cfset rdurl="findAgentName.cfm?agentIdFld=#agentIdFld#&agentNameFld=#agentNameFld#">
	<cfif not isdefined("agentname")><cfset agentname=""></cfif>
	<form method="post" action="findAgentName.cfm">
		<input type="hidden" name="agentIdFld" id="agentIdFld" value="#agentIdFld#">
		<input type="hidden" name="agentNameFld" id="agentNameFld" value="#agentNameFld#">
		<label for="agentname">Agent Name</label>
		<input type="text" id="agentname" name="agentname" value="#agentname#">
		<br><input type="submit" class="lnkBtn" value="Search">
	</form>
	<script>
		function makeNewName(name,id) {
			var a = prompt("Enter a new name (name type=aka) for " + name);
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
						if(result=='success'){
							document.location='findAgentName.cfm?agentIdFld=#agentIdFld#&agentNameFld=#agentNameFld#&agent_id=' + id;
						}else{
							alert(result);
						}
					}
				);
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
				<cfif isdefined("agent_id") and agent_id gt 0>
					and searchNames.agent_id=#agent_id#
				</cfif>
			GROUP BY
				dispNames.agent_id,
				dispNames.agent_name_id,
				dispNames.agent_name_type,
				dispNames.agent_name
			ORDER BY
				dispNames.agent_id,
				dispNames.agent_name
		</cfquery>	
				
		<cfif getAgentId.recordcount is 0>
			Nothing matched #agentname#.
			<cfif listfindnocase(session.roles,"manage_agents")>
				<br>If you're really sure that agent doesn't exist, 
				you can
				create a 
				<br><a target="blank" href="/findAgentName.cfm?action=newPerson">new person</a> or a 
				<br><a  target="blank" href="/findAgentName.cfm?action=newOtherAgent">new non-person agent.</a>
				<br>Reload or requery after you do so to get the new entry.
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

<cfif action is "newOtherAgent">
	<cfquery name="ctAgentType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select agent_type from ctagent_type order by agent_type
	</cfquery>
	<cfoutput>
		<form name="prefdName" action="findAgentName.cfm" method="post" target="_person">
			<input type="hidden" name="action" value="makeNewAgent">
			
		<input type="hidden" name="agentIdFld" id="agentIdFld" value="#agentIdFld#">
		<input type="hidden" name="agentNameFld" id="agentNameFld" value="#agentNameFld#">
			<input type="hidden" name="agent_name_type" value="preferred">
			<label for="agent_name">Preferred Name</label>
			<input type="text" name="agent_name" id="agent_name" size="50" class="reqdClr">
			<label for="agent_type">Agent Type</label>
			<select name="agent_type" id="agent_type" size="1">
				<cfloop query="ctAgentType">
					<cfif #ctAgentType.agent_type# neq 'person'>
						<option value="#ctAgentType.agent_type#">#ctAgentType.agent_type#</option>
					</cfif>
				</cfloop>
			</select>
			<label for="agent_remarks">Remarks</label>
			<input type="text"  size="50" name="agent_remarks" id="agent_remarks">
			<br>
			<input type="submit" value="Create Agent" class="savBtn">
			</form>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->
<cfif Action is "newPerson">
	<cfquery name="ctprefix" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select prefix from ctprefix order by prefix
	</cfquery>
	<cfquery name="ctsuffix" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select suffix from ctsuffix order by suffix
	</cfquery>
	<form name="newPerson" action="findAgentName.cfm" method="post" target="_person">
		<input type="hidden" name="Action" value="insertPerson">
		
		<input type="hidden" name="agentIdFld" id="agentIdFld" value="#agentIdFld#">
		<input type="hidden" name="agentNameFld" id="agentNameFld" value="#agentNameFld#">
		<label for="prefix">Prefix</label>
		<select name="prefix" id="prefix" size="1">
			<option value=""></option>
			<cfoutput query="ctprefix"> 
				<option value="#prefix#">#prefix#</option>
			</cfoutput> 
		</select>
		<label for="first_name">First Name</label>
		<input type="text" name="first_name" id="first_name">
		<label for="middle_name">Middle Name</label>
		<input type="text" name="middle_name" id="middle_name">
		<label for="last_name">Last Name</label>
		<input type="text" name="last_name" id="last_name" class="reqdClr">
		<label for="suffix">Suffix</label>
		<select name="suffix" size="1" id="suffix">
			<option value=""></option>
			<cfoutput query="ctsuffix"> 
				<option value="#suffix#">#suffix#</option>
			</cfoutput> 
    	</select>
		<label for="pref_name">Preferred Name</label>
		<input type="text" name="pref_name" id="pref_name">
		<input type="submit" value="Add Person" class="savBtn">
	</form>
</cfif>
<cfif action is "insertPerson">
	<cfoutput>
		<cftransaction>
			<cfquery name="agentID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select sq_agent_id.nextval nextAgentId from dual
			</cfquery>
			<cfquery name="agentNameID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select sq_agent_name_id.nextval nextAgentNameId from dual
			</cfquery>		
			<cfquery name="insPerson" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				INSERT INTO agent (
					agent_id,
					agent_type,
					preferred_agent_name_id)
				VALUES (
					#agentID.nextAgentId#,
					'person',
					#agentNameID.nextAgentNameId#
					)
			</cfquery>			
			<cfquery name="insPerson" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				INSERT INTO person ( 
					PERSON_ID
					<cfif len(#prefix#) gt 0>
						,prefix
					</cfif>
					<cfif len(#LAST_NAME#) gt 0>
						,LAST_NAME
					</cfif>
					<cfif len(#FIRST_NAME#) gt 0>
						,FIRST_NAME
					</cfif>
					<cfif len(#MIDDLE_NAME#) gt 0>
						,MIDDLE_NAME
					</cfif>
					<cfif len(#SUFFIX#) gt 0>
						,SUFFIX
					</cfif>
					)
				VALUES
					(#agentID.nextAgentId#
					<cfif len(#prefix#) gt 0>
						,'#prefix#'
					</cfif>
					<cfif len(#LAST_NAME#) gt 0>
						,'#LAST_NAME#'
					</cfif>
					<cfif len(#FIRST_NAME#) gt 0>
						,'#FIRST_NAME#'
					</cfif>
					<cfif len(#MIDDLE_NAME#) gt 0>
						,'#MIDDLE_NAME#'
					</cfif>
					<cfif len(#SUFFIX#) gt 0>
						,'#SUFFIX#'
					</cfif>
					)
			</cfquery>
			<cfif len(pref_name) is 0>
				<cfset name = "">
				<cfif len(#prefix#) gt 0>
					<cfset name = "#name# #prefix#">
				</cfif>
				<cfif len(#FIRST_NAME#) gt 0>
					<cfset name = "#name# #FIRST_NAME#">
				</cfif>
				<cfif len(#MIDDLE_NAME#) gt 0>
					<cfset name = "#name# #MIDDLE_NAME#">
				</cfif>
				<cfif len(#LAST_NAME#) gt 0>
					<cfset name = "#name# #LAST_NAME#">
				</cfif>
				<cfif len(#SUFFIX#) gt 0>
					<cfset name = "#name# #SUFFIX#">
				</cfif>
				<cfset pref_name = #trim(name)#>
			</cfif>
			<cfif not isdefined("ignoreDupChek") or ignoreDupChek is false>
				<cfquery name="dupPref" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select agent_id,agent_name from agent_name where upper(agent_name) like '%#ucase(pref_name)#%'
				</cfquery>
				<cfif dupPref.recordcount gt 0>
					<p>That agent may already exist! Click to see details.</p>
					<cfloop query="dupPref">
						<br><a href="/info/agentActivity.cfm?agent_id=#agent_id#">#agent_name#</a>
					</cfloop>
					<p>Are you sure you want to continue?</p>
					<form name="ac" method="post" action="findAgentName.cfm">
						<input type="hidden" name="action" value="insertPerson">
						
		<input type="hidden" name="agentIdFld" id="agentIdFld" value="#agentIdFld#">
		<input type="hidden" name="agentNameFld" id="agentNameFld" value="#agentNameFld#">
						<input type="hidden" name="prefix" value="#prefix#">
						<input type="hidden" name="LAST_NAME" value="#LAST_NAME#">
						<input type="hidden" name="FIRST_NAME" value="#FIRST_NAME#">
						<input type="hidden" name="MIDDLE_NAME" value="#MIDDLE_NAME#">
						<input type="hidden" name="SUFFIX" value="#SUFFIX#">
						<input type="hidden" name="pref_name" value="#pref_name#">
						<input type="hidden" name="ignoreDupChek" value="true">
						<input type="submit" class="insBtn" value="Of course. I carefully checked for duplicates before creating this agent.">
						<br><input type="button" class="qutBtn" onclick="back()" value="Oh - back one step, please.">
					</form>
					<cfabort>					
				</cfif>
			</cfif>
			<cfquery name="insName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				INSERT INTO agent_name (
					agent_name_id,
					agent_id,
					agent_name_type,
					agent_name,
					donor_card_present_fg)
				VALUES (
					#agentNameID.nextAgentNameId#,
					#agentID.nextAgentId#,
					'preferred',
					'#pref_name#',
					0
					)
			</cfquery>
		</cftransaction>
		<cfset rdurl=rdurl & "&agent_id=#agentID.nextAgentId#">	
		<cflocation url=rdurl>
	</cfoutput>
</cfif>



<cfif #Action# is "makeNewAgent">
	<cfoutput>
		<cftransaction>
			<cfquery name="agentID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select sq_agent_id.nextval nextAgentId from dual
			</cfquery>
			<cfquery name="agentNameID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select sq_agent_name_id.nextval nextAgentNameId from dual
			</cfquery>
			<cfquery name="insAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				INSERT INTO agent (
					agent_id,
					agent_type,
					preferred_agent_name_id
					<cfif len(#agent_remarks#) gt 0>
						,agent_remarks
					</cfif>
					)
				VALUES (
					#agentID.nextAgentId#,
					'#agent_type#',
					#agentNameID.nextAgentNameId#
					<cfif len(#agent_remarks#) gt 0>
						,'#agent_remarks#'
					</cfif>
					)
			</cfquery>
			<cfif not isdefined("ignoreDupChek") or ignoreDupChek is false>
				<cfquery name="dupPref" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select agent_id,agent_name from agent_name where upper(agent_name) like '%#ucase(agent_name)#%'
				</cfquery>
				<cfif dupPref.recordcount gt 0>
					<p>That agent may already exist! Click to see details.</p>
					<cfloop query="dupPref">
						<br><a href="/info/agentActivity.cfm?agent_id=#agent_id#">#agent_name#</a>
					</cfloop>
					<p>Are you sure you want to continue?</p>
					<form name="ac" method="post" action="findAgentName.cfm">
						<input type="hidden" name="action" value="makeNewAgent">
						
		<input type="hidden" name="agentIdFld" id="agentIdFld" value="#agentIdFld#">
		<input type="hidden" name="agentNameFld" id="agentNameFld" value="#agentNameFld#">
						<input type="hidden" name="agent_remarks" value="#agent_remarks#">
						<input type="hidden" name="agent_type" value="#agent_type#">
						<input type="hidden" name="agent_name" value="#agent_name#">
						<input type="hidden" name="ignoreDupChek" value="true">
						<input type="submit" class="insBtn" value="Of course. I carefully checked for duplicates before creating this agent.">
						<br><input type="button" class="qutBtn" onclick="back()" value="Oh - back one step, please.">
					</form>
					<cfabort>					
				</cfif>
			</cfif>
			<cfquery name="insName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				INSERT INTO agent_name (
					agent_name_id,
					agent_id,
					agent_name_type,
					agent_name,
					donor_card_present_fg)
				VALUES (
					#agentNameID.nextAgentNameId#,
					#agentID.nextAgentId#,
					'preferred',
					'#agent_name#',
					0
					)
			</cfquery>
		</cftransaction>
		<cfset rdurl=rdurl & "&agent_id=#agentID.nextAgentId#">	
		<cflocation url=rdurl>
	</cfoutput>
</cfif>
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