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
</style>
<script>
	$(function() {
		$( "#source" ).autocomplete({
			source: '/component/functions.cfc?method=ac_nc_source',
			width: 320,
			max: 50,
			autofill: false,
			multiple: false,
			scroll: true,
			scrollHeight: 300,
			matchContains: true,
			minChars: 1,
			selectFirst:false
		});
		$( "#term_type" ).autocomplete({
			source: '/component/functions.cfc?method=ac_alltaxterm_tt',
			width: 320,
			max: 50,
			autofill: false,
			multiple: false,
			scroll: true,
			scrollHeight: 300,
			matchContains: true,
			minChars: 1,
			selectFirst:false
		});
	});
	function requireTermOrName() {
		if ($( "#taxon_name" ).val().length==0 && $( "#taxon_term" ).val().length==0){
			$( "#srchFailure" ).show();
			$( "#taxon_name" ).addClass('redBorder');
			$( "#taxon_term" ).addClass('redBorder');
			return false;
		}
	}
	function resetForm() {
	    $("#taxa").find("input[type=text], textarea").val("");
	}
</script>
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
<!--------------------- end init -------------------------->
<cfoutput>
<cfif isdefined("taxon_name_id") and len(taxon_name_id) gt 0>
	<cfquery name="d" datasource="uam_god">
		select scientific_name from taxon_name where taxon_name_id=<cfqueryparam value = "#taxon_name_id#" CFSQLType = "CF_SQL_INTEGER"> 
	</cfquery>
	<cflocation url="/name/#d.scientific_name#" addtoken="false">
</cfif>
<cfset title="Search Taxonomy">
<table width="100%">
	<tr>
		<td width="50%" valign="top">
			<!--- search form gets half-width --->
			<h3>Search for Taxonomy</h3>
			<span id="srchFailure" class="warningOverflow" style="display:none;">You must provide at least one of Taxon Term or Taxon Name to search.</span>
			<form ACTION="/taxonomy.cfm" METHOD="post" name="taxa" id="taxa" onsubmit="return requireTermOrName()">
				<input type="hidden" name="action" value="search">
				<label for="taxon_name">Taxon Name</label>
				<input class="reqdClr" type="text" name="taxon_name" id="taxon_name" value="#taxon_name#">
				<span class="infoLink" onclick="var e=document.getElementById('taxon_name');e.value='='+e.value;">
					Prefix with = for exact match
				</span>
				<label for="taxon_term">Taxon Term (prefix with = [equal sign] for exact match)</label>
				<input class="reqdClr" type="text" name="taxon_term" id="taxon_term" value="#taxon_term#">
				<span class="infoLink" onclick="var e=document.getElementById('taxon_term');e.value='='+e.value;">
					Prefix with = for exact match
				</span>
				<label for="term_type">Term Type</label>
				<input type="text" name="term_type" id="term_type" value="#term_type#">
				<span class="infoLink" onclick="var e=document.getElementById('term_type');e.value='='+e.value;">
					Prefix with = for exact match
				</span>
				<span class="infoLink" onclick="var e=document.getElementById('term_type').value='NULL';">
					[ NULL ]
				</span>
				<label for="source">Source</label>
				<input type="text" name="source" id="source" value="#source#">
				<br>
				<input value="Search" type="submit">
				<br> <input type="button" onclick="resetForm()" value="clear form">
			</form>
			<cfif isdefined("session.roles") and listfindnocase(session.roles,"manage_taxonomy")>
				<br><a target="_blank" href="/editTaxonomy.cfm?action=newName">[ Create a new name ]</a>
			</cfif>
		</td>
		<td valign="top">
			<div style="margin-left:2em;">
				<!--- and help/about/etc. gets 1/2 ---->
				<h3>IMPORTANT ANNOUNCEMENT</h3>
	
				
				<P>
				Arctos taxonomy has changed.......
				<p>
				href=clickypop to real docs.....
				
				</p>
				
				<p>
					<ul>
						<li>
							<strong>Taxon Name</strong> is the "namestring" or "scientific name," the "data" that is used to form Identifications and the core
							of every Taxonomy record.
						</li>
						<li>
							<strong>Taxon Term</strong> is the data value of either a classification term ("Animalia") or or classification metadata (such
							as name authors).
						</li>
						<li>
							<strong>Term Type</strong> is the rank ("kingdom") for classification terms, in which role it may be NULL, and the label for 
							classification metadata ("author text").
						</li>
						<li>
							<strong>Source</strong> indicates the source of a classification (NOT a taxon name). Some classifications
							are <a href="/info/ctDocumentation.cfm?table=CTTAXONOMY_SOURCE">local</a>; most come from
							<a href="http://www.globalnames.org/" target="_blank" class="external">GlobalNames</a>.
						</li>
					</ul>	
				</p>
			</div>
		</td>
	</tr>
