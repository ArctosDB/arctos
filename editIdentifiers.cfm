<cfinclude template="/includes/alwaysInclude.cfm">
<cfset title = "Edit Identifiers">
<cfif action is "nothing">
	<script>
		function cloneCatalogedItem(collection_object_id){
			jQuery('#cloned').css("display", "inline").html('<img src="/images/indicator.gif">Creating clone(s) - hold tight.....');
			jQuery.getJSON("/component/functions.cfc",
				{
					method : "cloneCatalogedItem",
					collection_object_id : collection_object_id,
					numRecs: $("#numRecs").val(),
					refType: $("#refType").val(),
					taxon_name: $("#taxon_name").val(),
					collection_id: $("#collection_id").val(),
					returnformat : "json",
					queryformat : 'column'
				},
				function (r) {
					if (r == 'spiffy') {
						var q='created ' + $("#numRecs").val() + ' clones in bulkloader.';
					} else {
						var q='cloning failed.';
					}
					jQuery('#cloned').css("display", "inline").html(q);
				}
			);
		}
	</script>
	<cfoutput>

	<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select collection,collection_id from collection ORDER BY COLLECTION
	</cfquery>
	<cfquery name="ctid_references" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select id_references from ctid_references order by id_references
	</cfquery>
	<cfquery name="thisrec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			scientific_name,
			collection_id,
			collection
		from
			flat
		where
			collection_object_id=#collection_object_id#
	</cfquery>
	<span class="likeLink" onclick="document.getElementById('cThis').style.display='block';">[ Clone This Record ]</span>
	<div id="cThis" style="display:none; border:2px solid green;">
		Data from this cataloged item will be inserted into the Bulkloader, where you
		may further edit the record or flag it to load, as with any other new record.
		<br>Check specimen remarks in the bulkloader for things that might have been missed - this
		application has limited handling of agents, identifiers, attributes, and parts.
		<br>
		This might take a minute.
		Don't get all clicky or you'll make a mess.
		<br>Create
		<form name="clone">
			<label for="numRecs">Number of new records</label>
			<select name="numRecs" id="numRecs">
				<cfloop from="1" to="1000" index="i">
					<option value="#i#">#i#</option>
				</cfloop>
			</select>
			<label for="refType">relationship (id_references in bulkloader) to this record</label>
			<select name="refType" id="refType" size="1">
				<option value="">-pick one-</option>
				<cfloop query="ctid_references">
					<option value="#ctid_references.id_references#">#ctid_references.id_references#</option>
				</cfloop>
			</select>
			<input type="hidden" name="nothing">
			<label for="taxon_name">as taxon name</label>
			<input type="text" name="taxon_name"class="reqdClr" size="40" id="taxon_name" value="#thisRec.scientific_name#" onchange="taxaPick('nothing',this.id,'clone',this.value)">
			 <label for="collection_id">in collection</label>
			<select name="collection_id" id="collection_id">
				<cfloop query="c">
					<option <cfif c.collection_id is thisrec.collection_id> selected="selected" </cfif>value="#collection_id#">#collection#</option>
				</cfloop>
			</select>
			<br><input type="button" onclick="cloneCatalogedItem(#collection_object_id#)" value="Create Clone" class="insBtn">
		</form>
	</div>
	<br>
	<div id="cloned" style="display:none" class="redBorder"></div>
<cfquery name="getIDs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select
		COLL_OBJ_OTHER_ID_NUM_ID,
		cat_num,
		other_id_prefix,
		other_id_number,
		other_id_suffix,
		other_id_type,
		cataloged_item.collection_id,
		id_references,
		guid_prefix,
		coll_obj_other_id_num_id
	from
		cataloged_item,
		coll_obj_other_id_num,
		collection
	where
		cataloged_item.collection_id=collection.collection_id and
		cataloged_item.collection_object_id=coll_obj_other_id_num.collection_object_id (+) and
		cataloged_item.collection_object_id=#collection_object_id#
</cfquery>
<cfquery name="ctType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select other_id_type from ctcoll_other_id_type order by other_id_type
</cfquery>
<cfquery name="cat" dbtype="query">
	select
		cat_num,
		guid_prefix,
		collection_id
	from
		getIDs
	group by
		cat_num,
		guid_prefix,
		collection_id
