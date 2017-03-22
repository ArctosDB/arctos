<cfif not isdefined("action")><cfset action="nothing"></cfif>
<cfinclude template="/includes/functionLib.cfm">
<cfquery name="ctNameType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select agent_name_type as agent_name_type from ctagent_name_type where agent_name_type != 'preferred' order by agent_name_type
</cfquery>
<cfquery name="CTADDRESS_TYPE" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select ADDRESS_TYPE from CTADDRESS_TYPE order by ADDRESS_TYPE
</cfquery>
<cfquery name="ctAgent_Type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select agent_type from ctagent_type order by agent_type
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
	.shippingAddress {border:2px solid red;margin:1px;padding:1px;}
	fieldset {
	    border:0;
	    outline: 1px solid gray;
		margin:1em;
		padding:1em;
	}
	legend {
	    font-size:85%;
	}
	.deleting{border:5px solid orange;margin:1px;padding:1px;}
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
				$("#agent_name_type_new" + i).removeClass('reqdClr').prop('required',false);
				$("#agent_name_new" + i).removeClass('reqdClr').prop('required',false);
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
				$("#agent_status_new" + i).removeClass('reqdClr').prop('required',false);
				$("#status_date_new" + i).removeClass('reqdClr').prop('required',false);
			}
		});
		$(document).on("change", '[id^="agent_relationship_new"], [id^="related_agent_new"]', function(){
			var i =  this.id;
			i=i.replace("related_agent_new", "");
			i=i.replace("agent_relationship_new", "");
			if ( $("#agent_relationship_new" + i).val().length > 0 ||  $("#related_agent_new" + i).val().length > 0 ) {
				$("#agent_relationship_new" + i).addClass('reqdClr').prop('required',true);
				$("#related_agent_new" + i).addClass('reqdClr').prop('required',true);
				$("#valid_addr_fg_new" + i).addClass('reqdClr').prop('required',true);
			} else {
				$("#agent_relationship_new" + i).removeClass('reqdClr').prop('required',false);
				$("#related_agent_new" + i).removeClass('reqdClr').prop('required',false);
				$("#valid_addr_fg_new" + i).removeClass('reqdClr').prop('required',false);
			}
		});

		$(document).on("change", '[id^="address_type_"]', function(){
			var ntype,dfld;
			dfld=this.id.replace('address_type_','address_');
			if ( $(this).val()=='DELETE' ){
				$("#" + dfld).addClass('deleting');
				$(this).addClass('deleting');
				return false;
			}
			$("#" + dfld).removeClass('deleting');
			$(this).removeClass('deleting');
			if ( $(this).val()=='url' ){
				ntype='url';
			} else if ( $(this).val()=='email' ){
				ntype='email';
			} else if ( $(this).val().indexOf('phone')>-1 ||  $(this).val()=='fax'){
				ntype='tel';
			} else if ( $(this).val()=='shipping' || $(this).val()=='home' || $(this).val()=='correspondence' ){
				ntype='textarea';
			} else {
				ntype='text';
			}

			if (ntype=='textarea'){
				var newDataElem='<textarea class="reqdClr addresstextarea" name="' + dfld + '" id="' + dfld + '"></textarea>';
			} else {
				var newDataElem='<input type="' + ntype + '" class="reqdClr minput" name="' + dfld + '" id="' + dfld + '">';
			}
			var oldData=$("#" + dfld).val();
			$("#" + dfld).replaceWith(newDataElem );
			$("#" + dfld).val(oldData);
		});
		$(document).on("change", '[id^="address_type_new"], [id^="address_new"]', function(){
			// require paired values
			var i = this.id;
			var ntype = 'text';
			i=i.replace("address_type_new", "");
			i=i.replace("address_new", "");
			if ( $("#address_type_new" + i).val().length > 0 ||  $("#address_new" + i).val().length > 0 ) {
				$("#address_type_new" + i).addClass('reqdClr').prop('required',true);
				$("#address_new" + i).addClass('reqdClr').prop('required',true);
			} else {
				$("#address_type_new" + i).removeClass('reqdClr').prop('required',false);
				$("#address_new" + i).removeClass('reqdClr').prop('required',false);
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
	        guid_prefix,
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
	        guid_prefix
	       order by
	       	numSpecs desc,
	       	guid_prefix
	</cfquery>
	<cfquery name="address" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			ADDRESS_ID,
			ADDRESS_TYPE ,
			ADDRESS,
			VALID_ADDR_FG,
			ADDRESS_REMARK,
			count(shipfrom.transaction_id) numshipfrom,
			count(shipto.transaction_id) numshipto
		from
			address,
			shipment shipto,
			shipment shipfrom
		where
			agent_id = #agent.agent_id# and
			address.address_id=shipto.SHIPPED_TO_ADDR_ID (+) and
			address.address_id=shipfrom.SHIPPED_FROM_ADDR_ID (+)
		group by
			ADDRESS_ID,
			ADDRESS_TYPE ,
			ADDRESS,
			VALID_ADDR_FG,
			ADDRESS_REMARK
		order by
			valid_addr_fg DESC,
			address_type
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
			agent_relations.related_agent_id,
			getPreferredAgentName(agent_relations.created_by_agent_id) created_by_agent,
			to_char(agent_relations.created_on_date,'YYYY-MM-DD') created_on_date
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
	</div>
	<div style="border:2px dashed red;padding:.2em;margin:.2em;font-weight:bold;">
		<span class="helpLink" data-helplink="agent">Read the documentation</span>
		and <a href="/info/agentActivity.cfm?agent_id=#agent.agent_id#" target="_blank">view the Agent Activity report</a>
		before changing anything.
	</div>
	<div>
		Collecting Summary
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
				<td>#guid_prefix#</td>
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
							onchange="pickAgentModal('member_agent_id_#group_member_id#',this.id,this.value); return false;"
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
						onchange="pickAgentModal('member_agent_id_new1',this.id,this.value); return false;"
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
				<div style="max-height:6em;overflow:auto;">
					<cfloop query="ingroup">
						<br><a href="/agents.cfm?agent_id=#GROUP_AGENT_ID#">#preferred_agent_name#</a>
					</cfloop>
				</div>
			</cfif>
		</fieldset>
		<fieldset id="fs_fAgentName">
			<legend>Agent Names <span class="likeLink" onclick="getCtDoc('ctagent_name_type');">code table</span></legend>
			<cfloop query="agent_names">
				<div>
					<select name="agent_name_type_#agent_name_id#" id="agent_name_type_#agent_name_id#">
						<option value="DELETE">DELETE</option>
						<cfloop query="ctNameType">
							<option  <cfif ctNameType.agent_name_type is agent_names.agent_name_type> selected="selected" </cfif>
								value="#ctNameType.agent_name_type#">#ctNameType.agent_name_type#</option>
						</cfloop>
					</select>

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
			<legend>Agent Status <span class="likeLink" onclick="getCtDoc('ctAgent_Status');">code table</span></legend>
			<div style="display:table">
				<cfloop query="status">
					<div style="display: table-row;">
						<div style="display:table-cell">
							<select name="agent_status_#agent_status_id#" id="agent_status_#agent_status_id#" size="1" class="reqdClr">
								<option value="DELETE">DELETE</option>
								<cfloop query="ctagent_status">
									<option <cfif status.agent_status is agent_status> selected="selected" </cfif> value="#agent_status#">#agent_status#</option>
								</cfloop>
							</select>
						</div>
						<div style="display:table-cell">
							<input type="datetime" class="reqdClr sinput" name="status_date_#agent_status_id#" id="status_date_#agent_status_id#" value="#status_date#" placeholder="status date">
						</div>
						<div style="display:table-cell">
							<textarea class="mediumtextarea" placeholder="status remark" name="status_remark_#agent_status_id#" id="status_remark_#agent_status_id#">#stripQuotes(status_remark)#</textarea>
						</div>
						<div style="display:table-cell;font-size:x-small">
							#reported_by# on #dateformat(STATUS_REPORTED_DATE,'yyyy-mm-dd')#
						</div>
					</div>
				</cfloop>
			</div>
			<input type="hidden" id="nnas" value="1">
			<div class="newRec">
				<input type="button" onclick="addAgentStatus()" value="add a row">
				<label for="">Add Agent Status</label>
				<div style="display:table;">
					<div id="nas1" style="display: table-row;">
						<div style="display:table-cell">
							<select name="agent_status_new1" id="agent_status_new1" size="1">
							<option value="">pick status</option>
							<cfloop query="ctagent_status">
								<option value="#agent_status#">#agent_status#</option>
							</cfloop>
						</select>
						</div>
						<div style="display:table-cell">
							<input type="datetime" class="sinput" placeholder="status date" name="status_date_new1" id="status_date_new1" value="#dateformat(now(),'yyyy-mm-dd')#">
						</div>
						<div style="display:table-cell">
							<textarea class="mediumtextarea" name="status_remark_new1" placeholder="status remark" id="status_remark_new1"></textarea>
						</div>
					</div>
				</div>
			</div>
		</fieldset>
		<fieldset>
			<legend>Relationships <span class="likeLink" onclick="getCtDoc('CTAGENT_RELATIONSHIP');">code table</span></legend>
			<table >
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

						</td>
						<td>
							<input type="hidden" name="related_agent_id_#agent_relations_id#" id="related_agent_id_#agent_relations_id#" value="#related_agent_id#">
							<input type="text" name="related_agent_#agent_relations_id#" id="related_agent_#agent_relations_id#" value="#agent_name#"
								onchange="pickAgentModal('related_agent_id_#agent_relations_id#',this.id,this.value); return false;"
								onKeyPress="return noenter(event);" placeholder="pick an agent" class="reqdClr minput">
							<a href="/agents.cfm?agent_id=#related_agent_id#">[ link ]</a>
						</td>
						<td>
							<div style="font-size:x-small">
								Created by #created_by_agent# on #dateformat(created_on_date,'yyyy-mm-dd')#
							</div>
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
						<td></td>
					</tr>
				</cfloop>
				</tr>
				<tr class="newRec" id="nar1">
					<td>
						<input type="hidden" id="nnar" value="1">
						<select name="agent_relationship_new1" id="agent_relationship_new1" size="1">
							<option value="">pick relationship</option>
							<cfloop query="ctRelns">
								<option value="#ctRelns.AGENT_RELATIONSHIP#">#ctRelns.AGENT_RELATIONSHIP#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<input type="hidden" name="related_agent_id_new1" id="related_agent_id_new1">
						<input type="text" name="related_agent_new1" id="related_agent_new1"
							onchange="pickAgentModal('related_agent_id_new1',this.id,this.value); return false;"
							onKeyPress="return noenter(event);" placeholder="pick related agent" class="minput">
						<input type="button" onclick="addAgentRelationship()" value="add a row">
					</td>
					<td></td>
				</tr>
			</table>
		</fieldset>
		<fieldset>
			<legend>
				Address
				<span class="likeLink" onclick="getCtDoc('ctaddress_type');">code table</span>
				<span class="helpLink" data-helplink="agent_address">help</span>
				<span class="helpLink" data-helplink="agent_address_used">used shipment address</span>
				<a href="/info/agentActivity.cfm?agent_id=#agent.agent_id###shipping" target="_blank">shipment details</a>
			</legend>
			<cfloop query="address">
				<cfif address_type is "url">
					<cfset ttype='url'>
				<cfelseif address_type is "email">
					<cfset ttype='email'>
				<cfelseif address_type contains "phone" or address_type is "fax">
					<cfset ttype='tel'>
				<cfelseif address_type is "home" or address_type is "correspondence" or address_type is "shipping">
					<cfset ttype='textarea'>
				<cfelse>
					<cfset ttype='text'>
				</cfif>
				<div>
					<select name="address_type_#address_id#" id="address_type_#address_id#" size="1">
						<option value="DELETE">DELETE</option>
						<cfloop query="ctaddress_type">
							<option value="#ctaddress_type.ADDRESS_TYPE#"
								<cfif ctaddress_type.ADDRESS_TYPE is address.ADDRESS_TYPE>selected="selected"</cfif>
							>#ctaddress_type.ADDRESS_TYPE#</option>
						</cfloop>
					</select>
					<cfif numshipfrom gt 0 or numshipto gt 0>
						<cfset addrClass="shippingAddress">
					<cfelse>
						<cfset addrClass="">
					</cfif>


					<cfif ttype is 'textarea'>
						<textarea class="reqdClr addresstextarea #addrClass#" name="address_#address_id#" id="address_#address_id#">#ADDRESS#</textarea>
					<cfelse>
						<input type="#ttype#" class="reqdClr minput #addrClass#" name="address_#address_id#" id="address_#address_id#" value="#ADDRESS#">
					</cfif>
					<select name="valid_addr_fg_#address_id#" id="valid_addr_fg_#address_id#" class="reqdClr">
						<option value="1" <cfif valid_addr_fg is 1> selected="selected" </cfif>>valid</option>
						<option value="0" <cfif valid_addr_fg is 0> selected="selected" </cfif>>invalid</option>
					</select>
					<textarea class="smalltextarea" placeholder="remark" name="address_remark_#address_id#" id="address_remark_#address_id#">#address_remark#</textarea>



				</div>
			</cfloop>

			<input type="hidden" id="nnea" value="1">
			<div class="newRec" id="eaddiv1">
				<select name="address_type_new1" id="address_type_new1" size="1">
					<option value="">pick new</option>
					<cfloop query="ctaddress_type">
						<option value="#ctaddress_type.ADDRESS_TYPE#">#ctaddress_type.ADDRESS_TYPE#</option>
					</cfloop>
				</select>
				<input type="text" class="minput" name="address_new1" id="address_new1" placeholder="add address">
				<select name="valid_addr_fg_new1" id="valid_addr_fg_new1" class="reqdClr">
						<option value="1">valid</option>
						<option value="0">invalid</option>
					</select>
					<textarea class="smalltextarea" placeholder="remark" name="address_remark_new1" id="address_remark_new1"></textarea>




				<input type="button" onclick="addAddress()" value="add a row">
			</div>
		</fieldset>
		<input type="submit" value="save all changes" class="savBtn">
	</form>
</cfoutput>