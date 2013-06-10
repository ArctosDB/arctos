<cfinclude template="/includes/_header.cfm">
<!--------------------------------------------------------------------->
<cfset title="Bulk Modify Parts">
<cfif action is "nothing">
<cfoutput>
	<cfset numParts=3>
	<cfif not isdefined("table_name")>
		Bad call.<cfabort>
	</cfif>
<cfquery name="colcde" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select COLLECTION_ID from #table_name#
</cfquery>

<cfset colcdes = valuelist(colcde.COLLECTION_ID)>
<cfif listlen(colcdes) is not 1>
	You can only use this form on one collection at a time. Please revise your search.
	<cfabort>
</cfif>
<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select count(*) c from #table_name#
</cfquery>
<cfquery name="ctDisp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select coll_obj_disposition from ctcoll_obj_disp order by coll_obj_disposition
</cfquery>
	<p><strong>Option 1: Add Part(s)</strong></p>
	<form name="newPart" method="post" action="bulkPart.cfm">
		<input type="hidden" name="action" value="newPart">
		<input type="hidden" name="table_name" value="#table_name#">
	    <input type="hidden" name="numParts" value="#numParts#">
	    <table border width="90%">
			<tr>
				<td>
					Add Part 1
				</td>
				<td>Add part 2 (optional)</td>
				<td>Add part 3 (optional)</td>
			</tr>
			<tr>
				 <cfloop from="1" to="#numParts#" index="i">
	   				<td>
						<label for="part_name_#i#">Add Part (#i#)</label>
				   		<input type="text" name="part_name_#i#" id="part_name_#i#" class="reqdClr"
							onchange="findPart(this.id,this.value,'#colcdes#');" 
							onkeypress="return noenter(event);">
				   		<label for="lot_count_#i#">Part Count (#i#)</label>
				   		<input type="text" name="lot_count_#i#" id="lot_count_#i#" class="reqdClr" size="2">
				   		<label for="coll_obj_disposition_#i#">Disposition (#i#)</label>
				   		<select name="coll_obj_disposition_#i#" id="coll_obj_disposition_#i#" size="1"  class="reqdClr">
							<cfloop query="ctDisp">
								<option value="#ctDisp.coll_obj_disposition#">#ctDisp.coll_obj_disposition#</option>
							</cfloop>
						</select>
						<label for="condition_#i#">Condition (#i#)</label>
				   		<input type="text" name="condition_#i#" id="condition_#i#" class="reqdClr">
				   		<label for="coll_object_remarks_#i#">Remark (#i#)</label>
				   		<input type="text" name="coll_object_remarks_#i#" id="coll_object_remarks_#i#">
					</td>
				</cfloop>
			</tr>
		</table>
	   
	  	<input type="submit" value="Add Parts" class="savBtn">
	</form>
	<hr>
	<p>
		<strong>Option 2: Modify Existing Parts</strong>
	</p>
	<cfquery name="existParts" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select 
			specimen_part.part_name
		from 
			specimen_part,
			#table_name# 
		where
			specimen_part.derived_from_cat_item=#table_name#.collection_object_id
		group by specimen_part.part_name
		order by specimen_part.part_name
	</cfquery>
	<cfquery name="existCO" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select 
			coll_object.lot_count,
			coll_object.coll_obj_disposition
		from 
			specimen_part,
			coll_object,
			#table_name# 
		where
			specimen_part.derived_from_cat_item=#table_name#.collection_object_id and
			specimen_part.collection_object_id=coll_object.collection_object_id
		group by 
			coll_object.lot_count,
			coll_object.coll_obj_disposition
	</cfquery>
	<cfquery name="existLotCount" dbtype="query">
		select lot_count from existCO group by lot_count order by lot_count
	</cfquery>
	<cfquery name="existDisp" dbtype="query">
		select coll_obj_disposition from existCO group by coll_obj_disposition order by coll_obj_disposition
	</cfquery>
	<form name="modPart" method="post" action="bulkPart.cfm">
		<input type="hidden" name="action" value="modPart">
		<input type="hidden" name="table_name" value="#table_name#">
		<table border>
			<tr>
				<td></td>
				<td>
					Filter specimens for part...
				</td>
				<td>
					Update to...
				</td>
			</tr>
			<tr>
				<td>Part Name</td>
				<td>
			   		<select name="exist_part_name" id="exist_part_name" size="1" class="reqdClr">
						<option selected="selected" value=""></option>
							<cfloop query="existParts">
						    	<option value="#Part_Name#">#Part_Name#</option>
							</cfloop>
					</select>
				</td>
				<td>
					<input type="text" name="new_part_name" id="new_part_name" class="reqdClr"
						onchange="findPart(this.id,this.value,'#colcdes#');" 
						onkeypress="return noenter(event);">
				</td>
			</tr>
    		<tr>
				<td>Lot Count</td>
				<td>
					<select name="existing_lot_count" id="existing_lot_count" size="1" class="reqdClr">
						<option selected="selected" value="">ignore</option>
							<cfloop query="existLotCount">
						    	<option value="#lot_count#">#lot_count#</option>
							</cfloop>
					</select>
				</td>
				<td>
					<input type="text" name="new_lot_count" id="new_lot_count" class="reqdClr">
				</td>
			</tr>
			<tr>
				<td>Disposition</td>
				<td>
					<select name="existing_coll_obj_disposition" id="existing_coll_obj_disposition" size="1" class="reqdClr">
						<option selected="selected" value="">ignore</option>
							<cfloop query="existDisp">
						    	<option value="#coll_obj_disposition#">#coll_obj_disposition#</option>
							</cfloop>
					</select>
				</td>
				<td>
					<select name="new_coll_obj_disposition" id="new_coll_obj_disposition" size="1"  class="reqdClr">
						<option value="">no update</option>
						<cfloop query="ctDisp">
							<option value="#ctDisp.coll_obj_disposition#">#ctDisp.coll_obj_disposition#</option>
						</cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<td>Condition</td>
				<td>
					Existing CONDITION will be ignored
				</td>
				<td>
					<input type="text" name="new_condition" id="new_condition" class="reqdClr">
				</td>
			</tr>
			<tr>
				<td>Remark</td>
				<td>
					Existing REMARKS will be ignored
				</td>
				<td>
					<input type="text" name="new_remark" id="new_remark">
				</td>
			</tr>
			<tr>
				<td colspan="3" align="center">
					<input type="submit" value="Update Parts" class="savBtn">
				</td>
			</tr>
	  	</table>
	</form>
	<hr>
	<p>
		<strong>Option 3: Delete parts</strong>
	</p>
	<form name="delPart" method="post" action="bulkPart.cfm">
		<input type="hidden" name="action" value="delPart">
		<input type="hidden" name="table_name" value="#table_name#">
		<label for="exist_part_name">Existing Part Name</label>
		<select name="exist_part_name" id="exist_part_name" size="1" class="reqdClr">
			<option selected="selected" value=""></option>
				<cfloop query="existParts">
			    	<option value="#Part_Name#">#Part_Name#</option>
				</cfloop>
		</select>
		<label for="existing_lot_count">Existing Lot Count</label>
		<select name="existing_lot_count" id="existing_lot_count" size="1" class="reqdClr">
			<option selected="selected" value="">ignore</option>
				<cfloop query="existLotCount">
			    	<option value="#lot_count#">#lot_count#</option>
				</cfloop>
		</select>
		<label for="existing_coll_obj_disposition">Existing Disposition</label>
		<select name="existing_coll_obj_disposition" id="existing_coll_obj_disposition" size="1" class="reqdClr">
			<option selected="selected" value="">ignore</option>
				<cfloop query="existDisp">
			    	<option value="#coll_obj_disposition#">#coll_obj_disposition#</option>
				</cfloop>
		</select>
		<br><input type="submit" value="Delete Parts" class="delBtn">
	</form>
	<hr>
	
	<p>
		<strong>Specimens being Updated</strong>
	</p>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			flat.collection_object_id,
			flat.guid,
			flat.scientific_name,
			specimen_part.part_name,
			coll_object.condition,
			coll_object.lot_count,
			coll_object.coll_obj_disposition,
			coll_object_remark.coll_object_remarks
		from
			flat,
			specimen_part,
			coll_object,
			coll_object_remark,
			#table_name#
		where
			flat.collection_object_id=#table_name#.collection_object_id and
			flat.collection_object_id=specimen_part.derived_from_cat_item and
			specimen_part.collection_object_id=coll_object.collection_object_id and
			specimen_part.collection_object_id=coll_object_remark.collection_object_id (+)
		order by
			flat.guid		
	</cfquery>
	<cfquery name="s" dbtype="query">
		select collection_object_id,guid,scientific_name from d group by collection_object_id,guid,scientific_name
	</cfquery>
	<table border>
			<tr>
				<th>Specimen</th>
				<th>ID</th>
				<th>Parts</th>
			</tr>
			<cfloop query="s">
				<tr>
					<td><a href="/guid/#guid#">#guid#</a></td>
					<td>#scientific_name#</td>
					<cfquery name="sp" dbtype="query">
						select
							part_name,
							condition,
							lot_count,
							coll_obj_disposition,
							coll_object_remarks
						from
							d
						where
							collection_object_id=#collection_object_id#
					</cfquery>
					<td>
						<table border width="100%">
							<th>Part</th>
							<th>Condition</th>
							<th>Count</th>
							<th>Dispn</th>
							<th>Remark</th>
							<cfloop query="sp">
								<tr>
									<td>#part_name#</td>
									<td>#condition#</td>
									<td>#lot_count#</td>
									<td>#coll_obj_disposition#</td>
									<td>#coll_object_remarks#</td>
								</tr>
							</cfloop>
						</table>
					</td>
				</tr>
			</cfloop>
		</table>
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->
<cfif action is "delPart2">
	<cfoutput>
		<cftransaction>
			<cfloop list="#partID#" index="i">
				<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					delete from specimen_part where collection_object_id=#i#
				</cfquery>
			</cfloop>
		</cftransaction>
	</cfoutput>
	<cflocation url="bulkPart.cfm?table_name=#table_name#" addtoken="false">
</cfif>
<!---------------------------------------------------------------------------->
<cfif action is "delPart">
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				specimen_part.collection_object_id partID,
				collection.collection,
				cataloged_item.cat_num,
				identification.scientific_name,
				specimen_part.part_name,
				coll_object.condition,
				coll_object.lot_count,
				coll_object.coll_obj_disposition,
				coll_object_remark.coll_object_remarks
			from
				cataloged_item,
				collection,
				coll_object,
				specimen_part,
				identification,
				coll_object_remark,
				#table_name#
			where
				cataloged_item.collection_id=collection.collection_id and
				cataloged_item.collection_object_id=#table_name#.collection_object_id and
				cataloged_item.collection_object_id=specimen_part.derived_from_cat_item and
				specimen_part.collection_object_id=coll_object.collection_object_id and
				specimen_part.collection_object_id=coll_object_remark.collection_object_id (+) and
				cataloged_item.collection_object_id=identification.collection_object_id and
				accepted_id_fg=1 and
				part_name='#exist_part_name#'
				<cfif len(existing_lot_count) gt 0>
					and lot_count=#existing_lot_count#
				</cfif>
				<cfif len(existing_coll_obj_disposition) gt 0>
					and coll_obj_disposition='#existing_coll_obj_disposition#'
				</cfif>
			order by
				collection.collection,cataloged_item.cat_num		
		</cfquery>
		<form name="modPart" method="post" action="bulkPart.cfm">
			<input type="hidden" name="action" value="delPart2">
			<input type="hidden" name="table_name" value="#table_name#">
			<input type="hidden" name="partID" value="#valuelist(d.partID)#">
			<input type="submit" value="Looks good - do it" class="savBtn">
		</form>
		<table border>
			<tr>
				<th>Specimen</th>
				<th>ID</th>
				<th>PartToBeDeleted</th>
				<th>Condition</th>
				<th>Cnt</th>
				<th>Dispn</th>
				<th>Remark</th>
			</tr>
			<cfloop query="d">
				<tr>
					<td>#collection# #cat_num#</td>
					<td>#scientific_name#</td>
					<td>#part_name#</td>
					<td>#condition#</td>
					<td>#lot_count#</td>
					<td>#coll_obj_disposition#</td>
					<td>#coll_object_remarks#</td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
</cfif>

<!---------------------------------------------------------------------------->
<cfif action is "modPart2">
	<cfoutput>
	<cftransaction>
		<cfloop list="#partID#" index="i">
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update specimen_part set part_name='#new_part_name#' where collection_object_id=#i#
			</cfquery>			
			<cfif len(new_lot_count) gt 0 or len(new_coll_obj_disposition) gt 0 or len(new_condition) gt 0>
				<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update coll_object set
						flags=flags
						<cfif len(new_lot_count) gt 0>
							,lot_count=#new_lot_count#
						</cfif>
						<cfif len(new_coll_obj_disposition) gt 0>
							,coll_obj_disposition='#new_coll_obj_disposition#'
						</cfif>
						<cfif len(new_condition) gt 0>
							,condition='#new_condition#'
						</cfif>
					where collection_object_id=#i#
				</cfquery>
			</cfif>
			<cfif len(new_remark) gt 0>
				<cftry>
					<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						insert into coll_object_remark (collection_object_id,coll_object_remarks) values (#i#,'#new_remark#')
					</cfquery>
					<cfcatch>
						<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							update coll_object_remark set coll_object_remarks='#new_remark#' where collection_object_id=#i#
						</cfquery>						
					</cfcatch>
				</cftry>
			</cfif>
		</cfloop>
		</cftransaction>
		<cflocation url="bulkPart.cfm?table_name=#table_name#" addtoken="false">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->
<cfif action is "modPart">
	<cfif len(exist_part_name) is 0 or len(new_part_name) is 0>
		Not enough information.
		<cfabort>
	</cfif>
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				specimen_part.collection_object_id partID,
				collection.collection,
				cataloged_item.cat_num,
				identification.scientific_name,
				specimen_part.part_name,
				coll_object.condition,
				coll_object.lot_count,
				coll_object.coll_obj_disposition,
				coll_object_remark.coll_object_remarks
			from
				cataloged_item,
				collection,
				coll_object,
				specimen_part,
				identification,
				coll_object_remark,
				#table_name#
			where
				cataloged_item.collection_id=collection.collection_id and
				cataloged_item.collection_object_id=#table_name#.collection_object_id and
				cataloged_item.collection_object_id=specimen_part.derived_from_cat_item and
				specimen_part.collection_object_id=coll_object.collection_object_id and
				specimen_part.collection_object_id=coll_object_remark.collection_object_id (+) and
				cataloged_item.collection_object_id=identification.collection_object_id and
				accepted_id_fg=1 and
				part_name='#exist_part_name#'
				<cfif len(existing_lot_count) gt 0>
					and lot_count=#existing_lot_count#
				</cfif>
				<cfif len(existing_coll_obj_disposition) gt 0>
					and coll_obj_disposition='#existing_coll_obj_disposition#'
				</cfif>
			order by
				collection.collection,cataloged_item.cat_num		
		</cfquery>
		<form name="modPart" method="post" action="bulkPart.cfm">
			<input type="hidden" name="action" value="modPart2">
			<input type="hidden" name="table_name" value="#table_name#">
			<input type="hidden" name="exist_part_name" value="#exist_part_name#">
			<input type="hidden" name="new_part_name" value="#new_part_name#">
			<input type="hidden" name="existing_lot_count" value="#existing_lot_count#">
			<input type="hidden" name="new_lot_count" value="#new_lot_count#">
			<input type="hidden" name="existing_coll_obj_disposition" value="#existing_coll_obj_disposition#">
			<input type="hidden" name="new_coll_obj_disposition" value="#new_coll_obj_disposition#">
			<input type="hidden" name="new_condition" value="#new_condition#">
			<input type="hidden" name="new_remark" value="#new_remark#">
			<input type="hidden" name="partID" value="#valuelist(d.partID)#">
			<input type="submit" value="Looks good - do it" class="savBtn">
		</form>
		<table border>
			<tr>
				<th>Specimen</th>
				<th>ID</th>
				<th>OldPart</th>
				<th>NewPart</th>
				<th>OldCondition</th>
				<th>NewCondition</th>
				<th>OldCnt</th>
				<th>NewdCnt</th>
				<th>OldDispn</th>
				<th>NewDispn</th>
				<th>OldRemark</th>
				<th>NewRemark</th>
			</tr>
			<cfloop query="d">
				<tr>
					<td>#collection# #cat_num#</td>
					<td>#scientific_name#</td>
					<td>#part_name#</td>
					<td>#new_part_name#</td>
					<td>#condition#</td>
					<td>
						<cfif len(new_condition) gt 0>
							#new_condition#
						<cfelse>
							NOT UPDATED
						</cfif>
					</td>
					<td>#lot_count#</td>
					<td>
						<cfif len(new_lot_count) gt 0>
							#new_lot_count#
						<cfelse>
							NOT UPDATED
						</cfif>
					</td>
					<td>#coll_obj_disposition#</td>
					<td>
						<cfif len(new_coll_obj_disposition) gt 0>
							#new_coll_obj_disposition#
						<cfelse>
							NOT UPDATED
						</cfif>
					</td>
					<td>#coll_object_remarks#</td>
					<td>
						<cfif len(new_remark) gt 0>
							#new_remark#
						<cfelse>
							NOT UPDATED
						</cfif>
					</td>
					
				</tr>
			</cfloop>
		</table>
	</cfoutput>
</cfif>

<!---------------------------------------------------------------------------->
<cfif action is "newPart">
<cfoutput>
	<cfquery name="ids" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select distinct collection_object_id from #table_name#
	</cfquery>
	<cftransaction>
		<cfloop query="ids">
			<cfloop from="1" to="#numParts#" index="n">
				<cfset thisPartName = #evaluate("part_name_" & n)#>
				<cfset thisLotCount = #evaluate("lot_count_" & n)#>
				<cfset thisDisposition = #evaluate("coll_obj_disposition_" & n)#>
				<cfset thisCondition = #evaluate("condition_" & n)#>
				<cfset thisRemark = #evaluate("coll_object_remarks_" & n)#>
				<cfif len(#thisPartName#) gt 0>
					<cfquery name="insCollPart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
							#session.myAgentId#,
							sysdate,
							#session.myAgentId#,
							'#thisDisposition#',
							#thisLotCount#,
							'#thisCondition#',
							0 )		
					</cfquery>
					<cfquery name="newTiss" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						INSERT INTO specimen_part (
							  COLLECTION_OBJECT_ID,
							  PART_NAME
								,DERIVED_FROM_cat_item)
							VALUES (
								sq_collection_object_id.currval,
							  '#thisPartName#'
								,#ids.collection_object_id#)
					</cfquery>
					<cfif len(#thisRemark#) gt 0>
						<cfquery name="newCollRem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							INSERT INTO coll_object_remark (collection_object_id, coll_object_remarks)
							VALUES (sq_collection_object_id.currval, '#thisRemark#')
						</cfquery>
					</cfif>
				</cfif>			
			</cfloop>
		</cfloop>
	</cftransaction>
	Success!
	<a href="/SpecimenResults.cfm?collection_object_id=#valuelist(ids.collection_object_id)#">Return to SpecimenResults</a>
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">