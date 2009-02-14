<cfinclude template="/includes/alwaysInclude.cfm">
<cfset title = "Edit Identifiers">
<cfquery name="getIDs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
		COLL_OBJ_OTHER_ID_NUM_ID,
		cat_num,
		other_id_prefix,
		other_id_number,
		other_id_suffix,
		other_id_type, 
		cataloged_item.collection_id,
		collection.collection_cde,
		institution_acronym
	from 
		cataloged_item, 
		coll_obj_other_id_num,
		collection 
	where
		cataloged_item.collection_id=collection.collection_id and
		cataloged_item.collection_object_id=coll_obj_other_id_num.collection_object_id (+) and 
		cataloged_item.collection_object_id=#collection_object_id#
</cfquery>
<cfquery name="ctType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select other_id_type from ctcoll_other_id_type order by other_id_type
</cfquery>

<cfquery name="cataf" dbtype="query">
	select cat_num from getIDs group by cat_num
</cfquery>

<cfquery name="oids" dbtype="query">
	select 
		COLL_OBJ_OTHER_ID_NUM_ID,
		other_id_prefix,
		other_id_number,
		other_id_suffix,
		other_id_type 
	from 
		getIDs 
	group by 
		COLL_OBJ_OTHER_ID_NUM_ID,
		other_id_prefix,
		other_id_number,
		other_id_suffix,
		other_id_type
</cfquery>
<cfquery name="ctcoll_cde" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
		institution_acronym,
		collection_cde,
		collection_id 
	from collection
</cfquery>
<cfoutput>
<b>Edit existing Identifiers:
<table><form name="ids" method="post" action="editIdentifiers.cfm">
  <input type="hidden" name="collection_object_id" value="#collection_object_id#">

  <input type="hidden" name="Action" value="saveCatEdits">
  <tr class="evenRow"> 
    <td><div align="right">Catalog Number:</div></td>
    <td>
	<select name="collection_id" size="1" class="reqdClr">
		<cfset thisCollId=#getIDs.collection_id#>
		<cfloop query="ctcoll_cde">
			<option 
				<cfif #thisCollId# is #collection_id#> selected </cfif>
			value="#collection_id#">#institution_acronym# #collection_cde#</option>
		</cfloop>
	</select>
	
	<input type="text" name="cat_num" value="#catAF.cat_num#" class="reqdClr"></td>
	<td>
	<a href="##" onClick="window.open('/tools/findGap.cfm','','width=400,height=338, resizable,scrollbars');">
		<img src="/images/info.gif" border="0">
	</a>
	
	<input type="submit" 
	value="Save" 
	class="savBtn"
   	onmouseover="this.className='savBtn btnhov'" 
   	onmouseout="this.className='savBtn'">
	
	 </td>
  </tr>
  

	</form>
	<cfset i=1>
		<cfloop query="oids">
		<cfif len(#other_id_type#) gt 0>
		 <tr #iif(i MOD 2,DE("class='oddRow'"),DE("class='evenRow'"))#	><td>
		<form name="oids#i#" method="post" action="editIdentifiers.cfm">
		<input type="hidden" name="collection_object_id" value="#collection_object_id#">
		<input type="hidden" name="COLL_OBJ_OTHER_ID_NUM_ID" value="#COLL_OBJ_OTHER_ID_NUM_ID#">
		  <input type="hidden" name="Action">
					<td><cfset thisType = #oids.other_id_type#>
					<select name="other_id_type" size="1">				
				<cfloop query="ctType">					
					<option 
						<cfif #ctType.other_id_type# is #thisType#> selected </cfif>
						value="#ctType.other_id_type#">#ctType.other_id_type#</option>
				</cfloop>			
			</select>
			</td>
			<td nowrap="nowrap">
				<input type="text" value="#oids.other_id_prefix#" size="12" name="other_id_prefix">
				<input type="text" value="#oids.other_id_number#" size="12" name="other_id_number">
				<input type="text" value="#oids.other_id_suffix#" size="12"  name="other_id_suffix">		
			</td>
			<td nowrap="nowrap">
			<input type="button" 
	value="Save" 
	class="savBtn"
   	onmouseover="this.className='savBtn btnhov'" 
   	onmouseout="this.className='savBtn'"
	onclick="oids#i#.Action.value='saveOIDEdits';submit();">
	
	<input type="button" value="Delete" class="delBtn"
   onmouseover="this.className='delBtn btnhov'" onmouseout="this.className='delBtn'" onclick="oids#i#.Action.value='deleOID';confirmDelete('oids#i#');">
			</td>
			</form>
		</tr>
		<cfset i=#i#+1>
		</cfif>
	</cfloop>
	</table>
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
	<cfquery name="upCat" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	UPDATE cataloged_item SET 
		cat_num = #cat_num#,
		collection_id=#collection_id#		
	WHERE collection_object_id=#collection_object_id#
	</cfquery>
	</cftransaction>
	<cf_logEdit collection_object_id="#collection_object_id#">
	<cflocation url="editIdentifiers.cfm?collection_object_id=#collection_object_id#">
</cfoutput>
</cfif>
<!-------------------------------------------------------->
<!-------------------------------------------------------->
<cfif #Action# is "saveOIDEdits">
<cfoutput>
	<!---
	<cftry>
		
	
	<cfquery name="upOIDt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		UPDATE 
			coll_obj_other_id_num 
		SET 
			other_id_prefix='#other_id_prefix#',
			other_id_number=#other_id_number#,
			other_id_suffix='#other_id_suffix#',
			other_id_type = '#other_id_type#'
		WHERE 
			collection_object_id=#collection_object_id# and
			other_id_type = '#origother_id_type#' and
			other_id_prefix = '#origother_id_prefix#' AND
			other_id_number = #origother_id_number# AND
			other_id_suffix = '#origother_id_suffix#'
	</cfquery>
	<cfcatch>
		<cf_queryError>
	</cfcatch>
	</cftry>
	--->
	<cfquery name="upOIDt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
	
	
	<cf_logEdit collection_object_id="#collection_object_id#">
	<cflocation url="editIdentifiers.cfm?collection_object_id=#collection_object_id#">

</cfoutput>
</cfif>
<!-------------------------------------------------------->
<!-------------------------------------------------------->
<cfif #Action# is "deleOID">
<cfoutput>


<cfquery name="delOIDt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	DELETE FROM 
		coll_obj_other_id_num 
	WHERE 
		COLL_OBJ_OTHER_ID_NUM_ID=#COLL_OBJ_OTHER_ID_NUM_ID#
	</cfquery>
	
<cf_logEdit collection_object_id="#collection_object_id#">
	<cflocation url="editIdentifiers.cfm?collection_object_id=#collection_object_id#">

</cfoutput>
</cfif>
<!-------------------------------------------------------->
<!-------------------------------------------------------->
<cfif #Action# is "newOID">
<cfoutput>
	<cfquery name="newOIDt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
	<!---
<cftry>

	<cfcatch>
		<cf_queryError>
	</cfcatch>
	</cftry>
	--->
	<cf_logEdit collection_object_id="#collection_object_id#">
	<cflocation url="editIdentifiers.cfm?collection_object_id=#collection_object_id#">

</cfoutput>
</cfif>
<!-------------------------------------------------------->
<cfoutput>
<script type="text/javascript" language="javascript">
		changeStyle('#getIDs.institution_acronym#');
		parent.dyniframesize();
</script>
</cfoutput>