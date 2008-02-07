<cfinclude template = "includes/_header.cfm">
<script type="text/javascript">
	function getTaxaResultsData (val){
		var ar = val.split(',');
		var startAt = ar[0];
		var goTo = ar[1];
		document.location='TaxonomyResults.cfm?startAt=' + startAt + "&goTo=" + goTo; 
	}
</script>

<!----
<link rel="stylesheet" href="/includes/css.css">
<script type="text/javascript" src="/includes/js.js">
		<!--[if IE]>
			<link rel="stylesheet" href="/includes/hack.css">
		<![endif]-->
		
		---->
<cfset title = "Taxonomy Results">
<!--- 
	newQuery is a variable that causes the query to fetch from the database 
	if 1 or from cache if 0 (as in next page browsing). We want it to be 1 if we 
	come in from anywhere other than next/previous buttons
--->

<!--- check for crap - do NOT allow single-quotes, etc.
--->
<cfset thisTableName = "TaxaResults_#cfid#_#cftoken#">	
<cfif not isdefined("startAt") or len(#startAt#) is 0>
<cfset stringOfStuffToClean = "">

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
				INFRASPECIFIC_RANK
			 from taxonomy, common_name
				WHERE taxonomy.taxon_name_id = common_name.taxon_name_id (+)">
		<cfif isdefined("common_name") AND len(#common_name#) gt 0>
			<CFSET SQL = "#SQL# AND upper(common_name) LIKE '%#ucase(common_name)#%'">
			<cfset stringOfStuffToClean = "#stringOfStuffToClean##common_name#">
		</cfif>
		<cfif isdefined("genus") AND len(#genus#) gt 0>
			<CFSET SQL = "#SQL# AND upper(genus) LIKE '%#ucase(genus)#%'">
		</cfif>
		<cfif isdefined("phylum") AND len(#phylum#) gt 0>
			<CFSET SQL = "#SQL# AND upper(phylum) LIKE '%#ucase(phylum)#%'">
		</cfif>
		<cfif isdefined("species") AND len(#species#) gt 0>
			<CFSET SQL = "#SQL# AND upper(species) LIKE '%#ucase(species)#%'">
		</cfif>
		<cfif isdefined("subspecies") AND len(#subspecies#) gt 0>
			<CFSET SQL = "#SQL# AND upper(subspecies) LIKE '%#ucase(subspecies)#%'">
		</cfif>
		<cfif isdefined("full_taxon_name") AND len(#full_taxon_name#) gt 0>
			<CFSET SQL = "#SQL# AND upper(full_taxon_name) LIKE '%#ucase(full_taxon_name)#%'">
			<cfset stringOfStuffToClean = "#stringOfStuffToClean##full_taxon_name#">
		</cfif>
		<cfif isdefined("phylclass") AND len(#phylclass#) gt 0>
			<CFSET SQL = "#SQL# AND upper(phylclass) LIKE '%#ucase(phylclass)#%'">
		</cfif>
		<cfif isdefined("phylorder") AND len(#phylorder#) gt 0>
			<CFSET SQL = "#SQL# AND upper(phylorder) LIKE '%#ucase(phylorder)#%'">
		</cfif>
		<cfif isdefined("suborder") AND len(#suborder#) gt 0>
			<CFSET SQL = "#SQL# AND upper(suborder) LIKE '%#ucase(suborder)#%'">
		</cfif>
		<cfif isdefined("family") AND len(#family#) gt 0>
			<CFSET SQL = "#SQL# AND upper(family) LIKE '%#ucase(family)#%'">
		</cfif>
		<cfif isdefined("subfamily") AND len(#subfamily#) gt 0>
			<CFSET SQL = "#SQL# AND upper(subfamily) LIKE '%#ucase(subfamily)#%'">
		</cfif>
		<cfif isdefined("tribe") AND len(#tribe#) gt 0>
			<CFSET SQL = "#SQL# AND upper(tribe) LIKE '%#ucase(tribe)#%'">
		</cfif>
		<cfif isdefined("subgenus") AND len(#subgenus#) gt 0>
			<CFSET SQL = "#SQL# AND upper(subgenus) LIKE '%#ucase(subgenus)#%'">
		</cfif>
		<cfif isdefined("author_text") AND len(#author_text#) gt 0>
			<CFSET SQL = "#SQL# AND upper(author_text) LIKE '%#ucase(author_text)#%'">
		</cfif>
		<cfif isdefined("scientific_name") AND len(#scientific_name#) gt 0>
			<CFSET SQL = "#SQL# AND upper(scientific_name) LIKE '%#ucase(scientific_name)#%'">
			<cfset stringOfStuffToClean = "#stringOfStuffToClean##scientific_name#">
		</cfif>
		<cfif isdefined("VALID_CATALOG_TERM_FG") AND len(#VALID_CATALOG_TERM_FG#) gt 0>
			<CFSET SQL = "#SQL# AND VALID_CATALOG_TERM_FG = #VALID_CATALOG_TERM_FG#">
		</cfif>
		<cfif isdefined("we_have_some") AND #we_have_some# is 1>
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
				AUTHOR_TEXT,
				TRIBE,
				INFRASPECIFIC_RANK">
		<cfif #stringOfStuffToClean# contains "'">
			You searched for an illegal character.
			<cfabort>
		</cfif>

<CFSET SQL = "create table #thisTableName# as #SQL#">
<cftry>
	<cfquery name="die" datasource="#Application.web_user#">
		drop table #thisTableName#
	</cfquery>
	<cfcatch><!--- not there, so what? ---></cfcatch>
</cftry>
	<cftry>
		<cfquery name="makeTable" datasource="#Application.web_user#">
			#preservesinglequotes(SQL)#
		</cfquery>
	<cfcatch>
		<cfset sql=cfcatch.sql>
		<cfset message=cfcatch.message>
		<cfset queryError=cfcatch.queryError>
		<cf_queryError>
	</cfcatch>
</cftry>
<cfset startAt=1>
</cfif>
<cfquery name="summary" datasource="#Application.web_user#">
	select count(*) cnt from #thisTableName#
</cfquery>
<cfif not isdefined("goTo") or len(#goTo#) is 0 or #goTo# lte #startAt#>
	<cfset goTo = StartAt + client.displayrows>
</cfif>
<cfquery name="getTaxa" datasource="#Application.web_user#">
	Select * from (
				Select a.*, rownum rnum From (
					select * from #thisTableName# order by scientific_name
				) a where rownum <= #goTo#
			) where rnum >= #startAt#
</cfquery>

<CFOUTPUT>
<H4>
Found #summary.cnt# records.
<cfset numPages= ceiling(summary.cnt/client.displayrows)>
		<cfset loopTo=numPages-2>
		<label for="page_record">Records...</label>
		<select name="page_record" id="page_record" size="1" onchange="getTaxaResultsData(this.value);">
			<cfloop from="0" to="#loopTo#" index="i">
				<cfset bDispVal = (i * client.displayrows + 1)>
				<cfset eDispval = (i + 1) * client.displayrows>
				<option value="#bDispVal#,#client.displayrows#"
					<cfif #bDispVal# is #startAt#> selected="selected" </cfif>
							>#bDispVal# - #eDispval#</option>
			</cfloop>
			<!--- last set of records --->
			<cfset bDispVal = ((loopTo + 1) * client.displayrows )+ 1>
			<cfset eDispval = summary.cnt>
			<option value="#bDispVal#,#client.displayrows#"
					<cfif #bDispVal# is #startAt#> selected="selected" </cfif>>#bDispVal# - #eDispval#</option>
			<!--- all records --->
			<option 
					<cfif #startAt# is 1 and #goTo# is #summary.cnt#> selected="selected"</cfif>
						value="1,#summary.cnt#">1 - #summary.cnt#</option>
		</select>
		<a href="SpecimenResultsDownload.cfm?tableName=#thisTableName#">Download</a>
</H4>
</CFOUTPUT>

<table border="1">
	<tr>
  		<td>&nbsp;</td>
		<td><strong>Common Name(s)</strong></td>
		<td><strong>Phylum</strong></td>
		<td><strong>Class</strong></td>
        <td><strong>Order</strong></td>
        <td><strong>Suborder</strong></td>
        <td><strong>Family</strong></td>
	    <td><strong>Subfamily</strong></td>
        <td><strong>Tribe</strong></td>
        <td><strong>Genus</strong></td>
        <td><strong>Subgenus</strong></td>
        <td><strong>Species</strong></td>
        <td><strong>Subspecies</strong></td>
    </tr>
  <cfset i=1>
  <cfoutput query="getTaxa">
	<cfquery name="cName" datasource="#Application.web_user#">
		select common_name from common_name where
		taxon_name_id = #taxon_name_id#
	</cfquery>
	<cfset thisSearch = "%22#scientific_name#%22">
	<cfloop query="cName">
		<cfset thisSearch = "#thisSearch# OR %22#cName.common_name#%22">
	</cfloop>
	<cfset thisSearch = replace(thisSearch,"'","\'","all")>
  	<tr>
		<td nowrap>

			<div class="submenu">
				<ul>
					<li><h2 
							<cfif #VALID_CATALOG_TERM_FG# is 0> style="color:red;" </cfif>
							onclick="document.location='TaxonomyDetails.cfm?&taxon_name_id=#taxon_name_id#';">
								<em>#scientific_name#</em>&nbsp;#author_text#
							</h2>
						<ul>
							<cfif isdefined("client.roles") and listfindnocase(client.roles,"manage_taxonomy")>
								<li>
									<a href="Taxonomy.cfm?Action=edit&taxon_name_id=#taxon_name_id#"
										target="#client.target#">Edit</a>					
								</li>
							</cfif>
							<li>
								<a href="TaxonomyDetails.cfm?&taxon_name_id=#taxon_name_id#"
									target="#client.target#">Details</a>
							</li>
							<li>
								<a href="SpecimenResults.cfm?&taxon_name_id=#taxon_name_id#"
									target="#client.target#">Specimens</a>
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
  <cfset i=#i#+1>
  </cfoutput>
</table>


	<cf_getSearchTerms>
	<cfset log.query_string=returnURL>
	<cfset log.reported_count = #getTaxa.RecordCount#>
	<cfinclude template="/includes/activityLog.cfm">
 
<cfinclude template = "includes/_footer.cfm">