</cfquery>

<cfquery name="oids" dbtype="query">
	select
		COLL_OBJ_OTHER_ID_NUM_ID,
		other_id_prefix,
		other_id_number,
		other_id_suffix,
		other_id_type,
		id_references,
		coll_obj_other_id_num_id
	from
		getIDs
	group by
		COLL_OBJ_OTHER_ID_NUM_ID,
		other_id_prefix,
		other_id_number,
		other_id_suffix,
		other_id_type,
		id_references,
		coll_obj_other_id_num_id
</cfquery>
	<h3>Identifiers</h3>
<b>Edit existing Identifiers:
<form name="ids" method="post" action="editIdentifiers.cfm">
	<input type="hidden" name="collection_object_id" value="#collection_object_id#">
	<input type="hidden" name="Action" value="saveEdits">
	<cfset i=1>
	<table>
		<tr>
			<th>
				ID Type
		 		<span class="infoLink" onClick="getCtDoc('ctcoll_other_id_type','')">[ define ]</span>
			</th>
			<th>Prefix or String</th>
			<th>ID Number (int)</th>
			<th>Suffix</th>
			<th>
				Relationship
				<span class="infoLink" onClick="getCtDoc('ctid_references','')">[ define ]</span>
			</th>
			<th>Delete</th>
		</tr>
		<tr #iif(i MOD 2,DE("class='oddRow'"),DE("class='evenRow'"))#>
			<td>Catalog Number</td>
			<td>#cat.guid_prefix#:</td>
			<input type="hidden" name="oldcat_num" value="#cat.cat_num#">
			<td><input type="text" name="cat_num" value="#cat.cat_num#" size="12" class="reqdClr"></td>
	 		<td>
		 		<span class="infoLink"onClick="window.open('/tools/findGap.cfm','','width=400,height=338, resizable,scrollbars');">[ find gaps ]</span>
			</td>
		 	<td>self</td>
		 </tr>
		<cfloop query="oids">
			<input type="hidden" name="coll_obj_other_id_num_id_#i#" value="#coll_obj_other_id_num_id#">
			 <tr #iif(i MOD 2,DE("class='oddRow'"),DE("class='evenRow'"))#>
				 <td>
					<select name="other_id_type_#i#" id="other_id_type_#i#" size="1">
						<cfloop query="ctType">
							<option	<cfif ctType.other_id_type is oids.other_id_type> selected="selected" </cfif>
								value="#ctType.other_id_type#">#ctType.other_id_type#</option>
						</cfloop>
					</select>
				</td>
				<td>
					<input type="text" value="#oids.other_id_prefix#" size="12" name="other_id_prefix_#i#">
				</td>
				<td>
					<input type="text" value="#oids.other_id_number#" size="12" name="other_id_number_#i#">
				</td>
				<td>
					<input type="text" value="#oids.other_id_suffix#" size="12" name="other_id_suffix_#i#">
				</td>
				<td>
					<select name="id_references_#i#" id="id_references_#i#" size="1">
						<cfloop query="ctid_references">
							<option	<cfif ctid_references.id_references is oids.id_references> selected="selected" </cfif>
								value="#ctid_references.id_references#">#ctid_references.id_references#</option>
						</cfloop>
					</select>
				</td>
				<td>
					<input type="checkbox" id="delete_#i#" name="delete_#i#" value="1">
				</td>
			</tr>
			<cfset i=i+1>
		</cfloop>
		<cfset nid=i-1>
		<input type="hidden" value="#nid#" name="numberOfIDs" id="numberOfIDs">
	</table>
	<input type="submit" value="Save Changes" class="savBtn">
