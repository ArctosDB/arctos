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
<style>
	.warning{border:5px solid red;}
</style>
<script>
	window.setInterval(chkTax, 1000);
	function chkTax(){
		if ($("#nomenclatural_code").val()=='unknown'){
			$("#nomenclatural_code").addClass('warning');
		} else {
			$("#nomenclatural_code").removeClass('warning');
		}
		if ($("#kingdom").val()==''){
			$("#kingdom").addClass('warning');
		} else {
			$("#kingdom").removeClass('warning');
		}
	}
</script>
<!------------------------------------------------>
<cfif action is "nothing">
	<cfheader statuscode="301" statustext="Moved permanently">
	<cfheader name="Location" value="TaxonomySearch.cfm">
	<cfabort>
</cfif>
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
				<span class="infoLink" onclick="getCtDoc('cttaxon_status');">Define</span>
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
			<td>
				<label for="phylum">Phylum</label>
				<input type="text" name="phylum" id="phylum" value="#gettaxa.phylum#" size="30">
			</td>
		</tr>
		<tr>
			<td>
				<label for="phylclass">Class</label>
				<input type="text" name="phylclass" id="phylclass" value="#gettaxa.phylclass#" size="30">
			</td>
			<td>
				<label for="subclass">SubClass</label>
				<input type="text" name="subclass" id="subclass" value="#gettaxa.subclass#" size="30">
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
				<label for="superfamily">Superfamily</label>
				<input type="text" name="superfamily" id="superfamily" value="#gettaxa.superfamily#" size="30">
			</td>
			<td>
				&nbsp;
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
	<cfquery name="tax_pub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			taxonomy_publication_id,
			formatted_publication,
			taxonomy_publication.publication_id
		from
			taxonomy_publication,
			formatted_publication		
		where
			format_style='long' and
			taxonomy_publication.publication_id=formatted_publication.publication_id and
			taxonomy_publication.taxon_name_id=#taxon_name_id#
	</cfquery>
	<cfset i = 1>
	<span class="likeLink" onClick="getDocs('taxonomy','taxonomy_publication');">Related Publications</span>
	
		<form name="newPub" method="post" action="Taxonomy.cfm">
			<input type="hidden" name="taxon_name_id" value="#getTaxa.taxon_name_id#">
			<input type="hidden" name="Action" value="newTaxonPub">
			<input type="hidden" name="new_publication_id" id="new_publication_id">
			<label for="new_pub">Pick Publication</label>
			<input type="text" id="newPub" onchange="getPublication(this.id,'new_publication_id',this.value,'newPub')" size="80">
			<input type="submit" value="Add Publication" class="insBtn">
		</form>
		<cfif tax_pub.recordcount gt 0>
			<ul>
		</cfif>
		<cfloop query="tax_pub">
			<li>
				#formatted_publication#
				<ul>
					<li>
						<a href="Taxonomy.cfm?action=removePub&taxonomy_publication_id=#taxonomy_publication_id#&taxon_name_id=#taxon_name_id#">[ remove ]</a>
					</li>
					<li>
						<a href="SpecimenUsage.cfm?publication_id=#publication_id#">[ details ]</a>
					</li>
				</ul>
			</li>
		</cfloop>
		<cfif tax_pub.recordcount gt 0>
			</ul>
		</cfif>
	</table>
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
<cfif action is "removePub">
	<cfquery name="removePub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		delete from taxonomy_publication where taxonomy_publication_id=#taxonomy_publication_id#
	</cfquery>
	<cflocation url="Taxonomy.cfm?Action=edit&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "newTaxonPub">
	<cfquery name="newTaxonPub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		INSERT INTO taxonomy_publication (taxon_name_id,publication_id)
		VALUES (#taxon_name_id#,#new_publication_id#)
	</cfquery>
	<cflocation url="Taxonomy.cfm?Action=edit&taxon_name_id=#taxon_name_id#" addtoken="false">
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
<cfif action is "deleteCommon">
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
<cfif action is "saveCommon">
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
<cfif action is "newTaxa">
<cfset title = "Add Taxonomy">
<cfoutput>
	<table border>
		<form name="taxa" method="post" action="Taxonomy.cfm">
			<input type="hidden" name="Action" value="saveNewTaxa">
			<tr>
				<td>
					<label for="source_authority"><span class="likeLink" onClick="getDocs('taxonomy','source_authority');">Source</span></label>
					<select name="source_authority" id="source_authority" size="1"  class="reqdClr">
		              <cfloop query="ctSourceAuth">
		                <option 
							<cfif form.source_authority is ctsourceauth.source_authority> selected="selected" </cfif>
								value="#ctSourceAuth.source_authority#">#ctSourceAuth.source_authority#</option>
		              </cfloop>
		            </select>
				</td>
				<td>
					<label for="valid_catalog_term_fg"><span class="likeLink" onClick="getDocs('taxonomy','valid_term');">Valid?</span></label>
					<select name="valid_catalog_term_fg" id="valid_catalog_term_fg" size="1" class="reqdClr">
		              <option <cfif valid_catalog_term_fg is "1"> selected="selected" </cfif> value="1">yes</option>
		              <option <cfif valid_catalog_term_fg is "0"> selected="selected" </cfif> value="0">no</option>
		            </select>
				</td>
	        </tr>
	        <tr>
				<td>
					<label for="nomenclatural_code"><span class="likeLink" onClick="getDocs('taxonomy','nomenclatural_code');">Nomenclatural Code</span></label>
					<select name="nomenclatural_code" id="nomenclatural_code" size="1" class="reqdClr">
		               <cfloop query="ctnomenclatural_code">
		                <option 
								<cfif #form.nomenclatural_code# is "#ctnomenclatural_code.nomenclatural_code#"> selected </cfif>value="#ctnomenclatural_code.nomenclatural_code#">#ctnomenclatural_code.nomenclatural_code#</option>
		              </cfloop>
		            </select>
				</td>
				<td>
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
								<cfif form.infraspecific_rank is ctinfrank.infraspecific_rank> selected="selected" </cfif>value="#ctInfRank.infraspecific_rank#">#ctInfRank.infraspecific_rank#</option>
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
					<label for="phylum">Phylum</label>
					<input type="text" name="phylum" id="phylum" value="#phylum#" size="30">
				</td>
			</tr>
			<tr>
				<td>
					<label for="phylclass">Class</label>
					<input type="text" name="phylclass" id="phylclass" value="#phylclass#" size="30">
				</td>
				<td>
					<label for="subclass">Sublass</label>
					<input type="text" name="subclass" id="subclass" value="#subclass#" size="30">
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
					<label for="superfamily">Superamily</label>
					<input type="text" name="superfamily" id="superfamily" value="#superfamily#" size="30">
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
 					<input type="submit" value="Create" class="insBtn">
				</td>
			</tr>
		</form>
	</table>
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "saveNewtaxa">
<cfoutput>
<cfquery name="nextID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select sq_taxon_name_id.nextval nextID from dual
</cfquery>
	<cfquery name="newTaxa" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		INSERT INTO taxonomy (
			taxon_name_id,
			valid_catalog_term_fg,
			source_authority,
			author_text,
			tribe,
			infraspecific_rank,
			phylclass,
			phylorder,
			suborder,
			family,
			subfamily,
			genus,
			subgenus,
			species,
			subspecies,
			taxon_remarks,
			phylum,
			infraspecific_author,
			kingdom,
			nomenclatural_code,
			taxon_status,
			subclass,
			superfamily
		) VALUES (
			#nextID.nextID#,
			#valid_catalog_term_fg#,
			'#source_authority#',
			'#escapeQuotes(author_text)#',
			'#tribe#',
			'#infraspecific_rank#',
			'#phylclass#',
			'#phylorder#',
			'#suborder#',
			'#family#',
			'#subfamily#',
			'#genus#',
			'#subgenus#',
			'#species#',
			'#subspecies#',
			'#escapeQuotes(taxon_remarks)#',
			'#phylum#',
			'#escapeQuotes(infraspecific_author)#',
			'#kingdom#',
			'#nomenclatural_code#',
			'#taxon_status#',
			'#subclass#',
			'#superfamily#'
		)
	</cfquery>
	<cflocation url="Taxonomy.cfm?Action=edit&taxon_name_id=#nextID.nextID#" addtoken="false">	
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "newTaxaRelation">
<cfoutput>
	<cfquery name="newReln" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		INSERT INTO taxon_relations (
			 TAXON_NAME_ID,
			 RELATED_TAXON_NAME_ID,
			 TAXON_RELATIONSHIP,
			 RELATION_AUTHORITY
		  )	VALUES (
			#TAXON_NAME_ID#,
			 #newRelatedId#,
			 '#TAXON_RELATIONSHIP#',
		 	'#RELATION_AUTHORITY#'
		)		 
	</cfquery>
	<cflocation url="Taxonomy.cfm?Action=edit&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif Action is "deleReln">
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
<cfif #Action# is "saveTaxaEdits">
<cfoutput>
<cftransaction>
	<cfquery name="edTaxa" datasource="user_login" username='#session.username#' password="#decrypt(session.epw,cfid)#">
	UPDATE taxonomy SET 
		valid_catalog_term_fg=#valid_catalog_term_fg#,
		source_authority = '#source_authority#',
		author_text='#escapeQuotes(author_text)#',
		tribe = '#tribe#',
		infraspecific_rank = '#infraspecific_rank#',
		phylclass = '#phylclass#',
		phylorder = '#phylorder#',
		suborder = '#suborder#',
		family = '#family#',
		subfamily = '#subfamily#',
		genus = '#genus#',
		subgenus = '#subgenus#',
		species = '#species#',
		subspecies = '#subspecies#',
		phylum = '#phylum#',
		taxon_remarks = '#escapeQuotes(taxon_remarks)#',
		kingdom = '#kingdom#',
		nomenclatural_code = '#nomenclatural_code#',
		infraspecific_author = '#escapeQuotes(infraspecific_author)#',
		taxon_status='#taxon_status#',
		subclass='#subclass#',
		superfamily='#superfamily#'
	WHERE taxon_name_id=#taxon_name_id#
	</cfquery>
	</cftransaction>
	<cflocation url="Taxonomy.cfm?Action=edit&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->

<cfinclude template="includes/_footer.cfm">