</table>

<!----- always display search ---------->

<hr>
<!---------- search results ------------>
<cfif len(taxon_name) gt 0 or len(taxon_term) gt 0>
	<h3>Taxonomy Search Results</h3>
	<cfset sql="select scientific_name from (select scientific_name from taxon_name,taxon_term where 
		taxon_name.taxon_name_id=taxon_term.taxon_name_id (+) ">
	Search terms:
	<ul>
		<cfif len(taxon_name) gt 0>
			<cfif left(taxon_name,1) is "=">
				<cfset sql=sql & " and upper(taxon_name.scientific_name) = '#ucase(right(taxon_name,len(taxon_name)-1))#'">
				<li>scientific_name IS #right(taxon_name,len(taxon_name)-1)#</li>
			<cfelse>
				<cfset sql=sql & " and upper(taxon_name.scientific_name) like '%#ucase(taxon_name)#%'">
				<li>scientific_name CONTAINS #taxon_name#</li>
			</cfif>
		</cfif>
		<cfif len(taxon_term) gt 0>
			<cfif  left(taxon_term,1) is "=">
				<cfset sql=sql & " and upper(term) = '#ucase(right(taxon_term,len(taxon_term)-1))#'">
				<li>taxa term IS #right(taxon_term,len(taxon_term)-1)#</li>
			<cfelse>
				<cfset sql=sql & " and upper(term) like '%#ucase(taxon_term)#%'">
				<li>taxa term CONTAINS #taxon_term#</li>
			</cfif>			  
		</cfif>
		<cfif len(term_type) gt 0>
			<cfif  left(term_type,1) is "=">
				<cfset sql=sql & " and upper(term_type) = '#ucase(right(term_type,len(term_type)-1))#'">
				<li>term type IS #right(term_type,len(term_type)-1)#</li>
			<cfelseif term_type is "NULL">
				<cfset sql=sql & " and term_type is null">
				<li>term type IS NULL</li>
			<cfelse>
				<cfset sql=sql & " and upper(term_type) like '%#ucase(term_type)#%'">
				<li>term type CONTAINS #term_type#</li>
			</cfif>			  
		</cfif>
		<cfif len(source) gt 0>
			<cfset sql=sql & " and upper(source) like '%#ucase(source)#%'">
			<li>source CONTAINS #source#</li>
		</cfif>
		<cfset sql=sql & "
		group by scientific_name
		order by scientific_name)
		where rownum<1001">
	</ul>
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
			<br><a href="/name/#scientific_name#">#scientific_name#</a>
		</cfloop>
	</div>
</cfif>

