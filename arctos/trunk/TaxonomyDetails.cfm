<cfinclude template = "/includes/_header.cfm">
<cfif not isdefined("debug")>
	<cfset debug=false>
</cfif>

<cfif isdefined("scientific_name") and len(scientific_name) gt 0>
	<cfset checkSql(scientific_name)>
	<cfquery name="getTID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		SELECT taxon_name_id FROM taxonomy WHERE upper(scientific_name)	= '#ucase(scientific_name)#'
	</cfquery>
	<cfif debug>
		<cfdump var=#getTID#>
	</cfif>
	<cfif getTID.recordcount is 1>
		<cfset tnid=getTID.taxon_name_id>
	<cfelseif listlen(scientific_name," ") gt 1 and (listlast(scientific_name," ") is "sp." or listlast(scientific_name," ") is "ssp.")>
		<cfset s=listdeleteat(scientific_name,listlen(scientific_name," ")," ")>
		<cfset checkSql(s)>
		<cfquery name="getTID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT taxon_name_id FROM taxonomy WHERE upper(scientific_name)	= '#ucase(s)#'
		</cfquery>
		<cfif getTID.recordcount is 1>
			<cfheader statuscode="301" statustext="Moved permanently">
			<cfheader name="Location" value="/name/#s#">
			<cfabort>
		</cfif>
	<cfelseif listlen(scientific_name," ") is 3>
		<cfset checkSql(scientific_name)>
		<cfquery name="getTID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT
				scientific_name
			FROM
				taxonomy
			WHERE
				upper(genus) = '#ucase(listgetat(scientific_name,1," "))#' and
				upper(species) = '#ucase(listgetat(scientific_name,2," "))#' and
				upper(subspecies) = '#ucase(listgetat(scientific_name,3," "))#'
		</cfquery>
		<cfif getTID.recordcount is 1>
			<cfheader statuscode="301" statustext="Moved permanently">
			<cfheader name="Location" value="/name/#getTID.scientific_name#">
			<cfabort>
		</cfif>
	<cfelseif listlen(scientific_name," ") is 4>
		<cfset checkSql(scientific_name)>
		<cfquery name="getTID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT
				scientific_name
			FROM
				taxonomy
			WHERE
				upper(genus) = '#ucase(listgetat(scientific_name,1," "))#' and
				upper(species) = '#ucase(listgetat(scientific_name,2," "))#' and
				upper(subspecies) = '#ucase(listgetat(scientific_name,4," "))#'
		</cfquery>
		<cfif getTID.recordcount is 1>
			<cfheader statuscode="301" statustext="Moved permanently">
			<cfheader name="Location" value="/name/#getTID.scientific_name#">
			<cfabort>
		</cfif>
	</cfif>
</cfif>
<cfif isdefined("taxon_name_id")>
	<cfset checkSql(taxon_name_id)>
	<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select scientific_name from taxonomy where taxon_name_id=#taxon_name_id#
	</cfquery>
	<cfif len(c.scientific_name) gt 0>
		<cfheader statuscode="301" statustext="Moved permanently">
		<cfheader name="Location" value="/name/#c.scientific_name#">
		<cfabort>
	</cfif>
</cfif>
<cfif not isdefined("tnid") or not tnid gt 0>
	<cfheader statuscode="404" statustext="Not found">
	<div class="error">Not Found</div>
	<cfabort>
