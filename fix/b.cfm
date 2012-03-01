<cfinclude template="/includes/functionLib.cfm">
<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
		filtered_flat.LAST_EDIT_DATE,
		RelatedInformation,
		BASISOFRECORD,
		INSTITUTION_ACRONYM,
		COLLECTION_CDE,
		CAT_NUM,
		COLLECTORS,
		YEAR,
		MONTH,
		DAY,
		VERBATIM_DATE,
		DAYOFYEAR,
		HIGHER_GEOG,
		CONTINENT_OCEAN,
		ISLAND_GROUP,
		ISLAND,
		COUNTRY,
		STATE_PROV,
		COUNTY,
		SPEC_LOCALITY,
		DEC_LAT,
		DEC_LONG,
		DATUM,
		ORIG_LAT_LONG_UNITS,
		VERBATIMLATITUDE,
		VERBATIMLONGITUDE,
		GEOREFMETHOD,
		COORDINATEUNCERTAINTYINMETERS,
		LAT_LONG_REMARKS,
		MIN_ELEV_IN_M,
		MAX_ELEV_IN_M,
		VERBATIMELEVATION,
		MIN_DEPTH_IN_M,
		MAX_DEPTH_IN_M,
		SCIENTIFIC_NAME,
		FULL_TAXON_NAME,
		KINGDOM,
		PHYLUM,
		PHYLCLASS,
		PHYLORDER,
		FAMILY,
		GENUS,
		SPECIES,
		SUBSPECIES,
		AUTHOR_TEXT,
		IDENTIFICATIONMODIFIER,
		IDENTIFIEDBY,
		TYPESTATUS,
		SEX,
		PARTS,
		INDIVIDUALCOUNT,
		AGE_CLASS,
		GENBANKNUM,
		OTHERCATALOGNUMBERS,
		RELATEDCATALOGEDITEMS,
		REMARKS,
		enteredPerson.agent_name EnteredBy,
		editedPerson.agent_name EditedBy							
	from 
		filtered_flat,
		coll_object,
		preferred_agent_name enteredPerson,
		preferred_agent_name editedPerson		
	where 
		filtered_flat.collection_object_id = coll_object.collection_object_id AND
		coll_object.entered_person_id = enteredPerson.agent_id AND
		coll_object.last_edited_person_id = editedPerson.agent_id (+) AND
	upper(guid)='#ucase(guid)#'		
</cfquery>
<cfdump var="#d#">
<cfoutput>

<cfset mappings ="
		DateLastModified:LAST_EDIT_DATE|
		RelatedInformation:RelatedInformation|
		BasisOfRecord:BASISOFRECORD|
		InstitutionCode:INSTITUTION_ACRONYM|
		CollectionCode:COLLECTION_CDE|
		CatalogNumberText:CAT_NUM|
		CatalogNumberNumeric:CAT_NUM|
		Collector:COLLECTORS|
		CollectorNumber:COLLECTORNUMBER|
		FieldNumber:FIELD_NUM|
		YearCollected:YEAR|
		MonthCollected:MONTH|
		DayCollected:DAY|
		TimeCollected:EMPTYSTRING|
		VerbatimCollectingDate:VERBATIM_DATE|
		FieldNotes:FIELDNOTESURL|
		JulianDay:DAYOFYEAR
		HigherGeography:HIGHER_GEOG|
		ContinentOcean:CONTINENT_OCEAN|IslandGroup:ISLAND_GROUP|
		Island:ISLAND|Country:COUNTRY|StateProvince:STATE_PROV|County:COUNTY|Locality:SPEC_LOCALITY|DecimalLatitude:DEC_LAT|
		DecimalLongitude:DEC_LONG|HorizontalDatum:DATUM|OriginalCoordinateSystem:ORIG_LAT_LONG_UNITS|VerbatimLatitude:VERBATIMLATITUDE|
		VerbatimLongitude:VERBATIMLONGITUDE|GeorefMethod:GEOREFMETHOD|CoordinateUncertaintyInMeters:COORDINATEUNCERTAINTYINMETERS|
		LatLongComments:LAT_LONG_REMARKS|BoundingBox:EMPTYSTRING|MinimumElevationInMeters:MIN_ELEV_IN_M|
									MaximumElevationInMeters:MAX_ELEV_IN_M|VerbatimElevation:VERBATIMELEVATION|MinimumDepthInMeters:MIN_DEPTH_IN_M|
										MaximumDepthInMeters:MAX_DEPTH_IN_M|VerbatimDepth:EMPTYSTRING|ScientificName:SCIENTIFIC_NAME
