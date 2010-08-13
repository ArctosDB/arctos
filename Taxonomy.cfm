<cfinclude template="includes/_header.cfm">
<cfquery name="ctInfRank" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select infraspecific_rank from ctinfraspecific_rank order by infraspecific_rank
</cfquery>
<cfquery name="ctRelation" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select taxon_relationship  from cttaxon_relation order by taxon_relationship
</cfquery>
<cfquery name="ctSourceAuth" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select source_authority from CTTAXONOMIC_AUTHORITY order by source_authority
</cfquery>
<cfquery name="ctnomenclatural_code" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select nomenclatural_code from ctnomenclatural_code order by nomenclatural_code
</cfquery>
<cfquery name="cttaxon_status" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select taxon_status from cttaxon_status order by taxon_status
</cfquery>
<cfset title="Edit Taxonomy">
<!------------------------------------------------>
<cfif action is "nothing">
	<cfheader statuscode="301" statustext="Moved permanently">
	<cfheader name="Location" value="TaxonomySearch.cfm">
	<cfabort>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<!---
<!---------------------------------------------------------------------------------------------------->
<cfif #Action# is "search">
<cfset title="Taxonomy Search Results">
<cfset SQL = "SELECT 
				taxonomy.TAXON_NAME_ID,
				phylum,
					PHYLCLASS,
				PHYLORDER,
				SUBORDER,
				FAMILY,
				SUBFAMILY,
				GENUS,
				SUBGENUS,
				SPECIES,
				SUBSPECIES,
				VALID_CATALOG_TERM_FG,
				SOURCE_AUTHORITY,
				FULL_TAXON_NAME,
				SCIENTIFIC_NAME,
				AUTHOR_TEXT,
				TRIBE,
				INFRASPECIFIC_RANK,
				common_name 
			 from taxonomy, common_name
				WHERE taxonomy.taxon_name_id = common_name.taxon_name_id (+)">
		<cfif isdefined("phylum") AND len(#phylum#) gt 0>
			<CFSET SQL = "#SQL# AND upper(phylum) LIKE '%#ucase(trim(phylum))#%'">
		</cfif>
		<cfif isdefined("common_name") AND len(#common_name#) gt 0>
			<CFSET SQL = "#SQL# AND upper(common_name) LIKE '%#ucase(trim(common_name))#%'">
		</cfif>
		<cfif isdefined("genus") AND len(#genus#) gt 0>
			<CFSET SQL = "#SQL# AND upper(genus) LIKE '%#ucase(trim(genus))#%'">
		</cfif>
		<cfif isdefined("species") AND len(#species#) gt 0>
			<CFSET SQL = "#SQL# AND upper(species) LIKE '%#ucase(trim(species))#%'">
		</cfif>
		<cfif isdefined("subspecies") AND len(#subspecies#) gt 0>
			<CFSET SQL = "#SQL# AND upper(subspecies) LIKE '%#ucase(trim(subspecies))#%'">
		</cfif>
		<cfif isdefined("full_taxon_name") AND len(#full_taxon_name#) gt 0>
			<CFSET SQL = "#SQL# AND upper(full_taxon_name) LIKE '%#ucase(trim(full_taxon_name))#%'">
		</cfif>
		<cfif isdefined("phylclass") AND len(#phylclass#) gt 0>
			<CFSET SQL = "#SQL# AND upper(phylclass) LIKE '%#ucase(trim(phylclass))#%'">
		</cfif>
		<cfif isdefined("phylorder") AND len(#phylorder#) gt 0>
			<CFSET SQL = "#SQL# AND upper(phylorder) LIKE '%#ucase(phylorder)#%'">
		</cfif>
		<cfif isdefined("suborder") AND len(#suborder#) gt 0>
			<CFSET SQL = "#SQL# AND upper(suborder) LIKE '%#ucase(suborder)#%'">
		</cfif>
		<cfif isdefined("family") AND len(#family#) gt 0>
			<CFSET SQL = "#SQL# AND upper(family) LIKE '%#ucase(trim(family))#%'">
		</cfif>
		<cfif isdefined("subfamily") AND len(#subfamily#) gt 0>
			<CFSET SQL = "#SQL# AND upper(subfamily) LIKE '%#ucase(trim(subfamily))#%'">
		</cfif>
		<cfif isdefined("tribe") AND len(#tribe#) gt 0>
			<CFSET SQL = "#SQL# AND upper(tribe) LIKE '%#ucase(trim(tribe))#%'">
		</cfif>
		<cfif isdefined("subgenus") AND len(#subgenus#) gt 0>
			<CFSET SQL = "#SQL# AND upper(subgenus) LIKE '%#ucase(trim(subgenus))#%'">
		</cfif>
		<cfif isdefined("VALID_CATALOG_TERM_FG") AND len(#VALID_CATALOG_TERM_FG#) gt 0>
			<CFSET SQL = "#SQL# AND VALID_CATALOG_TERM_FG = VALID_CATALOG_TERM_FG">
		</cfif>
			<CFSET SQL = "#SQL# ORDER BY taxon_name_id">
		<cfquery name="getTaxa" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			#preservesinglequotes(SQL)#
		</cfquery>
		
		<table border="1">
  <tr>
  	<td>&nbsp;</td>
	
            <td><strong>Scientific Name</strong></td>
			<td><strong>Author Text</strong></td>
			<td><strong>Phylum</strong></td>
			<td><strong>Phylclass</strong></td>
            <td><strong>Phylorder</strong></td>
            <td><strong>Suborder</strong></td>
            <td><strong>Family</strong></td>
	        <td><strong>Subfamily</strong></td>
            <td><strong>Tribe</strong></td>
            <td><strong>Genus</strong></td>
            <td><strong>Subgenus</strong></td>
            <td><strong>Species</strong></td>
            <td><strong>Subspecies</strong></td>
    
  </tr>
  <cfoutput query="getTaxa"  group="taxon_name_id">
  <tr>
    <td>
	<form action="Taxonomy.cfm" method="post" name="details">
		<input type="hidden" name="Action" value="Edit">
		<input type="submit" value="Edit" class="lnkBtn"
   onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'">
		
		<input name="taxon_name_id" type="hidden" value="#taxon_name_id#">
	</form>
	</td>
    <td>#scientific_name#&nbsp;</td>
	<td>#author_text#&nbsp;</td>
	<td>#phylum#&nbsp;</td>
	<td>#Phylclass#&nbsp;</td>
    <td>#Phylorder#&nbsp;</td>
    <td>#Suborder#&nbsp;</td>
    <td>#Family#&nbsp;</td>
	<td>#Subfamily#&nbsp;</td>
    <td>#Tribe#&nbsp;</td>
    <td>#Genus#&nbsp;</td>
    <td>#Subgenus#&nbsp;</td>
    <td>#Species#&nbsp;</td>
    <td>#Subspecies#&nbsp;</td>
  </tr>
  </cfoutput>
</table>

</cfif>
<!---------------------------------------------------------------------------------------------------->
--->
<!---------------------------------------------------------------------------------------------------->
<cfif action is "edit">
	<cfset title="Edit Taxonomy">
	<cfquery name="getTaxa" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from taxonomy where taxon_name_id=#taxon_name_id#
	</cfquery>
<cfoutput>
	<span style="font-size:large;font-weight:bold">Edit Taxonomy: <em>#getTaxa.scientific_name#</em></span>
	<span class="infoLink" onClick="getDocs('taxonomy');">What's this?</span>
	<a class="infoLink" href="/name/#getTaxa.scientific_name#">Detail Page</a>
    <table border>
	<form name="taxa" method="post" action="Taxonomy.cfm">
    	<input type="hidden" name="taxon_name_id" value="#getTaxa.taxon_name_id#">
        <input type="hidden" name="Action">
		<tr>
			<td>
				<label for="source_authority">
					<span class="likeLink" onClick="getDocs('taxonomy','source_authority');">Source</span>
				</label>
				<select name="source_authority" id="source_authority" size="1"  class="reqdClr">
		             <cfloop query="ctSourceAuth">
		               <option <cfif gettaxa.source_authority is ctsourceauth.source_authority> selected="selected" </cfif>
							value="#ctSourceAuth.source_authority#">#ctSourceAuth.source_authority#</option>
		             </cfloop>
		        </select>
			</td>
			<td>
				<label for="valid_catalog_term_fg"><span class="likeLink" onClick="getDocs('taxonomy','valid_term');">ValidForCatalog?</span></label>
				<select name="valid_catalog_term_fg" id="valid_catalog_term_fg" size="1" class="reqdClr">
			    	<option <cfif getTaxa.valid_catalog_term_fg is "1"> selected="selected" </cfif> value="1">yes</option>
			        <option <cfif getTaxa.valid_catalog_term_fg is "0"> selected="selected" </cfif> value="0">no</option>
			    </select>
			</td>
		</tr>
      	<tr>
			<td>
				<label for="nomenclatural_code"><span class="likeLink" onClick="getDocs('taxonomy','nomenclatural_code');">Nomenclatural Code</span></label>
				<select name="nomenclatural_code" id="nomenclatural_code" size="1" class="reqdClr">
			    	<cfloop query="ctnomenclatural_code">
			        	<option <cfif gettaxa.nomenclatural_code is ctnomenclatural_code.nomenclatural_code> selected="selected" </cfif>
			            	value="#ctnomenclatural_code.nomenclatural_code#">#ctnomenclatural_code.nomenclatural_code#</option>
			        </cfloop>
				</select>
			</td>
			<td>
				<label for="genus">Genus <span class="likeLink" onClick="taxa.genus.value='&##215;' + taxa.genus.value;">Add &##215;</span></label>
				<input size="25" name="genus" id="genus" maxlength="40" value="#gettaxa.genus#">
			</td>
		</tr>
		<tr>
			<td>
				<label for="species">Species <span class="likeLink" 
					onClick="taxa.species.value='&##215;' + taxa.species.value;">Add &##215;</span></label>
				<input size="25" name="species" id="species" maxlength="40" value="#gettaxa.species#">
			</td>
			<td>
				<label for="author_text"><span class="likeLink" onClick="getDocs('taxonomy','author_text');">Species Author</span></label>
				<input type="text" name="author_text" id="author_text" value="#gettaxa.author_text#" size="30">
				<span class="infoLink" 
					onclick="window.open('/picks/KewAbbrPick.cfm?tgt=author_text','picWin','width=700,height=400, resizable,scrollbars')">
					Find Kew Abbr
				</span>
			</td>
		</tr>
		<tr>
			<td>
				<label for="infraspecific_rank"><span class="likeLink" onClick="getDocs('taxonomy','infraspecific_rank');">Infraspecific Rank</span></label>
				<select name="infraspecific_rank" id="infraspecific_rank" size="1">
                	<option value=""></option>
	                <cfloop query="ctInfRank">
	                  <option 
							<cfif gettaxa.infraspecific_rank is ctinfrank.infraspecific_rank> selected="selected" </cfif>value="#ctInfRank.infraspecific_rank#">#ctInfRank.infraspecific_rank#</option>
	                </cfloop>
              	</select>
			</td>
			<td>
				<label for="taxon_status"><span class="likeLink" onClick="getDocs('taxonomy','taxon_status');">Taxon Status</span></label>
				<select name="taxon_status" id="taxon_status" size="1">
			    	<option value=""></option>
			    	<cfloop query="cttaxon_status">
			        	<option <cfif gettaxa.taxon_status is cttaxon_status.taxon_status> selected="selected" </cfif>
			            	value="#cttaxon_status.taxon_status#">#cttaxon_status.taxon_status#</option>
			        </cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td>
				<label for="subspecies">Subspecies</label>
				<input size="25" name="subspecies" id="subspecies" maxlength="40" value="#gettaxa.subspecies#">
			</td>
			<td>
				<label for="author_text"><span class="likeLink" onClick="getDocs('taxonomy','infraspecific_author');">
					Infraspecific Author</span></label>
				<input type="text" name="infraspecific_author" id="infraspecific_author" value="#gettaxa.infraspecific_author#" size="30">
				<span class="infoLink" 
					onclick="window.open('/picks/KewAbbrPick.cfm?tgt=infraspecific_author','picWin','width=700,height=400, resizable,scrollbars')">
						Find Kew Abbr
					</span>
			</td>
		</tr>
		<tr>
			<td>
				<label for="kingdom">Kingdom</label>
				<input type="text" name="kingdom" id="kingdom" value="#gettaxa.kingdom#" size="30">
			</td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td>
				<label for="phylum">Phylum</label>
				<input type="text" name="phylum" id="phylum" value="#gettaxa.phylum#" size="30">
			</td>
			<td>
				<label for="phylclass">Class</label>
				<input type="text" name="phylclass" id="phylclass" value="#gettaxa.phylclass#" size="30">
			</td>
		</tr>
		<tr>
			<td>
				<label for="phylorder">Order</label>
				<input type="text" name="phylorder" id="phylorder" value="#gettaxa.phylorder#" size="30">
			</td>
			<td>
				<label for="suborder">Suborder</label>
				<input type="text" name="suborder" id="suborder" value="#gettaxa.suborder#" size="30">
			</td>
		</tr>
		<tr>
			<td>
				<label for="family">Family</label>
				<input type="text" name="family" id="family" value="#gettaxa.family#" size="30">
			</td>
			<td>
				<label for="subfamily">Subfamily</label>
				<input type="text" name="subfamily" id="subfamily" value="#gettaxa.subfamily#" size="30">
			</td>
		</tr>
		<tr>
			<td>
				<label for="tribe">Tribe</label>
				<input type="text" name="tribe" id="tribe" value="#gettaxa.tribe#" size="30">
			</td>
			<td>
				<label for="subfamily">Subgenus</label>
				<input type="text" name="subgenus" id="subgenus" value="#gettaxa.subgenus#" size="30">
			</td>
		</tr>
        <tr>
			<td colspan="2">
				<label for="taxon_remarks">Remarks</label>
				<textarea name="taxon_remarks" id="taxon_remarks" rows="3" cols="60">#gettaxa.taxon_remarks#</textarea>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<div align="center">
					<input type="button" value="Save" class="savBtn" onclick="taxa.Action.value='saveTaxaEdits';submit();">
              		<input type="button" value="Clone" class="insBtn" onclick="taxa.Action.value='newTaxa';submit();">
   					<input type="button" value="Delete" class="delBtn"	onclick="taxa.Action.value='deleTaxa';confirmDelete('taxa');">
				</div>
			</td>
		</tr>
      </form>
    </table>
</cfoutput>
<cfoutput>
<cfquery name="relations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT 
		scientific_name, 
		taxon_relationship,
		relation_authority,
		related_taxon_name_id
	FROM 
		taxon_relations,
		taxonomy
	WHERE
		taxon_relations.related_taxon_name_id = taxonomy.taxon_name_id 
		AND taxon_relations.taxon_name_id = #taxon_name_id#
</cfquery>
<cfset i = 1>
<span class="likeLink" onClick="getDocs('taxonomy','taxon_relations');">Related Taxa:</span>
<table border="1">
	<tr>
		<th>Relationship</th>
		<th>Related Taxa</th>
		<th>Authority</th>
	</tr>
	<form name="newRelation" method="post" action="Taxonomy.cfm">
		<input type="hidden" name="taxon_name_id" value="#getTaxa.taxon_name_id#">
		<input type="hidden" name="Action" value="newTaxaRelation">
		<tr class="newRec">
			<td>
				<label for="taxon_relationship">Add Relationship</label>
				<select name="taxon_relationship" size="1" class="reqdClr">
					<cfloop query="ctRelation">
						<option value="#ctRelation.taxon_relationship#">#ctRelation.taxon_relationship#</option>
					</cfloop>
				</select>
			</td>
			<td>
				<input type="text" name="relatedName" class="reqdClr" size="50" 
					onChange="taxaPick('newRelatedId','relatedName','newRelation',this.value); return false;"
					onKeyPress="return noenter(event);">
				<input type="hidden" name="newRelatedId">
			</td>
			<td>
				<input type="text" name="relation_authority">
			</td>
			<td>
				<input type="submit" value="Create" class="insBtn">	
   
   			</td>
		</tr>
	</form>
	<cfloop query="relations">
		<form name="relation#i#" method="post" action="Taxonomy.cfm">
			<input type="hidden" name="taxon_name_id" value="#getTaxa.taxon_name_id#">
			<input type="hidden" name="Action">
			<input type="hidden" name="related_taxon_name_id" value="#related_taxon_name_id#">
			<input type="hidden" name="origTaxon_Relationship" value="#taxon_relationship#">
			<tr>
				<td>
					<select name="taxon_relationship" size="1" class="reqdClr">
						<cfloop query="ctRelation">
							<option <cfif ctRelation.taxon_relationship is relations.taxon_relationship> 
								selected="selected" </cfif>value="#ctRelation.taxon_relationship#">#ctRelation.taxon_relationship#
							</option>
						</cfloop>
					</select>
				</td>
				<td>
					<input type="text" name="relatedName" class="reqdClr" size="50" value="#relations.scientific_name#"
						onChange="taxaPick('newRelatedId','relatedName','relation#i#',this.value); return false;"
						onKeyPress="return noenter(event);">
					<input type="hidden" name="newRelatedId">
				</td>
				<td>
					<input type="text" name="relation_authority" value="#relations.relation_authority#">
				</td>
				<td>
					<input type="button" value="Save" class="savBtn" onclick="relation#i#.Action.value='saveRelnEdit';submit();">	
					<input type="button" value="Delete" class="delBtn" onclick="relation#i#.Action.value='deleReln';confirmDelete('relation#i#');">
				</td>
			</tr>
		</form>
		<cfset i = #i#+1>
	</cfloop>
</table>
<cfquery name="common" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select common_name from common_name where taxon_name_id = #taxon_name_id#
</cfquery>
<span class="likeLink" onClick="getDocs('taxonomy','common_names');">Common Names</span>
<cfset i=1>
<cfloop query="common">
	<form name="common#i#" method="post" action="Taxonomy.cfm">
		<input type="hidden" name="Action">
		<input type="hidden" name="origCommonName" value="#common_name#">
		<input type="hidden" name="taxon_name_id" value="#taxon_name_id#">
		<input type="text" name="common_name" value="#common_name#" size="50">
		<input type="button" value="Save" class="savBtn" onClick="common#i#.Action.value='saveCommon';submit();">	
   		<input type="button" value="Delete" class="delBtn" onClick="common#i#.Action.value='deleteCommon';confirmDelete('common#i#');">
	</form>
	<cfset i=i+1>
</cfloop>
<table class="newRec">
	<tr>
		<td>
			<form name="newCommon" method="post" action="Taxonomy.cfm">
				<input type="hidden" name="Action" value="newCommon">
				<input type="hidden" name="taxon_name_id" value="#taxon_name_id#">
				<label for="common_name">New Common Name</label>
				<input type="text" name="common_name" size="50">
				<input type="submit" value="Create" class="insBtn">	
			</form>
		</td>
	</tr>
</table>
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "newCommon">
<cfoutput>
	<cfquery name="newCommon" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		INSERT INTO common_name (common_name, taxon_name_id)
		VALUES ('#common_name#', #taxon_name_id#)
	</cfquery>
	<cflocation url="Taxonomy.cfm?Action=edit&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->

<cfif Action is "deleTaxa">
<cfoutput>
	<cfquery name="deleTaxa" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		DELETE FROM 
			taxonomy
		WHERE 
			taxon_name_id=#taxon_name_id#
	</cfquery>
	You killed it!
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<!---------------------------------------------------------------------------------------------------->
<cfif #Action# is "deleteCommon">
<cfoutput>
	<cfquery name="killCommon" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		DELETE FROM 
			common_name
		WHERE 
			common_name='#origCommonName#' AND taxon_name_id=#taxon_name_id#
	</cfquery>
	<cflocation url="Taxonomy.cfm?Action=edit&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<!---------------------------------------------------------------------------------------------------->
<cfif #Action# is "saveCommon">
<cfoutput>
	<cfquery name="upCommon" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		UPDATE
			common_name
		SET 
			common_name = '#common_name#'
		WHERE 
			common_name='#origCommonName#' AND taxon_name_id=#taxon_name_id#
	</cfquery>
	<cflocation url="Taxonomy.cfm?Action=edit&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif #Action# is "newTaxa">
<cfset title = "Add Taxonomy">
<cfoutput>
<!--- set some passed-in variables as local so we don't confuse CF --->

<table border>
<form name="taxa" method="post" action="Taxonomy.cfm">
	<input type="hidden" name="Action" value="saveNewTaxa">
	
	
	<!---
	<tr><td width="50" align="right"><b><nobr>Phylum:</nobr></b> </td>
	<td><input size="25" name="phylum" maxlength="40" value="#phylum#"></td></tr>
	<tr><td width="50" align="right"><b><nobr>Class:</nobr></b></td>
<td> 
<input size="25" name="phylclass" maxlength="40" value="#phylclass#">
</td></tr>

<tr><td width="50" align="right"><b><nobr>Order:</nobr></b> </td><td><input size="25" name="phylorder" maxlength="40" value="#phylorder#"></td></tr>
<tr><td width="50" align="right"><b><nobr>Suborder:</nobr></b>
</td><td><input size="25" name="suborder" maxlength="40" value="#suborder#"></td></tr>
<tr> <td width="50" align="right"><b><nobr>Family:</nobr></b>
</td><td><input size="25" name="family" maxlength="40" value="#family#"></td></tr>
<tr><td width="50" align="right"><b><nobr>Subfamily:</nobr></b>
</td><td><input size="25" name="subfamily" maxlength="40" value="#subfamily#"></td></tr>
<tr><td width="50" align="right"><b><nobr>Tribe:</nobr></b>
	</td><td><input size="25" name="tribe" maxlength="40" value="#tribe#"></td></tr>
<tr><td width="50" align="right"><b><nobr>Genus:</nobr></b>
	</td><td><input size="25" name="genus" maxlength="40" value="#genus#"></td></tr>
<tr><td width="50" align="right"><b><nobr>Subgenus:</nobr></b>
	</td><td><input size="25" name="subgenus" maxlength="40" value="#subgenus#"></td></tr>
<tr><td width="50" align="right"><b><nobr>Species:</nobr></b>
	</td><td><input size="25" name="species" maxlength="40" value="#species#"></td></tr>
<tr><td width="50" align="right"><b><nobr>Subspecies:</nobr></b>
	</td><td><input size="25" name="subspecies" maxlength="40" value="#subspecies#"></td></tr>
<tr><td align="right"><b>Infraspecific Rank:</b></td>
	<td>	<select name="infraspecific_rank" size="1">
				<option value=""></option>
				<cfloop query="ctInfRank">
					<option 
						<cfif #irk# is "#ctInfRank.infraspecific_rank#"> selected </cfif>value="#ctInfRank.infraspecific_rank#">#ctInfRank.infraspecific_rank#</option>
				</cfloop>
			</select>
	</td>
</tr>	
<tr><td align="right"><b>Valid?</b></td>
	<td> <select name="valid_catalog_term_fg" size="1" class="reqdClr">
			<option <cfif #valid_catalog_term_fg# is "1"> selected </cfif> value="1">yes</option>
			<option 
				<cfif #valid_catalog_term_fg# is "0"> selected </cfif>
				value="0">no</option>
		</select>
	</td></tr>
	<tr><td align="right"><b>Source Authority: </b></td>
	<td> <select name="source_authority" size="1" class="reqdClr">
			<cfloop query="ctSourceAuth">
				<option 
						<cfif #srcauth# is "#ctSourceAuth.source_authority#"> selected </cfif>value="#ctSourceAuth.source_authority#">#ctSourceAuth.source_authority#</option>
			</cfloop>
		</select>
	</td></tr>
	<tr><td align="right"><b>Scientific Name: </b></td>
	<td><input type="text" name="scientific_name" value="#scientific_name#" size="50" readonly="yes" class="readClr">
	</td></tr>
	<tr><td align="right"><b>Remarks: </b></td>
	<td><input type="text" name="taxon_remarks" size="50">
	</td></tr>
	<tr><td align="right"><b>Author Text: </b></td>
	<td><input type="text" name="author_text" value="#author_text#" size="50">
	</td></tr>
	
	---->
	
	<td>
				<label for="source_authority"><span class="likeLink" onClick="getDocs('taxonomy','source_authority');">Source</span></label>
				<select name="source_authority" id="source_authority" size="1"  class="reqdClr">
	              <cfloop query="ctSourceAuth">
	                <option 
						<cfif #form.source_authority# is "#ctsourceauth.source_authority#"> selected </cfif>value="#ctSourceAuth.source_authority#">#ctSourceAuth.source_authority#</option>
	              </cfloop>
	            </select>
			</td>
			<td>
				<label for="valid_catalog_term_fg"><span class="likeLink" onClick="getDocs('taxonomy','valid_term');">Valid?</span></label>
				<select name="valid_catalog_term_fg" id="valid_catalog_term_fg" size="1" class="reqdClr">
	              <option <cfif #valid_catalog_term_fg# is "1"> selected </cfif> value="1">yes</option>
	              <option 
					<cfif #valid_catalog_term_fg# is "0"> selected </cfif>
					value="0">no</option>
	            </select>
			</td>
        </tr>
        <tr> 
        	<td colspan="2">
				<label for="genus">Genus <span class="likeLink" 
					onClick="taxa.genus.value='&##215;' + taxa.genus.value;">Add &##215;</span></label>
				<input size="25" name="genus" id="genus" maxlength="40" value="#genus#">
			</td>
		</tr>
		<tr>
			<td>
				<label for="species">Species <span class="likeLink" 
					onClick="taxa.species.value='&##215;' + taxa.species.value;">Add &##215;</span></label>
				<input size="25" name="species" id="species" maxlength="40" value="#species#">
			</td>
			<td>
				<label for="author_text"><span class="likeLink" onClick="getDocs('taxonomy','author_text');">Species Author</span></label>
				<input type="text" name="author_text" id="author_text" value="#author_text#" size="30">
				<span class="infoLink" 
					onclick="window.open('/picks/KewAbbrPick.cfm?tgt=author_text','picWin','width=700,height=400, resizable,scrollbars')">
						Find Kew Abbr
					</span>
			</td>
		</tr>
		<tr>
			<td>
				<label for="infraspecific_rank"><span class="likeLink" onClick="getDocs('taxonomy','infraspecific_rank');">Infraspecific Rank</span></label>
				<select name="infraspecific_rank" id="infraspecific_rank" size="1">
                	<option <cfif form.infraspecific_rank is ""> selected </cfif>  value=""></option>
	                <cfloop query="ctInfRank">
	                  <option 
							<cfif #form.infraspecific_rank# is "#ctinfrank.infraspecific_rank#"> selected </cfif>value="#ctInfRank.infraspecific_rank#">#ctInfRank.infraspecific_rank#</option>
	                </cfloop>
              	</select>
			</td>
			<td>
				<label for="taxon_status"><span class="likeLink" onClick="getDocs('taxonomy','taxon_status');">Taxon Status</span></label>
				<select name="taxon_status" id="taxon_status" size="1">
			    	<option value=""></option>
			    	<cfloop query="cttaxon_status">
			        	<option <cfif form.taxon_status is cttaxon_status.taxon_status> selected="selected" </cfif>
			            	value="#cttaxon_status.taxon_status#">#cttaxon_status.taxon_status#</option>
			        </cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td>
				<label for="subspecies">Subspecies</label>
				<input size="25" name="subspecies" id="subspecies" maxlength="40" value="#subspecies#">
			</td>
			<td>
				<label for="author_text"><span class="likeLink" onClick="getDocs('taxonomy','infraspecific_author');">
					Infraspecific Author</span></label>
				<input type="text" name="infraspecific_author" id="infraspecific_author" value="#infraspecific_author#" size="30">
				<span class="infoLink" 
					onclick="window.open('/picks/KewAbbrPick.cfm?tgt=infraspecific_author','picWin','width=700,height=400, resizable,scrollbars')">
						Find Kew Abbr
					</span>
			</td>
		</tr>
		<tr>
			<td>
				<label for="kingdom">Kingdom</label>
				<input type="text" name="kingdom" id="kingdom" value="#kingdom#" size="30">
			</td>
			<td>
				<label for="nomenclatural_code"><span class="likeLink" onClick="getDocs('taxonomy','nomenclatural_code');">Nomenclatural Code</span></label>
				<select name="nomenclatural_code" id="nomenclatural_code" size="1" class="reqdClr">
	               <cfloop query="ctnomenclatural_code">
	                <option 
							<cfif #form.nomenclatural_code# is "#ctnomenclatural_code.nomenclatural_code#"> selected </cfif>value="#ctnomenclatural_code.nomenclatural_code#">#ctnomenclatural_code.nomenclatural_code#</option>
	              </cfloop>
	            </select>
			</td>
		</tr>
		<tr>
			<td>
				<label for="phylum">Phylum</label>
				<input type="text" name="phylum" id="phylum" value="#phylum#" size="30">
			</td>
			<td>
				<label for="phylclass">Class</label>
				<input type="text" name="phylclass" id="phylclass" value="#phylclass#" size="30">
			</td>
		</tr>
		<tr>
			<td>
				<label for="phylorder">Order</label>
				<input type="text" name="phylorder" id="phylorder" value="#phylorder#" size="30">
			</td>
			<td>
				<label for="suborder">Suborder</label>
				<input type="text" name="suborder" id="suborder" value="#suborder#" size="30">
			</td>
		</tr>
		<tr>
			<td>
				<label for="family">Family</label>
				<input type="text" name="family" id="family" value="#family#" size="30">
			</td>
			<td>
				<label for="subfamily">Subfamily</label>
				<input type="text" name="subfamily" id="subfamily" value="#subfamily#" size="30">
			</td>
		</tr>
		<tr>
			<td>
				<label for="tribe">Tribe</label>
				<input type="text" name="tribe" id="tribe" value="#tribe#" size="30">
			</td>
			<td>
				<label for="subfamily">Subgenus</label>
				<input type="text" name="subgenus" id="subgenus" value="#subgenus#" size="30">
			</td>
		</tr>
        <tr>
			<td colspan="2">
				<label for="taxon_remarks">Remarks</label>
				<textarea name="taxon_remarks" id="taxon_remarks" rows="3" cols="60">#taxon_remarks#</textarea>
			</td>
		</tr>
<tr>
<td align="center" colspan="2">
 <input type="submit" value="Create" class="insBtn"
   onmouseover="this.className='insBtn btnhov'" onmouseout="this.className='insBtn'">	


</form></table>
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<!---------------------------------------------------------------------------------------------------->
<cfif #Action# is "saveNewtaxa">
<cfoutput>
<cfquery name="nextID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select sq_taxon_name_id.nextval nextID from dual
</cfquery>
	<cfquery name="newTaxa" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	INSERT INTO taxonomy (
		taxon_name_id
		,valid_catalog_term_fg
		,source_authority
		<cfif len(#author_text#) gt 0>
			,author_text		
		</cfif>
		<cfif len(#tribe#) gt 0>
			,tribe			
		</cfif>
		<cfif len(#infraspecific_rank#) gt 0>
			,infraspecific_rank			
		</cfif>
		<cfif len(#phylclass#) gt 0>
			,phylclass			
		</cfif>
		<cfif len(#phylorder#) gt 0>
			,phylorder		
		</cfif>
		<cfif len(#suborder#) gt 0>
			,suborder		
		</cfif>
		<cfif len(#family#) gt 0>
			,family	
		</cfif>
		<cfif len(#subfamily#) gt 0>
			,subfamily	
		</cfif>
		<cfif len(#genus#) gt 0>
			,genus			
		</cfif>
		<cfif len(#subgenus#) gt 0>
			,subgenus		
		</cfif>
		<cfif len(#species#) gt 0>
			,species			
		</cfif>
		<cfif len(#subspecies#) gt 0>
			,subspecies		
		</cfif>	
		<cfif len(#taxon_remarks#) gt 0>
			,taxon_remarks		
		</cfif>	
		<cfif len(#phylum#) gt 0>
			,phylum		
		</cfif>
		<cfif len(#infraspecific_author#) gt 0>
			,infraspecific_author		
		</cfif>
		<cfif len(#kingdom#) gt 0>
			,kingdom		
		</cfif>
		<cfif len(#nomenclatural_code#) gt 0>
			,nomenclatural_code		
		</cfif>	
		<cfif len(taxon_status) gt 0>
			,taxon_status		
		</cfif>		
		)	
	VALUES (
		#nextID.nextID#
		,#valid_catalog_term_fg#
		,'#source_authority#'
		<cfif len(#author_text#) gt 0>
			,'#author_text#'
		</cfif>
		<cfif len(#tribe#) gt 0>
			,'#tribe#'
		</cfif>
		<cfif len(#infraspecific_rank#) gt 0>
			,'#infraspecific_rank#'
		</cfif>
		<cfif len(#phylclass#) gt 0>
			,'#phylclass#'			
		</cfif>
		<cfif len(#phylorder#) gt 0>
			,'#phylorder#'
		</cfif>
		<cfif len(#suborder#) gt 0>
			,'#suborder#'		
		</cfif>
		<cfif len(#family#) gt 0>
			,'#family#'
		</cfif>
		<cfif len(#subfamily#) gt 0>
			,'#subfamily#'	
		</cfif>
		<cfif len(#genus#) gt 0>
			,'#genus#'
		</cfif>
		<cfif len(#subgenus#) gt 0>
			,'#subgenus#'		
		</cfif>
		<cfif len(#species#) gt 0>
			,'#species#'
		</cfif>
		<cfif len(#subspecies#) gt 0>
			,'#subspecies#'		
		</cfif>
		<cfif len(#taxon_remarks#) gt 0>
			,'#taxon_remarks#'		
		</cfif>	
		<cfif len(#phylum#) gt 0>
			,'#phylum#'		
		</cfif>
		<cfif len(#infraspecific_author#) gt 0>
			,'#infraspecific_author#'		
		</cfif>
		<cfif len(#kingdom#) gt 0>
			,'#kingdom#'
		</cfif>
		<cfif len(#nomenclatural_code#) gt 0>
			,'#nomenclatural_code#'		
		</cfif>
		<cfif len(taxon_status) gt 0>
			,'#taxon_status#'		
		</cfif>		
			)
		</cfquery>
		
	<cflocation url="Taxonomy.cfm?Action=edit&taxon_name_id=#nextID.nextID#" addtoken="false">
	
	
	
	
		
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->

<!---------------------------------------------------------------------------------------------------->
<cfif #Action# is "newTaxaRelation">
<cfoutput>
	<cfquery name="newReln" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	INSERT INTO taxon_relations (
		 TAXON_NAME_ID,
		 RELATED_TAXON_NAME_ID,
		 TAXON_RELATIONSHIP
		 <cfif len(#RELATION_AUTHORITY#) gt 0>
		 	,RELATION_AUTHORITY
		 </cfif>
		  )
	VALUES (
		#TAXON_NAME_ID#,
		 #newRelatedId#,
		 '#TAXON_RELATIONSHIP#'
		 <cfif len(#RELATION_AUTHORITY#) gt 0>
		 	,'#RELATION_AUTHORITY#'
		 </cfif> )
		 
	</cfquery>
	<cflocation url="Taxonomy.cfm?Action=edit&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<!---------------------------------------------------------------------------------------------------->
<cfif #Action# is "deleReln">
<cfoutput>
<cfquery name="deleReln" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	DELETE FROM 
		taxon_relations
	WHERE
		taxon_name_id = #taxon_name_id#
		AND Taxon_relationship = '#origtaxon_relationship#'
		AND related_taxon_name_id=#related_taxon_name_id#
		</cfquery>
		<cflocation url="Taxonomy.cfm?Action=edit&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<!---------------------------------------------------------------------------------------------------->
<cfif #Action# is "saveRelnEdit">
<cfoutput>
<cfquery name="edRel" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	UPDATE taxon_relations SET
		taxon_relationship = '#taxon_relationship#'
		<cfif len(#newRelatedId#) gt 0>
			,related_taxon_name_id = #newRelatedId#
		<cfelse>
			,related_taxon_name_id = #related_taxon_name_id#
		</cfif>
		<cfif len(#relation_authority#) gt 0>
			,relation_authority = '#relation_authority#'
		<cfelse>
			,relation_authority = null
		</cfif>
	WHERE
		taxon_name_id = #taxon_name_id#
		AND Taxon_relationship = '#origTaxon_relationship#'
		AND related_taxon_name_id=#related_taxon_name_id#
</cfquery>
<cflocation url="Taxonomy.cfm?Action=edit&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfoutput>

</cfif>
<!---------------------------------------------------------------------------------------------------->

<!---------------------------------------------------------------------------------------------------->
<cfif #Action# is "saveTaxaEdits">
<cfoutput>
<cftransaction>
<!----
<cfif #session.username# is "steffi">
username='#session.username#'
 password="#decrypt(session.epw,cfid)#"
<cfflush>
		</cfif>
	---->
	<cfquery name="edTaxa" datasource="user_login" username='#session.username#' password="#decrypt(session.epw,cfid)#">
	UPDATE taxonomy SET 
		valid_catalog_term_fg=#valid_catalog_term_fg#
		,source_authority = '#source_authority#'
		<cfif len(#author_text#) gt 0>
			,author_text='#author_text#'
		<cfelse>
			,author_text=null			
		</cfif>
		<cfif len(#tribe#) gt 0>
			,tribe = '#tribe#'
		<cfelse>
			,tribe = null			
		</cfif>
		<cfif len(#infraspecific_rank#) gt 0>
			,infraspecific_rank = '#infraspecific_rank#'
		<cfelse>
			,infraspecific_rank = null			
		</cfif>
		<cfif len(#phylclass#) gt 0>
			,phylclass = '#phylclass#'
		<cfelse>
			,phylclass = null			
		</cfif>
		<cfif len(#phylorder#) gt 0>
			,phylorder = '#phylorder#'
		<cfelse>
			,phylorder = null			
		</cfif>
		<cfif len(#suborder#) gt 0>
			,suborder = '#suborder#'
		<cfelse>
			,suborder = null			
		</cfif>
		<cfif len(#family#) gt 0>
			,family = '#family#'
		<cfelse>
			,family = null			
		</cfif>
		<cfif len(#subfamily#) gt 0>
			,subfamily = '#subfamily#'
		<cfelse>
			,subfamily = null			
		</cfif>
		<cfif len(#genus#) gt 0>
			,genus = '#genus#'
		<cfelse>
			,genus = null			
		</cfif>
		<cfif len(#subgenus#) gt 0>
			,subgenus = '#subgenus#'
		<cfelse>
			,subgenus = null			
		</cfif>
		<cfif len(#species#) gt 0>
			,species = '#species#'
		<cfelse>
			,species = null			
		</cfif>
		<cfif len(#subspecies#) gt 0>
			,subspecies = '#subspecies#'
		<cfelse>
			,subspecies = null			
		</cfif>		
		<cfif len(#phylum#) gt 0>
			,phylum = '#phylum#'
		<cfelse>
			,phylum = null			
		</cfif>		
		<cfif len(#taxon_remarks#) gt 0>
			,taxon_remarks = '#taxon_remarks#'
		<cfelse>
			,taxon_remarks = null			
		</cfif>
		<cfif len(#kingdom#) gt 0>
			,kingdom = '#kingdom#'
		<cfelse>
			,kingdom = null			
		</cfif>
		<cfif len(#nomenclatural_code#) gt 0>
			,nomenclatural_code = '#nomenclatural_code#'
		<cfelse>
			,nomenclatural_code = null			
		</cfif>
		<cfif len(#infraspecific_author#) gt 0>
			,infraspecific_author = '#infraspecific_author#'
		<cfelse>
			,infraspecific_author = null			
		</cfif>
		,taxon_status='#taxon_status#'	
	WHERE taxon_name_id=#taxon_name_id#
	</cfquery>
	</cftransaction>
	<cflocation url="Taxonomy.cfm?Action=edit&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->

<cfinclude template="includes/_footer.cfm">