<!--- 
	queries time out, so split this up into a bunch of smaller queries
	and keep redirecting until we get it happy
	--->
<cfif not isdefined("startWith")>
	<cfset startWith = 0>
</cfif>	
<cfif not isdefined("stopAt")>
	<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select max(collection_object_id) as mcid from flat
	</cfquery>
	<cfset stopAt = c.mcid>
</cfif>	
<cfif #startWith# gte #stopAt#>
<cfoutput>#stopAt# gte #startWith#</cfoutput>
	SPIFFY!
	<cfabort>
</cfif>
	<cfset p1k = #startWith# + 5000>
	<cfoutput>-- getting #startWith# to #p1k# --<cfflush></cfoutput>
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT 
			flat.collection_object_id,
			collection_cde,
			institution_acronym,
			cat_num,
			SCIENTIFIC_NAME,		
			SPEC_LOCALITY,
			VERBATIM_DATE,
			HIGHER_GEOG,		
			decode(instr(encumbrance_action,'mask collector'),
				0,collectors,
				NULL,collectors,
				'Anonymous') as collectors,
			TYPESTATUS,
			PARTS,
			decode(instr(encumbrance_action,'mask original field number'),
				0,OTHERCATALOGNUMBERS,
				NULL,OTHERCATALOGNUMBERS,
				ConcatOtherIdFilt(flat.collection_object_id,1)) as OTHERCATALOGNUMBERS,
			GENBANKNUM ,
			SEX,
			BEGAN_DATE,
			ENDED_DATE,
			FIELD_NUM,	
			RELATEDCATALOGEDITEMS,	
			ACCESSION,		
			CONTINENT_OCEAN,
			COUNTRY ,
			STATE_PROV,
			COUNTY,
			FEATURE,
			ISLAND,
			ISLAND_GROUP,
			QUAD,
			SEA ,
			MIN_ELEV_IN_M,
			MAX_ELEV_IN_M,
			DATUM,
			ORIG_LAT_LONG_UNITS,
			decode(instr(encumbrance_action,'mask coordinates'),
				0,VerbatimLatitude,
				NULL,VerbatimLatitude,
				'Masked') as  VerbatimLatitude,
			decode(instr(encumbrance_action,'mask coordinates'),
				0,VerbatimLongitude,
				NULL,VerbatimLongitude,
				'Masked') as  VerbatimLongitude,
			LAT_LONG_REF_SOURCE,
			COORDINATEUNCERTAINTYINMETERS,
			GEOREFMETHOD,
			LAT_LONG_REMARKS,
			LAT_LONG_DETERMINER ,
			IDENTIFIEDBY,
			flat.MADE_DATE,
			flat.REMARKS,
			HABITAT,
			ASSOCIATED_SPECIES,
			LAST_EDIT_DATE,
			COLL_OBJ_DISPOSITION
		FROM 
			flat,
			coll_object_encumbrance,
			encumbrance
		where 
			flat.collection_object_id =coll_object_encumbrance.collection_object_id (+) AND
			coll_object_encumbrance.encumbrance_id = encumbrance.encumbrance_id (+) AND
			flat.collection_object_id between #startWith# and #p1k# AND
			not exists (
				select * from encumbrance,coll_object_encumbrance where 
				encumbrance.encumbrance_id = coll_object_encumbrance.encumbrance_id
				and coll_object_encumbrance.collection_object_id = flat.collection_object_id and 
				encumbrance.encumbrance_action like '%mask record%'
			)
	</cfquery>
	<cfindex 
	query="data" 
	collection="veritySearchData"
	action="Update"
	type="Custom"
	key="collection_object_id"
	custom1 = "INSTITUTION_ACRONYM"
	custom2 = "COLLECTION_CDE"
	custom3 = "CAT_NUM"
	category="data,specimen"
	title="collection_object_id"	
	body="
		INSTITUTION_ACRONYM,
		COLLECTION_CDE,
		cat_num,
		SCIENTIFIC_NAME,		
		SPEC_LOCALITY,
		VERBATIM_DATE,
		HIGHER_GEOG,		
		COLLECTORS,		
		TYPESTATUS,
		PARTS,
		OTHERCATALOGNUMBERS,		
		GENBANKNUM ,
		SEX,
		BEGAN_DATE,
		ENDED_DATE,
		FIELD_NUM,	
		RELATEDCATALOGEDITEMS,	
		ACCESSION,		
		CONTINENT_OCEAN,
		COUNTRY ,
		STATE_PROV,
		COUNTY,
		FEATURE,
		ISLAND,
		ISLAND_GROUP,
		QUAD,
		SEA ,
		MIN_ELEV_IN_M,
		MAX_ELEV_IN_M,
		DATUM,
		ORIG_LAT_LONG_UNITS,
		VERBATIMLATITUDE,
		VERBATIMLONGITUDE,
		LAT_LONG_REF_SOURCE,
		COORDINATEUNCERTAINTYINMETERS,
		GEOREFMETHOD,
		LAT_LONG_REMARKS,
		LAT_LONG_DETERMINER ,
		IDENTIFIEDBY,
		MADE_DATE,
		REMARKS,
		HABITAT,
		ASSOCIATED_SPECIES,
		LAST_EDIT_DATE,
		COLL_OBJ_DISPOSITION">
		<cfoutput>
			<cfset theURL = "indexSpecimens.cfm?startWith=#p1k#&stopAt=#stopAt#">
			<script>
				document.location='#theURL#';
			</script>
	</cfoutput>
spiffy