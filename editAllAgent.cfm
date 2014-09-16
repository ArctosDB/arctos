<cfif not isdefined("action")><cfset action="nothing"></cfif>
<cfinclude template="/includes/functionLib.cfm">
<cfquery name="ctNameType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select agent_name_type as agent_name_type from ctagent_name_type where agent_name_type != 'preferred' order by agent_name_type
</cfquery>
<cfquery name="CTELECTRONIC_ADDR_TYPE" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select ADDRESS_TYPE from CTELECTRONIC_ADDR_TYPE order by ADDRESS_TYPE
</cfquery>
<cfquery name="ctAgent_Type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select agent_type from ctagent_type order by agent_type
</cfquery>
<cfquery name="ctElecAddrType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select address_type from ctelectronic_addr_type order by address_type
</cfquery>
<cfquery name="ctRelns" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select AGENT_RELATIONSHIP from CTAGENT_RELATIONSHIP order by AGENT_RELATIONSHIP
</cfquery>
<cfquery name="ctagent_status" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select agent_status from ctagent_status order by agent_status
</cfquery>
<style>
	.validAddress{border:2px solid green;margin:1px;padding:1px;}
	.invalidAddress{border:2px solid red;margin:1px;padding:1px;}
	
	fieldset {
	    border:0;
	    outline: 1px solid gray;
		margin:1em;
		padding:1em;
	}
	legend {
	    font-size:85%;
	}
</style>
<script>
	$(document).ready(function() {
		$(".reqdClr:visible").each(function(e){
		    $(this).prop('required',true);
		});
		// have to keep this here - it's not called from ajax.js on injected forms
		$("input[type='date'], input[type='datetime']" ).datepicker();
		$("#fEditAgent").submit(function(event){
			event.preventDefault();
			$.ajax({
				url: "/component/agent.cfc?queryformat=column&method=saveAgent&returnformat=json",
				type: "GET",
				dataType: "json",
				data:  $("#fEditAgent").serialize(),
				success: function(r) {
					if (r=='success'){

						//console.log('success: reload ' + $("#agent_id").val() );
						loadEditAgent( $("#agent_id").val() );
						//$("#fs_fEditAgent legend").removeClass().addClass('goodsave').text('Save Successful');
					} else {
						//$("#fs_fEditAgent legend").removeClass().addClass('badsave').text('ERROR!');
						var m='An error occurred and your changes were not saved.\nIn the event of multiple error messages, ';
						m+='you may need to reload this page to continue. Save incrementally if necessary. \n';
						alert (m + r);
					}
				},
				error: function (xhr, textStatus, errorThrown){
				    alert(errorThrown + ': ' + textStatus + ': ' + xhr);
				}
			});
		});
		
		$(document).on("change", '[id^="agent_name_type_new"], [id^="agent_name_new"]', function(){
			var i =  this.id;
			i=i.replace("agent_name_type_new", ""); 
			i=i.replace("agent_name_new", ""); 
			if ( $("#agent_name_type_new" + i).val().length > 0 ||  $("#agent_name_new" + i).val().length > 0 ) {
				$("#agent_name_type_new" + i).addClass('reqdClr').prop('required',true);
				$("#agent_name_new" + i).addClass('reqdClr').prop('required',true);
			} else {
				$("#agent_name_type_new" + i).removeClass().prop('required',false);
				$("#agent_name_new" + i).removeClass().prop('required',false);
			}
		});

		$(document).on("change", '[id^="agent_status_new"], [id^="status_date_new"]', function(){
			var i =  this.id;
			i=i.replace("status_date_new", ""); 
			i=i.replace("agent_status_new", ""); 
			if ( $("#agent_status_new" + i).val().length > 0 ||  $("#status_date_new" + i).val().length > 0 ) {
				$("#agent_status_new" + i).addClass('reqdClr').prop('required',true);
				$("#status_date_new" + i).addClass('reqdClr').prop('required',true);
			} else {
				$("#agent_status_new" + i).removeClass().prop('required',false);
				$("#status_date_new" + i).removeClass().prop('required',false);
			}
		});
		$(document).on("change", '[id^="agent_relationship_new"], [id^="related_agent_new"]', function(){
			var i =  this.id;
			i=i.replace("related_agent_new", ""); 
			i=i.replace("agent_relationship_new", ""); 
			if ( $("#agent_relationship_new" + i).val().length > 0 ||  $("#related_agent_new" + i).val().length > 0 ) {
				$("#agent_relationship_new" + i).addClass('reqdClr').prop('required',true);
				$("#related_agent_new" + i).addClass('reqdClr').prop('required',true);
			} else {
				$("#agent_relationship_new" + i).removeClass().prop('required',false);
				$("#related_agent_new" + i).removeClass().prop('required',false);
			}
		});

		$(document).on("change", '[id^="electronic_address_type_"]', function(){
			// change input type
			var ntype,dfld;
			if ( $(this).val()=='url' ){
				ntype='url';
			} else if ( $(this).val()=='e-mail' ){
				ntype='email';
			} else if ( $(this).val().indexOf('phone')>-1 ||  $(this).val()=='fax'){
				ntype='tel';
			} else {
				ntype='text';
			}
			dfld=this.id.replace('electronic_address_type_','electronic_address_');
			$("#" + dfld).clone().attr('type',ntype).insertAfter("#" + dfld).prev().remove();
		});

		$(document).on("change", '[id^="electronic_address_type_new"], [id^="electronic_address_new"]', function(){
			// require paired values
			var i = this.id;
			var ntype = 'text';
			i=i.replace("electronic_address_type_new", ""); 
			i=i.replace("electronic_address_new", ""); 
			if ( $("#electronic_address_type_new" + i).val().length > 0 ||  $("#electronic_address_new" + i).val().length > 0 ) {
				$("#electronic_address_type_new" + i).addClass('reqdClr').prop('required',true);
				$("#electronic_address_new" + i).addClass('reqdClr').prop('required',true);
			} else {
				$("#electronic_address_type_new" + i).removeClass().prop('required',false);
				$("#electronic_address_new" + i).removeClass().prop('required',false);
			}
		});
	});
