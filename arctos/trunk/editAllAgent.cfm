<cfinclude template="/includes/_frameHeader.cfm">
<script type='text/javascript' src='/includes/internalAjax.js'></script>
<cfquery name="ctNameType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select agent_name_type as agent_name_type from ctagent_name_type
</cfquery>
<cfquery name="ctAgentType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select agent_type from ctagent_type
</cfquery>
<cfquery name="ctAddrType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select addr_type from ctaddr_type
</cfquery>
<cfquery name="ctElecAddrType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select address_type from ctelectronic_addr_type
</cfquery>
<cfquery name="ctprefix" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select prefix from ctprefix order by prefix
</cfquery>
<cfquery name="ctsuffix" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select suffix from ctsuffix order by suffix
</cfquery>
<cfif not isdefined("agent_id")>
	<cfset agent_id = -1>
</cfif>
<script language="javascript" type="text/javascript">
	function suggestName(ntype){
		try {
			var fName=document.getElementById('first_name').value;
			var mName=document.getElementById('middle_name').value;
			var lName=document.getElementById('last_name').value;
			var name='';
			if (ntype=='initials plus last'){
				if (fName.length>0){
					name=fName.substring(0,1) + '. ';
				}
				if (mName.length>0){
					name+=mName.substring(0,1) + '. ';
				}
				if (lName.length>0){
					name+=lName;
				} else {
					name='';
				}
			}
			if (ntype=='last plus initials'){
				if (lName.length>0){
					name=lName + ', ';
					if (fName.length>0){
						name+=fName.substring(0,1) + '. ';
					}
					if (mName.length>0){
						name+=mName.substring(0,1) + '. ';
					}
				} else {
					name='';
				}				
			}
			if (name.length>0){
				var rf=document.getElementById('agent_name');
				var tName=name.replace(/^\s+|\s+$/g,""); // trim spaces
				if (rf.value.length==0){
					rf.value=tName;
				}
			}
		}
		catch(e){
			//console.log('Error with suggestName: ' + e);
		}
	}
</script>
<!------------------------------------------------------------------------------------------------------------->
<cfif action is "newOtherAgent">
	<cfoutput>
		<form name="prefdName" action="editAllAgent.cfm" method="post" target="_person">
			<input type="hidden" name="action" value="makeNewAgent">
			<input type="hidden" name="agent_name_type" value="preferred">
			<label for="agent_name">Name</label>
			<input type="text" name="agent_name" id="agent_name" size="50">
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
<cfif #Action# is "newPerson">
	<form name="newPerson" action="editAllAgent.cfm" method="post" target="_person">
		<input type="hidden" name="Action" value="insertPerson">
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
<!------------------------------------------------------------------------------------------------------------->
<cfif action is "nothing">
	<cfif not isdefined("agent_id") OR agent_id lt 0 >
		<cfabort>
	</cfif>
	<cfquery name="person" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
			<cfset nameStr= listappend(nameStr,prefix,' ')>
			
			<cfset nameStr= listappend(nameStr,first_name,' ')>
			<cfset nameStr= listappend(nameStr,middle_name,' ')>
			<cfset nameStr= listappend(nameStr,last_name,' ')>
			<cfset nameStr= listappend(nameStr,suffix,' ')>
			<!---
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
					--->
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
						<cfquery name="getName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
			<cfif listcontainsnocase(session.roles,"manage_transactions")>
				<cfquery name="rank" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select count(*) || ' ' || agent_rank agent_rank from agent_rank where agent_id=#agent_id# group by agent_rank
				</cfquery>
				<br><a href="/info/agentActivity.cfm?agent_id=#agent_id#" target="_self">Agent Activity</a>
				<cfif rank.recordcount is 0>
					~ <span class="likeLink" onclick="rankAgent('#agent_id#');">Rank</span>
				<cfelse>
					<br>Rank:
					#valuelist(rank.agent_rank,"; ")#
					<span class="likeLink" onclick="rankAgent('#agent_id#');">Details</span>
				</cfif>
				<br>
			</cfif>
		</td>
	</tr>
</cfoutput>
<cfquery name="agentAddrs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from addr
			where 
			agent_id = #person.agent_id#
			order by valid_addr_fg DESC
</cfquery>
<cfquery name="elecagentAddrs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from electronic_address
			where 
			agent_id = #person.agent_id#
