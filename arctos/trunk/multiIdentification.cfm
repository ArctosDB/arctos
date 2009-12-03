<cfinclude template="/includes/_header.cfm">
	<script language="JavaScript" src="/includes/CalendarPopup.js" type="text/javascript"></script>
	<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
		var cal1 = new CalendarPopup("theCalendar");
		cal1.showYearNavigation();
		cal1.showYearNavigationInput();
	</SCRIPT>
	<SCRIPT LANGUAGE="JavaScript" type="text/javascript">document.write(getCalendarStyles());</SCRIPT>
<script type='text/javascript' src='/includes/_editIdentification.js'></script>


<!----------------------------------------------------------------------------------->

<!--------------------------------------------------------------------------------------------------->
<cfif #Action# is "nothing">
	<!--- edit IDs for a list of specimens passed in from specimenresults --->
	<!--- no security --->
<cfset title = "Edit Identification">
<cfquery name="ctnature" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select nature_of_id from ctnature_of_id
</cfquery>
<cfquery name="ctFormula" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select taxa_formula from cttaxa_formula order by taxa_formula
</cfquery>
<cfoutput>
</cfoutput> <cfoutput> <strong>Add Identification For <font size="+1"><i>All</i></font> 
  specimens listed below:</strong> 
  <table>
  <form name="newID" method="post" action="multiIdentification.cfm">
            <input type="hidden" name="Action" value="createManyNew">
            <input type="hidden" name="collection_object_id" value="#collection_object_id#" >
    		<tr>
				<td>
				<a href="javascript:void(0);" class="novisit" onClick="getDocs('identification','id_formula')">ID Formula:</a></td>
				
				<td>
					<cfif not isdefined("taxa_formula")>
						<cfset taxa_formula='A'>
					</cfif>
					<cfset thisForm = "#taxa_formula#">
					<select name="taxa_formula" size="1" class="reqdClr"
					onchange="newIdFormula(this.value);">
						<cfloop query="ctFormula">
						<cfif #ctFormula.taxa_formula# is "A">
							<cfset thisDispVal = "one taxon">
						<cfelseif #ctFormula.taxa_formula# is "A ?">
							<cfset thisDispVal = 'taxon + "?"'>
						<cfelseif #ctFormula.taxa_formula# is "A or B">
							<cfset thisDispVal = 'A "or" B'>
						<cfelseif #ctFormula.taxa_formula# is "A x B">
							<cfset thisDispVal = 'A "x" B'>
						<cfelseif #ctFormula.taxa_formula# is "A sp.">
							<cfset thisDispVal = 'A "sp."'>
						<cfelseif #ctFormula.taxa_formula# is "A cf.">
							<cfset thisDispVal = 'A "cf."'>
						<cfelseif #ctFormula.taxa_formula# is "A ssp.">
							<cfset thisDispVal = 'A "ssp."'>
						<cfelseif #ctFormula.taxa_formula# is "A and B">
							<cfset thisDispVal = 'A and B'>
						<cfelseif #ctFormula.taxa_formula# is "A aff.">
							<cfset thisDispVal = 'A "aff."'>
						<cfelseif #ctFormula.taxa_formula# is "A / B intergrade">
							<cfset thisDispVal = 'A / B intergrade'>
						<cfelse>
							<cfset thisDispVal = "ERROR!!!">
						</cfif>
							<option 
								<cfif #thisForm# is "#ctFormula.taxa_formula#"> selected </cfif>value="#ctFormula.taxa_formula#">#thisDispVal#</option>
						</cfloop>
					</select>
				</td>
			</tr>     
	         
            <tr> 
              <td><div align="right">Taxon A:</div></td>
              <td>
			  	<input type="text" name="taxa_a" class="reqdClr" size="50" 
				onChange="taxaPick('TaxonAID','taxa_a','newID',this.value); return false;"
				onKeyPress="return noenter(event);">
				<input type="hidden" name="TaxonAID"> 
			  </td>
            </tr>
			<tr id="taxon_b_row" style="display:none;"> 
              <td><div align="right">Taxon B:</div></td>
              <td>
			  	<input type="text" name="taxa_b" id="taxa_b" class="reqdClr" size="50" 
					onChange="taxaPick('TaxonBID','taxa_b','newID',this.value); return false;"
					onKeyPress="return noenter(event);">
				<input type="hidden" name="TaxonBID" id="TaxonBID">
			  </td>
            </tr>
            <tr> 
              <td><div align="right">
			  <a href="javascript:void(0);" class="novisit" onClick="getDocs('identification','id_by')">ID By:</a>
				
							 </div></td>
              <td><input type="text" name="idBy" class="reqdClr" size="50" 
			 		 onchange="getAgent('newIdById','idBy','newID',this.value); return false;"
			  		 onkeypress="return noenter(event);"> 
                <input type="hidden" name="newIdById"> 
				<span class="infoLink" onclick="addNewIdBy('two');">more...</span>
				

			 </td>
            </tr>
			<tr id="addNewIdBy_two" style="display:none;"> 
              	<td>
					<div align="right">
						ID By:<span class="infoLink" onclick="clearNewIdBy('two');"> clear</span>	
					</div>
				</td>
              	<td>
					<input type="text" name="idBy_two" id="idBy_two" class="reqdClr" size="50" 
			 		 	onchange="getAgent('newIdById_two','idBy_two','newID',this.value); return false;"
			  		 	onkeypress="return noenter(event);"> 
                	<input type="hidden" name="newIdById_two" id="newIdById_two"> 
					<span class="infoLink" onclick="addNewIdBy('three');">more...</span>			

			 </td>
            </tr>
           <tr id="addNewIdBy_three" style="display:none;"> 
              	<td>
					<div align="right">
						ID By:<span class="infoLink" onclick="clearNewIdBy('three');"> clear</span>	
					</div>
				</td>
              	<td>
					<input type="text" name="idBy_three" id="idBy_three" class="reqdClr" size="50" 
			 		 	onchange="getAgent('newIdById_three','idBy_three','newID',this.value); return false;"
			  		 	onkeypress="return noenter(event);"> 
                	<input type="hidden" name="newIdById_three" id="newIdById_three"> 			

			 </td>
            </tr>
            <tr> 
              <td><div align="right">
			  <a href="javascript:void(0);" class="novisit" onClick="getDocs('identification','id_date')">ID Date:</a></td>
			  </div></td>
              <td><input type="text" name="made_date"></td>
            </tr>
            <tr> 
              <td><div align="right">
			  <a href="javascript:void(0);" class="novisit" onClick="getDocs('identification','nature_of_id')"> Nature of ID:</a></td>
			
			 </div></td>
              <td><select name="nature_of_id" size="1" class="reqdClr">
                  <cfloop query="ctnature">
                    <option  value="#ctnature.nature_of_id#">#ctnature.nature_of_id#</option>
                  </cfloop>
                </select>
				<img 
				class="likeLink" 
				src="/images/ctinfo.gif"
				border="0"
				alt="Code Table Value Definition"
				onClick="getCtDoc('ctnature_of_id',newID.nature_of_id.value)"></td>
            </tr>
            <tr> 
              <td><div align="right">Remarks:</div></td>
              <td><input type="text" name="identification_remarks" size="50"></td>
            </tr>
            <tr> 
              <td colspan="2"><div align="center"> 
                    <input type="submit" value="Add Identification to all listed specimens" class="insBtn"
   onmouseover="this.className='insBtn btnhov';this.focus();" onmouseout="this.className='insBtn'">	

                </div></td>
            </tr>
    </table>
          
        </form>
		
		
  
  

