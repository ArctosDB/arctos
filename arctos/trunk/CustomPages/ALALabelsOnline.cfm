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
	<table cellpadding="0" cellspacing="0" style="width:1600px; ">
	<cfset i=0>
	<cfoutput query="getData"  group="collection_object_id">
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
		<Cfset sciname = "<i>#scientific_name#</i>">
		
		<cfif len(#isChildOf.genus#) gt 0 AND len(#isChildOf.species#) gt 0>
			<Cfset sciname = "<i>#isChildOf.genus# #isChildOf.species#</i>">
			<cfif len(#isChildOf.author_text#) gt 0>
				<Cfset sciname = "#sciname# #isChildOf.author_text#">
			</cfif>
		<cfelse>
			<Cfset sciname = "<i>#scientific_name#</i>">
		</cfif>
		
		<cfif len(#infraspecific_rank#) gt 0 and len(#subspecies#) gt 0>
			<Cfset sciname = "#sciname# #infraspecific_rank# <i>#subspecies#</i>">
		</cfif>
		<cfif len(#author_text#) gt 0>
			<Cfset sciname = "#sciname# #author_text#">
		</cfif>
		<!---------------------------------------->
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
			<cfset colls = "#c1# <i>et al.</i>">
		</cfif>
		<!------------------------------------->
		<cfset coordinates = "">
	<cfif len(#verbatimLatitude#) gt 0 AND len(#verbatimLongitude#) gt 0>
		<cfset coordinates = "#verbatimLatitude# / #verbatimLongitude#">
		<cfset coordinates = replace(coordinates,"d","","all")>
		<cfset coordinates = replace(coordinates,"m","'","all")>
		<cfset coordinates = replace(coordinates,"s","''","all")>
	</cfif>
	<cfset coordinates = replace(coordinates," ","&nbsp;","all")>
		<!-------------------------------------------->
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
		<!------------------------------->
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
		<!---------------------------------->
		<cfset thisDate = "">
		<cftry>
			<cfset thisDate = #dateformat(verbatim_date,"dd mmm yyyy")#>
			<cfcatch>
				<cfset thisDate = #verbatim_date#>
			</cfcatch>
		</cftry>
	
		<cfif (i MOD 2) is 0>
			<tr>
		</cfif>
			<td>
				<table width="790"
					style="border-top-style:dotted; border-top-width:1px; border-top-color:##CCCCCC;
					border-bottom-style:dotted; border-bottom-width:1px; border-bottom-color:##CCCCCC;
					border-right-style:dotted; border-right-width:1px;  border-right-color:##CCCCCC;">
					<tr>
						<td style="height:380px; " valign="top">
							<span align="left" style="float:left; width:39%">
									<strong style="font-size:larger; ">#family#</strong>
						  	</span>
							 <span align="right" style="float:right; width:60%; text-align:right;">
								<strong style="font-size:larger; ">#state_prov#, #country#</strong>
							 </span>
							<p>&nbsp;
							<p><span style="font-weight:600; font-size:larger;">#sciname#</span></p>
							<cfif len(#identification_remarks#) gt 0>
								<br><span style="font-size:14px; ">#identification_remarks#</span>
							</cfif>
							<p><span style="font-size:larger; ">#locality#</span>
							<p><span style="font-size:14px; ">#colls# #original_field_number#</span>
							<p><span style="font-size:14px; ">#thisDate#</span>
							<cfif len(#identifier#) gt 0 OR len(#made_date#) gt 0>
								<p><span style="font-size:14px; ">Det. #identifier# #made_date#</span>
							</cfif>
							</td>
						</tr>
						<tr>
							<td style="height:20px; ">
								<div align="center">
								<cfif len(#Park_Service_catalog#) gt 0 and len(#Park_Service_catalog#) gt 0>
									<span style="font-size:larger; ">NPS Acc. #Park_Service_accession#, Cat. #Park_Service_catalog#</span>
									<br>
								</cfif>
								
								
									<font size="+1">Herbarium, University of Alaska Museum (ALA) accession <strong>#ALAAC_number#</strong></font>
								</div>
								<span style="float:right ">
									<font size="-2">#number_of_labels#</font>
								</span>
								
							</td>
						</tr>
				</table>
			</td>
		<cfif (i MOD 2)	>
			</tr>
		</cfif>
<cfset i=#i#+1>
</cfoutput>
</table>
<!----
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

---->