</cfif>
<cfset checkSql(tnid)>
<cfhtmlhead text='<script src="http://maps.google.com/maps?file=api&amp;v=2.x&amp;sensor=false&amp;key=#application.gmap_api_key#" type="text/javascript"></script>'>
<cfset taxaRanksList="Kingdom,Phylum,PHYLClass,Subclass,PHYLOrder,Suborder,Superfamily,Family,Subfamily,Genus,Subgenus,Species,Subspecies,Nomenclatural_Code,Taxon_Status">
<cfquery name="getDetails" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	SELECT
		taxonomy.TAXON_NAME_ID,
		taxonomy.VALID_CATALOG_TERM_FG,
		taxonomy.SOURCE_AUTHORITY,
		taxonomy.taxon_status,
		taxonomy.FULL_TAXON_NAME,
		<cfloop list="#taxaRanksList#" index="i">
			taxonomy.#i#,
		</cfloop>
		taxonomy.SCIENTIFIC_NAME,
		taxonomy.display_name,
		taxonomy.AUTHOR_TEXT,
		taxonomy.INFRASPECIFIC_AUTHOR,
		taxonomy.INFRASPECIFIC_RANK,
		common_name,
		taxon_relations.RELATED_TAXON_NAME_ID,
		taxon_relations.TAXON_RELATIONSHIP,
		taxon_relations.RELATION_AUTHORITY,
		related_taxa.SCIENTIFIC_NAME as related_name,
		related_taxa.display_name as related_display_name,
		imp_related_taxa.SCIENTIFIC_NAME imp_related_name,
		imp_related_taxa.display_name imp_related_display_name,
		imp_taxon_relations.taxon_name_id imp_RELATED_TAXON_NAME_ID,
		imp_taxon_relations.TAXON_RELATIONSHIP imp_TAXON_RELATIONSHIP,
		imp_taxon_relations.RELATION_AUTHORITY imp_RELATION_AUTHORITY
	 from
	 	taxonomy,
		common_name,
		taxon_relations,
		taxonomy related_taxa,
		taxon_relations imp_taxon_relations,
		taxonomy imp_related_taxa
	 WHERE
		taxonomy.taxon_name_id = common_name.taxon_name_id (+) AND
		taxonomy.taxon_name_id = taxon_relations.taxon_name_id (+) AND
		taxon_relations.related_taxon_name_id = related_taxa.taxon_name_id (+) AND
		taxonomy.taxon_name_id = imp_taxon_relations.related_taxon_name_id (+) AND
		imp_taxon_relations.taxon_name_id = imp_related_taxa.taxon_name_id (+) and
		taxonomy.taxon_name_id = #tnid#
		ORDER BY scientific_name, common_name, related_taxon_name_id
</cfquery>
<cfif debug>
		<cfdump var=#getDetails#>
	</cfif>
<cfquery name="common_name" dbtype="query">
	select
		common_name
	from
		getDetails
	where
		common_name is not null
	group by
		common_name
</cfquery>
<cfif debug>
		<cfdump var=#common_name#>
	</cfif>
<cfquery name="one" dbtype="query">
	select
		TAXON_NAME_ID,
		VALID_CATALOG_TERM_FG,
		SOURCE_AUTHORITY,
		FULL_TAXON_NAME,
		SCIENTIFIC_NAME,
		display_name,
		AUTHOR_TEXT,
		INFRASPECIFIC_RANK,
		<cfloop list="#taxaRanksList#" index="i">
			#i#,
		</cfloop>
		INFRASPECIFIC_AUTHOR
	from
		getDetails
	group by
		TAXON_NAME_ID,
		VALID_CATALOG_TERM_FG,
		SOURCE_AUTHORITY,
		FULL_TAXON_NAME,
		SCIENTIFIC_NAME,
		display_name,
		AUTHOR_TEXT,
		INFRASPECIFIC_RANK,
		<cfloop list="#taxaRanksList#" index="i">
			#i#,
		</cfloop>
		INFRASPECIFIC_AUTHOR
</cfquery>
<cfquery name="related" dbtype="query">
	select
		RELATED_TAXON_NAME_ID,
		TAXON_RELATIONSHIP,
		RELATION_AUTHORITY,
		related_name,
		related_display_name
	from
		getDetails
	where
		RELATED_TAXON_NAME_ID is not null
	group by
		RELATED_TAXON_NAME_ID,
		TAXON_RELATIONSHIP,
		RELATION_AUTHORITY,
		related_name,
		related_display_name
