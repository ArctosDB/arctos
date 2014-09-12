
<cfinclude template="/includes/_header.cfm">

<style>

#sidebar, #main {
    display: table-cell;
}

#sidebar {
    width:35%;
    float: left;
    padding:1em;
}

#agntEditCell {
   margin:1em;
    padding:1em;
    border:1px solid black;

}
#td_search{
     margin:.5em;
    padding:.5em;
    border:1px solid black;

}
#agntRslCell{
     margin:.5em;
    padding:.5em;
    border:1px solid black;

}


</style>
<script>
	$(document).ready(function() {
		var agent_id = getUrlParameter('agent_id');
		if ( typeof agent_id !== 'undefined' && agent_id.length > 0 ) {
			loadEditAgent(agent_id);
		}
		$("#agntSearch").submit(function(event){
			event.preventDefault();
			loadAgentSearch($("#agntSearch").serialize());
		});
	});
</script>


<!---


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



				
						
							
function addAgentAddr(aid){
		var guts = "includes/forms/editAgentAddr.cfm?action=newAddress&agent_id=" + aid;
	$("<div id='dialog' class='popupDialog'><img src='/images/indicator.gif'></div>").dialog({
		autoOpen: true,
		closeOnEscape: true,
		height: 'auto',
		modal: true,
		position: ['center', 'center'],
		title: 'Add Address',
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
					
				
				
function editAgentAddress (aid){
console.log('clickypop');
	var guts = "includes/forms/editAgentAddr.cfm?action=editAddress&addr_id=" + aid;
//    $("#dialog").dialog('open');




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
	$(window).resize(function() {
		//fluidDialog();
		$(".ui-dialog-content").dialog("option", "position", ['center', 'center']);
	});
	$(".ui-widget-overlay").click(function(){
	    $(".ui-dialog-titlebar-close").trigger('click');
	});




}

</script>
---->




<cfset title='Manage Agents'>

<cfquery name="ctagent_name_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select agent_name_type from ctagent_name_type order by agent_name_type
</cfquery>
<cfquery name="ctagent_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select agent_type from ctagent_type order by agent_type
</cfquery>
<cfquery name="ctagent_status" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select agent_status from ctagent_status order by agent_status
</cfquery>



<cfoutput>


<div id="content">
  <div id="sidebar">
    <div id="td_search">
		<form name="agntSearch" id="agntSearch">
			<input type="hidden" name="Action" value="search">
			<label for="anyName"><a href="javascript:void(0);" onClick="getDocs('agent','anynamesearch')">Any part of any name</a></label>
			<input type="text" name="anyName" id="anyName" size="75">
			<table width="100%">
				<tr>
					<td>
						<label for="agent_type">Agent Type</label>
						<select name="agent_type" size="1" id="agent_type">
							<option value=""></option>
							<cfloop query="ctagent_type">
								<option value="#agent_type#">#agent_type#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<label for="agent_id">AgentID</label>
						<input type="text" name="agent_id" size="12">
					</td>
				</tr>
			</table>
			<label for="address"><a href="javascript:void(0);" onClick="getDocs('agent','address')">Address</a></label>
			<input type="text" name="address" id="address" size="75">
			<table width="100%">
				<tr>
					<td>
						<label for="agent_status">Agent Status</label>
						<select name="agent_status" size="1" id="agent_status">
							<option value=""></option>
							<cfloop query="ctagent_status">
								<option value="#agent_status#">#agent_status#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<label for="status_date_oper">date match type</label>
						<select name="status_date_oper" size="1" id="status_date_oper">
							<option value="<=">Before</option>
							<option selected value="=" >At</option>
							<option value=">=">After</option>
						</select>
					</td>
					<td>
						<label for="status_date">Status Date</label>
						<input type="date" name="status_date" id="status_date" size="15">
					</td>
				</tr>
			</table>
			<table width="100%">
				<tr>
					<td>
						<label for="agent_name_type">Agent Name Type</label>
						<select name="agent_name_type" size="1" id="agent_name_type">
							<option value=""></option>
							<cfloop query="ctagent_name_type">
								<option value="#agent_name_type#">#agent_name_type#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<label for="agent_name">Agent Name</label>
						<input type="text" name="agent_name" id="agent_name" size="35">
					</td>
				</tr>
			</table>
			<table width="100%">
				<tr>
					<td>
						<label for="created_by">Created By</label>
						<input type="text" name="created_by" id="created_by" size="35">
		
					</td>
					<td>
						<label for="create_date_oper">create date match type</label>
						<select name="create_date_oper" size="1" id="create_date_oper">
							<option value="<=">Before</option>
							<option selected value="=" >At</option>
							<option value=">=">After</option>
						</select>
					</td>
					<td>
						<label for="created_date">Created Date</label>
						<input type="datetime" name="created_date" id="created_date" size="15">
					</td>
				</tr>
			</table>
			<table width="100%">
				<tr>
					<td>
						<input type="submit" value="Search" class="schBtn" id="goAgentSearch">
					</td>
					<td><input type="reset" value="Clear Form" class="clrBtn"></td>
					<td>
					<input type="button" 
						value="Create New Person Agent" 
						class="insBtn"
						onClick="window.open('editAllAgent.cfm?action=newAgent&agent_type=person','_person');">
					<input type="button" 
						value="Create New Non-Person Agent" 
						class="insBtn"
						onClick="window.open('editAllAgent.cfm?action=newAgent','_person');">
					</td>
				</tr>
			</table>
		</form>
	</div>
    <div id="agntRslCell"></div>
      
  </div>
 	<div id="main">
		<div id="agntEditCell"></div>
	</div>
</div>


<cfinclude template="/includes/_footer.cfm">

</cfoutput>