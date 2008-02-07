<cfset basSelect = "
 SELECT 
	cataloged_item.collection_object_id,
	decode(country,
		'United States','U.S.A.',
		country) country,
	state_prov,
	spec_locality,
	verbatim_date, 
	began_date, 
	ended_date,
	concatColls('collection_object_id', cataloged_item.collection_object_id, 'agent_name','coll_names') collectors,
	decode(orig_lat_long_units, 
		'decimal degrees',to_char(dec_lat) || 'd', 
		'deg. min. sec.', to_char(lat_deg) || 'd ' || to_char(lat_min) || 'm ' || to_char(lat_sec) || 's ' || lat_dir, 
		'degrees dec. minutes', to_char(lat_deg) || 'd ' || to_char(dec_lat_min) || 'm ' || lat_dir ) 
		VerbatimLatitude, 
	decode(orig_lat_long_units, 
		'decimal degrees',to_char(dec_long) || 'd', 
		'deg. min. sec.', to_char(long_deg) || 'd ' || to_char(long_min) || 'm ' || to_char(long_sec) || 's ' || long_dir, 
		'degrees dec. minutes', to_char(long_deg) || 'd ' || to_char(dec_long_min) || 'm ' || long_dir ) 
		VerbatimLongitude,
	lat_long_determiner.agent_name latlongdet,
	county,
	feature,
	decode(quad,
		NULL,NULL,
		quad||' Quad')
		quad,
	coll_object_remarks,
	associated_species,
	ConcatAttributeValue(cataloged_item.collection_object_id,'diploid number') diploid_number,
	ConcatAttributeValue(cataloged_item.collection_object_id,'number of labels') number_of_labels,
	datum,
	max_error_distance||' '||max_error_units max_error,
	concatSingleOtherId(cataloged_item.collection_object_id,'ALAAC number') ALAAC_number ,
	concatSingleOtherId(cataloged_item.collection_object_id,'U. S. National Park Service accession') Park_Service_accession ,
	concatSingleOtherId(cataloged_item.collection_object_id,'U. S. National Park Service catalog') Park_Service_catalog ,
	concatSingleOtherId(cataloged_item.collection_object_id,'integer field number') integer_field_number ,
	concatSingleOtherId(cataloged_item.collection_object_id,'original field number') original_field_number ,
	concatSingleOtherId(cataloged_item.collection_object_id,'secondary field number') secondary_field_number,
	family,
	author_text,
	subspecies,
	taxonomy.taxon_name_id,
	infraspecific_rank,
	identification_remarks,
	decode(identificationer.agent_name,
		'unknown',NULL,
		identificationer.agent_name)
		identifier,
	minimum_elevation,
	maximum_elevation,
	orig_elev_units,
	coll_object_remark.habitat microhabitat,
	decode(taxa_formula,
		'A',taxonomy.genus||' '||taxonomy.species,
		identification.scientific_name)
		scientific_name,
	infraspecific_rank,
	to_char(made_date,'dd Mon YYYY') made_date
	">
<cfset basFrom = "FROM 
	cataloged_item,
	collection, 
	identification,
	preferred_agent_name identificationer,
	geog_auth_rec,
	locality,
	collecting_event, 
	accepted_lat_long,
	preferred_agent_name lat_long_determiner,
	coll_object specCollObj,
	coll_object_remark,
	taxonomy,
	identification_taxonomy
	">
