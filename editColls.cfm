<cfinclude template="/includes/alwaysInclude.cfm">
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
		collector_role, coll_order
</cfquery>
<script>
	function deleteThis(i){
		$("#name_" + i).val('DELETE');
		$("#agent_id_" + i).val('DELETE');
	}
	jQuery(document).ready(function() {
		$( "#colls" ).submit(function( event ) {
	
		console.log('I am submitting now....');
	
	
			//event.preventDefault();
			var linkOrderData=$("#sortable").sortable('toArray').join(',');
	
			console.log(linkOrderData);
	
	
			$( "#roworder" ).val(linkOrderData);
		//	var nccellary = new Array();
		//	$.each($("tr[id^='nccell_']"), function() {
		//		nccellary.push(this.id);
		//    });
		//	var ncls=nccellary.join(',');
		//	$( "#noclassrows" ).val(ncls);
			//$( "#colls" ).submit();

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
					<th>Ctl</th>
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
							<input type="hidden" name="agent_id_#i#" id="agent_id_#i#">
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
			</tbody>
		</table>
		<br>
		<input type="submit" value="Save" class="savBtn">	
		</form>	
			   
			
		
	

</cfoutput> 
<!------------------------------------------------------------------------------------->
<cfif action is "saveEdits">
<cfoutput>

<cfdump var=#form#>
<!--------
	<cfquery name="upColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	UPDATE collector SET
		<cfif len(#newagent_id#) gt 0>
			agent_id = #newagent_id#
		<cfelse>
			agent_id = #oldAgent_id#
		</cfif>
		,collector_role='#collector_role#'
		,coll_order=#coll_order#
		where
		collection_object_id = #collection_object_id# and
		collector_role = '#oldRole#' AND
		coll_order=#oldOrder# AND
		agent_id=#oldAgent_id#
		</cfquery>
		<cflocation url="editColls.cfm?collection_object_id=#collection_object_id#">
		------------>
</cfoutput>	
</cfif>
<!------------------------------------------------------------------------------------->
<cfif #Action# is "newColl">
<cfoutput>

	<cfquery name="newColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	INSERT INTO collector (
		collection_object_id, agent_id, collector_role,coll_order)
	VALUES (#collection_object_id#, #newagent_id#,'#collector_role#',#coll_order#)
	</cfquery>
	<cflocation url="editColls.cfm?collection_object_id=#collection_object_id#">
</cfoutput>	
</cfif>
<!------------------------------------------------------------------------------------->
<cfif #Action# is "deleteColl">
<cfoutput>
	<cfquery name="deleColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	DELETE FROM  collector WHERE 
		collection_object_id = #collection_object_id# AND
		agent_id = #oldagent_id#
		AND collector_role='#collector_role#'
	</cfquery>
		<cflocation url="editColls.cfm?collection_object_id=#collection_object_id#">
</cfoutput>	
</cfif>
<!------------------------------------------------------------------------------------->
<cf_customizeIFrame>