<cfoutput>
<cfquery name="colls" datasource="uam_god">
	select * from collection	
</cfquery>
<cfset mappings = "GlobalUniqueIdentifier:GUID|DateLastModified:LAST_EDIT_DATE|BasisOfRecord:BASISOFRECORD|InstitutionCode:INSTITUTION_ACRONYM|CollectionCode:COLLECTION_CDE|CatalogNumber:CAT_NUM|CatalogNumberText:CAT_NUM|InformationWithheld:ENCUMBRANCES|Remarks:REMARKS|ScientificName:SCIENTIFIC_NAME|HigherTaxon:FULL_TAXON_NAME|Kingdom:KINGDOM|Phylum:PHYLUM|Class:PHYLCLASS|Order:PHYLORDER|Family:FAMILY|Genus:GENUS|SpecificEpithet:SPECIES|Species:SPECIES|InfraspecificRank:INFRASPECIFIC_RANK|InfraspecificEpithet:SUBSPECIES|AuthorYearOfScientificName:AUTHOR_TEXT|NomenclaturalCode:NOMENCLATURAL_CODE|IdentificationQualifier:IDENTIFICATIONMODIFIER|HigherGeography:HIGHER_GEOG|Continent:CONTINENT_OCEAN|IslandGroup:ISLAND_GROUP|Island:ISLAND|Country:COUNTRY|StateProvince:STATE_PROV|County:COUNTY|Locality:SPEC_LOCALITY|MinimumElevationInMeters:MIN_ELEV_IN_M|MaximumElevationInMeters:MAX_ELEV_IN_M|MinimumDepthInMeters:MIN_DEPTH_IN_M|MaximumDepthInMeters:MAX_DEPTH_IN_M|CollectingMethod:COLLECTING_METHOD|ValidDistributionFlag:COLLECTING_SOURCE|EarliestDateCollected:BEGAN_DATE|LatestDateCollected:ENDED_DATE|DayOfYear:DAYOFYEAR|Collector:COLLECTORS|Sex:SEX|LifeStage:AGE_CLASS|Attributes:ATTRIBUTES|ImageURL:IMAGEURL|RelatedInformation:SPECIMENDETAILURL|CatalogNumberNumeric:CAT_NUM|IdentifiedBy:IDENTIFIEDBY|DateIdentified:MADE_DATE|CollectorNumber:COLLECTORNUMBER|FieldNumber:FIELD_NUM|FieldNotes:FIELDNOTESURL|VerbatimCollectingDate:VERBATIM_DATE|VerbatimElevation:VERBATIMELEVATION|Preparations:PARTS|TypeStatus:TYPESTATUS|GenBankNumber:GENBANKNUM|OtherCatalogNumbers:OTHERCATALOGNUMBERS|RelatedCatalogedItems:RELATEDCATALOGEDITEMS|Disposition:COLL_OBJ_DISPOSITION|IndividualCount:INDIVIDUALCOUNT|DecimalLatitude:DEC_LAT|DecimalLongitude:DEC_LONG|GeodeticDatum:DATUM|CoordinateUncertaintyInMeters:COORDINATEUNCERTAINTYINMETERS|VerbatimLatitude:VERBATIMLATITUDE|VerbatimLongitude:VERBATIMLONGITUDE|VerbatimCoordinateSystem:ORIG_LAT_LONG_UNITS|GeoreferenceProtocol:GEOREFMETHOD|GeoreferenceSources:LAT_LONG_REF_SOURCE|GeoreferenceVerificationStatus:VERIFICATIONSTATUS|GeoreferenceRemarks:LAT_LONG_REMARKS">
<!---- may want to put these in a table at some point, for now we can just set them here --->
<cfif #cgi.HTTP_HOST# contains "database.museum">
	<cfset constr = "db.arctos.database.museum:1522">
	<cfset database = "arctos">
	<cfset tableName = "DIGIR_FILTERED_FLAT">
	<cfset filePath = "/../ht_restricted/DiGIRprov/config/">
