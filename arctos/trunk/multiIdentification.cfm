<cfinclude template="/includes/_header.cfm">
<script language="JavaScript" type="text/javascript">
	jQuery(document).ready(function() {
		jQuery("#made_date").datepicker();
	});
</script>
<script type='text/javascript' src='/includes/_editIdentification.js'></script>
<!--------------------------------------------------------------------------------------------------->
<cfif Action is "nothing">
	<!--- edit IDs for a list of specimens passed in from specimenresults --->
	<!--- no security --->
<cfset title = "Edit Identification">
<cfquery name="ctnature" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select nature_of_id from ctnature_of_id
</cfquery>
<cfquery name="ctFormula" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select taxa_formula from cttaxa_formula order by taxa_formula
</cfquery>
<cfoutput>
</cfoutput> <cfoutput> <strong>Add Identification For <font size="+1"><i>All</i></font> 
  specimens listed below:</strong> 
  <table>
  <form name="newID" method="post" action="multiIdentification.cfm">
            <input type="hidden" name="Action" value="createManyNew">
    		<tr>
				<td>
				<a href="javascript:void(0);" class="novisit" onClick="getDocs('identification','id_formula')">ID Formula:</a></td>
				
				<td>
					<cfif not isdefined("taxa_formula")>
						<cfset taxa_formula='A'>
					</cfif>
					<cfset thisForm = "#taxa_formula#">
					<select name="taxa_formula" id="taxa_formula" size="1" class="reqdClr" onchange="newIdFormula(this.value);">
						<cfloop query="ctFormula">
							<option 
								<cfif #thisForm# is "#ctFormula.taxa_formula#"> selected </cfif>value="#ctFormula.taxa_formula#">#taxa_formula#</option>
						</cfloop>
					</select>
			
			<!---
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
					--->
				</td>
			</tr>     
	         
            <tr> 
              <td><div align="right">Taxon A:</div></td>
              <td>
			  	<input type="text" name="taxona" id="taxona" class="reqdClr" size="50" 
				onChange="taxaPick('taxona_id','taxona','newID',this.value); return false;"
				onKeyPress="return noenter(event);">
				<input type="hidden" name="taxona_id" id="taxona_id"> 
			  </td>
            </tr>
			<tr id="userID" style="display:none;"> 
		    	<td>
					<div class="helpLink" id="user_identification">Identification:</div>
				</td>
		         <td>
				  	<input type="text" name="user_id" id="user_id" size="50">
				</td>
		  	</tr>
			<tr id="taxon_b_row" style="display:none;"> 
              <td><div align="right">Taxon B:</div></td>
              <td>
			  	<input type="text" name="taxonb" id="taxonb" class="reqdClr" size="50" 
					onChange="taxaPick('taxonb_id','taxonb','newID',this.value); return false;"
					onKeyPress="return noenter(event);">
				<input type="hidden" name="taxonb_id" id="taxonb_id">
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
              <td><input type="text" name="made_date" id="made_date"></td>
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
		
		
  
  

<cfquery name="specimenList" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	 SELECT 
	 	flat.collection_object_id, 
		flat.cat_num,
		concatSingleOtherId(flat.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID,
		flat.scientific_name,
		flat.country,
		flat.state_prov,
		flat.county,
		flat.quad,
		flat.collection
	FROM 
		flat,#session.SpecSrchTab#
	WHERE 
		flat.collection_object_id=#session.SpecSrchTab#.collection_object_id
	ORDER BY 
		flat.collection_object_id
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
<cfif Action is "createManyNew">

<cfoutput>

<cfif taxa_formula is "A {string}">
	<cfset scientific_name = user_id>
<cfelseif taxa_formula is "A">
	<cfset scientific_name = taxona>
<cfelseif taxa_formula is "A or B">
	<cfset scientific_name = "#taxona# or #taxonb#">
<cfelseif taxa_formula is "A and B">
	<cfset scientific_name = "#taxona# and #taxonb#">
<cfelseif taxa_formula is "A x B">
	<cfset scientific_name = "#taxona# x #taxonb#">
<cfelseif taxa_formula is "A ?">
	<cfset scientific_name = "#taxona# ?">
<cfelseif taxa_formula is "A sp.">
	<cfset scientific_name = "#taxona# sp.">
<cfelseif taxa_formula is "A ssp.">
	<cfset scientific_name = "#taxona# ssp.">
<cfelseif taxa_formula is "A cf.">
	<cfset scientific_name = "#taxona# cf.">
<cfelseif taxa_formula is "A aff.">
	<cfset scientific_name = "#taxona# aff.">
<cfelseif taxa_formula is "A / B intergrade">
	<cfset scientific_name = "#taxona# / #taxonb# intergrade">
<cfelse>
	The taxa formula you entered isn't handled yet! Please submit a bug report.
	<cfabort>
</cfif>
<!--- looop through the collection_object_list and update things one at a time--->
			<cfquery name="theList" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select collection_object_id from #session.SpecSrchTab#
			</cfquery>
			<cfdump var=#theList#>
			<cfset colobjidlist=theList.collection_object_id>
		

looping for #len(colobjidlist)#
		
		
	<cftransaction>
		<cfloop list="#colobjidlist#" index="i">
		#i#
		
		
		<cfquery name="upOldID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			UPDATE identification SET ACCEPTED_ID_FG=0 where collection_object_id = #i#
		</cfquery>
		<cfquery name="newID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			INSERT INTO identification (
				IDENTIFICATION_ID,
				COLLECTION_OBJECT_ID
				<cfif len(MADE_DATE) gt 0>
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
					,'#MADE_DATE#'
				</cfif>
				,'#NATURE_OF_ID#'
				 ,1
				 <cfif len(#IDENTIFICATION_REMARKS#) gt 0>
					,'#stripQuotes(IDENTIFICATION_REMARKS)#'
				</cfif>
				,'#taxa_formula#'
				,'#scientific_name#')
			</cfquery>
			<cfquery name="newIdAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
				<cfquery name="newIdAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
				<cfquery name="newIdAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
			 <cfquery name="newId2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				INSERT INTO identification_taxonomy (
					identification_id,
					taxon_name_id,
					variable)
				VALUES (
					sq_identification_id.currval,
					#taxona_id#,
					'A')
			 </cfquery>
			 <cfif #taxa_formula# contains "B">
				 <cfquery name="newId3" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					INSERT INTO identification_taxonomy (
						identification_id,
						taxon_name_id,
						variable)
					VALUES (
						sq_identification_id.currval,
						#taxonb_id#,
						'B')
				 </cfquery>
			 </cfif>
</cfloop>
	</cftransaction>
	
	<!----
	<cflocation url="multiIdentification.cfm" addtoken="no">
	----->
	all done
</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------->
<cfinclude template="includes/_footer.cfm">