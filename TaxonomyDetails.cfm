<cfinclude template = "includes/_header.cfm">
<!--- get taxon name ID if we're passed a scientific name --->
<cfif isdefined("scientific_name") and len(#scientific_name#) gt 0>
	<cfquery name="getTID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT taxon_name_id FROM taxonomy WHERE upper(scientific_name)	= '#ucase(scientific_name)#'
	</cfquery>
	
	<cfif getTID.recordcount is 1>
		<cfset tnid=#getTID.taxon_name_id#>
	<cfelse>
	  	<div class="error">
			<cfoutput>#scientific_name#</cfoutput> was not found.	
		</div>
	</cfif>
</cfif>
<cfif isdefined("taxon_name_id")>
	<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select scientific_name from taxonomy where taxon_name_id=#taxon_name_id# 
	</cfquery>
	<cflocation url="/name/#c.scientific_name#" addtoken="false">
</cfif>
<cfset taxaRanksList="Kingdom,Phylum,PHYLClass,Subclass,PHYLOrder,Suborder,Superfamily,Family,Subfamily,Genus,Subgenus,Species,Subspecies,Nomenclatural_Code">
<cfquery name="getDetails" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT 
		taxonomy.TAXON_NAME_ID,
		taxonomy.VALID_CATALOG_TERM_FG,
		taxonomy.SOURCE_AUTHORITY,
		taxonomy.FULL_TAXON_NAME,
		<cfloop list="#taxaRanksList#" index="i">
			taxonomy.#i#,
		</cfloop>
		taxonomy.SCIENTIFIC_NAME,
		taxonomy.AUTHOR_TEXT,
		taxonomy.INFRASPECIFIC_AUTHOR,		
		taxonomy.INFRASPECIFIC_RANK,
		common_name,
		taxon_relations.RELATED_TAXON_NAME_ID,
		taxon_relations.TAXON_RELATIONSHIP,
		taxon_relations.RELATION_AUTHORITY,
		related_taxa.SCIENTIFIC_NAME as related_name,
		imp_related_taxa.SCIENTIFIC_NAME imp_related_name,
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
<cfquery name="one" dbtype="query">
	select
		TAXON_NAME_ID,
		VALID_CATALOG_TERM_FG,
		SOURCE_AUTHORITY,
		FULL_TAXON_NAME,
		SCIENTIFIC_NAME,
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
		related_name
	from
		getDetails
	where
		RELATED_TAXON_NAME_ID is not null
	group by
		RELATED_TAXON_NAME_ID,
		TAXON_RELATIONSHIP,
		RELATION_AUTHORITY,
		related_name
</cfquery>
<cfquery name="imp_related" dbtype="query">
	select
		imp_related_name,
		imp_RELATED_TAXON_NAME_ID,
		imp_TAXON_RELATIONSHIP,
		imp_RELATION_AUTHORITY
	from
		getDetails
	where
		imp_RELATED_TAXON_NAME_ID is not null
	group by
		imp_related_name,
		imp_RELATED_TAXON_NAME_ID,
		imp_TAXON_RELATIONSHIP,
		imp_RELATION_AUTHORITY
</cfquery>
<cfoutput>
	<cfset title="#one.scientific_name#">
	<cfset metaDesc="Taxon Detail for #one.scientific_name#">
	<cfset thisSearch = "%22#one.scientific_name#%22">
	<cfloop query="common_name">
		<cfset thisSearch = "#thisSearch# OR %22#common_name#%22">
	</cfloop>	
	<div align="left">
		<cfif one.VALID_CATALOG_TERM_FG is 1>
	   		<font size="+1"	>
		    	<I><B>#one.SCIENTIFIC_NAME#</B></I>			    
			</font>
			<cfif len(one.AUTHOR_TEXT) gt 0>
				<font size="+1">#one.AUTHOR_TEXT#</font>
				<cfset metaDesc=metaDesc & "; Author: #one.AUTHOR_TEXT#">
        	</cfif>
        <cfelseIF #one.VALID_CATALOG_TERM_FG# is 0>
	    	<font size="+1"><I><b>#one.SCIENTIFIC_NAME#</b></I></font>
	    	<cfif len(#one.AUTHOR_TEXT#) gt 0>
		    	<font size="+1">#one.AUTHOR_TEXT#</font>
			</cfif>
	        <br>
	        <font color="##FF0000" size="-1">
		    	&nbsp;&nbsp;&nbsp;&nbsp;
		    	This name is not accepted for current identifications.
			</font>
	    </cfif>
	</div>
	<cfif isdefined("session.roles") and listfindnocase(session.roles,"manage_taxonomy")>
		<a href="/Taxonomy.cfm?action=edit&taxon_name_id=#one.taxon_name_id#">Edit Taxonomy</a>	
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
		</cfif>
	</ul>
	
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
	<p>
		Links:
		<ul>
			<li>
				Search Arctos for specimens <a href="/SpecimenResults.cfm?taxon_name_id=#one.taxon_name_id#">
				exactly <I>#one.SCIENTIFIC_NAME#</I></a>
			</li>
			<li>
				Search Arctos for specimens <a href="/SpecimenResults.cfm?scientific_name=#one.scientific_name#">like <em>#one.scientific_name#</em></a>
			</li>
			<li>
				<a href="http://images.google.com/images?q=#thisSearch#" target="_blank">
					<img src="/images/GoogleImage.gif" width="40" border="0">&nbsp;Google Images</a>
			</li>
			<li>
				<cfset srchName = #replace(one.scientific_name," ","+","all")#>
				<a href="http://ispecies.org/?q=#srchName#">iSpecies</a>
			</li>
			<li>
				<cfset srchName = #replace(one.scientific_name," ","%20","all")#>
				<a href="http://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=Scientific_Name&search_value=#srchName#&search_kingdom=every&search_span=containing&categories=All&source=html&search_credRating=all"><img src="/images/itis.gif" border="0" width="30">&nbsp;ITIS</a>
			</li>
			<li>
				<cfset srchName = #replace(one.scientific_name," ","%20","all")#>
				<a href="http://www.unep-wcmc.org/isdb/CITES/Taxonomy/tax-species-result.cfm?displaylanguage=eng&Genus=%25#one.genus#%25&source=animals&Species=#one.species#"><img src="/images/UNEP.jpg" border="0" width="30">&nbsp;UNEP</a>
			</li>			
		</ul>			
	</p>
	<cfif len(one.genus) gt 0>
		<cfquery name="samegen" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select scientific_name from taxonomy where genus='#one.genus#'
			and scientific_name != '#one.scientific_name#' and
			rownum < 25
			order by scientific_name
		</cfquery>
		<div>
			<cfif len(one.scientific_name) gt 0>
				Top 25 Arctos entries for genus=#one.genus# <a href="/TaxonomyResults.cfm?genus=#one.genus#">See all</a>
				<ul>
					<cfloop query="samegen">
						<li><a href="/name/#scientific_name#">#scientific_name#</a></li>
					</cfloop>
				</ul>
			<cfelse>
				There are no other Arctos records in this genera.
			</cfif>			
		</div>
	</cfif>
</cfoutput>
<cfinclude template = "includes/_footer.cfm">