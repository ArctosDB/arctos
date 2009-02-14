<cfinclude template="/includes/alwaysInclude.cfm">
<cfquery name="getColls" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT 
		agent_name, 
		collector_role,
		coll_order,
		collector.agent_id,
		institution_acronym
	FROM
		collector, 
		preferred_agent_name,
		cataloged_item,
		collection
	WHERE
		collector.collection_object_id = cataloged_item.collection_object_id and
		cataloged_item.collection_id=collection.collection_id AND
		collector.agent_id = preferred_agent_name.agent_id AND
		collector.collection_object_id = #collection_object_id#
	ORDER BY 
		collector_role, coll_order
</cfquery>

<cfoutput> <cfset i=1>

<table>
<cfloop query="getColls">
	<form name="colls#i#" method="post" action="editColls.cfm"  onSubmit="return gotAgentId(this.newagent_id.value)">
	<input type="hidden" name="collection_object_id" value="#collection_object_id#">
	<input type="hidden" name="Action" value="">
		 <tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	><td>
		Name: <input type="text" name="Name" value="#getColls.agent_name#" class="reqdClr" 
		onchange="getAgent('newagent_id','Name','colls#i#',this.value); return false;"
		 onKeyPress="return noenter(event);">
		
		<input type="hidden" name="newagent_id">
		<input type="hidden" name="oldagent_id" value="#agent_id#">
		
                  Role: 
				  <input type="hidden" name="oldRole" value="#getColls.collector_role#">
                  <select name="collector_role" size="1"  class="reqdClr">
					<option <cfif #getColls.collector_role# is 'c'> selected </cfif>value="c">collector</option>
					<option <cfif #getColls.collector_role# is 'p'> selected </cfif>value="p">preparator</option>
				</select>
		Order: 
			 <input type="hidden" name="oldOrder" value="#getColls.coll_order#">
			<select name="coll_order" size="1" class="reqdClr">
				<cfset thisLoop =#getColls.recordcount# +1>
				<cfloop from="1" index="c" to="#thisLoop#">
					<option 
						<cfif #c# is #getColls.coll_order#> selected </cfif>value="#c#">#c#</option>
					
				</cfloop>
			</select>
		
              <input type="button" 
	value="Save" 
	class="savBtn"
   	onmouseover="this.className='savBtn btnhov'" 
   	onmouseout="this.className='savBtn'"
	onclick="colls#i#.Action.value='saveEdits';submit();">	

                 <input type="button" value="Delete" class="delBtn"
   onmouseover="this.className='delBtn btnhov'" onmouseout="this.className='delBtn'" onClick="colls#i#.Action.value='deleteColl';confirmDelete('colls#i#');">	
   
		</td></tr>
	</form>
	<cfset i = #i#+1>
</cfloop>
</table>
<table class="newRec">
	<tr>
		<td><strong>Add an Agent:</strong></td>
	</tr>
	<tr>
		<td><form name="newColl" method="post" action="editColls.cfm"  onSubmit="return gotAgentId(this.newagent_id.value)">
	<input type="hidden" name="collection_object_id" value="#collection_object_id#">
	<input type="hidden" name="Action" value="newColl">
		
		Name: <input type="text" name="name" class="reqdClr"
		onchange="getAgent('newagent_id','name','newColl',this.value); return false;"
		 onKeyPress="return noenter(event);">
		<input type="hidden" name="newagent_id">
		
	
         Role: 
          <select name="collector_role" size="1" class="reqdClr">
					<option value="c">collector</option>
					<option value="p">preparator</option>
					
				</select>
		Order: 
			<select name="coll_order" size="1" class="reqdClr">
				<cfset thisLoop = #getColls.recordcount# +1>
				<cfloop from="1" index="c" to="#thisLoop#">
					<option <cfif #c# is #thisLoop#> selected </cfif>
						value="#c#">#c#</option>
					
				</cfloop>
			</select>
			
		<input type="submit" value="Create" class="insBtn"
   onmouseover="this.className='insBtn btnhov'" onmouseout="this.className='insBtn'">
         
        </form></td>
	</tr>
</table>
<p>

</cfoutput> 
<!------------------------------------------------------------------------------------->
<cfif #Action# is "saveEdits">
<cfoutput>
	<cfquery name="upColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
	<cf_logEdit collection_object_id="#collection_object_id#">
<cf_ActivityLog sql="UPDATE collector SET
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
		agent_id=#oldAgent_id#">
		<cflocation url="editColls.cfm?collection_object_id=#collection_object_id#">
</cfoutput>	
</cfif>
<!------------------------------------------------------------------------------------->
<cfif #Action# is "newColl">
<cfoutput>

	<cfquery name="newColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	INSERT INTO collector (
		collection_object_id, agent_id, collector_role,coll_order)
	VALUES (#collection_object_id#, #newagent_id#,'#collector_role#',#coll_order#)
	</cfquery>
	<cf_ActivityLog sql="INSERT INTO collector (
		collection_object_id, agent_id, collector_role,coll_order)
	VALUES (#collection_object_id#, #newagent_id#,'#collector_role#',#coll_order#)">
	
	<cf_logEdit collection_object_id="#collection_object_id#">
	
	<cflocation url="editColls.cfm?collection_object_id=#collection_object_id#">
</cfoutput>	
</cfif>
<!------------------------------------------------------------------------------------->
<cfif #Action# is "deleteColl">
<cfoutput>
	<cfquery name="deleColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	DELETE FROM  collector WHERE 
		collection_object_id = #collection_object_id# AND
		agent_id = #oldagent_id#
		AND collector_role='#collector_role#'
	</cfquery>
	<cf_logEdit collection_object_id="#collection_object_id#">
	<cf_ActivityLog sql="DELETE FROM  collector WHERE 
		collection_object_id = #collection_object_id# AND
		agent_id = #oldagent_id#
		AND collector_role='#collector_role#'">
		<cflocation url="editColls.cfm?collection_object_id=#collection_object_id#">
</cfoutput>	
</cfif>
<!------------------------------------------------------------------------------------->

<cfoutput>
<script type="text/javascript" language="javascript">
		changeStyle('#getColls.institution_acronym#');
		parent.dyniframesize();
</script>
</cfoutput>

