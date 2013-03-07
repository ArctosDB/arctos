<!--

	fetch data about related specimens into a cache for query, display

	This should be done in RDF er sumthin, but I'm not writing RDF to myself and everybody
	else sucks, so here we are. Try not to screw up future possibilities too much....

--->
<cfoutput>
	<!---

	--->
	<cfquery name="newOrStale" datasource="uam_god">
		select
			coll_obj_other_id_num.COLL_OBJ_OTHER_ID_NUM_ID,
			coll_obj_other_id_num.ID_REFERENCES,
			coll_obj_other_id_num.OTHER_ID_TYPE,
			coll_obj_other_id_num.DISPLAY_VALUE,
			CTCOLL_OTHER_ID_TYPE.BASE_URL
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
			rownum<1000
		UNION
		select
			coll_obj_other_id_num.COLL_OBJ_OTHER_ID_NUM_ID,
			coll_obj_other_id_num.ID_REFERENCES,
			coll_obj_other_id_num.OTHER_ID_TYPE,
			coll_obj_other_id_num.DISPLAY_VALUE,
			CTCOLL_OTHER_ID_TYPE.BASE_URL
		from
			coll_obj_other_id_num,
			CTCOLL_OTHER_ID_TYPE,
			cf_relations_cache
		where
			coll_obj_other_id_num.ID_REFERENCES != 'self' and
			coll_obj_other_id_num.OTHER_ID_TYPE=CTCOLL_OTHER_ID_TYPE.OTHER_ID_TYPE and
			CTCOLL_OTHER_ID_TYPE.BASE_URL is not null and
			coll_obj_other_id_num.COLL_OBJ_OTHER_ID_NUM_ID = cf_relations_cache.COLL_OBJ_OTHER_ID_NUM_ID and
			sysdate-CACHEDATE > 30 and
			rownum<1000
	</cfquery>
	<cfloop query="newOrStale">
		<!--- this should be a web fetch, but see above. Try to be nice about encumbrances, get only public data, etc. --->
		<cfquery name="fetch" datasource="uam_god">
			select
				HIGHER_GEOG || ': ' || SPEC_LOCALITY locality,
				SCIENTIFIC_NAME,
				FAMILY
			from
				filtered_flat
			where guid='#OTHER_ID_TYPE#:#DISPLAY_VALUE#'
		</cfquery>
		<cfdump var=#newOrStale#>
		<!---
			if we get something, update (via delete and insert)
			if we do NOT get anything, assume the "other system"
			is just hosed and hang on to whatever we already had
			That is, do nothing
		---->
		<cfif fetch.recordcount is 1>
			<!---
				if this becomes something more than SQL, we'll need to alter this to only delete the things
				that we're going to rebuild
			---->
			<cfquery name="ins" datasource="uam_god">
				delete from cf_relations_cache where COLL_OBJ_OTHER_ID_NUM_ID=#newOrStale.COLL_OBJ_OTHER_ID_NUM_ID#
			</cfquery>
			<cfif len(fetch.locality) gt 0>
				<cfquery name="ins" datasource="uam_god">
					insert into cf_relations_cache (
						COLL_OBJ_OTHER_ID_NUM_ID,
						TERM,
						VALUE
					) values (
						#newOrStale.COLL_OBJ_OTHER_ID_NUM_ID#,
						'locality',
						'#fetch.locality#'
					)
				</cfquery>
			</cfif>
			<cfif len(fetch.SCIENTIFIC_NAME) gt 0>
				<cfquery name="ins" datasource="uam_god">
					insert into cf_relations_cache (
						COLL_OBJ_OTHER_ID_NUM_ID,
						TERM,
						VALUE
					) values (
						#newOrStale.COLL_OBJ_OTHER_ID_NUM_ID#,
						'identification',
						'#fetch.SCIENTIFIC_NAME#'
					)
				</cfquery>
			</cfif>
			<cfif len(fetch.FAMILY) gt 0>
				<cfquery name="ins" datasource="uam_god">
					insert into cf_relations_cache (
						COLL_OBJ_OTHER_ID_NUM_ID,
						TERM,
						VALUE
					) values (
						#newOrStale.COLL_OBJ_OTHER_ID_NUM_ID#,
						'family',
						'#fetch.FAMILY#'
					)
				</cfquery>
			</cfif>
		</cfif>
	</cfloop>
</cfoutput>