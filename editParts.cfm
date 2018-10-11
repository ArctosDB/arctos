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
			/*
			hover and click combine to do weird things; just let users click to scroll+highlight for now
			$(".ssspn").hover(function(){
				$("#" + $(this).attr("data-pid") ).addClass('relted');
				$(this).css('cursor','pointer');
			 },
		    function(){
		        $("#" + $(this).attr("data-pid") ).removeClass('relted');
		    });
		    */
		    $(".ssspn").click(function(){
		    	$('html, body').animate({
			        scrollTop: $("#" + $(this).attr("data-pid")).offset().top
			    }, 2000);
			    $("#" + $(this).attr("data-pid") ).addClass('relted').delay(5000).removeClass('relted', "slow");
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

				 	$('html, body').animate({
			        	scrollTop: $("#tblnewRec").offset().top
				    }, 2000);
				}
			}
			function createClone(i){
			 	$("#ssinfodiv").html('Creating a clone of ' + $('#part_name' + i).val() + ' (ID=' + $("#partID" + i).val() + ')');
			 	$("#parent_part_id").val($("#partID" + i).val());
			 	$("#newPart input[name=part_name]").val($('#part_name' + i).val());
			 	$("#newPart input[name=lot_count]").val($('#lot_count' + i).val());
			 	$("#newPart input[name=coll_obj_disposition]").val($('#coll_obj_disposition' + i).val());
			 	$("#newPart input[name=condition]").val($('#condition' + i).val());
			 	$("#newPart input[name=coll_object_remarks]").val($('#coll_object_remarks' + i).val());

			 	$('html, body').animate({
		        	scrollTop: $("#tblnewRec").offset().top
			    }, 2000);
			}
	</script>
	<cfoutput>
		<cffunction name="getChildParts"  returnType="string">
			<!---- build table row(s) for one part and any attributes ---->
			<cfargument name="pid" type="string" required="yes">
			<cfargument name="level" type="string" required="yes">
			<cfargument name="p_q" type="query" required="yes">
			<cfargument name="l_q" type="query" required="yes">
			<cfargument name="i" type="string" required="yes">
			<cfquery name="ctDisp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
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
					coll_object_remarks,
					parentContainerDisplay
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
					coll_object_remarks,
					parentContainerDisplay
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
									<span id="pid_#partID#">
										#partID#
									</span>
									<cfif len(sampled_from_obj_id) gt 0>
										<br><span class="ssspn likeLink" data-pid="pid_#sampled_from_obj_id#">Subsampled from #sampled_from_obj_id#</span>
									</cfif>
									<br><span class="likeLink" style="font-weight:100" onClick="getCtDoc('ctspecimen_part_name')">[ Define values ]</span>
								</label>
								<input type="text" name="part_name#i#" id="part_name#i#" class="reqdClr" value="#p.part_name#" size="25"
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
							<!----
							<span style="font-size:small">
								<cfif len(p.label) gt 0>
									#p.label#
								<cfelse>
									-NONE-
								</cfif>
							</span>
							---->
							#p.parentContainerDisplay#
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
								value="Clone"
								class="insBtn"
								onClick="createClone(#i#)">
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
					<tr>
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
												<td>#attribute_value#&nbsp;</td>
												<td>#attribute_units#&nbsp;</td>
												<td>#dateformat(determined_date,"yyyy-mm-dd")#&nbsp;</td>
												<td>#agent_name#&nbsp;</td>
												<td>#attribute_remark#&nbsp;</td>
											</tr>
										</cfloop>
									</table>
								<cfelse>
									--no attributes--
								</cfif>
							</div>
						</td>
						<td><input type="button" value="Manage Attributes" class="savBtn" onclick="mgPartAtts(#partID#);"></td>
					</tr>
				</cfloop>
			</cfsavecontent>
			<cfreturn r>
		</cffunction>
<!--------------------->
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
				getContainerDisplay(parentContainer.container_id) parentContainerDisplay,
				coll_object_remark.coll_object_remarks,
				specimen_part_attribute.part_attribute_id,
				specimen_part_attribute.attribute_type,
				specimen_part_attribute.attribute_value,
				specimen_part_attribute.attribute_units,
				specimen_part_attribute.determined_date,
				specimen_part_attribute.determined_by_agent_id,
				getPreferredAgentName(specimen_part_attribute.determined_by_agent_id) part_attribute_determiner,
				specimen_part_attribute.attribute_remark,

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
		<cfquery name="ctDisp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select coll_obj_disposition from ctcoll_obj_disp order by coll_obj_disposition
		</cfquery>
		<cfquery name="thisCollectionCde" dbtype="query" >
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
			<div style="text-align:center;">
				<input type="button" value="Save All Changes" class="savBtn" onclick="parts.action.value='saveEdits';submit();">
			</div>
				<cfset numberOfParts= i-1>
				<input type="hidden" name="NumberOfParts" value="#orderedparts.recordcount#">
				<input type="hidden" name="partID">
			</table>
		</form>
		<a name="newPart"></a>
		<table class="newRec" id="tblnewRec">
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