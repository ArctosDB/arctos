<div id="theHead">
	<cfinclude template="includes/_header.cfm">
</div>
<cfquery name="ctcoll" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select collection, collection_id from collection order by collection
</cfquery>
<!--------------------------------------------------------------------------------->
<cfif #Action# is "nothing">
<cfoutput>
<cfquery name="getItems" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT
		cataloged_item.collection_object_id,
		cataloged_item.cat_num,
		accn.accn_number,
		preferred_agent_name.agent_name,
		collector.coll_order,
		geog_auth_rec.higher_geog,
		locality.spec_locality,
		collecting_event.verbatim_date,
		identification.scientific_name,
		collection.institution_acronym,
		trans.institution_acronym transInst,
		trans.transaction_id,
		collection.collection,
		a_coll.collection accnColln
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
		collection,
		collection a_coll,
		#session.SpecSrchTab#
	WHERE
		cataloged_item.accn_id = accn.transaction_id AND
		accn.transaction_id = trans.transaction_id AND
		trans.collection_id=a_coll.collection_id and
		cataloged_item.collection_object_id = collector.collection_object_id AND
		collector.agent_id = preferred_agent_name.agent_id AND
		collector_role='c' AND
		cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND
		cataloged_item.collection_id = collection.collection_id AND
		collecting_event.locality_id = locality.locality_id AND
		locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND
		cataloged_item.collection_object_id = identification.collection_object_id AND
		identification.accepted_id_fg = 1 AND
		cataloged_item.collection_object_id = #session.SpecSrchTab#.collection_object_id
	ORDER BY cataloged_item.collection_object_id
	</cfquery>
	Add all the items listed below to accession:
	<form name="addItems" method="post" action="addAccn.cfm">
		<input type="hidden" name="Action" value="addItems">
		<table border="1">
			<tr>
				<td>
					<label for="collection_id">Collection</label>
					<select name="collection_id" id="collection_id" size="1" onchange="findAccession();">
						<cfloop query="ctcoll">
							<option value="#collection_id#">#collection#</option>
						</cfloop>
					</select>
				</td>
				<td>
					<label for="accn_number">Accession</label>
					<input type="text" name="accn_number" id="accn_number" onchange="findAccession();">
				</td>
				<td>
					<input type="button" id="a_lkup" value="lookup" class="lnkBtn" onclick="findAccession();">
				</td>
     			<td>
					<div id="g_num" class="noShow">
						<input type="submit" id="s_btn" value="Add Items" class="savBtn">
					</div>
					<div id="b_num">
						Pick a valid Accession
					</div>
					
				</td>
			</tr>
		</table>	
	</form>
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
		<td>#collection# #cat_num#</td>
		<td>#scientific_name#</td>
		<td><a href="SpecimenResults.cfm?Accn_trans_id=#transaction_id#">#accnColln# #Accn_number#</a></td>
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
</cfif>
<!--------------------------------------------------------------------------------->

<!--------------------------------------------------------------------------------->
<cfif #Action# is "addItems">
	<cfoutput>
		
		<cfquery name="accn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT accn.TRANSACTION_ID FROM accn,trans WHERE
			accn.TRANSACTION_ID=trans.TRANSACTION_ID AND
			accn_number = '#accn_number#' 
			and collection_id = #collection_id#			
		</cfquery>
		<cfif accn.recordcount is 1 and accn.transaction_id gt 0>
			<cftransaction>
				<cfquery name="upAccn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					UPDATE cataloged_item SET accn_id = #accn.transaction_id# where collection_object_id  in (
						select collection_object_id from #session.SpecSrchTab#) 
				</cfquery>
			</cftransaction>
		<cfelse>
      <font color="##FF0000" size="+2">That accn was not found! 
	 SELECT accn.TRANSACTION_ID FROM accn,trans WHERE
			accn.TRANSACTION_ID=trans.TRANSACTION_ID AND
			accn_number = '#accn_number#' 
			and collection_id = '#collection_id#'	
      <cfabort>
		</cfif>
		
		<cflocation url="addAccn.cfm" addtoken="false">
		
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