<cfinclude template="/includes/_header.cfm">
<cf_customizeIFrame>
<cfif action is "nothing">

<style>
	.relted {border:5px solid red;}
</style>
	<script language="javascript" type="text/javascript">
		jQuery(document).ready(function() {
			$(".reqdClr:visible").each(function(e){
			    $(this).prop('required',true);
			});

		$(".ssspn").hover(function(){
			$("#" + $(this).attr("data-pid") ).addClass('relted');
			 },
		    function(){
		        $("#" + $(this).attr("data-pid") ).addClass('blue');
		    });






});




		function createSubsample(i){
				 var r = confirm("Create a new part as a subsample of this part?");
				 if (r == true) {
				 	$("#ssinfodiv").html('Creating a subsample of ' + $('#part_name' + i).val() + ' (ID=' + $("#partID" + i).val() + ')');
				 	$("#parent_part_id").val($("#partID" + i).val());
				 	$("#newPart input[name=part_name]").val($('#part_name' + i).val());
				 	$("#newPart input[name=lot_count]").val($('#lot_count' + i).val());
				 	$("#newPart input[name=coll_obj_disposition]").val($('#coll_obj_disposition' + i).val());
				 	$("#newPart input[name=condition]").val($('#condition' + i).val());
				 	$("#newPart input[name=coll_object_remarks]").val($('#coll_object_remarks' + i).val());
				}
			}
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
		<cfquery name="thisCollectionCde" dbtype="query">
			select collection_cde from raw group by collection_cde
		</cfquery>



<cfquery name="ploan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT
				loan.loan_number,
				loan.transaction_id,
				loan_item.collection_object_id
			FROM
				loan,
				loan_item,
				specimen_part
			WHERE
				loan.transaction_id=loan_item.transaction_id and
				loan_item.collection_object_id=specimen_part.collection_object_id AND
				specimen_part.derived_from_cat_item=#collection_object_id#
		</cfquery>

<cfquery name="orderedparts" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select
		collection_object_id part_id,
 		level,
 		part_name
	from (
 		SELECT
			SAMPLED_FROM_OBJ_ID,
			collection_object_id,
			part_name
		FROM
			specimen_part
 		where
			derived_from_cat_item=#collection_object_id#
 		)
	START WITH SAMPLED_FROM_OBJ_ID is null
	CONNECT BY PRIOR collection_object_id = SAMPLED_FROM_OBJ_ID
	ORDER SIBLINGS BY part_name
</cfquery>









