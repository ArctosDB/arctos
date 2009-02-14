<cfinclude template="/includes/alwaysInclude.cfm">
<cfif #action# is "nothing" OR #action# is "newAttPicked">
<strong>Edit Individual Attributes</strong>

<a href="javascript:void(0);" 
							onClick="windowOpener('/info/attributeHelpPick.cfm','','width=600,height=600, resizable,scrollbars'); return false;"
							onMouseOver="self.status='Click for Attributes help.';return true;" 
							onmouseout="self.status='';return true;"><img src="/images/info.gif" border="0"></a>
<cfoutput>
<cfquery name="whatColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select collection_cde from cataloged_item where 
	collection_object_id = #collection_object_id#
</cfquery>
<cfquery name="indiv" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT cat_num, collection.collection_cde, institution_acronym,
	cataloged_item.collection_object_id collection_object_id, 
	ATTRIBUTE_ID,
	agent_name,
	determined_by_agent_id,
	ATTRIBUTE_TYPE,
	ATTRIBUTE_VALUE,
	attribute_units,
	ATTRIBUTE_REMARK,
	DETERMINED_DATE,
	DETERMINATION_METHOD
	FROM cataloged_item, collection,
	attributes,
	preferred_agent_name
	WHERE cataloged_item.collection_id = collection.collection_id AND
	cataloged_item.collection_object_id = attributes.collection_object_id (+) AND
	attributes.determined_by_agent_id = preferred_agent_name.agent_id AND
	cataloged_item.collection_object_id = #collection_object_id#
</cfquery>
<cfquery name="ctattribute_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT attribute_type FROM ctattribute_type where 
	collection_cde='#whatColl.collection_cde#'
</cfquery>
<cfquery name="ctflags" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT flags from ctflags
</cfquery>
<!---- cache this query --->
<cfquery name="ctCodes" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
		attribute_type,
		value_code_table,
		units_code_table
	 from ctattribute_code_tables
</cfquery>
<cfquery name="getIndivDetails" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
		COLL_OBJ_DISPOSITION,
		CONDITION,
		CAT_NUM
		COLLECTION_cde,
		DISPOSITION_REMARKS,
		COLL_OBJECT_REMARKS,
		habitat,
		associated_species,
		flags
	FROM
		cataloged_item, 
		coll_object,
		coll_object_remark
	WHERE
		cataloged_item.collection_object_id = coll_object.collection_object_id AND
		cataloged_item.collection_object_id = coll_object_remark.collection_object_id (+) AND
		cataloged_item.collection_object_id = #collection_object_id#
		
</cfquery>
<cfquery name="ctdisp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select coll_obj_disposition from ctcoll_obj_disp
</cfquery>
<cfquery name="ctcoll" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select collection_cde from ctcollection_cde
</cfquery>
</cfoutput>
<cfoutput query="getIndivDetails">
	<form name="details" method="post" action="editBiolIndiv.cfm">
		<input type="hidden" value="saveNoAttEdits" name="Action">
		<input type="hidden" value="#collection_object_id#" name="collection_object_id">
    <table>
      <tr> 
        <td><div align="right">Disposition: </div></td>
        <td><select name="COLL_OBJ_DISPOSITION" size="1" class="reqdClr">
            <cfloop query="ctdisp">
              <option 
						<cfif #getIndivDetails.COLL_OBJ_DISPOSITION# is "#ctdisp.COLL_OBJ_DISPOSITION#"> selected </cfif>
						value="#ctdisp.COLL_OBJ_DISPOSITION#">#ctdisp.COLL_OBJ_DISPOSITION#</option>
            </cfloop>
          </select></td>
        <td><div align="right">Condition: 
		<img src="/images/info.gif" border="0" class="likeLink" onClick="chgCondition('#collection_object_id#')"></div></td>
        <td><input type="text" name="CONDITION" value="#CONDITION#" class="reqdClr"></td>
     
       
       <!----
	    <td><div align="right">Collection:</div></td>
        <td>
		<cfquery name="ctCollID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				collection_id,
				collection_cde,
				institution_acronym 
			FROM
				collection
			GROUP BY
				collection_id,
				collection_cde,
				institution_acronym 
		</cfquery>
		<select name="COLLECTION_ID" size="1" class="reqdClr">
            <cfloop query="ctCollID">
              <option 
						<cfif #getIndivDetails.collection_id# is "#ctCollID.collection_id#"> selected </cfif>
						value="#ctCollID.collection_id#">#ctCollID.institution_acronym# #ctCollID.collection_cde#</option>
            </cfloop>
          </select>
		  <!----
		<select name="COLLECTION_CDE" size="1" class="reqdClr">
            <cfloop query="ctcoll">
              <option 
						<cfif #getIndivDetails.collection_cde# is "#ctcoll.collection_cde#"> selected </cfif>
						value="#ctcoll.collection_cde#">#ctcoll.collection_cde#</option>
            </cfloop>
          </select>
		  ---->
		  </td>
		  ---->
      </tr>
     
     
      <tr> 
	  <tr>
	  	<td align="right">Missing:
		
	</td>
	<td>
	<select name="flags" size="1">
			<option value=""></option>
			<cfloop query="ctflags">
				<option <cfif #getIndivDetails.flags# is #ctflags.flags#> selected </cfif>value="#flags#">#flags#</option>
			</cfloop>
		</select>	
	</td>
	  </tr>
        <td><div align="right">Disp. Remarks:</div></td>
        <td colspan="5">
		<input type="text" name="DISPOSITION_REMARKS" value="#DISPOSITION_REMARKS#" size="80"></td>
      </tr>
      <tr> 
        <td><div align="right">Specimen Remarks:</div></td>
        <td colspan="5"> 
          <textarea name="COLL_OBJECT_REMARKS" cols="80" rows="2">#COLL_OBJECT_REMARKS#</textarea></td>
      </tr>
	   <tr> 
        <td><div align="right">Microhabitat:</div></td>
        <td colspan="5"> 
          <textarea name="habitat" cols="80" rows="2">#habitat#</textarea></td>
      </tr>
	   <tr> 
        <td><div align="right">Associated Species:</div></td>
        <td colspan="5"> 
          <textarea name="associated_species" cols="80" rows="2">#associated_species#</textarea></td>
      </tr>
	  
	  
		
	  <tr>
	  	<td colspan="6" align="center">
		 <input type="submit" 
	value="Save Changes" 
	class="savBtn"
   	onmouseover="this.className='savBtn btnhov'" 
   	onmouseout="this.className='savBtn'">	

		</td>
	  </tr>
	 
    </table>
    <br>
  
	</form>
