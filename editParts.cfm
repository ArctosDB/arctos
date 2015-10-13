<cfinclude template="/includes/_header.cfm">
<cf_customizeIFrame>
<cfif action is "nothing">
<script language="javascript" type="text/javascript">
	jQuery(document).ready(function() {
		$(".reqdClr:visible").each(function(e){
		    $(this).prop('required',true);
		});
	});
</script>
	<cfoutput>
	<cfquery name="raw" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		SELECT
			specimen_part.collection_object_id as partID,
			specimen_part.part_name,
			coll_object.coll_obj_disposition,
			coll_object.condition,
			specimen_part.sampled_from_obj_id,
			cataloged_item.collection_cde,
			coll_object.lot_count,
			parentContainer.barcode,
			parentContainer.label,
			parentContainer.container_id AS parentContainerId,
			thisContainer.container_id AS partContainerId,
			coll_object_remark.coll_object_remarks,
			specimen_part_attribute.part_attribute_id,
			specimen_part_attribute.attribute_type,
			specimen_part_attribute.attribute_value,
			specimen_part_attribute.attribute_units,
			specimen_part_attribute.determined_date,
			specimen_part_attribute.determined_by_agent_id,
			getPreferredAgentName(specimen_part_attribute.determined_by_agent_id) part_attribute_determiner,
			specimen_part_attribute.attribute_remark
		FROM
			cataloged_item
			INNER JOIN collection ON (cataloged_item.collection_id = collection.collection_id)
			LEFT OUTER JOIN specimen_part ON (cataloged_item.collection_object_id = specimen_part.derived_from_cat_item)
			LEFT OUTER JOIN specimen_part_attribute ON (specimen_part.collection_object_id = specimen_part_attribute.collection_object_id)
			LEFT OUTER JOIN coll_object ON (specimen_part.collection_object_id = coll_object.collection_object_id)
			LEFT OUTER JOIN coll_obj_cont_hist ON (specimen_part.collection_object_id = coll_obj_cont_hist.collection_object_id)
			LEFT OUTER JOIN container thisContainer ON (coll_obj_cont_hist.container_id = thisContainer.container_id)
			LEFT OUTER JOIN container parentContainer ON (thisContainer.parent_container_id = parentContainer.container_id)
			LEFT OUTER JOIN coll_object_remark ON (specimen_part.collection_object_id = coll_object_remark.collection_object_id)
		WHERE
			cataloged_item.collection_object_id = #collection_object_id#
		ORDER BY sampled_from_obj_id DESC,part_name ASC
	</cfquery>
	<cfquery name="ctDisp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select coll_obj_disposition from ctcoll_obj_disp order by coll_obj_disposition
	</cfquery>
	<cfquery name="getParts" dbtype="query">
		select
			partID,
			part_name,
			coll_obj_disposition,
			condition,
			sampled_from_obj_id,
			collection_cde,
			lot_count,
			barcode,
			label,
			parentContainerId,
			partContainerId,
			coll_object_remarks
		from raw
		group by
			partID,
			part_name,
			coll_obj_disposition,
			condition,
			sampled_from_obj_id,
			collection_cde,
			lot_count,
			barcode,
			label,
			parentContainerId,
			partContainerId,
			coll_object_remarks
		ORDER BY sampled_from_obj_id DESC,part_name ASC
	</cfquery>
 	<b>Edit #getParts.recordcount# Specimen Parts</b>&nbsp;<span class="infoLink" onClick="getDocs('parts')">help</span>
	<br><a href="/findContainer.cfm?collection_object_id=#collection_object_id#">Part Locations</a>
	<cfset i = 1>
	<cfset listedParts = "">
	<form name="parts" method="post" action="editParts.cfm">
		<input type="hidden" name="action" value="saveEdits">
		<input type="hidden" name="collection_object_id" value="#collection_object_id#">
	<table border>
	<cfloop query="getParts">
		<cfif len(getParts.partID) gt 0>
			<input type="hidden" name="partID#i#" value="#getParts.partID#">
			<!--- next couple lines and the if statement stop us from putting the same part in the
			grid twice, which seems to happen when tehre are 2 parts in different containers -
			voodoo solution, but it works.....
			---->
			<cfif not #listcontains(listedParts, getParts.partID)#>
				<cfset listedParts = "#listedParts#,#getParts.partID#">
			<cfif i mod 2 eq 0>
				<cfset bgc = "##C0C0C0">
			<cfelse>
				<cfset bgc="##F5F5F5">
			</cfif>
			<cfset lblClr = "red">
			<cfif len(sampled_from_obj_id) gt 0>
				<cfset bgc="##669999">
			</cfif>
				<tr bgcolor="#bgc#">
					<td>
						<label for="part_name#i#">
							Part
							<cfif len(sampled_from_obj_id) gt 0>
								Subsample
							</cfif>
							&nbsp;<span class="likeLink" style="font-weight:100" onClick="getCtDoc('ctspecimen_part_name')">[ Define values ]</span>
						</label>
						<input type="text" name="part_name#i#" id="part_name#i#" class="reqdClr"
							value="#getParts.part_name#" size="25"
							onchange="findPart(this.id,this.value,'#getParts.collection_cde#');"
							onkeypress="return noenter(event);">
					</td>
					<td>
						<label for="coll_obj_disposition#i#">Disposition</label>
						<select name="coll_obj_disposition#i#" size="1" class="reqdClr" style="width:150px";>
			              <cfloop query="ctDisp">
				              <option <cfif ctdisp.coll_obj_disposition is getParts.coll_obj_disposition> selected </cfif>value="#ctDisp.coll_obj_disposition#">#ctDisp.coll_obj_disposition#</option>
			              </cfloop>
			            </select>
					</td>
					<td>
						<label for="condition#i#">Condition&nbsp;<span class="likeLink" style="font-weight:100" onClick="chgCondition('#getParts.partID#')">[ History ]</span></label>
						<textarea name="condition#i#" id="condition#i#" class="reqdClr mediumtextarea">#getparts.condition#</textarea>
					</td>
					<td>
						<label for="lot_count#i#">##</label>
						<input type="text" id="lot_count#i#" name="lot_count#i#" value="#getparts.lot_count#"  class="reqdClr" size="2">
					</td>
					<td>
						<label for="label#i#">In Container Label</label>
						<span style="font-size:small">
							<cfif len(getparts.label) gt 0>
								#getparts.label#
							<cfelse>
								-NONE-
							</cfif>
						</span>
						<input type="hidden" name="label#i#" value="#getparts.label#">
						<input type="hidden" name="parentContainerId#i#" value="#getparts.parentContainerId#">
						<input type="hidden" name="partContainerId#i#" value="#getparts.partContainerId#">
					</td>
					<td>
						<label for="newCode#i#">Add to barcode</label>
						<input type="text" name="newCode#i#" id="newCode#i#" size="10">
					</td>
					<td>
						<label for="coll_object_remarks#i#">Remark</label>
						<textarea name="coll_object_remarks#i#" id="coll_object_remarks#i#" class="smalltextarea">#stripQuotes(getparts.coll_object_remarks)#</textarea>
					</td>

					<td align="middle">
						<input type="button" value="Delete" class="delBtn"
							onclick="parts.action.value='deletePart';parts.partID.value='#partID#';confirmDelete('parts','#part_name#');">
						<br>
						<span class="infoLink"
						<input type="button"
							value="Copy"
							class="insBtn"
							onClick="newPart.part_name.value='#part_name#';
								newPart.lot_count.value='#lot_count#';
								newPart.coll_obj_disposition.value='#coll_obj_disposition#';
								newPart.condition.value='#condition#';
								newPart.coll_object_remarks.value='#coll_object_remarks#';">
					</td>
				</tr>
				<cfquery name="pAtt" dbtype="query">
					select
						 part_attribute_id,
						 attribute_type,
						 attribute_value,
						 attribute_units,
						 determined_date,
						 determined_by_agent_id,
						 attribute_remark,
						 part_attribute_determiner agent_name
					from
						raw
					where
						part_attribute_id is not null and
						partID=#partID#
				</cfquery>
				<tr bgcolor="#bgc#">
					<td colspan="8" align="center">
						<cfif pAtt.recordcount gt 0>
						<table border>
							<tr>
								<th>Attribute</th>
								<th>Value</th>
								<th>Units</th>
								<th>Date</th>
								<th>DeterminedBy</th>
								<th>Remark</th>
							</tr>
							<cfloop query="pAtt">
								<tr>
									<td>#attribute_type#</td>
									<td>
										#attribute_value#&nbsp;
									</td>
									<td>
										#attribute_units#&nbsp;
									</td>
									<td>
										#dateformat(determined_date,"yyyy-mm-dd")#&nbsp;
									</td>
									<td>
										#agent_name#&nbsp;
									</td>
									<td>
										#attribute_remark#&nbsp;
									</td>
								</tr>
							</cfloop>
						</td>
					</table>
					<cfelse>
						--no attributes--
					</cfif>
					<td><input type="button" value="Manage Attributes" class="savBtn"
			   			onclick="mgPartAtts(#partID#);">
					</td>
				</tr>
				<cfset i = i+1>
	     </cfif><!---- end of the list ---->
	</cfif>