<cfquery name="specimenList" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	 SELECT 
	 	cataloged_item.collection_object_id as collection_object_id, 
		cat_num,
		concatSingleOtherId(cataloged_item.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID,
		scientific_name,
		country,
		state_prov,
		county,
		quad,
		institution_acronym,
		collection.collection
	FROM 
		identification, 
		collecting_event,
		locality,
		geog_auth_rec,
		cataloged_item,
		collection
	WHERE 
		locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id 
		AND collecting_event.locality_id = locality.locality_id 
		AND cataloged_item.collecting_event_id = collecting_event.collecting_event_id 
		AND cataloged_item.collection_object_id = identification.collection_object_id 
		and accepted_id_fg=1
		AND cataloged_item.collection_id = collection.collection_id
		AND cataloged_item.collection_object_id IN (#collection_object_id#)
	ORDER BY 
		collection_object_id
</cfquery>
<br><b>#specimenList.recordcount# Specimens Being Re-Identified:</b>

</cfoutput>

<table width="95%" border="1">
<tr>
	<td><strong>Catalog Number</strong></td>
	<td><strong><cfoutput>#session.CustomOtherIdentifier#</cfoutput></strong></td>
	<td><strong>Accepted Scientific Name</strong></td>
	<td><strong>Country</strong></td>
	<td><strong>State</strong></td>
	<td><strong>County</strong></td>
	<td><strong>Quad</strong></td>
</tr>
 <cfoutput query="specimenList" group="collection_object_id">
    <tr>
	  <td>
	  	#collection#&nbsp;#cat_num#
	  </td>
	<td>
		#CustomID#&nbsp;
	</td>
	<td><i>#Scientific_Name#</i></td>
	<td>#Country#&nbsp;</td>
	<td>#State_Prov#&nbsp;</td>
	<td>
		#county#&nbsp;
	</td>
	<td>
		#quad#&nbsp;
	</td>
</tr>


</cfoutput>
</table>
</cfif>
<!----------------------------------------------------------------------------------->
<!----------------------------------------------------------------------------------->
<cfif #Action# is "createManyNew">

<cfoutput>
<cfif #taxa_formula# is "A">
	<cfset scientific_name = "#taxa_a#">
<cfelseif #taxa_formula# is "A or B">
	<cfset scientific_name = "#taxa_a# or #taxa_b#">
<cfelseif #taxa_formula# is "A x B">
	<cfset scientific_name = "#taxa_a# x #taxa_b#">
<cfelseif #taxa_formula# is "A ?">
		<cfset scientific_name = "#taxa_a# ?">
<cfelseif #taxa_formula# is "A sp.">
		<cfset scientific_name = "#taxa_a# sp.">
<cfelseif #taxa_formula# is "A cf.">
	<cfset scientific_name = "#taxa_a# cf.">
<cfelseif #taxa_formula# is "A aff.">
	<cfset scientific_name = "#taxa_a# aff.">
<cfelseif #taxa_formula# is "A ssp.">
	<cfset scientific_name = "#taxa_a# ssp.">
<cfelseif #taxa_formula# is "A / B intergrade">
	<cfset scientific_name = "#taxa_a# / #taxa_b# intergrade.">
<cfelseif #taxa_formula# is "A and B">
	<cfset scientific_name = "#taxa_a# and #taxa_b#">
<cfelse>
	The taxa formula you entered isn't handled yet! Please submit a bug report.
	<cfabort>
</cfif>
<!--- looop through the collection_object_list and update things one at a time--->
	<cftransaction>
		<cfloop list="#collection_object_id#" index="i">
		<cfquery name="upOldID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			UPDATE identification SET ACCEPTED_ID_FG=0 where collection_object_id = #i#
		</cfquery>
		<cfquery name="newID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			INSERT INTO identification (
				IDENTIFICATION_ID,
				COLLECTION_OBJECT_ID
				<cfif len(#MADE_DATE#) gt 0>
					,MADE_DATE
				</cfif>
				,NATURE_OF_ID
				 ,ACCEPTED_ID_FG
				 <cfif len(#IDENTIFICATION_REMARKS#) gt 0>
					,IDENTIFICATION_REMARKS
				</cfif>
				,taxa_formula
				,scientific_name)
			VALUES (
				sq_identification_id.nextval,
				#i#
				<cfif len(#MADE_DATE#) gt 0>
					,'#dateformat(MADE_DATE,"dd-mmm-yyyy")#'
				</cfif>
				,'#NATURE_OF_ID#'
				 ,1
				 <cfif len(#IDENTIFICATION_REMARKS#) gt 0>
					,'#stripQuotes(IDENTIFICATION_REMARKS)#'
				</cfif>
				,'#taxa_formula#'
				,'#scientific_name#')
			</cfquery>
			<cfquery name="newIdAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into identification_agent (
					identification_id,
					agent_id,
					identifier_order) 
				values (
					sq_identification_id.currval,
					#newIdById#,
					1
					)
			</cfquery>
			 <cfif len(#newIdById_two#) gt 0>
				<cfquery name="newIdAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					insert into identification_agent (
						identification_id,
						agent_id,
						identifier_order) 
					values (
						sq_identification_id.currval,
						#newIdById_two#,
						2
						)
				</cfquery>
			 </cfif>
			 <cfif len(#newIdById_three#) gt 0>
				<cfquery name="newIdAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					insert into identification_agent (
						identification_id,
						agent_id,
						identifier_order) 
					values (
						sq_identification_id.currval,
						#newIdById_three#,
						3
						)
				</cfquery>
			 </cfif>
			 <cfquery name="newId2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				INSERT INTO identification_taxonomy (
					identification_id,
					taxon_name_id,
					variable)
				VALUES (
					sq_identification_id.currval,
					#TaxonAID#,
					'A')
			 </cfquery>
			 <cfif #taxa_formula# contains "B">
				 <cfquery name="newId3" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					INSERT INTO identification_taxonomy (
						identification_id,
						taxon_name_id,
						variable)
					VALUES (
						sq_identification_id.currval,
						#TaxonBID#,
						'B')
				 </cfquery>
			 </cfif>
</cfloop>
	</cftransaction>
	<cflocation url="multiIdentification.cfm?collection_object_id=#collection_object_id#" addtoken="no">
	
</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------->
	<cfinclude template="includes/_footer.cfm">

<DIV ID="theCalendar" STYLE="position:absolute;visibility:hidden;background-color:white;layer-background-color:white;"></DIV>