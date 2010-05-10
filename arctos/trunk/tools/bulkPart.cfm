<cfinclude template="/includes/_header.cfm">
<!--------------------------------------------------------------------->
<cfif action is "nothing">
<cfoutput>
	<cfset numParts=3>
	<cfif not isdefined("table_name")>
		Bad call.<cfabort>
	</cfif>
<cfquery name="colcde" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select distinct(collection_cde) from #table_name#
</cfquery>

<cfset colcdes = valuelist(colcde.collection_cde)>
<cfif listlen(colcdes) is not 1>
	You can only use this form on one collection at a time. Please revise your search.
	<cfabort>
</cfif>
<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select count(*) c from #table_name#
</cfquery>
<cfif c.c gte 1000>
	You can only use this form on 1000 specimens at a time. Please revise your search.
	<cfabort>
</cfif>
<cfquery name="ctDisp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select coll_obj_disposition from ctcoll_obj_disp
</cfquery>
<cfquery name="ctpart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select distinct(part_name) from ctspecimen_part_name where collection_cde='#colcdes#'
</cfquery>
	<p><strong>Option 1: Add Part(s) to all specimens listed below</strong></p>
	<form name="newPart" method="post" action="bulkPart.cfm">
		<input type="hidden" name="action" value="newPart">
		<input type="hidden" name="table_name" value="#table_name#">
	    <input type="hidden" name="numParts" value="#numParts#">
	    	
	    <cfloop from="1" to="#numParts#" index="i">
	   		<label for="part_name_#i#">Add Part (#i#)</label>
	   		<select name="part_name_#i#" id="part_name_#i#" size="1" class="reqdClr">
				<option selected="selected" value=""></option>
					<cfloop query="ctpart">
				    	<option value="#ctpart.Part_Name#">#ctpart.Part_Name#</option>
					</cfloop>
			</select>
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
		</cfloop>
	  	<input type="submit" value="Add Parts" class="savBtn">
	</form>
	<hr>
	<p>
		<strong>Option 2: Modify a part for all specimens listed below</strong>
	</p>
	<cfquery name="existParts" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			part_name
		from 
			specimen_part,
			#table_name# 
		where
			specimen_part.derived_from_cat_item=#table_name#.collection_object_id
		group by part_name
		order by part_name
	</cfquery>
	<cfquery name="existCO" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			lot_count,
			coll_obj_disposition
		from 
			specimen_part,
			coll_object,
			#table_name# 
		where
			specimen_part.derived_from_cat_item=#table_name#.collection_object_id and
			specimen_part.collection_object_id=coll_object.collection_object_id
		group by 
			lot_count,
			coll_obj_disposition
	</cfquery>
	<cfquery name="existLotCount" dbtype="query">
		select lot_count from existCO group by lot_count order by lot_count
	</cfquery>
	<cfquery name="existDisp" dbtype="query">
		select coll_obj_disposition from existCO group by coll_obj_disposition order by coll_obj_disposition
	</cfquery>
	<form name="newPart" method="post" action="bulkPart.cfm">
		<input type="hidden" name="action" value="modPart">
		<input type="hidden" name="table_name" value="#table_name#">
		<table border>
			<tr>
				<td>
					Filter specimens for part...
				</td>
				<td>
					Update to...
				</td>
				<td></td>
			</tr>
			<tr>
				<td>Part Name</td>
				<td>
					<label for="existing_part_name">Existing Part</label>
			   		<select name="part_name_#i#" id="part_name_#i#" size="1" class="reqdClr">
						<option selected="selected" value=""></option>
							<cfloop query="existParts">
						    	<option value="#Part_Name#">#Part_Name#</option>
							</cfloop>
					</select>
				</td>
				<td>
					<select name="new_part_name" id="new_part_name" size="1" class="reqdClr">
						<option selected="selected" value=""></option>
							<cfloop query="ctpart">
						    	<option value="#ctpart.Part_Name#">#ctpart.Part_Name#</option>
							</cfloop>
					</select>
				</td>
			</tr>
    	
   		<label for="existing_lot_count">Existing Part Count</label>
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
		<br>Existing CONDITION will be ignored.
		<br>Existing REMARKS will be ignored.
	  	<br>
	  	
	  	<input type="submit" value="Add Parts" class="savBtn">
	  	</table>
	</form>
	<!------------------------------------------------------------------------->
	<script>
		getSpecResultsData(1,999);
	</script>
	<div id="resultsGoHere"></div>
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->
<cfif #action# is "newPart">
<cfoutput>
	<cfquery name="ids" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select distinct collection_object_id from #table_name#
	</cfquery>
	<cfset thisDate = dateformat(now(),"dd-mmm-yyyy")>
	<cftransaction>
		<cfloop query="ids">
			<cfloop from="1" to="#numParts#" index="n">
				<cfset thisPartName = #evaluate("part_name_" & n)#>
				<cfset thisLotCount = #evaluate("lot_count_" & n)#>
				<cfset thisDisposition = #evaluate("coll_obj_disposition_" & n)#>
				<cfset thisCondition = #evaluate("condition_" & n)#>
				<cfset thisRemark = #evaluate("coll_object_remarks_" & n)#>
				<cfif len(#thisPartName#) gt 0>
					<cfquery name="insCollPart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
							'#thisDate#',
							#session.myAgentId#,
							'#thisDisposition#',
							#thisLotCount#,
							'#thisCondition#',
							0 )		
					</cfquery>
					<cfquery name="newTiss" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
						<cfquery name="newCollRem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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