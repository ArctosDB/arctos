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
		select * from taxon_name,taxon_term where 
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
		<a href="/editTaxonomy.cfm?action=editnoclass&taxon_name_id=#taxon_name_id.taxon_name_id#">Edit Non-Classification Data</a>
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
	<cfif tax_pub.recordcount is 0>
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


	<h4>Classifications</h4>
	<cfif isdefined("session.roles") and listfindnocase(session.roles,"manage_taxonomy")>
		<a target="_blank" href="/ScheduledTasks/globalnames_fetch.cfm?name=#name#">Refresh/pull GlobalNames</a>
		<a href="/editTaxonomy.cfm?action=newClassification&taxon_name_id=#taxon_name_id.taxon_name_id#">Create Classification</a>
	</cfif>
	<cfquery name="sources" dbtype="query">
		select 
			source,
			classification_id
		from 
			d 
		where 
			classification_id is not null 
		group by 
			source,
			classification_id
		order by 
			source,
			classification_id
	</cfquery>		
	<cfloop query="sources">
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
		<hr>
		Data from source <strong>#source#</strong>
		<!--- maybe later....
		<cfif listfindnocase(editableSources,source,"|")>
			<a href="/editTaxonomy.cfm?action=editClassification&name=#name#&classification_id=#classification_id#">Edit Classification</a>
		</cfif>
		---->
		<a href="/editTaxonomy.cfm?action=editClassification&name=#name#&classification_id=#classification_id#">[ Edit Classification ]</a>

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
</cfif>
</cfoutput>
<!---------------------------------------------------------------------------------------------------->
<cfinclude template="includes/_footer.cfm">