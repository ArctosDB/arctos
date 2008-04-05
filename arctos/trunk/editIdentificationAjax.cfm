<div id="theHead">
	<cfinclude template="/includes/_header.cfm">
</div>
<script type='text/javascript' src='/includes/_editIdentification.js'></script>
<script type='text/javascript' src='/includes/jquery/jquery.js'></script>
<script type="text/javascript" language="javascript">
jQuery( function($) {
	//setInterval(checkRequired,500);
	
});


function checkRequired(){	
	// loop over all the forms...
	$('form').each(function(){
		var fid=this.id;
		console.log('checking form ' + fid);
		// and all the className=reqdClr elements
		var hasIssues;
		$('#' + fid + ' > :input.reqdClr').each(function() {
			var id=this.id;
			console.log('checking form ' + fid + ' input ' + id);
			// see if they have something
			if (document.getElementById(id).value.length == 0) {
				hasIssues=1;
			}
		});
		if (hasIssues == 1) {
			// form is NOT ready for submission
			document.getElementById(fid).setAttribute('onsubmit',"return false");
			$("#" + fid + " > *[@type='submit']").val("Not ready...");			
		} else {
			document.getElementById(fid).removeAttribute('onsubmit');
			$("#" + fid + " > :input[@type='submit']").val("spiffy!");
		}
	});
}


function removeHelpDiv() {
	if (document.getElementById('helpDiv')) {
		$('#helpDiv').remove();
	}
}
</script>
<cfif #Action# is "nothing">
<cfquery name="ctFormula" datasource="#Application.web_user#">
	select taxa_formula from cttaxa_formula order by taxa_formula
</cfquery>
<cfoutput>
<cfquery name="getID" datasource="#Application.web_user#">
	SELECT
		identification.identification_id,
		institution_acronym,
		identification.scientific_name, 
		cat_num, 
		cataloged_item.collection_cde, 
		agent_name,
		identifier_order,
		identification_agent.agent_id,
		made_date,
		nature_of_id, 
		accepted_id_fg, 
		identification_remarks
	FROM 
		cataloged_item, 
		identification,
		collection ,
		identification_agent,
		preferred_agent_name
	WHERE 
		identification.collection_object_id = cataloged_item.collection_object_id AND
		identification.identification_id = identification_agent.identification_id (+) AND
		identification_agent.agent_id = preferred_agent_name.agent_id (+) AND
		cataloged_item.collection_id=collection.collection_id AND
		cataloged_item.collection_object_id = #collection_object_id#
		ORDER BY accepted_id_fg
	DESC
</cfquery>
<cfquery name="ctnature" datasource="#Application.web_user#">
	select nature_of_id from ctnature_of_id
</cfquery>
<input type="button" onclick="checkRequired()" value="checkRequired">



<form name="newID" id="newID" method="post" action="editIdentification.cfm">
	<input type="hidden" name="Action" value="createNew">
    <input type="hidden" name="collection_object_id" value="#collection_object_id#" >
<table class="newRec">
	<tr>
 		<td colspan="2">
			<strong><font size="+1">Add new Determination</font></strong>&nbsp;
		</td>
 	</tr>
 	<tr>
		<td>
			<span class="helpLink" id="identification.taxa_formula">ID Formula:</span>
		</td>
