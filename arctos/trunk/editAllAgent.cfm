<cfinclude template="/includes/alwaysInclude.cfm">
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

		
	#map-canvas { height: 300px;width:500px; }
	
fieldset {
    border:0;
    outline: 1px solid gray;
	margin:1em;
	padding:1em;
}

legend {
    font-size:85%;
}

.goodsave {
   border:1px solid green;
margin:.1em;
}
.badsave {
   border:2px solid red;
	margin:.5em;
}

</style>


<!----
<script>

   
	$(document).ready(function() {

		$(".reqdClr:visible").each(function(e){
		    $(this).prop('required',true);
		});


		$("#fEditAgent").submit(function(event){
			event.preventDefault();
			console.log( $("#fEditAgent").serialize() );

			$.ajax({
				url: "/component/agent.cfc?queryformat=column&method=saveAgent&returnformat=json",
				type: "GET",
				dataType: "json",
				data:  $("#fEditAgent").serialize(),
				success: function(r) {
					if (r=='success'){

						console.log('success: reload ' + $("#agent_id").val() );
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
		$("#fAgentName").submit(function(event){
			event.preventDefault();
			var q=$("#fAgentName").serialize();
			$.ajax({
				url: "/component/agent.cfc?queryformat=column&method=saveAgentNames&returnformat=json",
				type: "GET",
				dataType: "json",
				data:  q,
				success: function(r) {
					if (r=='success'){
						$("#fs_fAgentName legend").removeClass().addClass('goodsave').text('Save Successful');
					} else {
						$("#fs_fAgentName legend").removeClass().addClass('badsave').text('ERROR!');
						alert('An error occurred: ' + r);
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



	
	});


function addAgentName(){
	var i=parseInt($("#nnan").val()) + parseInt(1);

	var h='<div id="agentnamedv'+i+'"><select name="agent_name_type_new'+i+'" id="agent_name_type_new'+i+'"></select>';
	h+='<input type="text" name="agent_name_new'+i+'" id="agent_name_new'+i+'" size="40" ></div>';
	$('#agentnamedv' + $("#nnan").val()).after(h);
	$('#agent_name_type_new1').find('option').clone().appendTo('#agent_name_type_new' + i);
	$("#nnan").val(i);
}
function addAgentStatus(){
	var i=parseInt($("#nnas").val()) + parseInt(1);
	var h='<tr id="nas'+i+'" class="newRec"><td>';
	h+='<select name="agent_status_new'+i+'" id="agent_status_new'+i+'" size="1" class="reqdClr"></select>';
	h+='</td><td><input type="datetime" size="12" name="status_date_new'+i+'" id="status_date_new'+i+'"></td>';
	h+='<td><input type="text" size="50" name="status_remark_new'+i+'" id="status_remark_new'+i+'"></td><td></td></tr>';
	$('#nas' + $("#nnas").val()).after(h);
	$('#agent_status_new1').find('option').clone().appendTo('#agent_status_new' + i);
	$("#nnas").val(i);
}
function addAgentRelationship(){
	var i=parseInt($("#nnar").val()) + parseInt(1);
	var h='<tr id="nar'+i+'" class="newRec"><td>';
	h+='<select name="agent_relationship_new'+i+'" id="agent_relationship_new'+i+'" size="1"></select> ';
	h+='</td><td><input type="hidden" name="related_agent_id_new'+i+'" id="related_agent_id_new'+i+'">';
	h+='<input type="text" name="related_agent_new'+i+'" id="related_agent_new'+i+'" ';
	h+='onchange="getAgent(\'related_agent_idnew'+i+'\',this.id,\'fEditAgent\',this.value); return false;"';
	h+='onKeyPress="return noenter(event);">';
	h+='</td></tr>';
	$('#nar' + $("#nnar").val()).after(h);
	$('#agent_relationship_new1').find('option').clone().appendTo('#agent_relationship_new' + i);
	$("#nnar").val(i);

}



				
						
							
							
					
				
				
function editAgentAddress (aid){
console.log('clickypop');
	var guts = "includes/forms/editAgentAddr.cfm?addr_id=" + aid;
//    $("#dialog").dialog('open');




	$("<div id='dialog' class='popupDialog'><img src='/images/indicator.gif'></div>").dialog({
		autoOpen: true,
		closeOnEscape: true,
		height: 'auto',
		modal: true,
		position: ['center', 'center'],
		title: 'Build Taxon Name',
		width: 'auto',
		close: function() {
			$( this ).remove();
		},
	}).load(guts, function() {
		$(this).dialog("option", "position", ['center', 'center'] );
	});
	$(window).resize(function() {
		//fluidDialog();
		$(".ui-dialog-content").dialog("option", "position", ['center', 'center']);
	});
	$(".ui-widget-overlay").click(function(){
	    $(".ui-dialog-titlebar-close").trigger('click');
	});




}

</script>


----->
<!----



function editAgentAddress (aid){
	var guts = "includes/forms/editAgentAddr.cfm?addr_id=" + aid;

/
	$("<div id='dialog' class='popupDialog'><img src='/images/indicator.gif'></div>").dialog({
		autoOpen: true,
		closeOnEscape: true,
		height: 'auto',
		modal: true,
		position: ['center', 'center'],
		title: 'Edit Address',
		width: 'auto',
		close: function() {
			$( this ).remove();
		},
	}).load(guts, function() {
		$(this).dialog("option", "position", ['center', 'center'] );
	});
*/
	/*
	$(window).resize(function() {
		//fluidDialog();
		$(".ui-dialog-content").dialog("option", "position", ['center', 'center']);
	});
	$(".ui-widget-overlay").click(function(){
	    $(".ui-dialog-titlebar-close").trigger('click');
	});
*/
}				









$.ajax({
		url: "/component/agent.cfc?queryformat=column&method=addAgentName&returnformat=json",
		type: "GET",
		dataType: "json",
		data: {
			agent_name_type:  $("#agent_name_type_new").val(),
			agent_name : $("#agent_name_new").val()
		},
		success: function(r) {
			if (r=='success'){
				$("#fs_fAgentName legend").removeClass().addClass('goodsave').text('Insert Successful');
				var h='<select name="agent_name_type_' + r.DATA.AGENT_NAME_ID[0] + '" id="agent_name_type_' + r.DATA.AGENT_NAME_ID[0] + '">';
						<option value="">DELETE</option>
						<cfloop query="ctNameType">
							<option  <cfif ctNameType.agent_name_type is agent_names.agent_name_type> selected="selected" </cfif>
								value="#ctNameType.agent_name_type#">#ctNameType.agent_name_type#</option>
						</cfloop>
					</select>
					<input type="text" value="#agent_names.agent_name#" name="agent_name_#agent_name_id#" id="agent_name_#agent_name_id#" size="40" required class="reqdClr">
					<cfif agent_name_type is "login">
						<a href="/AdminUsers.cfm?action=edit&username=#agent_names.agent_name#" class="infoLink">[ Arctos user ]</a>
					</cfif>
					



			} else {
				$("#fs_fAgentName legend").removeClass().addClass('badsave').text('ERROR!');
				alert('An error occurred: ' + r);
			}
		},
		error: function (xhr, textStatus, errorThrown){
		    alert(errorThrown + ': ' + textStatus + ': ' + xhr);
		}
	});
* */


---->


<!------------------------------------------------------------------------------------------------------------->
<cfif action is "nothing">
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
				agent_name, 
				related_agent_id
			from 
				agent_relations, 
				agent_name
			where 
			  agent_relations.related_agent_id = agent_name.agent_id and
			  agent_name_type = 'preferred' and
			  agent_relations.agent_id=#agent.agent_id#
		</cfquery>
		
		<div>
			AgentID #agent.agent_id# created by #agent.created_by_agent# on #agent.CREATED_DATE#
			<span class="infoLink" onClick="getDocs('agent')">Help</span>
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
			<fieldset id="fs_fEditAgent">
				<legend>Edit Agent</legend>
				<input type="hidden" name="agent_id" id="agent_id" value="#agent_id#">
				<label for="preferred_agent_name">Preferred Name</label>
				<input type="text" value="#stripQuotes(agent.preferred_agent_name)#" name="preferred_agent_name" id="preferred_agent_name" size="50" class="reqdClr">
				 
				<label for="agent_type">Agent Type</label>
				<select name="agent_type" id="agent_type" class="reqdClr">
					<cfloop query="ctAgent_Type">
						<option  <cfif ctAgent_Type.agent_type is agent.agent_type> selected="selected" </cfif>
							value="#ctAgent_Type.agent_type#">#ctAgent_Type.agent_type#</option>
					</cfloop>
				</select>
				<label for="agent_remarks">Agent Remark</label>
				<input type="text" value="#stripQuotes(agent.agent_remarks)#" name="agent_remarks" id="agent_remarks" size="100">
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
						<input type="text" value="#agent_names.agent_name#" name="agent_name_#agent_name_id#" id="agent_name_#agent_name_id#" size="40" required class="reqdClr">
						<cfif agent_name_type is "login">
							<a href="/AdminUsers.cfm?action=edit&username=#agent_names.agent_name#" class="infoLink">[ Arctos user ]</a>
						</cfif>
					</div>
				</cfloop>
				<div class="newRec">
					Add Name<br>
					<input type="hidden" id="nnan" value="1">
					<div id="agentnamedv1">
						<select name="agent_name_type_new1" id="agent_name_type_new1">
							<option value=""></option>
							<cfloop query="ctNameType">
								<option value="#ctNameType.agent_name_type#">#ctNameType.agent_name_type#</option>
							</cfloop>
						</select>
						<input type="text" name="agent_name_new1" id="agent_name_new1" size="40">
						<input type="button" onclick="addAgentName()" value="more">
					</div>
				</div>
			</fieldset>
			<fieldset>
				<table border>
					<tr>
					<th>
						<span class="likeLink" onclick="getCtDoc('ctAgent_Status');">Agent Status</span>
					</th>
					<th>Status Date</th>
					<th>Remark</th>
					<th></th>
					<th></th>
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
						<td><input type="text" size="50" name="status_remark_#agent_status_id#" id="status_remark_#agent_status_id#" value="#status_remark#"></td>
						<td>
							<span style="font-size:x-small;">(#reported_by# on #dateformat(STATUS_REPORTED_DATE,'yyyy-mm-dd')#)</span>
						</td>
					</tr>
				</cfloop>
				<input type="hidden" id="nnas" value="1">
				<tr id="nas1" class="newRec">
					<td>
						<select name="agent_status_new1" id="agent_status_new1" size="1">
							<option value=""></option>
							<cfloop query="ctagent_status">
								<option value="#agent_status#">#agent_status#</option>
							</cfloop>
						</select>
					</td>
					<td><input type="datetime" size="12" name="status_date_new1" id="status_date_new1" value="#dateformat(now(),'yyyy-mm-dd')#"></td>
					<td><input type="text" size="50" name="status_remark_new1" id="status_remark_new1"></td>
					<td><input type="button" onclick="addAgentStatus()" value="more"></td>
				</tr>
				
			</table>
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
						</td>
						<td>
							<input type="hidden" name="related_agent_id_#agent_relations_id#" id="related_agent_id_#agent_relations_id#" value="#related_agent_id#">
							<input type="text" name="related_agent_#agent_relations_id#" id="related_agent_#agent_relations_id#" class="reqdClr" value="#agent_name#"
								onchange="getAgent('related_agent_id_#agent_relations_id#',this.id,'fEditAgent',this.value); return false;"
							onKeyPress="return noenter(event);">
						</td>
					</tr>
				</cfloop>
				</tr>
				<tr id="nar1">
					<td>
						
						<input type="hidden" id="nnar" value="1">
						<select name="agent_relationship_new1" id="agent_relationship_new1" size="1">
							<option value=""></option>
							<cfloop query="ctRelns">
								<option value="#ctRelns.AGENT_RELATIONSHIP#">#ctRelns.AGENT_RELATIONSHIP#</option>
							</cfloop>
						</select> 
					</td>
					<td>
						<input type="hidden" name="related_agent_id_new1" id="related_agent_id_new1">
						<input type="text" name="related_agent_new1" id="related_agent_new1"
							onchange="getAgent('related_agent_id_new1',this.id,'fEditAgent',this.value); return false;"
							onKeyPress="return noenter(event);">
						<input type="button" onclick="addAgentRelationship()" value="more">
					</td>
				</tr>
			</table>
		</fieldset>
		<fieldset>
			<legend>Electronic Address</legend>
			<cfloop query="elecagentAddrs">
				<select name="electronic_address_type_#electronic_address_id#" id="electronic_address_type_#electronic_address_id#" size="1">
					<option value="DELETE">DELETE</option>
					<cfloop query="CTELECTRONIC_ADDR_TYPE">
						<option value="#CTELECTRONIC_ADDR_TYPE.ADDRESS_TYPE#"
							<cfif CTELECTRONIC_ADDR_TYPE.ADDRESS_TYPE is elecagentAddrs.ADDRESS_TYPE>selected="selected"</cfif>
						>#CTELECTRONIC_ADDR_TYPE.ADDRESS_TYPE#</option>
					</cfloop>
				</select>
				<input type="text" class="reqdClr" size="12" name="electronic_address_#electronic_address_id#" 
					id="electronic_address_#electronic_address_id#" value="#ADDRESS#">

			</cfloop>

		</fieldset>
		
			
		<input type="submit">
		</form>
									<input type="button" onclick="addAgentAddr(#agent_id#)" value="New Address">

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
			<br />
			
		<br />
		
		<!-----
		
	
			
		
			<br>
		</form>
				
		<cfset i=1>
		<cfloop query="agentAddrs">
			<cfif valid_addr_fg is 1>
				<div style="border:2px solid green;margin:1px;padding:1px;">
			<cfelse>
				<div style="border:2px solid red;margin:1px;padding:1px;">
			</cfif>
				<form name="addr#i#" method="post" action="editAllAgent.cfm">
					<input type="hidden" name="agent_id" value="#agent.agent_id#">
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
				&nbsp;
				<input type="button" class="lnkBtn" value="Edit" onclick="addr#i#.action.value='editAddr';addr#i#.submit();">
				&nbsp;
				<input type="button" class="delBtn" value="Delete" onclick="addr#i#.action.value='deleteAddr';confirmDelete('addr#i#');">
				<div style="margin-left:1em;">
					#replace(formatted_addr,chr(10),"<br>","all")#
				</div>
				<cfset i=#i#+1>
			</div>
		</cfloop>
			<br />
			<cfset i=1>
			<cfloop query="elecagentAddrs">
				<form name="elad#i#" method="post" action="editAllAgent.cfm">
					<input type="hidden" name="action" >
					<input type="hidden" name="agent_id" value="#agent.agent_id#">
					<input type="hidden" name="address_type" value="#address_type#">
					<input type="hidden" name="address" value="#address#">
				</form>
				<div style="border:2px solid green;margin:1px;padding:1px;">
					#address_type#: #address#
					<input type="button" value="Edit" class="lnkBtn" onclick="elad#i#.action.value='editElecAddr';elad#i#.submit();">
					<input type="button" value="Delete" class="delBtn" onclick="elad#i#.action.value='deleElecAddr';confirmDelete('elad#i#');">
				</div>
				<cfset i=#i#+1>
			</cfloop>
		<br />
		
		
		
		<cfif agent.agent_type is "group">
			<cfquery name="grpMem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
			<label for="gmemdv">Group Members</label>
			<cfset i=1>
			<br />
			<div id="gmemdv" style="border:2px solid green;margin:1px;padding:1px;">
				<cfloop query="grpMem">
					<form name="groupMember#i#" method="post" action="editAllAgent.cfm">
						<input type="hidden" name="action" value="deleteGroupMember" />
						<input type="hidden" name="member_agent_id" value="#member_agent_id#" />
						<input type="hidden" name="agent_id" value="#agent_id#" />
						#agent_name#&nbsp;<input type="button" value="Remove Member" class="delBtn" onClick="confirmDelete('groupMember#i#');"><br>
					</form>
					<cfset i=#i# + 1>
				</cfloop>
			</div>
			<cfquery name="memOrd" dbtype="query">
				select max(member_order) + 1 as nextMemOrd from grpMem
			</cfquery>
			<cfif len(memOrd.nextMemOrd) gt 0>
				<cfset nOrd = memOrd.nextMemOrd>
			<cfelse>
				<cfset nOrd = 1>
			</cfif>
			<form name="newGroupMember" method="post" action="editAllAgent.cfm">
				<input type="hidden" name="agent_id" value="#agent_id#" />
				<input type="hidden" name="action" value="makeNewGroupMemeber" />
				<input type="hidden" name="member_order" value="#nOrd#" />
				<input type="hidden" name="member_id">
				<div class="newRec">
					<label for="">Add Member to Group</label>
					<input type="text" name="group_member" class="reqdClr" 
						onchange="getAgent('member_id','group_member','newGroupMember',this.value); return false;"
				 		onKeyPress="return noenter(event);">
					<input type="submit" class="insBtn" value="Add Group Member">
				</div>
			</form>
		</cfif>
		
			<div id="nagnndv" class="newRec">
				<label for="nagnndv">Add agent name</label>
				<form name="newName" action="editAllAgent.cfm" method="post" target="_person">
					<input type="hidden" name="Action" value="newName">
					<input type="hidden" name="agent_id" value="#agent.agent_id#">
					<select name="agent_name_type" onchange="suggestName(this.value);">
						<cfloop query="ctNameType">
							<option value="#ctNameType.agent_name_type#">#ctNameType.agent_name_type#</option>
						</cfloop>
					</select>
					<input type="text" name="agent_name" id="agent_name">
					<input type="submit" class="insBtn" value="Create Name">
				</form>
			</div>
			
			<br />
		
			<br />
			<div class="newRec">
				<label>Add Address</label>
				<form name="newAddress" method="post" action="editAllAgent.cfm">
					<input type="hidden" name="agent_id" value="#agent.agent_id#">
					<input type="hidden" name="Action" value="newAddress">
					<table>
						<tr>
							<td>
								<label for="addr_type">Address Type</label>
								<select name="addr_type" id="addr_type" size="1">
									<cfloop query="ctAddrType">
									<option value="#ctAddrType.addr_type#">#ctAddrType.addr_type#</option>
									</cfloop>
								</select>
							</td>
							<td>
								<label for="job_title">Job Title</label>
								<input type="text" name="job_title" id="job_title">
							</td>
						</tr>
						<tr>
							<td colspan="2">
								<label for="institution">Institution</label>
								<input type="text" name="institution" id="institution"size="50" >
							</td>
						</tr>
						<tr>
							<td colspan="2">
								<label for="department">Department</label>
								<input type="text" name="department" id="department" size="50" >
							</td>
						</tr>
						<tr>
							<td colspan="2">
								<label for="street_addr1">Street Address 1</label>
								<input type="text" name="street_addr1" id="street_addr1" size="50" class="reqdClr">
							</td>
						</tr>
						<tr>
							<td colspan="2">
								<label for="street_addr2">Street Address 2</label>
								<input type="text" name="street_addr2" id="street_addr2" size="50">
							</td>
						</tr>
						<tr>
							<td>
								<label for="city">City</label>
								<input type="text" name="city" id="city" class="reqdClr">
							</td>
							<td>
								<label for="state">State</label>
								<input type="text" name="state" id="state" class="reqdClr">
							</td>
						</tr>
						<tr>
							<td>
								<label for="zip">Zip</label>
								<input type="text" name="zip" id="zip" class="reqdClr">
							</td>
							<td>
								<label for="country_cde">Country Code</label>
								<input type="text" name="country_cde" id="country_cde" class="reqdClr">
							</td>
						</tr>
						<tr>
							<td>
								<label for="mail_stop">Mail Stop</label>
								<input type="text" name="mail_stop" id="mail_stop">
							</td>
							<td>
								<label for="valid_addr_fg">Valid?</label>
								<select name="valid_addr_fg" id="valid_addr_fg" size="1">
									<option value="1">yes</option>
									<option value="0">no</option>
								</select>
							</td>
						</tr>
						<tr>
							<td colspan="2">
								<label for="addr_remarks">Address Remark</label>
								<input type="text" name="addr_remarks" id="addr_remarks" size="50">
							</td>
						</tr>
						<tr>
							<td colspan="2">
								<input type="submit" class="insBtn" value="Create Address">
							</td>
						</tr>
					</table>
				</form>
			</div>
			<br />
			<div class="newRec">
				<label>Add Electronic Address</label>
				<form name="newElecAddr" method="post" action="editAllAgent.cfm">
					<input name="Action" type="hidden" value="newElecAddr">
					<input type="hidden" name="agent_id" value="#agent.agent_id#">
					<select name="address_type" size="1">
						<cfloop query="ctElecAddrType">
							<option value="#ctElecAddrType.address_type#">#ctElecAddrType.address_type#</option>
						</cfloop>
					</select>
					<input type="text" name="address" id="address" size="50">
					<input type="submit" class="insBtn" value="Create Address">
				</form>
			</div>
			
			
			---->
	</cfoutput>
</cfif>





<cfif not isdefined("agent_id")>
	<cfset agent_id = -1>
</cfif>
<script language="javascript" type="text/javascript">
	jQuery(document).ready(function() {
		//$.noConflict();
		///jQuery("#birth_date").datepicker();
	});
	function togglePerson(atype){
		if (atype=='person'){
			$("#newPersonAttrs").show();
		} else {
			$("#newPersonAttrs").hide();
		}
		try{parent.resizeCaller();}catch(e){}
	}
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
		}
	}
	function autosuggestPreferredName(){
		var pname=$("#first_name").val() + ' ' +  $("#middle_name").val() + ' ' + $("#last_name").val();
		//pname=pname.replace(/^\s+|\s+$/g,"");
		pname = pname.replace(/\s{2,}/g, ' ');
		$("#preferred_agent_name").val(pname);
	}
	function autosuggestNameComponents(){
		jQuery.getJSON("/component/functions.cfc",
			{
				method : "splitAgentName",
				returnformat : "json",
				queryformat : 'column',
				name : $("#preferred_agent_name").val()
			},
			function (r) {
				if (r.DATA.FORMATTED_NAME[0].length > 0){
					var sfn=r.DATA.FORMATTED_NAME[0];
					var sfirstn=r.DATA.FIRST[0];
					var smdln=r.DATA.MIDDLE[0];
					var slastn=r.DATA.LAST[0];
					if (r.DATA.FORMATTED_NAME[0] != $("#preferred_agent_name").val()){
						var r=confirm("Suggested formatted name does not match the preferred name you entered.\n Press OK to use " + sfn + ' or CANCEL to keep what you entered.');
						if (r==true){
  							$("#preferred_agent_name").val(sfn);
						}
					}
					if ($("#first_name").val().length == 0 && sfirstn.length>0){
						$("#first_name").val(sfirstn);
					}
					if ($("#middle_name").val().length == 0 && smdln.length>0){
						$("#middle_name").val(smdln);
					}
					if ($("#last_name").val().length == 0 && slastn.length>0){
						$("#last_name").val(slastn);
					}
				} else { 
					alert('Unable to parse input. Please carefully check preferred name format');
				}
			}
		);
	}
	function forceSubmit(){
		$("#forceOverride").val('true');
		$("#createAgent").submit();
	}
	function preCreateCheck(){
		if ($("#forceOverride").val()=="true"){
			return true;
		}
		if ($("#agent_type").val()=='person'){
			if ($("#first_name").val().length==0 && $("#last_name").val().length==0 && $("#middle_name").val().length==0){
				alert('First, middle, or last name is required for person agents. Use the autogenerate button.');
				$("#forceOverride").val('false');
				return false;
			}
		}
		jQuery.getJSON("/component/functions.cfc",
			{
				method : "checkAgent",
				returnformat : "json",
				queryformat : 'column',
				preferred_name : $("#preferred_agent_name").val(),
				agent_type : $("#agent_type").val(),
				first_name : $("#first_name").val(),
				middle_name : $("#middle_name").val(),
				last_name : $("#last_name").val()
			},
			function (r) {
				if(r){
					$("#forceOverride").val('false');
					var theHTML='There are potential problems with the agent you are trying to create.<br>' + r;
					theHTML+='<br><span onclick="forceSubmit()" class="likeLink">click here to force creation</span>';
					$("#preCreateErrors").html(theHTML).addClass('error').show();
					return false;
				}else{
					$("#forceOverride").val('true');
					$("#createAgent").submit();
				}
			}
		);
		return false;
	}
</script>
<!------------------------------------------------------------------------------------------------------------->
<cfif Action is "makeNewAgent">
	<cfif not isdefined("first_name")>
		<cfset first_name="">
	</cfif>
	<cfif not isdefined("middle_name")>
		<cfset middle_name="">
	</cfif>
	<cfif not isdefined("last_name")>
		<cfset last_name="">
	</cfif>
	<cfoutput>
		<cfif not isdefined("forceOverride") or forceOverride is not "true">
			<cfset probs="">
			<cfif agent_type is "person">
				<cfif 
					(not isdefined("first_name") or len(first_name) is 0) and 
					(not isdefined("middle_name") and len(middle_name) is 0) and 
					(not isdefined("last_name") and len(last_name) is 0)>
					<cfset probs=listappend(probs,"Person agents must have first, middle, and/or last name.",";")>
				</cfif>
				<cfif isdefined("first_name") and len(first_name) is 1>
					<cfset probs=listappend(probs,"Abbreviations should be followed by a period.",";")>
				</cfif>
				<cfif isdefined("middle_name") and len(middle_name) is 1>
					<cfset probs=listappend(probs,"Abbreviations should be followed by a period.",";")>
				</cfif>
				<cfif isdefined("last_name") and len(last_name) is 1>
					<cfset probs=listappend(probs,"Abbreviations should be followed by a period.",";")>
				</cfif>
			<cfelse>
				<cfif 
					(isdefined("first_name") and len(first_name) gt 0) or 
					(isdefined("middle_name") and len(middle_name) gt 0) or 
					(isdefined("last_name") and len(last_name) gt 0)>
					<cfset probs=listappend(probs,"Non-person agents may not have first, middle, or last name.",";")>
					<cfabort>
				</cfif>
			</cfif>
			<cfset obj = CreateObject("component","component.functions")>
			<cfset fnProbs = obj.checkAgent(
				preferred_name="#preferred_agent_name#",
				agent_type="#agent_type#",
				first_name="#first_name#",
				middle_name="#middle_name#",
				last_name="#last_name#"
			)>
			<cfset probs=listappend(probs,fnProbs,";")>
			<cfif len(probs) gt 0>
				<div>
					There are potential problems with this agent:
				</div>
				<ul>
				<cfloop list="#probs#" index="p" delimiters=";">
					<li>
						#p#
					</li>
				</cfloop>
				</ul>
				<cfset forceURL="/editAllAgent.cfm?action=makeNewAgent&forceOverride=true">
				<cfloop collection="#form#" item="theField">
					<cfif theField is not "fieldNames" and theField is not "ACTION">
						<cfset forceURL=forceURL & "&" & theField & '=' & form[theField]>
					</cfif>
				</cfloop>
				<cfloop collection="#url#" item="theField">
					<cfif theField is not "fieldNames" and theField is not "ACTION">
						<cfset forceURL=forceURL & "&" & theField & '=' & url[theField]>
					</cfif>
				</cfloop>
				Use your back button to fix the problems.
				<p>
					If you're really sure that you want to create this agent, you can also <a href="#forceURL#">force creation</a>.
				</p>	
				<cfabort>			
			</cfif>
		</cfif>
		<cftransaction>
			<cfquery name="agentID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select sq_agent_id.nextval nextAgentId from dual
			</cfquery>
			<cfquery name="insAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				INSERT INTO agent (
					agent_id,
					agent_type,
					preferred_agent_name,
					agent_remarks
					)
				VALUES (
					#agentID.nextAgentId#,
					'#agent_type#',
					'#preferred_agent_name#',
					'#agent_remarks#'
				)
			</cfquery>
			<cfquery name="insPName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				INSERT INTO agent_name (
					agent_name_id,
					agent_id,
					agent_name_type,
					agent_name
				) VALUES (
					sq_agent_name_id.nextval,
					#agentID.nextAgentId#,
					'preferred',
					'#preferred_agent_name#'
				)
			</cfquery>
			<cfif isdefined("first_name") and len(first_name) gt 0>
				<cfquery name="insFName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					INSERT INTO agent_name (
					agent_name_id,
					agent_id,
					agent_name_type,
					agent_name
				) VALUES (
					sq_agent_name_id.nextval,
					#agentID.nextAgentId#,
					'first name',
					'#first_name#'
				)
				</cfquery>
			</cfif>
			<cfif isdefined("middle_name") and len(middle_name) gt 0>
				<cfquery name="insMName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					INSERT INTO agent_name (
					agent_name_id,
					agent_id,
					agent_name_type,
					agent_name
				) VALUES (
					sq_agent_name_id.nextval,
					#agentID.nextAgentId#,
					'middle name',
					'#middle_name#'
				)
				</cfquery>
			</cfif>
			<cfif isdefined("last_name") and len(last_name) gt 0>
				<cfquery name="insLName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					INSERT INTO agent_name (
					agent_name_id,
					agent_id,
					agent_name_type,
					agent_name
				) VALUES (
					sq_agent_name_id.nextval,
					#agentID.nextAgentId#,
					'last name',
					'#last_name#'
				)
				</cfquery>
			</cfif>
		</cftransaction>			
		<cflocation url="editAllAgent.cfm?agent_id=#agentID.nextAgentId#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->
<cfif action is "newAgent">
	<cfoutput>
		<strong>Create Agent</strong>
		<form name="prefdName" action="editAllAgent.cfm" method="post" target="_person" id="createAgent" onsubmit="return preCreateCheck()">
			<input type="hidden" name="action" value="makeNewAgent">
			<input type="hidden" name="forceOverride" id="forceOverride" value="">
			<label for="agent_type">Agent Type</label>
			<select name="agent_type" id="agent_type" size="1" class="reqdClr" onchange="togglePerson(this.value);">
				<option value=""></option>
				<cfloop query="ctAgent_Type">
					<option value="#ctAgent_Type.agent_type#">#ctAgent_Type.agent_type#</option>
				</cfloop>
			</select>
			<input type="hidden" name="agent_name_type" value="preferred">
			<label for="preferred_agent_name">Preferred Name</label>
			<input type="text" name="preferred_agent_name" id="preferred_agent_name" size="50" class="reqdClr">
			<div id="newPersonAttrs" style="display:none;">
				<br><span class="likeLink" onclick="autosuggestNameComponents();">Autogenerate name components from preferred name</span>
				<label for="first_name">First Name</label>
				<input type="text" name="first_name" id="first_name">
				<label for="middle_name">Middle Name</label>
				<input type="text" name="middle_name" id="middle_name">
				<label for="last_name">Last Name</label>
				<input type="text" name="last_name" id="last_name">
				<br><span class="likeLink" onclick="autosuggestPreferredName();">Autogenerate preferred name from first/middle/last</span>
			</div>
			<label for="agent_remarks">Remarks</label>
			<input type="text"  size="80" name="agent_remarks" id="agent_remarks">
			<br>
			<input type="submit" value="Create Agent" class="savBtn">
			<div id="preCreateErrors" style="display:none;">
			</div>
		</form>
		<div class="importantNotification">
			Read <a href="http://arctosdb.org/documentation/agent/##create" class="external" target="_blank">documentation</a> BEFORE clicking buttons!
		</div>
		<cfif isdefined("agent_type") and agent_type is "person">
			<script>
				$("##agent_type").val('person');
				togglePerson('person');
			</script>
		</cfif>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->
<cfif action is "updateStatus">
	<cfoutput>
		<cfquery name="newStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update agent_status 
			set
			AGENT_STATUS='#AGENT_STATUS#',
				STATUS_DATE='#STATUS_DATE#',
				STATUS_REMARK='#status_remark#'
			where AGENT_STATUS_ID=#AGENT_STATUS_ID#
		</cfquery>
		<cflocation url="editAllAgent.cfm?agent_id=#agent_id#">
	</cfoutput>
</cfif>

<!------------------------------------------------------------------------------------------------------------->
<cfif action is "deleteStatus">
	<cfoutput>
		<cfquery name="newStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from  agent_status where agent_status_id=#agent_status_id#
		</cfquery>
		<cflocation url="editAllAgent.cfm?agent_id=#agent_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->
<cfif action is "newStatus">
	<cfoutput>
		<cfquery name="newStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into agent_status (
				AGENT_STATUS_ID,
				AGENT_ID,
				AGENT_STATUS,
				STATUS_DATE,
				STATUS_REMARK
			) values (
				sq_AGENT_STATUS_ID.nextval,
				#agent_id#,
				'#agent_status#',
				'#status_date#',
				'#status_remark#'
			)
		</cfquery>
		<cflocation url="editAllAgent.cfm?agent_id=#agent_id#">
	</cfoutput>
</cfif>			
<!------------------------------------------------------------------------------------------------------------->
<cfif #Action# is "editElecAddr">
	<cfoutput>
		<form name="edElecAddr" method="post" action="editAllAgent.cfm">
			<input name="Action" type="hidden" value="saveEditElecAddr">
			<input type="hidden" name="agent_id" value="#agent_id#">
			<input type="hidden" name="origAddress" value="#address#">
			<input type="hidden" name="origAddressType" value="#address_type#">
			<select name="address_type" size="1" id="address_type">
				<cfloop query="ctElecAddrType">
					<option <cfif #form.address_type# is "#ctElecAddrType.address_type#"> selected </cfif>value="#ctElecAddrType.address_type#">#ctElecAddrType.address_type#</option>
				</cfloop>
			</select>
			<input type="text" name="address" id="address" value="#address#" size="50">
			<input type="submit" 
				value="Save Updates" 
				class="savBtn">
		</form>
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->
<cfif #Action# is "saveEditElecAddr">
	<cfoutput>
		<cfquery name="upElecAddr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
		<cfquery name="deleElecAddr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from electronic_address where
				agent_id=#agent_id#
				and address_type='#address_type#'
				and address='#address#'
		</cfquery>
		<cflocation url="editAllAgent.cfm?agent_id=#agent_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->
<cfif action is "editAddr">
	<cfset title = "Edit Address">
	Edit Address:
	<cfoutput>
	<form name="editAddr" method="post" action="editAllAgent.cfm">
		<input type="hidden" name="agent_id" value="#agent_id#">
		<input type="hidden" name="action" value="saveEditsAddr">
		<input type="hidden" name="addr_id" value="#addr_id#">
			<table>
				<tr>
					<td>
						<label for="addr_type">Address Type</label>
						<select name="addr_type" id="addr_type" size="1">
							<cfloop query="ctAddrType">
							<option 
								<cfif addrtype is ctAddrType.addr_type> selected="selected" </cfif>
								value="#ctAddrType.addr_type#">#ctAddrType.addr_type#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<label for="job_title">Job Title</label>
						<input type="text" name="job_title" id="job_title" value="#job_title#">
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="institution">Institution</label>
						<input type="text" name="institution" id="institution" size="50"  value="#institution#">
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="department">Department</label>
						<input type="text" name="department" id="department" size="50"  value="#department#">
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="street_addr1">Street Address 1</label>
						<input type="text" name="street_addr1" id="street_addr1" size="50" class="reqdClr" value="#street_addr1#">
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="street_addr2">Street Address 2</label>
						<input type="text" name="street_addr2" id="street_addr2" size="50" value="#street_addr2#">
					</td>
				</tr>
				<tr>
					<td>
						<label for="city">City</label>
						<input type="text" name="city" id="city" class="reqdClr" value="#city#">
					</td>
					<td>
						<label for="state">State</label>
						<input type="text" name="state" id="state" class="reqdClr" value="#state#">
					</td>
				</tr>
				<tr>
					<td>
						<label for="zip">Zip</label>
						<input type="text" name="zip" id="zip" class="reqdClr" value="#zip#">
					</td>
					<td>
						<label for="country_cde">Country Code</label>
						<input type="text" name="country_cde" id="country_cde" class="reqdClr" value="#country_cde#">
					</td>
				</tr>
				<tr>
					<td>
						<label for="mail_stop">Mail Stop</label>
						<input type="text" name="mail_stop" id="mail_stop" value="#mail_stop#">
					</td>
					<td>
						<label for="valid_addr_fg">Valid?</label>
						<select name="valid_addr_fg" id="valid_addr_fg" size="1">
							<option <cfif validfg IS "1"> selected="selected" </cfif>value="1">yes</option>
							<option <cfif validfg IS "0"> selected="selected" </cfif>value="0">no</option>
						</select>
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="addr_remarks">Address Remark</label>
						<input type="text" name="addr_remarks" id="addr_remarks" size="50" value="#addr_remarks#">
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<input type="submit" class="savBtn" value="Save Edits">
					</td>
				</tr>
			</table>
		</form>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->	
<cfif #Action# is "saveEditsAddr">
	<cfoutput>
		<cfquery name="editAddr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
		<cfquery name="killAddr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from addr where addr_id=#addr_id#
		</cfquery>
		<cflocation url="editAllAgent.cfm?agent_id=#agent_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->	
<cfif #Action# is "saveCurrentAddress">
	<cfoutput>
		<cftransaction>
			<cfquery name="addr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
			<cfquery name="elecaddr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
	<cfquery name="elecaddr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
		<cfquery name="prefName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select agent_name from preferred_agent_name where agent_id=#agent_id#
		</cfquery>
		<cfquery name="addr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
		<cfquery name="newReln" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
<cfif action is "deleteRelated">
	<cfoutput>
	<cfquery name="killRel" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from agent_relations where
			agent_id = #agent_id#
			and related_agent_id = #related_agent_id#
			and agent_relationship = '#relationship#'
	</cfquery>
	<!--- and the merge file ---->
	<cfquery name="killRel_CFMerge" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_dup_agent set status='relationship removed by #session.username#' where 
		AGENT_ID=#agent_id# and 
		RELATED_AGENT_ID=#related_agent_id#
	</cfquery>
	<cflocation url="editAllAgent.cfm?agent_id=#agent_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->	
<cfif #Action# is "deleteGroupMember">
	<cfoutput>
	<cfquery name="killGrpMem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
		<cfquery name="changeRelated" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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

<!------------------------------------------------------------------------------------------------------------->	
<cfif #Action# is "updateName">
	<cfoutput>
		<cfquery name="updateName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			UPDATE agent_name SET agent_name = '#agent_name#', agent_name_type='#agent_name_type#'
			where agent_name_id = #agent_name_id#
		</cfquery>
		<cflocation url="editAllAgent.cfm?agent_id=#agent_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->	
<cfif action is "deleteName">
	<cfoutput>
		<cfquery name="deleteAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			DELETE FROM agent_name WHERE agent_name_id = #agent_name_id#
		</cfquery>
		<cflocation url="editAllAgent.cfm?agent_id=#agent_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------->
<cfif #action# is "makeNewGroupMemeber">
	<cfquery name="newGroupMember" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		INSERT INTO group_member (GROUP_AGENT_ID, MEMBER_AGENT_ID, MEMBER_ORDER)
		values (#agent_id#,#member_id#,#MEMBER_ORDER#)
	</cfquery>
	<cflocation url="editAllAgent.cfm?agent_id=#agent_id#">
</cfif>
<!------------------------------------------------------------------------------------------------------------->
<!----
<script>
	parent.resizeCaller();
</script>

---->
<!------------------------------------------------------------------------------------------------------------->
<cfinclude template="includes/_pickFooter.cfm">