<cfinclude template="includes/_header.cfm">
<style>
	.reqdToSearchDiv {
		border:1px solid green;
		display: inline-block;
		padding:1em;
		margin:1em;
	}
	.taxonomyResultsDiv {
		padding-left:3em;
	}
	.warningOverflow {
		border:2px solid red;
		display: inline-block;
		padding:1em;
		margin:1em;
	}
	.highlight {
		border:2px solid red;
		padding:1em;
		margin:1em;
	}
	#specTaxMap{
		width:60%;
		margin-left:10em;
	}
</style>

<!--------- global form defaults -------------->
<cfif not isdefined("taxon_name")>
	<cfset taxon_name="">
</cfif>
<cfif not isdefined("taxon_term")>
	<cfset taxon_term="">
</cfif>
<cfif not isdefined("term_type")>
	<cfset term_type="">
</cfif>
<cfif not isdefined("source")>
	<cfset source="">
</cfif>
<cfif not isdefined("common_name")>
	<cfset common_name="">
</cfif>
<!--------------------- end init -------------------------->
<cfoutput>

<cfset title="Search Taxonomy">

			<!--- search form gets half-width --->
			<h3>Search Taxonomy (default is case-insensitive STARTS WITH)</h3>
			<form ACTION="#Application.mobileURL#/taxonomy.cfm" METHOD="get" name="taxa" id="taxa">
				<label for="taxon_name">Taxon Name</label>
				<input type="text" name="taxon_name" id="taxon_name" value="#taxon_name#" >

				<label for="taxon_term">Taxon Term</label>
				<input type="text" name="taxon_term" id="taxon_term" value="#taxon_term#" >

				<label for="term_type">Term Type</label>
				<input type="text" name="term_type" id="term_type" value="#term_type#" >

				<label for="source">Source</label>
				<input type="text" name="source" id="source" value="#source#" >
				<label for="common_name">Common Name</label>
				<input type="text" name="common_name" id="common_name" value="#common_name#" >

				<br>
				<input value="Search" type="submit">&nbsp;&nbsp;&nbsp;
				<input type="button" onclick="resetForm()" value="Clear Form">
			</form>


<!----- always display search ---------->

