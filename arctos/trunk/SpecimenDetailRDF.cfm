<cfinclude template="/includes/functionLib.cfm">
<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select 
		filtered_flat.lastdate LAST_EDIT_DATE,
		filtered_flat.collection_object_id,
		guid,
		collection,
		began_date,
		ended_date,
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
		VERBATIM_coordinates,
		COORDINATEUNCERTAINTYINMETERS,
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
		editedPerson.agent_name EditedBy,
		COLL_OBJECT_ENTERED_DATE,
		georeference_source,
		georeference_protocol
	from 
		filtered_flat,
		coll_object,
		preferred_agent_name enteredPerson,
		preferred_agent_name editedPerson		
	where 
		filtered_flat.collection_object_id = coll_object.collection_object_id AND
		coll_object.entered_person_id = enteredPerson.agent_id AND
		coll_object.last_edited_person_id = editedPerson.agent_id (+) AND
	upper(guid)=<cfqueryparam value="#ucase(guid)#" CFSQLType="CF_SQL_VARCHAR" maxLength="25">
</cfquery>
<cfif d.recordcount is not 1>
	<div class="error">fail</div>
	<cfabort>
</cfif>
<cfquery name="media" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select
		media_id 
	from 
		media_relations 
	where 
		media_relationship like '% cataloged_item' and
		RELATED_PRIMARY_KEY=<cfqueryparam value="#d.collection_object_id#" CFSQLType="CF_SQL_INTEGER">