HigherTaxon:FULL_TAXON_NAME|Kingdom:KINGDOM|Phylum:PHYLUM|Class:PHYLCLASS|Order:PHYLORDER|Family:FAMILY|Genus:GENUS|Species:SPECIES|
Subspecies:SUBSPECIES|ScientificNameAuthor:AUTHOR_TEXT|IdentificationModifier:IDENTIFICATIONMODIFIER|IdentifiedBy:IDENTIFIEDBY|
YearIdentified:EMPTYSTRING|MonthIdentified:EMPTYSTRING|DayIdentified:EMPTYSTRING|TypeStatus:TYPESTATUS|Sex:SEX|Preparations:PARTS|Tissues:EMPTYSTRING|
											IndividualCount:INDIVIDUALCOUNT|AgeClass:AGE_CLASS|GenBankNum:GENBANKNUM|OtherCatalogNumbers:OTHERCATALOGNUMBERS|RelatedCatalogedItems:RELATEDCATALOGEDITEMS|
										Remarks:REMARKS">

  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns##"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:tap="http://rs.tdwg.org/tapir/1.0"
        xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:hyam="http://hyam.net/tapir2sw##"
        xmlns:dwc="http://rs.tdwg.org/dwc/terms/" xmlns:dwcc="http://rs.tdwg.org/dwc/curatorial/"
        xmlns:dc="http://purl.org/dc/terms/"
        xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos##">

    <!--This is metadata about this metadata document-->
    <rdf:Description
        rdf:about="#application.serverRootUrl#/guid/#guid#">
        <dc:creator>dustymc</dc:creator>
        <dc:created>#now()#</dc:created>
    
        <dc:hasVersion rdf:resource="#application.serverRootUrl#/guid/#guid#" />
    
    </rdf:Description>
    

    <!--This is metadata about this specimen-->
    <rdf:Description rdf:about="#application.serverRootUrl#/guid/#guid#">
	
	
	
	 <dc:title>#d.guid#: #d.collection# #d.cat_num# #d.scientific_name#</dc:title>
	
	<dc:description>#d.collection# #d.cat_num# #d.scientific_name#</dc:description>

	<cfif (d.verbatim_date is d.began_date) AND (d.verbatim_date is d.ended_date)>
		<cfset thisDate = #d.verbatim_date#>
	<cfelseif (
		(d.verbatim_date is not d.began_date) OR
			(d.verbatim_date is not d.ended_date)
		) AND d.began_date is d.ended_date>
		<cfset thisDate = "#d.verbatim_date# (#d.began_date#)">
	<cfelse>
		<cfset thisDate = "#d.verbatim_date# (#d.began_date# - #d.ended_date#)">
	</cfif>
					
					
                
                    <dc:created>#thisDate#</dc:created>
                
        <cfif len(d.dec_lat) gt 0>
		 <geo:Point>
            <geo:lat>#d.dec_lat#</geo:lat>
            <geo:long>#d.dec_long#</geo:long>
        </geo:Point>
		</cfif>
               
                
        <!-- Assertions based on experimental version of Darwin Core -->
        <dwc:SampleID>#application.serverRootUrl#/guid/#d.guid#</dwc:SampleID>
        <dc:modified>#d.last_edit_date#</dc:modified>
        <dwc:BasisOfRecord>Specimen</dwc:BasisOfRecord>
        <dwc:InstitutionCode>#d.institution_acronym#</dwc:InstitutionCode>
        <dwc:CollectionCode>#d.collection_cde#</dwc:CollectionCode>
        <dwc:CatalogNumber>#d.cat_num#</dwc:CatalogNumber>
        <dwc:ScientificName>#d.scientific_name#</dwc:ScientificName>
      
        <dwc:HigherGeography>#d.higher_geog#</dwc:HigherGeography>

            <dwc:Country>#d.country#</dwc:Country>
        
            <dwc:StateProvince>#d.state_prov#</dwc:StateProvince>
            
            
            <dwc:Locality>#d.spec_locality#</dwc:Locality>
            
            <dwc:DecimalLongitude>#d.dec_lat#</dwc:DecimalLongitude>
        <dwc:DecimalLatitude>#d.dec_long#</dwc:DecimalLatitude>
           
        
            <dwc:MinimumElevationInMeters></dwc:MinimumElevationInMeters>
        <dwc:MaximumElevationInMeters></dwc:MaximumElevationInMeters>
        
            <dwc:EarliestDateCollected>#d.began_date#</dwc:EarliestDateCollected>
        
            <dwc:Collector>#d.collectors#</dwc:Collector>
            
    </rdf:Description>
    
