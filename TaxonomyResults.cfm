<cfinclude template = "includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<script type="text/javascript">
	function getTaxaResultsData (val){
		var ar = val.split(',');
		var startAt = ar[0];
		var goTo = ar[1];
		document.location='TaxonomyResults.cfm?startAt=' + startAt + "&goTo=" + goTo; 
	}
	jQuery(".browseLink").live('click', function(e){
		var bgDiv = document.createElement('div');
		bgDiv.id = 'bgDiv';
		bgDiv.className = 'bgDiv';
		bgDiv.setAttribute('onclick','closeBrowse()');
		document.body.appendChild(bgDiv);
		var type=this.type;
		var type=$(this).attr('type');
		var dval=$(this).attr('dval');
		var theDiv = document.createElement('div');
		theDiv.id = 'browseDiv';
		theDiv.className = 'sscustomBox';
		theDiv.style.position="absolute";
		ih='<span onclick="closeBrowse()" class="likeLink" style="position:absolute;top:0;right:0;color:red;">Close&nbsp;Window</span>';
		ih+='<p>Search&nbsp;for&nbsp;' + type + '&nbsp;=&nbsp;'
		ih+='<a href="/TaxonomyResults.cfm?' + type + '==' + encodeURIComponent(dval) + '">' + dval.replace(/ /g, "&nbsp;") + '</a></p>';
		theDiv.innerHTML=ih;
		document.body.appendChild(theDiv);
		viewport.init("#browseDiv");
		viewport.init("#bgDiv");
	});
	function closeBrowse() {
		if(document.getElementById('bgDiv')){
			jQuery('#bgDiv').remove();
		}
		if (document.getElementById('browseDiv')) {
			jQuery('#browseDiv').remove();
		}
	}
</script>
<cfset titleTerms="">
<cfif isdefined("session.displayrows") and isnumeric(session.displayrows) and session.displayrows gt 0>
	<cfset dr=session.displayrows>
<cfelse>
	<cfset dr=20>