<td>
			<cfif not isdefined("taxa_formula")>
				<cfset taxa_formula='A'>
			</cfif>
			<cfset thisForm = "#taxa_formula#">
			<select name="taxa_formula" id="taxa_formula" size="1" class="reqdClr"
				onchange="newIdFormula(this.value);">
				<cfloop query="ctFormula">
					<cfif #ctFormula.taxa_formula# is "A">
						<cfset thisDispVal = "one taxon">
					<cfelseif #ctFormula.taxa_formula# is "A ?">
						<cfset thisDispVal = 'taxon + "?"'>
					<cfelseif #ctFormula.taxa_formula# is "A or B">
						<cfset thisDispVal = 'A "or" B'>
					<cfelseif #ctFormula.taxa_formula# is "A / B intergrade">
						<cfset thisDispVal = 'A / B intergrade'>
					<cfelseif #ctFormula.taxa_formula# is "A x B">
						<cfset thisDispVal = 'A "x" B'>
					<cfelseif #ctFormula.taxa_formula# is "A and B">
						<cfset thisDispVal = 'A "and" B'>
					<cfelseif #ctFormula.taxa_formula# is "A sp.">
						<cfset thisDispVal = 'A "sp."'>
					<cfelseif #ctFormula.taxa_formula# is "A cf.">
						<cfset thisDispVal = 'A "cf."'>
					<cfelseif #ctFormula.taxa_formula# is "A aff.">
						<cfset thisDispVal = 'A "aff."'>
					<cfelseif #ctFormula.taxa_formula# is "A ssp.">
						<cfset thisDispVal = 'A "ssp."'>
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
              <td colspan="2">
						<input type="submit" value="missing elements">
            </td>
            </tr>


	</form>
	<!---
	<input id="f1_1" class="reqdClr">
	<input id="f1_2" class="reqdClr">
	<input id="f1_3" class="reqdClr">
		<input id="f1_4" class="booger">

</form>
---->
</cfoutput>
</cfif>
<!---
	
<!--------------------------------------------------------------------------------------------------->

</div><!--- kill content div --->








<!---   




		
	
	<tr> 
    	<td><div align="right">Taxon A:</div></td>
        	<td>
				<input type="text" name="taxa_a" id="taxa_a" class="reqdClr" size="50"
					onChange="taxaPick('TaxonAID','taxa_a','newID',this.value); return false;"
					onKeyPress="return noenter(event);">
					<input type="hidden" name="TaxonAID" id="TaxonAID" class="reqdClr"> 
			  </td>
            </tr>
	--->   
	
			<!----
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
            	<td>
					<div align="right">
			  			<span class="helpLink" id="identified_by">ID By:</span>
			  		 </div>
				</td>
              	<td>
					<input type="text" name="idBy" id="idBy" class="reqdClr" size="50" 
			 		 onchange="getAgent('newIdById','idBy','newID',this.value); return false;"
			  		 onkeypress="return noenter(event);"> 
                	<input type="hidden" name="newIdById" id="newIdById" class="reqdClr"> 
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
              <td><select name="nature_of_id" id="nature_of_id" size="1" class="reqdClr">
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
              <td><input type="text" name="identification_remarks" id="identification_remarks" size="50"></td>
            </tr>
           
          --->
        
<!----
<p>
<strong><font size="+1">Edit an Existing Determination</font></strong>
<img src="/images/info.gif" border="0" onClick="getDocs('identification')" class="likeLink">
</p>
<cfset i = 1>
<cfquery name="distIds" dbtype="query">
	SELECT
		identification_id,
		institution_acronym,
		scientific_name, 
		cat_num, 
		collection_cde, 
		made_date,
		nature_of_id, 
		accepted_id_fg, 
		identification_remarks
	FROM 
		getID
	GROUP BY
		identification_id,
		institution_acronym,
		scientific_name, 
		cat_num, 
		collection_cde, 
		made_date,
		nature_of_id, 
		accepted_id_fg, 
		identification_remarks
	ORDER BY 
		accepted_id_fg DESC,
		made_date
</cfquery>
<cfloop query="distIds">
	<cfquery name="identifiers" dbtype="query">
		select 
			agent_name,
			identifier_order,
			agent_id
		FROM
			getID
		WHERE
			identification_id=#identification_id#
		ORDER BY
			identifier_order
	</cfquery>
	<cfset thisIdentification_id = #identification_id#>
	