</rdf:RDF>  
	
	
	
	
</cfoutput>



<cfabort>



<cfcontent type="application/rdf+xml; charset=ISO-8859-1">






<cfif isdefined("guid")>
	<cfset checkSql(guid)>
	<cfset sql="select collection_object_id from 
					#session.flatTableName#
				WHERE
					upper(guid)='#ucase(guid)#'">
	<cfset checkSql(sql)>
	<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(sql)#
	</cfquery>
	<cfif isdefined("c.collection_object_id") and len(c.collection_object_id) gt 0>
		<cfset collection_object_id=c.collection_object_id>
	<cfelse>
		<cfinclude template="/errors/404.cfm">
		<cfabort>
	</cfif>
<cfelse>
	guid required<cfabort>
</cfif>

<cfset detSelect = "
	SELECT
		cataloged_item.collection_object_id as collection_object_id,
		cataloged_item.cat_num,
		collection.collection_cde,
		cataloged_item.accn_id,
		collection.collection,
			collection.institution_acronym,
		identification.scientific_name,
		identification.identification_remarks,
		identification.identification_id,
		identification.made_date,
		identification.nature_of_id,
		collecting_event.collecting_event_id,
		collecting_event.coll_event_remarks,
		case when 
			#oneOfUs# != 1 and concatencumbrances(cataloged_item.collection_object_id) like '%mask year collected%' then
				replace(began_date,substr(began_date,1,4),'8888')
		else 
			collecting_event.began_date  
		end began_date,
		case when 
			#oneOfUs# != 1 and concatencumbrances(cataloged_item.collection_object_id) like '%mask year collected%' then
				replace(ended_date,substr(ended_date,1,4),'8888')
		else 
			collecting_event.ended_date  
		end ended_date,
		case when 
			#oneOfUs# != 1 and concatencumbrances(cataloged_item.collection_object_id) like '%mask year collected%' then
				'Masked'
		else 
			collecting_event.verbatim_date  
		end verbatim_date,
		collecting_event.habitat_desc,
		locality.locality_id,
		locality.minimum_elevation,
		locality.maximum_elevation,
		locality.orig_elev_units,
		locality.spec_locality,		
		case when 
			#oneOfUs# != 1 and 
				concatencumbrances(cataloged_item.collection_object_id) like '%mask coordinates%' and
					accepted_lat_long.orig_lat_long_units is not null
				then 'Masked'
		else
			decode(accepted_lat_long.orig_lat_long_units,
				'decimal degrees',to_char(accepted_lat_long.dec_lat) || '&deg; ',
				'deg. min. sec.', to_char(accepted_lat_long.lat_deg) || '&deg; ' ||
					to_char(accepted_lat_long.lat_min) || '&acute; ' || 
					to_char(accepted_lat_long.lat_sec) || '&acute;&acute; ' || accepted_lat_long.lat_dir,
				'degrees dec. minutes', to_char(accepted_lat_long.lat_deg) || '&deg; ' || 
					to_char(accepted_lat_long.dec_lat_min) || '&acute; ' || accepted_lat_long.lat_dir
			) 
		end VerbatimLatitude,
		case when 
			#oneOfUs# != 1 and 
				concatencumbrances(cataloged_item.collection_object_id) like '%mask coordinates%' and
					accepted_lat_long.orig_lat_long_units is not null
				then 'Masked'
		else
			decode(accepted_lat_long.orig_lat_long_units,
				'decimal degrees',to_char(accepted_lat_long.dec_long) || '&deg;',
				'deg. min. sec.', to_char(accepted_lat_long.long_deg) || '&deg; ' || 
					to_char(accepted_lat_long.long_min) || '&acute; ' || 
					to_char(accepted_lat_long.long_sec) || '&acute;&acute; ' || accepted_lat_long.long_dir,
				'degrees dec. minutes', to_char(accepted_lat_long.long_deg) || '&deg; ' || 
					to_char(accepted_lat_long.dec_long_min) || '&acute; ' || accepted_lat_long.long_dir
			)
		end VerbatimLongitude,
		accepted_lat_long.dec_lat,
		accepted_lat_long.dec_long,
		accepted_lat_long.max_error_distance,
		accepted_lat_long.max_error_units,
		accepted_lat_long.determined_date latLongDeterminedDate,
		accepted_lat_long.lat_long_ref_source,
		accepted_lat_long.lat_long_remarks,
		accepted_lat_long.datum,
		latLongAgnt.agent_name latLongDeterminer,
		geog_auth_rec.geog_auth_rec_id,
		geog_auth_rec.continent_ocean,
		geog_auth_rec.country,
		geog_auth_rec.state_prov,
		geog_auth_rec.quad,
		geog_auth_rec.county,
		geog_auth_rec.island,
		geog_auth_rec.island_group,
		geog_auth_rec.sea,
		geog_auth_rec.HIGHER_GEOG,
		geog_auth_rec.feature,
		coll_object.coll_object_entered_date,
		coll_object.last_edit_date,
		coll_object.flags,
		coll_object_remark.coll_object_remarks,
		coll_object_remark.disposition_remarks,
		coll_object_remark.associated_species,
		coll_object_remark.habitat,
		enteredPerson.agent_name EnteredBy,
		editedPerson.agent_name EditedBy,
		accn_number accession,
		concatencumbrances(cataloged_item.collection_object_id) concatenatedEncumbrances,
		concatEncumbranceDetails(cataloged_item.collection_object_id) encumbranceDetail,
		locality.locality_remarks,
		verbatim_locality,
		min_depth,
		max_depth,
		depth_units,
		collecting_method,
		collecting_source,
			concatcoll(cataloged_item.collection_object_id) collectors
	FROM 
		cataloged_item,
		collection,
		identification,
		collecting_event,
		locality,
		accepted_lat_long,
		preferred_agent_name latLongAgnt,
		geog_auth_rec,
		coll_object,
		coll_object_remark,
		preferred_agent_name enteredPerson,
		preferred_agent_name editedPerson,
		accn,
		trans
	WHERE 
		cataloged_item.collection_id = collection.collection_id AND
		cataloged_item.collection_object_id = identification.collection_object_id AND
		identification.accepted_id_fg = 1 AND
		cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND
		collecting_event.locality_id = locality.locality_id  AND
		locality.locality_id = accepted_lat_long.locality_id (+) AND
		accepted_lat_long.determined_by_agent_id = latLongAgnt.agent_id (+) AND
		locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND
		cataloged_item.collection_object_id = coll_object.collection_object_id AND
		coll_object.collection_object_id = coll_object_remark.collection_object_id (+) AND
		coll_object.entered_person_id = enteredPerson.agent_id AND
		coll_object.last_edited_person_id = editedPerson.agent_id (+) AND
		cataloged_item.accn_id =  accn.transaction_id  AND
		accn.transaction_id = trans.transaction_id AND
	cataloged_item.collection_object_id = #collection_object_id#
	">