<!--------------------- taxonomy details --------------------->
<cfif isdefined("name") and len(name) gt 0>
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
	<cfquery name="cf_global_settings" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select
			google_client_id,
			google_private_key
		from cf_global_settings
	</cfquery>
	<cfquery name="cttaxonomy_source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select source from cttaxonomy_source order by source
	</cfquery>
	<cfhtmlhead text='<script src="http://maps.googleapis.com/maps/api/js?client=#cf_global_settings.google_client_id#&sensor=false" type="text/javascript"></script>'>
	<script>
		jQuery(document).ready(function(){
			//var elemsToLoad='specTaxMedia,taxRelatedNames,mapTax';
			var taxon_name_id=$("##taxon_name_id").val();

			var elemsToLoad='taxRelatedNames,mapTax';
			getMedia('taxon',taxon_name_id,'specTaxMedia','10','1');
			//var elemsToLoad='taxRelatedNames';
			var elemAry = elemsToLoad.split(",");
			for(var i=0; i<elemAry.length; i++){
				load(elemAry[i]);
			}
		});
		function load(name){
			var scientific_name=$("##scientific_name").val();
			var taxon_name_id=$("##taxon_name_id").val();
			var ptl="/includes/taxonomy/" + name + ".cfm?taxon_name_id=" + taxon_name_id + "&scientific_name=" + scientific_name;
			jQuery.get(ptl, function(data){
				 jQuery('##' + name).html(data);
			})
		}
	</script>
	
	<cfquery name="d" datasource="uam_god">
		select 
			taxon_name.taxon_name_id,
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
			taxon_name,
			taxon_term 
		where 
			taxon_name.taxon_name_id=taxon_term.taxon_name_id (+) and
			upper(scientific_name)='#ucase(name)#'
	</cfquery>	
	<cfif d.recordcount is 0>
		sorry, we don't see to have data for #name# yet.
		<!----
		You can <a href="taxonomydemo.cfm?action=createTerm&scientific_name=#name#">create #name#</a>
		---->
		<cfabort>
	</cfif>
	<cfquery name="scientific_name" dbtype="query">
		select scientific_name from d group by scientific_name
	</cfquery>
	<cfquery name="taxon_name_id" dbtype="query">
		select taxon_name_id from d group by taxon_name_id
	</cfquery>
	<span class="annotateSpace">
		<cfquery name="existingAnnotations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select count(*) cnt from annotations
			where taxon_name_id = #taxon_name_id.taxon_name_id#
		</cfquery>
		<a href="javascript: openAnnotation('taxon_name_id=#taxon_name_id.taxon_name_id#')">
			[Annotate]
		<cfif #existingAnnotations.cnt# gt 0>
			<br>(#existingAnnotations.cnt# existing)
		</cfif>
		</a>
    </span>
	<input type="hidden" id="scientific_name" value="#scientific_name.scientific_name#">
	<input type="hidden" id="taxon_name_id" value="#taxon_name_id.taxon_name_id#">
	<h3>Taxonomy Details for <i>#name#</i></h3>
	<cfset title="Taxonomy Details: #name#">
	<cfif isdefined("session.roles") and listfindnocase(session.roles,"manage_taxonomy")>
		<a href="/editTaxonomy.cfm?action=editnoclass&taxon_name_id=#taxon_name_id.taxon_name_id#">[ Edit Non-Classification Data ]</a>
	</cfif>	
	<div id="specTaxMedia"></div>
	<div id="mapTax" style="margin:2em;"></div>
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
						#TAXON_RELATIONSHIP# <a href='/name/#scientific_name#'>#scientific_name#</a>
						<cfif len(RELATION_AUTHORITY) gt 0>( Authority: #RELATION_AUTHORITY#)</cfif>
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
						#TAXON_RELATIONSHIP# <a href='/name/#scientific_name#'>#scientific_name#</a>
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
					<a href="/SpecimenResults.cfm?scientific_name=#scientific_name.scientific_name#">
						Specimens currently identified as #scientific_name.scientific_name#
					</a>
					<a href="/SpecimenResults.cfm?anyTaxId=#taxon_name_id.taxon_name_id#">
						[ include unaccepted IDs ]
					</a>
					<a href="/SpecimenResults.cfm?taxon_name_id=#taxon_name_id.taxon_name_id#">
						[ exact matches only ]
					</a>
					<a href="/SpecimenResults.cfm?scientific_name=#scientific_name.scientific_name#&media_type=any">
						[ with Media ]
					</a>
				</li>
				<li>
					<a href="/bnhmMaps/bnhmMapData.cfm?showRangeMaps=true&scientific_name=#scientific_name.scientific_name#" class="external" target="_blank">
						BerkeleyMapper + RangeMaps
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
					<a href="/SpecimenResults.cfm?cited_taxon_name_id=#taxon_name_id.taxon_name_id#">
						Specimens cited using #scientific_name.scientific_name#
					</a>
				</li>
			</cfif>
		</ul>
	</p>
	<a name="classifications"></a>
	<h4>Classifications</h4>
	<cfif isdefined("session.roles") and listfindnocase(session.roles,"manage_taxonomy")>
		<a target="_blank" href="/ScheduledTasks/globalnames_fetch.cfm?name=#name#">[ Refresh/pull GlobalNames ]</a>
		<a href="/editTaxonomy.cfm?action=forceDeleteNonLocal&taxon_name_id=#taxon_name_id.taxon_name_id#">[ Force-delete all non-local metadata ]</a>
		<a href="/editTaxonomy.cfm?action=newClassification&taxon_name_id=#taxon_name_id.taxon_name_id#">[ Create Classification ]</a>
	</cfif>
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
	<br>Jump to Source....
	<ul>
		<cfloop query="sources">
			<li><a href="###anchor#">#source#</a></li>
		</cfloop>
	</ul>
	<cfloop query="sources">
		<div class="sourceDiv">
			Data from source <strong>#source#</strong>
			<a name="#anchor#" href="##classifications">[ Jump to Classifications ]</a>
			<cfquery name="source_classification" dbtype="query">
				select classification_id from d where source='#source#' group by classification_id
			</cfquery>
			<cfloop query="source_classification">
				<div class="classificationDiv">
					<cfif isdefined("session.roles") and listfindnocase(session.roles,"manage_taxonomy")>
						<cfif listcontains(valuelist(cttaxonomy_source.source),sources.source)>
							<a href="/editTaxonomy.cfm?action=editClassification&name=#name#&classification_id=#classification_id#">[ Edit Classification ]</a> (ID: #classification_id#)
						<cfelse>
							[ Editing non-local sources disallowed ]
						</cfif>
					</cfif>
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
						<br><span style="font-size:small">globalnames score=#qscore.gn_score#</span>
					<cfelse>
						<br><span style="font-size:small">globalnames score not available</span>
					</cfif>
					<cfif len(qscore.match_type) gt 0>
						<br><span style="font-size:small">globalnames match type=#qscore.match_type#</span>
					<cfelse>
						<br><span style="font-size:small">match type not available</span>
					</cfif>
					<cfif thisone.recordcount gt 0>
						<p>Classification:
						<cfset indent=1>
						<cfloop query="thisone">
							<div style="padding-left:#indent#em;">
								#term#
								<cfset tlink="/taxonomy.cfm?taxon_term==#term#">
								<cfif len(term_type) gt 0>
									(#term_type#)
									<cfset ttlink=tlink & "&term_type==#term_type#">
								<cfelse>
									<cfset ttlink=tlink & "&term_type=NULL">
								</cfif>
								<cfset srclnk=ttlink & "&source=#sources.source#">
								<a class="infoLink" href="#tlink#">[ more like this term ]</a>
								<a class="infoLink" href="#ttlink#">[ including rank ]</a>
								<a class="infoLink" href="#srclnk#">[ from this source ]</a>
							</div>
							<cfset indent=indent+1>
						</cfloop>
					<cfelse>
						<p>no classification provided</p>
					</cfif>
					<p>
						<cfloop query="notclass">
							<br>#term_type#: #term#
						</cfloop>
					</p>
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