<hr>
<!---------- search results ------------>
<cfif len(taxon_name) gt 0 or len(taxon_term) gt 0 or len(common_name) gt 0 or len(source) gt 0 or len(term_type) gt 0>
	<h3>Taxonomy Search Results</h3>

	<cfset tabls="taxon_name">
	<cfset tbljoin="">
	<cfset whr="">

	Search terms:
	<ul>
		<cfif len(taxon_name) gt 0>
			<cfif left(taxon_name,1) is "=">
				<cfset whr=whr & " and upper(scientific_name) = '#escapeQuotes(ucase(right(taxon_name,len(taxon_name)-1)))#'">
				<li>scientific_name IS #right(taxon_name,len(taxon_name)-1)#</li>
			<cfelseif left(taxon_name,1) is "%">
				<cfset whr=whr & " and upper(scientific_name) like '%#ucase(escapeQuotes(right(taxon_name,len(taxon_name)-1)))#%'">
				<li>scientific_name CONTAINS #taxon_term#</li>
			<cfelse>
				<cfset whr=whr & " and upper(scientific_name) like '#ucase(escapeQuotes(taxon_name))#%'">
				<li>scientific_name STARTS WITH #taxon_name#</li>
			</cfif>
		</cfif>
		<cfif len(taxon_term) gt 0>
			<cfif tabls does not contain "taxon_term">
				<cfset tabls=tabls & " , taxon_term">
				<cfset tbljoin=tbljoin & " AND taxon_name.taxon_name_id=taxon_term.taxon_name_id">
			</cfif>

			<cfif  left(taxon_term,1) is "=">
				<cfset whr=whr & " and upper(term) = '#escapeQuotes(ucase(right(taxon_term,len(taxon_term)-1)))#'">
				<li>taxa term IS #right(taxon_term,len(taxon_term)-1)#</li>
			<cfelseif left(taxon_term,1) is "%">
				<cfset whr=whr & " and upper(term) like '%#escapeQuotes(ucase(right(taxon_term,len(taxon_term)-1)))#%'">
				<li>taxa term CONTAINS #taxon_term#</li>
			<cfelse>
				<cfset whr=whr & " and upper(term) like '#escapeQuotes(ucase(taxon_term))#%'">
				<li>taxa term STARTS WITH #taxon_term#</li>
			</cfif>
		</cfif>
		<cfif len(term_type) gt 0>
			<cfif tabls does not contain "taxon_term">
				<cfset tabls=tabls & " , taxon_term">
				<cfset tbljoin=tbljoin & " AND taxon_name.taxon_name_id=taxon_term.taxon_name_id">
			</cfif>

			<cfif  left(term_type,1) is "=">
				<cfset whr=whr & " and upper(term_type) = '#escapeQuotes(ucase(right(term_type,len(term_type)-1)))#'">
				<li>term type IS #right(term_type,len(term_type)-1)#</li>
			<cfelseif term_type is "NULL">
				<cfset whr=whr & " and term_type is null">
				<li>term type IS NULL</li>
			<cfelseif left(term_type,1) is "%">
				<cfset whr=whr & " and upper(term_type) like '%#escapeQuotes(ucase(right(term_type,len(term_type)-1)))#%'">
				<li>term type CONTAINS #term_type#</li>
			<cfelse>
				<cfset whr=whr & " and upper(term_type) like '#escapeQuotes(ucase(term_type))#%'">
				<li>term type STARTS WITH #term_type#</li>
			</cfif>
		</cfif>
		<cfif len(source) gt 0>
			<cfif tabls does not contain "taxon_term">
				<cfset tabls=tabls & " , taxon_term">
				<cfset tbljoin=tbljoin & " AND taxon_name.taxon_name_id=taxon_term.taxon_name_id">
			</cfif>
			<cfset whr=whr & " and upper(source) like '#escapeQuotes(ucase(source))#%'">
			<li>source STARTS WITH #source#</li>
		</cfif>
		<cfif len(common_name) gt 0>
			<cfif tabls does not contain "common_name">
				<cfset tabls=tabls & " , common_name">
				<cfset tbljoin=tbljoin & " AND taxon_name.taxon_name_id=common_name.taxon_name_id">
			</cfif>

			<cfif  left(common_name,1) is "=">
				<cfset whr=whr & " and upper(common_name) = '#escapeQuotes(ucase(right(common_name,len(common_name)-1)))#' ">
				<li>common name IS #right(common_name,len(common_name)-1)#</li>
			<cfelseif left(common_name,1) is "%">
				<cfset whr=whr & " and upper(common_name) LIKE '%#escapeQuotes(ucase(right(common_name,len(common_name)-1)))#%' ">
				<li>common name CONTAINS #common_name#</li>
			<cfelse>
				<cfset whr=whr & " and upper(common_name) like '#escapeQuotes(ucase(common_name))#%' ">
				<li>common name STARTS WITH #common_name#</li>
			</cfif>


		</cfif>


		<cfset sql="select scientific_name from (select scientific_name from #tabls# where 1=1 #tbljoin# #whr# ">

		<cfset sql=sql & "
		group by scientific_name
		order by scientific_name)
		where rownum<1001">

	</ul>
	<cfif isdefined("debug") and debug is true>
		<cfdump var=#sql#>
	</cfif>
	<cfquery name="d" datasource="uam_god">
		#preservesinglequotes(sql)#
	</cfquery>
	<cfset title="Taxonomy Search Results">
	#d.recordcount# results - click results for more information.
	<cfif d.recordcount is 1000>
		<span class="warningOverflow">This form will return a maximum of 1,000 records.</span>
	</cfif>
	<div class="taxonomyResultsDiv">
		<cfloop query="d">
			<br><a href="#Application.mobileURL#/name/#scientific_name#">#scientific_name#</a>
		</cfloop>
	</div>
