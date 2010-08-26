<cfinclude template="/includes/alwaysInclude.cfm">
<script language="javascript" type="text/javascript">
	jQuery(document).ready(function() {
		jQuery("input[id^='determined_date_']").each(function(){
			$("#" + this.id).datepicker();
		});
		$("#determined_date").datepicker();
		$("#mammgrid_determined_date").datepicker();
		$("input[id^='attribute_id_']").each(function(){
			//var attid=$("#" + this.id).val();
			populateAttribute($("#" + this.id).val());
			//parent.console.log('got att ID ' + attid);
			//parent.console.log(this.id);
		});
		
		
	});
	function populateAttribute(aid) {	
		parent.console.log('getting data for ' + aid + '::' + $("#attribute_type_" + aid).val());
		
		jQuery.getJSON("/component/DataEntry.cfc",
			{
				method : "getAttCodeTbl",
				attribute : $("#attribute_type_" + aid).val(),
				collection_cde : $("#collection_cde").val(),
				element : aid,
				returnformat : "json",
				queryformat : 'column'
			},
			success_populateAttribute
		);	
	}
	function success_populateAttribute (r) {
		
		var result=r.DATA;
		var resType=result.V[0];
		var aid=result.V[1];
		parent.console.log(aid);
		parent.console.log(r);
		aid='_' + aid;
		$("#attribute_value" + aid).remove();
		$("#attribute_units" + aid).remove();
		
		
		if (resType == 'value') {
			var d = '<select name="attribute_value' + aid + '" id="attribute_value' + aid + '">';
			d+='<option value=""></option>';
			for (i=2;i<result.V.length;i++) {
				d+='<option value="' + result.V[i] + '">' + result.V[i] + '</option>';
			}
			d+='</select>';
			$("#_attribute_value" + aid).append(d);
			$("#attribute_value" + aid).val($("#val" + aid).val());
		} else if (resType == 'units') {
			var d = '<select name="attribute_units' + aid + '" id="attribute_units' + aid + '">';
			d+='<option value=""></option>';
			for (i=2;i<result.V.length;i++) {
				d+='<option value="' + result.V[i] + '">' + result.V[i] + '</option>';
			}
			d+='</select>';
			$("#_attribute_units" + aid).append(d);
			$("#attribute_units" + aid).val($("#unit_" + aid).val());
			var t='<input type="text" name="attribute_value' + aid + '" id="attribute_value' + aid + '">';
			$("#_attribute_value" + aid).append(t);
			$("#attribute_value" + aid).val($("#val" + aid).val());
		} else {
			var t='<input type="text" name="attribute_value' + aid + '" id="attribute_value' + aid + '">';
			$("#_attribute_value" + aid).append(t);
			$("#attribute_value" + aid).val($("#val" + aid).val());
		}
	}