</cfquery>
	<tr>
		<td>
			<strong>Addresses:</strong>
			<cfoutput>
				<cfset i=1>
				<cfloop query="agentAddrs">
					<cfif valid_addr_fg is 1>
						<div style="border:2px solid green;margin:1px;padding:1px;">
					<cfelse>
						<div style="border:2px solid red;margin:1px;padding:1px;">
					</cfif>
						<form name="addr#i#" method="post" action="editAllAgent.cfm">
							<input type="hidden" name="agent_id" value="#person.agent_id#">
							<input type="hidden" name="addr_id" value="#agentAddrs.addr_id#">
							<input type="hidden" name="action" value="editAddr">
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
						</form>
						#addr_type# Address (<cfif #valid_addr_fg# is 1>valid<cfelse>invalid</cfif>)
						&nbsp;&nbsp;<span class="likeLink" onclick="addr#i#.action.value='editAddr';addr#i#.submit();">Edit</span>
						&nbsp;&nbsp;~&nbsp;&nbsp;<span class="likeLink" onclick="addr#i#.action.value='deleteAddr';confirmDelete('addr#i#');">Delete</span>
						<div style="margin-left:1em;">
							#replace(formatted_addr,chr(10),"<br>","all")#
						</div>
						<cfset i=#i#+1>
					</div>
				</cfloop>
			</cfoutput>
		</td>
	</tr>
	<tr>
		<td>
			<strong>Electronic Addresses:</strong>
			<cfset i=1>
			<cfoutput>
				<cfloop query="elecagentAddrs">
					<form name="elad#i#" method="post" action="editAllAgent.cfm">
						<input type="hidden" name="action" >
						<input type="hidden" name="agent_id" value="#person.agent_id#">
						<input type="hidden" name="address_type" value="#address_type#">
						<input type="hidden" name="address" value="#address#">
					</form>
					<div>
						#address_type#: #address#
						<span class="likeLink" onclick="elad#i#.action.value='editElecAddr';elad#i#.submit();">Edit</span>
						&nbsp;&nbsp;~&nbsp;&nbsp;
						<span class="likeLink" onclick="elad#i#.action.value='deleElecAddr';confirmDelete('elad#i#');">Delete</span>
					</div>
					<cfset i=#i#+1>
				</cfloop>
			</cfoutput>
		</td>
	</tr>
<cfif #person.agent_type# is "person">
<cfoutput query="person">
<form name="editPerson" action="editAllAgent.cfm" method="post" target="_person">
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
				<td><input type="text" name="first_name" id="first_name" value="#first_name#"></td>
				<td><input type="text" name="middle_name" id="middle_name" value="#middle_name#"></td>
				<td><input type="text" name="last_name" id="last_name" value="#last_name#"></td>
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
			<cfquery name="grpMem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
					<form name="groupMember#i#" method="post" action="editAllAgent.cfm">
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
			<form name="newGroupMember" method="post" action="editAllAgent.cfm">
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
	

		<cfquery name="names" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
			<form name="a#name#" action="editAllAgent.cfm" method="post" target="_person">
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
			 <form name="newName" action="editAllAgent.cfm" method="post" target="_person">
			 <input type="hidden" name="Action" value="newName">
			 <input type="hidden" name="agent_id" value="#person.agent_id#">
			<tr>
				<td>
					<input type="text" name="agent_name" id="agent_name">
				</td>
				<td>
					 <select name="agent_name_type" onchange="suggestName(this.value);">
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
<cfquery name="relns" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select agent_relationship, agent_name, related_agent_id
		 from agent_relations, agent_name
		  where 
		  agent_relations.related_agent_id = agent_name.agent_id 
		  and agent_name_type = 'preferred' and
		  agent_relations.agent_id=#person.agent_id#
	</cfquery>
		<cfquery name="ctRelns" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
			<form name="agentRelations#i#" method="post" action="editAllAgent.cfm">
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
			<form name="newRelationship" method="post" action="editAllAgent.cfm">
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
			<cfform name="newAddress" method="post" action="editAllAgent.cfm">
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

					<cfform name="newElecAddr" method="post" action="editAllAgent.cfm">
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
</cfif>
<!------------------------------------------------------------------------------------------------------------->
<cfif #Action# is "editElecAddr">
<cfoutput>
<cfform name="edElecAddr" method="post" action="editAllAgent.cfm">
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
<cfif #Action# is "saveEditElecAddr">
	<cfoutput>
		<cfquery name="upElecAddr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			UPDATE electronic_address SET
				address_type = '#address_type#',
				address = '#address#'
			where
				agent_id = #agent_id#
				and address_type = '#origAddressType#'
				and address = '#origAddress#'
		</cfquery>
		<cflocation url="editAllAgent.cfm?agent_id=#agent_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->
<cfif #Action# is "deleElecAddr">
	<cfoutput>
		<cfquery name="deleElecAddr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			delete from electronic_address where
				agent_id=#agent_id#
				and address_type='#address_type#'
				and address='#address#'
		</cfquery>
		<cflocation url="editAllAgent.cfm?agent_id=#agent_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->
