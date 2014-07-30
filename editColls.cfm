<cfinclude template="/includes/alwaysInclude.cfm">
<cfif action is "nothing">
	<style>
		.dragger {
			cursor:move;
		}
	</style>
	<cfquery name="ctcollector_role" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select collector_role from ctcollector_role order by collector_role
	</cfquery>
	<cfquery name="getColls" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		SELECT 
			agent_name, 
			collector_role,
			coll_order,
			collector.agent_id,
			collector_id
		FROM
			collector, 
			preferred_agent_name
		WHERE
			collector.collection_object_id = #collection_object_id# and
			collector.agent_id = preferred_agent_name.agent_id 
		ORDER BY 
			coll_order
	</cfquery>
	<script>
		function deleteThis(i){
			$("#name_" + i).val('DELETE');
			$("#agent_id_" + i).val('');
		}
		jQuery(document).ready(function() {
			$( "#colls" ).submit(function( event ) {
				var linkOrderData=$("#sortable").sortable('toArray').join(',');
				$( "#roworder" ).val(linkOrderData);
				return true;
			});
		});
		$(function() {
			$( "#sortable" ).sortable({
				handle: '.dragger'
			});
		});
	</script>
	<cfoutput>
		<cfset i=1>
		<form name="colls" id="colls" method="post" action="editColls.cfm" >
			<input type="hidden" name="collection_object_id" value="#collection_object_id#">
			<input type="hidden" name="action" value="saveEdits">
			<input type="hidden" name="roworder" id="roworder" value="">
			<table id="clastbl" border="1">
				<thead>
					<tr>
						<th>Drag To Order</th>
						<th>Agent</th>
						<th>Role</th>
						<th></th>
					</tr>
				</thead>
				<tbody id="sortable">
					<cfloop query="getColls">
						<input type="hidden" name="collector_id_#i#" value="#collector_id#">
						<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))# id="row_#i#">
							<td class="dragger">
								(drag row here)
							</td>
							<td>
								<input type="text" name="name_#i#" id="name_#i#" value="#getColls.agent_name#" class="reqdClr" 
									onchange="getAgent('agent_id_#i#','name_#i#','colls',this.value); return false;"
							 		onKeyPress="return noenter(event);">
								<input type="hidden" name="agent_id_#i#" id="agent_id_#i#" value="#getColls.agent_id#">
							</td>
							<td>
								 <select name="collector_role_#i#" id="collector_role_#i#" size="1"  class="reqdClr">
								 	<cfloop query="ctcollector_role">
								 		<option <cfif getColls.collector_role is ctcollector_role.collector_role> selected="selected" </cfif>
								 			value="#ctcollector_role.collector_role#">#ctcollector_role.collector_role#</option>
								 	</cfloop>
								</select>
							</td>
							<td>
								<input type="button" class="delBtn" value="delete" onclick="deleteThis('#i#');">
							</td>
						</tr>
						<cfset i = i+1>
					</cfloop>
					<tr class="newRec" id="row_new1">
						<td class="dragger">
							(drag row here)
						</td>
						<td>
							<input type="hidden" name="collector_id_new1" value="new">
							<input type="text" name="name_new1" id="name_new1" value="" class="" 
								placeholder="Add an Agent"
								onchange="getAgent('agent_id_new1','name_new1','colls',this.value); return false;"
						 		onKeyPress="return noenter(event);">
							<input type="hidden" name="agent_id_new1" id="agent_id_new1">
						</td>
						<td>
							 <select name="collector_role_new1" id="collector_role_new1" size="1"  class="reqdClr">
							 	<cfloop query="ctcollector_role">
							 		<option	value="#ctcollector_role.collector_role#">#ctcollector_role.collector_role#</option>
							 	</cfloop>
							</select>
						</td>
						<td>
							<input type="button" class="delBtn" value="delete" onclick="deleteThis('new1');">
						</td>
					</tr>
					<tr class="newRec" id="row_new2">
						<td class="dragger">
							(drag row here)
						</td>
						<td>
							<input type="hidden" name="collector_id_new2" value="new">
							<input type="text" name="name_new2" id="name_new2" value="" class="" 
								placeholder="Add an Agent"
								onchange="getAgent('agent_id_new2','name_new2','colls',this.value); return false;"
						 		onKeyPress="return noenter(event);">
							<input type="hidden" name="agent_id_new2" id="agent_id_new2">
						</td>
						<td>
							 <select name="collector_role_new2" id="collector_role_new2" size="1"  class="reqdClr">
							 	<cfloop query="ctcollector_role">
							 		<option	value="#ctcollector_role.collector_role#">#ctcollector_role.collector_role#</option>
							 	</cfloop>
							</select>
						</td>
						<td>
							<input type="button" class="delBtn" value="delete" onclick="deleteThis('new2');">
						</td>
					</tr>
					<tr class="newRec" id="row_new3">
						<td class="dragger">
							(drag row here)
						</td>
						<td>
							<input type="hidden" name="collector_id_new3" value="new">
							<input type="text" name="name_new3" id="name_new3" value="" class="" 
								placeholder="Add an Agent"
								onchange="getAgent('agent_id_new3','name_new3','colls',this.value); return false;"
						 		onKeyPress="return noenter(event);">
							<input type="hidden" name="agent_id_new3" id="agent_id_new3">
						</td>
						<td>
							 <select name="collector_role_new3" id="collector_role_new3" size="1"  class="reqdClr">
							 	<cfloop query="ctcollector_role">
							 		<option	value="#ctcollector_role.collector_role#">#ctcollector_role.collector_role#</option>
							 	</cfloop>
							</select>
						</td>
						<td>
							<input type="button" class="delBtn" value="delete" onclick="deleteThis('new3');">
						</td>
					</tr>				
				</tbody>
			</table>
			<br>
			<input type="submit" value="Save" class="savBtn">	
		</form>	
	</cfoutput> 
</cfif>
<!------------------------------------------------------------------------------------->
<cfif action is "saveEdits">
	<cfoutput>
		<cfset agntOrdr=1>
		<cftransaction>
			<cfquery name="killall" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				delete from 
					collector
				where
					collection_object_id=#collection_object_id#
			</cfquery>
			<cfloop list="#ROWORDER#" index="i">
				<cfset thisID=replacenocase(i,'row_','','all')>
				<cfset thisName=evaluate("NAME_" & thisID)>
				<cfset thisAgentID=evaluate("AGENT_ID_" & thisID)>
				<cfset thisRole=evaluate("COLLECTOR_ROLE_" & thisID)>
				<cfset thisCollectorID=evaluate("COLLECTOR_ID_" & thisID)>
				<cfif len(thisAgentID) gt 0>
					<cfquery name="nc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						insert into collector (
							collector_id,
							collection_object_id,
							agent_id,
							collector_role,
							coll_order
						) values (
							sq_collector_id.nextval,
							#collection_object_id#,
							#thisAgentID#,
							'#thisRole#',
							#agntOrdr#
						)
					</cfquery>
					<cfset agntOrdr=agntOrdr+1>
				</cfif>
			</cfloop>
		</cftransaction>
		<cflocation url="editColls.cfm?collection_object_id=#collection_object_id#">
	</cfoutput>	
</cfif>
<cf_customizeIFrame>