<cfset basWhere = "WHERE 
	cataloged_item.collection_id = collection.collection_id AND 
	cataloged_item.collection_object_id = identification.collection_object_id AND 
	identification.accepted_id_fg = 1 AND 
	locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND 
	collecting_event.locality_id = locality.locality_id AND 
	cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND 
	locality.locality_id = accepted_lat_long.locality_id (+) AND 
	accepted_lat_long.determined_by_agent_id = lat_long_determiner.agent_id (+) AND 
	cataloged_item.collection_object_id = specCollObj.collection_object_id AND 
	cataloged_item.collection_object_id = coll_object_remark.collection_object_id (+) AND
	identification.id_made_by_agent_id = identificationer.agent_id AND
	identification.identification_id = identification_taxonomy.identification_id AND
	identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id AND
	cataloged_item.collection_cde='Herb'
	">
	
	
	<cfset basQual = "">
	<cfinclude template="/includes/SearchSql.cfm">
	
			

		<cfset SqlString = "#basSelect# #basFrom# #basWhere# #basQual# ORDER BY cataloged_item.collection_object_id">	

	
		<cfif len(#basQual#) is 0 AND basFrom does not contain "binary_object">
			<CFSETTING ENABLECFOUTPUTONLY=0>
			
			<font color="#FF0000" size="+2">You must enter some search criteria!</font>	  
			<cfabort>
		</cfif>
		<!----
		<cfoutput>
	#preserveSingleQuotes(SqlString)#
	
	</cfoutput>
	---->
	<cfquery name="getData" datasource = "#Application.web_user#" >
		#preserveSingleQuotes(SqlString)#
	</cfquery>
	
	
	
	
	<cfif getData.recordcount is 0>
	<CFSETTING ENABLECFOUTPUTONLY=0>
			<cfoutput>
		<font color="##FF0000" size="+2">Your search returned no results.</font>	  
		<p>Some possibilities include:</p>
		<ul>
			<li>
				If you searched by taxonomy, please consult <a href="/TaxonomySearch.cfm" target="#client.target#" class="novisit">Arctos Taxonomy</a>.
			</li>
			<li>
				Try broadening your search criteria. Try the next-higher geographic element, remove criteria, etc. Don't assume we've accurately or predictably recorded data!
			</li>
			<li>
				Use dropdowns or partial word matches instead of text strings, which may be entered in unexpected ways. "Doe" is a good choice for a collector if "John P. Doe" didn't match anything.
			</li>
			<li>
				Read the documentation for individual search fields (click the title of the field to see documentation). Arctos fields may not be what you expect them to be.
			</li>
		</ul>
		</cfoutput>
		
		<cfabort>
	</cfif>
	
<cfset i=1>
<table border>
<cfset dlPath = "#SpecimenDownloadPath#">
<cfset dlFile = "#Client.SpecimenDownloadFileName#">
<tr>
	<td>Country</td>
	<td>State</td>
	<td>Specific_Locality</td>
	<td>Date</td>
	<td>Collectors</td>
	<td>Coordinates</td>
	<td>Coordinate_Determiner</td>
	<td>County</td>
	<td>Feature</td>
	<td>Quad</td>
	<td>Remarks</td>
	<td>Associated_Species</td>
	<td>Diploid_Number</td>
	<td>Number_Of_Labels</td>
	<td>Datum</td>
	<td>Max_Error</td>
	<td>ALAAC_number</td>
	<td>Park_Service_Accession</td>
	<td>Park_Service_Catalog</td>
	<td>Original_Field_Number</td>
	<td>Secondary_Field_Number</td>
	<td>Family</td>
	<td>Scientific_Name_1</td>
	<td>Scientific_Name_2</td>
	<td>Scientific_Name_3</td>
	<td>Scientific_Name_4</td>
	<td>Identifier</td>
	<td>ID_Date</td>
	<td>Identification_Remarks</td>
	<td>Elevation</td>
	<td>Microhabitat</td>
</tr>
<cfset header="Locality#chr(9)#State#chr(9)#Country#chr(9)#Date#chr(9)#Collectors#chr(9)#Coordinate_Determiner#chr(9)#Remarks#chr(9)#Diploid_Number#chr(9)#Number_Of_Labels#chr(9)#Datum#chr(9)#Max_Error#chr(9)#ALAAC_number#chr(9)#Park_Service_Accession#chr(9)#Park_Service_Catalog#chr(9)#Original_Field_Number#chr(9)#Secondary_Field_Number#chr(9)#Family#chr(9)#Scientific_Name_1#chr(9)#Scientific_Name_2#chr(9)#Scientific_Name_3#chr(9)#Scientific_Name_4#chr(9)#Identifier#chr(9)#ID_Date#chr(9)#Identification_Remarks">


<cfset header = "#header##chr(10)#"><!--- add one and only one line break back onto the end --->
<cffile action="write" file="#dlPath##dlFile#" addnewline="no" output="#header#">

<cfoutput query="getData"  group="collection_object_id">
<tr>
		<cfset scientific_name_1 = "">
		<cfset scientific_name_2 = "">
		<cfset scientific_name_3 = "">
		<cfset scientific_name_3 = "">
 	<cfquery name="isChildOf" datasource="#Application.web_user#">
			select 
				genus,
				species,
				author_text
			FROM
				taxonomy,
				taxon_relations
			WHERE
				taxon_relations.taxon_name_id = #taxon_name_id# AND
				taxon_relationship='child of' AND
				taxonomy.taxon_name_id = related_taxon_name_id
		</cfquery>
				
		<cfif len(#isChildOf.genus#) gt 0 AND len(#isChildOf.species#)>
			<!--- this specimen is a child taxa - use the parent ---->
			<cfset scientific_name_1 = "#isChildOf.genus# #isChildOf.species#">
		<cfelse>
			<cfset scientific_name_1 = #scientific_name#>
		</cfif>
		
		
		<cfif len(#isChildOf.author_text#) gt 0>
			<cfset scientific_name_2 = "#isChildOf.author_text#">
		</cfif>
		
		<cfif len(#infraspecific_rank#) gt 0>
			<cfif len(#scientific_name_2#) gt 0>
				<cfset scientific_name_2 = "#scientific_name_2# #infraspecific_rank#">
			<cfelse>
				<cfset scientific_name_2 = #infraspecific_rank#>
			</cfif>
		</cfif>
		<cfif len(#subspecies#) gt 0>
			<cfset scientific_name_3 = #subspecies#>
		</cfif>
		<cfif len(#author_text#) gt 0>
			<cfset scientific_name_4 = #author_text#>
		</cfif>
		
		<!--- first, figure out how many collectors there are --->
		<cfset numColls=0>
		<cfloop list="#Collectors#" delimiters=";" index="c">
			<cfset #numColls# = #numColls# +1>
		</cfloop>
		
		<cfif #numColls# is 1>
			<cfset colls = "#Collectors#">
		<cfelseif #numColls# is 2>
			<cfset colls = replace(collectors,";"," &","all")>
		<cfelseif #numColls# is 3>
			<cfset cNum = 1>
			<cfloop list="#Collectors#" delimiters=";" index="c">
				<cfif #cNum# is 1>
					<cfset colls = "#c#">
				<cfelseif #cnum# is 2>
					<cfset colls = "#colls#, #c#">
				<cfelseif #cnum# is 3>
					<cfset colls = "#colls# & #c#">
				</cfif>
				<cfset cNum = #cNum# + 1>
			</cfloop>
		<cfelse>
			<cfset breakPos = find(";",collectors) -1>
			<cfset c1 = left(collectors,breakPos)>
			<cfset colls = "#c1# et al.">
		</cfif>
		
		<!----
		<cfset c = #replace(Collectors,";","<br>","all")#>
			<cfset c = #replace(c," ","&nbsp;","all")#>
			<cfset c = #replace(c,"<br>&nbsp;","<br>","all")#>
				#c#
		---->
		<cfset thisDate = "">
		<cftry>
			<cfset thisDate = #dateformat(verbatim_date,"dd mmm yyyy")#>
			<cfcatch>
				<cfset thisDate = #verbatim_date#>
			</cfcatch>
		</cftry>
		<cfset elevation = "">
		<cfif len(#minimum_elevation#) gt 0 OR len(#maximum_elevation#) gt 0>
			<cfif #orig_elev_units# is "m">
				<cfset minel = #minimum_elevation#>
				<cfset maxel = #maximum_elevation#>
			<cfelseif #orig_elev_units# is "ft">
				<cfset minel = #minimum_elevation# * .3048>
				<cfset maxel = #maximum_elevation# * .3048>
			<cfelse>
				<cfset minel = 999999999999999999999999999>
				<cfset maxel = 999999999999999999999999999>
			</cfif>
			<cfif #minel# is #maxel#>
				<cfset elevation = "#maxel# m">
			<cfelse>
				<cfset elevation = "#minel# - #maxel# m">
			</cfif>
		</cfif>
		<cfset thisQuad = "">
		<cfif len(#quad#) gt 0>
			<cfset thisQuad = "#quad#.:">
		</cfif>
		<cfset thisCounty = "">
		<cfif len(#county#) gt 0>
			<cfset thisCounty = "#county# Co.:">
		</cfif>
		<cfset thisFeature = "">
		<cfif len(#Feature#) gt 0>
			<cfset thisFeature = "#Feature#, ">
		</cfif>
		<cfset thisSpecloc = "">
		<cfif len(#spec_locality#) gt 0>
			<cfset thisSpecloc = "#spec_locality#, ">
		</cfif>
		<cfset coordinates = "">
		<cfif len(#VerbatimLatitude#) gt 0 and len(#VerbatimLongitude#) gt 0>
			<cfset coordinates = "#VerbatimLatitude# #VerbatimLongitude#">
		</cfif>
		<cfset micHab = "">
		<cfif len(#microhabitat#) gt 0>
			<cfset micHab = "#microhabitat#, ">
		</cfif>
		
		<cfset locality = "">
		<cfif len(#quad#) gt 0>
			<cfif len(#locality#) gt 0>
				<cfset locality = "#locality# #ucase(quad)#.:">
			<cfelse>
				<cfset locality = "#ucase(quad)#.:">
			</cfif>
		</cfif>
		<cfif len(#county#) gt 0>
			<cfif len(#locality#) gt 0>
				<cfset locality = "#locality# #ucase(county)# CO.:">
			<cfelse>
				<cfset locality = "#ucase(county)# CO.:">
			</cfif>
		</cfif>
		<cfif len(#feature#) gt 0>
			<cfif len(#locality#) gt 0>
				<cfset locality = "#locality#, #feature#">
			<cfelse>
				<cfset locality = "#feature#">
			</cfif>
		</cfif>
		<cfif len(#spec_locality#) gt 0>
			<cfif len(#locality#) gt 0>
				<cfset locality = "#locality#, #spec_locality#">
			<cfelse>
				<cfset locality = "#spec_locality#">
			</cfif>
		</cfif>
		<cfif len(#coordinates#) gt 0>
			<cfif len(#locality#) gt 0>
				<cfset locality = "#locality#, #coordinates#">
			<cfelse>
				<cfset locality = "#coordinates#">
			</cfif>
		</cfif>
		<cfif len(#elevation#) gt 0>
			<cfif len(#locality#) gt 0>
				<cfset locality = "#locality#, #elevation#">
			<cfelse>
				<cfset locality = "#elevation#">
			</cfif>
		</cfif>
		<cfif len(#microhabitat#) gt 0>
			<cfif len(#locality#) gt 0>
				<cfset locality = "#locality#, #microhabitat#">
			<cfelse>
				<cfset locality = "#microhabitat#">
			</cfif>
		</cfif>
		<cfif len(#associated_species#) gt 0>
			<cfif len(#locality#) gt 0>
				<cfset locality = "#locality#, #associated_species#">
			<cfelse>
				<cfset locality = "#associated_species#">
			</cfif>
		</cfif>
		<cfset locality = "#locality#.">

<cfset oneline="#locality##chr(9)##state_prov##chr(9)##country##chr(9)##thisDate##chr(9)##colls##chr(9)##latlongdet##chr(9)##coll_object_remarks##chr(9)##diploid_number##chr(9)##number_of_labels##chr(9)##datum##chr(9)##max_error##chr(9)##ALAAC_number##chr(9)##Park_Service_accession##chr(9)##Park_Service_catalog##chr(9)##original_field_number##chr(9)##secondary_field_number##chr(9)##family##chr(9)##scientific_name_1##chr(9)##scientific_name_2##chr(9)##scientific_name_3##chr(9)##scientific_name_4##chr(9)##identifier##chr(9)##made_date##chr(9)##identification_remarks##chr(9)#">

<!----
<cfset oneline="#country##chr(9)##state_prov##chr(9)##thisSpecloc##chr(9)##thisDate##chr(9)##colls##chr(9)##coordinates##chr(9)##latlongdet##chr(9)##thisCounty##chr(9)##thisFeature##chr(9)##thisQuad##chr(9)##coll_object_remarks##chr(9)##associated_species##chr(9)##diploid_number##chr(9)##number_of_labels##chr(9)##datum##chr(9)##max_error##chr(9)##ALAAC_number##chr(9)##Park_Service_accession##chr(9)##Park_Service_catalog##chr(9)##original_field_number##chr(9)##secondary_field_number##chr(9)##family##chr(9)##scientific_name_1##chr(9)##scientific_name_2##chr(9)##scientific_name_3##chr(9)##scientific_name_4##chr(9)##identifier##chr(9)##made_date##chr(9)##identification_remarks##chr(9)##elevation##chr(9)##micHab#">


---->


<td>#country#</td>
	<td>#state_prov#</td>
	<td>#spec_locality#</td>
	<td>#thisDate#</td>
	<td nobreak>#colls#</td>
	<td>#VerbatimLatitude# #VerbatimLongitude#</td>
	<td>#latlongdet#</td>	
	<td>#county#</td>
	<td>#feature#</td>
	<td>#quad#</td>
	<td>#coll_object_remarks#</td>
	<td>#associated_species#</td>
	<td>#diploid_number#</td>
	<td>#number_of_labels#</td>
	<td>#datum#</td>
	<td>#max_error#</td>
	<td>#ALAAC_number#</td>
	<td>#Park_Service_Accession#</td>
	<td>#Park_Service_Catalog#</td>
	<td>#Original_Field_Number#</td>
	<td>#Secondary_Field_Number#</td>
	<td>#Family#</td>
	<td>#scientific_name_1#</td>
	<td>#scientific_name_2#</td>
	<td>#scientific_name_3#</td>
	<td>#scientific_name_4#</td>
	<td>#identifier#</td>
	<td>#made_date#</td>
	<td>#Identification_Remarks#</td>
	<td>#elevation#</td>
	<td>#microhabitat#</td>
<!-----
----->

<cfset oneLine = trim(#oneLine#)>
	<cffile action="append" file="#dlPath##dlFile#" addnewline="yes" output="#oneLine#">


	</tr>
  </cfoutput>
  <cfoutput>
	<cfset downloadFile = "/download/#dlFile#">
	---<a href="/download_agree.cfm?downloadFile=#downloadFile#">get DL</a>
	<!----
	<cflocation url="/download_agree.cfm?downloadFile=#downloadFile#">
	---->
	
	</cfoutput>

</table>

<!------------------------- make download ----------------------------------------------------------->



<!---- end action not download ---->
<cfif #Action# is "download">

	
	
<cfif #detail_level# gte 1>
	<cfset header = "Catalog_Number#chr(9)#Scientific_Name">
</cfif>
<cfif #detail_level# gte 2>
	<cfset header = "#header##chr(9)#Af_Number#chr(9)#Other_Identifiers#chr(9)#Accession#chr(9)#Collectors#chr(9)#Latitude#chr(9)#Longitude">
</cfif>
<cfif #detail_level# gte 4>
	<cfset header = "#header##chr(9)#Decimal_Latitude#chr(9)#Decimal_Longitude#chr(9)#Maximum_Error#chr(9)#Datum#chr(9)#Original_Lat_Long_Units#chr(9)#Lat_Long_Determiner#chr(9)#Lat_Long_Reference#chr(9)#Lat_Long_Remarks">
				
</cfif>
<cfif #detail_level# gte 4>
	<cfset header = "#header##chr(9)#Continent">
</cfif>
<cfif #detail_level# gte 1>
	<cfset header = "#header##chr(9)#Country#chr(9)#State">
</cfif>
<cfif #detail_level# gte 4>
	<cfset header = "#header##chr(9)#Sea">
</cfif>
<cfif #detail_level# gte 2>
	<cfset header = "#header##chr(9)#Map_Name#chr(9)#Feature#chr(9)#County#chr(9)#Island_Group#chr(9)#Island#chr(9)#Associated_Species#chr(9)#Microhabitat">
</cfif>
<cfif #detail_level# gte 1>
	<cfset header = "#header##chr(9)#Specific_Locality#chr(9)#Verbatim_Date">
</cfif>
<cfif #detail_level# gte 3>
	<cfset header = "#header##chr(9)#Coll_Date">
</cfif>
<cfif #detail_level# gte 1>
	<cfset header = "#header##chr(9)#Parts#chr(9)#Sex">
</cfif>

<cfif #detail_level# gte 3>
	<cfloop list="#attList#" index="val">
		<cfif #val# is not "sex">
			<cfset val = #replace(val," ","_","all")#>
			<cfset header = "#header##chr(9)##val#">
		</cfif>
	</cfloop>
</cfif>
	<cfif #detail_level# gte 4>
		<cfloop list="#attList#" index="val">
			<cfset val = #replace(val," ","_","all")#>
				<cfset header = "#header##chr(9)##val#_details">
		</cfloop>
		<cfloop list="#OIDlist#" index="val">
			<cfset val = #replace(val," ","_","all")#>
			<cfset header = "#header##chr(9)##val#">
		</cfloop>
	</cfif>
	<cfif #detail_level# gte 2>
	<cfset header = "#header##chr(9)#Specimen_Remarks#chr(9)#Specimen_Disposition">
		
	</cfif>
<cfset header=#trim(header)#>
	

 <cfoutput query="getBasic" group="collection_object_id">
 	<cfset oneLine = "#institution_acronym# #collection_cde# #cat_num##chr(9)##Scientific_Name#">

<cfif #detail_level# gte 2>
	<cfset oneLine = "#oneLine##chr(9)##af_num##chr(9)##other_ids##chr(9)##Accession##chr(9)##Collectors#">
</cfif>
<cfif #detail_level# gte 2>
				<cfif #encumbrance_action# does not contain "coordinates">
					<cfset oneLine = "#oneLine##chr(9)##verbatimLatitude##chr(9)##verbatimLongitude#">
				<cfelse>
					<cfif isdefined("client.rights") AND #client.rights# contains "student0">
						<cfset oneLine = "#oneLine##chr(9)##verbatimLatitude##chr(9)##verbatimLongitude#">
					<cfelse>
						<cfset oneLine = "#oneLine##chr(9)#Masked#chr(9)#Masked">
					</cfif>
				</cfif>
				
</cfif>
<cfif #detail_level# gte 4>
				<cfif #encumbrance_action# does not contain "coordinates">
					<cfset oneLine = "#oneLine##chr(9)##decimallatitude##chr(9)##decimallongitude##chr(9)##max_error##chr(9)##datum##chr(9)##orig_lat_long_units##chr(9)##lat_long_determiner##chr(9)##lat_long_ref_source##chr(9)##lat_long_remarks#">
				<cfelse>
					<cfif isdefined("client.rights") AND #client.rights# contains "student0">
						<cfset oneLine = "#oneLine##chr(9)##decimallatitude##chr(9)##decimallongitude##chr(9)##max_error##chr(9)##datum##chr(9)##orig_lat_long_units##chr(9)##lat_long_determiner##chr(9)##lat_long_ref_source##chr(9)##lat_long_remarks#">
					<cfelse>
						<cfset oneLine = "#oneLine##chr(9)#Masked#chr(9)#Masked#chr(9)##max_error##chr(9)##datum##chr(9)##orig_lat_long_units##chr(9)##lat_long_determiner##chr(9)##lat_long_ref_source##chr(9)##lat_long_remarks#">
					</cfif>
				</cfif>
	
</cfif>
<cfif #detail_level# gte 4>
	<cfset oneLine = "#oneLine##chr(9)##CONTINENT_OCEAN#">
</cfif>
<cfset oneLine = "#oneLine##chr(9)##Country##chr(9)##State_Prov#">
<cfif #detail_level# gte 4>
	<cfset oneLine = "#oneLine##chr(9)##sea#">
</cfif>
<cfif #detail_level# gte 2>
	<cfset oneLine = "#oneLine##chr(9)##quad##chr(9)##feature##chr(9)##county##chr(9)##island_group##chr(9)##island##chr(9)##Associated_Species##chr(9)##habitat#">
</cfif> 
<cfset oneLine = "#oneLine##chr(9)##spec_locality##chr(9)##verbatim_date#">
<cfif #detail_level# gte 3>
	<cfif #began_date# is #ended_date# AND len(#began_date#) gt 0>
		<cfset collDate = "#dateformat(began_date,"dd mmm yyyy")#">
	<cfelseif len(#ended_date#) is 0 AND len(#began_date#) is 0>
		<cfset collDate = "Not recorded.">
	<cfelse>
		<cfset collDate = "#dateformat(began_date,"dd mmm yyyy")# - #dateformat(ended_date,"dd mmm yyyy")#">
	</cfif>
	<cfset oneLine = "#oneLine##chr(9)##collDate#">
</cfif>
<cfset oneLine = "#oneLine##chr(9)##parts##chr(9)##sex#">
<cfif #detail_level# gte 3>
		<cfloop list="#attList#" index="val">
			<cfset thisName = #val#>
			<cfset thisName = #replace(thisName," ","_","all")#>
			<cfset thisName = #replace(thisName,"-","_","all")#>
			<cfset thisName = #left(thisName,20)#>
			
			<cfif #thisName# is not "sex">
				<Cfset thisVal =#evaluate("getBasic." &  thisName)#>
				<cfset oneLine = "#oneLine##chr(9)##thisVal#">
			</cfif>
		</cfloop>
	</cfif>
	
	<cfif #detail_level# gte 4>
		<cfloop list="#attList#" index="val">
			<cfset thisName = #val#>
			<cfset thisName = #replace(thisName," ","_","all")#>
			<cfset thisName = #replace(thisName,"-","_","all")#>
			<cfset thisName = #left(thisName,20)#>
			<cfset thisName = "#thisName#_Detail">
			<cfset thisVal = #evaluate("getBasic." &  thisName)#>
			<cfset oneLine = "#oneLine##chr(9)##thisVal#">
			
		</cfloop>
		<cfloop list="#OIDlist#" index="val">
		
			<cfset thisNum = #val#>
			<cfset thisNum = #replace(thisNum," ","_","all")#>
			<cfset thisNum = #replace(thisNum,"-","_","all")#>
			<cfset thisNum = #replace(thisNum,".","_","all")#>
			<cfset thisNum = #right(thisNum,20)#>
			<cfif #left(thisNum,1)# is "_">
				<cfset thisNum = #replace(thisNum,"_","","first")#>
			</cfif>
			<cfset thisVal =#evaluate("getBasic." &  thisNum)#>
			<cfset oneLine = "#oneLine##chr(9)##thisVal#">
			
		</cfloop>
		
	</cfif>
<cfif #detail_level# gte 2>
	<cfset oneLine = "#oneLine##chr(9)##coll_object_remarks##chr(9)##coll_obj_disposition#">
</cfif>
<cfset oneLine = trim(#oneLine#)>
	<cffile action="append" file="#dlPath##dlFile#" addnewline="yes" output="#oneLine#">
	
	</cfoutput>
	<cfoutput>
	<cfset downloadFile = "/download/#dlFile#">
	<cflocation url="download_agree.cfm?cnt=#cnt.recordcount#&downloadFile=#downloadFile#">
	</cfoutput>
</cfif>
	
	<!------------------------------------- end download ----------------------------------->
<cfif #Action# is "labels">

<cfset dlPath = "#SpecimenDownloadPath#">
<cfset dlFile = "#Client.SpecimenDownloadFileName#">
	<cfset header = "CatalogNumber#chr(9)#ScientificName#chr(9)#AfNumber#chr(9)#LatLong#chr(9)#Geog#chr(9)#VerbatimDate#chr(9)#Sex#chr(9)#Collectors#chr(9)#Parts#chr(9)#FieldNumber#chr(9)#Measurements#chr(9)#Accn#chr(9)#">

<cfset header=#trim(header)#>
	<cfset header = "#header##chr(10)#"><!--- add one and only one line break back onto the end --->
<cffile action="write" file="#dlPath##dlFile#" addnewline="no" output="#header#">

 <cfoutput query="getBasic" group="collection_object_id">
 	<cfset af = "">
	<cfif len(#af_num#) gt 0>
		<cfset af = "AF #af_num#">
	</cfif>
	<cfset coordinates = "">
	<cfif len(#verbatimLatitude#) gt 0 AND len(#verbatimLongitude#) gt 0>
		<cfset coordinates = "#verbatimLatitude# / #verbatimLongitude#">
		<cfset coordinates = replace(coordinates,"d","","all")>
		<cfset coordinates = replace(coordinates,"m","'","all")>
		<cfset coordinates = replace(coordinates,"s","''","all")>
	</cfif>
	<cfset geog = "">
		<cfif #state_prov# is "Alaska">
			<cfset geog = "Alaska">
			<cfif len(#island#) gt 0>
				<cfset geog = "#geog#, #island#">
			</cfif>
			<cfif len(#sea#) gt 0>
				<cfif len(#quad#) is 0>
					<cfset geog = "#geog#, #sea#">
				</cfif>
			</cfif>
			<cfif len(#quad#) gt 0>
					<cfif not #geog# contains " Quad">
						<cfset geog = "#geog#, #quad# Quad">
					</cfif>
			</cfif>
			
			<cfif len(#feature#) gt 0>
				<cfset geog = "#geog#, #feature#">
			</cfif>
			<cfif len(#spec_locality#) gt 0>
				<cfset geog = "#geog#; #spec_locality#">
			</cfif>
		<cfelse>
		  	<cfif len(#country#) gt 0>
				<cfset geog = "#country#">
			</cfif>
			<cfif len(#sea#) gt 0>
				<cfset geog = "#geog#, #sea#">
			</cfif>
			<cfif len(#state_prov#) gt 0>
				<cfset geog = "#geog#, #state_prov#">
			</cfif>
			<cfif len(#island#) gt 0>
				<cfset geog = "#geog#, #island#">
			</cfif>
			<cfif len(#quad#) gt 0>
				<cfset geog = "#geog#, #quad# Quad">
			</cfif>
			<cfif len(#feature#) gt 0>
				<cfset geog = "#geog#, #feature#">
			</cfif>
			<cfif len(#spec_locality#) gt 0>
				<cfset geog = "#geog#; #spec_locality#">
			</cfif>
		</cfif>
		<cfset sexcode = "">
		<cfif len(#sex#) gt 0>
			<cfif #sex# is "male">
				<cfset sexcode = "M">
			<cfelseif #sex# is "female">
				<cfset sexcode = "F">
			<cfelse>
				<cfset sexcode = "?">
			</cfif>
		</cfif>
		<cfset FieldNum = "">
		<cfloop list="#OIDlist#" index="val">
			<cfif #val# contains "original field number">
				<cfset FieldNum = "#val#">
			</cfif>
		</cfloop>
		<cfif len(#sex#) gt 0>
			<cfif #sex# is "male">
				<cfset sexcode = "M">
			<cfelseif #sex# is "female">
				<cfset sexcode = "F">
			<cfelse>
				<cfset sexcode = "?">
			</cfif>
		</cfif>
		<cfif #collectors# contains ";">
			<Cfset spacePos = find(";",collectors)>
			<cfset thisColl = left(collectors,#SpacePos# - 1)>
			<cfset thisColl = "#thisColl# et al.">
		<cfelse>
			<cfset thisColl = #collectors#>
		</cfif>
		<cfset totlen = "">
		<cfset taillen = "">
		<cfset hf = "">
		<cfset efn = "">
		<cfset weight = "">
		<cfset totlen_val = "">
		<cfset taillen_val = "">
		<cfset hf_val = "">
		<cfset efn_val = "">
		<cfset weight_val = "">
		<cfset totlen_units = "">
		<cfset taillen_units = "">
		<cfset hf_units = "">
		<cfset efn_units = "">
		<cfset weight_units = "">
				
		<cfloop list="#attList#" index="val">
			<cfset thisName = #val#>
			<cfset thisName = #replace(thisName," ","_","all")#>
			<cfset thisName = #replace(thisName,"-","_","all")#>
			<cfset thisName = #left(thisName,20)#>
			
			<cfif #val# is "total length">
				<cfset totlen = "#evaluate("getBasic." &  thisName)#">
			</cfif>
			<cfif #val# is "tail length">
				<cfset taillen = "#evaluate("getBasic." &  thisName)#">
			</cfif>
			<cfif #val# is "hind foot with claw">
				<cfset hf = "#evaluate("getBasic." &  thisName)#">
			</cfif>
			<cfif #val# is "ear from notch">
				<cfset efn = "#evaluate("getBasic." &  thisName)#">
			</cfif>
			<cfif #val# is "weight">
				<cfset weight = "#evaluate("getBasic." &  thisName)#">
			</cfif>
		</cfloop>
		<cfif len(#totlen#) gt 0>
			<cfif #trim(totlen)# contains " ">
				<cfset spacePos = find(" ",totlen)>
				<cfset totlen_val = trim(left(totlen,#spacePos#))>
				<cfset totlen_Units = trim(right(totlen,len(totlen) - #spacePos#))>
			</cfif>		
		</cfif>
		<cfif len(#taillen#) gt 0>
			<cfif #trim(taillen)# contains " ">
				<cfset spacePos = find(" ",taillen)>
				<cfset taillen_val = trim(left(taillen,#spacePos#))>
				<cfset taillen_Units = trim(right(taillen,len(taillen) - #spacePos#))>
			</cfif>		
		</cfif>
		<cfif len(#hf#) gt 0>
			<cfif #trim(hf)# contains " ">
				<cfset spacePos = find(" ",hf)>
				<cfset hf_val = trim(left(hf,#spacePos#))>
				<cfset hf_Units = trim(right(hf,len(hf) - #spacePos#))>
			</cfif>		
		</cfif>
		<cfif len(#efn#) gt 0>
			<cfif trim(#efn#) contains " ">
				<cfset spacePos = find(" ",efn)>
				<cfset efn_val = trim(left(efn,#spacePos#))>
				<cfset efn_Units = trim(right(efn,len(efn) - #spacePos#))>
			</cfif>		
		</cfif>
		<cfif len(#weight#) gt 0>
			<cfif trim(#weight#) contains " ">
				<cfset spacePos = find(" ",weight)>
				<cfset weight_val = trim(left(weight,#spacePos#))>
				<cfset weight_Units = trim(right(weight,len(weight) - #spacePos#))>
			</cfif>		
		</cfif>
		
			<cfif len(#totlen#) gt 0>
				<cfif #totlen_Units# is "mm">
					<cfset meas = "#totlen_val#-">
				<cfelse>
					<cfset meas = "#totlen_val# #totlen_units#-">
				</cfif>
			<cfelse>
				<cfset meas="X-">
			</cfif>
			
			<cfif len(#taillen#) gt 0>
				<cfif #taillen_Units# is "mm">
					<cfset meas = "#meas##taillen_val#-">
				<cfelse>
					<cfset meas = "#meas##taillen_val# #taillen_Units#-">
				</cfif>
			<cfelse>
				<cfset meas="#meas#X-">
			</cfif>
			
			<cfif len(#hf#) gt 0>
				<cfif #hf_Units# is "mm">
					<cfset meas = "#meas##hf_val#-">
				<cfelse>
					<cfset meas = "#meas##hf_val# #hf_Units#-">
				</cfif>
			<cfelse>
				<cfset meas="#meas#X-">
			</cfif>
	
			<cfif len(#efn#) gt 0>
				<cfif #efn_Units# is "mm">
					<cfset meas = "#meas##efn_val#-">
				<cfelse>
					<cfset meas = "#meas##efn_val# #efn_Units#=">
				</cfif>
			<cfelse>
				<cfset meas="#meas#X=">
			</cfif>
			
			<cfif len(#weight#) gt 0>
				<cfif #weight_Units# is "g">
					<cfset meas = "#meas##weight_val#">
				<cfelse>
					<cfset meas = "#meas##weight_val# #weight_Units#">
				</cfif>
			<cfelse>
				<cfset meas="#meas#X">
			</cfif>
 	<cfset oneLine = "#cat_num##chr(9)##Scientific_Name##chr(9)##af##chr(9)##coordinates##chr(9)##geog##chr(9)##verbatim_date##chr(9)##sexcode##chr(9)##thisColl##chr(9)##parts##chr(9)##FieldNum##chr(9)##meas##chr(9)##Accession#">
<!----
<cfif #detail_level# gte 2>
	<cfset oneLine = "#oneLine##chr(9)##af_num##chr(9)##other_ids##chr(9)##Accession##chr(9)##Collectors#">
</cfif>
<cfif #detail_level# gte 2>
				<cfif #encumbrance_action# does not contain "coordinates">
					<cfset oneLine = "#oneLine##chr(9)#">
				<cfelse>
					<cfif isdefined("client.rights") AND #client.rights# contains "student0">
						<cfset oneLine = "#oneLine##chr(9)##verbatimLatitude##chr(9)
						##verbatimLongitude#">
					<cfelse>
						<cfset oneLine = "#oneLine##chr(9)#Masked#chr(9)#Masked">
					</cfif>
				</cfif>
				
</cfif>
<cfif #detail_level# gte 4>
				<cfif #encumbrance_action# does not contain "coordinates">
					<cfset oneLine = "#oneLine##chr(9)##decimallatitude##chr(9)#
					#decimallongitude##chr(9)##max_error##chr(9)##datum##chr(9)##orig
					_lat_long_units##chr(9)##lat_long_determiner##chr(9)##lat_long_ref_
					source##chr(9)##lat_long_remarks#">
				<cfelse>
					<cfif isdefined("client.rights") AND #client.rights# contains "student0">
						<cfset oneLine = "#oneLine##chr(9)##decimallatitude##chr(9)#
						#decimallongitude##chr(9)##max_error##chr(9)##datum##chr(9)#
						
						#orig_lat_long_units##chr(9)##lat_long_determiner##chr(9)#
						lat_long_ref_source##chr(9)##lat_long_remarks#">
					<cfelse>
						<cfset oneLine = "#oneLine##chr(9)#Masked#chr(9)#Masked#ch
						r(9)##max_error##chr(9)##datum##chr(9)##orig_lat_long_units##ch
						r(9)##lat_long_determiner##chr(9)##lat_long_ref_source##chr(9)##lat_long_remarks#">
					</cfif>
				</cfif>
	
</cfif>
<cfif #detail_level# gte 4>
	<cfset oneLine = "#oneLine##chr(9)##CONTINENT_OCEAN#">
</cfif>
<cfset oneLine = "#oneLine##chr(9)##Country##chr(9)##State_Prov#">
<cfif #detail_level# gte 4>
	<cfset oneLine = "#oneLine##chr(9)##sea#">
</cfif>
<cfif #detail_level# gte 2>
	<cfset oneLine = "#oneLine##chr(9)##quad##chr(9)##feature##chr(9)##county##chr(9)##island_group##chr(9)##island##chr(9)##Associated_Species##chr(9)##habitat#">
</cfif> 
<cfset oneLine = "#oneLine##chr(9)##spec_locality##chr(9)##verbatim_date#">
<cfif #detail_level# gte 3>
	<cfif #began_date# is #ended_date# AND len(#began_date#) gt 0>
		<cfset collDate = "#dateformat(began_date,"dd mmm yyyy")#">
	<cfelseif len(#ended_date#) is 0 AND len(#began_date#) is 0>
		<cfset collDate = "Not recorded.">
	<cfelse>
		<cfset collDate = "#dateformat(began_date,"dd mmm yyyy")# - #dateformat(ended_date,"dd mmm yyyy")#">
	</cfif>
	<cfset oneLine = "#oneLine##chr(9)##collDate#">
</cfif>
<cfset oneLine = "#oneLine##chr(9)####chr(9)#">
<cfif #detail_level# gte 3>
		<cfloop list="#attList#" index="val">
			<cfset thisName = #val#>
			<cfset thisName = #replace(thisName," ","_","all")#>
			<cfset thisName = #replace(thisName,"-","_","all")#>
			<cfset thisName = #left(thisName,20)#>
			
			<cfif #thisName# is not "sex">
				<Cfset thisVal =#evaluate("getBasic." &  thisName)#>
				<cfset oneLine = "#oneLine##chr(9)##thisVal#">
			</cfif>
		</cfloop>
	</cfif>
	
	<cfif #detail_level# gte 4>
		<cfloop list="#attList#" index="val">
			<cfset thisName = #val#>
			<cfset thisName = #replace(thisName," ","_","all")#>
			<cfset thisName = #replace(thisName,"-","_","all")#>
			<cfset thisName = #left(thisName,20)#>
			<cfset thisName = "#thisName#_Detail">
			<cfset thisVal = #evaluate("getBasic." &  thisName)#>
			<cfset oneLine = "#oneLine##chr(9)##thisVal#">
			
		</cfloop>
		<cfloop list="#OIDlist#" index="val">
		
			<cfset thisNum = #val#>
			<cfset thisNum = #replace(thisNum," ","_","all")#>
			<cfset thisNum = #replace(thisNum,"-","_","all")#>
			<cfset thisNum = #replace(thisNum,".","_","all")#>
			<cfset thisNum = #right(thisNum,20)#>
			<cfif #left(thisNum,1)# is "_">
				<cfset thisNum = #replace(thisNum,"_","","first")#>
			</cfif>
			<cfset thisVal =#evaluate("getBasic." &  thisNum)#>
			<cfset oneLine = "#oneLine##chr(9)##thisVal#">
			
		</cfloop>
		
	</cfif>
<cfif #detail_level# gte 2>
	<cfset oneLine = "#oneLine##chr(9)##coll_object_remarks##chr(9)##coll_obj_disposition#">
</cfif>

<cfset oneLine = trim(#oneLine#)>
	<cffile action="append" file="#dlPath##dlFile#" addnewline="yes" output="#oneLine#">
	
	
	<cfoutput>
	<cfset downloadFile = "/download/#dlFile#">
	<cflocation url="download_agree.cfm?cnt=#cnt.recordcount#&downloadFile=#downloadFile#">
	</cfoutput>
	
	
	
	
	---->
	<cfset oneLine = trim(#oneLine#)>
	<cffile action="append" file="#dlPath##dlFile#" addnewline="yes" output="#oneLine#">
	</cfoutput>
	<cfoutput>
	<cfset downloadFile = "/download/#dlFile#">
	<cflocation url="download_agree.cfm?cnt=#cnt.recordcount#&downloadFile=#downloadFile#">
	</cfoutput>
</cfif>
	
<cfinclude template = "/includes/_footer.cfm">