</cfif>

<!--------------------- taxonomy details --------------------->
<cfif isdefined("name") and len(name) gt 0>
	<a id="taxondetail" name="taxondetail"></a>
	<style>
		.classificationDiv {
			border:2px solid black;
			display:block;
			margin:2em;
			padding:2em;
			background-color:##F8F8F8;
		}
		.sourceDiv {
			border:2px solid black;
			display:block;
			margin:2em;
			padding:2em;
		}
	</style>
	<cfquery name="d" datasource="uam_god">
		select
			taxon_name_id,
			scientific_name,
			term,
			term_type,
			source,
			classification_id,
			gn_score,
			position_in_classification,
			lastdate,
			match_type,
			regexp_replace(source,'[^A-Za-z]') anchor
		from
			v_mv_sciname_term
		where
			upper(scientific_name)='#ucase(name)#'
	</cfquery>
	<cfif d.recordcount is 0>
		No data for #name# is available. Please search again, or use the Contact link below to tell us what's missing.
		<cfinclude template="includes/_footer.cfm">
		<cfheader statuscode="404" statustext="Not found">
		<cfabort>
	</cfif>

	<cfquery name="scientific_name" dbtype="query">
		select scientific_name from d group by scientific_name
	</cfquery>
	<cfquery name="taxon_name_id" dbtype="query">
		select taxon_name_id from d group by taxon_name_id
	</cfquery>

	<cfset title="Taxonomy Details: #name#">
	<h3>Taxonomy Details for <i>#name#</i></h3>

	<cfquery name="related" datasource="uam_god">
		select
			TAXON_RELATIONSHIP,
			RELATION_AUTHORITY,
			scientific_name
		from
			taxon_relations,
			taxon_name
		where
			taxon_relations.related_taxon_name_id=taxon_name.taxon_name_id and
			taxon_relations.taxon_name_id=#taxon_name_id.taxon_name_id#
	</cfquery>
	<cfif related.recordcount gte 1>
		<p>
			<h4>Related Taxa (from)</h4>
			<ul>
				<cfloop query="related">
					<li>
						#TAXON_RELATIONSHIP# <a href='#Application.mobileURL#/name/#scientific_name#'>#scientific_name#</a>
						<cfif len(RELATION_AUTHORITY) gt 0>(Authority: #RELATION_AUTHORITY#)</cfif>
					</li>
				</cfloop>
			</ul>
		</p>
	</cfif>
	<cfquery name="revrelated" datasource="uam_god">
		select
			TAXON_RELATIONSHIP,
			RELATION_AUTHORITY,
			scientific_name
		from
			taxon_relations,
			taxon_name
		where
			taxon_relations.taxon_name_id=taxon_name.taxon_name_id and
			taxon_relations.related_taxon_name_id=#taxon_name_id.taxon_name_id#
	</cfquery>
	<cfif revrelated.recordcount gte 1>
		<p>
			<h4>Related Taxa (to)</h4>
			<ul>
				<cfloop query="revrelated">
					<li>
						#TAXON_RELATIONSHIP# <a href='#Application.mobileURL#/name/#scientific_name#'>#scientific_name#</a>
						<cfif len(RELATION_AUTHORITY) gt 0>( Authority: #RELATION_AUTHORITY#)</cfif>
					</li>
				</cfloop>
			</ul>
		</p>
	</cfif>
	<cfquery name="common_name" datasource="uam_god">
		select
			common_name
		from
			common_name
		where
			taxon_name_id=#taxon_name_id.taxon_name_id#
	</cfquery>
	<cfif common_name.recordcount gte 1>
		<p>
			<h4>Common Name(s)</h4>
			<ul>
				<cfloop query="common_name">
					<li>
						#common_name#
					</li>
				</cfloop>
			</ul>
		</p>
	</cfif>
	<cfquery name="tax_pub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			taxonomy_publication_id,
			short_citation,
			taxonomy_publication.publication_id
		from
			taxonomy_publication,
			publication
		where
			taxonomy_publication.publication_id=publication.publication_id and
			taxonomy_publication.taxon_name_id=#taxon_name_id.taxon_name_id#
	</cfquery>
	<cfif tax_pub.recordcount gt 0>
		<div>
			Related Publications:
			<ul>
				<cfloop query="tax_pub">
					<li>
						<a href="/SpecimenUsage.cfm?publication_id=#publication_id#">#short_citation#</a>
					</li>
				</cfloop>
			</ul>
	    </div>
	</cfif>
	<cfquery name="sidas" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) c from identification_taxonomy where taxon_name_id=#taxon_name_id.taxon_name_id#
	</cfquery>
	<cfif sidas.c gt 0>
		<p>
			Arctos Links:
			<ul>
				<li>
					<a href="#Application.mobileURL#/SpecimenResults.cfm?scientific_name=#scientific_name.scientific_name#">
						Specimens currently identified as #scientific_name.scientific_name#
					</a>
					<a href="#Application.mobileURL#/SpecimenResults.cfm?anyTaxId=#taxon_name_id.taxon_name_id#">
						[ include unaccepted IDs ]
					</a>
					<a href="#Application.mobileURL#/SpecimenResults.cfm?taxon_name_id=#taxon_name_id.taxon_name_id#">
						[ exact matches only ]
					</a>
					<a href="#Application.mobileURL#/SpecimenResults.cfm?scientific_name=#scientific_name.scientific_name#&media_type=any">
						[ with Media ]
					</a>
				</li>

			</cfif>
			 <cfquery name="citas" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select
					count(*) c
				from
					citation,
					identification_taxonomy
				where
					citation.identification_id=identification_taxonomy.identification_id and
					identification_taxonomy.taxon_name_id=#taxon_name_id.taxon_name_id#
			</cfquery>
			<cfif citas.c gt 0>
				<li>
					<a href="#Application.mobileURL#/SpecimenResults.cfm?cited_taxon_name_id=#taxon_name_id.taxon_name_id#">
						Specimens cited using #scientific_name.scientific_name#
					</a>
				</li>
			</cfif>
		</ul>
	</p>
	<a name="classifications"></a>
	<h4>Classifications</h4>

	<cfquery name="sources" dbtype="query">
		select
			source,
			anchor
		from
			d
		where
			classification_id is not null
		group by
			source,
			anchor
		order by
			source
	</cfquery>
	<ul>
		<cfloop query="sources">
			<li><a href="###anchor#">#source#</a></li>
		</cfloop>
	</ul>
	<cfloop query="sources">
		<div class="mobilesourceDiv">
			<cfif source is "Catalogue of Life">
				<cfset srcHTML='<a href="http://www.catalogueoflife.org/" target="_blank" class="external">#source#</a>'>
			<cfelseif source is "Arctos">
				<cfset srcHTML='<span class="likeLink" onclick="getDocs(''taxonomy'',''arctos_source'')">#source#</span>'>
			<cfelseif source is "GBIF Taxonomic Backbone">
				<cfset srcHTML='<a href="http://www.gbif.org/informatics/name-services/using-names-data/taxonomic-backbone/" target="_blank" class="external">#source#</a>'>
			<cfelseif source is "ITIS">
				<cfset srcHTML='<a href="http://www.itis.gov/" target="_blank" class="external">#source#</a>'>
			<cfelseif source is "Interim Register of Marine and Nonmarine Genera">
				<cfset srcHTML='<a href="http://www.obis.org.au/irmng/" target="_blank" class="external">#source#</a>'>
			<cfelseif source is "WoRMS">
				<cfset srcHTML='<a href="http://www.marinespecies.org/" target="_blank" class="external">#source#</a>'>
			<cfelseif source is "Wikispecies">
				<cfset srcHTML='<a href="http://species.wikimedia.org/wiki/Main_Page" target="_blank" class="external">#source#</a>'>
			<cfelseif source is "NCBI">
				<cfset srcHTML='<a href="http://www.ncbi.nlm.nih.gov/Taxonomy/taxonomyhome.html/" target="_blank" class="external">#source#</a>'>
			<cfelseif source is "Index Fungorum">
				<cfset srcHTML='<a href="http://www.indexfungorum.org/Names/Names.asp" target="_blank" class="external">#source#</a>'>
			<cfelseif source is "GRIN Taxonomy for Plants">
				<cfset srcHTML='<a href="http://www.ars-grin.gov/cgi-bin/npgs/html/index.pl" target="_blank" class="external">#source#</a>'>
			<cfelseif source is "Freebase">
				<cfset srcHTML='<a href="http://www.freebase.com/" target="_blank" class="external">#source#</a>'>
			<cfelseif source is "EOL">
				<cfset srcHTML='<a href="http://eol.org/" target="_blank" class="external">#source#</a>'>
			<cfelse>
				<cfset srcHTML=source>
			</cfif>
			Data from source <strong>#srcHTML#</strong>
			<a name="#anchor#" href="##classifications">[ Classifications ]</a>
			<a href="##taxondetail">[ Top ]</a>
			<cfquery name="source_classification" dbtype="query">
				select classification_id from d where source='#source#' group by classification_id
			</cfquery>
			<cfloop query="source_classification">
				<div class="classificationDiv">

					<cfquery name="notclass" dbtype="query">
						select
							term,
							term_type
						from
							d
						where
							position_in_classification is null and
							classification_id='#classification_id#'
						group by
							term,
							term_type
						order by
							term_type,
							term
					</cfquery>
					<cfquery name="qscore" dbtype="query">
						select gn_score,match_type from d where classification_id='#classification_id#' and gn_score is not null group by gn_score,match_type
					</cfquery>
					<cfquery name="thisone" dbtype="query">
						select
							term,
							term_type
						from
							d
						where
							position_in_classification is not null and
							classification_id='#classification_id#'
						group by
							term,
							term_type
						order by
							position_in_classification
					</cfquery>


					<cfquery name="lastdate" dbtype="query">
						select max(lastdate) as lastdate from d where classification_id='#classification_id#'
					</cfquery>
					<br><span style="font-size:small">last update: #lastdate.lastdate#</span>
					<cfif len(qscore.gn_score) gt 0>
						<br><span style="font-size:small"><a target="_blank" class="external" href="http://resolver.globalnames.org/api">globalnames score</a>=#qscore.gn_score#</span>
					<cfelse>
						<br><span style="font-size:small">globalnames score not available</span>
					</cfif>
					<cfif len(qscore.match_type) gt 0>
						<br><span style="font-size:small">globalnames match type=#qscore.match_type#</span>
					<cfelse>
						<br><span style="font-size:small">match type not available</span>
					</cfif>
					<p>
						<cfloop query="notclass">
							<br>#term_type#: #term#
						</cfloop>
					</p>
					<cfif thisone.recordcount gt 0>
						<p>Classification:
						<cfset indent=.2>
						<cfloop query="thisone">
							<div style="padding-left:#indent#em;">
								#term#
								<cfset tlink="#Application.mobileURL#/taxonomy.cfm?taxon_term==#term#">
								<cfif len(term_type) gt 0>
									(#term_type#)
									<cfset ttlink=tlink & "&term_type==#term_type#">
								<cfelse>
									<cfset ttlink=tlink & "&term_type=NULL">
								</cfif>
								<cfset srclnk=ttlink & "&source=#sources.source#">
								<!----
								<a href="#tlink#">[ more like this term ]</a>
								<a href="#ttlink#">[ including rank ]</a>
								<a href="#srclnk#">[ from this source ]</a>
								---->
							</div>
							<cfset indent=indent+.2>
						</cfloop>
					<cfelse>
						<p>no classification provided</p>
					</cfif>
				</div>
			</cfloop>
		</div>
	</cfloop>

	<p>
		External Links:
		<cfset srchName = URLEncodedFormat(scientific_name.scientific_name)>
		<ul>

			<!--- things that we've been asked to link to but which cannot deal with our data
			<li>
				<a class="external" target="_blank" href="http://amphibiaweb.org/cgi/amphib_query?where-genus=#one.genus#&where-species=#one.species#">
					AmphibiaWeb
				</a>
			</li>

			END things that we've been asked to link to but which cannot deal with our data ---->
			<li id="ispecies">
				<a class="external" target="_blank" href="http://ispecies.org/?q=#srchName#">iSpecies</a>
			</li>
			<li>
				<a class="external" target="_blank" href="http://wikipedia.org/wiki/#srchName#">
					Wikipedia
				</a>
			</li>
			<li>
				<a class="external" target="_blank" href="http://animaldiversity.ummz.umich.edu/site/search?SearchableText=#srchName#">
					Animal Diversity Web
				</a>
			</li>

			<cfset thisSearch = "%22#scientific_name.scientific_name#%22">
			<cfloop query="common_name">
				<cfset thisSearch = "#thisSearch# OR %22#common_name#%22">
			</cfloop>


			<li>
				<a class="external" target="_blank" href="http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?name=#srchName#">
					NCBI
				</a>
			</li>

			<li>
				<a class="external" href="http://google.com/search?q=#thisSearch#" target="_blank">
					Google
				</a>
				<a class="external" href="http://images.google.com/images?q=#thisSearch#" target="_blank">
					Images
				</a>
			</li>
			<li>
				<a class="external" target="_blank" href="http://www.eol.org/search/?q=#srchName#">
					Encyclopedia of Life
				</a>
			</li>
			<li>
				<a class="external" target="_blank" href="http://www.ubio.org/browser/search.php?search_all=#srchName#">
					uBio
				</a>
			</li>
			<li>
				<a class="external" target="_blank" href="http://www.efloras.org/browse.aspx?name_str=#srchName#">Flora of North America</a>
			</li>
			<li>
				<a class="external" target="_blank" href="http://www.ipni.org/ipni/simplePlantNameSearch.do?find_wholeName=#srchName#">
					The International Plant Names Index
				</a>
			</li>
			<li>
				<a class="external" target="_blank" href="http://epic.kew.org/searchepic/summaryquery.do?scientificName=#srchName#&searchAll=true&categories=names&categories=bibl&categories=colln&categories=taxon&categories=flora&categories=misc">
					electronic plant information centre
				</a>
			</li>
			<li>
				<a class="external" target="_blank" href="http://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=Scientific_Name&search_value=#srchName#&search_kingdom=every&search_span=containing&categories=All&source=html&search_credRating=all">
					ITIS
				</a>
			</li>
			<li>
				<a class="external" target="_blank" href="http://www.catalogueoflife.org/col/search/all/key/#srchName#/match/1">
					Catalogue of Life
				</a>
			</li>
			<li>
				<a class="external" target="_blank" href="
					http://www.google.com/custom?q=#srchName#&sa=Go!&cof=S:http://www.unep-wcmc.org;AH:left;LH:56;L:http://www.unep-wcmc.org/wdpa/I/unepwcmcsml.gif;LW:100;AWFID:681b57e6eabf5be6;&domains=unep-wcmc.org&sitesearch=unep-wcmc.org">
					UNEP (CITES)
				</a>
			</li>
			<li id="wikispecies">
				<a class="external" target="_blank" href="http://species.wikimedia.org/wiki/#srchName#">
					WikiSpecies
				</a>
			</li>
			<li>
				<a class="external" target="_blank" href="http://www.biodiversitylibrary.org/name/#srchName#">
					Biodiversity Heritage Library
				</a>
			</li>
		</ul>
	</p>
</cfif>
</cfoutput>
<!---------------------------------------------------------------------------------------------------->
<cfinclude template="includes/_footer.cfm">