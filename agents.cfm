
<cfinclude template="/includes/_header.cfm">
<cfquery name="ctprefix" datasource="#Application.web_user#">
	select distinct(prefix) as prefix from person where prefix is not null
</cfquery>
<cfquery name="ctsuffix" datasource="#Application.web_user#">
	select distinct(suffix) as suffix from person where suffix is not null
</cfquery>
<cfquery name="ctNameType" datasource="#Application.web_user#">
	select agent_name_type as agent_name_type from ctagent_name_type
</cfquery>
<cfquery name="ctAgentType" datasource="#Application.web_user#">
	select agent_type from ctagent_type
</cfquery>
<cfquery name="ctAddrType" datasource="#Application.web_user#">
	select addr_type from ctaddr_type
</cfquery>
<cfquery name="ctElecAddrType" datasource="#Application.web_user#">
	select address_type from ctelectronic_addr_type
</cfquery>


<span class="infoLink pageHelp" onclick="getDocs('agent');">Page Help</span>
<cfif #action# is "nothing" OR #action# is "search"><!--- keep this around until they find something and go to edit mode --->
<cfoutput>
Find Agents:
<form name="agntSearch" action="agents.cfm" method="post">
	<input type="hidden" name="action" value="search">
<table>	
	<tr>
		<td>
			<label for="prefix">Prefix</label>
			<select name="prefix" size="1" id="prefix">
				<option selected value="">none</option>
      	    	<cfloop query="ctprefix"> 
        			<option value="#ctprefix.prefix#">#ctprefix.prefix#</option>
      				</cfloop> 
   			 </select>
		</td>
		<td>
			<label for="first_name"><a href="javascript:void(0);" onClick="getDocs('agent','namesearch')">First Name</a></label>
			<input type="text" name="first_name">
		</td>
	</tr>
		<td>
			<label for="middle_name">
				<a href="javascript:void(0);" onClick="getDocs('agent','namesearch')">Middle Name</a>
			</label>
			<input type="text" name="middle_name" id="middle_name">
		</td>
		<td>
			<label for="last_name">
				<a href="javascript:void(0);" onClick="getDocs('agent','namesearch')">Last Name</a>
			</label>
			<input type="text" name="last_name" id="last_name">
		</td>
	<tr>
	<tr>
		<td>
			<label for="suffix">
				Suffix
			</label>
			<select name="suffix" size="1" id="suffix">
				<option selected value="">none</option>
	      	   	<cfloop query="ctsuffix"> 
	        		<option value="#ctsuffix.suffix#">#ctsuffix.suffix#</option>
	      		</cfloop> 
	   		 </select>
		</td>
		<td>
			<label for="agent_id">
				Agent ID
			</label>
			<input type="text" name="agent_id" size="6" id="agent_id">
		</td>
	</tr>
	<tr>
		<td>
			<label for="birthOper">
				Birth Date
			</label>
			<select name="birthOper" size="1" id="birthOper">
				<option value="<=">Before</option>
				<option selected value="=" >Is</option>
				<option value=">=">After</option>
			</select>
			<input type="text" size="6" name="birth_date" id="birth_date">
		</td>
		<td>
			<label for="deathOper">
				Death Date
			</label>
			<select name="deathOper" size="1" id="deathOper">
				<option value="<=">Before</option>
				<option selected value="=" >Is</option>
				<option value=">=">After</option>
			</select>
			<input type="text" size="6" name="death_date" id="death_date">
		</td>
	</tr>
	<tr>
		<td>
			<label for="address">
				<a href="javascript:void(0);" onClick="getDocs('agent','address')">Address</a>
			</label>
			<input type="text" name="address" id="address">
		</td>
		<td>
			<label for="anyName">
				<a href="javascript:void(0);" onClick="getDocs('agent','anynamesearch')">Any part of any name</a>
			</label>
			<input type="text" name="anyName" id="anyName">
		</td>
	</tr>
	<tr>
		<td colspan="2" align="center">
			<input type="submit" 
				value="Search" 
				class="schBtn"
				onmouseover="this.className='schBtn btnhov'"
				onmouseout="this.className='schBtn'">
			<input type="reset" 
				value="Clear Form" 
				class="clrBtn"
				onmouseover="this.className='clrBtn btnhov'"
				onmouseout="this.className='clrBtn'">
				<br>
				<input type="button" 
					value="New Person" 
					class="insBtn"
					onmouseover="this.className='insBtn btnhov'"
					onmouseout="this.className='insBtn'"
					onClick="document.location='agents.cfm?action=newPerson';">
				<input type="button" 
					value="New Other Agent" 
					class="insBtn"
					onmouseover="this.className='insBtn btnhov'"
					onmouseout="this.className='insBtn'"
					onClick="document.location='agents.cfm?action=newOtherAgent';">
		</td>
	</tr>
</table>
</form>
</cfoutput>	
</cfif>
<!--------------------------------------------------------------------------->
<cfif #action# is "search">
<cfoutput>

<cfset sql = "SELECT 
					preferred_agent_name.agent_id,
					preferred_agent_name.agent_name,
					agent_type
				FROM 
					agent_name
					left outer join preferred_agent_name ON (agent_name.agent_id = preferred_agent_name.agent_id)
					LEFT OUTER JOIN agent ON (agent_name.agent_id = agent.agent_id)
					LEFT OUTER JOIN person ON (agent.agent_id = person.person_id)
				WHERE 
					agent.agent_id > -1
					">
					<!---
					agent_name_type='preferred'
					--->
