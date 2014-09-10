<cfif not isdefined("agent_id")>
	<cfset agent_id=-1>
</cfif>
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

function getUrlParameter(sParam)
{
    var sPageURL = window.location.search.substring(1);
    var sURLVariables = sPageURL.split('&');
    for (var i = 0; i < sURLVariables.length; i++) 
    {
        var sParameterName = sURLVariables[i].split('=');
        if (sParameterName[0] == sParam) 
        {
            return sParameterName[1];
        }
    }
}    
$(document).ready(function() {
	var agent_id = getUrlParameter('agent_id');
	console.log('agent_id=' + agent_id);



	jQuery("#status_date").datepicker();
	$("#agntSearch").submit(function(event){

	console.log('form submit');


		event.preventDefault();
var q=$("#agntSearch").serialize();
		loadAgentSearch(q);
	});



});
function loadEditAgent(aid){
$("#agntEditCell").html('<img src="/images/indicator.gif">');
var ptl="/editAllAgent.cfm?agent_id=" + aid;
		$("#agntEditCell").load(ptl,{},function(){
			//viewport.init("#customDiv");
		});
}

function loadAgentSearch(q){
var h;
$("#agntRslCell").html('<img src="/images/indicator.gif">');

$.ajax({
		url: "/component/agent.cfc?queryformat=column&method=findAgents&returnformat=json",
		type: "GET",
		dataType: "json",
		async: false,
		data:  q,
		success: function(r) {
			console.log(r);

			if (r.ROWCOUNT===0){
				$("#agntRslCell").html('nothing found');
				return false;
			}
			h='<div style="height:30em; overflow:scroll;">';
			for (i=0;i<r.ROWCOUNT;i++) {
				h+='<div class="likeLink" onclick="loadEditAgent(' + r.DATA.AGENT_ID[i] + ');">';
				h+= r.DATA.PREFERRED_AGENT_NAME[i] + '<font size="-1"> (';
				h+=r.DATA.AGENT_TYPE[i] + ': ' + r.DATA.AGENT_ID[i] + ')</font> </div>';
			}
			h+='</div>';
			$("#agntRslCell").html(h);
	

		},
		error: function (xhr, textStatus, errorThrown){
		    alert(errorThrown + ': ' + textStatus + ': ' + xhr);
		}
	});
}

</script>
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
						<input type="text" name="agent_id" size="12" id="agent_id">
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
						<input type="text" name="status_date" id="status_date" size="15">
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
						<input type="text" name="created_date" id="created_date" size="15">
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