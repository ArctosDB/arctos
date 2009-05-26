<cfinclude template="/includes/_header.cfm">
<!--------------------------------------------------------------------------------------------------->
<cfif #Action# is "nothing">
<cfset title = "Edit Collectors">
<cfoutput> 
	<cfquery name="getColls" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT 
		 	cataloged_item.collection_object_id as collection_object_id, 
			cataloged_item.cat_num,
			concatSingleOtherId(cataloged_item.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID,
			identification.scientific_name,
			geog_auth_rec.country,
			geog_auth_rec.state_prov,
			geog_auth_rec.county,
			geog_auth_rec.quad,
			collection.collection,
			CONCATPREP(cataloged_item.collection_object_id) preps,
			concatColl(cataloged_item.collection_object_id) colls
		FROM 
			identification, 
			collecting_event,
			locality,
			geog_auth_rec,
			cataloged_item,
			collection
		WHERE 
			locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id 
			AND collecting_event.locality_id = locality.locality_id 
			AND cataloged_item.collecting_event_id = collecting_event.collecting_event_id 
			AND cataloged_item.collection_object_id = identification.collection_object_id 
			and accepted_id_fg=1
			AND cataloged_item.collection_id = collection.collection_id
			AND cataloged_item.collection_object_id IN (#collection_object_id#)
		ORDER BY 
			cataloged_item.collection_object_id
	</cfquery>
	<h2>
		Add/Remove collectors for all specimens listed below
	</h2>
	Pick an agent, a role, and an order to insert or delete an agent for all records listed below. 
	<br>Order is ignored for deletion.
	<br>
  	<form name="tweakColls" method="post" action="multiAgent.cfm">
		<input type="hidden" name="collection_object_id" value="#collection_object_id#">
		<input type="hidden" name="action" value="">
		<label for="name">Name</label>
		<input type="text" name="name" class="reqdClr" 
			onchange="getAgent('agent_id','name','tweakColls',this.value); return false;"
		 	onKeyPress="return noenter(event);">
		<input type="hidden" name="agent_id">
		<label for="collector_role">Role</label>		
        <select name="collector_role" size="1"  class="reqdClr">
			<option value="c">collector</option>
			<option value="p">preparator</option>
		</select>
		<label for="coll_order">Order</label>
		<select name="coll_order" size="1" class="reqdClr">
			<option value="first">First</option>
			<option value="last">Last</option>
		</select>         
		<input type="button" 
			value="Insert Agent" 
			class="insBtn"
   			onclick="tweakColls.action.value='insertColl';submit();">
		<input type="button" 
			value="Remove Agent" 
			class="delBtn"
   			onclick="tweakColls.action.value='deleteColl';submit();">
	</form>
		
		
  
<br><b>Specimens:</b>

<table border="1">
<tr>
	<th>Catalog Number</th>
	<th>#session.CustomOtherIdentifier#</th>
	<th>Accepted Scientific Name</th>
	<th>Collectors</th>
	<th>Preparators</th>
	<th>Country</th>
	<th>State</th>
	<th>County</th>
	<th>Quad</th>
</tr>
<cfloop query="getColls">
    <tr>
	  <td>
	  	#collection#&nbsp;#cat_num#
	  </td>
	<td>
		#CustomID#&nbsp;
	</td>
	<td><i>#Scientific_Name#</i></td>
	<td>#colls#</td>
	<td>#preps#</td>
	<td>#Country#&nbsp;</td>
	<td>#State_Prov#&nbsp;</td>
	<td>
		#county#&nbsp;
	</td>
	<td>
		#quad#&nbsp;
	</td>
</tr>
</cfloop>
</table>
</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------->
<cfif #Action# is "insertColl">
insertColl
<cfdump var="form">
</cfif>
<!----------------------------------------------------------------------------------->
<cfif #Action# is "deleteColl">
deleteColl
<cfdump var="form">
</cfif>
<!----------------------------------------------------------------------------------->
<cfinclude template="includes/_footer.cfm">