</script>
<!------------------------------------------------------------------------------------------------------------->
<cfif not isdefined("agent_id") OR agent_id lt 0 >
	<cfabort>
</cfif>
<cfoutput>	
	<cfquery name="agent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select 
			agent_id,
			preferred_agent_name,
			agent_remarks,
			agent_type,
			getPreferredAgentName(CREATED_BY_AGENT_ID) created_by_agent,
			CREATED_DATE
		from 
			agent
		where 
			agent_id=#agent_id#
	</cfquery>

	<cfquery name="activitySummary" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
	        collection,
	        min(began_date) earliest,
	        max(ended_date) latest,
	        count(*) numSpecs
	      from
	        collector,
	        cataloged_item,
	        specimen_event,
	        collecting_event,
	        collection
	      where
	        collector.collection_object_id=cataloged_item.collection_object_id and
	        cataloged_item.collection_object_id=specimen_event.collection_object_id and
	        specimen_event.collecting_event_id=collecting_event.collecting_event_id and
	        cataloged_item.collection_id=collection.collection_id and
	        collector.agent_id=#agent_id#
	      group by
	        collection
	       order by
	       	numSpecs desc,
	       	collection
	</cfquery>
	<cfquery name="agentAddrs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from addr
		where 
		agent_id = #agent.agent_id#
		order by valid_addr_fg DESC
	</cfquery>
	<cfquery name="elecagentAddrs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from electronic_address
		where 
		agent_id = #agent.agent_id#
	</cfquery>
	<cfquery name="status" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			agent_status_id,
			agent_status,
			status_date,
			STATUS_REMARK,
			getPreferredAgentName(STATUS_REPORTED_BY) reported_by,
			STATUS_REPORTED_DATE
		from agent_status
		where 
		agent_id = #agent.agent_id#
	</cfquery>	
		
	<cfquery name="agent_names" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from agent_name where agent_id=#agent_id# and agent_name_type!='preferred' order by agent_name_type,agent_name
	</cfquery>
	<cfquery name="relns" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select 
			agent_relations_id,
			agent_relationship, 
			agent.preferred_agent_name agent_name, 
			related_agent_id
		from 
			agent_relations, 
			agent
		where 
		  agent_relations.related_agent_id = agent.agent_id and
		  agent_relations.agent_id=#agent_id#
	</cfquery>
	
	<cfquery name="reciprelns" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select 
			agent_relations.agent_relationship, 
			agent.preferred_agent_name,
			agent_relations.agent_id
		from 
			agent_relations, 
			agent
		where 
		  agent_relations.agent_id = agent.agent_id and
		  agent_relations.related_agent_id=#agent_id#
	</cfquery>
	
	<div>
		AgentID #agent.agent_id# created by #agent.created_by_agent# on #agent.CREATED_DATE#
		<span class="likeLink" onClick="getDocs('agent')">Help</span>
	</div> 
	<div>
		Collecting Summary - <a href="/info/agentActivity.cfm?agent_id=#agent.agent_id#" target="_blank">click for full Agent Activity report</a>
	</div>
	<table border>
		<tr>
			<th>Collection</th>
			<th>Earliest Date</th>
			<th>Latest Date</th>
			<th>NumberSpecimens</th>
		</tr>
		<cfloop query="activitySummary">
			<tr>
				<td>#collection#</td>
				<td>#earliest#</td>
				<td>#latest#</td>
				<td>#numSpecs#</td>
			</tr>
		</cfloop>
	</table>
	<cfif listcontainsnocase(session.roles,"manage_transactions")>
		<cfquery name="rank" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select count(*) || ' ' || agent_rank agent_rank from agent_rank where agent_id=#agent_id# group by agent_rank
		</cfquery>
		<br>
		<cfif rank.recordcount gt 0>
			Previous Ranking: #valuelist(rank.agent_rank,"; ")#
		</cfif>
		<input type="button" class="lnkBtn" onclick="rankAgent('#agent.agent_id#');" value="Rank">
	</cfif>
	<form name="fEditAgent" id="fEditAgent">
		<input type="submit" value="save all changes" class="savBtn">
		<fieldset id="fs_fEditAgent">
			<legend>Edit Agent</legend>
			<input type="hidden" name="agent_id" id="agent_id" value="#agent_id#">
			<label for="preferred_agent_name">Preferred Name</label>
			<input type="text" value="#stripQuotes(agent.preferred_agent_name)#" name="preferred_agent_name" id="preferred_agent_name" class="reqdClr minput">
			 
			<label for="agent_type">Agent Type</label>
			<select name="agent_type" id="agent_type" class="reqdClr">
				<cfloop query="ctAgent_Type">
					<option  <cfif ctAgent_Type.agent_type is agent.agent_type> selected="selected" </cfif>
						value="#ctAgent_Type.agent_type#">#ctAgent_Type.agent_type#</option>
				</cfloop>
			</select>
			<span class="infoLink" onclick="getCtDoc('ctagent_type');">Define</span>
			<label for="agent_remarks">Agent Remark</label>
			<textarea class="largetextarea" name="agent_remarks" id="agent_remarks">#stripQuotes(agent.agent_remarks)#</textarea>
			<!----
			<input type="text" value="#stripQuotes(agent.agent_remarks)#" name="agent_remarks" id="agent_remarks" size="100">
			---->
		</fieldset>
		<cfif agent.agent_type is "group">
			<cfquery name="grpMem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select 
					group_member_id,
					MEMBER_AGENT_ID,
					preferred_agent_name					
				from 
					group_member,
					agent
				where 
					group_member.MEMBER_AGENT_ID = agent.agent_id AND
					GROUP_AGENT_ID = #agent_id#
				order by 
					preferred_agent_name					
			</cfquery>
			<fieldset>
				<legend>Group Members</legend>
				<cfloop query="grpMem">
					<div>
						<input type="hidden" name="member_agent_id_#group_member_id#" id="member_agent_id_#group_member_id#" value="#member_agent_id#">
						<input type="text" name="group_member_#group_member_id#" id="group_member_#group_member_id#" value="#preferred_agent_name#"
							onchange="pickAgentTest('member_agent_id_#group_member_id#',this.id,this.value); return false;"
							onKeyPress="return noenter(event);" placeholder="pick an agent" class="reqdClr minput">
						<input type="button" class="delBtn" onclick="$('##group_member_#group_member_id#').val('DELETE');" value="delete">
						<a href="/agents.cfm?agent_id=#member_agent_id#">[ agent]</a>
					</div>
				</cfloop>
				<input type="hidden" id="nnga" value="1">
				<input type="button" onclick="addGroupMember()" value="add a row">
				<label for="newGroupMembers">Add Group Members</label>
				<div class="newRec" id="newGroupMembers">
					<input type="hidden" name="member_agent_id_new1" id="member_agent_id_new1">
					<input type="text" name="group_member_new1" id="group_member_new1" class="minput"
						onchange="pickAgentTest('member_agent_id_new1',this.id,this.value); return false;"
						onKeyPress="return noenter(event);" placeholder="new group member">
				</div>
			</fieldset>
		</cfif>
		<fieldset>
			<legend>Group Membership</legend>
			<cfquery name="ingroup" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				  select 
			          GROUP_AGENT_ID,
			          preferred_agent_name          
			        from 
			          group_member,
			          agent
			        where 
			          group_member.GROUP_AGENT_ID = agent.agent_id AND
			          MEMBER_AGENT_ID = #agent_id#
			        order by 
			          preferred_agent_name
			</cfquery>
			<cfif ingroup.recordcount is 0>
				This agent is not a member of any groups
			<cfelse>
				<div style="max-height:6em;overflow:scroll;">
					<cfloop query="ingroup">
						<br><a href="/agents.cfm?agent_id=#GROUP_AGENT_ID#">#preferred_agent_name#</a>
					</cfloop>
				</div>
			</cfif>
		</fieldset>
		<fieldset id="fs_fAgentName">			
			<legend>Agent Names</legend>
			<cfloop query="agent_names">
				<div>
					<select name="agent_name_type_#agent_name_id#" id="agent_name_type_#agent_name_id#">
						<option value="DELETE">DELETE</option>
						<cfloop query="ctNameType">
							<option  <cfif ctNameType.agent_name_type is agent_names.agent_name_type> selected="selected" </cfif>
								value="#ctNameType.agent_name_type#">#ctNameType.agent_name_type#</option>
						</cfloop>
					</select>
					<span class="infoLink" onclick="getCtDoc('ctagent_name_type');">Define</span>
					<input type="text" value="#agent_names.agent_name#" name="agent_name_#agent_name_id#" id="agent_name_#agent_name_id#" size="40" class="reqdClr minput">
					<cfif agent_name_type is "login">
						<a href="/AdminUsers.cfm?action=edit&username=#agent_names.agent_name#" class="infoLink">[ Arctos user ]</a>
					</cfif>
				</div>
			</cfloop>
			<div class="newRec">
				<input type="hidden" id="nnan" value="1">
				<input type="button" onclick="addAgentName()" value="add a row">
				<label for="agentnamedv1">Add Name</label>
				<div id="agentnamedv1">
					<select name="agent_name_type_new1" id="agent_name_type_new1">
						<option value="">pick name type</option>
						<cfloop query="ctNameType">
							<option value="#ctNameType.agent_name_type#">#ctNameType.agent_name_type#</option>
						</cfloop>
					</select>
					<input type="text" name="agent_name_new1" id="agent_name_new1" placeholder="new agent name" class="minput">
				</div>
			</div>
		</fieldset>
		<fieldset>
			<legend>Agent Status <span class="likeLink" onclick="getCtDoc('ctAgent_Status');">codetable</span></legend>
			
			<!----
			<table border>
				<tr>
					<th>
						<span class="likeLink" onclick="getCtDoc('ctAgent_Status');">Agent Status</span>
					</th>
					<th>Status Date</th>
					<th>Remark</th>
					<th>Whodunit</th>
			</tr>
			<cfloop query="status">
				<tr>
					<td>
						<select name="agent_status_#agent_status_id#" id="agent_status_#agent_status_id#" size="1" class="reqdClr">
							<option value="DELETE">DELETE</option>
							<cfloop query="ctagent_status">
								<option <cfif status.agent_status is agent_status> selected="selected" </cfif>" value="#agent_status#">#agent_status#</option>
							</cfloop>
						</select>
					</td>
					<td><input type="datetime" class="reqdClr" size="12" name="status_date_#agent_status_id#" id="status_date_#agent_status_id#" value="#status_date#"></td>
					<td>
						<textarea class="mediumtextarea" placeholder="status remark" name="status_remark_#agent_status_id#" id="status_remark_#agent_status_id#">#stripQuotes(status_remark)#</textarea>
					</td>
					<td>
						<span style="font-size:x-small;">(#reported_by# on #dateformat(STATUS_REPORTED_DATE,'yyyy-mm-dd')#)</span>
					</td>
				</tr>
			</cfloop>
				<input type="hidden" id="nnas" value="1">
				<tr id="nas1" class="newRec">
					<td>
						<select name="agent_status_new1" id="agent_status_new1" size="1">
							<option value="">pick status</option>
							<cfloop query="ctagent_status">
								<option value="#agent_status#">#agent_status#</option>
							</cfloop>
						</select>
					</td>
					<td><input type="datetime" size="12" name="status_date_new1" id="status_date_new1" value="#dateformat(now(),'yyyy-mm-dd')#"></td>
					<td>
						<textarea class="mediumtextarea" name="status_remark_new1" placeholder="status remark" id="status_remark_new1"></textarea>
					</td>
					<td><input type="button" onclick="addAgentStatus()" value="add a row"></td>
				</tr>
			</table>
			---->
		</fieldset>
		<fieldset>
			<table border>
				<tr>
					<th>Relationship
					<th>RelatedAgent</th>
				</th>
				<cfloop query="relns">
					<tr>
						<td>
							<select name="agent_relationship_#agent_relations_id#" id="agent_relationship_#agent_relations_id#" size="1">
								<option value="DELETE">DELETE</option>
								<cfloop query="ctRelns">
									<option value="#ctRelns.AGENT_RELATIONSHIP#"
										<cfif ctRelns.AGENT_RELATIONSHIP is relns.AGENT_RELATIONSHIP>selected="selected"</cfif>
										>#ctRelns.AGENT_RELATIONSHIP#</option>
								</cfloop>
							</select>
							<span class="infoLink" onclick="getCtDoc('CTAGENT_RELATIONSHIP');">Define</span>
						</td>
						<td>
							<input type="hidden" name="related_agent_id_#agent_relations_id#" id="related_agent_id_#agent_relations_id#" value="#related_agent_id#">
							<input type="text" name="related_agent_#agent_relations_id#" id="related_agent_#agent_relations_id#" value="#agent_name#"
							onchange="pickAgentTest('related_agent_id_#agent_relations_id#',this.id,this.value); return false;"
							onKeyPress="return noenter(event);" placeholder="pick an agent" class="reqdClr minput">
						</td>
					</tr>
				
				</cfloop>
				<cfloop query="reciprelns">
					<tr>
						<td>
							#agent_relationship#
						</td>
						<td>
							from <a href="/agents.cfm?agent_id=#agent_id#">#preferred_agent_name#</a>
						</td>
					</tr>
				</cfloop>
				</tr>
				<tr class="newRec" id="nar1">
					<td>
						<input type="hidden" id="nnar" value="1">
						<select name="agent_relationship_new1" id="agent_relationship_new1" size="1">
							<option value="">Pick New</option>
							<cfloop query="ctRelns">
								<option value="#ctRelns.AGENT_RELATIONSHIP#">#ctRelns.AGENT_RELATIONSHIP#</option>
							</cfloop>
						</select> 
					</td>
					<td>
						<input type="hidden" name="related_agent_id_new1" id="related_agent_id_new1">
						<input type="text" name="related_agent_new1" id="related_agent_new1"
							onchange="pickAgentTest('related_agent_id_new1',this.id,this.value); return false;"
							onKeyPress="return noenter(event);" placeholder="pick related agent" class="minput">
						<input type="button" onclick="addAgentRelationship()" value="add a row">
					</td>
				</tr>
			</table>
		</fieldset>
		<fieldset>
			<legend>Electronic Address</legend>
			<cfloop query="elecagentAddrs">
				<cfif address_type is "url">
					<cfset ttype='url'>
				<cfelseif address_type is "e-mail">
					<cfset ttype='email'>
				<cfelseif address_type contains "phone" or address_type is "fax">
					<cfset ttype='tel'>
				<cfelse>
					<cfset ttype='text'>
				</cfif>
				<div>
					<select name="electronic_address_type_#electronic_address_id#" id="electronic_address_type_#electronic_address_id#" size="1">
						<option value="DELETE">DELETE</option>
						<cfloop query="CTELECTRONIC_ADDR_TYPE">
							<option value="#CTELECTRONIC_ADDR_TYPE.ADDRESS_TYPE#"
								<cfif CTELECTRONIC_ADDR_TYPE.ADDRESS_TYPE is elecagentAddrs.ADDRESS_TYPE>selected="selected"</cfif>
							>#CTELECTRONIC_ADDR_TYPE.ADDRESS_TYPE#</option>
						</cfloop>
					</select>
					<span class="infoLink" onclick="getCtDoc('CTELECTRONIC_ADDR_TYPE');">Define</span>
					<input type="#ttype#" class="reqdClr minput" name="electronic_address_#electronic_address_id#" 
						id="electronic_address_#electronic_address_id#" value="#ADDRESS#">
				</div>
			</cfloop>
			
			<input type="hidden" id="nnea" value="1">
			<div class="newRec" id="eaddiv1">
				<select name="electronic_address_type_new1" id="electronic_address_type_new1" size="1">
					<option value="">pick new</option>
					<cfloop query="CTELECTRONIC_ADDR_TYPE">
						<option value="#CTELECTRONIC_ADDR_TYPE.ADDRESS_TYPE#">#CTELECTRONIC_ADDR_TYPE.ADDRESS_TYPE#</option>
					</cfloop>
				</select>
				<input type="text" class="minput" name="electronic_address_new1" id="electronic_address_new1" placeholder="add electronic address">
				<input type="button" onclick="addElectronicAddress()" value="add a row">
			</div>
		</fieldset>			
		<input type="submit" value="save all changes" class="savBtn">
	</form>
	<hr>
	<fieldset>
		<legend>Address</legend>
		<input type="button" onclick="addAgentAddr(#agent_id#)" value="New Address" class="insBtn">
		<cfloop query="agentAddrs">
			<cfif valid_addr_fg is 1>
				<cfset thisClass="validAddress">
			<cfelse>
				<cfset thisClass="invalidAddress">
			</cfif>
			<div class="#thisClass#" id="aow_#ADDR_ID#" style="width:100%; display: table;">
			    <div style="display: table-row">
			        <div id="atype_#ADDR_ID#" style="display: table-cell;">
			        	#addr_type# Address (<cfif valid_addr_fg is 1>valid<cfelse>invalid</cfif>)
			        </div>
			        <div style="display: table-cell;text-align:right;">
			        	<input type="button" onclick="editAgentAddress('#ADDR_ID#');" value="edit">
			        </div>
			    </div>
		    	<div id="dvaddr_#ADDR_ID#" style="margin-left:1em;">
					#replace(formatted_addr,chr(10),"<br>","all")#
				</div>
			</div>				
		</cfloop>
	</fieldset>
</cfoutput>