<cffunction name="getChildParts"  returnType="string">
	<!---- build table row(s) for one part and any attributes ---->

	<cfargument name="pid" type="string" required="yes">
	<cfargument name="level" type="string" required="yes">
	<cfargument name="p_q" type="query" required="yes">
	<cfargument name="l_q" type="query" required="yes">
	<cfargument name="i" type="string" required="yes">




		<cfquery name="ctDisp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select coll_obj_disposition from ctcoll_obj_disp order by coll_obj_disposition
		</cfquery>


	<cfquery name="p" dbtype="query">
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
		from
			p_q
		where
			partID=#pid#
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
	</cfquery>


	<cfsavecontent variable="r">
		<cfset pdg=level-1>



		<cfloop query="p">
			<input type="hidden" name="partID#i#" id="partID#i#"  value="#pid#">

							<tr>
								<td>
									<div style="padding-left:#pdg#em;">
									<label for="part_name#pid#">
										Part
										<div id="pid_#partID#">
											#partID#
										</div>
										<cfif len(sampled_from_obj_id) gt 0>
											<br>Subsampled from <span class="ssspn" data-pid="pid_#partID#">#sampled_from_obj_id#</span>#sampled_from_obj_id#
										</cfif>
										<br><span class="likeLink" style="font-weight:100" onClick="getCtDoc('ctspecimen_part_name')">[ Define values ]</span>

									</label>
									<input type="text" name="part_name#i#" id="part_name#i#" class="reqdClr"
										value="#p.part_name#" size="25"
										onchange="findPart(this.id,this.value,'#p.collection_cde#');"
										onkeypress="return noenter(event);">
									</div>
								</td>
								<td>
									<label for="coll_obj_disposition#i#">Disposition</label>
									<select name="coll_obj_disposition#i#" id="coll_obj_disposition#i#" size="1" class="reqdClr" style="width:150px";>
						              <cfloop query="ctDisp">
							              <option <cfif ctdisp.coll_obj_disposition is p.coll_obj_disposition> selected </cfif>value="#ctDisp.coll_obj_disposition#">#ctDisp.coll_obj_disposition#</option>
						              </cfloop>
						            </select>
								</td>
								<td>
									<label for="condition#i#">Condition&nbsp;<span class="likeLink" style="font-weight:100" onClick="chgCondition('#p.partID#')">[ History ]</span></label>
									<textarea name="condition#i#" id="condition#i#" class="reqdClr mediumtextarea">#p.condition#</textarea>
								</td>
								<td>
									<label for="lot_count#i#">##</label>
									<input type="text" id="lot_count#i#" name="lot_count#i#" value="#p.lot_count#"  class="reqdClr" size="2">
								</td>
								<td>
									<label for="label#i#">In Container Label</label>
									<span style="font-size:small">
										<cfif len(p.label) gt 0>
											#p.label#
										<cfelse>
											-NONE-
										</cfif>
									</span>
									<input type="hidden" name="label#i#" value="#p.label#">
									<input type="hidden" name="parentContainerId#i#" value="#p.parentContainerId#">
									<input type="hidden" name="partContainerId#i#" value="#p.partContainerId#">
								</td>
								<td>
									<label for="newCode#i#">Add to barcode</label>
									<input type="text" name="newCode#i#" id="newCode#i#" size="10">
								</td>
								<td>
									<label for="coll_object_remarks#i#">Remark</label>
									<textarea name="coll_object_remarks#i#" id="coll_object_remarks#i#" class="smalltextarea">#stripQuotes(p.coll_object_remarks)#</textarea>
								</td>
								<cfquery dbtype="query" name="tlp">
									select * from l_q where transaction_id is not null and collection_object_id=#p.partID#
								</cfquery>
								<td>
									<cfloop query="tlp">
										<div>
											<a href="/Loan.cfm?action=editLoan&transaction_id=#transaction_id#">#loan_number#</a>
										</div>
									</cfloop>
								</td>
								<td align="middle">
									<input type="button" value="Delete" class="delBtn"
										onclick="parts.action.value='deletePart';parts.partID.value='#p.partID#';confirmDelete('parts','#p.part_name#');">
									<input type="button"
										value="Copy"
										class="insBtn"
										onClick="newPart.part_name.value='#p.part_name#';
											newPart.lot_count.value='#p.lot_count#';
											newPart.coll_obj_disposition.value='#p.coll_obj_disposition#';
											newPart.condition.value='#p.condition#';
											newPart.coll_object_remarks.value='#p.coll_object_remarks#';">
									<input type="button"
										value="Subsample"
										class="insBtn"
										onClick="createSubsample(#i#)">
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
									partID=#p.partID#
							</cfquery>
							<tr >
								<td colspan="8" align="center">
								<div style="padding-left:#level#em;">


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
										</div>
									</td>
								</table>
								<cfelse>
									--no attributes--
								</cfif>
								<td><input type="button" value="Manage Attributes" class="savBtn"
						   			onclick="mgPartAtts(#partID#);">
								</td>
							</tr>
				</cfloop>

				<!----


		<tr>
			<td>
				<div style="padding-left:#pdg#em;">
					#p.part_name#
				</div>
			</td>
			<td>#p.part_condition#</td>
			<td>#p.part_disposition#</td>
			<td>#p.lot_count#</td>
			<cfif oneOfUs is 1>
				<td>#p.label#</td>
				<td>#p.barcode#</td>
				<td>#replace(p.FCTree,':','←<wbr>','all')#</td>
				<cfquery dbtype="query" name="tlp">
					select * from l_q where transaction_id is not null and collection_object_id=#pid#
				</cfquery>
				<td>
					<cfloop query="tlp">
						<div>
							<a href="/Loan.cfm?action=editLoan&transaction_id=#transaction_id#">#loan_number# (#LOAN_STATUS#)</a>
						</div>
					</cfloop>
				</td>
			</cfif>
			<td>#p.part_remarks#</td>
		</tr>
		<cfquery name="patt" dbtype="query">
			select
				attribute_type,
				attribute_value,
				attribute_units,
				determined_date,
				attribute_remark,
				agent_name
			from
				p_q
			where
				attribute_type is not null and
				part_id=#pid#
			group by
				attribute_type,
				attribute_value,
				attribute_units,
				determined_date,
				attribute_remark,
				agent_name
			order by
				attribute_type,
				determined_date
		</cfquery>
		<cfif patt.recordcount gt 0>
			<tr>
				<td colspan="6">
					<div style="padding-left:#level#em;">

					<table border id="patbl#pid#" class="detailCellSmall sortable">
						<tr>
							<th>
								Attribute
							</th>
							<th>
								Value
							</th>
							<th>
								Date
							</th>
							<th>
								Dtr.
							</th>
							<th>
								Rmk.
							</th>
						</tr>
						<cfloop query="patt">
							<tr>
								<td>
									#attribute_type#
								</td>
								<cfif not(oneOfUs) and attribute_type is "location" and one.encumbranceDetail contains "mask part attribute location">
									<td>masked</td>
									<td>-</td>
									<td>-</td>
									<td>-</td>
								<cfelse>
									<td>#attribute_value# <cfif len(attribute_units) gt 0>#attribute_units#</cfif></td>
									<td>#dateformat(determined_date,'yyyy-mm-dd')#</td>
									<td>#agent_name#</td>
									<td>#attribute_remark#</td>
								</cfif>
							</tr>
						</cfloop>
					</table>
					</div>
				</td>
			</tr>
		</cfif>
		---->
	</cfsavecontent>
