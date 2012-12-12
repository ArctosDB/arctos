<cfinclude template="/includes/alwaysInclude.cfm">
<cfset title = "Edit Identifiers">
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
<cfquery name="ctid_references" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select id_references from ctid_references order by id_references
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
<cfquery name="ctcoll_cde" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select
		institution_acronym,
		collection_cde,
		collection_id
	from collection
</cfquery>
<cfoutput>
<b>Edit existing Identifiers:
<form name="ids" method="post" action="editIdentifiers.cfm">
	<input type="hidden" name="collection_object_id" value="#collection_object_id#">
	<input type="hidden" name="Action" value="saveEdits">
	<cfset i=1>
	<table>
		<tr>
			<th>ID Type</th>
			<th>Prefix</th>
			<th>ID Number (int)</th>
			<th>Suffix</th>
			<th>ID References</th>
		</tr>
		<tr #iif(i MOD 2,DE("class='oddRow'"),DE("class='evenRow'"))#>
			<td>Catalog Number</td>
			<td>#cat.guid_prefix#:</td>
	 		<td>
		 		<span class="infoLink"onClick="window.open('/tools/findGap.cfm','','width=400,height=338, resizable,scrollbars');">[ find gaps ]</span>
			</td>
		 	<td><input type="text" name="cat_num" value="#cat.cat_num#" class="reqdClr"></td>
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
			</tr>
			<cfset i=i+1>
		</cfloop>
	</table>
</form>

	<table class="newRec"><tr><td>
	<b>Add New Identifier:</b> <img
								class="likeLink"
								src="/images/ctinfo.gif"
								onMouseOver="self.status='Code Table Value Definition';return true;"
								onmouseout="self.status='';return true;"
								border="0"
								alt="Code Table Value Definition"
								onClick="getCtDoc('ctcoll_other_id_type','')">
	<table>
		<tr>
			<form name="newOID" method="post" action="editIdentifiers.cfm">
		<input type="hidden" name="collection_object_id" value="#collection_object_id#">
		  <input type="hidden" name="Action" value="newOID">
					<td>
					<select name="other_id_type" size="1" class="reqdClr">
				<cfloop query="ctType">
					<option
						value="#ctType.other_id_type#">#ctType.other_id_type#</option>
				</cfloop>

			</select>
			</td>
			<td>
				<input type="text" class="reqdClr" name="other_id_prefix" size="6">
				<input type="text" class="reqdClr" name="other_id_number" size="6">
				<input type="text" class="reqdClr" name="other_id_suffix" size="6">
			</td>
			<td>
			 <input type="submit" value="Save" class="insBtn"
   onmouseover="this.className='insBtn btnhov'" onmouseout="this.className='insBtn'">

</td>
			</form>
		</tr>
	</table>
	</td></tr></table>
</cfoutput>
</table>
<!-------------------------------------------------------->
<cfif #Action# is "saveCatEdits">
<cfoutput>
	<cftransaction>
	<cfquery name="upCat" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	UPDATE cataloged_item SET
		cat_num = '#cat_num#',
		collection_id=#collection_id#
	WHERE collection_object_id=#collection_object_id#
	</cfquery>
	</cftransaction>
	<cflocation url="editIdentifiers.cfm?collection_object_id=#collection_object_id#">
</cfoutput>
</cfif>
<!-------------------------------------------------------->
<cfif #Action# is "saveOIDEdits">
<cfoutput>
	<cfquery name="upOIDt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		UPDATE
			coll_obj_other_id_num
		SET
			other_id_type = '#other_id_type#'
			<cfif len(#other_id_prefix#) gt 0>
				,other_id_prefix='#other_id_prefix#'
			<cfelse>
				,other_id_prefix= NULL
			</cfif>
			<cfif len(#other_id_number#) gt 0>
				,other_id_number=#other_id_number#
			<cfelse>
				,other_id_number= NULL
			</cfif>
			<cfif len(#other_id_suffix#) gt 0>
				,other_id_suffix='#other_id_suffix#'
			<cfelse>
				,other_id_suffix= NULL
			</cfif>
		WHERE
			COLL_OBJ_OTHER_ID_NUM_ID=#COLL_OBJ_OTHER_ID_NUM_ID#
	</cfquery>
	<cflocation url="editIdentifiers.cfm?collection_object_id=#collection_object_id#">
</cfoutput>
</cfif>
<!-------------------------------------------------------->
<cfif #Action# is "deleOID">
<cfoutput>
<cfquery name="delOIDt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	DELETE FROM
		coll_obj_other_id_num
	WHERE
		COLL_OBJ_OTHER_ID_NUM_ID=#COLL_OBJ_OTHER_ID_NUM_ID#
	</cfquery>
	<cflocation url="editIdentifiers.cfm?collection_object_id=#collection_object_id#">
</cfoutput>
</cfif>
<!-------------------------------------------------------->
<cfif #Action# is "newOID">
<cfoutput>
	<cfquery name="newOIDt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	INSERT INTO coll_obj_other_id_num
		(collection_object_id,
		other_id_type,
		other_id_prefix,
		other_id_number,
		other_id_suffix
	) VALUES (
		#collection_object_id#,
		'#other_id_type#',
		<cfif len(#other_id_prefix#) gt 0>
			'#other_id_prefix#'
		<cfelse>
			NULL
		</cfif>
		,
		<cfif len(#other_id_number#) gt 0>
			#other_id_number#
		<cfelse>
			NULL
		</cfif>
		,
		<cfif len(#other_id_suffix#) gt 0>
			'#other_id_suffix#'
		<cfelse>
			NULL
		</cfif>)
	</cfquery>
	<cflocation url="editIdentifiers.cfm?collection_object_id=#collection_object_id#">
</cfoutput>
</cfif>
<!-------------------------------------------------------->
<cf_customizeIFrame>