<cfif #Action# is "editAddr">
<cfset title = "Edit Address">
Edit This Address:
<cfoutput>
<form name="editAddr" method="post" action="editAllAgent.cfm">
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
<cfif #Action# is "saveEditsAddr">
	<cfoutput>
		<cfquery name="editAddr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			UPDATE addr SET 
				STREET_ADDR1 = '#STREET_ADDR1#'
				,STREET_ADDR2 = '#STREET_ADDR2#'
				,department = '#department#'
				,institution = '#institution#'
				,CITY = '#CITY#'
				,STATE = '#STATE#'
				,ZIP = '#ZIP#'
				,COUNTRY_CDE = '#COUNTRY_CDE#'
				,MAIL_STOP = '#MAIL_STOP#'
				 ,AGENT_ID = #AGENT_ID#
				,ADDR_TYPE = '#ADDR_TYPE#'
				,JOB_TITLE = '#JOB_TITLE#'
				,VALID_ADDR_FG = '#VALID_ADDR_FG#'
				,ADDR_REMARKS = '#ADDR_REMARKS#'
			where addr_id=#addr_id#
		</cfquery>
		<cflocation url="editAllAgent.cfm?agent_id=#agent_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->
<cfif #Action# is "deleteAddr">
	<cfoutput>
		<cfquery name="killAddr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			delete from addr where addr_id=#addr_id#
		</cfquery>
		<cflocation url="editAllAgent.cfm?agent_id=#agent_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->	
<cfif #Action# is "saveCurrentAddress">
	<cfoutput>
		<cftransaction>
			<cfquery name="addr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				UPDATE addr SET 
					addr_id = #addr_id#
				 	,STREET_ADDR1 = '#STREET_ADDR1#'
				 	,institution = '#institution#'
					,department = '#department#'
				 	,STREET_ADDR2 = '#STREET_ADDR2#'
				 	,CITY = '#CITY#'
				 	,state = '#state#'
					,ZIP = '#ZIP#'
				 	,COUNTRY_CDE = '#COUNTRY_CDE#'
				 	,MAIL_STOP = '#MAIL_STOP#'
				 where addr_id = #addr_id#
			</cfquery>	
			<cfquery name="elecaddr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				UPDATE electronic_address 
				SET 
					AGENT_ID = #agent_id#
					,ELECTRONIC_ADDR = '#ELECTRONIC_ADDR#'	
					,address_type='#address_type#'	
				where
					AGENT_ID = #agent_id#
			</cfquery>
		</cftransaction>
		<cflocation url="editAllAgent.cfm?agent_id=#agent_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------>
<cfif #Action# is "newElecAddr">
	<cfoutput>
	<cfquery name="elecaddr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		INSERT INTO electronic_address (
			AGENT_ID
			,address_type
		 	,address	
		 ) VALUES (
			#agent_id#
			,'#address_type#'
		 	,'#address#'
		)
	</cfquery>
	<cflocation url="editAllAgent.cfm?agent_id=#agent_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------>
<cfif #Action# is "newAddress">
	<cfoutput>
		<cfquery name="prefName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select agent_name from preferred_agent_name where agent_id=#agent_id#
		</cfquery>
		<cfquery name="addr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			INSERT INTO addr (
				ADDR_ID
				,STREET_ADDR1
				,STREET_ADDR2
				,institution
				,department
				,CITY
				,state
				,ZIP
			 	,COUNTRY_CDE
			 	,MAIL_STOP
			 	,agent_id
			 	,addr_type
			 	,job_title
				,valid_addr_fg
				,addr_remarks
			) VALUES (
				 sq_addr_id.nextval
			 	,'#STREET_ADDR1#'
			 	,'#STREET_ADDR2#'
			 	,'#institution#'
			 	,'#department#'
			 	,'#CITY#'
			 	,'#state#'
			 	,'#ZIP#'
			 	,'#COUNTRY_CDE#'
			 	,'#MAIL_STOP#'
			 	,#agent_id#
			 	,'#addr_type#'
			 	,'#job_title#'
			 	,#valid_addr_fg#
			 	,'#addr_remarks#'
			)
		</cfquery>
		<cflocation url="editAllAgent.cfm?agent_id=#agent_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->	
