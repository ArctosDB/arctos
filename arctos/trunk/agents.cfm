<cfif not isdefined("agent_id")>
	<cfset agent_id=-1>
</cfif>
<cfinclude template="/includes/_header.cfm">


<script>


$(document).ready(function() {
	jQuery("#status_date").datepicker();
	$("#agntSearch").submit(function(event){

	console.log('form submit');


		event.preventDefault();
var q=$("#agntSearch").serialize();
		loadAgentSearch(q);
	});

/*
		
$("#goAgentSearch").click(function(e){
		var q=$("#agntSearch").serialize();
		console.log(q);
var bgDiv = document.createElement('div');
		bgDiv.id = 'bgDiv';
		bgDiv.className = 'bgDiv';
		bgDiv.setAttribute('onclick','closeAndRefresh()');
		document.body.appendChild(bgDiv);
		var cDiv = document.createElement('div');
		cDiv.id = 'customDiv';
		cDiv.className = 'sscustomBox';
		cDiv.innerHTML='<br>Loading...';
		document.body.appendChild(cDiv);
		var ptl="/includes/SpecSearch/customIDs.cfm";
		$(cDiv).load(ptl,{},function(){
			viewport.init("#customDiv");
		});
* 
* 	});
* */


});
function loadEditAgent(aid){
$("#td_rslt").html('<img src="/images/indicator.gif">');
var ptl="/editAllAgent.cfm?agent_id=" + aid;
		$("#td_rslt").load(ptl,{},function(){
			//viewport.init("#customDiv");
		});
}

function loadAgentSearch(q){
var h;
$("#td_edit").html('<img src="/images/indicator.gif">');

$.ajax({
		url: "/component/functions.cfc?queryformat=column&method=findAgents&returnformat=json",
		type: "GET",
		dataType: "json",
		async: false,
		data:  q,
		success: function(r) {
			console.log(r);

			if (r.ROWCOUNT===0){
				$("#td_edit").html('nothing found');
				return false;
			}
			h='<div style="height:20em; overflow:auto;">';
			for (i=0;i<r.ROWCOUNT;i++) {
				h+='<div class="likeLink" onclick="loadEditAgent(' + r.DATA.AGENT_ID[i] + ');">';
				h+= r.DATA.PREFERRED_AGENT_NAME[i] + '<font size="-1"> (';
				h+=r.DATA.AGENT_TYPE[i] + ': ' + r.DATA.AGENT_ID[i] + ')</font> </div>';
			}
			h+='</div>';
			$("#td_edit").html(h);
	

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


<style>


	#td_search {
		height:50%;
		width:35%;
		vertical-align:top;
	}
	
	#td_rslt {
		height:50%;
		width:65%;
		vertical-align:top;
	}
	
	#td_edit {
		height:100%;
		width:35%;
		vertical-align:top;
	}
	#olTabl {
		height:100%;
		width:100%;
		border-spacing: 0;
    	border-collapse: separate;
	}
	
	
	#_search {
		width:100%;
		height:100%;
	}
	
	#_pick {
		width:100%;
		height:100%;
	}
	
	#_person {
		width:100%;
		height:100%;
	}


</style>
<script>
	jQuery(document).ready(function() {
		var wh=$(window).height();
		var sfmenuh = $('div.sf-mainMenuWrapper:first').height();
		var hh = $('#header_color').height();
		wh=wh - hh - sfmenuh - 120;
		$("#olTabl").height(wh); 
	});
</script>
<cfoutput>
	<table border id="olTabl">
		<tr>
			<td id="td_search">
			i am td_search



<div style="border:1px solid red;padding:1em;margin:1em;">
<table width="100%">
	<tr>
		<td>
			Agent Search		
		</td>
		<td>
			<span class="infoLink pageHelp" onclick="getDocs('agent');">Page Help</span>
		</td>
	</tr>
</table>
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



			</td>
			<td id="td_rslt" rowspan="2">
			
			
			i am td_rslt
			</td>
		</tr>
		<tr>
			<td id="td_edit" valign="top">
			i am td_edit
			</td>
		</tr>
	</table>


<!-----------
<table border id="olTabl">
	<tr>
		<td id="td_search">
		srch
		<!----
			<iframe src="/AgentSearch.cfm" id="_search" name="_search"></iframe>
			<br>
			---->
		</td>
		<td id="td_rslt" rowspan="2">
			edit 
		</td>
		
	</tr>
		<tr>
		<td id="td_edit" valign="top">
		results
		
		<!----
			---->
		</td>
		</tr>
</table>


----------------->

<cfinclude template="/includes/_footer.cfm">

</cfoutput>