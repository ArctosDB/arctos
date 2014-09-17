<cfinclude template="/includes/alwaysInclude.cfm">
<cfif action is "nothing">
	<cfquery name="ctAgent_Type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select agent_type from ctagent_type order by agent_type
	</cfquery>
	<script language="javascript" type="text/javascript">
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
		function autosuggestNameComponents(benice){
			jQuery.getJSON("/component/agent.cfc",
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
						if (benice===false || ($("#first_name").val().length == 0 && sfirstn.length>0)){
							$("#first_name").val(sfirstn);
						}
						if (benice===false || ($("#middle_name").val().length == 0 && smdln.length>0)){
							$("#middle_name").val(smdln);
						}
						if (benice===false || ($("#last_name").val().length == 0 && slastn.length>0)){
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
			//if ($("#forceOverride").val()=="true"){
			//	return true;
		//	}
			if ($("#agent_type").val()=='person'){
				if ($("#first_name").val().length==0 && $("#last_name").val().length==0 && $("#middle_name").val().length==0){
					alert('First, middle, or last name is required for person agents. Use the autogenerate button.');
					//$("#forceOverride").val('false');
					return false;
				}
			}

/*
			jQuery.getJSON("/component/agent.cfc",
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
						
						var q='There are potential problems with the agent you are trying to create.\n\n' + r;
						p+='If you are absolutely sure that this agent is not a duplicate, you may ';
						p+='click "confirm" to force creation.

//						theHTML+='<span onclick="forceSubmit()" class="likeLink">click here to force creation</span></p>';
	//					$("#preCreateErrors").html(theHTML).addClass('error').show();
						
var c=confirm(q);
console.log(c);

return false;
					}else{
						$("#forceOverride").val('true');
						$("#createAgent").submit();
					}
				}
			);
			return false;
*/
		}
	</script>
	<cfoutput>
		<strong>Create Agent</strong>
		<form name="prefdName" id="createAgent" onsubmit="return preCreateCheck()">
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
				<br>
				Autogenerate name components from preferred name
				<span class="likeLink" onclick="autosuggestNameComponents(true);">[ if blank ]</span>
				<span class="likeLink" onclick="autosuggestNameComponents(false);">[ overwrite ]</span>
				
				
				<label for="first_name">First Name</label>
				<input type="text" name="first_name" id="first_name">
				<label for="middle_name">Middle Name</label>
				<input type="text" name="middle_name" id="middle_name">
				<label for="last_name">Last Name</label>
				<input type="text" name="last_name" id="last_name">
				<br><span class="likeLink" onclick="autosuggestPreferredName();">Autogenerate/overwrite preferred name from first/middle/last</span>
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
<!------------------------------------------------>
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
	
	i am makeNewAgent
	
	
	<cfabort>
	
	
	
	
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
			<cfset obj = CreateObject("component","component.agent")>
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
		<br>Agent created successfully.
		If you're seeing this something is broken so file a bug report!
		<script>
			parent.loadEditAgent(#agentID.nextAgentId#);
			parent.$(".ui-dialog-titlebar-close").addClass('obvious').trigger('click');
		</script>
	</cfoutput>
</cfif>