<cfif #Action# is "addRelationship">
	<cfoutput>
		<cfif len(#newRelatedAgentId#) is 0>
			Pick an agent, then click the button.
			<cfabort>
		</cfif>
		<cfquery name="newReln" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			INSERT INTO agent_relations (
				AGENT_ID,
				RELATED_AGENT_ID,
				AGENT_RELATIONSHIP)
			VALUES (
				#agent_id#,
				#newRelatedAgentId#,
				'#relationship#')		  
		</cfquery>
		<cflocation url="editAllAgent.cfm?agent_id=#agent_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->	
<cfif #Action# is "deleteRelated">
	<cfoutput>
	<cfquery name="killRel" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		delete from agent_relations where
			agent_id = #agent_id#
			and related_agent_id = #related_agent_id#
			and agent_relationship = '#relationship#'
	</cfquery>
<cflocation url="editAllAgent.cfm?agent_id=#agent_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->	
<cfif #Action# is "deleteGroupMember">
	<cfoutput>
	<cfquery name="killGrpMem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		DELETE FROM group_member WHERE 
		GROUP_AGENT_ID =#agent_id# AND
		MEMBER_AGENT_ID = #MEMBER_AGENT_ID#
	</cfquery>
	<cflocation url="editAllAgent.cfm?agent_id=#agent_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->	
<cfif #Action# is "changeRelated">
	<cfoutput>
		<cfquery name="changeRelated" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
		<cflocation url="editAllAgent.cfm?agent_id=#agent_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->	
<cfif #Action# is "newName">
	<cfoutput>
		<cfquery name="updateName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			INSERT INTO agent_name (
				agent_name_id, agent_id, agent_name_type, agent_name)
			VALUES (
				sq_agent_name_id.nextval, #agent_id#, '#agent_name_type#','#agent_name#')
		</cfquery>			
		<cflocation url="editAllAgent.cfm?agent_id=#agent_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->	
<cfif #Action# is "updateName">
	<cfoutput>
		<cfquery name="updateName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			UPDATE agent_name SET agent_name = '#agent_name#', agent_name_type='#agent_name_type#'
			where agent_name_id = #agent_name_id#
		</cfquery>
		<cflocation url="editAllAgent.cfm?agent_id=#agent_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->	
<cfif #Action# is "deleteName">
	<cfoutput>
		<cfquery name="delId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT 
				PROJECT_AGENT.AGENT_NAME_ID,
				PUBLICATION_AUTHOR_NAME.AGENT_NAME_ID,
				project_sponsor.AGENT_NAME_ID
			FROM
				PROJECT_AGENT,
				PUBLICATION_AUTHOR_NAME,
				project_sponsor,
				agent_name
			WHERE
				agent_name.agent_name_id = PROJECT_AGENT.AGENT_NAME_ID (+) and
				agent_name.agent_name_id = PUBLICATION_AUTHOR_NAME.AGENT_NAME_ID  (+) and
				agent_name.agent_name_id = project_sponsor.AGENT_NAME_ID  (+) and
				agent_name.agent_name_id = #agent_name_id#
		</cfquery>
		<cfif #delId.recordcount# gt 1>
			The agent name you are trying to delete is active.<cfabort>
		</cfif>
		<cfquery name="deleteAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			DELETE FROM agent_name WHERE agent_name_id = #agent_name_id#
		</cfquery>
		<cflocation url="editAllAgent.cfm?agent_id=#agent_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->	
<cfif #Action# is "editPerson">
	<cfoutput>
		<cftransaction>
			<cfquery name="editPerson" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
			<cfquery name="updateAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
	<cflocation url="editAllAgent.cfm?agent_id=#agent_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->
<cfif #action# is "makeNewGroupMemeber">
	<cfquery name="newGroupMember" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		INSERT INTO group_member (GROUP_AGENT_ID, MEMBER_AGENT_ID, MEMBER_ORDER)
		values (#agent_id#,#member_id#,#MEMBER_ORDER#)
	</cfquery>
	<cflocation url="editAllAgent.cfm?agent_id=#agent_id#">
</cfif>
<!------------------------------------------------------------------------------------------------------------->
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
					<form name="ac" method="post" action="editAllAgent.cfm">
						<input type="hidden" name="action" value="insertPerson">
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
		<cflocation url="editAllAgent.cfm?agent_id=#agentID.nextAgentId#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->
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
		<cflocation url="editAllAgent.cfm?agent_id=#agentID.nextAgentId#">
	</cfoutput>
</cfif>
<script>
	parent.resizeCaller();
</script>
<cfoutput>
<script type="text/javascript" language="javascript">
	console.log(top.location);
	console.log(document.location);
	if (top.location==document.location) {
    	top.location='/agents.cfm?agent_id=#agent_id#';
	}
</script>
</cfoutput>
<!------------------------------------------------------------------------------------------------------------->
<cfinclude template="includes/_pickFooter.cfm">