</cfif>
<cfif not isdefined("startAt") or len(#startAt#) is 0>
<cfset stringOfStuffToClean = "">
		<cfset SQL = "select * from (SELECT 
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
				display_name,
				AUTHOR_TEXT,
				TRIBE,
				INFRASPECIFIC_RANK,
				kingdom,
				SUPERFAMILY,
				SUBCLASS,
				TAXON_REMARKS,
				NOMENCLATURAL_CODE,
				INFRASPECIFIC_AUTHOR
			 from taxonomy, common_name
				WHERE taxonomy.taxon_name_id = common_name.taxon_name_id (+)">
		<cfif isdefined("common_name") AND len(#common_name#) gt 0>
			<CFSET SQL = "#SQL# AND upper(common_name) LIKE '%#ucase(common_name)#%'">
			<cfset stringOfStuffToClean = "#stringOfStuffToClean##common_name#">
			<cfset titleTerms=listappend(titleTerms,'#common_name#')>
		</cfif>
		
		<cfif isdefined("source_authority") AND len(#source_authority#) gt 0>
			<CFSET SQL = "#SQL# AND source_authority = '#source_authority#'">
		</cfif>
		<cfif isdefined("genus") AND len(#genus#) gt 0>
			<cfif left(genus,1) is "=">
				<CFSET SQL = "#SQL# AND upper(genus) = '#ucase(right(genus,len(genus)-1))#'">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(genus) LIKE '%#ucase(genus)#%'">
			</cfif>
			<cfset titleTerms=listappend(titleTerms,'#genus#')>
		</cfif>
		<cfif isdefined("phylum") AND len(#phylum#) gt 0>
			<cfif left(phylum,1) is "=">
				<CFSET SQL = "#SQL# AND upper(phylum) = '#ucase(right(phylum,len(phylum)-1))#'">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(phylum) LIKE '%#ucase(phylum)#%'">
			</cfif>
			<cfset titleTerms=listappend(titleTerms,'#phylum#')>
		</cfif>
		<cfif isdefined("species") AND len(#species#) gt 0>
			<cfif left(species,1) is "=">
				<CFSET SQL = "#SQL# AND upper(species) = '#ucase(right(species,len(species)-1))#'">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(species) LIKE '%#ucase(species)#%'">
			</cfif>
			<cfset titleTerms=listappend(titleTerms,'#species#')>
		</cfif>
		<cfif isdefined("subspecies") AND len(#subspecies#) gt 0>
			<cfif left(subspecies,1) is "=">
				<CFSET SQL = "#SQL# AND upper(subspecies) = '#ucase(right(subspecies,len(subspecies)-1))#'">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(subspecies) LIKE '%#ucase(subspecies)#%'">
			</cfif>
			<cfset titleTerms=listappend(titleTerms,'#subspecies#')>
		</cfif>
		<cfif isdefined("full_taxon_name") AND len(#full_taxon_name#) gt 0>
			<cfif left(full_taxon_name,1) is "=">
				<CFSET SQL = "#SQL# AND upper(full_taxon_name) = '#ucase(right(full_taxon_name,len(full_taxon_name)-1))#'">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(full_taxon_name) LIKE '%#ucase(full_taxon_name)#%'">
			</cfif>
			<cfset stringOfStuffToClean = "#stringOfStuffToClean##full_taxon_name#">
			<cfset titleTerms=listappend(titleTerms,'#full_taxon_name#')>
		</cfif>
		<cfif isdefined("kingdom") AND len(#kingdom#) gt 0>
			<cfif left(kingdom,1) is "=">
				<CFSET SQL = "#SQL# AND upper(kingdom) = '#ucase(right(kingdom,len(kingdom)-1))#'">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(kingdom) LIKE '%#ucase(kingdom)#%'">
			</cfif>
			<cfset titleTerms=listappend(titleTerms,'#kingdom#')>
		</cfif>
		<cfif isdefined("phylclass") AND len(#phylclass#) gt 0>
			<cfif left(phylclass,1) is "=">
				<CFSET SQL = "#SQL# AND upper(phylclass) = '#ucase(right(phylclass,len(phylclass)-1))#'">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(phylclass) LIKE '%#ucase(phylclass)#%'">
			</cfif>
			<cfset titleTerms=listappend(titleTerms,'#phylclass#')>
		</cfif>
		<cfif isdefined("phylorder") AND len(#phylorder#) gt 0>
			<cfif left(phylorder,1) is "=">
				<CFSET SQL = "#SQL# AND upper(phylorder) = '#ucase(right(phylorder,len(phylorder)-1))#'">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(phylorder) LIKE '%#ucase(phylorder)#%'">
			</cfif>
			<cfset titleTerms=listappend(titleTerms,'#phylorder#')>
		</cfif>
		<cfif isdefined("suborder") AND len(#suborder#) gt 0>
			<cfif left(suborder,1) is "=">
				<CFSET SQL = "#SQL# AND upper(suborder) = '#ucase(right(suborder,len(suborder)-1))#'">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(suborder) LIKE '%#ucase(suborder)#%'">
			</cfif>
			<cfset titleTerms=listappend(titleTerms,'#suborder#')>
		</cfif>
		<cfif isdefined("family") AND len(#family#) gt 0>
			<cfif left(family,1) is "=">
				<CFSET SQL = "#SQL# AND upper(family) = '#ucase(right(family,len(family)-1))#'">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(family) LIKE '%#ucase(family)#%'">
			</cfif>
			<cfset titleTerms=listappend(titleTerms,'#family#')>
		</cfif>
		<cfif isdefined("subfamily") AND len(#subfamily#) gt 0>
			<cfif left(subfamily,1) is "=">
				<CFSET SQL = "#SQL# AND upper(subfamily) = '#ucase(right(subfamily,len(subfamily)-1))#'">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(subfamily) LIKE '%#ucase(subfamily)#%'">
			</cfif>
			<cfset titleTerms=listappend(titleTerms,'#subfamily#')>
		</cfif>
		<cfif isdefined("tribe") AND len(#tribe#) gt 0>
			<cfif left(tribe,1) is "=">
				<CFSET SQL = "#SQL# AND upper(tribe) = '#ucase(right(tribe,len(tribe)-1))#'">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(tribe) LIKE '%#ucase(tribe)#%'">
			</cfif>
			<cfset titleTerms=listappend(titleTerms,'#tribe#')>
		</cfif>
		<cfif isdefined("subgenus") AND len(#subgenus#) gt 0>
			<cfif left(subgenus,1) is "=">
				<CFSET SQL = "#SQL# AND upper(subgenus) = '#ucase(right(subgenus,len(subgenus)-1))#'">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(subgenus) LIKE '%#ucase(subgenus)#%'">
			</cfif>
			<cfset titleTerms=listappend(titleTerms,'#subgenus#')>
		</cfif>
		<cfif isdefined("author_text") AND len(#author_text#) gt 0>
			<cfif left(author_text,1) is "=">
				<CFSET SQL = "#SQL# AND upper(author_text) = '#ucase(right(author_text,len(author_text)-1))#'">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(author_text) LIKE '%#ucase(author_text)#%'">
			</cfif>
			<cfset titleTerms=listappend(titleTerms,'#author_text#')>
		</cfif>
		<cfif isdefined("scientific_name") AND len(#scientific_name#) gt 0>
			<cfif left(scientific_name,1) is "=">
				<CFSET SQL = "#SQL# AND upper(scientific_name) = '#ucase(right(scientific_name,len(scientific_name)-1))#'">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(scientific_name) LIKE '%#ucase(scientific_name)#%'">
			</cfif>
			<cfset stringOfStuffToClean = "#stringOfStuffToClean##scientific_name#">
			<cfset titleTerms=listappend(titleTerms,'#scientific_name#')>
		</cfif>
		<cfif isdefined("VALID_CATALOG_TERM_FG") AND len(#VALID_CATALOG_TERM_FG#) gt 0>
			<CFSET SQL = "#SQL# AND VALID_CATALOG_TERM_FG = #VALID_CATALOG_TERM_FG#">
		</cfif>
		<cfif isdefined("we_have_some") AND #we_have_some# is true>
			<CFSET SQL = "#SQL# AND taxonomy.taxon_name_id IN ( select taxon_name_id FROM identification_taxonomy )">
		</cfif>
		<CFSET SQL = "#SQL# group by
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
				display_name,
				AUTHOR_TEXT,
				TRIBE,
				INFRASPECIFIC_RANK,
				kingdom,
				SUPERFAMILY,
				SUBCLASS,
				TAXON_REMARKS,
				NOMENCLATURAL_CODE,
				INFRASPECIFIC_AUTHOR
					) where rownum<1001">
		<cfif #stringOfStuffToClean# contains "'">
			You searched for an illegal character.
			<cfabort>
		</cfif>
<cfset checkSql(SQL)>
<cfset title = "Taxonomy Results: " & titleTerms>
<CFSET SQL = "create table #session.TaxSrchTab# as #SQL#">
<cftry>
	<cfquery name="die" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		drop table #session.TaxSrchTab#
	</cfquery>
	<cfcatch><!--- not there, so what? ---></cfcatch>
</cftry>
	<cfquery name="makeTable" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(SQL)#
	</cfquery>
<cfset startAt=1>
</cfif>
<cfquery name="summary" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select count(*) cnt from #session.TaxSrchTab#
</cfquery>
<cfif summary.cnt is 0>
	<div class="error">
		Nothing found. Please use your back button to try again.
		<cfabort>
	</div>
</cfif>
<cfif not isdefined("goTo") or len(#goTo#) is 0 or goTo lte startAt>
	<cfset goTo = StartAt + dr>
</cfif>
<cfquery name="getTaxa" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	Select * from (
				Select a.*, rownum rnum From (
					select * from #session.TaxSrchTab# order by scientific_name
				) a where rownum <= #goTo#
			) where rnum >= #startAt#
</cfquery>

<CFOUTPUT>
<H4>
Found #summary.cnt# records. 
<cfif summary.cnt is 1000>
	<div style="color:red;">
		Note: This form will not return >1000 records; you may need to narrow your search to return all matches.
	</div>
</cfif>
<cfset numPages= ceiling(summary.cnt/dr)>
		<cfset loopTo=numPages-2>
		<label for="page_record">Records...</label>
		<select name="page_record" id="page_record" size="1" onchange="getTaxaResultsData(this.value);">
			<cfloop from="0" to="#loopTo#" index="i">
				<cfset bDispVal = (i * dr + 1)>
				<cfset eDispval = (i + 1) * dr>
				<option value="#bDispVal#,#dr#"
					<cfif #bDispVal# is #startAt#> selected="selected" </cfif>
							>#bDispVal# - #eDispval#</option>
			</cfloop>
			<!--- last set of records --->
			<cfset bDispVal = ((loopTo + 1) * dr )+ 1>
			<cfset eDispval = summary.cnt>
			<option value="#bDispVal#,#dr#"
					<cfif #bDispVal# is #startAt#> selected="selected" </cfif>>#bDispVal# - #eDispval#</option>
			<!--- all records --->
			<option 
					<cfif #startAt# is 1 and #goTo# is #summary.cnt#> selected="selected"</cfif>
						value="1,#summary.cnt#">1 - #summary.cnt#</option>
		</select>
		<a href="SpecimenResultsDownload.cfm?tableName=#session.TaxSrchTab#">Download</a>
</H4>
</CFOUTPUT>

<table border="1" id="tre" class="sortable">
	<tr>
  		<th>Name</th>
		<th>Common&nbsp;Name(s)</th>
		<th>Nomenclatural&nbsp;Code</th>
		<th>Kingdom</th>
		<th>Phylum</th>
		<th>Class</th>
		<th>Subclass</th>
        <th>Order</th>
        <th>Suborder</th>
        <th>Superfamily</th>
        <th>Family</th>
	    <th>Subfamily</th>
        <th>Tribe</th>
        <th>Genus</th>
        <th>Subgenus</th>
        <th>Species</th>
        <th>Author</th>
		<th>Infraspecific&nbsp;Rank</th>
        <th>Subspecies</th>
        <th>Infraspecific&nbsp;Author</th>
        <th>Authority</th>
        <th>Remark</th>
    </tr>
  <cfset i=1>
  <cfoutput query="getTaxa">
	<cfquery name="cName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select common_name from common_name where
		taxon_name_id = #taxon_name_id#
	</cfquery>
	<cfset thisSearch = "%22#scientific_name#%22">
	<cfloop query="cName">
		<cfset thisSearch = "#thisSearch# OR %22#cName.common_name#%22">
	</cfloop>
	<cfset thisSearch = replace(thisSearch,"'","\'","all")>
    <tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
		<td nowrap>

			<div class="submenu">
				<ul>
					<li><h2 
							<cfif #VALID_CATALOG_TERM_FG# is 0> style="color:red;" </cfif>
							onclick="document.location='TaxonomyDetails.cfm?&taxon_name_id=#taxon_name_id#';">
								#display_name#
							</h2>
						<ul>
							<cfif isdefined("session.roles") and listfindnocase(session.roles,"manage_taxonomy")>
								<li>
									<a target="_blank" href="Taxonomy.cfm?Action=edit&taxon_name_id=#taxon_name_id#">Edit</a>					
								</li>
							</cfif>
							<li>
								<a href="TaxonomyDetails.cfm?&taxon_name_id=#taxon_name_id#">Details</a>
							</li>
							<li>
								<a href="SpecimenResults.cfm?&taxon_name_id=#taxon_name_id#">Specimens</a>
							</li>
							<li>
								<a href="http://images.google.com/images?q=#thisSearch#"
									target="_blank">Google Images&nbsp;<img src="/images/linkOut.gif" border="0" alt="external link"></a>
							</li>
							<li>
								<a href="http://en.wikipedia.org/wiki/Special:Search/#scientific_name#"
									target="_blank">Wikipedia&nbsp;<img src="/images/linkOut.gif" border="0" alt="external link"></a>
							</li>
				
						</ul>
					</li> 
				</ul>
			</div>
	<!---<ul
				style="list-style-type: none;
					padding:0;
					margin:0;"><li>list</li></ul>	--->
	</td>
    <td nowrap>
	<cfif #cName.recordcount# is 0>
		<font size="-1" color="##FF0000">None recorded</font>
	<cfelse>
		<cfloop query="cName">
			#common_name#<br>
		</cfloop>
	</cfif>
	</td>
	<td>#nomenclatural_code#&nbsp;</td>
	<td>#kingdom#&nbsp;</td>
	<td><span class="browseLink" type="phylum" dval="#phylum#">#phylum#</span></td>
	<td><span class="browseLink" type="Phylclass" dval="#Phylclass#">#Phylclass#</span></td>
	<td><span class="browseLink" type="subclass" dval="#subclass#">#subclass#</span></td>
    <td><span class="browseLink" type="Phylorder" dval="#Phylorder#">#Phylorder#</span></td>
    <td><span class="browseLink" type="Suborder" dval="#Suborder#">#Suborder#</span></td>
    <td><span class="browseLink" type="superfamily" dval="#superfamily#">#superfamily#</span></td>
    <td><span class="browseLink" type="family" dval="#family#">#family#</span></td>
	<td><span class="browseLink" type="Subfamily" dval="#Subfamily#">#Subfamily#</span></td>
    <td><span class="browseLink" type="Tribe" dval="#Tribe#">#Tribe#</span></td>
    <td><span class="browseLink" type="Genus" dval="#Genus#">#Genus#</span></td>
    <td><span class="browseLink" type="Subgenus" dval="#Subgenus#">#Subgenus#</span></td>
    <td><span class="browseLink" type="Species" dval="#Species#">#Species#</span></td>
    <td nowrap="nowrap"><span class="browseLink" type="author_text" dval="#author_text#">#author_text#</span></td>
    <td>#infraspecific_rank#&nbsp;</td>	
    <td><span class="browseLink" type="Subspecies" dval="#Subspecies#">#Subspecies#</span></td>
    <td nowrap="nowrap"><span class="browseLink" type="infraspecific_author" dval="#infraspecific_author#">#infraspecific_author#</span></td>
    <td nowrap="nowrap">#source_authority#&nbsp;</td>
    <td nowrap="nowrap">#taxon_remarks#&nbsp;</td>
  </tr>
  <cfset i=i+1>
  </cfoutput>
</table> 
<cfinclude template = "includes/_footer.cfm">