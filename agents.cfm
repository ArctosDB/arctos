<cfif not isdefined("agent_id")>
	<cfset agent_id=-1>
</cfif>
<cfinclude template="/includes/_header.cfm">


<script>


$(document).ready(function() {
	jQuery("#status_date").datepicker();
	$("#formEdit").submit(function(event){
		event.preventDefault();
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


function loadAgentSearch(q){
$("#td_edit").html('<img src="/images/indicator.gif">');
	var ptl="/AgentGrid.cfm?" + q;
		$("#td_edit").load(ptl,{},function(){
			//viewport.init("#customDiv");
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


<!---------------
<script type="text/javascript">




/***********************************************
* IFrame SSI script II- © Dynamic Drive DHTML code library (http://www.dynamicdrive.com)
* Visit DynamicDrive.com for hundreds of original DHTML scripts
* This notice must stay intact for legal use
***********************************************/

//Input the IDs of the IFRAMES you wish to dynamically resize to match its content height:
//Separate each ID with a comma. Examples: ["myframe1", "myframe2"] or ["myframe"] or [] for none:
var iframeids=["_search","_person","_pick"]

//Should script hide iframe from browsers that don't support this script (non IE5+/NS6+ browsers. Recommended):
var iframehide="yes"

var getFFVersion=navigator.userAgent.substring(navigator.userAgent.indexOf("Firefox")).split("/")[1]
var FFextraHeight=parseFloat(getFFVersion)>=0.1? 60 : 0 //extra height in px to add to iframe in FireFox 1.0+ browsers

function resizeCaller() {
var dyniframe=new Array()
for (i=0; i<iframeids.length; i++){
if (document.getElementById)
resizeIframe(iframeids[i])
//reveal iframe for lower end browsers? (see var above):
if ((document.all || document.getElementById) && iframehide=="no"){
var tempobj=document.all? document.all[iframeids[i]] : document.getElementById(iframeids[i])
tempobj.style.display="block"
}
}
}

function resizeIframe(frameid){
var currentfr=document.getElementById(frameid)
if (currentfr && !window.opera){
currentfr.style.display="block"
if (currentfr.contentDocument && currentfr.contentDocument.body.offsetHeight) //ns6 syntax
currentfr.height = currentfr.contentDocument.body.offsetHeight+FFextraHeight; 
else if (currentfr.Document && currentfr.Document.body.scrollHeight) //ie5+ syntax
currentfr.height = currentfr.Document.body.scrollHeight;
if (currentfr.addEventListener)
currentfr.addEventListener("load", readjustIframe, false)
else if (currentfr.attachEvent){
currentfr.detachEvent("onload", readjustIframe) // Bug fix line
currentfr.attachEvent("onload", readjustIframe)
}
}
}

function readjustIframe(loadevt) {
var crossevt=(window.event)? event : loadevt
var iframeroot=(crossevt.currentTarget)? crossevt.currentTarget : crossevt.srcElement
if (iframeroot)
resizeIframe(iframeroot.id);
}

function loadintoIframe(iframeid, url){
if (document.getElementById)
document.getElementById(iframeid).src=url
}

if (window.addEventListener)
window.addEventListener("load", resizeCaller, false)
else if (window.attachEvent)
window.attachEvent("onload", resizeCaller)
else
window.onload=resizeCaller


</script>

------------>
<style>


	#td_search {
		height:50%;
		width:35%;
	}
	
	#td_rslt {
		height:50%;
		width:65%;
	}
	
	#td_edit {
		height:100%;
		width:35%;
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
<form name="agntSearch" id="agntSearch" action="AgentGrid.cfm" method="post" target="_pick">
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