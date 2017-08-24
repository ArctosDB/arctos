<cfinclude template="/includes/_header.cfm">
<style>
	#pagewrapper {
		/* encloses tabled content */
		width: 100%;
		display: table;
	}
	#leftside, #maincell {
	    display: table-cell;
	}
	#divrow{
		display: table-row;
	}
	#leftside {
	    width:35%;
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
	function createAgent(type){
		var guts = "includes/forms/createagent.cfm?agent_type=" + type;
		$("<iframe src='" + guts + "' id='dialog' class='popupDialog' style='width:600px;height:600px;'></iframe>").dialog({
			autoOpen: true,
			closeOnEscape: true,
			height: 'auto',
			modal: true,
			position: ['center', 'center'],
			title: 'New Agent',
 			width:800,
  			height:600,
			close: function() {
				$( this ).remove();
			},
		}).width(800-10).height(600-10);
		$(window).resize(function() {
			$(".ui-dialog-content").dialog("option", "position", ['center', 'center']);
		});
		$(".ui-widget-overlay").click(function(){
		    $(".ui-dialog-titlebar-close").trigger('click');
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
<cfquery name="ctguid_prefix" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select guid_prefix from collection order by guid_prefix
</cfquery>
<cfoutput>
	<div id="pagewrapper">
		<div id="divrow">
			<div id="leftside">
				<div id="td_search">
					<form name="agntSearch" id="agntSearch">
						<fieldset class="compact">
							<label for="anyName" class="helpLink" data-helplink="agent_any_name_search">Any part of any name</label>
							<input type="text" name="anyName" id="anyName" class="minput" placeholder="this is the search box you're looking for">
							<div style="display:table;width:100%;">
								<div style="display:table-cell">
									<label for="agent_type">Agent Type</label>
									<select name="agent_type" size="1" id="agent_type">
										<option value=""></option>
										<cfloop query="ctagent_type">
											<option value="#agent_type#">#agent_type#</option>
										</cfloop>
									</select>
								</div>
								<div style="display:table-cell">
									<label for="agent_id">AgentID</label>
									<input type="number" name="agent_id" placeholder="agent_id">
								</div>
							</div>
							<div style="display:table;width:100%;">
								<div style="display:table-cell">
									<label for="agent_name_type">Agent Name Type</label>
									<select name="agent_name_type" size="1" id="agent_name_type">
										<option value=""></option>
										<cfloop query="ctagent_name_type">
											<option value="#agent_name_type#">#agent_name_type#</option>
										</cfloop>
									</select>
								</div>
								<div style="display:table-cell">
									<label for="agent_name">Agent Name</label>
									<input type="text" name="agent_name" id="agent_name" class="msinput" placeholder="non-preferred name">
								</div>
							</div>
							<div style="display:table;width:100%;">
								<div style="display:table-cell">
									<label for="agent_remark">Agent Remark</label>
									<input type="text" name="agent_remark" id="agent_remark" class="minput" placeholder="agent remark">
								</div>
							</div>
							<div style="display:table;width:100%;">
								<div style="display:table-cell">
								<label for="used_by_collection" class="helpLink" data-helplink="agent_used_collection_search">Used by Collection</label>
									<select name="used_by_collection" size="1" id="used_by_collection">
										<option value=""></option>
										<cfloop query="ctguid_prefix">
											<option value="#guid_prefix#">#guid_prefix#</option>
										</cfloop>
									</select>
								</div>
							</div>


						</fieldset>
						<fieldset class="compact">
							<label for="address">Address</label>
							<input type="text" name="address" id="address" class="minput" placeholder="any part of any address">
						</fieldset>
						<fieldset class="compact">
							<div style="display:table;width:100%;">
								<div style="display:table-cell">
									<label for="agent_status">Agent Status</label>
									<select name="agent_status" size="1" id="agent_status">
										<option value=""></option>
										<cfloop query="ctagent_status">
											<option value="#agent_status#">#agent_status#</option>
										</cfloop>
									</select>
								</div>
								<div style="display:table-cell">
									<label for="status_date_oper">Match</label>
									<select name="status_date_oper" size="1" id="status_date_oper">
										<option value="<=">Before</option>
										<option selected value="=" >At</option>
										<option value=">=">After</option>
									</select>
								</div>
								<div style="display:table-cell">
									<label for="status_date">Status Date</label>
									<input type="date" name="status_date" id="status_date" size="15" placeholder="status date">
								</div>
							</div>
						</fieldset>
						<fieldset class="compact">
							<div style="display:table;width:100%;">
								<div style="display:table-cell">
								<label for="created_by">Created By</label>
										<input type="text" name="created_by" id="created_by" class="sinput" placeholder="created by agent">
								</div>
								<div style="display:table-cell">
								<label for="create_date_oper">Match</label>
										<select name="create_date_oper" size="1" id="create_date_oper">
											<option value="<=">Before</option>
											<option selected value="=" >At</option>
											<option value=">=">After</option>
										</select>
								</div>
								<div style="display:table-cell">
								<label for="created_date">Created Date</label>
										<input type="datetime" name="created_date" id="created_date" size="15" placeholder="created date">
								</div>
							</div>
						</fieldset>
						<div style="display:table;width:100%;">
							<div style="display:table-cell;width:25%;">
								<input type="submit" value="Search" class="schBtn" id="goAgentSearch">
							</div>
							<div style="display:table-cell;width:25%;">
								<input type="reset" value="Clear Form" class="clrBtn">
							</div>
							<div style="display:table-cell;width:25%;">
								<input type="button" value="Create Person" class="insBtn" onClick="createAgent('person');">
							</div>
							<div style="display:table-cell;width:25%;">
								<input type="button" value="Create Agent" class="insBtn" onClick="createAgent();">
							</div>
						</div>
					</form>
				</div>
			 	<div id="agntRslCell"></div>
			</div><!---/leftside--->
			<div id="maincell">
				<div id="agntEditCell"></div>
			</div>
		</div><!-----divrow---->
	</div><!----pagewrapper---->
	</cfoutput>
<cfinclude template="/includes/_footer.cfm">