</form>
<b>Add New Identifier:</b>
<form name="newOID" method="post" action="editIdentifiers.cfm">
	<input type="hidden" name="collection_object_id" value="#collection_object_id#">
	<input type="hidden" name="Action" value="newOID">
	<table class="newRec">
		<tr>
			<td>
				<select name="other_id_type" id="other_id_type" size="1">
					<cfloop query="ctType">
						<option	value="#ctType.other_id_type#">#ctType.other_id_type#</option>
					</cfloop>
				</select>
			</td>
			<td>
				<input type="text" size="12" name="other_id_prefix">
			</td>
			<td>
				<input type="text" size="12" name="other_id_number">
			</td>
			<td>
				<input type="text" size="12" name="other_id_suffix">
			</td>
			<td>
				<select name="id_references" id="id_references" size="1">
					<cfloop query="ctid_references">
						<option	<cfif ctid_references.id_references is 'self'> selected="selected" </cfif>
								value="#ctid_references.id_references#">#ctid_references.id_references#</option>
					</cfloop>
				</select>
			</td>
		</tr>
	</table>
	<input type="submit" value="Insert" class="insBtn">
</form>
</cfoutput>
</cfif>
<!-------------------------------------------------------->
<cfif action is "saveEdits">
<cfoutput>
	<cftransaction>
		<!--- save an update if possible --->
		<cfif oldcat_num is not cat_num>
			<cfquery name="upCat" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				UPDATE cataloged_item SET
					cat_num = '#cat_num#'
				WHERE collection_object_id=#collection_object_id#
			</cfquery>
		</cfif>

		<cfloop from="1" to="#numberOfIDs#" index="n">
			<cfset thisCOLL_OBJ_OTHER_ID_NUM_ID = evaluate("COLL_OBJ_OTHER_ID_NUM_ID_" & n)>
			<cfset thisID_REFERENCES = evaluate("ID_REFERENCES_" & n)>
			<cfset thisOTHER_ID_NUMBER = evaluate("OTHER_ID_NUMBER_" & n)>
			<cfset thisOTHER_ID_PREFIX = evaluate("OTHER_ID_PREFIX_" & n)>
			<cfset thisOTHER_ID_SUFFIX = evaluate("OTHER_ID_SUFFIX_" & n)>
			<cfset thisOTHER_ID_TYPE = evaluate("OTHER_ID_TYPE_" & n)>
			<cfif isdefined("delete_" & n) and evaluate("delete_" & n) is 1>
				<cfquery name="dOIDt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					delete from coll_obj_other_id_num WHERE
					COLL_OBJ_OTHER_ID_NUM_ID=#thisCOLL_OBJ_OTHER_ID_NUM_ID#
				</cfquery>
			<cfelse>
				<cfquery name="upOIDt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					UPDATE
						coll_obj_other_id_num
					SET
						other_id_type = '#thisOTHER_ID_TYPE#',
						other_id_prefix='#thisOTHER_ID_PREFIX#',
						<cfif len(thisOTHER_ID_NUMBER) gt 0>
							other_id_number=#thisOTHER_ID_NUMBER#,
						<cfelse>
							other_id_number=NULL,
						</cfif>
						other_id_suffix='#thisOTHER_ID_SUFFIX#',
						id_references='#thisID_REFERENCES#'
					WHERE
						COLL_OBJ_OTHER_ID_NUM_ID=#thisCOLL_OBJ_OTHER_ID_NUM_ID#
				</cfquery>
			</cfif>
		</cfloop>
	</cftransaction>
	<cflocation url="editIdentifiers.cfm?collection_object_id=#collection_object_id#">
</cfoutput>
</cfif>
<!-------------------------------------------------------->
<cfif action is "newOID">
	<cfoutput>
		<cfquery name="newOIDt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		INSERT INTO coll_obj_other_id_num
			(collection_object_id,
			other_id_type,
			other_id_prefix,
			other_id_number,
			other_id_suffix,
			id_references
		) VALUES (
			#collection_object_id#,
			'#other_id_type#',
			'#other_id_prefix#',
			<cfif len(other_id_number) gt 0>
				#other_id_number#
			<cfelse>
				NULL
			</cfif>
			,
			'#other_id_suffix#',
			'#id_references#')
		</cfquery>
		<cflocation url="editIdentifiers.cfm?collection_object_id=#collection_object_id#">
	</cfoutput>
</cfif>
<!-------------------------------------------------------->
<cf_customizeIFrame>