<cfset checkSql(detSelect)>
<cfquery name="one" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	#preservesinglequotes(detSelect)#
</cfquery>
<cfif one.concatenatedEncumbrances contains "mask record" and oneOfUs neq 1>
	Record masked.<cfabort>
</cfif>
<cfoutput>
    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns##"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:tap="http://rs.tdwg.org/tapir/1.0"
        xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:hyam="http://hyam.net/tapir2sw##"
        xmlns:dwc="http://rs.tdwg.org/dwc/terms/" xmlns:dwcc="http://rs.tdwg.org/dwc/curatorial/"
        xmlns:dc="http://purl.org/dc/terms/"
        xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos##">

    <!--This is metadata about this metadata document-->
    <rdf:Description
        rdf:about="#application.serverRootUrl#/guid/#guid#">
        <dc:creator>dustymc</dc:creator>
        <dc:created>#now()#</dc:created>
    
        <dc:hasVersion rdf:resource="#application.serverRootUrl#/guid/#guid#" />
    
    </rdf:Description>
    

    <!--This is metadata about this specimen-->
    <rdf:Description rdf:about="#application.serverRootUrl#/guid/#guid#">
	
	
	
	 <dc:title>#one.collection# #one.cat_num# #one.scientific_name#</dc:title>
	
	<dc:description>#one.collection# #one.cat_num# #one.scientific_name#</dc:description>

	<cfif (one.verbatim_date is one.began_date) AND (one.verbatim_date is one.ended_date)>
		<cfset thisDate = #one.verbatim_date#>
	<cfelseif (
		(one.verbatim_date is not one.began_date) OR
			(one.verbatim_date is not one.ended_date)
		) AND one.began_date is one.ended_date>
		<cfset thisDate = "#one.verbatim_date# (#one.began_date#)">
	<cfelse>
		<cfset thisDate = "#one.verbatim_date# (#one.began_date# - #one.ended_date#)">
	</cfif>
					
					
                
                    <dc:created>#thisDate#</dc:created>
                
        <cfif len(one.dec_lat) gt 0>
		 <geo:Point>
            <geo:lat>#one.dec_lat#</geo:lat>
            <geo:long>#one.dec_long#</geo:long>
        </geo:Point>
		</cfif>
               
                
        <!-- Assertions based on experimental version of Darwin Core -->
        <dwc:SampleID>#application.serverRootUrl#/guid/#guid#1</dwc:SampleID>
        <dc:modified>#one.last_edit_date#</dc:modified>
        <dwc:BasisOfRecord>Specimen</dwc:BasisOfRecord>
        <dwc:InstitutionCode>#one.institution_acronym#</dwc:InstitutionCode>
        <dwc:CollectionCode>#one.collection_cde#</dwc:CollectionCode>
        <dwc:CatalogNumber>#one.cat_num#</dwc:CatalogNumber>
        <dwc:ScientificName>#one.scientific_name#</dwc:ScientificName>
      
        <dwc:HigherGeography>#one.higher_geog#</dwc:HigherGeography>

            <dwc:Country>#one.country#</dwc:Country>
        
            <dwc:StateProvince>#one.state_prov#</dwc:StateProvince>
            
            
            <dwc:Locality>#one.spec_locality#</dwc:Locality>
            
            <dwc:DecimalLongitude>#one.dec_lat#</dwc:DecimalLongitude>
        <dwc:DecimalLatitude>#one.dec_long#</dwc:DecimalLatitude>
           
        
            <dwc:MinimumElevationInMeters></dwc:MinimumElevationInMeters>
        <dwc:MaximumElevationInMeters></dwc:MaximumElevationInMeters>
        
            <dwc:EarliestDateCollected>#one.began_date#</dwc:EarliestDateCollected>
        
            <dwc:Collector>#one.collectors#</dwc:Collector>
            
    </rdf:Description>
    
</rdf:RDF>  
	
	
	
</cfoutput>                       