<cfreturn r>
</cffunction>











	<b>Edit #orderedparts.recordcount# Specimen Parts</b>&nbsp;<span class="helpLink" data-helplink="parts">help</span>
		<br><a href="/findContainer.cfm?collection_object_id=#collection_object_id#">Part Locations</a>

<form name="parts" method="post" action="editParts.cfm">
			<input type="hidden" name="action" value="saveEdits">
			<input type="hidden" name="collection_object_id" value="#collection_object_id#">



			<table border>
				<cfset i=1>
				<cfloop query="orderedparts">
					<cfset zxc=getChildParts(part_id,level,raw,ploan,i)>
					#zxc#
					<cfset i=i+1>
				</cfloop>
			</table>

			<table border>

				<tr bgcolor="##00CC00">
					<td colspan="10" align="center">
						<input type="button" value="Save All Changes" class="savBtn"
						   onclick="parts.action.value='saveEdits';submit();">
				   </td>
				</tr>
				<cfset numberOfParts= #i# - 1>
				<input type="hidden" name="NumberOfParts" value="#orderedparts.recordcount#">
				<input type="hidden" name="partID">
			</table>
		</form>

<!----



		<!--- just parts ---->
		<cfquery name="partsOnly" dbtype="query">
			select
				partID,
				part_name,
				coll_obj_disposition,
				condition,
				sampled_from_obj_id,
				lot_count,
				barcode,
				label,
				parentContainerId,
				partContainerId,
				coll_object_remarks
			from
				raw
			where
				partID is not null and
				sampled_from_obj_id is null
			group by
				partID,
				part_name,
				coll_obj_disposition,
				condition,
				sampled_from_obj_id,
				lot_count,
				barcode,
				label,
				parentContainerId,
				partContainerId,
				coll_object_remarks
			order by
				part_name
		</cfquery>
		<!--- just the object, no data ---->
		<cfquery name="getParts" dbtype="query">
			select
				'' as ordr,
				partID,
				part_name,
				coll_obj_disposition,
				condition,
				sampled_from_obj_id,
				lot_count,
				barcode,
				label,
				parentContainerId,
				partContainerId,
				coll_object_remarks
			from raw
			where
			1=2
		</cfquery>
		<cfset rnum=1>
		<cfloop query="partsOnly">
			<cfset queryAddRow(getParts)>
			<cfset querySetCell(getParts,"ordr",rnum,rnum)>
			<cfset querySetCell(getParts,"partID",partID,rnum)>
			<cfset querySetCell(getParts,"part_name",part_name,rnum)>
			<cfset querySetCell(getParts,"coll_obj_disposition",coll_obj_disposition,rnum)>
			<cfset querySetCell(getParts,"condition",condition,rnum)>
			<cfset querySetCell(getParts,"sampled_from_obj_id",sampled_from_obj_id,rnum)>
			<cfset querySetCell(getParts,"lot_count",lot_count,rnum)>
			<cfset querySetCell(getParts,"barcode",barcode,rnum)>
			<cfset querySetCell(getParts,"label",label,rnum)>
			<cfset querySetCell(getParts,"parentContainerId",parentContainerId,rnum)>
			<cfset querySetCell(getParts,"partContainerId",partContainerId,rnum)>
			<cfset querySetCell(getParts,"coll_object_remarks",coll_object_remarks,rnum)>
			<cfset rnum=rnum+1>
			<cfquery name="thisSS" dbtype="query">
				select
					partID,
					part_name,
					coll_obj_disposition,
					condition,
					sampled_from_obj_id,
					lot_count,
					barcode,
					label,
					parentContainerId,
					partContainerId,
					coll_object_remarks
				from
					raw
				where
					sampled_from_obj_id=#partID#
				order by
					part_name
			</cfquery>
			<cfloop query="thisSS">
				<cfset queryAddRow(getParts)>
				<cfset querySetCell(getParts,"ordr",rnum,rnum)>
				<cfset querySetCell(getParts,"partID",partID,rnum)>
				<cfset querySetCell(getParts,"part_name",part_name,rnum)>
				<cfset querySetCell(getParts,"coll_obj_disposition",coll_obj_disposition,rnum)>
				<cfset querySetCell(getParts,"condition",condition,rnum)>
				<cfset querySetCell(getParts,"sampled_from_obj_id",sampled_from_obj_id,rnum)>
				<cfset querySetCell(getParts,"lot_count",lot_count,rnum)>
				<cfset querySetCell(getParts,"barcode",barcode,rnum)>
				<cfset querySetCell(getParts,"label",label,rnum)>
				<cfset querySetCell(getParts,"parentContainerId",parentContainerId,rnum)>
				<cfset querySetCell(getParts,"partContainerId",partContainerId,rnum)>
				<cfset querySetCell(getParts,"coll_object_remarks",coll_object_remarks,rnum)>
				<cfset rnum=rnum+1>
			</cfloop>
		</cfloop>

	 	<b>Edit #getParts.recordcount# Specimen Parts</b>&nbsp;<span class="helpLink" data-helplink="parts">help</span>
		<br><a href="/findContainer.cfm?collection_object_id=#collection_object_id#">Part Locations</a>
		<cfset i = 1>
		<cfset listedParts = "">
		<form name="parts" method="post" action="editParts.cfm">
			<input type="hidden" name="action" value="saveEdits">
			<input type="hidden" name="collection_object_id" value="#collection_object_id#">

			<cfdump var=#getParts#>


			<table border>

				<tr bgcolor="##00CC00">
					<td colspan="10" align="center">
						<input type="button" value="Save All Changes" class="savBtn"
						   onclick="parts.action.value='saveEdits';submit();">
				   </td>
				</tr>
				<cfset numberOfParts= #i# - 1>
				<input type="hidden" name="NumberOfParts" value="#numberOfParts#">
				<input type="hidden" name="partID">
			</table>
		</form>
		---->
		<a name="newPart"></a>
		<table class="newRec">
			<tr>
				<td>
					<strong>Add Specimen Part</strong>
					<form name="newPart" id="newPart" method="post" action="editParts.cfm">
						<input type="hidden" name="Action" value="newPart">
						<input type="hidden" name="collection_object_id" value="#collection_object_id#">
						<input type="hidden" name="parent_part_id" id="parent_part_id">
						<div id="ssinfodiv"></div>
					    <table>
					      <tr>
					        <td><div align="right">Part Name: </div></td>
					        <td>
								<input type="text" name="part_name" id="part_name" class="reqdClr" placeholder="type and tab to pick"
									onchange="findPart(this.id,this.value,'#thisCollectionCde.collection_cde#');"
									onkeypress="return noenter(event);">
							</td>
					      </tr>
						   <tr>
					        <td><div align="right">Count:</div></td>
					        <td><input type="number" min="0" max="9999" name="lot_count" class="reqdClr" size="2"></td>
					      </tr>
					      <tr>
					        <td><div align="right">Disposition:</div></td>
					        <td>
						        <select name="coll_obj_disposition" size="1"  class="reqdClr">
						            <cfloop query="ctDisp">
						              <option value="#ctDisp.coll_obj_disposition#">#ctDisp.coll_obj_disposition#</option>
						            </cfloop>
					          	</select>
							</td>
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
								<td><div align="right">AddToContainerBarcode:</div</td>
								<td><input type="text" name="newPartContainerBarcode"></td>
							</tr>
					      <tr>
					        <td colspan="2">
						        <div align="center">
							        <input type="submit" value="Create" class="insBtn">
					          </div>
							</td>
					      </tr>
					    </table>
				  </form>
				</td>
			</tr>
		</table>
	</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------->
