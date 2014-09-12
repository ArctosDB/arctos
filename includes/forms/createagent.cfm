<cfinclude template="/includes/alwaysInclude.cfm">

<cfquery name="ctAgent_Type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select agent_type from ctagent_type order by agent_type
</cfquery>

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