</script>
<cfif action is "nothing">
	<strong>Edit Individual Attributes</strong>
	<span class="infoLInk" onClick="windowOpener('/info/attributeHelpPick.cfm','','width=600,height=600, resizable,scrollbars');">Help</span>
	<cfoutput>
		<cfquery name="raw" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT
				COLL_OBJ_DISPOSITION,
				CONDITION,
				DISPOSITION_REMARKS,
				COLL_OBJECT_REMARKS,
				habitat,
				associated_species,
				flags,
				cat_num, 
				collection.collection_cde, 
				institution_acronym,
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
			FROM 
				cataloged_item,
				collection,
				attributes,
				preferred_agent_name,
				coll_object,
				coll_object_remark
			WHERE
				cataloged_item.collection_id = collection.collection_id AND
				cataloged_item.collection_object_id = attributes.collection_object_id (+) AND
				attributes.determined_by_agent_id = preferred_agent_name.agent_id (+) AND				
				cataloged_item.collection_object_id = coll_object.collection_object_id AND
				cataloged_item.collection_object_id = coll_object_remark.collection_object_id (+) AND
				cataloged_item.collection_object_id = #collection_object_id#
		</cfquery>
		
		<cfquery name="ctflags" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT flags from ctflags
		</cfquery>
		<cfquery name="indiv" dbtype="query">
			select 
				COLL_OBJ_DISPOSITION,
				CONDITION,
				CAT_NUM,
				collection_cde,
				DISPOSITION_REMARKS,
				COLL_OBJECT_REMARKS,
				habitat,
				associated_species,
				flags
			FROM
				raw
			group by
				COLL_OBJ_DISPOSITION,
				CONDITION,
				CAT_NUM,
				collection_cde,
				DISPOSITION_REMARKS,
				COLL_OBJECT_REMARKS,
				habitat,
				associated_species,
				flags
		</cfquery>
		<cfquery name="ctattribute_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT attribute_type FROM ctattribute_type where 
			collection_cde='#indiv.collection_cde#'
		</cfquery>
		<cfquery name="atts" dbtype="query">
			select
				collection_object_id, 
				ATTRIBUTE_ID,
				agent_name,
				determined_by_agent_id,
				ATTRIBUTE_TYPE,
				ATTRIBUTE_VALUE,
				attribute_units,
				ATTRIBUTE_REMARK,
				DETERMINED_DATE,
				DETERMINATION_METHOD
			from
				raw
			group by
				collection_object_id, 
				ATTRIBUTE_ID,
				agent_name,
				determined_by_agent_id,
				ATTRIBUTE_TYPE,
				ATTRIBUTE_VALUE,
				attribute_units,
				ATTRIBUTE_REMARK,
				DETERMINED_DATE,
				DETERMINATION_METHOD
		</cfquery>
		<cfquery name="ctdisp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select coll_obj_disposition from ctcoll_obj_disp
		</cfquery>
		<cfquery name="ctcoll" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select collection_cde from ctcollection_cde
		</cfquery>
		<form name="details" method="post" action="editBiolIndiv.cfm">
			<input type="hidden" value="saveNoAttEdits" name="Action">
			<input type="hidden" value="#collection_object_id#" name="collection_object_id">
			<input type="hidden" value="#indiv.collection_cde#" name="collection_cde" id="collection_cde">
    		<table>
      			<tr> 
			        <td>
				        <label for="coll_obj_disposition">Disposition</label>
				        <select name="coll_obj_disposition" id="coll_obj_disposition" size="1" class="reqdClr">
				            <cfloop query="ctdisp">
				              <option <cfif indiv.coll_obj_disposition is ctdisp.coll_obj_disposition> selected="selected" </cfif>
									value="#ctdisp.coll_obj_disposition#">#ctdisp.coll_obj_disposition#</option>
				            </cfloop>
			        	</select>
					</td>
        			<td>
						<label for="condition">Specimen Condition</label>
						<input type="text" name="condition" id="condition" value="#indiv.condition#" class="reqdClr">
						<span class="infoLink" onClick="chgCondition('#collection_object_id#')">history</span>
					</td>
					<td>
						<label for="flags">Missing</label>
						<select name="flags" id="flags" size="1">
							<option value=""></option>
							<cfloop query="ctflags">
								<option <cfif indiv.flags is ctflags.flags> selected="selected" </cfif>value="#flags#">#flags#</option>
							</cfloop>
						</select>
					</td>
				</tr>
			</table>
			<label for="disposition_remarks">Specimen Disposition Remarks</label>
			<input type="text" name="disposition_remarks" id="disposition_remarks" value="#indiv.disposition_remarks#" size="80">
			<label for="coll_object_remarks">Specimen Remarks</label>
			<textarea name="coll_object_remarks" id="coll_object_remarks" cols="80" rows="2">#indiv.coll_object_remarks#</textarea>
			<label for="habitat">Microhabitat</label>
			<textarea name="habitat" id="habitat" cols="80" rows="2">#indiv.habitat#</textarea>
			<label for="habitat">Associated Species</label>
			<textarea name="associated_species" id="associated_species" cols="80" rows="2">#indiv.associated_species#</textarea>
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
				<cfloop query="atts">
					<input type="hidden" name="number_of_attributes" id="number_of_attributes" value="#atts.recordcount#">
					<input type="hidden" name="attribute_id_#i#" id="attribute_id_#i#" value="#attribute_id#">
					<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
						<td>
							<input type="text" name="attribute_type_#attribute_id#" id="attribute_type_#attribute_id#" value="#attribute_type#" readonly="yes" class="readClr">
						</td>
						<td id="_attribute_value_#attribute_id#">
							<input type="hidden" name="val_#attribute_id#" id="val_#attribute_id#" value="#attribute_value#">
						</td>
						<td id="_attribute_units_#attribute_id#">
							<input type="hidden" name="unit_#attribute_id#" id="unit_#attribute_id#" value="#attribute_units#">
						</td>
						<td id="_remarks_#attribute_id#">
							<input type="text" name="attribute_remark_#attribute_id#" id="attribute_remark_#attribute_id#" value="#attribute_remark#">
						</td>
						<td id="_determined_date_#attribute_id#">
							<input type="text" name="determined_date_#attribute_id#" id="determined_date_#attribute_id#" 
								value="#dateformat(determined_date,'yyyy-mm-dd')#" class="reqdClr" size="12">
						</td>
						<td id="_determination_method_#attribute_id#">
							<input type="text" name="determination_method_#attribute_id#" id="determination_method_#attribute_id#" value="#determination_method#">
						</td>
						<td id="_agent_name_#attribute_id#">
							<input type="hidden" name="determined_by_agent_id_#attribute_id#" id="determined_by_agent_id_#attribute_id#" 
								value="#determined_by_agent_id#">
							<input type="text" name="agent_name_#attribute_id#" class="reqdClr" value="#agent_name#"
		 						onchange="getAgent('determined_by_agent_id_#attribute_id#',this.id,'details',this.value); return false;"
		  						onKeyPress="return noenter(event);">
						</td>
						<td>
							<input type="button" 
								value="Delete" 
								class="delBtn"
								onclick="deleteAttribute('#attribute_id#');">
						</td>
					</tr>
					<cfset i=i+1>
				</cfloop>
				<tr class="newRec">
					<td>
						<select name="attribute_type_new" id="attribute_type_new" size="1" onChange="populateAttribute('new');">
							<option value="">Create New Attribute</option>
							<cfloop query="ctattribute_type">
								<option value="#ctattribute_type.attribute_type#">#ctattribute_type.attribute_type#</option>
							</cfloop>
						</select>
					</td>
					<td id="_attribute_value_new">
					<td id="_attribute_units_new">
					<td id="remarks_new">
						<input type="text" name="attribute_remark" id="attribute_remark">
					</td>
					<td id="determined_date_new">
						<input type="text" name="determined_date" id="determined_date" size="12">
					</td>
					<td id="determination_method_new">
						<input type="text" name="determination_method" id="determination_method">
					</td>
					<td id="agent_name_new">
						<input type="hidden" name="determined_by_agent_id" id="determined_by_agent_id">
						<input type="text" name="agent_name" class="reqdClr"
	 						onchange="getAgent('determined_by_agent_id',this.id,'details',this.value); return false;"
	  						onKeyPress="return noenter(event);">
					</td>
					<td>
						
					</td>
				</tr>
			</table>
			<cfif indiv.collection_cde is "Mamm">
				<cfquery name="ctlength_units" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select length_units from ctlength_units order by length_units
				</cfquery>
				<cfquery name="ctweight_units" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select weight_units from ctweight_units order by weight_units
				</cfquery>
				<label for="mammatttab">Existing values will NOT show up in this grid; add mammal attributes only.</label>
				<table id="mammatttab" class="newRec">
					<tr>
						<td>
							<label for="total_length">Total</label>
							<input type="text" name="total_length" size="4">
							<select name="total_length_units" size="1">
								<cfloop query="ctlength_units">
									<option <cfif length_units is "mm"> selected="selected" </cfif>
										value="#ctlength_units.length_units#">#ctlength_units.length_units#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<label for="tail_length">Tail</label>
							<input type="text" name="tail_length" size="4">
							<select name="tail_length_units" size="1">
								<cfloop query="ctlength_units">
									<option <cfif length_units is "mm"> selected="selected" </cfif>
										value="#ctlength_units.length_units#">#ctlength_units.length_units#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<label for="hind_foot_with_claw">HF(c)</label>
							<input type="text" name="hind_foot_with_claw" size="4">
							<select name="hind_foot_with_claw_units" size="1">
								<cfloop query="ctlength_units">
									<option <cfif length_units is "mm"> selected="selected" </cfif>
										value="#ctlength_units.length_units#">#ctlength_units.length_units#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<label for="ear_from_notch">EFN</label>
							<input type="text" name="ear_from_notch" size="4">
							<select name="ear_from_notch_units" size="1">
								<cfloop query="ctlength_units">
									<option <cfif length_units is "mm"> selected="selected" </cfif>
										value="#ctlength_units.length_units#">#ctlength_units.length_units#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<label for="weight">WT</label>
							<input type="text" name="weight" size="4">
							<select name="weight_units" size="1">
								<cfloop query="ctweight_units">
									<option <cfif weight_units is "g"> selected="selected" </cfif>
										value="#ctweight_units.weight_units#">#ctweight_units.weight_units#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<label for="determined_date">Date</label>
							<input type="text" name="determined_date" id="mammgrid_determined_date" size="10">
						</td>
						<td>
							<label for="mammgrid_detagentid">Determiner</label>
							<input type="hidden" name="mammgrid_detagentid">
							<input type="text" name="mammgrid_determiner" class="reqdClr"
								onchange="getAgent('mammgrid_detagentid',this.name,'details',this.value); return false;">
						</td>
					</tr>
				</table>
			</cfif>
			<br>
			<input type="submit" value="save">
		</form>
	</cfoutput>
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
		,DETERMINED_DATE='#dateformat(thisDeterminedDate,"yyyy-mm-dd")#'
		<cfif len(#thisDeterminationMethod#) gt 0>
			,DETERMINATION_METHOD='#thisDeterminationMethod#'
			<cfelse>
				,DETERMINATION_METHOD=null
		</cfif> 
	WHERE attribute_id=#thisAttributeId#
	</cfquery>
</cfloop>
	 <cflocation url="editBiolIndiv.cfm?collection_object_id=#collection_object_id#">   
	
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------>
<cfif #Action# is "deleteAttribute">
<cfoutput>
	<cfquery name="del" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		DELETE FROM attributes WHERE attribute_id=#attribute_id#
	</cfquery>
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
					,'#dateformat(DETERMINED_DATE,"yyyy-mm-dd")#')
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
						,'#dateformat(DETERMINED_DATE,"yyyy-mm-dd")#')
				</cfquery>
			</cfif>
			<cfif len(#hind_foot_with_claw#) gt 0>
				<cfquery name="hind_foot_with_claw" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
						,'hind foot with claw'
						,'#hind_foot_with_claw#'
						,'#hind_foot_with_claw_units#'
						,'#dateformat(DETERMINED_DATE,"yyyy-mm-dd")#')
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
						,'#dateformat(DETERMINED_DATE,"yyyy-mm-dd")#')
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
						,'#dateformat(DETERMINED_DATE,"yyyy-mm-dd")#')
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
		,'#dateformat(DETERMINED_DATE,"yyyy-mm-dd")#'
		<cfif len(#DETERMINATION_METHOD#) gt 0>
			,'#DETERMINATION_METHOD#'
		</cfif> )
	</cfquery>
<cflocation url="editBiolIndiv.cfm?collection_object_id=#collection_object_id#"> </cfoutput>
</cfif>
<!------------------------------------------------------------------------------>
<cfif #Action# is "saveNoAttEdits">
<cfoutput>
	<cftransaction>
		<cfquery name="upCollObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			UPDATE coll_object SET
				last_edited_person_id = #session.myAgentId#
				,last_edit_date = sysdate
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
<cf_customizeIFrame>