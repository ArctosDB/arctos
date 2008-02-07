<div id="theHead">
	<cfinclude template="includes/_header.cfm">
</div>
</div><!--- kill content div --->
<cfquery name="ctSuff" datasource="#Application.web_user#">
	select collection_cde from ctcollection_cde
</cfquery>
<cfquery name="ctinst" datasource="#Application.web_user#">
	select distinct(institution_acronym) as institution_acronym from collection
</cfquery>
<!--------------------------------------------------------------------------------->
<cfif #Action# is "nothing">
<cfoutput>
<cfquery name="getItems" datasource="#Application.web_user#">
	SELECT
		cataloged_item.collection_object_id,
		cat_num,
		accn_number,
		agent_name,
		coll_order,
		higher_geog,
		spec_locality,
		verbatim_date,
		scientific_name,
		collection.institution_acronym,
		trans.institution_acronym transInst,
		trans.transaction_id		
	FROM
		cataloged_item,
		accn,
		trans,
		collecting_event,
		locality,
		geog_auth_rec,
		collector,
		preferred_agent_name,
		identification,
		collection
	WHERE
		cataloged_item.accn_id = accn.transaction_id AND
		accn.transaction_id = trans.transaction_id AND
		cataloged_item.collection_object_id = collector.collection_object_id AND
		collector.agent_id = preferred_agent_name.agent_id AND
		collector_role='c' AND
		cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND
		cataloged_item.collection_id = collection.collection_id AND
		collecting_event.locality_id = locality.locality_id AND
		locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND
		cataloged_item.collection_object_id = identification.collection_object_id AND
		identification.accepted_id_fg = 1 AND
		cataloged_item.collection_object_id IN (#collection_object_id#)
	ORDER BY cataloged_item.collection_object_id
	</cfquery>
Add all the items listed below to accession:

	<table border="1">
	<form name="addItems" method="post" action="addAccn.cfm">
		<input type="hidden" name="collection_object_id" value="#collection_object_id#">
		<input type="hidden" name="Action" value="addItems">
	<tr>
		<td><font size="-1">Institution</font></td>
      <td><font size="-1">Accn Number</font></td>
	</tr>
	<tr>
		<td>
			<select name="institution_acronym" size="1">
				<cfloop query="ctinst">
					<option value="#institution_acronym#">#institution_acronym#</option>
				</cfloop>
			</select>
			
		</td>
		<td><input type="text" name="accn_number"></td>
	
	</tr>
	<tr>
		<td colspan="2"><input type="submit" value="Add Items"></td>
	</tr>	
</form>
<tr>

<td colspan="2">
<table border>
	<tr>
		<td>Cat Num</td>
		<td>Scientific Name</td>
		<td>Accn</td>
		<td>Collectors</td>
		<td>Geog</td>
		<td>Spec Loc</td>
		<td>Date</td>
		
	</tr>
	</cfoutput>
<cfoutput query="getItems" group="collection_object_id">
	<tr>
		<td>#cat_num#</td>
		<td>#scientific_name#</td>
		<td><a href="SpecimenResults.cfm?Accn_trans_id=#transaction_id#">#transInst# #Accn_number#</a></td>
		<td>
			<cfquery name="getAgent" dbtype="query">
				select agent_name, coll_order from getItems where collection_object_id = #getItems.collection_object_id#
				order by coll_order
			</cfquery>
			<cfset colls = "">
			<cfloop query="getAgent">
				<cfif len(#colls#) is 0>
					<cfset colls = #getAgent.agent_name#>
				  <cfelse>
				  	<cfset colls = "#colls#, #getAgent.agent_name#">
				</cfif>
			</cfloop>
		#colls#</td>
		<td>#higher_geog#</td>
		<td>#spec_locality#</td>
		<td>#verbatim_date#</td>
	</tr>
</cfoutput>
</table>
</td></tr>
</table>
</cfif>
<!--------------------------------------------------------------------------------->

<!--------------------------------------------------------------------------------->
<cfif #Action# is "addItems">
	<cfoutput>
		
		<cfquery name="accn" datasource="#Application.web_user#">
			SELECT accn.TRANSACTION_ID FROM accn,trans WHERE
			accn.TRANSACTION_ID=trans.TRANSACTION_ID AND
			accn_number = '#accn_number#' 
			and institution_acronym = '#institution_acronym#'			
		</cfquery>
		<cfif accn.recordcount is 1>
			<cftransaction>
			<cfloop list="#collection_object_id#" index="i">
				<cfquery name="upAccn" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
					UPDATE cataloged_item SET accn_id = #accn.transaction_id# where collection_object_id = #i#
				</cfquery>
			</cfloop>
			</cftransaction>
		<cfelse>
      <font color="##FF0000" size="+2">That accn was not found! 
	  SELECT accn.TRANSACTION_ID FROM accn,trans WHERE
			accn.TRANSACTION_ID=trans.TRANSACTION_ID AND
			accn_number = #accn_number# 
			and institution_acronym = '#institution_acronym#'		
      <cfabort>
		</cfif>
		
		<cflocation url="addAccn.cfm?collection_object_id=#collection_object_id#">
		
	</cfoutput>
</cfif>
<!--------------------------------------------------------------------------------->
<div id="theFoot">
	<cfinclude template="includes/_footer.cfm">
</div>
<cfoutput>
<script type="text/javascript" language="javascript">
	if (self != top) {
		changeStyle('#getItems.institution_acronym#');
		parent.dyniframesize();
		document.getElementById("theHead").style.display='none';
		document.getElementById("theFoot").style.display='none';
	}
</script>
</cfoutput>