<cfif isdefined("First_Name") AND len(#First_Name#) gt 0>
	<cfset sql = "#sql# AND first_name LIKE '#First_Name#'">
</cfif>
<cfif isdefined("Last_Name") AND len(#Last_Name#) gt 0>
	<cfset lastname = #replace(last_name,"'","''")#>
	<cfset sql = "#sql# AND Last_Name LIKE '#lastname#'">
</cfif>
<cfif isdefined("Middle_Name") AND len(#Middle_Name#) gt 0>
	<cfset sql = "#sql# AND Middle_Name LIKE '#Middle_Name#'">
</cfif>
<cfif isdefined("Suffix") AND len(#Suffix#) gt 0>
	<cfset sql = "#sql# AND Suffix = '#Suffix#'">
</cfif>
<cfif isdefined("Prefix") AND len(#Prefix#) gt 0>
	<cfset sql = "#sql# AND Prefix = '#Prefix#'">
</cfif>
<cfif isdefined("Birth_Date") AND len(#Birth_Date#) gt 0>
	<cfset bdate = #dateformat(birth_date,'dd-mmm-yyyy')#>
	<cfset sql = "#sql# AND Birth_Date #birthOper# '#bdate#'">
</cfif>
<cfif isdefined("Death_Date") AND len(#Death_Date#) gt 0>
	<cfset ddate = #dateformat(Death_Date,'dd-mmm-yyyy')#>
	<cfset sql = "#sql# AND Death_Date #deathOper# '#ddate#'">
</cfif>
<cfif isdefined("anyName") AND len(#anyName#) gt 0>
	<cfset sql = "#sql# AND upper(agent_name.agent_name) like '%#ucase(anyName)#%'">
</cfif>
<cfif isdefined("agent_id") AND isnumeric(#agent_id#)>
	<cfset sql = "#sql# AND agent_name.agent_id = #agent_id#">
</cfif>
<cfif isdefined("address") AND len(#address#) gt 0>
	<cfset sql = "#sql# AND agent_id IN (
			select agent_id from addr where upper(formatted_addr) like '%#ucase(address)#%')">
</cfif>

<cfset sql = "#sql# GROUP BY  preferred_agent_name.agent_id,
					preferred_agent_name.agent_name,
					agent_type">
<cfset sql = "#sql# ORDER BY preferred_agent_name.agent_name">
		<cfquery name="getAgents" datasource="#Application.web_user#">
			#preservesinglequotes(sql)#
		</cfquery>
	<cfif #getAgents.recordcount# is 0>
		<span style="background-color:red;">Nothing matched!</span>
	<cfelse>
		<p>Click to Edit:</p>
		<cfloop query="getAgents">
			<a href="agents.cfm?action=editAgent&agent_id=#agent_id#">
			 	#agent_name#</a> <font size="-1">(#agent_type#: #agent_id#)</font> 
		  	<br>
		</cfloop>
	</cfif>

</cfoutput>
</cfif>
<!-------------------------------------------->
<cfif #Action# is "newOtherAgent">
<cfoutput>
<form name="prefdName" action="agents.cfm" method="post">
	<input type="hidden" name="Action" value="makeNewAgent">
	<br>Name: <input type="text" name="agent_name" size="50">
	<br>Name Type:
		<input type="text" name="agent_name_type" value="preferred" readonly="yes" class="readClr">
	<br>Agent Type:
		<select name="agent_type" size="1">
			<cfloop query="ctAgentType">
				<cfif #ctAgentType.agent_type# neq 'person'>
					<option value="#ctAgentType.agent_type#">#ctAgentType.agent_type#</option>
				</cfif>
			</cfloop>
		</select>
		<br>Remarks: <input type="text"  size="50" name="agent_remarks">
		<input type="submit" value="Save" class="savBtn"
   			onmouseover="this.className='savBtn btnhov'" onmouseout="this.className='savBtn'">
		</form>
	</cfoutput>
</cfif>
<!----------------------------------------------------->
















<!------------------------------------------------------------------------------------------------------------->
<cfif #Action# is "newPerson">
	<form name="newPerson" action="agents.cfm" method="post">
		<input type="hidden" name="Action" value="insertPerson">
		<br>Prefix: 
		<select name="prefix" size="1">
			<option value=""></option>
				<cfoutput query="ctprefix"> 
					<option value="#prefix#">#prefix#</option>
				</cfoutput> 
		</select>
		<br>First Name: <input type="text" name="first_name">
		<br>Middle Name: <input type="text" name="middle_name">
		<br>Last Name: <input type="text" name="last_name">
		<br>Suffix: 
		<select name="suffix" size="1">
			<option value=""></option>
			<cfoutput query="ctsuffix"> 
			<option value="#suffix#">#suffix#</option>
			</cfoutput> 
    	</select>
		<input type="submit" value="Add Person" class="savBtn"
   			onmouseover="this.className='savBtn btnhov'" onmouseout="this.className='savBtn'">
	</form>
</cfif>
<!------------------------------------------------------------------------------------------------------------->

<!------------------------------------------------------------------------------------------------------------->
<cfif #Action# is "editAgent">
	<cfquery name="person" datasource="#Application.web_user#">
			select 
				agent_id,
				person_id,
				prefix,
				suffix,
				first_name,
				last_name,
				middle_name,
				birth_date,
				death_date,
				agent_remarks,
				agent_type
			from 
				agent
				left outer join person on (agent_id = person_id)
				where agent_id=#agent_id#
		</cfquery>
		
	<cfoutput query="person">
		<cfif #agent_type# is "person">	
			<cfset nameStr="">
				<cfif len(#prefix#) gt 0>
					<cfif len(#nameStr#) gt 0>
						<cfset nameStr="#nameStr# #prefix#">
					<cfelse>
						<cfset nameStr="#prefix#">
					</cfif>
				</cfif>
				<cfif len(#first_name#) gt 0>
					<cfif len(#nameStr#) gt 0>
						<cfset nameStr="#nameStr# #first_name#">
					<cfelse>
						<cfset nameStr="#first_name#">
					</cfif>
				 </cfif>
					<cfif len(#middle_name#) gt 0>
						<cfif len(#nameStr#) gt 0>
							<cfset nameStr="#nameStr# #middle_name#">
						<cfelse>
							<cfset nameStr="#middle_name#">
						</cfif>
					</cfif>
					<cfif len(#last_name#) gt 0>
						<cfif len(#nameStr#) gt 0>
							<cfset nameStr="#nameStr# #last_name#">
						<cfelse>
							<cfset nameStr="#last_name#">
						</cfif>
					</cfif>
					<cfif len(#suffix#) gt 0>
						<cfif len(#nameStr#) gt 0>
							<cfset nameStr="#nameStr# #suffix#">
						<cfelse>
							<cfset nameStr="#suffix#">
						</cfif>
					</cfif>
					<cfif len(#birth_date#) gt 0>
						<cfset nameStr="#nameStr# (#dateformat(birth_date,"dd mmm yyyy")#">
					<cfelse>
						<cfset nameStr="#nameStr# (unknown">
					</cfif>
					<cfif len(#death_date#) gt 0>
						<cfset nameStr="#nameStr# - #dateformat(death_date,"dd mmm yyyy")#)">
					<cfelse>
						<cfset nameStr="#nameStr# - unknown)">
					</cfif>
				<cfelse>
						<cfquery name="getName" datasource="#Application.web_user#">
							select agent_name from agent_name where agent_id=#agent_id#
							and agent_name_type='preferred'
						</cfquery>
						<cfset nameStr=#getName.agent_name#>
					</cfif>
<table border="1"><!--- outer table --->
	<tr>
		 <td>
			<a href="javascript:void(0);" onClick="getDocs('agent')"><img src="/images/info.gif" border="0" alt="Agent Help"></a>
			<strong><font color="##000066">#nameStr#</font></strong> (#agent_type#) {ID: #agent_id#} 
			<cfif len(#person.agent_remarks#) gt 0>
				<br>#person.agent_remarks#
			</cfif>
			<br><a href="/info/agentActivity.cfm?agent_id=#agent_id#" target="#client.target#">Agent Activity</a>
		</td>
	</tr>
</cfoutput>
<cfquery name="agentAddrs" datasource="#Application.web_user#">
			select * from addr
			where 
			agent_id = #person.agent_id#
</cfquery>
<cfquery name="elecagentAddrs" datasource="#Application.web_user#">
			select * from electronic_address
			where 
			agent_id = #person.agent_id#
</cfquery>
	<tr>
		<td>
			<table>
				<tr>
					<td>
						<font color="##000066"><strong>Current Addresses:</strong></font>
					</td>
				</tr>
				<cfset i=1>
				<cfoutput>
				<cfloop query="agentAddrs">
				<form name="addr#i#" method="post" action="agents.cfm">
					<input type="hidden" name="agent_id" value="#person.agent_id#">
					<input type="hidden" name="addr_id" value="#agentAddrs.addr_id#">
					<input type="hidden" name="Action" value="editAddr">
					<input type="hidden" name="addrtype" value="#agentAddrs.addr_type#">
					<input type="hidden" name="job_title" value="#agentAddrs.job_title#">
					<input type="hidden" name="street_addr1" value="#agentAddrs.street_addr1#">
					<input type="hidden" name="department" value="#agentAddrs.department#">
					<input type="hidden" name="institution" value="#agentAddrs.institution#">
					<input type="hidden" name="street_addr2" value="#agentAddrs.street_addr2#">
					<input type="hidden" name="city" value="#agentAddrs.city#">
					<input type="hidden" name="state" value="#agentAddrs.state#">
					<input type="hidden" name="zip" value="#agentAddrs.zip#">
					<input type="hidden" name="country_cde" value="#agentAddrs.country_cde#">
					<input type="hidden" name="mail_stop" value="#agentAddrs.mail_stop#">
					<input type="hidden" name="validfg" value="#agentAddrs.valid_addr_fg#">
					<input type="hidden" name="addr_remarks" value="#agentAddrs.addr_remarks#">
					<input type="hidden" name="formatted_addr" value="#agentAddrs.formatted_addr#">
				<tr>
					<td>
						<em>Type:</em> #addr_type#&nbsp&nbsp&nbsp;
						Valid?
						<cfif #valid_addr_fg# is 1>
							Yes
						<cfelse>
							No
						</cfif>
					</td>
				</tr>
				<tr>
					<td>
						#replace(formatted_addr,"#chr(10)#","<br>","all")#
					</td>
				</tr>
				<tr>
					<td>
						<em>Remarks:</em> #addr_remarks#
					</td>
				</tr>
				<tr>
					<td nowrap align="center">
						<table>
							<tr>
								<td>
								<input type="submit" 
							value="Edit" 
							class="lnkBtn"
							onmouseover="this.className='lnkBtn btnhov'"
							onmouseout="this.className='lnkBtn'">
								</td>
								
						
						</form>
						<form name="kill#i#" method="post" action="agents.cfm">
							<input type="hidden" name="Action" value="deleteAddr">
							<input type="hidden" name="addr_id" value="#agentAddrs.addr_id#">
							<input type="hidden" name="agent_id" value="#person.agent_id#">
							
							<td>
								<input type="button" 
												value="Delete" 
												class="delBtn"
												onmouseover="this.className='delBtn btnhov'"
												onmouseout="this.className='delBtn'"
												onclick="confirmDelete('kill#i#');">
								</td>
							</tr>
						</table>
						
						</form>
					</td>
				</tr>
				<cfset i=#i#+1>
				</cfloop>
				</cfoutput>
			</table>
		</td>
	</tr>
	<tr>
		<td>
		<table>
			<tr>
				<td colspan="2">
					<font color="#000066"><strong>Current Electronic Addresses:</strong></font>
				</td>
			</tr>
			<cfset i=1>
			<cfoutput>
			<cfloop query="elecagentAddrs">
			<form name="elad#i#" method="post" action="agents.cfm">
			<input type="hidden" name="Action" >
			<input type="hidden" name="agent_id" value="#person.agent_id#">
			<input type="hidden" name="address_type" value="#address_type#">
			<input type="hidden" name="address" value="#address#">
			<tr>
				<td align="right">
					#address_type#: 
				</td>
				<td>
					#address#
				</td>
				<td>
				<input type="button" 
						value="Edit" 
						class="lnkBtn"
						onmouseover="this.className='lnkBtn btnhov'"
						onmouseout="this.className='lnkBtn'"
						onClick="elad#i#.Action.value='editElecAddr';submit();">
				</td>
				<td>
					<input type="button" 
						value="Delete" 
						class="delBtn"
						onmouseover="this.className='delBtn btnhov'"
						onmouseout="this.className='delBtn'"
						onClick="elad#i#.Action.value='deleElecAddr';confirmDelete('elad#i#');">
				</td>
			</tr>
			
			</form>
			<cfset i=#i#+1>
			</cfloop>
			</cfoutput>
		</table>
	</td>
</tr>
<cfif #person.agent_type# is "person">
<cfoutput query="person">
<form name="editPerson" action="agents.cfm" method="post">
	<input type="hidden" name="agent_id" value="#agent_id#">
	<input type="hidden" name="Action">
<tr>
	<td>
		<strong><font color="##000066">Person</font></strong>
	</td>
</tr>
<tr>
	<td>
		<table>
			<tr>
				<td><font size="-1">Prefix</font></td>
				<td><font size="-1">First Name</font></td>
				<td><font size="-1">Middle Name</font></td>
				<td><font size="-1">Last Name</font></td>
				<td><font size="-1">Suffix</font></td>
			</tr>
			<tr>
				<td>	
					<select name="prefix" size="1">
						<option value=""></option>
						<cfloop query="ctprefix"> 
							<option value="#ctprefix.prefix#"
							<cfif #ctprefix.prefix# is "#person.prefix#">selected</cfif>>#ctprefix.prefix#
							</option>
						</cfloop> 
					</select>
				</td>
				<td><input type="text" name="first_name" value="#first_name#"></td>
				<td><input type="text" name="middle_name" value="#middle_name#"></td>
				<td><input type="text" name="last_name" value="#last_name#"></td>
				<td>
					<select name="suffix" size="1">
						<option value=""></option>
						   <cfloop query="ctsuffix"> 
								<option value="#ctsuffix.suffix#"
									<cfif #ctsuffix.suffix# is "#person.suffix#">selected</cfif>>#ctsuffix.suffix#</option>
							</cfloop> 
					</select>
				</td>
			</tr>
			<tr>
				<td align="right">DOB</td>
				<td><input type="text" name="birth_date" value="#dateformat(birth_date,'dd mmm yyyy')#" size="10"></td>
				<td align="right">DOD</td>
				<td colspan="2"><input type="text" name="death_date" value="#dateformat(death_date,'dd mmm yyyy')#" size="10"></td>
			</tr>
			<tr>
				<td align="right">Remarks:</td>
				<td colspan="4"><input type="text" value="#agent_remarks#" name="agent_remarks" size="50"></td>
			</tr>
		</table>
<tr>
	<td align="center">
		<input type="button" 
				value="Update Person" 
				class="savBtn"
				onmouseover="this.className='savBtn btnhov'"
				onmouseout="this.className='savBtn'"
				onClick="editPerson.Action.value='editPerson';submit();">
	</td>
</tr>
</form>
</cfoutput>
</cfif>
</td>
</tr><!--- end of person blurb ---->
	<cfoutput>
<!---------------------------- group handling ------------------------------>
<cfif #person.agent_type# is "group">
	<tr>
		<td>
			<cfquery name="grpMem" datasource="#Application.web_user#">
				select 
					MEMBER_AGENT_ID,
					MEMBER_ORDER,
					agent_name					
				from 
					group_member,
					preferred_agent_name
				where 
					group_member.MEMBER_AGENT_ID = preferred_agent_name.agent_id AND
					GROUP_AGENT_ID = #agent_id#
				order by MEMBER_ORDER					
			</cfquery>
			<table border>
				<tr>
					<td colspan="3">Group Members:</td>
				</tr>
				<tr>
					<td>Name</td>
					<td>Order</td>
					<td>&nbsp;</td>
				</tr>
				<cfset i=1>
				<cfloop query="grpMem">
					<form name="groupMember#i#" method="post" action="agents.cfm">
						<input type="hidden" name="action" />
						<input type="hidden" name="member_agent_id" value="#member_agent_id#" />
						<input type="hidden" name="agent_id" value="#agent_id#" />
					<tr>
						<td>
							#agent_name#
						</td>
						<td>#MEMBER_ORDER#</td>
						<td>
							<input type="button" 
								value="Delete Member" 
								class="delBtn"
								onmouseover="this.className='delBtn btnhov'"
								onmouseout="this.className='delBtn'"
								onClick="groupMember#i#.action.value='deleteGroupMember';confirmDelete('groupMember#i#');">
						</td>
					</tr>
					</form>
					<cfset i=#i# + 1>
				</cfloop>
			</table>
			<form name="newGroupMember" method="post" action="agents.cfm">
				<input type="hidden" name="agent_id" value="#agent_id#" />
				<input type="hidden" name="action" value="makeNewGroupMemeber" />
				<cfquery name="memOrd" dbtype="query">
					select max(member_order) + 1 as nextMemOrd from grpMem
				</cfquery>
				<cfif #len(memOrd.nextMemOrd)# gt 0>
					<cfset nOrd = #memOrd.nextMemOrd#>
				<cfelse>
					<cfset nOrd = 1>
				</cfif>
				<input type="hidden" name="member_order" value="#nOrd#" />
			<table class="newRec">
				<tr>
					<td colspan="2">Add Member to Group</td>
				</tr>
				<tr>
					<td>
						<input type="hidden" name="member_id">
						<input type="text" name="group_member" class="reqdClr" 
							onchange="getAgent('member_id','group_member','newGroupMember',this.value); return false;"
		 					onKeyPress="return noenter(event);">
					</td>
					
					<td>
						<input type="submit" 
								value="Insert Member" 
								class="insBtn"
								onmouseover="this.className='insBtn btnhov'"
								onmouseout="this.className='insBtn'">
					</td>
				</tr>
			</table>
			</form>
		</td>
	</tr>
</cfif>
<!---------------------------- / group handling ------------------------------>
	

		<cfquery name="names" datasource="#Application.web_user#">
			select * from agent_name where agent_id=#agent_id#
		</cfquery>
	</cfoutput>
	
		<!--- we have to loop here so we can get unique form names. Names cannot be a number, so tack on a... --->
		<cfset name = 1>
<tr>
	<td>
		<font color="#000066"><strong><a href="javascript:void(0);" onClick="getDocs('agent','names')">
			Agent Names:</a></strong></font>
	 </td>
</tr>
<tr>
	<td>
		<table>
			<cfloop query="names">
			<cfoutput>
			<form name="a#name#" action="agents.cfm" method="post">
			<input type="hidden" name="Action">
			<input type="hidden" name="agent_name_id" value="#names.agent_name_id#">
			<input type="hidden" name="agent_id" value="#names.agent_id#">
			<tr>
				<td>
					<input type="text" value="#names.agent_name#" name="agent_name">
				</td>
				<td>
					<select name="agent_name_type">
						<cfif #agent_name_type# is not "preferred">
						 <cfset thisName = "#names.agent_name_type#">	
						<cfloop query="ctNameType">
							<option  <cfif #ctNameType.agent_name_type# is "#thisName#"> selected </cfif>value="#ctNameType.agent_name_type#">#ctNameType.agent_name_type#</option>
						</cfloop>
						<cfelse>
							<option value="preferred">preferred</option>
						</cfif>
					</select>
				</td>
				<td>
					<input type="button" 
						value="Update" 
						class="savBtn"
						onmouseover="this.className='savBtn btnhov'"
						onmouseout="this.className='savBtn'"
						onClick="a#name#.Action.value='updateName';submit();">
					<cfif #agent_name_type# is not "preferred">
					<input type="button" 
						value="Delete" 
						class="delBtn"
						onmouseover="this.className='delBtn btnhov'"
						onmouseout="this.className='delBtn'"
						onClick="a#name#.Action.value='deleteName';confirmDelete('a#name#');">
					</cfif>
					<input type="button" 
						value="Copy" 
						class="insBtn"
						onmouseover="this.className='insBtn btnhov'"
						onmouseout="this.className='insBtn'"
						onClick="newName.agent_name.value='#names.agent_name#';newName.agent_name_type.value='#names.agent_name_type#'">
				</td>
			</tr>
			</form>
			<cfset name = #name# + 1>
			</cfoutput>
			</cfloop>
		</table>
	</td>
</tr>
<tr>
	<td>
		<table class="newRec">
			<tr>
				<td colspan="3">
					<font color="#FF00FF">Add new name</font>
				</td>
			</tr>
			<cfoutput>
			 <form name="newName" action="agents.cfm" method="post">
			 <input type="hidden" name="Action" value="newName">
			 <input type="hidden" name="agent_id" value="#person.agent_id#">
			<tr>
				<td>
					<input type="text" name="agent_name">
				</td>
				<td>
					 <select name="agent_name_type">
						<cfloop query="ctNameType">
							<option value="#ctNameType.agent_name_type#">#ctNameType.agent_name_type#</option>
						</cfloop>
					  </select>
				</td>
				<td>
					<input type="submit" 
						value="Create" 
						class="insBtn"
						onmouseover="this.className='insBtn btnhov'"
						onmouseout="this.className='insBtn'">
				</td>
			</tr>
			</form>
			</cfoutput>
		</table>
  	</td> 
</tr>
<cfquery name="relns" datasource="#Application.web_user#">
		select agent_relationship, agent_name, related_agent_id
		 from agent_relations, agent_name
		  where 
		  agent_relations.related_agent_id = agent_name.agent_id 
		  and agent_name_type = 'preferred' and
		  agent_relations.agent_id=#person.agent_id#
	</cfquery>
		<cfquery name="ctRelns" datasource="#Application.web_user#">
			select AGENT_RELATIONSHIP from CTAGENT_RELATIONSHIP
	</cfquery>
<cfif #relns.recordcount# gt 0>
<tr>
    <td>
		<table>
			<tr>
				<td colspan="3">
					<font color="#FF00FF">
					 <a href="javascript:void(0);" onClick="getDocs('agent','relations')">
					 Related Agents</a>
					</font>
				</td>
			</tr>
			<cfset i=1>
			<cfoutput>
			<cfloop query="relns">
			<form name="agentRelations#i#" method="post" action="agents.cfm">
			  <input type="hidden" name="Action">
			  <input type="hidden" name="agent_id" value="#person.agent_id#">
			  <input type="hidden" name="related_agent_id" value="#related_agent_id#">
			  <input type="hidden" name="oldRelationship" value="#agent_relationship#">
			  <input type="hidden" name="newRelatedAgentId">
			  <cfset thisReln = #agent_relationship#>
			<tr>
				<td>
					 <select name="relationship" size="1">
						<cfloop query="ctRelns">
						  <option value="#ctRelns.AGENT_RELATIONSHIP#"
										<cfif #ctRelns.AGENT_RELATIONSHIP# is "#thisReln#">
											selected
										</cfif>
										>#ctRelns.AGENT_RELATIONSHIP# </option>
						</cfloop>
					  </select> 
				</td>
				<td>
					 <input type="text" name="related_agent" class="reqdClr" value="#agent_name#"
						onchange="getAgent('newRelatedAgentId','related_agent','agentRelations#i#',this.value); return false;"
						onKeyPress="return noenter(event);">
				</td>
				<td>
					<input type="button" 
						value="Save Change" 
						class="savBtn"
						onmouseover="this.className='savBtn btnhov'"
						onmouseout="this.className='savBtn'"
						onClick="agentRelations#i#.Action.value='changeRelated';submit();">
					<input type="button" 
						value="Delete" 
						class="delBtn"
						onmouseover="this.className='delBtn btnhov'"
						onmouseout="this.className='delBtn'"
						onClick="agentRelations#i#.Action.value='deleteRelated';confirmDelete('agentRelations#i#');">
				</td>
			</tr>
			</form>
			<cfset i=#i#+1>
			</cfloop> 
			</cfoutput> 
		</table>
	</td>
</tr>
</cfif>
<tr>
	<td>
		<table class="newRec">
			<tr>
				<td>
					<font color="#FF00FF">Add New Relationship </font>
				</td>
			</tr>
			<cfoutput>
			<form name="newRelationship" method="post" action="agents.cfm">
			<input type="hidden" name="Action" value="addRelationship">
			<input type="hidden" name="newRelatedAgentId">
			<input type="hidden" name="agent_id" value="#person.agent_id#">
			<tr class="newRec"> 
				<td>
					<select name="relationship" size="1">
						<cfloop query="ctRelns"> 
							<option value="#ctRelns.AGENT_RELATIONSHIP#">#ctRelns.AGENT_RELATIONSHIP#</option>
						</cfloop> 
					</select>
				</td>
				<td>
					<input type="text" name="related_agent" class="reqdClr"
						onchange="getAgent('newRelatedAgentId','related_agent','newRelationship',this.value); return false;"
						onKeyPress="return noenter(event);">
				</td>					
				<td>
					<input type="submit" 
						value="Save Change" 
						class="savBtn"
						onmouseover="this.className='savBtn btnhov'"
						onmouseout="this.className='savBtn'">
				</td>
			</tr>
			</form>
			</cfoutput>
		</table>
	</td>
</tr>
<tr>
	<td>
<table class="newRec">
<tr>
	<td colspan="2">
		Add Address for this agent:
	</td>
</tr>

		<cfoutput>
			<cfform name="newAddress" method="post" action="agents.cfm">
				<input type="hidden" name="agent_id" value="#person.agent_id#">
				<input type="hidden" name="Action" value="newAddress">
				
					<tr>
						<td>Address Type:</td>
						<td>
							<select name="addr_type" size="1">
								<cfloop query="ctAddrType">
								<option value="#ctAddrType.addr_type#">#ctAddrType.addr_type#</option>
								</cfloop>
							</select>
						</td>
						<td>Job Title</td>
						<td><input type="text" name="job_title"></td>
					</tr>
					<tr>
						<td>Institution</td>
						<td colspan="3">
							<input type="text" name="Institution" size="50" >
						</td>
					</tr>
					<tr>
						<td>Department</td>
						<td colspan="3">
							<input type="text" name="Department" size="50" >
						</td>
					</tr>
					<tr>
						<td>Address 1</td>
						<td colspan="3">
							<input type="text" name="street_addr1" size="50" class="reqdClr">
						</td>
					</tr>
					<tr>
						<td>Address 2</td>
						<td colspan="3">
							<input type="text" name="street_addr2" size="50">
						</td>
					</tr>
					<tr>
						<td>City</td>
						<td>
							<input type="text" name="city" class="reqdClr">
						</td>
						<td>State</td>
						<td>
							<input type="text" name="state" class="reqdClr">
						</td>
					</tr>
					<tr>
						<td>Zip</td>
						<td><input type="text" name="zip" class="reqdClr"></td>
						<td>Country</td>
						<td>
							<input type="text" name="country_cde">
						</td>
					</tr>
					<tr>
						<td>Mail Stop</td>
						<td>
							<input type="text" name="mail_stop">
						</td>
						<td>Valid?</td>
						<td>
							<select name="valid_addr_fg" size="1">
									<option value="1">yes</option>
									<option value="0">no</option>
								</select>
						</td>
					</tr>
					<tr>				
						<td>Remarks</td>
						<td colspan="3">
							<input type="text" name="addr_remarks" size="50">
						</td>
					</tr>
					<tr>
						<td>
						<input type="submit" 
							value="Save this Address" 
							class="savBtn"
							onmouseover="this.className='savBtn btnhov'"
							onmouseout="this.className='savBtn'">
						</td>
					</tr>
					</table>
</cfform>

					<cfform name="newElecAddr" method="post" action="agents.cfm">
					<input name="Action" type="hidden" value="newElecAddr">
					<input type="hidden" name="agent_id" value="#person.agent_id#">
					<table class="newRec">
					<tr>
						<td>Add Electronic Address:</td>
					</tr>
					<tr>
						<td>Address Type:
						</td>
						<td>
							<select name="address_type" size="1">
								<cfloop query="ctElecAddrType">
									<option value="#ctElecAddrType.address_type#">#ctElecAddrType.address_type#</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td>Address</td>
						<td><input type="text" name="Address"></td>
					<tr>
						<td>
						<input type="submit" 
							value="Save this Electronic Address" 
							class="savBtn"
							onmouseover="this.className='savBtn btnhov'"
							onmouseout="this.className='savBtn'">
						</td>
					</tr>
				</table>
			</cfform>
			</td></tr></table>
		</cfoutput>
		
		
		
		
				
</cfif><!--- end action=view --->
<!------------------------------------------------------------------------------------------------------------->

<!------------------------------------------------------------------------------------------------------------->
<cfif #Action# is "editElecAddr">
<cfoutput>
<cfform name="edElecAddr" method="post" action="agents.cfm">
					<input name="Action" type="hidden" value="saveEditElecAddr">
					<input type="hidden" name="agent_id" value="#agent_id#">
					<input type="hidden" name="origAddress" value="#address#">
					<input type="hidden" name="origAddressType" value="#address_type#">
					<table><tr>
						<td>Address Type:
						</td>
						<td>
							<select name="address_type" size="1">
								<cfloop query="ctElecAddrType">
									<option <cfif #form.address_type# is "#ctElecAddrType.address_type#"> selected </cfif>value="#ctElecAddrType.address_type#">#ctElecAddrType.address_type#</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td>Address</td>
						<td><input type="text" name="Address" value="#address#"></td>
					<tr>
						<td>
						<input type="submit" 
		value="Save Updates" 
		class="savBtn"
		onmouseover="this.className='savBtn btnhov'"
		onmouseout="this.className='savBtn'">
		</td>
					</tr>
				</table>
			</cfform>
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->

<!------------------------------------------------------------------------------------------------------------->
<cfif #Action# is "saveEditElecAddr">
	<cfoutput>
		<cfquery name="upElecAddr" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			UPDATE electronic_address SET
				address_type = '#address_type#',
				address = '#address#'
			where
				agent_id = #agent_id#
				and address_type = '#origAddressType#'
				and address = '#origAddress#'
		</cfquery>
		
		<cf_ActivityLog sql="
			UPDATE electronic_address SET
				address_type = '#address_type#',
				address = '#address#'
			where
				agent_id = #agent_id#
				and address_type = '#origAddressType#'
				and address = '#origAddress#'">

		<cflocation url="agents.cfm?action=editAgent&agent_id=#agent_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->
<!------------------------------------------------------------------------------------------------------------->
<cfif #Action# is "deleElecAddr">
	<cfoutput>
		<cfquery name="deleElecAddr" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			delete from electronic_address where
				agent_id=#agent_id#
				and address_type='#address_type#'
				and address='#address#'
		</cfquery>
		<cf_ActivityLog sql="
			delete from electronic_address where
				agent_id=#agent_id#
				and address_type='#address_type#'
				and address='#address#'">
		<cflocation url="agents.cfm?action=editAgent&agent_id=#agent_id#">
		
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->

<!------------------------------------------------------------------------------------------------------------->
<cfif #Action# is "editAddr">
<cfset title = "Edit Address">
Edit This Address:
<cfoutput>
<form name="editAddr" method="post" action="agents.cfm">
				<input type="hidden" name="agent_id" value="#agent_id#">
				<input type="hidden" name="addr_id" value="#addr_id#">
				<input type="hidden" name="Action" value="saveEditsAddr">
				<tr><td>
				<table>
					<tr>
						<td>Address Type:</td>
						<td>
							<select name="addr_type" size="1">
								<cfloop query="ctAddrType">
								<option 
									<cfif #addrtype# is "#ctAddrType.addr_type#"> selected </cfif>
										value="#ctAddrType.addr_type#">#ctAddrType.addr_type#</option>
								</cfloop>
							</select>
						</td>
						<td>Job Title</td>
						<td><input type="text" name="job_title" value="#job_title#"></td>
					</tr>
					<tr>
						<td>Institution</td>
						<td colspan="3">
							<input type="text" name="Institution" size="50" value="#Institution#">
						</td>
					</tr>
					<tr>
						<td>Department</td>
						<td colspan="3">
							<input type="text" name="Department" size="50" value="#Department#">
						</td>
					</tr>
					<tr>
						<td>Address 1</td>
						<td colspan="3">
							<input type="text" name="street_addr1" size="50" value="#street_addr1#">
						</td>
					</tr>
					<tr>
						<td>Address 2</td>
						<td colspan="3">
							<input type="text" name="street_addr2" size="50" value="#street_addr2#">
						</td>
					</tr>
					<tr>
						<td>City</td>
						<td>
							<input type="text" name="city" value="#city#">
						</td>
						<td>State</td>
						<td>
							<input type="text" name="state" value="#state#">
						</td>
					</tr>
					<tr>
						<td>Zip</td>
						<td><input type="text" name="zip" value="#zip#"></td>
						<td>Country</td>
						<td>
							<input type="text" name="country_cde" value="#country_cde#">
						</td>
					</tr>
					<tr>
						<td>Mail Stop</td>
						<td>
							<input type="text" name="mail_stop" value="#mail_stop#">
						</td>
						<td>Valid?</td>
						<td>
							<select name="valid_addr_fg" size="1">
									<option <cfif #validfg# IS 	"1"> SELECTED </cfif>value="1">yes</option>
									<option <cfif #validfg# IS 	"0"> SELECTED </cfif>value="0">no</option>
								</select>
						</td>
					</tr>
					<tr>				
						<td>Remarks</td>
						<td colspan="3">
							<input type="text" name="addr_remarks" size="50" value="#addr_remarks#">
						</td>
					</tr>
					<tr>
						<td>Formatted Address
							<br>
                <font size="-1">(Leave blank to auto-generate)</font> </td>
						<cfset thisAddr = #replace(formatted_addr,"<br>","##chr(10)##","all")#>
						<td colspan="3"><textarea rows="6" cols="50" name="formatted_addr">#thisAddr#</textarea></td>
					</tr>
					<tr>
						<td><input type="submit" 
		value="Save Updates" 
		class="savBtn"
		onmouseover="this.className='savBtn btnhov'"
		onmouseout="this.className='savBtn'"></td>
					</tr>
					</table>
</form>
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->
<!------------------------------------------------------------------------------------------------------------->	
<cfif #Action# is "saveEditsAddr">
	<cfoutput>
		<cfquery name="editAddr" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			UPDATE addr SET 
				STREET_ADDR1 = '#STREET_ADDR1#'
				<cfif len(#STREET_ADDR2#) gt 0>
					,STREET_ADDR2 = '#STREET_ADDR2#'
				  <cfelse>
				  	,STREET_ADDR2 = null				
				</cfif>
				<cfif len(#department#) gt 0>
					,department = '#department#'
				  <cfelse>
				  	,department = null				
				</cfif>
				<cfif len(#institution#) gt 0>
					,institution = '#institution#'
				  <cfelse>
				  	,institution = null				
				</cfif>
				,CITY = '#CITY#'
				,STATE = '#STATE#'
				,ZIP = '#ZIP#'
				<cfif len(#COUNTRY_CDE#) gt 0>
					,COUNTRY_CDE = '#COUNTRY_CDE#'
				  <cfelse>
				  	,COUNTRY_CDE = null				
				</cfif>
				<cfif len(#MAIL_STOP#) gt 0>
					,MAIL_STOP = '#MAIL_STOP#'
				  <cfelse>
				  	,MAIL_STOP = null				
				</cfif>
				,AGENT_ID = #AGENT_ID#
				,ADDR_TYPE = '#ADDR_TYPE#'
				<cfif len(#JOB_TITLE#) gt 0>
					,JOB_TITLE = '#JOB_TITLE#'
				  <cfelse>
				  	,JOB_TITLE = null				
				</cfif>
				,VALID_ADDR_FG = '#VALID_ADDR_FG#'
				<cfif len(#ADDR_REMARKS#) gt 0>
					,ADDR_REMARKS = '#ADDR_REMARKS#'
				  <cfelse>
				  	,ADDR_REMARKS = null				
				</cfif>
				where addr_id=#addr_id#
		</cfquery>
			<cf_ActivityLog sql="UPDATE addr SET 
				STREET_ADDR1 = '#STREET_ADDR1#'
				<cfif len(#STREET_ADDR2#) gt 0>
					,STREET_ADDR2 = '#STREET_ADDR2#'
				  <cfelse>
				  	,STREET_ADDR2 = null				
				</cfif>
				<cfif len(#department#) gt 0>
					,department = '#department#'
				  <cfelse>
				  	,department = null				
				</cfif>
				<cfif len(#institution#) gt 0>
					,institution = '#institution#'
				  <cfelse>
				  	,institution = null				
				</cfif>
				,CITY = '#CITY#'
				,STATE = '#STATE#'
				,ZIP = '#ZIP#'
				<cfif len(#COUNTRY_CDE#) gt 0>
					,COUNTRY_CDE = '#COUNTRY_CDE#'
				  <cfelse>
				  	,COUNTRY_CDE = null				
				</cfif>
				<cfif len(#MAIL_STOP#) gt 0>
					,MAIL_STOP = '#MAIL_STOP#'
				  <cfelse>
				  	,MAIL_STOP = null				
				</cfif>
				,AGENT_ID = #AGENT_ID#
				,ADDR_TYPE = '#ADDR_TYPE#'
				<cfif len(#JOB_TITLE#) gt 0>
					,JOB_TITLE = '#JOB_TITLE#'
				  <cfelse>
				  	,JOB_TITLE = null				
				</cfif>
				,VALID_ADDR_FG = '#VALID_ADDR_FG#'
				<cfif len(#ADDR_REMARKS#) gt 0>
					,ADDR_REMARKS = '#ADDR_REMARKS#'
				  <cfelse>
				  	,ADDR_REMARKS = null				
				</cfif>
				where addr_id=#addr_id#">
		<Cfif len(#formatted_addr#) is 0>
			<!--- make one, otherwise use their edits --->
			<cfquery name="addr" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				select * from addr
				,preferred_agent_name where addr.agent_id = preferred_agent_name.agent_id
				and addr_id=#addr_id#
			</cfquery>
			<cfset formAddr = "#addr.agent_name#">
			<cfif len(#addr.job_title#) gt 0>
				<cfset formAddr = "#formAddr#, #addr.job_title#">		
			</cfif>
			<cfif len(#addr.institution#) gt 0>
				<cfset formAddr = "#formAddr#<br>#addr.institution#">		
			</cfif>
			<cfif len(#addr.department#) gt 0>
				<cfset formAddr = "#formAddr#<br>#addr.department#">		
			</cfif>
			<cfif len(#addr.street_addr1#) gt 0>
				<cfset formAddr = "#formAddr#<br>#addr.street_addr1#">		
			</cfif>
			<cfif len(#addr.street_addr2#) gt 0>
				<cfset formAddr = "#formAddr#<br>#addr.street_addr2#">		
			</cfif>
				<cfset formAddr = "#formAddr#<br>#addr.city#, #addr.state# #addr.zip#">		
			<cfif len(#addr.country_cde#) gt 0>
				<cfset formAddr = "#formAddr#<br>#addr.country_cde#">		
			</cfif>
			<cfif len(#addr.mail_stop#) gt 0>
				<cfset formAddr = "#formAddr#<br>#addr.mail_stop#">		
			</cfif>
			<cfset formatted_addr = #replace(formAddr,"<br>","#chr(10)#","all")#>
		</Cfif>	
			<cfquery name="makeFormat" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				update addr SET formatted_addr=
					'#formatted_addr#'
				where addr_id = #addr_id#
			</cfquery>
		
		<cflocation url="agents.cfm?action=editAgent&agent_id=#agent_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->
<!------------------------------------------------------------------------------------------------------------->	
<cfif #Action# is "deleteAddr">
	<cfoutput>
		<cfquery name="killAddr" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			delete from addr where addr_id=#addr_id#
		</cfquery>
		<cf_ActivityLog sql="delete from addr where addr_id=#addr_id#">
		<cflocation url="agents.cfm?action=editAgent&agent_id=#agent_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->
<!------------------------------------------------------------------------------------------------------------->	
<cfif #Action# is "saveCurrentAddress">
	<cfoutput>
		
		<cfquery name="nextAddr" datasource="#Application.web_user#">
			select max(addr_id) + 1 as nextAddrId from addr
		</cfquery>
	<cftransaction>
	<cfquery name="addr" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			UPDATE addr SET 
				addr_id = #addr_id#
			 <cfif len(#STREET_ADDR1#) gt 0>
			 	,STREET_ADDR1 = '#STREET_ADDR1#'
			 </cfif>
			 <cfif len(#institution#) gt 0>
			 	,institution = '#institution#'
			 </cfif>
			 <cfif len(#department#) gt 0>
			 	,department = '#department#'
			 </cfif>
			 <cfif len(#STREET_ADDR2#) gt 0>
			 	,STREET_ADDR2 = '#STREET_ADDR2#'
			 </cfif>
			 <cfif len(#CITY#) gt 0>
			 	,CITY = '#CITY#'
			 </cfif>
			 <cfif len(#state#) gt 0>
			 	,state = '#state#'
			 </cfif>
			 <cfif len(#ZIP#) gt 0>
				,ZIP = '#ZIP#'
			 </cfif>
			 <cfif len(#COUNTRY_CDE#) gt 0>
			 	,COUNTRY_CDE = '#COUNTRY_CDE#'
			 </cfif>
			 <cfif len(#MAIL_STOP#) gt 0>
			 	,MAIL_STOP = '#MAIL_STOP#'
			 </cfif>
			 where addr_id = #addr_id#
	</cfquery>	
		
		<cfquery name="addr" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			select * from addr
			,preferred_agent_name where addr.agent_id = preferred_agent_name.agent_id
			and addr_id=#addr_id#
		</cfquery>
		<cfset formAddr = "#addr.agent_name#">
		<cfif len(#addr.job_title#) gt 0>
			<cfset formAddr = "#formAddr#, #addr.job_title#">		
		</cfif>
		<cfif len(#addr.institution#) gt 0>
			<cfset formAddr = "#formAddr#<br>#addr.institution#">		
		</cfif>
		<cfif len(#addr.department#) gt 0>
			<cfset formAddr = "#formAddr#<br>#addr.department#">		
		</cfif>
		<cfif len(#addr.street_addr1#) gt 0>
			<cfset formAddr = "#formAddr#<br>#addr.street_addr1#">		
		</cfif>
		<cfif len(#addr.street_addr2#) gt 0>
			<cfset formAddr = "#formAddr#<br>#addr.street_addr2#">		
		</cfif>
			<cfset formAddr = "#formAddr#<br>#addr.city#, #addr.state# #addr.zip#">		
		<cfif len(#addr.country_cde#) gt 0>
			<cfset formAddr = "#formAddr#<br>#addr.country_cde#">		
		</cfif>
		<cfif len(#addr.mail_stop#) gt 0>
			<cfset formAddr = "#formAddr#<br>#addr.mail_stop#">		
		</cfif>	
			<cfquery name="makeFormat" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				update addr SET formatted_addr=
					'#formAddr#'
				where addr_id = #addr_id#
			</cfquery>
		<cfquery name="elecaddr" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				UPDATE electronic_address 
			 SET AGENT_ID = #agent_id#
			 <cfif len(#ELECTRONIC_ADDR#) gt 0>
			 ,ELECTRONIC_ADDR = '#ELECTRONIC_ADDR#'	
			 </cfif>
			 <cfif len(#address_type#) gt 0>
			 	,address_type='#address_type#'	
			 </cfif>
			where
			AGENT_ID = #agent_id#
		</cfquery>
		</cftransaction>
		<cf_ActivityLog sql="UPDATE addr SET 
				addr_id = #addr_id#
			 <cfif len(#STREET_ADDR1#) gt 0>
			 	,STREET_ADDR1 = '#STREET_ADDR1#'
			 </cfif>
			 <cfif len(#institution#) gt 0>
			 	,institution = '#institution#'
			 </cfif>
			 <cfif len(#department#) gt 0>
			 	,department = '#department#'
			 </cfif>
			 <cfif len(#STREET_ADDR2#) gt 0>
			 	,STREET_ADDR2 = '#STREET_ADDR2#'
			 </cfif>
			 <cfif len(#CITY#) gt 0>
			 	,CITY = '#CITY#'
			 </cfif>
			 <cfif len(#state#) gt 0>
			 	,state = '#state#'
			 </cfif>
			 <cfif len(#ZIP#) gt 0>
				,ZIP = '#ZIP#'
			 </cfif>
			 <cfif len(#COUNTRY_CDE#) gt 0>
			 	,COUNTRY_CDE = '#COUNTRY_CDE#'
			 </cfif>
			 <cfif len(#MAIL_STOP#) gt 0>
			 	,MAIL_STOP = '#MAIL_STOP#'
			 </cfif>
			 where addr_id = #addr_id#">
			<cf_ActivityLog
			 sql="UPDATE electronic_address 
			 SET AGENT_ID = #agent_id#
			 <cfif len(#ELECTRONIC_ADDR#) gt 0>
			 ,ELECTRONIC_ADDR = '#ELECTRONIC_ADDR#'	
			 </cfif>
			 <cfif len(#address_type#) gt 0>
			 	,address_type='#address_type#'	
			 </cfif>
			where
			AGENT_ID = #agent_id#">
			
<cflocation url="agents.cfm?action=editAgent&agent_id=#agent_id#">
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------>

<!------------------------------------------------------------------------------------------------------------>
<cfif #Action# is "newElecAddr">
	<cfoutput>
	<cfquery name="elecaddr" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				INSERT INTO electronic_address (
			 AGENT_ID
			 ,address_type
		 	,address	
			 )
			VALUES (
				#agent_id#
				,'#address_type#'
		 	,'#address#'
			)
		</cfquery>
		<cf_ActivityLog sql="INSERT INTO electronic_address (
			 AGENT_ID
			 ,address_type
		 	,address	
			 )
			VALUES (
				#agent_id#
				,'#address_type#'
		 	,'#address#'
			)">
		<cflocation url="agents.cfm?action=editAgent&agent_id=#agent_id#">
		</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------>


<!------------------------------------------------------------------------------------------------------------->	
<cfif #Action# is "newAddress">
	<cfoutput>
		<cfquery name="nextAddr" datasource="#Application.web_user#">
			select max(addr_id) + 1 as nextAddrId from addr
		</cfquery>
		<cfquery name="prefName" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			select agent_name from preferred_agent_name where agent_id=#agent_id#
		</cfquery>
	<cftransaction>
	<cfquery name="addr" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		INSERT INTO addr (
			 ADDR_ID
			 <cfif len(#STREET_ADDR1#) gt 0>
			 	,STREET_ADDR1
			 </cfif>
			 <cfif len(#STREET_ADDR2#) gt 0>
			 	,STREET_ADDR2
			 </cfif>
			 <cfif len(#institution#) gt 0>
			 	,institution
			 </cfif>
			 <cfif len(#department#) gt 0>
			 	,department
			 </cfif>
			 <cfif len(#CITY#) gt 0>
			 	,CITY
			 </cfif>
			 <cfif len(#state#) gt 0>
			 	,state
			 </cfif>
			 <cfif len(#ZIP#) gt 0>
			 	,ZIP
			 </cfif>
			 <cfif len(#COUNTRY_CDE#) gt 0>
			 	,COUNTRY_CDE
			 </cfif>
			 <cfif len(#MAIL_STOP#) gt 0>
			 	,MAIL_STOP
			 </cfif>
			 <cfif len(#agent_id#) gt 0>
			 	,agent_id
			 </cfif>
			 <cfif len(#addr_type#) gt 0>
			 	,addr_type
			 </cfif>
			 <cfif len(#job_title#) gt 0>
			 	,job_title
			 </cfif>
			 <cfif len(#valid_addr_fg#) gt 0>
			 	,valid_addr_fg
			 </cfif>
			  <cfif len(#addr_remarks#) gt 0>
			 	,addr_remarks
			 </cfif>
			  )
			VALUES (
			 #nextAddr.nextAddrId#
			 <cfif len(#STREET_ADDR1#) gt 0>
			 	,'#STREET_ADDR1#'
			 </cfif>
			 <cfif len(#STREET_ADDR2#) gt 0>
			 	,'#STREET_ADDR2#'
			 </cfif>
			 <cfif len(#institution#) gt 0>
			 	,'#institution#'
			 </cfif>
			 <cfif len(#department#) gt 0>
			 	,'#department#'
			 </cfif>
			 <cfif len(#CITY#) gt 0>
			 	,'#CITY#'
			 </cfif>
			  <cfif len(#state#) gt 0>
			 	,'#state#'
			 </cfif>
			 <cfif len(#ZIP#) gt 0>
			 	,'#ZIP#'
			 </cfif>
			 <cfif len(#COUNTRY_CDE#) gt 0>
			 	,'#COUNTRY_CDE#'
			 </cfif>
			 <cfif len(#MAIL_STOP#) gt 0>
			 	,'#MAIL_STOP#'
			 </cfif>
			 <cfif len(#agent_id#) gt 0>
			 	,#agent_id#
			 </cfif>
			 <cfif len(#addr_type#) gt 0>
			 	,'#addr_type#'
			 </cfif>
			 <cfif len(#job_title#) gt 0>
			 	,'#job_title#'
			 </cfif>
			 <cfif len(#valid_addr_fg#) gt 0>
			 	,#valid_addr_fg#
			 </cfif>
			  <cfif len(#addr_remarks#) gt 0>
			 	,'#addr_remarks#'
			 </cfif>
		)
	</cfquery>
	
	<cfquery name="addr" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			select * from addr
			,preferred_agent_name where addr.agent_id = preferred_agent_name.agent_id
			and addr.agent_id=#agent_id#
		</cfquery>
		<cfset formAddr = "#addr.agent_name#">
		<cfif len(#addr.job_title#) gt 0>
			<cfset formAddr = "#formAddr#, #addr.job_title#">		
		</cfif>
		<cfif len(#addr.institution#) gt 0>
			<cfset formAddr = "#formAddr#<br>#addr.institution#">		
		</cfif>
		<cfif len(#addr.department#) gt 0>
			<cfset formAddr = "#formAddr#<br>#addr.department#">		
		</cfif>
		<cfif len(#addr.street_addr1#) gt 0>
			<cfset formAddr = "#formAddr#<br>#addr.street_addr1#">		
		</cfif>
		<cfif len(#addr.street_addr2#) gt 0>
			<cfset formAddr = "#formAddr#<br>#addr.street_addr2#">		
		</cfif>
			<cfset formAddr = "#formAddr#<br>#addr.city#, #addr.state# #addr.zip#">		
		<cfif len(#addr.country_cde#) gt 0>
			<cfset formAddr = "#formAddr#<br>#addr.country_cde#">		
		</cfif>
		<cfif len(#addr.mail_stop#) gt 0>
			<cfset formAddr = "#formAddr#<br>#addr.mail_stop#">		
		</cfif>	
			<cfquery name="makeFormat" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				update addr SET formatted_addr=
					'#formAddr#'
				where addr_id = #nextAddr.nextAddrId#
			</cfquery>
	</cftransaction>
	<cf_ActivityLog sql="INSERT INTO addr (
			 ADDR_ID
			 <cfif len(#STREET_ADDR1#) gt 0>
			 	,STREET_ADDR1
			 </cfif>
			 <cfif len(#STREET_ADDR2#) gt 0>
			 	,STREET_ADDR2
			 </cfif>
			 <cfif len(#institution#) gt 0>
			 	,institution
			 </cfif>
			 <cfif len(#department#) gt 0>
			 	,department
			 </cfif>
			 <cfif len(#CITY#) gt 0>
			 	,CITY
			 </cfif>
			 <cfif len(#state#) gt 0>
			 	,state
			 </cfif>
			 <cfif len(#ZIP#) gt 0>
			 	,ZIP
			 </cfif>
			 <cfif len(#COUNTRY_CDE#) gt 0>
			 	,COUNTRY_CDE
			 </cfif>
			 <cfif len(#MAIL_STOP#) gt 0>
			 	,MAIL_STOP
			 </cfif>
			 <cfif len(#agent_id#) gt 0>
			 	,agent_id
			 </cfif>
			 <cfif len(#addr_type#) gt 0>
			 	,addr_type
			 </cfif>
			 <cfif len(#job_title#) gt 0>
			 	,job_title
			 </cfif>
			 <cfif len(#valid_addr_fg#) gt 0>
			 	,valid_addr_fg
			 </cfif>
			  <cfif len(#addr_remarks#) gt 0>
			 	,addr_remarks
			 </cfif>
			  )
			VALUES (
			 #nextAddr.nextAddrId#
			 <cfif len(#STREET_ADDR1#) gt 0>
			 	,'#STREET_ADDR1#'
			 </cfif>
			 <cfif len(#STREET_ADDR2#) gt 0>
			 	,'#STREET_ADDR2#'
			 </cfif>
			 <cfif len(#institution#) gt 0>
			 	,'#institution#'
			 </cfif>
			 <cfif len(#department#) gt 0>
			 	,'#department#'
			 </cfif>
			 <cfif len(#CITY#) gt 0>
			 	,'#CITY#'
			 </cfif>
			  <cfif len(#state#) gt 0>
			 	,'#state#'
			 </cfif>
			 <cfif len(#ZIP#) gt 0>
			 	,'#ZIP#'
			 </cfif>
			 <cfif len(#COUNTRY_CDE#) gt 0>
			 	,'#COUNTRY_CDE#'
			 </cfif>
			 <cfif len(#MAIL_STOP#) gt 0>
			 	,'#MAIL_STOP#'
			 </cfif>
			 <cfif len(#agent_id#) gt 0>
			 	,#agent_id#
			 </cfif>
			 <cfif len(#addr_type#) gt 0>
			 	,'#addr_type#'
			 </cfif>
			 <cfif len(#job_title#) gt 0>
			 	,'#job_title#'
			 </cfif>
			 <cfif len(#valid_addr_fg#) gt 0>
			 	,#valid_addr_fg#
			 </cfif>
			  <cfif len(#addr_remarks#) gt 0>
			 	,'#addr_remarks#'
			 </cfif>
		)">
		<cflocation url="agents.cfm?action=editAgent&agent_id=#agent_id#">
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------>

<!------------------------------------------------------------------------------------------------------------->	
<cfif #Action# is "addRelationship">
 <!--- no security --->
	<cfoutput>
	<cfif len(#newRelatedAgentId#) is 0>
	Pick an agent, then click the button.
	<cfabort>
</cfif>
<cfquery name="newReln" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
	INSERT INTO agent_relations (
		AGENT_ID,
		RELATED_AGENT_ID,
		AGENT_RELATIONSHIP)
	VALUES (
		#agent_id#,
		#newRelatedAgentId#,
		'#relationship#')		  
</cfquery>
<cf_ActivityLog sql="INSERT INTO agent_relations (
		AGENT_ID,
		RELATED_AGENT_ID,
		AGENT_RELATIONSHIP)
	VALUES (
		#agent_id#,
		#newRelatedAgentId#,
		'#relationship#')">
<cflocation url="agents.cfm?action=editAgent&agent_id=#agent_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------>

<!------------------------------------------------------------------------------------------------------------->	
<cfif #Action# is "deleteRelated">
 <!--- no security --->
	<cfoutput>
	<cfquery name="killRel" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		delete from agent_relations where
			agent_id = #agent_id#
			and related_agent_id = #related_agent_id#
			and agent_relationship = '#relationship#'
	</cfquery>
<cf_ActivityLog sql="delete from agent_relations where
			agent_id = #agent_id#
			and related_agent_id = #related_agent_id#
			and agent_relationship = '#relationship#'">
<cflocation url="agents.cfm?action=editAgent&agent_id=#agent_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------>

<!------------------------------------------------------------------------------------------------------------->	
<cfif #Action# is "deleteGroupMember">
	<cfoutput>
	<cfquery name="killGrpMem" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		DELETE FROM group_member WHERE 
		GROUP_AGENT_ID =#agent_id# AND
		MEMBER_AGENT_ID = #MEMBER_AGENT_ID#
	</cfquery>
	<!--- fill any gaps ( fix as needed )--->
	<cflocation url="agents.cfm?action=editAgent&agent_id=#agent_id#">

	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->	
<cfif #Action# is "changeRelated">
 <!--- no security --->
	<cfoutput>
	<!----
	
	---->
	<cfquery name="changeRelated" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
UPDATE agent_relations SET
	related_agent_id = 
		<cfif len(#newRelatedAgentId#) gt 0>
			#newRelatedAgentId#
		  <cfelse>
		  	#related_agent_id#
		</cfif>
		, agent_relationship='#relationship#'
	WHERE agent_id=#agent_id#
	AND related_agent_id=#related_agent_id#
	AND agent_relationship='#oldRelationship#'
	</cfquery>
	<cf_ActivityLog sql="UPDATE agent_relations SET
	related_agent_id = 
		<cfif len(#newRelatedAgentId#) gt 0>
			#newRelatedAgentId#
		  <cfelse>
		  	#related_agent_id#
		</cfif>
		, agent_relationship='#relationship#'
	WHERE agent_id=#agent_id#
	AND related_agent_id=#related_agent_id#
	AND agent_relationship='#oldRelationship#'">
<cflocation url="agents.cfm?action=editAgent&agent_id=#agent_id#">
	<!----

---->
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------>

<!------------------------------------------------------------------------------------------------------------->	
<cfif #Action# is "newName">
 <!--- no security --->
	<cfoutput>
	
	<!--- get next agent_id --->
	<cfquery name="agentNameID" datasource="#Application.web_user#">
		select max(agent_name_id) + 1 as nextAgentNameId from agent_name
	</cfquery>
	<cfquery name="updateName" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		INSERT INTO agent_name (
			agent_name_id, agent_id, agent_name_type, agent_name)
		VALUES (
			#agentNameID.nextAgentNameId#, #agent_id#, '#agent_name_type#','#agent_name#')
		</cfquery>

		<cf_ActivityLog sql="INSERT INTO agent_name (
			agent_name_id, agent_id, agent_name_type, agent_name)
		VALUES (
			#agentNameID.nextAgentNameId#, #agent_id#, '#agent_name_type#','#agent_name#')">
			
		<cflocation url="agents.cfm?action=editAgent&agent_id=#agent_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------>

<!------------------------------------------------------------------------------------------------------------->	
<cfif #Action# is "updateName">
 <!--- no security --->
	<cfoutput>
		<cfquery name="updateName" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			UPDATE agent_name SET agent_name = '#agent_name#', agent_name_type='#agent_name_type#'
			where agent_name_id = #agent_name_id#
		</cfquery>
		<cf_ActivityLog sql="UPDATE agent_name SET agent_name = '#agent_name#', agent_name_type='#agent_name_type#'
			where agent_name_id = #agent_name_id#">
		<cflocation url="agents.cfm?action=editAgent&agent_id=#agent_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->

<!------------------------------------------------------------------------------------------------------------->	
<cfif #Action# is "deleteName">
 <!--- no security --->
	<cfoutput>
	
	<cfquery name="delId" datasource="#Application.web_user#">
SELECT 
	PROJECT_AGENT.AGENT_NAME_ID,
	PUBLICATION_AUTHOR_NAME.AGENT_NAME_ID
FROM
	PROJECT_AGENT,
	PUBLICATION_AUTHOR_NAME,
	agent_name
WHERE
	agent_name.agent_name_id = PROJECT_AGENT.AGENT_NAME_ID (+) and
	agent_name.agent_name_id = PUBLICATION_AUTHOR_NAME.AGENT_NAME_ID  (+) and
	agent_name.agent_name_id = #agent_name_id#
</cfquery>

<cfif #delId.recordcount# gt 1>
	The agent you are trying to delete has active agent names. Delete denied.<cfabort>
</cfif>
	<cfquery name="deleteAgent" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		DELETE FROM agent_name WHERE agent_name_id = #agent_name_id#
	</cfquery>
<cf_ActivityLog
sql="DELETE FROM agent_name WHERE agent_name_id = #agent_name_id#">
		
		
		<cflocation url="agents.cfm?action=editAgent&agent_id=#agent_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->


<!------------------------------------------------------------------------------------------------------------->	
<cfif #Action# is "deletePerson">
 <!--- no security --->

	
	<cfoutput>
		<cftransaction>
			<cfquery name="deleNames" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				DELETE FROM agent_name WHERE agent_id = #agent_id#
			</cfquery>
			<cfquery name="delePerson" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			DELETE FROM person WHERE person_id = #agent_id#
			</cfquery>
			<cfquery name="deleAgent" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			DELETE FROM agent WHERE agent_id = #agent_id#
			</cfquery>
		</cftransaction>
		<cf_ActivityLog sql="DELETE FROM person WHERE person_id = #agent_id#">
		<cf_ActivityLog sql="DELETE FROM agent WHERE agent_id = #agent_id#">
		<cf_ActivityLog sql="DELETE FROM agent_name WHERE agent_id = #agent_id#">
		
			
		<br>Deleted #first_name# #middle_name# #last_name#. 
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->




<!------------------------------------------------------------------------------------------------------------->	
<cfif #Action# is "editPerson">
 <!--- no security --->
	<cfoutput>
		<cftransaction>
		<cfquery name="editPerson" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		UPDATE person SET
			person_id=#agent_id#
			<cfif len(#first_name#) gt 0>
				,first_name='#first_name#'
			<cfelse>
				,first_name=null
			</cfif>
			<cfif len(#prefix#) gt 0>
				,prefix='#prefix#'
			<cfelse>
				,prefix=null
			</cfif>
			<cfif len(#middle_name#) gt 0>
				,middle_name='#middle_name#'
			<cfelse>
				,middle_name=null
			</cfif>
			<cfif len(#last_name#) gt 0>
				,last_name='#last_name#'
			<cfelse>
				,last_name=null
			</cfif>
			<cfif len(#suffix#) gt 0>
				,suffix='#suffix#'
			<cfelse>
				,suffix=null
			</cfif>
			<cfif len(#birth_date#) gt 0>
				,birth_date='#dateformat(birth_date,"dd-mmm-yyyy")#'
			  <cfelse>
			  	,birth_date=null
			</cfif>
			<cfif len(#death_date#) gt 0>
				,death_date='#dateformat(death_date,"dd-mmm-yyyy")#'
			  <cfelse>
			  	,death_date=null
			</cfif>
			WHERE 
				person_id=#agent_id#
			</cfquery>	
			
		<cfquery name="updateAgent" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			UPDATE agent SET 
				<cfif len(#agent_remarks#) gt 0>
					agent_remarks = '#agent_remarks#'
				  <cfelse>
				  	agent_remarks = null
				</cfif>
			WHERE
				agent_id = #agent_id#
		</cfquery>
		
		</cftransaction>
	<cf_ActivityLog sql="UPDATE person SET
			person_id=#agent_id#
			<cfif len(#first_name#) gt 0>
				,first_name='#first_name#'
			</cfif>
			<cfif len(#prefix#) gt 0>
				,prefix='#prefix#'
			</cfif>
			<cfif len(#middle_name#) gt 0>
				,middle_name='#middle_name#'
			</cfif>
			<cfif len(#last_name#) gt 0>
				,last_name='#last_name#'
			</cfif>
			<cfif len(#suffix#) gt 0>
				,suffix='#suffix#'
			</cfif>
			<cfif len(#birth_date#) gt 0>
				,birth_date='#dateformat(birth_date,"dd-mmm-yyyy")#'
			  <cfelse>
			  	,birth_date=null
			</cfif>
			<cfif len(#death_date#) gt 0>
				,death_date='#dateformat(death_date,"dd-mmm-yyyy")#'
			  <cfelse>
			  	,death_date=null
			</cfif>
			WHERE 
				person_id=#agent_id#">
		<cf_ActivityLog sql="UPDATE agent SET 
				<cfif len(#agent_remarks#) gt 0>
					agent_remarks = '#agent_remarks#'
				  <cfelse>
				  	agent_remarks = null
				</cfif>
			WHERE
				agent_id = #agent_id#">
		
		<cflocation url="agents.cfm?action=editAgent&agent_id=#agent_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->

<!------------------------------------------------------------------------------------------------------------->
<cfif #action# is "makeNewGroupMemeber">
	<cfquery name="newGroupMember" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		INSERT INTO group_member (GROUP_AGENT_ID, MEMBER_AGENT_ID, MEMBER_ORDER)
		values (#agent_id#,#member_id#,#MEMBER_ORDER#)
	</cfquery>
	<cflocation url="agents.cfm?action=editAgent&agent_id=#agent_id#">
</cfif>

<!------------------------------------------------------------------------------------------------------------->

<cfif #action# is "insertPerson">

 <!--- no security --->
	<cfoutput>
		<!--- we need at least a first or last name to proceed --->
		<cfif len(#first_name#) is 0 AND len(#last_name#) is 0>
			You must provide at least a first or last name to create a new person.
			<br>Use your browser's back button to try again.
			<cfabort>
		</cfif>
		<!--- get the next agent_id --->
		<cfquery name="agentID" datasource="#Application.web_user#">
			select max(agent_id) + 1 as nextAgentId from agent
		</cfquery>
		<!--- get the next agent_name_id --->
		<cfquery name="agentNameID" datasource="#Application.web_user#">
			select max(agent_name_id) + 1 as nextAgentNameId from agent_name
		</cfquery>
		
		
		<cfquery name="insPerson" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
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
			
		<cfquery name="insPerson" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
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
					<cfset name = #trim(name)#>
				
			
			<cfquery name="insName" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
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
				'#name#',
				0
				)
			</cfquery>
			
				<cf_ActivityLog sql="INSERT INTO agent_name (
				agent_name_id,
				agent_id,
				agent_name_type,
				agent_name,
				donor_card_present_fg)
			VALUES (
				#agentNameID.nextAgentNameId#,
				#agentID.nextAgentId#,
				'preferred',
				'#name#',
				0
				)">
				<cf_ActivityLog sql="INSERT INTO person ( 
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
			)">
			<cf_ActivityLog sql="INSERT INTO agent (
				agent_id,
				agent_type,
				preferred_agent_name_id)
			VALUES (
				#agentID.nextAgentId#,
				'person',
				#agentNameID.nextAgentNameId#
				)">
		
		
		<cflocation url="agents.cfm?action=editAgent&agent_id=#agentID.nextAgentId#">
		
	</cfoutput>
	
</cfif>
<!------------------------------------------------------------------------------------------------------------->
<cfif #Action# is "makeNewAgent">
 <!--- no security --->


	<cfoutput>
		<!--- we need at least a first or last name to proceed --->
		
		<!--- get the next agent_id --->
		<cfquery name="agentID" datasource="#Application.web_user#">
			select max(agent_id) + 1 as nextAgentId from agent
		</cfquery>
		<!--- get the next agent_name_id --->
		<cfquery name="agentNameID" datasource="#Application.web_user#">
			select max(agent_name_id) + 1 as nextAgentNameId from agent_name
		</cfquery>
		
	
			<cfquery name="insAgent" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			
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
			<cfquery name="insName" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
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
					
				<cflocation url="agents.cfm?action=editAgent&agent_id=#agentID.nextAgentId#">
		
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->
<cfinclude template="/includes/_footer.cfm">