</cfquery>
<cfquery name="imp_related" dbtype="query">
	select
		imp_related_name,
		imp_RELATED_TAXON_NAME_ID,
		imp_TAXON_RELATIONSHIP,
		imp_RELATION_AUTHORITY,
		imp_related_display_name
	from
		getDetails
	where
		imp_RELATED_TAXON_NAME_ID is not null
	group by
		imp_related_name,
		imp_RELATED_TAXON_NAME_ID,
		imp_TAXON_RELATIONSHIP,
		imp_RELATION_AUTHORITY,
		imp_related_display_name
</cfquery>
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
		taxonomy_publication.taxon_name_id=#tnid#
</cfquery>

<cfif debug>
		<cfdump var=#tax_pub#>
	</cfif>
<cfoutput>
	<script>
		jQuery(document).ready(function(){
			//var elemsToLoad='specTaxMedia,taxRelatedNames,mapTax';
			var elemsToLoad='taxRelatedNames,mapTax';
			getMedia('taxon','#one.taxon_name_id#','specTaxMedia','10','1');
			//var elemsToLoad='taxRelatedNames';
			var elemAry = elemsToLoad.split(",");
			for(var i=0; i<elemAry.length; i++){
				load(elemAry[i]);
			}
		});
		function load(name){
			//var el=document.getElementById(name);
			var ptl="/includes/taxonomy/" + name + ".cfm?taxon_name_id=#one.taxon_name_id#&scientific_name=#one.scientific_name#";
			jQuery.get(ptl, function(data){
				 jQuery('##' + name).html(data);
			})
		}
	</script>
	<cfset title="#one.scientific_name#">
	<cfset metaDesc="Taxon Detail for #one.scientific_name#">
	<cfset thisSearch = "%22#one.scientific_name#%22">
	<cfloop query="common_name">
		<cfset thisSearch = "#thisSearch# OR %22#common_name#%22">
	</cfloop>
	<span class="annotateSpace">
		<cfif len(session.username) gt 0>
			<cfquery name="existingAnnotations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select count(*) cnt from annotations
				where taxon_name_id = #tnid#
			</cfquery>
			<a href="javascript: openAnnotation('taxon_name_id=#tnid#')">
				[Annotate]
			<cfif #existingAnnotations.cnt# gt 0>
				<br>(#existingAnnotations.cnt# existing)
			</cfif>
			</a>
		<cfelse>
			<a href="/login.cfm">Login or Create Account</a>
		</cfif>
    </span>

	<cfif debug>
		<cfdump var=#existingAnnotations#>
	</cfif>

	<div align="left">
		<cfif one.VALID_CATALOG_TERM_FG is 1>
	   		<font size="+1"	>
		    	<B>#one.display_name#</B>
			</font>
			<cfif len(one.AUTHOR_TEXT) gt 0>
				<cfset metaDesc=metaDesc & "; Author: #one.AUTHOR_TEXT#">
        	</cfif>
        <cfelseIF #one.VALID_CATALOG_TERM_FG# is 0>
	    	<font size="+1"><b>#one.display_name#</b></font>
	        <br>
	        <font color="##FF0000" size="-1">
		    	&nbsp;
		    	This name is not accepted for current identifications.
			</font>
	    </cfif>
	</div>
	<cfif isdefined("session.roles") and listfindnocase(session.roles,"manage_taxonomy")>
		<a href="/Taxonomy.cfm?action=edit&taxon_name_id=#one.taxon_name_id#">[ Edit Taxonomy ]</a>
	</cfif>
	<table border>
		<tr>
			<cfloop list="#taxaRanksList#" index="i">
				<cfif len(evaluate("one." & i)) gt 0>
					<cfset lbl=replace(i,"PHYL",'')>
					<cfif lbl is "subspecies" and len(one.infraspecific_rank) gt 0>
						<cfset lbl=one.infraspecific_rank>
					</cfif>
					<th>#lbl#</th>
				</cfif>
			</cfloop>
		</tr>
		<tr>
			<cfloop list="#taxaRanksList#" index="i">
				<cfif len(evaluate("one." & i)) gt 0>
					<td>#evaluate("one." & i)#</td>
					<cfset metaDesc=metaDesc & "; #replace(i,'PHYL','')#: #evaluate('one.' & i)#">
				</cfif>
			</cfloop>
		</tr>
	</table>
	<p>Name Authority: <b>#one.source_Authority#</b></p>
	<p>Common Name(s):
	<ul>
		<cfif len(common_name.common_name) is 0>
			<li><b>No common names recorded.</b></li>
		<cfelse>
			<cfset metaDesc=metaDesc & "; Common Names: #valuelist(common_name.common_name)#">
			<cfloop query="common_name">
				<li><b>#common_name#</b></li>
			</cfloop>
			<cfset title = title & ' (#valuelist(common_name.common_name, "; ")#)'>
		</cfif>
	</ul>
	<div>
		Related Publications:
		<ul>
		 	<cfif tax_pub.recordcount is 0>
				<li><b>No related publications recorded.</b></li>
			<cfelse>
				<cfloop query="tax_pub">
					<li>
						<a href="/SpecimenUsage.cfm?publication_id=#publication_id#">
							#short_citation#
						</a>
					</li>
				</cfloop>
			</cfif>
		</ul>
    </div>
	<div>
		Related Taxa:
		<ul>
		 	<cfif related.recordcount is 0 and imp_related.recordcount is 0>
				<li><b>No related taxa recorded.</b></li>
			<cfelse>
				<cfloop query="related">
					<li>
						#TAXON_RELATIONSHIP# of <a href="/TaxonomyDetails.cfm?taxon_name_id=#RELATED_TAXON_NAME_ID#"><i><b>#related_name#</b></i></a>
						<cfif len(RELATION_AUTHORITY) gt 0>
							(Authority: #RELATION_AUTHORITY#)
						</cfif>
					</li>
				</cfloop>
				<cfloop query="imp_related">
					<li>
						<a href="/TaxonomyDetails.cfm?taxon_name_id=#imp_RELATED_TAXON_NAME_ID#"><i><b>#imp_related_name#</b></i></a>
						is #imp_TAXON_RELATIONSHIP#
						<cfif len(imp_RELATION_AUTHORITY) gt 0>
							(Authority: #imp_RELATION_AUTHORITY#)
						</cfif>
					</li>
				</cfloop>
			</cfif>
		</ul>
    </div>
	<div id="specTaxMedia"></div>
	<div id="mapTax"></div>
	<p>
		Arctos Links:
		<ul>
			<cfquery name="sidas" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select count(*) c from identification_taxonomy where taxon_name_id=#one.taxon_name_id#
			</cfquery>

				<cfif debug>
		<cfdump var=#sidas#>
	</cfif>

			<cfif sidas.c gt 0>
				<li>
					<a href="/SpecimenResults.cfm?scientific_name=#one.scientific_name#">
						Specimens currently identified as #one.display_name#
					</a>
					<a href="/SpecimenResults.cfm?anyTaxId=#one.taxon_name_id#">
						[ include unaccepted IDs ]
					</a>
					<a href="/SpecimenResults.cfm?taxon_name_id=#one.taxon_name_id#">
						[ exact matches only ]
					</a>
					<a href="/SpecimenResults.cfm?scientific_name=#one.scientific_name#&media_type=any">
						[ with Media ]
					</a>
				</li>
				<li>
					<a href="/bnhmMaps/bnhmMapData.cfm?showRangeMaps=true&scientific_name=#one.scientific_name#" class="external" target="_blank">
						BerkeleyMapper + RangeMaps
					</a>
				</li>
			<cfelse>
				<li>No specimens use this name in Identifications.</li>
			</cfif>
			<li>
				 <cfquery name="citas" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select
						count(*) c
					from
						citation,
						identification_taxonomy
					where
						citation.identification_id=identification_taxonomy.identification_id and
						identification_taxonomy.taxon_name_id=#one.taxon_name_id#
				</cfquery>

				<cfif debug>
		<cfdump var=#citas#>
	</cfif>
				<cfif citas.c gt 0>
					<a href="/SpecimenResults.cfm?cited_taxon_name_id=#one.taxon_name_id#">
						Specimens cited using #one.display_name#
					</a>
				<cfelse>
					No specimens citations use this name.
				</cfif>
			</li>
		</ul>
	</p>
	External Links:

	<p>
		<cfset srchName = URLEncodedFormat(one.scientific_name)>
		<ul>
			<cfif one.phylclass is "Amphibia">
				<li>
					<a class="external" target="_blank" href="http://amphibiaweb.org/cgi/amphib_query?where-genus=#one.genus#&where-species=#one.species#">
						AmphibiaWeb
					</a>
				</li>
			</cfif>
			<li id="ispecies">
				<a class="external" target="_blank" href="http://ispecies.org/?q=#srchName#">iSpecies</a>
			</li>
			<li>
				<a class="external" target="_blank" href="http://wikipedia.org/wiki/#srchName#">
					Wikipedia
				</a>
			</li>

			<cfif one.kingdom is not "Plantae">
			<li>
				<a class="external" target="_blank" href="http://animaldiversity.ummz.umich.edu/site/search?SearchableText=#srchName#">
					Animal Diversity Web
				</a>
			</li>
			</cfif>
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
			<cfif one.kingdom is "Plantae">
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
			</cfif>
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


			<!----

			<li id="ispecies">
				<a class="external soft404" target="_blank" href="http://ispecies.org/?q=#srchName#">iSpecies</a>
				<span class="infoLink" onclick="alert('This site does not properly return page status. The link may or may not work.')";>[status unknown]</span>
			</li>


			<cfhttp url="http://wikipedia.org/wiki/#srchName#" method="head"></cfhttp>
			<cfset status=left(cfhttp.statuscode,3)>

			<li id="wikipedia">
				<a class="external <cfif status is "404">fourohfour</cfif>" target="_blank" href="http://wikipedia.org/wiki/#srchName#">
					Wikipedia
				</a>
				<cfif status is "404">
					<span class="infoLink" onclick="alert('This link is dead, but you may be able to locate useful information on the page anyway.')";>[status 404]</span>
				</cfif>
			</li>

			<cfif one.kingdom is not "Plantae">
			<li>
				<a class="external soft404" target="_blank" href="http://animaldiversity.ummz.umich.edu/site/search?SearchableText=#srchName#">
					Animal Diversity Web
				</a>
				<span class="infoLink" onclick="alert('This site does not properly return page status. The link may or may not work.')";>[status unknown]</span>
			</li>
			</cfif>
			<li>
				<a class="external soft404" target="_blank" href="http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?name=#srchName#">
					NCBI
				</a>
				<span class="infoLink" onclick="alert('This site does not properly return page status. The link may or may not work.')";>[status unknown]</span>
			</li>
			<li>
				<a class="external soft404" href="http://google.com/search?q=#thisSearch#" target="_blank">
					Google
				</a>
				<a class="external soft404" href="http://images.google.com/images?q=#thisSearch#" target="_blank">
					Images
				</a>
				<span class="infoLink" onclick="alert('This site does not allow pre-fetching. The link may or may not work.')";>[status unknown]</span>
			</li>
			<li>
				<a class="external soft404" target="_blank" href="http://www.eol.org/search/?q=#srchName#">
					Encyclopedia of Life
				</a>
				<span class="infoLink" onclick="alert('This site does not properly return page status. The link may or may not work.')";>[status unknown]</span>
			</li>
			<li>
				<a class="external soft404" target="_blank" href="http://www.ubio.org/browser/search.php?search_all=#srchName#">
					uBio
				</a>
				<span class="infoLink" onclick="alert('This site does not properly return page status. The link may or may not work.')";>[status unknown]</span>
			</li>
			<cfif one.kingdom is "Plantae">
				<li>
					<a class="external soft404" target="_blank" href="http://www.efloras.org/browse.aspx?name_str=#srchName#">Flora of North America</a>
				</li>
				<span class="infoLink" onclick="alert('This site does not properly return page status. The link may or may not work.')";>[status unknown]</span>
				<li>
					<a class="external soft404" target="_blank" href="http://www.ipni.org/ipni/simplePlantNameSearch.do?find_wholeName=#srchName#">
						The International Plant Names Index
					</a>
					<span class="infoLink" onclick="alert('This site does not properly return page status. The link may or may not work.')";>[status unknown]</span>
				</li>
				<li>
					<a class="external soft404" target="_blank" href="http://epic.kew.org/searchepic/summaryquery.do?scientificName=#srchName#&searchAll=true&categories=names&categories=bibl&categories=colln&categories=taxon&categories=flora&categories=misc">
						electronic plant information centre
					</a>
					<span class="infoLink" onclick="alert('This site does not properly return page status. The link may or may not work.')";>[status unknown]</span>
				</li>
			</cfif>
			<li>
				<a class="external soft404" target="_blank" href="http://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=Scientific_Name&search_value=#srchName#&search_kingdom=every&search_span=containing&categories=All&source=html&search_credRating=all">
					ITIS
				</a>
				<span class="infoLink" onclick="alert('This site does not properly return page status. The link may or may not work.')";>[status unknown]</span>
			</li>
			<li>
				<a class="external soft404" target="_blank" href="http://www.catalogueoflife.org/col/search/all/key/#srchName#/match/1">
					Catalogue of Life
				</a>
				<span class="infoLink" onclick="alert('This site does not properly return page status. The link may or may not work.')";>[status unknown]</span>
			</li>
			<li>
				<a class="external" target="_blank" href="
					http://www.google.com/custom?q=#srchName#&sa=Go!&cof=S:http://www.unep-wcmc.org;AH:left;LH:56;L:http://www.unep-wcmc.org/wdpa/I/unepwcmcsml.gif;LW:100;AWFID:681b57e6eabf5be6;&domains=unep-wcmc.org&sitesearch=unep-wcmc.org">
					UNEP (CITES)
				</a>
				<span class="infoLink" onclick="alert('This site does not properly return page status. The link may or may not work.')";>[status unknown]</span>
			</li>
			<cfhttp url="http://species.wikimedia.org/wiki/#srchName#" method="head"></cfhttp>
			<cfset status=left(cfhttp.statuscode,3)>
			<li id="wikispecies">
				<a class="external <cfif status is "404">fourohfour</cfif>" target="_blank" href="http://species.wikimedia.org/wiki/#srchName#">
					WikiSpecies
				</a>
				<cfif status is "404">
					<span class="infoLink" onclick="alert('This link is dead, but you may be able to locate useful information on the page anyway.')";>[status 404]</span>
				</cfif>
			</li>
			<li>
				<a class="external soft404" target="_blank" href="http://www.biodiversitylibrary.org/name/#srchName#">
					Biodiversity Heritage Library
				</a>
				<span class="infoLink" onclick="alert('This site does not properly return page status. The link may or may not work.')";>[status unknown]</span>
			</li>

			---->
		</ul>
	</p>
	<p id="taxRelatedNames"></p>
	<!-------
	<cfif len(one.genus) gt 0>
		<cfquery name="samegen" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select scientific_name,display_name from taxonomy where genus='#one.genus#'
			and scientific_name != '#one.scientific_name#'
			order by scientific_name
		</cfquery>
		<div>
			<cfif len(one.scientific_name) gt 0>
				Additional Arctos entries for <a href="/TaxonomyResults.cfm?genus==#one.genus#">genus=#one.genus#</a>
				<ul>
					<cfloop query="samegen">
						<li><a href="/name/#scientific_name#">#display_name#</a></li>
					</cfloop>
				</ul>
			<cfelse>
				There are no other Arctos records in this genera.
			</cfif>
		</div>
	</cfif>
	----->
</cfoutput>
<cfinclude template = "includes/_footer.cfm">