</cfquery>
<cfoutput>
<cfcontent type="application/rdf+xml; charset=ISO-8859-1">
<cfsavecontent variable="myRDF">
<?xml version="1.0" encoding="utf-8"?>
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns##"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:tap="http://rs.tdwg.org/tapir/1.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:hyam="http://hyam.net/tapir2sw##"
	xmlns:dwc="http://rs.tdwg.org/dwc/terms/" xmlns:dwcc="http://rs.tdwg.org/dwc/curatorial/"
	xmlns:dc="http://purl.org/dc/terms/"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos##">
	<!-- 
		So, we pretty much just made this all up. It's a
		nifty way to test out content negotiation, but we have no idea
		if the RDF is actually useful to anyone.
		If you have actual use for rdf, and would like us to do something different,
		just drop up an email (you probably know who we are, right?) or fill
		out the contact form at http://arctos.database.museum/contact.cfm
		We'd love to hear your feedback. Or just tell us you found this thing.
		
		This document in no way represents all information available from Arctos.
	-->
    <rdf:Description rdf:about="#application.serverRootUrl#/guid/#guid#">
        <dc:creator>#d.EnteredBy#</dc:creator>
        <dc:created>#dateformat(d.COLL_OBJECT_ENTERED_DATE,"yyyy-mm-dd")#</dc:created>
        <dc:hasVersion rdf:resource="#application.serverRootUrl#/guid/#guid#" />
    </rdf:Description>
    <!-- This is metadata about this specimen -->
    <rdf:Description rdf:about="#application.serverRootUrl#/guid/#guid#">
		<dc:title>#d.guid# - #d.collection# #d.cat_num# #d.scientific_name#</dc:title>
		<dc:description>#d.collection# #d.cat_num# #d.scientific_name#</dc:description>
		<geo:Point>
			<geo:lat>#d.dec_lat#</geo:lat>
			<geo:long>#d.dec_long#</geo:long>
		</geo:Point>
	  	<!-- Assertions based on experimental version of Darwin Core -->
		<dc:modified>#dateformat(d.last_edit_date,"yyyy-mm-dd")#</dc:modified>
		<dwc:SampleID>#application.serverRootUrl#/guid/#d.guid#</dwc:SampleID>
		<dwc:BasisOfRecord>#d.BasisOfRecord#</dwc:BasisOfRecord>
		<dwc:InstitutionCode>#d.institution_acronym#</dwc:InstitutionCode>
		<dwc:CollectionCode>#d.collection_cde#</dwc:CollectionCode>
		<dwc:CatalogNumber>#d.cat_num#</dwc:CatalogNumber>
		<dwc:ScientificName>#d.scientific_name#</dwc:ScientificName>
		<dwc:HigherTaxon>#d.FULL_TAXON_NAME#</dwc:HigherTaxon>
		<dwc:Kingdom>#d.KINGDOM#</dwc:Kingdom>
		<dwc:Phylum>#d.PHYLUM#</dwc:Phylum>
		<dwc:Class>#d.PHYLCLASS#</dwc:Class>
		<dwc:Order>#d.PHYLORDER#</dwc:Order>
		<dwc:Family>#d.FAMILY#</dwc:Family>
		<dwc:Genus>#d.GENUS#</dwc:Genus>
		<dwc:Species>#d.SPECIES#</dwc:Species>
		<dwc:Subspecies>#d.SUBSPECIES#</dwc:Subspecies>
		<dwc:IdentifiedBy>#d.IDENTIFIEDBY#</dwc:IdentifiedBy>
		<dwc:HigherGeography>#d.higher_geog#</dwc:HigherGeography>
		<dwc:ContinentOcean>#d.CONTINENT_OCEAN#</dwc:ContinentOcean>
		<dwc:Country>#d.country#</dwc:Country>
		<dwc:StateProvince>#d.state_prov#</dwc:StateProvince>
		<dwc:IslandGroup>#d.ISLAND_GROUP#</dwc:IslandGroup>
		<dwc:Island>#d.ISLAND#</dwc:Island>
		<dwc:County>#d.COUNTY#</dwc:County>
		<dwc:Locality>#d.spec_locality#</dwc:Locality>
		<dwc:DecimalLongitude>#d.dec_lat#</dwc:DecimalLongitude>
		<dwc:DecimalLatitude>#d.dec_long#</dwc:DecimalLatitude>
		<dwc:HorizontalDatum>#d.DATUM#</dwc:HorizontalDatum>
		<dwc:OriginalCoordinateSystem>#d.ORIG_LAT_LONG_UNITS#</dwc:OriginalCoordinateSystem>
		<dwc:VerbatimCoordinates>#d.VERBATIM_coordinates#</dwc:VerbatimCoordinates>
		<dwc:GeoreferenceSource>#d.georeference_source#</dwc:GeoreferenceSource>
		<dwc:GeoreferenceProtocol>#d.georeference_protocol#</dwc:GeoreferenceProtocol>
		<dwc:CoordinateUncertaintyInMeters>#d.COORDINATEUNCERTAINTYINMETERS#</dwc:CoordinateUncertaintyInMeters>
		<dwc:MinimumElevationInMeters>#d.MIN_ELEV_IN_M#</dwc:MinimumElevationInMeters>
		<dwc:MaximumElevationInMeters>#d.MAX_ELEV_IN_M#</dwc:MaximumElevationInMeters>
		<dwc:VerbatimElevation>#d.VERBATIMELEVATION#</dwc:VerbatimElevation>
		<dwc:MinimumDepthInMeters>#d.MIN_DEPTH_IN_M#</dwc:MinimumDepthInMeters>
		<dwc:MaximumDepthInMeters>#d.MAX_DEPTH_IN_M#</dwc:MaximumDepthInMeters>
		<dwc:TypeStatus>#d.TYPESTATUS#</dwc:TypeStatus>
		<dwc:Sex>#d.SEX#</dwc:Sex>
		<dwc:Preparations>#d.PARTS#</dwc:Preparations>
		<dwc:IndividualCount>#d.INDIVIDUALCOUNT#</dwc:IndividualCount>
		<dwc:AgeClass>#d.AGE_CLASS#</dwc:AgeClass>
		<dwc:OtherCatalogNumbers>#d.OTHERCATALOGNUMBERS#</dwc:OtherCatalogNumbers>
		<dwc:GenBankNum>#d.GENBANKNUM#</dwc:GenBankNum>
		<dwc:RelatedCatalogedItems>#d.RELATEDCATALOGEDITEMS#</dwc:RelatedCatalogedItems>
		<dwc:Collector>#d.collectors#</dwc:Collector>
		<dwc:EarliestDateCollected>#d.began_date#</dwc:EarliestDateCollected>
		<dwc:LatestDateCollected>#d.ended_date#</dwc:LatestDateCollected>
		<dwc:VerbatimCollectingDate>#d.VERBATIM_DATE#</dwc:VerbatimCollectingDate>
		<dwc:Remarks>#d.REMARKS#</dwc:Remarks>
		<cfif media.recordcount gt 0><dwc:ImageURL>#application.serverRootUrl#/MediaSearch.cfm?action=search&media_id=#valuelist(media.media_id)#</dwc:ImageURL></cfif>
    </rdf:Description>
</rdf:RDF>
</cfsavecontent>
<cfset myRDF=replace(myRDF,'&','&amp;','all')>
<cfset myRDF=REReplace( myRDF, "^[^<]*", "", "all" )>
#myRDF#
</cfoutput>