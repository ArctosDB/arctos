<!--

	fetch data about related specimens into a cache for query, display

	This should be done in RDF er sumthin, but I'm not writing RDF to myself and everybody
	else sucks, so here we are. Try not to screw up future possibilities too much....

--->

<cfquery name="new" datasource="uam_god">
	select
		COLL_OBJ_OTHER_ID_NUM_ID,
		ID_REFERENCES,
		OTHER_ID_TYPE,
		DISPLAY_VALUE,
		BASE_URL
	from
		coll_obj_other_id_num,
		CTCOLL_OTHER_ID_TYPE
	where
		coll_obj_other_id_num.ID_REFERENCES != 'self' and
		coll_obj_other_id_num.OTHER_ID_TYPE=CTCOLL_OTHER_ID_TYPE.OTHER_ID_TYPE and
		CTCOLL_OTHER_ID_TYPE.BASE_URL is not null and
		coll_obj_other_id_num.COLL_OBJ_OTHER_ID_NUM_ID not in (
			select COLL_OBJ_OTHER_ID_NUM_ID from cf_relations_cache
		) and
		rownum<10
</cfquery>
<cfoutput>
	<cfloop query="new">
		<!--- this should be a web fetch, but see above. Try to be nice about encumbrances, get only public data, etc. --->
		<cfquery name="fetch" datasource="uam_god">
			select
				HIGHER_GEOG,
				SPEC_LOCALITY,
				DEC_LAT,
				DEC_LONG,
				COORDINATEUNCERTAINTYINMETERS,
				SCIENTIFIC_NAME,
				FAMILY
			from
				filtered_flat
			where guid='#OTHER_ID_TYPE:DISPLAY_VALUE#'
		</cfquery>
		<cfdump var=#fetch#>
	</cfloop>
</cfoutput>