</cfloop>
<tr bgcolor="##00CC00">
	<td colspan="10" align="center">
		<input type="button" value="Save All Changes" class="savBtn"
		   onclick="parts.action.value='saveEdits';submit();">
   </td>
</tr>
<cfset numberOfParts= #i# - 1>
<input type="hidden" name="NumberOfParts" value="#numberOfParts#">
<input type="hidden" name="partID">
 </form>


</table>
<a name="newPart"></a>

<table class="newRec"><tr><td>
<strong>Add Specimen Part</strong>
<form name="newPart" method="post" action="editParts.cfm">
	<input type="hidden" name="Action" value="newPart">
	<input type="hidden" name="collection_object_id" value="#collection_object_id#">
    <table>
      <tr>
        <td><div align="right">Part Name: </div></td>
        <td>
			<input type="text" name="part_name" id="part_name" class="reqdClr" placeholder="type and tab to pick"
				onchange="findPart(this.id,this.value,'#getParts.collection_cde#');"
				onkeypress="return noenter(event);">
		</td>
      </tr>
	   <tr>
        <td><div align="right">Count:</div></td>
        <td><input type="number" min="0" max="9999" name="lot_count" class="reqdClr" size="2"></td>
      </tr>
      <tr>
        <td><div align="right">Disposition:</div></td>
        <td><select name="coll_obj_disposition" size="1"  class="reqdClr">
            <cfloop query="ctDisp">
              <option value="#ctDisp.coll_obj_disposition#">#ctDisp.coll_obj_disposition#</option>
            </cfloop>
          </select></td>
      </tr>
      <tr>
        <td><div align="right">Condition:</div></td>
        <td><input type="text" name="condition" class="reqdClr" placeholder="describe item condition"></td>
      </tr>
	    <tr>
        <td><div align="right">Remarks:</div></td>
        <td><input type="text" name="coll_object_remarks"></td>
      </tr>
      <tr>
        <td colspan="2"><div align="center">
           <input type="submit" value="Create" class="insBtn">
          </div></td>
      </tr>

    </table>

  </form>

