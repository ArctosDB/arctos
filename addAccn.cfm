<cfinclude template="includes/_header.cfm">
<cfquery name="ctcoll" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select collection, collection_id from collection order by collection
</cfquery>
<!--------------------------------------------------------------------------------->
<cfif action is "nothing">
	<script>
		function getit(){
			var a = $('#accn_number').val();
			var c = $('#collection_id').val();
			getAccn2(a, c);
		}
	</script>
<cfoutput>
	
<cfquery name="getItems" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	SELECT
		accn.ACCN_NUMBER,
		flat.collection_object_id,
		flat.guid,
		flat.collectors,
		flat.higher_geog,
		flat.spec_locality,
		flat.verbatim_date,
		flat.scientific_name,
		collection.collection,
		accn.transaction_id,
		collection.collection_id
	FROM
		flat,
		cataloged_item,
		accn,
		trans,
		collection
		<cfif (not isdefined("collection_object_id")) or (isdefined("collection_object_id") and listlen(collection_object_id) gt 1) or len(collection_object_id) is 0>
			,#session.username#.#session.SpecSrchTab#
		</cfif>
	WHERE
		flat.collection_object_id=cataloged_item.collection_object_id and
		cataloged_item.accn_id = accn.transaction_id AND
		accn.transaction_id = trans.transaction_id AND
		trans.collection_id=collection.collection_id and
		flat.collection_object_id = 
		<cfif isdefined("collection_object_id") and listlen(collection_object_id) is 1>
			#collection_object_id#
		<cfelse>
			#session.username#.#session.SpecSrchTab#.collection_object_id
		</cfif>
	ORDER BY flat.collection_object_id
	</cfquery>
	Add all the items listed below to accession:
	<form name="addItems" method="post" action="addAccn.cfm">
		<input type="hidden" name="Action" value="addItems">
		<cfif isdefined("collection_object_id") and listlen(collection_object_id) is 1>
			<input type="hidden" name="collection_object_id" value="#collection_object_id#">
		</cfif>
		<label for="tCtl">Find Accession</label>
		<table border="1" id="tCtl">
			<tr>
				<td>
					<label for="collection_id">Collection</label>
					<select name="collection_id" id="collection_id" size="1">
						<cfloop query="ctcoll">
							<option <cfif ctcoll.collection_id is getItems.collection_id> selected="selected" </cfif>value="#collection_id#">#collection#</option>
						</cfloop>
					</select>
				</td>
				<td>
					<label for="accn_number">Accession</label>
					<input type="text" name="accn_number" id="accn_number" onchange="getit();">
				</td>
     			<td>
					<input type="submit" id="s_btn" value="Add Items" class="savBtn">
				</td>
			</tr>
		</table>	
	</form>
	<label for="tSpc">Specimens being reaccessioned</label>
<table border id="tSpc">
	<tr>
		<td>GUID</td>
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
		<td>#guid#</td>
		<td>#scientific_name#</td>
		<td><a href="/SpecimenResults.cfm?Accn_trans_id=#transaction_id#" target="_top">#collection# #Accn_number#</a></td>
		<td>#collectors#</td>
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
		
		<cfquery name="accn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT 
				accn.TRANSACTION_ID 
			FROM 
				accn,
				trans 
			WHERE
				accn.TRANSACTION_ID=trans.TRANSACTION_ID AND
				accn_number = '#accn_number#' 
				and collection_id = #collection_id#			
		</cfquery>
		<cfif accn.recordcount is 1 and len(accn.transaction_id) gt 0>
			<cftransaction>
				<cfquery name="upAccn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					UPDATE cataloged_item SET accn_id = #accn.transaction_id# where collection_object_id  in (
					<cfif isdefined("collection_object_id") and listlen(collection_object_id) is 1>
						#collection_object_id#
					<cfelse>
						select collection_object_id from #session.username#.#session.SpecSrchTab#
					</cfif>
					) 
				</cfquery>
			</cftransaction>
		<cfelse>
		     <div class="error">
		      	Not one match - aborting.... 
			 	<cfdump var=#accn#>
			 </div>
			<cfabort>
		</cfif>
		
		<cfif isdefined("collection_object_id") and listlen(collection_object_id) is 1>
			<cflocation url="addAccn.cfm?collection_object_id=#collection_object_id#" addtoken="false">
		<cfelse>
			<cflocation url="addAccn.cfm" addtoken="false">
		</cfif>
		
		
		
	</cfoutput>
</cfif>
<!--------------------------------------------------------------------------------->
<cfinclude template="includes/_footer.cfm">
<cf_customizeIFrame>