<form name="id#thisIdentification_id#" method="post" action="editIdentification.cfm"  onSubmit="return gotAgentId(this.newIdById.value)">
	       
          
            <table id="mainTable_#thisIdentification_id#">
              <tr> 
                <td><div align="right">Scientific Name:</div></td>
                <td><b><i>#scientific_name#</i></b>
				
				  
			    </td>
              </tr>
              <tr> 
                <td><div align="right">Accepted?:</div></td>
				<td>
				<cfif #accepted_id_fg# is 0>
				<select name="ACCEPTED_ID_FG" id="accepted_id_fg_#thisIdentification_id#"size="1" class="reqdClr" onchange="flippedAccepted(this.value,'#collection_object_id#','#thisIdentification_id#');this.className='red';">
                    <option value="1"
							<cfif #ACCEPTED_ID_FG# is 1> selected </cfif>>yes</option>
                    <option 
							<cfif #accepted_id_fg# is 0> selected </cfif>value="0">no</option>
                  </select> 
				  <cfelse>
				  	<b>Yes</b>
				  </cfif>
				  
			    </td>
              </tr>
              <!---
			  <tr> 
                <td><div align="right"> <a href="javascript:void(0);" class="novisit" onClick="getDocs('identification','id_by')">ID By:</a>
				</div></td>
                <td><input type="text" name="idBy" value="#getID.agent_name#" class="reqdClr"
				 size="50" onchange="getAgent('newIdById','idBy','id#i#',this.value); return false;"
				 oonKeyPress="return noenter(event);"> 
                <input type="hidden" name="newIdById"> 
				
				
			</td>
              </tr>
			  --->
			  
			  <tr>
					<td colspan="2">
					<table id="identifierTable_#thisIdentification_id#">
					<tbody id="identifierTableBody_#thisIdentification_id#">
			 <cfloop query="identifiers">
				<!--- this needs to be a table with an ID so we can get at it via the DOM --->
				
				
				<tr id="IdTr_#thisIdentification_id#_#agent_id#">
					<td>
						Identified By:
					</td>
					<td>
						<input type="text" 
							name="IdBy_#thisIdentification_id#_#agent_id#" 
							id="IdBy_#thisIdentification_id#_#agent_id#" 
							value="#agent_name#" 
							class="reqdClr"
							size="50" 
							onchange="this.className='red';getAgent('IdById_#thisIdentification_id#_#agent_id#','IdBy_#thisIdentification_id#_#agent_id#','id#thisIdentification_id#',this.value); return false;"
				 			onKeyPress="return noenter(event);"> 
							<!---
							<img src="/images/down.gif" class="likeLink" onclick="rearrangeIdentifiers('down','#thisIdentification_id#','#agent_id#');" />
							<img src="/images/up.gif" class="likeLink" onclick="rearrangeIdentifiers('up','#thisIdentification_id#','#agent_id#');" />
							--->
				 <input type="hidden" name="IdById_#thisIdentification_id#_#agent_id#" id="IdById_#thisIdentification_id#_#agent_id#" value="#agent_id#"> 
				<img src="/images/del.gif" class="likeLink" onclick="removeIdentifier('#thisIdentification_id#','#agent_id#')" />
				 <img src="/images/save.gif" id="saveButton#thisIdentification_id#_#agent_id#" class="likeLink" onclick="saveIdentifierChange('IdBy_#thisIdentification_id#_#agent_id#');" />
					</td>
				</tr>
				
			</cfloop>
			</tbody>
				</table>
				</td>
				</tr>
				<cfquery name="maxID" dbtype="query">select max(identifier_order) as nid from identifiers</cfquery>
				<input type="hidden" name="number_of_identifiers" value="#maxID.nid#" />
              <tr>
					<td>
						Add Identifier:
					</td>
					<td>
						<input type="text" 
							name="newidentifier_#thisIdentification_id#" 
							id="newidentifier_#thisIdentification_id#" 
							size="50" onchange="getAgent('newidentifierID_#thisIdentification_id#','newidentifier_#thisIdentification_id#','id#thisIdentification_id#',this.value); return false;"
				 oonKeyPress="return noenter(event);"> 
				 <img src="/images/save.gif" class="likeLink" onclick="addIdentifier('newidentifier_#thisIdentification_id#','#thisIdentification_id#',document.getElementById('newidentifierID_#thisIdentification_id#').value);" />
				 <input type="hidden" name="newidentifierID_#thisIdentification_id#" id="newidentifierID_#thisIdentification_id#"> 
					</td>
				</tr>
			  <tr> 
                <td><div align="right">
				<a href="javascript:void(0);" class="novisit" onClick="getDocs('identification','id_date')">ID Date:</a></td></div></td>
                <td><input type="text" value="#dateformat(made_date,'dd-mmm-yyyy')#" name="made_date" id="made_date_#thisIdentification_id#" onchange="saveIdDateChange('#thisIdentification_id#', this.value);"> 
                </td>
              </tr>
              <tr> 
                <td><div align="right">
				<a href="javascript:void(0);" class="novisit" onClick="getDocs('identification','nature_of_id')"> Nature of ID:</a></td>
				</div></td>
                <td>
				<cfset thisID = #nature_of_id#>
				<select name="nature_of_id" id="nature_of_id_#thisIdentification_id#" size="1" class="reqdClr" onchange="saveNatureOfId('#thisIdentification_id#', this.value);">
                    <cfloop query="ctnature">
                      <option <cfif #ctnature.nature_of_id# is #thisID#> selected </cfif> value="#ctnature.nature_of_id#">#ctnature.nature_of_id#</option>
                    </cfloop>
                  </select>
				  <img 
				class="likeLink" 
				src="/images/ctinfo.gif"
				border="0"
				alt="Code Table Value Definition"
				onClick="getCtDoc('ctnature_of_id',id#thisIdentification_id#.nature_of_id.value)">
				</td>
              </tr>
              <tr> 
                <td><div align="right">Remarks:</div></td>
                <td><input type="text" name="identification_remarks" id="identification_remarks_#thisIdentification_id#" value="#identification_remarks#" size="50" onchange="saveIdRemarks('#thisIdentification_id#', this.value);"></td>
              </tr>
              <tr> 
                <td colspan="2"><div align="center">
					<cfif #ACCEPTED_ID_FG# is 0>
						 <input type="button" 
						 value="Delete" 
						 class="delBtn"
						 onmouseover="this.className='delBtn btnhov'" 
						 onmouseout="this.className='delBtn'"
						 onClick="deleteIdentification('#thisIdentification_id#');">
					</cfif>
					
                  </div></td>
              </tr>
            </table>
           
      </form>
