<cfif not isdefined("taxon_name_id")>
	<p style="color:#FF0000; font-size:14px;">
		Did not get a taxon_name_id - aborting....
	</p>
	<cfabort>
</cfif>
<cfinclude template = "includes/_header.cfm">
<!--- get taxon name ID if we're passed a scientific name --->
<cfif isdefined("scientific_name") and len(#scientific_name#) gt 0>
	<cfquery name="getTID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT taxon_name_id FROM taxonomy WHERE upper(scientific_name)
		LIKE '#ucase(scientific_name)#'
	</cfquery>
	<cfif getTID.recordcount is 1>
		<cfset taxon_name_id=#getTID.taxon_name_id#>
	  <cfelse>
	  	Scientific Name not found!!
		<br>Aborting search.
		<cfabort>
	</cfif>
</cfif>
<cfquery name="getDetails" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT 
		taxonomy.TAXON_NAME_ID,
		taxonomy.VALID_CATALOG_TERM_FG,
		taxonomy.SOURCE_AUTHORITY,
		taxonomy.FULL_TAXON_NAME,
		taxonomy.SCIENTIFIC_NAME,
		taxonomy.AUTHOR_TEXT,
		common_name,
		taxonomy.genus,
		taxonomy.species,
		RELATED_TAXON_NAME_ID,
		TAXON_RELATIONSHIP,
		RELATION_AUTHORITY,
		related_taxa.SCIENTIFIC_NAME as related_name
	 from 
	 	taxonomy, 
		common_name, 
		taxon_relations,
		taxonomy related_taxa
	 WHERE 
		taxonomy.taxon_name_id = common_name.taxon_name_id (+) AND
		taxonomy.taxon_name_id = taxon_relations.taxon_name_id (+) AND
		taxon_relations.related_taxon_name_id = related_taxa.taxon_name_id (+) AND
		taxonomy.taxon_name_id = #taxon_name_id#
		ORDER BY scientific_name, common_name, related_taxon_name_id
</cfquery>
<Cfoutput query="getDetails" group="scientific_name">
<cfset title="#getDetails.scientific_name#">
<cfset thisSearch = "%22#getDetails.scientific_name#%22">


<cfoutput group="common_name">
	<cfif len(#common_name#) gt 0>
		<cfset thisSearch = "#thisSearch# OR %22#common_name#%22">
	</cfif>	
</cfoutput>
</Cfoutput>
<Cfoutput query="getDetails" group="scientific_name">
	<div align="left">
	  <cfif #VALID_CATALOG_TERM_FG# is 1>
	      <font size="+1"	>
		      <a href="SpecimenResults.cfm?taxon_name_id=#taxon_name_id#"><I><B>#SCIENTIFIC_NAME#</B></I></a>
			    
		</font>
		
		      <cfif len(#AUTHOR_TEXT#) gt 0>
			      <font size="+1"	>#AUTHOR_TEXT#</font>
        </cfif>
		  <br>
        <cfelseIF #VALID_CATALOG_TERM_FG# is 0>
		        <p><font size="+1"><I><b>#SCIENTIFIC_NAME#</b></I></font>		            <cfif len(#AUTHOR_TEXT#) gt 0>
		              <font size="+1">#AUTHOR_TEXT#</font>
					 
		              </cfif>
	              <br>
	                <font color="##FF0000" size="-1">&nbsp;&nbsp;&nbsp;&nbsp;This
	                term is not accepted for current identifications.</font><br>
	      
	        </cfif>
  </div>
	<P align="left"><b>#FULL_TAXON_NAME#</b>
		
	<p align="left">Authority: <b>#source_Authority#</b>
		
		<p align="left">Common Name(s):<br>
		<cfoutput group="common_name">
			<cfif len(#Common_name#) gt 0>	
				&nbsp;&nbsp;&nbsp;&nbsp;<b>#common_name#</b><br>
			<cfelse>&nbsp;&nbsp;&nbsp;&nbsp;<b>No common names recorded.</b><br>
			</cfif>	
	</cfoutput>
	<p>
	<div align="left">Related Taxa:<br>
	  <cfoutput group="related_taxon_name_id">
			  <cfif len(#related_taxon_name_id#) gt 0>
&nbsp;&nbsp;&nbsp;&nbsp;<b>#TAXON_RELATIONSHIP#</b>&nbsp;<a href="TaxonomyDetails.cfm?taxon_name_id=#RELATED_TAXON_NAME_ID#"><i><b>#related_name#</b></i></a><br>
			    <cfelse>
			&nbsp;&nbsp;&nbsp;&nbsp;<b>No related taxa recorded.</b><br>
	    </cfif>	
	    </cfoutput>
		
    </div>
	<p>
		Links:
		<ul>
			<li>
				<a href="SpecimenResults.cfm?taxon_name_id=#taxon_name_id#">
					Search Arctos for <I>#SCIENTIFIC_NAME#</I></a>
			</li>
			<li>
				<a href="http://images.google.com/images?q=#thisSearch#" target="_blank">
					<img src="/images/GoogleImage.gif" width="40" border="0">&nbsp;Google Images</a>
			</li>
			
			<li>
				<cfset srchName = #replace(scientific_name," ","%20","all")#>
				<a href="http://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=Scientific_Name&search_value=#srchName#&search_kingdom=every&search_span=containing&categories=All&source=html&search_credRating=all"><img src="/images/itis.gif" border="0" width="30">&nbsp;ITIS</a>
			</li>
			<li>
				<cfset srchName = #replace(scientific_name," ","%20","all")#>
				<a href="http://www.unep-wcmc.org/isdb/CITES/Taxonomy/tax-species-result.cfm?displaylanguage=eng&Genus=%25#genus#%25&source=animals&Species=#species#"><img src="/images/UNEP.jpg" border="0" width="30">&nbsp;UNEP</a>
			</li>
			
			<li>
				<cfset srchName = #replace(scientific_name," ","+","all")#>
				<a href="http://darwin.zoology.gla.ac.uk/~rpage/portal/main.php?taxon_name=#srchName#&Submit=Go">TSE</a>
			</li>
		</ul>
			
	</p>
</Cfoutput>

 
<cfinclude template = "includes/_footer.cfm">