<cfelse>
	<cfabort>
	<!----------- add collections here ----------------------->
</cfif>
<cfset data = '<?xml version="1.0"?>'>
<cfset data = '#data#<resources>
'>
<cfloop query="colls">
<cfset thisCollection = "#lcase(institution_acronym)#_#lcase(collection_cde)#">
<cfset data = '#data#<resource name="#thisCollection#" configFile="#thisCollection#.xml"/>
'>
</cfloop>
<cfset data = '#data#</resources>'>
<cfset fileName = "#filePath#resources.xml">

<cffile action="write" file="#application.webDirectory##fileName#" addnewline="yes" output="#data#" mode="777">


<cfloop query="colls">
	<cfset thisCollection = "#lcase(institution_acronym)#_#lcase(collection_cde)#">
	<cfset fileName = "#filePath##thisCollection#.xml">
	<cfset data = '<?xml version="1.0" encoding="utf-8" ?>
	'>
	<cfset data = '#data#<configuration>
	'>
	<cfset data = '#data#<datasource type="SQL" constr="#constr#" uid="digir_query" pwd="digir_query" database="#database#" dbtype="oci805" encoding="ISO-8859-1"/>
	'>
	<cfset data = '#data#<table name="#tableName#" key="COLLECTION_OBJECT_ID"/>
	'>
	<cfset data = '#data#<filter>
	'>
	<cfset data = '#data#<equals>
	'>
	<cfset data = '#data#<term table="DIGIR_FILTERED_FLAT" field="COLLECTION_ID" type="NUMERIC">#COLLECTION_ID#</term>
	'>
	<cfset data = '#data#</equals>
	'>
	<cfset data = '#data#</filter>
	'>
	<cfset data = '#data#<concepts xmlns:darwin="http://digir.net/schema/conceptual/darwin/2003/1.0">
	'>
	<cfset i=1>
	<cfloop list="#mappings#" index="p" delimiters="|">
		<cfset dwcName = listgetat(p,1,":")>
		<cfset fieldName = listgetat(p,2,":")>
		<!---
		p:#p#<br><cfflush>
		
		dwcName:#dwcName#<br><cfflush>
		
		fieldName:#fieldName#<br><cfflush>
		--->
		<cfif #dwcName# is "CatalogNumberNumeric"
			OR #dwcName# is "YearCollected"
			OR #dwcName# is "MonthCollected"
			OR #dwcName# is "DayCollected"
			OR #dwcName# is "DecimalLatitude"
			OR #dwcName# is "DecimalLongitude"
			OR #dwcName# is "CoordinateUncertaintyInMeters"
			OR #dwcName# is "MinimumElevationInMeters"
			OR #dwcName# is "MaximumElevationInMeters"
			OR #dwcName# is "IndividualCount">	
			<cfset thisType = "numeric">
		<cfelse>
			<cfset thisType = "text">
		</cfif>
		<cfset data = '#data#<concept searchable="1" returnable="1" name="darwin:#dwcName#" type="#thisType#" 
			table="DIGIR_FILTERED_FLAT" field="#fieldName#" zid="#i#"/>
			'>
		<cfset i=#i#+1>
	</cfloop>
	<cfset data = '#data#</concepts>
	'>
	<cfset data = '#data#<metadata>
		'>
	<cfquery name="TechContact" datasource="uam_god">
		select 
			agent_name,
			ADDRESS
		from
			preferred_agent_name,
			collection_contacts,
			(select agent_id, ADDRESS from electronic_address where
			ADDRESS_TYPE='e-mail') electronic_address
		where 
			preferred_agent_name.agent_id = collection_contacts.CONTACT_AGENT_ID and
			collection_contacts.CONTACT_AGENT_ID = electronic_address.AGENT_ID (+) and
			CONTACT_ROLE='technical support' and
			collection_contacts.collection_id=#collection_id#			
	</cfquery>
	<cfloop query="TechContact">
		<cfset data = '#data#<contact type="technical">
		'>
		<cfset data = '#data#<name>#agent_name#</name>
		'>
		<cfset data = '#data#<title>technical support</title>
		'>
		<cfset data = '#data#<emailAddress>#ADDRESS#</emailAddress>
		'>	
		<cfset data = '#data#</contact>
		'>
	</cfloop>
	<cfquery name="AdminContact" datasource="uam_god">
		select 
			agent_name,
			ADDRESS
		from
			preferred_agent_name,
			collection_contacts,
			(select agent_id, ADDRESS from electronic_address where
			ADDRESS_TYPE='e-mail') electronic_address
		where 
			preferred_agent_name.agent_id = collection_contacts.CONTACT_AGENT_ID and
			collection_contacts.CONTACT_AGENT_ID = electronic_address.AGENT_ID (+) and
			CONTACT_ROLE='loan request' and
			collection_contacts.collection_id=#collection_id#			
	</cfquery>
	<cfloop query="AdminContact">
		<cfset data = '#data#<contact type="administrative">
		'>
		<cfset data = '#data#<name>#agent_name#</name>
		'>
		<cfset data = '#data#<title>administrative contact</title>
		'>
		<cfset data = '#data#<emailAddress>#ADDRESS#</emailAddress>
		'>	
		<cfset data = '#data#</contact>
		'>
	</cfloop>	
	<cfset data = '#data#<conceptualSchema schemaLocation="http://bnhm.berkeley.edu/manis/DwC/darwin2jrw030315.xsd">http://digir.net/schema/conceptual/darwin/2003/1.0</conceptualSchema>
	'>

	<cfset data = '#data#<recordIdentifier>#collection#</recordIdentifier>
	'>
	<cfset data = '#data#<recordBasis>PreservedSpecimen</recordBasis>
	'>
	<cfset data = '#data#<name>#descr#</name>
	'>
	<cfset data = '#data#<abstract>#descr#</abstract>
	'>
	<cfset data = '#data#<relatedInformation>http://arctos.database.museum</relatedInformation>
	'>
	<cfset data = '#data#<keywords>#descr#</keywords>
	'>
	<cfset data = '#data#<citation>#descr#</citation>
	'>
	<cfset data = '#data#<useRestrictions>none</useRestrictions>
	'>
	<cfset data = '#data#<minQueryTermLength>1</minQueryTermLength>
	'>
	<cfset data = '#data#<maxSearchResponseRecords>25000</maxSearchResponseRecords>
	'>
	<cfset data = '#data# <maxInventoryResponseRecords>25000</maxInventoryResponseRecords>'>
	<cfset data = '#data#
	</metadata>
	'>
	<cfset data = '#data#</configuration>
	'>
	<cffile action="write" file="#application.webDirectory##fileName#" addnewline="yes" output="#data#" mode="777">
</cfloop>

<!--- now make the static stuff --->
<!--- start with providerMeta ---> 
<cfset pm='<metadata>
				<name>Arctos</name>
				<accessPoint>! set by application !</accessPoint>
				<implementation>! set by application !</implementation>
				<host>
					  <name>Arctos</name>
					  <code>Arctos</code>
					  <relatedInformation>#Application.serverRootUrl#/home.cfm</relatedInformation>
					    <contact type="administrative">
					  		<name>Dusty L. McDonald</name>
					  		<title>Programmer</title>
					  	</contact>
					  	<contact type="technical">
					  		<name>Dusty L. McDonald</name>
					  		<title>Programmer</title>
					  	</contact>
					  	<abstract>
					  		Arctos is an ongoing effort to integrate access to specimen data, collection-management tools, and external resources on the Web.
					  	</abstract>
				  	</host>
				</metadata>
			'>
<cffile action="write" file="#application.webDirectory##filePath#/providerMeta.xml" addnewline="yes" output="#pm#" mode="777">
</cfoutput>