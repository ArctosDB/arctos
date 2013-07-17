<cfinclude template="includes/_header.cfm">
<!---- unified taxonomy (except editing) form ---------->

<!--------- global form defaults -------------->

<cfif not isdefined("taxon_name")>
	<cfset taxon_name="">
</cfif>
<cfif not isdefined("taxon_term")>
	<cfset taxon_term="">
</cfif>

<cfif not isdefined("src")>
	<cfset src="">
</cfif>
	
<!---- blurb about arctos taxonomy ------->
<h3>IMPORTANT ANNOUNCEMENT</h3>


<P>
Arctos taxonomy has changed.......
<p>
(Maybe write something here, AC??)

</p>


</P>
<hr>

<cfoutput>
<cfif isdefined("taxon_name_id") and len(taxon_name_id) gt 0>
	<cfquery name="d" datasource="uam_god">
		select scientific_name from taxon_name where taxon_name_id=<cfqueryparam value = "#taxon_name_id#" CFSQLType = "CF_SQL_INTEGER"> 
		</cfquery>
	<cflocation url="/name/#d.scientific_name#" addtoken="false">
</cfif>



<cfset title="Search Taxonomy">
<!----- always display search ---------->
<h3>Search for Taxonomy</h3>
<form ACTION="/taxonomy.cfm" METHOD="post" name="taxa">
	<input type="hidden" name="action" value="search">
	<label for="taxon_name">Taxon Name (prefix with = [equal sign] for exact match)</label>
	<input type="text" name="taxon_name" id="taxon_name">
	<label for="taxon_term">Taxon Term (prefix with = [equal sign] for exact match)</label>
	<input type="text" name="taxon_term" id="taxon_term">
	<br>
	<input value="Search" type="submit">
</form>
<cfif isdefined("session.roles") and listfindnocase(session.roles,"manage_taxonomy")>
	<br><a target="_blank" href="/editTaxonomy.cfm?action=newName">[ Create a new name ]</a>
</cfif>
<hr>
<!---------- search results ------------>
<cfif len(taxon_name) gt 0 or len(taxon_term) gt 0>
	<cfquery name="d" datasource="uam_god">
		select scientific_name from taxon_name,taxon_term where 
		taxon_name.taxon_name_id=taxon_term.taxon_name_id (+) and
		<cfif len(taxon_name) gt 0>
			upper(taxon_name.scientific_name)  
			<cfif  left(taxon_name,1) is "=">
				= '#ucase(taxon_name)#'
			<cfelse>
				like '%#ucase(taxon_name)#%'
			</cfif>
		</cfif>
		<cfif len(taxon_term) gt 0>
			and upper(taxon_term)
			<cfif  left(taxon_term,1) is "=">
				= '#ucase(taxon_name)#'
			<cfelse>
				like '%#ucase(taxon_term)#%'
			</cfif>			  
		</cfif>
		and rownum<1001
		group by scientific_name
		order by scientific_name
	</cfquery>
	<h3>Taxonomy Search Results</h3>
	<cfset title="Taxonomy Search Results">
	#d.recordcount# results:
	<cfloop query="d">
		<br><a href="/name/#scientific_name#">#scientific_name#</a>
	</cfloop>
</cfif>

<!--------------------- taxonomy details --------------------->
<cfif isdefined("name") and len(name) gt 0>
	<cfquery name="cf_global_settings" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select
			google_client_id,
			google_private_key
		from cf_global_settings
	</cfquery>
	<cfoutput>
		<cfhtmlhead text='<script src="http://maps.googleapis.com/maps/api/js?client=#cf_global_settings.google_client_id#&sensor=false" type="text/javascript"></script>'>
	</cfoutput>
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
	
	
	<!--- pipe-delimited list of things that users are allowed to edit --->
	<cfset editableSources="Arctos">
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
				<cfloop query="revrelated">				
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
	
	<h4>Classifications</h4>
	<cfif isdefined("session.roles") and listfindnocase(session.roles,"manage_taxonomy")>
		<a target="_blank" href="/ScheduledTasks/globalnames_fetch.cfm?name=#name#">[ Refresh/pull GlobalNames ]</a>
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

	<cfloop query="sources">
		<hr>
		<a name="#anchor#"></a>
		Data from source <strong>#source#</strong>
		<cfquery name="source_classification" dbtype="query">
			select classification_id from d where source='#source#'
		</cfquery>
		<cfloop query="source_classification">
			<a href="/editTaxonomy.cfm?action=editClassification&name=#name#&classification_id=#classification_id#">[ Edit Classification ]</a> (ID: #classification_id#)
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
						<cfif len(term_type) gt 0>
							(#term_type#)
						</cfif>
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
		</cfloop>
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