<cfset i = #i#+1>
</cfloop>
 ---->
</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------->

<!----------------------------------------------------------------------------------->
<cfif #Action# is "deleteIdent">
	<cfif #accepted_id_fg# is "1">
		<font color="#FF0000" size="+1">You can't delete the accepted identification!</font> 
		<cfabort>
    </cfif>
	<cftransaction>
		<cfquery name="deleteId" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			DELETE FROM identification WHERE identification_id = #identification_id#
		</cfquery>
		<cfquery name="deleteTId" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			DELETE FROM identification_taxonomy WHERE identification_id = #identification_id#
		</cfquery>
	</cftransaction>
	<cf_logEdit collection_object_id="#collection_object_id#">
  <cflocation url="editIdentification.cfm?collection_object_id=#collection_object_id#">
</cfif>
<!----------------------------------------------------------------------------------->

<!--------------------------------------------------------------------------------------------------->
<cfif #Action# is "multi">
	<!--- edit IDs for a list of specimens passed in from specimenresults --->
	<!--- no security --->
<cfset title = "Edit Identification">
<cfquery name="ctnature" datasource="#Application.web_user#">
	select nature_of_id from ctnature_of_id
</cfquery>
<cfoutput>
<cfquery name="getID" datasource="#Application.web_user#">
	SELECT
		identification_id, 
		identification.scientific_name, 
		cat_num, 
		collection_cde, 
		agent_name, 
		made_date,
		nature_of_id, 
		accepted_id_fg, 
		identification_remarks
	FROM 
		cataloged_item, 
		identification, 
		preferred_agent_name
	WHERE 
		identification.collection_object_id = cataloged_item.collection_object_id AND
		identification.id_made_by_agent_id = preferred_agent_name.agent_id AND
		cataloged_item.collection_object_id IN ( #collection_object_id# )
	ORDER BY accepted_id_fg
	DESC
</cfquery>
</cfoutput> <cfoutput> <strong>Add Identification For <font size="+1"><i>All</i></font> 
  specimens listed below:</strong> 
  <table>
  <form name="newID" method="post" action="editIdentification.cfm">
	      <input type="hidden" name="content_url" value="editIdentification.cfm">
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
		
		
  
  

<cfquery name="specimenList" datasource="#Application.web_user#">
	 SELECT 
	 	cataloged_item.collection_object_id as collection_object_id, 
		cat_num,
		concatSingleOtherId(cataloged_item.collection_object_id,'#Client.CustomOtherIdentifier#') AS CustomID,
		scientific_name,
		country,
		state_prov,
		county,
		quad,
		institution_acronym,
		collection.collection_cde
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
		AND cataloged_item.collection_id = collection.collection_id
		AND cataloged_item.collection_object_id IN (#collection_object_id#)
	ORDER BY 
		collection_object_id
</cfquery>
</cfoutput>
<br><b>Specimens Being Re-Identified:</b>

<table width="95%" border="1">
<tr>
	<td><strong>Catalog Number</strong></td>
	<td><strong><cfoutput>#Client.CustomOtherIdentifier#</cfoutput></strong></td>
	<td><strong>Accepted Scientific Name</strong></td>
	<td><strong>Country</strong></td>
	<td><strong>State</strong></td>
	<td><strong>County</strong></td>
	<td><strong>Quad</strong></td>
</tr>
 <cfoutput query="specimenList" group="collection_object_id">
    <tr>
	  <td>
	  	#collection_cde#&nbsp;#cat_num#
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
<cfloop list="#collection_object_id#" index="i">
	<cftransaction>
		<cfquery name="nextID" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			select max(identification_id) + 1 as nextID from identification
		</cfquery>
		<cfquery name="upOldID" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			UPDATE identification SET ACCEPTED_ID_FG=0 where collection_object_id = #i#
		</cfquery>
		<cfquery name="newID" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
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
				,scientific_name,
				id_made_by_agent_id)
			VALUES (
				#nextID.nextID#,
				#i#
				<cfif len(#MADE_DATE#) gt 0>
					,'#dateformat(MADE_DATE,"dd-mmm-yyyy")#'
				</cfif>
				,'#NATURE_OF_ID#'
				 ,1
				 <cfif len(#IDENTIFICATION_REMARKS#) gt 0>
					,'#IDENTIFICATION_REMARKS#'
				</cfif>
				,'#taxa_formula#'
				,'#scientific_name#',
				#newIdById#)
			</cfquery>
			<cfquery name="newIdAgent" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				insert into identification_agent (
					identification_id,
					agent_id,
					identifier_order) 
				values (
					#nextID.nextID#,
					#newIdById#,
					1
					)
			</cfquery>
			 <cfif len(#newIdById_two#) gt 0>
				<cfquery name="newIdAgent" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
					insert into identification_agent (
						identification_id,
						agent_id,
						identifier_order) 
					values (
						#nextID.nextID#,
						#newIdById_two#,
						2
						)
				</cfquery>
			 </cfif>
			 <cfif len(#newIdById_three#) gt 0>
				<cfquery name="newIdAgent" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
					insert into identification_agent (
						identification_id,
						agent_id,
						identifier_order) 
					values (
						#nextID.nextID#,
						#newIdById_three#,
						3
						)
				</cfquery>
			 </cfif>
			 <cfquery name="newId2" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				INSERT INTO identification_taxonomy (
					identification_id,
					taxon_name_id,
					variable)
				VALUES (
					#nextID.nextID#,
					#TaxonAID#,
					'A')
			 </cfquery>
			 <cfif #taxa_formula# contains "B">
				 <cfquery name="newId3" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
					INSERT INTO identification_taxonomy (
						identification_id,
						taxon_name_id,
						variable)
					VALUES (
						#nextID.nextID#,
						#TaxonBID#,
						'B')
				 </cfquery>
			 </cfif>
			 <cfquery name="oneAcc" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				update identification set ACCEPTED_ID_FG=1 where identification_id=#nextID.nextID#
			</cfquery>	
	</cftransaction>
</cfloop>

	<cflocation url="editIdentification.cfm?collection_object_id=#collection_object_id#&Action=multi" addtoken="no">
	
</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------->




















<!----------------------------------------------------------------------------------->
<cfif #Action# is "createNew">
<cfquery name="nextID" datasource="#Application.web_user#">
	select max(identification_id) + 1 as nextID from identification
</cfquery>
<cfoutput>
<cfif #taxa_formula# is "A">
	<cfset scientific_name = "#taxa_a#">
<cfelseif #taxa_formula# is "A or B">
	<cfset scientific_name = "#taxa_a# or #taxa_b#">
<cfelseif #taxa_formula# is "A and B">
	<cfset scientific_name = "#taxa_a# and #taxa_b#">
<cfelseif #taxa_formula# is "A x B">
	<cfset scientific_name = "#taxa_a# x #taxa_b#">
<cfelseif #taxa_formula# is "A ?">
		<cfset scientific_name = "#taxa_a# ?">
<cfelseif #taxa_formula# is "A sp.">
		<cfset scientific_name = "#taxa_a# sp.">

<cfelseif #taxa_formula# is "A ssp.">
		<cfset scientific_name = "#taxa_a# ssp.">
<cfelseif #taxa_formula# is "A cf.">
		<cfset scientific_name = "#taxa_a# cf.">
<cfelseif #taxa_formula# is "A aff.">
	<cfset scientific_name = "#taxa_a# aff.">
<cfelseif #taxa_formula# is "A / B intergrade">
	<cfset scientific_name = "#taxa_a# / #taxa_b# intergrade">
<cfelse>
	The taxa formula you entered isn't handled yet! Please submit a bug report.
	<cfabort>
</cfif>
<!--- set all IDs to not accepted for this item --->



<cftransaction>
	<cfquery name="upOldID" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		UPDATE identification SET ACCEPTED_ID_FG=0 where collection_object_id = #collection_object_id#
	</cfquery>
	
	<cfquery name="newID" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
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
		,scientific_name,
		id_made_by_agent_id)
	VALUES (
		#nextID.nextID#,
		#COLLECTION_OBJECT_ID#
		<cfif len(#MADE_DATE#) gt 0>
			,'#dateformat(MADE_DATE,"dd-mmm-yyyy")#'
		</cfif>
		,'#NATURE_OF_ID#'
		 ,1
		 <cfif len(#IDENTIFICATION_REMARKS#) gt 0>
			,'#IDENTIFICATION_REMARKS#'
		</cfif>
		,'#taxa_formula#'
		,'#scientific_name#',
		#newIdById#)
		 </cfquery>
		<cfquery name="newIdAgent" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			insert into identification_agent (
				identification_id,
				agent_id,
				identifier_order) 
			values (
				#nextID.nextID#,
				#newIdById#,
				1
				)
		</cfquery>
		 <cfif len(#newIdById_two#) gt 0>
		 	<cfquery name="newIdAgent" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				insert into identification_agent (
					identification_id,
					agent_id,
					identifier_order) 
				values (
					#nextID.nextID#,
					#newIdById_two#,
					2
					)
			</cfquery>
		 </cfif>
		 <cfif len(#newIdById_three#) gt 0>
		 	<cfquery name="newIdAgent" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				insert into identification_agent (
					identification_id,
					agent_id,
					identifier_order) 
				values (
					#nextID.nextID#,
					#newIdById_three#,
					3
					)
			</cfquery>
		 </cfif>
		
		 <cfquery name="newId2" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		 	INSERT INTO identification_taxonomy (
				identification_id,
				taxon_name_id,
				variable)
			VALUES (
				#nextID.nextID#,
				#TaxonAID#,
				'A')
		 </cfquery>
		
		 <cfif #taxa_formula# contains "B">
			 <cfquery name="newId3" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				INSERT INTO identification_taxonomy (
					identification_id,
					taxon_name_id,
					variable)
				VALUES (
					#nextID.nextID#,
					#TaxonBID#,
					'B')
			 </cfquery>
		 </cfif>
		
		<!--- make the newest ID accepted --->
		<cfquery name="oneAcc" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			update identification set ACCEPTED_ID_FG=1 where identification_id=#nextID.nextID#
		</cfquery>	 
</cftransaction>
		 <cf_logEdit collection_object_id="#COLLECTION_OBJECT_ID#">

	<cflocation url="editIdentification.cfm?collection_object_id=#collection_object_id#">
	
</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------->
<!----------------------------------------------------------------------------------->
<cfif #Action# is "saveEdits">

<cfoutput>
<cfif #orig_accepted_id_fg# is "0">
	<cfif #ACCEPTED_ID_FG# is 1>
		<!--- changing from not accepted to accepted - set all others not accepted --->
		<cftransaction>
		<cfquery name="upOldID" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			UPDATE identification SET ACCEPTED_ID_FG=0 where collection_object_id = #collection_object_id#
		</cfquery>
		<cfquery name="newAcceptedId" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			UPDATE identification SET ACCEPTED_ID_FG=1 where identification_id = #identification_id#
		</cfquery>
		</cftransaction>
	</cfif>
</cfif>
	
	<cfquery name="updateId" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		UPDATE identification SET
		nature_of_id = '#nature_of_id#'
		<cfif len(#made_date#) gt 0>
			,made_date = '#dateformat(made_date,'dd-mmm-yyyy')#'
		</cfif>
		<cfif len(#identification_remarks#) gt 0>
			,identification_remarks = '#identification_remarks#'
		</cfif>
	where identification_id=#identification_id#
</cfquery>
	<br />there are #number_of_identifiers# identifiers...
	<cfloop from="1" to="#number_of_identifiers#" index="i">
		<cfset thisIdId = evaluate("IdById" & i)>
		<cfif len(#thisIdId#) gt 0>
			<cfquery name="updateIdA" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				update identification_agent set 
				agent_id=#thisIdId# where
				identifier_order=#i# and
				identification_id=#identification_id#
			</cfquery>
		<cfelse>
			<cfquery name="updateIdA" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				delete from identification_agent
				where identifier_order=#i# and
				identification_id=#identification_id#				
			</cfquery>
		</cfif>
		<hr />
	</cfloop>
	<cfif len(#newidentifierID#) gt 0>
		<cfset thisOrder = #number_of_identifiers# + 1>
		<cfquery name="newIdA" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		insert into identification_agent (
			identification_id,
			agent_id,
			identifier_order) 
		values (
			#identification_id#,
			#newidentifierID#,
			#thisOrder#
			)
		</cfquery>
	</cfif>
			
					
	<!---
		<input type="text" name="idBy#identifier_order#" value="#agent_name#" class="reqdClr"
				 size="50" onchange="getAgent('IdById#identifier_order#','idBy#identifier_order#','id#i#',this.value); return false;"
				 oonKeyPress="return noenter(event);"> 
				 <input type="hidden" name="IdById#identifier_order#"> 
					</td>
					--->
<!---



	<cfquery name="updateId" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
	UPDATE identification SET
		identification_id=#identification_id#
		<cfif len(#newIdById#) gt 0>
			,id_made_by_agent_id = #newIdById#
		</cfif>
		<cfif len(#made_date#) gt 0>
			,made_date = '#dateformat(made_date,'dd-mmm-yyyy')#'
		</cfif>
		<cfif len(#nature_of_id#) gt 0>
			,nature_of_id = '#nature_of_id#'
		</cfif>
		<cfif len(#identification_remarks#) gt 0>
			,identification_remarks = '#identification_remarks#'
		</cfif>
	where identification_id=#identification_id#
	</cfquery>
	
	
		
		
	<cf_logEdit collection_object_id="#collection_object_id#">
	<cflocation url="editIdentification.cfm?collection_object_id=#collection_object_id#">
	--->
</cfoutput>
</cfif>
<!---
<cfoutput>
<script type="text/javascript" language="javascript">
	changeStyle('#getID.institution_acronym#');
	parent.dyniframesize();
</script>
</cfoutput>
--->

<!----
<div id="theFoot">
	<cfinclude template="includes/_footer.cfm">
</div>
<script>
	var thePar = parent.location.href;
	var isFrame = thePar.indexOf('Locality.cfm');
	if (isFrame == -1) {
		document.getElementById("theHead").style.display='none';
		document.getElementById("theFoot").style.display='none';
		changeStyle('#getID.institution_acronym#');
		//parent.dyniframesize();
	}
</script>

---->
---->