<cfif action is "deletePart">
	<cfoutput>
		<cftransaction>
			<cfquery name="delePart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				DELETE FROM specimen_part WHERE collection_object_id = #partID#
			</cfquery>
		</cftransaction>
		<cflocation url="editParts.cfm?collection_object_id=#collection_object_id#" addtoken="false">
	</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------->
<cfif action is "saveEdits">
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
				<cfstoredproc procedure="movePartToContainer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					<cfprocparam cfsqltype="CF_SQL_FLOAT" value="#thisPartId#"><!---- v_collection_object_id ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#thisnewCode#"><!---- v_barcode ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value=""><!---- v_container_id ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value=""><!---- v_parent_container_type ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value=""><!---- v_parent_container_label ---->
				</cfstoredproc>
			</cfif>
		</cfloop>
	</cftransaction>
	<cflocation url="editParts.cfm?collection_object_id=#collection_object_id#" addtoken="false">
</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------->
<cfif action is "newpart">
	<cfquery name= "getEntBy" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		SELECT agent_id FROM agent_name WHERE agent_name = '#session.username#'  group by agent_id
	</cfquery>
	<cfquery name= "pid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		SELECT sq_collection_object_id.nextval pid FROM dual
	</cfquery>
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
			#pid.pid#,
			'SP',
			#session.myAgentID#,
			sysdate,
			#session.myAgentID#,
			'#COLL_OBJ_DISPOSITION#',
			#lot_count#,
			'#condition#',
			0 )
	</cfquery>
	<cfquery name="newTiss" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		INSERT INTO specimen_part (
			COLLECTION_OBJECT_ID,
			PART_NAME,
			DERIVED_FROM_cat_item
			<cfif isdefined("parent_part_id") and len(parent_part_id) gt 0>
				,SAMPLED_FROM_OBJ_ID
			</cfif>
		) VALUES (
			#pid.pid#,
			'#PART_NAME#',
			#collection_object_id#
			<cfif isdefined("parent_part_id") and len(parent_part_id) gt 0>
				,#parent_part_id#
			</cfif>
		)
	</cfquery>
	<cfif len(coll_object_remarks) gt 0>
		<!---- new remark --->
		<cfquery name="newCollRem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			INSERT INTO coll_object_remark (collection_object_id, coll_object_remarks)
			VALUES (#pid.pid#, '#escapeQuotes(coll_object_remarks)#')
		</cfquery>
	</cfif>
	<cfif len(newPartContainerBarcode) gt 0>
		<cfstoredproc procedure="movePartToContainer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			<cfprocparam cfsqltype="CF_SQL_FLOAT" value="#pid.pid#"><!---- v_collection_object_id ---->
			<cfprocparam cfsqltype="cf_sql_varchar" value="#newPartContainerBarcode#"><!---- v_barcode ---->
			<cfprocparam cfsqltype="cf_sql_varchar" value=""><!---- v_container_id ---->
			<cfprocparam cfsqltype="cf_sql_varchar" value=""><!---- v_parent_container_type ---->
			<cfprocparam cfsqltype="cf_sql_varchar" value=""><!---- v_parent_container_label ---->
		</cfstoredproc>
	</cfif>
	</cftransaction>
	<cflocation url="editParts.cfm?collection_object_id=#collection_object_id#" addtoken="false">
</cfif>