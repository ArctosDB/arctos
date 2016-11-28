<cfinclude template="/includes/alwaysInclude.cfm">
<cfif action is "nothing">
<cfoutput>
	<cfquery name="cttaxonomy_source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select source from cttaxonomy_source order by source
	</cfquery>
	<p>
		This for clones (copies) a classification from one name to another. You MUST edit the new data, and you may need to delete
		any "old" classification data.
	</p>

	<p>


		<form name="newCC" method="post" action="cloneclass.cfm">
				<input type="text" name="taxon_name_id" value="#taxon_name_id#">
				<input type="text" name="tgt_taxon_name_id">
				<input type="text" name="taxon_name_id" value="#classification_id#">
				<input type="text" name="action" value="newCC">
				<p>
					1) Pick a target taxon name (the one which will get the new data)
					<input type="text" name="tgtName" class="reqdClr" size="50"
						onChange="taxaPick('tgt_taxon_name_id','tgtName','newCC',this.value); return false;"
						onKeyPress="return noenter(event);">
				</p>
				<p>
					2) Pick a source for the new classification
					<select name="source" id="source" class="reqdClr">
						<cfloop query="cttaxonomy_source">
							<option value="#source#">#source#</option>
						</cfloop>
					</select>
				</p>
				<p>
					3) Review what's being cloned into the name you picked above

					<cfquery name="d" datasource="uam_god">
						select
							term,
							nvl(term_type,'[not given]') term_type,
							position_in_classification
						from
							v_mv_sciname_term
						where
							taxon_name_id=#taxon_name_id# and
							classification_id='#classification_id#'
					</cfquery>
					<cfquery name="nct" dbtype="query">
						select term,term_type from d where position_in_classification is null order by term_type
					</cfquery>
					<br>Non-classification terms
					<ul>
						<cfloop query="nct">
							<li>#term_type#=#term#</li>
						</cfloop>
					</ul>
					<cfquery name="ct" dbtype="query">
						select term,term_type from d where position_in_classification is not null order by position_in_classification
					</cfquery>
					<br>Classification terms
					<cfset indent=0>
					<ul>
						<cfloop query="ct">
							<li style="margin-left:#indent#em;">#term_type#=#term#</li>
							<cfset indent=indent+1>
						</cfloop>
					</ul>

				</p>


			4) Do it.

			<br><input type="submit" value="create and edit classification">
		</form>
	</p>
</cfoutput>
	hi im here to clone a classification

	<cfabort>


	<cfquery name="ctAgent_Type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select agent_type from ctagent_type order by agent_type
	</cfquery>
	<style>
		/* override the error style for this page */

		.error{
			position:absolute;
			font-size:1em;
			color:red;
			border:5px solid red;
			padding:1em;
			margin:0 1em 0 0;
			top:0;
			left:0;
			bottom:0;
			background-color:white;
			text-align:left;
			z-index:20;
			overflow:auto;}
	</style>
	<script language="javascript" type="text/javascript">
		$(document).ready(function() {
			$(".reqdClr:visible").each(function(e){
			    $(this).prop('required',true);
			});
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
			// force the submit, log it, let them deal with any real errors
			$("#status").val('force');
			$("#createAgent").submit();
		}
		function removeErrDiv(){
			// start over
			$("#status").val('unchecked');
			$("#preCreateErrors").html('').removeClass().hide();
		}
		function preCreateCheck(){
			// if status is pass or force, just submit the form
			if ($("#status").val()!="unchecked"){
				return true;
			}
			if ($("#agent_type").val()=='person'){
				if ($("#first_name").val().length==0 && $("#last_name").val().length==0 && $("#middle_name").val().length==0){
					alert('First, middle, or last name is required for person agents. Use the autogenerate button.');
					$("#status").val('unchecked');
					return false;
				}
			}
			$("#createAgent").find(":submit").css('display', 'none');
			$('<img id="ldgimg">').attr('src', '/images/indicator.gif').insertAfter($("#createAgent").find(":submit"));
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
						var q='There are potential problems with the agent you are trying to create.<ul>';
	 					var errs = r.split(";");
						for (var i = 0; i < errs.length; i++) {
						    q+='<li>' + errs[i] + '</li>';
						}
						q+='</ul>';
						if (r.indexOf('FATAL ERROR')==-1){
							q+='If you are absolutely sure that this agent is not a duplicate, you may ';
							q+='<span onclick="forceSubmit()" class="infoLink">click here to force creation</span>';
						}
						q+='<p><span onclick="removeErrDiv()" class="likeLink">return to create agent form</span></p>';
						$("#preCreateErrors").html(q).addClass('error').show();
						$("#createAgent").find(":submit").css('display', 'block');
						$("#ldgimg").remove();
						return false;
					}else{
						$("#status").val('pass');
						$("#createAgent").submit();
					}
				}
			);
			return false;
		}
	</script>
	<cfoutput>
		<strong>Create Agent</strong>
		<form name="prefdName" id="createAgent" onsubmit="return preCreateCheck()">
			<input type="hidden" name="action" value="makeNewAgent">
			<!---
				possible values here:
					unchecked: run the checks
					pass: passed checks, just create agent
					force: failed checks, creation forced, log it
			---->
			<input type="hidden" name="status" id="status" value="unchecked">
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
	<cfoutput>
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
		<cfif isdefined("status") and status is "force">
			<cfmail subject="force agent creation" to="#Application.bugReportEmail#" from="ForceAgent@#Application.fromEmail#" type="html">
				#session.username# just force-created agent
				<a href="#Application.serverRootUrl#/agents.cfm?agent_id=#agentID.nextAgentId#">#preferred_agent_name#</a>.
				<p>
					That's probably a bad idea.
				</p>
			</cfmail>
		</cfif>
		<br>Agent created successfully.
		If you're seeing this something is broken so file a bug report!
		<script>
			parent.loadEditAgent(#agentID.nextAgentId#);
			parent.$(".ui-dialog-titlebar-close").addClass('obvious').trigger('click');
		</script>
	</cfoutput>
</cfif>