</cfoutput>
<cfoutput>
<cfset i=1>
<table border cellpadding="2">
	<tr>
		<td>Attribute</td>
		<td>Value</td>
		<td>Units</td>
		<td>Remarks</td>
		<td>Det. Date</td>
		<td>Det. Meth</td>
		<td>Determiner</td>
		<td>&nbsp;</td>
	</tr>
<form name="oldAttributes" method="post" action="editBiolIndiv.cfm" onSubmit="noenter();">
		<input type="hidden" name="action">
		<input type="hidden" name="attribute_id">
		<input type="hidden" name="collection_object_id" value="#collection_object_id#">
<cfloop query="indiv">
	<cfif len(#indiv.attribute_type#) gt 0>
	
		<input type="hidden" name="attribute_id_#i#" value="#indiv.attribute_id#">
	 <tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
		<td><cfset thisAttType = #indiv.attribute_type#>
		<input type="text" name="attribute_type_#i#" value="#thisAttType#" readonly="yes" class="readClr">
		</td>
		<td>
		
		<!---- see if we should have a code table here --->
		<cfquery name="isValCt" dbtype="query">
			select value_code_table from ctCodes where attribute_type='#thisAttType#'
		</cfquery>
		<cfif isdefined("isValCt.value_code_table") and len(#isValCt.value_code_table#) gt 0>
			<!-- there's a code table --->
			<cfquery name="valCT" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select * from #isValCt.value_code_table#
			</cfquery>
			
			<!---- get column names --->
			<cfquery name="getCols" datasource="uam_god">
				select column_name from sys.user_tab_columns where table_name='#ucase(isValCt.value_code_table)#'
				and column_name <> 'DESCRIPTION'
			</cfquery>
				<cfset collCode = "">
				<cfset columnName = "">
				<cfloop query="getCols">
						<cfif getCols.column_name is "COLLECTION_CDE">
							<cfset collCode = "yes">
						  <cfelse>
							<cfset columnName = "#getCols.column_name#">
						</cfif>
				</cfloop>
				<!--- if we got a collection code, rerun the query to filter ---->
				<cfif len(#collCode#) gt 0>
					<cfquery name="valCodes" dbtype="query">
						SELECT #columnName# as valCodes from valCT
						WHERE collection_cde='#indiv.collection_cde#'
					</cfquery>
				  <cfelse>
				 
				  	<cfquery name="valCodes" dbtype="query">
						SELECT #columnName# as valCodes from valCT
					</cfquery>
				</cfif>
				<cfset thisAttVal = "#indiv.attribute_value#">
				<select name="attribute_value_#i#" size="1" class="reqdClr">
					<option value=""></option>
					<cfloop query="valCodes">
						<option 
							<cfif #valCodes.valCodes# is "#thisAttVal#"> selected </cfif>
						value="#valCodes.valCodes#">#valCodes.valCodes#</option>
					</cfloop>
				</select>
				<img src="/images/info.gif" border="0" 
				onClick="getCtDoc('#isValCt.value_code_table#',oldAttributes.attribute_value_#i#.value)">
		
		
		
		
		
		  <cfelse><!--- free text --->
		  	<input type="text" name="attribute_value_#i#" value="#indiv.attribute_value#" class="reqdClr" size="25">
		</cfif>
		
		
		
		</td>
		<td>
		
		<!---- see if we should have a code table here --->
		<cfquery name="isUnitCt" dbtype="query">
			select units_code_table from ctCodes where attribute_type='#thisAttType#'
		</cfquery>
		<cfif isdefined("isUnitCt.units_code_table") and len(#isUnitCt.units_code_table#) gt 0>
			<!-- there's a code table --->
			<!---- get the data --->
			<cfquery name="unitCT" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select * from #isUnitCt.units_code_table#
			</cfquery>
			<!---- get column names --->
			<cfquery name="getCols" datasource="uam_god">
				select column_name from sys.user_tab_columns where table_name='#ucase(isUnitCt.units_code_table)#'
				and column_name <> 'DESCRIPTION'
			</cfquery>
				<cfset collCode = "">
				<cfset columnName = "">
				<cfloop query="getCols">
					<cfif getCols.column_name is "COLLECTION_CDE">
						<cfset collCde = "yes">
					  <cfelse>
					 	<cfset columnName = "#getCols.column_name#">
					</cfif>
				</cfloop>
				<!--- if we got a collection code, rerun the query to filter ---->
				<cfif len(#collCode#) gt 0>
			
					<cfquery name="unitCodes" dbtype="query">
						SELECT #columnName# as unitCodes from unitCT
						WHERE collection_cde='#indiv.collection_cde#'
					</cfquery>
				  <cfelse>
			
				  	<cfquery name="unitCodes" dbtype="query">
						SELECT #columnName# as unitCodes from unitCT
					</cfquery>
				</cfif>
				<cfset thisAttUnit = "#indiv.attribute_units#">
				<select name="attribute_units_#i#" size="1" class="reqdClr">
					<option value=""></option>
					<cfloop query="unitCodes">
						<option 
							<cfif #unitCodes.unitCodes# is "#thisAttUnit#"> selected </cfif>
						value="#unitCodes.unitCodes#">#unitCodes.unitCodes#</option>
					</cfloop>
				</select>
		  <cfelse><!--- free text --->
		  <!----
		  no code table
		  	<input type="text" name="attribute_units" value="#indiv.attribute_units#">
			----->
			<input type="hidden" name="attribute_units_#i#" value="">
			&nbsp;
		</cfif>
		
		</td>
		<td>
		<cfset detDate = #dateformat(indiv.determined_date,"dd mmm yyyy")#>
		<input type="text" name="attribute_remark_#i#" value="#indiv.attribute_remark#"></td>
		<td><input type="text" name="determined_date_#i#" value="#detDate#" class="reqdClr" size="12"></td>
		<td><input type="text" name="determination_method_#i#" value="#indiv.determination_method#"></td>
		<td>
		<input type="hidden" name="determined_by_agent_id_#i#" value="#indiv.determined_by_agent_id#">
		
		<input type="text" name="agent_name_#i#" class="reqdClr" value="#indiv.agent_name#"
		 onchange="getAgent('determined_by_agent_id_#i#','agent_name_#i#','oldAttributes',oldAttributes.agent_name_#i#.value); return false;"
		  onKeyPress="return noenter(event);">
		
		<!----
		<input type="button" name="pickDeterminer"
				value="Find" 
				class="picBtn"
				onmouseover="this.className='picBtn btnhov'"
				onmouseout="this.className='picBtn'"
				onclick="getAgent('determined_by_agent_id','agent_name','att#i#',att#i#.agent_name.value); return false;">
				---->
				</td>
			<td>
		
		<input type="button" 
				value="Delete" 
				class="delBtn"
				onmouseover="this.className='delBtn btnhov'"
				onmouseout="this.className='delBtn'"
				onclick="oldAttributes.attribute_id.value='#attribute_id#';;oldAttributes.action.value='deleteAttribute';confirmDelete('oldAttributes');">
			</td>
	</tr>
</cfif>
	<cfset i=#i#+1>
</cfloop>
<cfset numberOfAttributes= #i# - 1>
<input type="hidden" name="numberOfAttributes" value="#numberOfAttributes#">
<tr>
	<td colspan="7" align="center">
	<input type="button"  
				value="Save Attribute Changes" 
				class="savBtn"
				onmouseover="this.className='savBtn btnhov';this.focus();"
				onmouseout="this.className='savBtn'"
				onclick="oldAttributes.action.value='saveChanges';submit();">
	</td>
</tr>
</form>
</table>
<br>
<table class="newRec">
<a name="newAttribute"></a>
New attribute:
	<form name="newArrtibute" method="post" action="editBiolIndiv.cfm##newAttribute">
		<input type="hidden" name="action" value="newAttPicked">
		<input type="hidden" name="collection_object_id" value="#collection_object_id#">
		<input type="hidden" name="content_url" value="editBiolIndiv.cfm">
		<cfif isdefined("attribute_type")>
			<cfset seleAtt = "#attribute_type#">
		  <cfelse>
		  	<cfset seleAtt = "">
		</cfif>
		<tr>
		<td>
		Attribute:
		</td>
		<td> <select name="attribute_type" size="1" onChange="submit();" class="reqdClr">
			<option value="">Pick one...</option>
			<cfloop query="ctattribute_type">
			<option <cfif #seleAtt# is "#ctattribute_type.attribute_type#"> selected </cfif>
				value="#ctattribute_type.attribute_type#">#ctattribute_type.attribute_type#</option>
			</cfloop>
		</select>
		</td>
		</tr>
	</form>
	<cfif #action# is "newAttPicked">
	<cfset thisAttType = "#seleAtt#">
	<form name="newAttribute" method="post" action="editBiolIndiv.cfm">
		<input type="hidden" name="action" value="newAttribute">
		<input type="hidden" name="collection_object_id" value="#collection_object_id#">
		<input type="hidden" name="attribute_type" value="#thisAttType#">
		<tr>
			<td>Value</td>
			<td>
			
			<!---- see if we should have a code table here --->
		<cfquery name="isValCt" dbtype="query">
			select value_code_table from ctCodes where attribute_type='#thisAttType#'
		</cfquery>
		<cfif isdefined("isValCt.value_code_table") and len(#isValCt.value_code_table#) gt 0>
			<!-- there's a code table --->
			<cfquery name="valCT" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select * from #isValCt.value_code_table#
			</cfquery>
			<!----------------------->
			<!---- get column names --->
			<cfquery name="getCols" datasource="uam_god">
				select column_name from sys.user_tab_columns where table_name='#ucase(isValCt.value_code_table)#'
				and column_name <> 'DESCRIPTION'
			</cfquery>
				<cfset collCde = "">
				<cfset columnName = "">
				<cfloop query="getCols">
					<cfif getCols.column_name is "COLLECTION_CDE">
						<cfset collCde = "yes">
					  <cfelse>
					 	<cfset columnName = "#getCols.column_name#">
					</cfif>
				</cfloop>
				<!--- if we got a collection code, rerun the query to filter ---->
				
				<cfif len(#collCde#) gt 0>
				
					<cfquery name="valCodes" dbtype="query">
						SELECT #columnName# as valCodes from valCT
						WHERE collection_cde='#whatColl.collection_cde#'
					</cfquery>
				  <cfelse>				
				  	<cfquery name="valCodes" dbtype="query">
						SELECT #columnName# as valCodes from valCT
					</cfquery>					
				</cfif>				
				<select name="attribute_value" size="1" class="reqdClr">
					<option value=""></option>
					<cfloop query="valCodes">
						<option 
						value="#valCodes.valCodes#">#valCodes.valCodes#</option>
					</cfloop>
				</select>
		
			
		  <cfelse><!--- free text --->
		  <input type="text" name="attribute_value" class="reqdClr">
		</cfif>
		
		
		
		</td>
		</tr>
		<tr>
			<td>Units:</td>
			<td>
			<!---- see if we should have a code table here --->
		<cfquery name="isUnitCt" dbtype="query">
			select units_code_table from ctCodes where attribute_type='#thisAttType#'
		</cfquery>
		<cfif isdefined("isUnitCt.units_code_table") and len(#isUnitCt.units_code_table#) gt 0>
		
			<!-- there's a code table --->
			<!---- get the data --->
			<cfquery name="unitCT" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select * from #isUnitCt.units_code_table#
			</cfquery>
			<!---- get column names --->
			<cfquery name="getCols" datasource="uam_god">
				select (column_name) from sys.user_tab_columns where table_name='#ucase(isUnitCt.units_code_table)#'
				and upper(column_name) <> 'DESCRIPTION'
			</cfquery>
				<cfset collCode = "">
				<cfset columnName = "">
				<cfloop query="getCols">
					<cfif getCols.column_name is "COLLECTION_CDE">
						<cfset collCde = "yes">
					  <cfelse>
					 	<cfset columnName = "#getCols.column_name#">
					</cfif>
				</cfloop>
				<!--- if we got a collection code, rerun the query to filter ---->
				<cfif len(#collCode#) gt 0>
					is coll cde
					<cfquery name="unitCodes" dbtype="query">
						SELECT #columnName# as unitCodes from unitCT
						WHERE collection_cde='#indiv.collection_cde#'
					</cfquery>
				  <cfelse>
				  is not coll cde
				  	<cfquery name="unitCodes" dbtype="query">
						SELECT #columnName# as unitCodes from unitCT
					</cfquery>
				</cfif>
				<cfset thisAttUnit = "#indiv.attribute_units#">
				<select name="attribute_units" size="1" class="reqdClr">
					<option value=""></option>
					<cfloop query="unitCodes">
						<option 
						value="#unitCodes.unitCodes#">#unitCodes.unitCodes#</option>
					</cfloop>
				</select>
		  <cfelse><!--- free text --->
		 
		  	<input type="hidden" name="attribute_units" value="">
		</cfif>
			</td>
		</tr>
		<tr>
			<td>Remarks:</td>
			<td><input type="text" name="attribute_remark"></td>
		</tr>
		<tr>
			<td>Date:</td>
			<td>
				<cfset thisDate = "#dateformat(now(),"dd mmm yyyy")#">
				<input type="text" name="determined_date" value="#thisDate#" class="reqdClr">
			</td>
		</tr>
		<tr>
			<td>Meth:</td>
			<td>
				<input type="text" name="determination_method">
			</td>
		</tr>
		<tr>
			<td>Determiner:</td>
			<td>
				<cfset defAgnt = "unknown">
				<cfquery name="defaultDeterminer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					SELECT agent_id FROM preferred_agent_name
					WHERE agent_name = '#defAgnt#'
				</cfquery>
				<input type="hidden" name="determined_by_agent_id" value="#defaultDeterminer.agent_id#">
		<input type="text" name="agent_name" class="reqdClr" value="#defAgnt#"
		 onchange="getAgent('determined_by_agent_id','agent_name','newAttribute',newAttribute.agent_name.value); return false;"
		  onKeyPress="return noenter(event);">
		
			</td>
		</tr>
		<tr>
			<td colspan="2">
			<input type="submit" 
				value="Create" 
				class="insBtn"
				onmouseover="this.className='insBtn btnhov';this.focus();"
				onmouseout="this.className='insBtn'">
			</td>
		</tr>
		<!--- declare our picked attribute type into this variable --->
		
		<!--------------------->
		
		
		
		
		
		
		</form>
		<!------------------------------------>
		
		<cfelse><!--- waiting for them to pick something ---->
		<td>
		pick an attribute to populate these fields....
		</td>
		
	
		</cfif>
		
</table>
		
	
</cfoutput>
<cfif #indiv.collection_cde# is "Mamm">
<cfoutput>
<cfquery name="ctlength_units" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from ctlength_units
</cfquery>
<cfquery name="ctweight_units" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from ctweight_units
</cfquery>
<form name="mammalAtts" method="post" action="editBiolIndiv.cfm" onSubmit="return gotAgentId(this.determined_by_agent_id.value)">
	<table border>
		<tr>
			<td colspan="8">
				Existing values will NOT show up in this grid!! Use it to add new values ONLY. If you enter an existing value here, 
					it will be entered twice, <em>e.g.</em>:
					<blockquote>
						Total length: {old value}
						<br>Total length: {new value}
					</blockquote>
					
			</td>
		</tr>
		<tr>
			<td nowrap>
				Total Length:
			</td>
			<td nowrap>
				<input type="text" name="total_length" size="4">
				<select name="total_length_units" size="1">
					<cfloop query="ctlength_units">
						<option 
							<cfif #length_units# is "mm"> selected </cfif>value="#ctlength_units.length_units#">#ctlength_units.length_units#</option>
					</cfloop>
				</select>
			</td>
			<td nowrap>
				Tail Length:
			</td>
			<td nowrap>
				<input type="text" name="tail_length" size="4">
				<select name="tail_length_units" size="1">
					<cfloop query="ctlength_units">
						<option 
							<cfif #length_units# is "mm"> selected </cfif>value="#ctlength_units.length_units#">#ctlength_units.length_units#</option>
					</cfloop>
				</select>
			</td>
			<td nowrap>
				Hind Foot with claw:
			</td>
			<td nowrap>
				<input type="text" name="hind_foot_with_claw" size="4">
				<select name="hind_foot_with_claw_units" size="1">
					<cfloop query="ctlength_units">
						<option 
							<cfif #length_units# is "mm"> selected </cfif>value="#ctlength_units.length_units#">#ctlength_units.length_units#</option>
					</cfloop>
				</select>
			</td>
			<td nowrap>
				EFN:
			</td>
			<td nowrap>
				<input type="text" name="ear_from_notch" size="4">
				<select name="ear_from_notch_units" size="1">
					<cfloop query="ctlength_units">
						<option 
							<cfif #length_units# is "mm"> selected </cfif>value="#ctlength_units.length_units#">#ctlength_units.length_units#</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td nowrap>
				Weight:
			</td>
			<td nowrap>
				<input type="text" name="weight" size="4">
				<select name="weight_units" size="1">
					<cfloop query="ctweight_units">
						<option 
							<cfif #weight_units# is "g"> selected </cfif>value="#ctweight_units.weight_units#">#ctweight_units.weight_units#</option>
					</cfloop>
				</select>
			</td>
			<td>
				Determined Date:
			</td>
			<td>
				<input type="text" name="determined_date" size="10">
			</td>
			<td>
				Determiner:
			</td>
			<td colspan="2">
				<input type="hidden" name="determined_by_agent_id">
		<input type="text" name="agent_name" class="reqdClr"
		onchange="getAgent('determined_by_agent_id','agent_name','mammalAtts',this.value); return false;">
		
			</td>
			
		</tr>
		<tr>
			<td colspan="8" align="center">
				<input type="hidden" name="action" value="saveMammalAtts">
				<input type="hidden" value="#indiv.collection_object_id#" name="collection_object_id">
				<input type="submit" 
					value="Save" 
					class="savBtn"
					onmouseover="this.className='savBtn btnhov'"
					onmouseout="this.className='savBtn'">
			</td>
		</tr>
	</table>
</form>
</cfoutput>
</cfif>

</cfif>
<!------------------------------------------------------------------------------>

<!------------------------------------------------------------------------------>
<cfif #Action# is "saveChanges">
<cfoutput>

<cfloop from="1" to="#numberOfAttributes#" index="n">
	<cfset thisAttributeId = #evaluate("attribute_id_" & n)#>
	<cfset thisAttributeType = #evaluate("attribute_type_" & n)#>
	<cfset thisAttributeUnits = #evaluate("attribute_units_" & n)#>
	<cfset thisAttributeValue = #evaluate("attribute_value_" & n)#>
	<cfset thisAttributeRemark = #evaluate("attribute_remark_" & n)#>
	<cfset thisDeterminedDate = #evaluate("determined_date_" & n)#>
	<cfset thisDeterminationMethod = #evaluate("determination_method_" & n)#>
	<cfset thisDeterminedByAgentId = #evaluate("determined_by_agent_id_" & n)#>
	
	<cfquery name="isStoopid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select units_code_table from ctattribute_code_tables where
		attribute_type = '#thisAttributeType#'
	</cfquery>
	<cfif len(#isStoopid.units_code_table#) gt 0>
		<cfif len(#thisAttributeUnits#) is 0>
			<font color="##FF0000" size="+2">#thisAttributeType# requires units!</font>		  
			<cfabort>
		</cfif>
	</cfif>
	<cfif len(#thisAttributeValue#) is 0>
			<font color="##FF0000" size="+2">You must supply an attribute value!</font>		  
			<cfabort>
	</cfif>
	<cfquery name="upAt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	UPDATE attributes SET
		attribute_type='#thisAttributeType#'
		,DETERMINED_BY_AGENT_ID = #thisDeterminedByAgentId#
		,ATTRIBUTE_VALUE='#thisAttributeValue#'
		<cfif len(#thisAttributeUnits#) gt 0>
			,ATTRIBUTE_UNITS='#thisAttributeUnits#'
			<cfelse>
				,ATTRIBUTE_UNITS=null
		</cfif>
		<cfif len(#thisAttributeRemark#) gt 0>
			,ATTRIBUTE_REMARK='#thisAttributeRemark#'
		  <cfelse>
		  	,ATTRIBUTE_REMARK=null
		</cfif>
		,DETERMINED_DATE='#dateformat(thisDeterminedDate,"dd-mmm-yyyy")#'
		<cfif len(#thisDeterminationMethod#) gt 0>
			,DETERMINATION_METHOD='#thisDeterminationMethod#'
			<cfelse>
				,DETERMINATION_METHOD=null
		</cfif> 
	WHERE attribute_id=#thisAttributeId#
	</cfquery>
</cfloop>

	
	<cf_logEdit collection_object_id="#collection_object_id#">
	 <cflocation url="editBiolIndiv.cfm?collection_object_id=#collection_object_id#">   
	
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------>

<!------------------------------------------------------------------------------>
<cfif #Action# is "deleteAttribute">
<cfoutput>
	<cfquery name="del" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		DELETE FROM attributes WHERE attribute_id=#attribute_id#
	</cfquery>
	<cf_logEdit collection_object_id="#collection_object_id#">
<cflocation url="editBiolIndiv.cfm?collection_object_id=#collection_object_id#"> </cfoutput>
</cfif>
<!------------------------------------------------------------------------------>
<cfif #Action# is "saveMammalAtts">
	<cfoutput>
		<cfif len(#determined_by_agent_id#) is 0>
			You need a determiner!
			<cfabort>
		</cfif>
		<cfif len(#determined_date#) is 0>
			determined_date is required!
			<cfabort>
		</cfif>
		
		<cfif len(#total_length#) gt 0>
			<cfquery name="total_length" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				INSERT INTO attributes (
					ATTRIBUTE_ID
					,COLLECTION_OBJECT_ID
					,DETERMINED_BY_AGENT_ID
					,ATTRIBUTE_TYPE
					,ATTRIBUTE_VALUE
					,ATTRIBUTE_UNITS
					,DETERMINED_DATE
					 )
				VALUES (
					sq_attribute_id.nextval
					,#collection_object_id#
					,#determined_by_agent_id#
					,'total length'
					,'#total_length#'
					,'#total_length_units#'
					,'#dateformat(DETERMINED_DATE,"dd-mmm-yyyy")#')
				</cfquery>
			</cfif>
			
			<cfif len(#tail_length#) gt 0>
				<cfquery name="tail_length" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					INSERT INTO attributes (
						ATTRIBUTE_ID
						,COLLECTION_OBJECT_ID
						,DETERMINED_BY_AGENT_ID
						,ATTRIBUTE_TYPE
						,ATTRIBUTE_VALUE
						,ATTRIBUTE_UNITS
						,DETERMINED_DATE
						 )
					VALUES (
						sq_attribute_id.nextval
						,#collection_object_id#
						,#determined_by_agent_id#
						,'tail length'
						,'#tail_length#'
						,'#tail_length_units#'
						,'#dateformat(DETERMINED_DATE,"dd-mmm-yyyy")#')
				</cfquery>
			</cfif>
			<cfif len(#hind_foot_with_claw#) gt 0>
				<cfquery name="hind_foot_with_claw" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					INSERT INTO attributes (
						ATTRIBUTE_ID
						COLLECTION_OBJECT_ID
						,DETERMINED_BY_AGENT_ID
						,ATTRIBUTE_TYPE
						,ATTRIBUTE_VALUE
						,ATTRIBUTE_UNITS
						,DETERMINED_DATE
						 )
					VALUES (
						sq_attribute_id.nextval,
						#collection_object_id#
						,#determined_by_agent_id#
						,'hind foot with claw'
						,'#hind_foot_with_claw#'
						,'#hind_foot_with_claw_units#'
						,'#dateformat(DETERMINED_DATE,"dd-mmm-yyyy")#')
				</cfquery>
			</cfif>
			<cfif len(#ear_from_notch#) gt 0>
				<cfquery name="ear_from_notch" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					INSERT INTO attributes (
						ATTRIBUTE_ID
						,COLLECTION_OBJECT_ID
						,DETERMINED_BY_AGENT_ID
						,ATTRIBUTE_TYPE
						,ATTRIBUTE_VALUE
						,ATTRIBUTE_UNITS
						,DETERMINED_DATE
						 )
					VALUES (
						sq_attribute_id.nextval,
						#collection_object_id#
						,#determined_by_agent_id#
						,'ear from notch'
						,'#ear_from_notch#'
						,'#ear_from_notch_units#'
						,'#dateformat(DETERMINED_DATE,"dd-mmm-yyyy")#')
				</cfquery>
			</cfif>
			<cfif len(#weight#) gt 0>
				<cfquery name="weight" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					INSERT INTO attributes (
						ATTRIBUTE_ID
						,COLLECTION_OBJECT_ID
						,DETERMINED_BY_AGENT_ID
						,ATTRIBUTE_TYPE
						,ATTRIBUTE_VALUE
						,ATTRIBUTE_UNITS
						,DETERMINED_DATE
						 )
					VALUES (
						sq_attribute_id.nextval
						,#collection_object_id#
						,#determined_by_agent_id#
						,'weight'
						,'#weight#'
						,'#weight_units#'
						,'#dateformat(DETERMINED_DATE,"dd-mmm-yyyy")#')
				</cfquery>
			</cfif>
			
<cflocation url="editBiolIndiv.cfm?collection_object_id=#collection_object_id#"> 	</cfoutput>
</cfif>

<!------------------------------------------------------------------------------>
<cfif #Action# is "newAttribute">
<cfoutput>
	<cfquery name="isStoopid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select units_code_table from ctattribute_code_tables where
		attribute_type = '#attribute_type#'
	</cfquery>
	
	<cfif len(#isStoopid.units_code_table#) gt 0>
		<cfif len(#ATTRIBUTE_UNITS#) is 0>
			<font color="##FF0000" size="+2">#attribute_type# requires units!</font>		  
			<cfabort>
		</cfif>
	
	</cfif>
	<cfif len(#attribute_value#) is 0>
			<font color="##FF0000" size="+2">You must supply an attribute value!</font>		  
			<cfabort>
	</cfif>	
	<cfquery name="newAtt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	INSERT INTO attributes (
		ATTRIBUTE_ID
		,COLLECTION_OBJECT_ID
		,DETERMINED_BY_AGENT_ID
		,ATTRIBUTE_TYPE
		,ATTRIBUTE_VALUE
		<cfif len(#ATTRIBUTE_UNITS#) gt 0>
			,ATTRIBUTE_UNITS
		</cfif>
		<cfif len(#ATTRIBUTE_REMARK#) gt 0>
			,ATTRIBUTE_REMARK
		</cfif>
		,DETERMINED_DATE
		<cfif len(#DETERMINATION_METHOD#) gt 0>
			,DETERMINATION_METHOD
		</cfif>
		 )
	VALUES (
		sq_attribute_id.nextval
		,#collection_object_id#
		,#DETERMINED_BY_AGENT_ID#
		,'#ATTRIBUTE_TYPE#'
		,'#ATTRIBUTE_VALUE#'
		<cfif len(#ATTRIBUTE_UNITS#) gt 0>
			,'#ATTRIBUTE_UNITS#'
		</cfif>
		<cfif len(#ATTRIBUTE_REMARK#) gt 0>
			,'#ATTRIBUTE_REMARK#'
		</cfif>
		,'#dateformat(DETERMINED_DATE,"dd-mmm-yyyy")#'
		<cfif len(#DETERMINATION_METHOD#) gt 0>
			,'#DETERMINATION_METHOD#'
		</cfif> )
	</cfquery>
	<cf_logEdit collection_object_id="#collection_object_id#">
<cflocation url="editBiolIndiv.cfm?collection_object_id=#collection_object_id#"> </cfoutput>
</cfif>
<!------------------------------------------------------------------------------>


<cfif #Action# is "saveNoAttEdits">

<cfoutput>
	<cfset thisDate = dateformat(now(),"dd-mmm-yyyy")>
	<cftransaction>
		<cfquery name="upCollObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			UPDATE coll_object SET
				last_edited_person_id = #session.myAgentId#
				,last_edit_date = '#thisDate#'
				,coll_obj_disposition = '#coll_obj_disposition#'
				,condition = '#condition#'
				,flags='#flags#'
			WHERE collection_object_id = #collection_object_id#
		</cfquery>
		<cfquery name="isCORem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select collection_object_id from coll_object_remark where 
			collection_object_id = #collection_object_id#
		</cfquery>
		<cfif len(#isCORem.collection_object_id#) gt 0>
			<cfquery name="upCoRem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				UPDATE coll_object_remark SET
					collection_object_id = #collection_object_id#
					<cfif len(#disposition_remarks#) gt 0>
						,disposition_remarks = '#disposition_remarks#'
					<cfelse>
						,disposition_remarks = null
					</cfif>
					<cfif len(#coll_object_remarks#) gt 0>
						,coll_object_remarks = '#coll_object_remarks#'
					<cfelse>
						,coll_object_remarks = null
					</cfif>
					<cfif len(#habitat#) gt 0>
						,habitat = '#habitat#'
					<cfelse>
						,habitat = null
					</cfif>
					<cfif len(#associated_species#) gt 0>
						,associated_species = '#associated_species#'
					<cfelse>
						,associated_species = null
					</cfif>
					WHERE collection_object_id = #collection_object_id#
			</cfquery>
		<cfelse><!--- see if we need to add an entry --->
			<cfif len(#disposition_remarks#) gt 0 OR len(#coll_object_remarks#) gt 0 OR len(#habitat#) gt 0>
				<cfquery name="newBIRem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					INSERT INTO coll_object_remark (
						collection_object_id
						<cfif len(#disposition_remarks#) gt 0>
							,disposition_remarks
						</cfif>
						<cfif len(#coll_object_remarks#) gt 0>
							,coll_object_remarks
						</cfif>
						<cfif len(#habitat#) gt 0>
							,habitat
						</cfif>
						<cfif len(#associated_species#) gt 0>
							,associated_species
						</cfif>
						 ) VALUES (
						#collection_object_id#
						<cfif len(#disposition_remarks#) gt 0>
							,'#disposition_remarks#'
						</cfif>
						<cfif len(#coll_object_remarks#) gt 0>
							,'#coll_object_remarks#'
						</cfif>
						<cfif len(#habitat#) gt 0>
							,'#habitat#'
						</cfif>
						<cfif len(#associated_species#) gt 0>
							,'#associated_species#'
						</cfif> )
				</cfquery>
			</cfif>
		</cfif>				
	</cftransaction>
<cflocation url="editBiolIndiv.cfm?collection_object_id=#collection_object_id#">
</cfoutput>
</cfif>
<cfoutput>
<script type="text/javascript" language="javascript">
	changeStyle('#indiv.institution_acronym#');
//	var pDivH = document.getElementById('fHolder').height;
//	var fContentH = document.getElementById('theFrame').scrollHeight;
//	alert(pDivH);
//	alert(fContentH);
	parent.dyniframesize();
//parent.document.getElementById('fHolder').height = document.getElementById('theFrame').scrollHeight;
</script>
</script>
</cfoutput>