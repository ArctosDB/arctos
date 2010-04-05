<cfinclude template="/includes/_header.cfm">

<!--------------------------------------------------------------------->
<cfif #action# is "nothing">
<cfoutput>
	<cfset numParts=3>
	<cfif not isdefined("table_name")>
		Bad call.<cfabort>
	</cfif>
<cfquery name="colcde" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select distinct(collection_cde) from #table_name#
</cfquery>
<cfset colcdes = valuelist(colcde.collection_cde)>
<cfset colcdes = "'#replace(colcdes,",","','","all")#'">
<cfquery name="ctDisp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select coll_obj_disposition from ctcoll_obj_disp
</cfquery>

	<h3>Add Part(s) to all specimens listed below</h3>
	<form name="newPart" method="post" action="bulkPart.cfm">
		<input type="hidden" name="action" value="newPart">
		<input type="hidden" name="table_name" value="#table_name#">
	    <input type="hidden" name="numParts" value="#numParts#">
	    	
	    <cfloop from="1" to="#numParts#" index="i">
	   		<table>
	   			<tr>
	   				<td>Part #i#:</td>
	   			</tr>
	   			<tr>
	   				<td>
	   					<label for="part_name_#i#">Part Name</label>
	   					<select name="part_name_#i#" id="part_name_#i#" size="1" class="reqdClr">
				            <option selected="selected" value=""></option>
				            <cfloop query="Part">
				              <option value="#Part.Part_Name#">#Part.Part_Name#</option>
				            </cfloop>
				          </select>
	   				</td>
	   			</tr>
	   			<tr>
	   				<td>
	   					<label for="lot_count_#i#">Part Count</label>
	   					<input type="text" name="lot_count_#i#" id="lot_count_#i#" class="reqdClr" size="2">
	   				</td>
	   			</tr>
	   			<tr>
	   				<td>
	   					<label for="coll_obj_disposition_#i#">Disposition</label>
	   					<select name="coll_obj_disposition_#i#" id="coll_obj_disposition_#i#" size="1"  class="reqdClr">
				            <cfloop query="ctDisp">
				              <option value="#ctDisp.coll_obj_disposition#">#ctDisp.coll_obj_disposition#</option>
				            </cfloop>
				          </select>
	   				</td>
	   			</tr>
	   			<tr>
	   				<td>
	   					<label for="condition_#i#">Condition</label>
	   					<input type="text" name="condition_#i#" id="condition_#i#" class="reqdClr">
	   				</td>
	   				<td>
	   					<label for="coll_object_remarks_#i#">Remarks</label>
	   					<input type="text" name="coll_object_remarks_#i#" id="coll_object_remarks_#i#">
	   				</td>
	   			</tr>
	   		</table>
	   		<hr>
	    </cfloop>
	  	<input type="submit" value="Add Parts" class="savBtn"
		   onmouseover="this.className='savBtn btnhov'" onmouseout="this.className='savBtn'">
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