</td></tr></table>

</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------->

<!----------------------------------------------------------------------------------->
<cfif #Action# is "deletePart">

<cfoutput>


	<cftransaction>
	<cfquery name="delePart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		DELETE FROM specimen_part WHERE collection_object_id = #partID#
	</cfquery>
</cftransaction>
<cflocation url="editParts.cfm?collection_object_id=#collection_object_id#">
</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------->
<cfif #Action# is "saveEdits">
<cfoutput>
	<cftransaction>
	<cfloop from="1" to="#numberOfParts#" index="n">
		<cfset thisPartId = #evaluate("partID" & n)#>
		<cfset thisPartName = #evaluate("Part_name" & n)#>
		<cfset thisDisposition = #evaluate("coll_obj_disposition" & n)#>
		<cfset thisCondition = #evaluate("condition" & n)#>
		<cfset thisLotCount = #evaluate("lot_count" & n)#>
		<cfset thiscoll_object_remarks = #evaluate("coll_object_remarks" & n)#>
		<cfset thisnewCode = #evaluate("newCode" & n)#>
		<cfset thislabel = #evaluate("label" & n)#>
		<cfset thisparentContainerId = #evaluate("parentContainerId" & n)#>
		<cfset thispartContainerId = #evaluate("partContainerId" & n)#>
		<cfquery name="upPart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			UPDATE specimen_part SET
				Part_name = '#thisPartName#'
			WHERE collection_object_id = #thisPartId#
		</cfquery>
		<cfquery name="upPartCollObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			UPDATE coll_object SET
				coll_obj_disposition = '#thisDisposition#'
				,condition = '#thisCondition#',
				lot_count = #thisLotCount#
			WHERE collection_object_id = #thisPartId#
		</cfquery>
		<cfif len(thiscoll_object_remarks) gt 0>
			<cfquery name="ispartRem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select coll_object_remarks from coll_object_remark where
				collection_object_id = #thisPartId#
			</cfquery>
			<cfif ispartRem.recordcount is 0>
				<cfquery name="newCollRem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					INSERT INTO coll_object_remark (collection_object_id, coll_object_remarks)
					VALUES (#thisPartId#, '#thiscoll_object_remarks#')
				</cfquery>
			<cfelse>
				<cfquery name="updateCollRem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					UPDATE coll_object_remark SET
					coll_object_remarks = '#thiscoll_object_remarks#'
					 WHERE collection_object_id = #thisPartId#
				</cfquery>
			</cfif>
		<cfelse>
			<cfquery name="killRem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				UPDATE coll_object_remark SET
				coll_object_remarks = null
				 WHERE collection_object_id = #thisPartId#
			</cfquery>
		</cfif>
		<cfif len(thisnewCode) gt 0>
			<br>thisPartId: #thisPartId#
			<br>thisnewCode: #thisnewCode#
			<br>go
			<br>movePartToContainer(#thisPartId#,'#thisnewCode#','','');
			<cfstoredproc procedure="movePartToContainer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				<cfprocparam cfsqltype="CF_SQL_FLOAT" value="#thisPartId#"><!---- v_collection_object_id ---->
				<cfprocparam cfsqltype="cf_sql_varchar" value="#thisnewCode#"><!---- v_barcode ---->
				<cfprocparam cfsqltype="cf_sql_varchar" value=""><!---- v_container_id ---->
				<cfprocparam cfsqltype="cf_sql_varchar" value=""><!---- v_parent_container_type ---->
			</cfstoredproc>
			<br>back
		</cfif>
		<!----

			<cfquery name="isCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				SELECT
					container_id, container_type, parent_container_id
				FROM
					container
				WHERE
					barcode = '#thisnewCode#'
					AND container_type <> 'collection object'
			</cfquery>
			<cfif #isCont.container_type# is 'cryovial label'>
				<cfquery name="upCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update container set container_type='cryovial'
					where container_id=#isCont.container_id# and
					container_type='cryovial label'
				</cfquery>
			</cfif>
			<cfif isCont.recordcount is 1>
				<cfquery name="thisCollCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					SELECT
						container_id
					FROM
						coll_obj_cont_hist
					WHERE
					collection_object_id = #thisPartId#
				</cfquery>
				<cfquery name="upPartBC" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					UPDATE
						container
					SET
						parent_container_id = #isCont.container_id#
					WHERE
						container_id = #thisCollCont.container_id#
				</cfquery>
				<cfquery name="upPartPLF" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					UPDATE container SET print_fg = #thisprint_fg# WHERE
					container_id = #isCont.container_id#
				</cfquery>
			</cfif>
			<cfif isCont.recordcount lt 1>
				That barcode was not found in the container database. You can only put parts into appropriate pre-existing containers.
				<br>Click <a href="editParts.cfm?collection_object_id=#collection_object_id#">here</a> to return to editing parts.
				<cfabort>
			</cfif>
			<cfif #isCont.recordcount# gt 1>
				That barcode has multiple matches!! Something really bad has happened!! Please
			 	<a href="mailto:#application.bugReportEmail#">contact us</a>!
				<cfabort>
			</cfif>

		</cfif>
		<cfif len(thislabel) gt 0>
			<cfquery name="upPartPLF" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				UPDATE container SET print_fg = #thisprint_fg# WHERE
				container_id = #thisparentContainerId#
			</cfquery>
		</cfif>
		<cfif len(#thislabel#) is 0 AND len(#thisparentContainerId#) gt 0 AND #thisprint_fg# gt 0>
			<font color="##FF0000" size="+1">
				You tried to flag a part for labels, but that part isn't in a container. There's nothing to print!
			</font>
			<cfabort>
		</cfif>
		---->
	</cfloop>
	</cftransaction>
	<cflocation url="editParts.cfm?collection_object_id=#collection_object_id#">
</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------->
<cfif #Action# is "newpart">
	<cfquery name= "getEntBy" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		SELECT agent_id FROM agent_name WHERE agent_name = '#session.username#'  group by agent_id
	</cfquery>
				<cfif getEntBy.recordcount is 0>
					<cfabort showerror = "You aren't a recognized agent!">
				<cfelseif getEntBy.recordcount gt 1>
					<cfabort showerror = "Your login has has multiple matches.">
				</cfif>
				<cfset enteredbyid = getEntBy.agent_id>
	<cftransaction>
	<cfquery name="updateColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		INSERT INTO coll_object (
			COLLECTION_OBJECT_ID,
			COLL_OBJECT_TYPE,
			ENTERED_PERSON_ID,
			COLL_OBJECT_ENTERED_DATE,
			LAST_EDITED_PERSON_ID,
			COLL_OBJ_DISPOSITION,
			LOT_COUNT,
			CONDITION,
			FLAGS )
		VALUES (
			sq_collection_object_id.nextval,
			'SP',
			#enteredbyid#,
			sysdate,
			#enteredbyid#,
			'#COLL_OBJ_DISPOSITION#',
			#lot_count#,
			'#condition#',
			0 )
	</cfquery>
	<cfquery name="newTiss" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		INSERT INTO specimen_part (
			  COLLECTION_OBJECT_ID,
			  PART_NAME
				,DERIVED_FROM_cat_item)
			VALUES (
				sq_collection_object_id.currval,
			  '#PART_NAME#'
				,#collection_object_id#)
	</cfquery>
	<cfif len(#coll_object_remarks#) gt 0>
			<!---- new remark --->
			<cfquery name="newCollRem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				INSERT INTO coll_object_remark (collection_object_id, coll_object_remarks)
				VALUES (sq_collection_object_id.currval, '#coll_object_remarks#')
			</cfquery>
	</cfif>
	</cftransaction>
	<cflocation url="editParts.cfm?collection_object_id=#collection_object_id#">
</cfif>
<!----------------------------------------------------------------------------------->
