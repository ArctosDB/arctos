

<!--

	Build a bulkloader of potential reciprocal relationships
	
	

--->
<cfoutput>
	<!--- hard-code this because we have no better place for it.... --->
	<cfset ctid_references = querynew("r1,r2")>
	<cfset temp = queryaddrow(ctid_references,1)>
	<cfset i=1>
	<cfset temp = QuerySetCell(ctid_references, "r1", 'ate', i)>
	<cfset temp = QuerySetCell(ctid_references, "r2", 'eaten by', i)>	
	<cfset i=i+1>
	<cfset temp = queryaddrow(ctid_references,1)>
	<cfset temp = QuerySetCell(ctid_references, "r1", 'collected from', i)>
	<cfset temp = QuerySetCell(ctid_references, "r2", 'collected on', i)>
	<cfset i=i+1>
	<cfset temp = queryaddrow(ctid_references,1)>
	<cfset temp = QuerySetCell(ctid_references, "r1", 'collected with', i)>
	<cfset temp = QuerySetCell(ctid_references, "r2", 'collected with', i)>
	<cfset i=i+1>
	<cfset temp = queryaddrow(ctid_references,1)>
	<cfset temp = QuerySetCell(ctid_references, "r1", 'host of', i)>
	<cfset temp = QuerySetCell(ctid_references, "r2", 'parasite of', i)>
	<cfset i=i+1>
	<cfset temp = queryaddrow(ctid_references,1)>
	<cfset temp = QuerySetCell(ctid_references, "r1", 'in amplexus with', i)>
	<cfset temp = QuerySetCell(ctid_references, "r2", 'in amplexus with', i)>
	<cfset i=i+1>
	<cfset temp = queryaddrow(ctid_references,1)>
	<cfset temp = QuerySetCell(ctid_references, "r1", 'littermate or nestmate of', i)>
	<cfset temp = QuerySetCell(ctid_references, "r2", 'littermate or nestmate of', i)>
	<cfset i=i+1>
	<cfset temp = queryaddrow(ctid_references,1)>
	<cfset temp = QuerySetCell(ctid_references, "r1", 'mate of', i)>
	<cfset temp = QuerySetCell(ctid_references, "r2", 'mate of', i)>
	<cfset i=i+1>
	<cfset temp = queryaddrow(ctid_references,1)>
	<cfset temp = QuerySetCell(ctid_references, "r1", 'offspring of', i)>
	<cfset temp = QuerySetCell(ctid_references, "r2", 'parent of', i)>
	<cfset i=i+1>
	<cfset temp = queryaddrow(ctid_references,1)>
	<cfset temp = QuerySetCell(ctid_references, "r1", 'same individual as', i)>
	<cfset temp = QuerySetCell(ctid_references, "r2", 'same individual as', i)>
	<cfset i=i+1>
	<cfset temp = queryaddrow(ctid_references,1)>
	<cfset temp = QuerySetCell(ctid_references, "r1", 'TEST---sibling of', i)>
	<cfset temp = QuerySetCell(ctid_references, "r2", 'sibling of', i)>
	
	
	<cfquery name="rCTID_REFERENCES" datasource="uam_god">
		select ID_REFERENCES from CTID_REFERENCES where ID_REFERENCES != 'self'
	</cfquery>
	<cfquery name="c1" dbtype="query">
		select r1 from ctid_references where r1 not in (#valuelist(rCTID_REFERENCES.ID_REFERENCES)# )
	</cfquery>
	<cfif c1.recordcount is not 0>
		<cfthrow message='pendingRelations r1 MIA'>
	</cfif>
	
	
	
	<cfabort>
	
	
	
	<cfquery name="CTCOLLECTION" datasource="uam_god">
		select collection_id from collection
	</cfquery>
		
	<cfloop query="CTID_REFERENCES">
		<cfloop query="ctcollection">
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
					rownum<100
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
		</cfloop>	

		
	</cfloop>
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
	
	<br>found #newOrStale.recordcount#
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




<cfinclude template="/includes/_header.cfm">
<cfquery name="getRels" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select * from cf_temp_relations where RELATED_COLLECTION_OBJECT_ID is null
</cfquery>
<cfoutput>
	<cfloop query="getRels">
		<cfif #related_to_num_type# is "catalog number">
			<cftry>
			<cfquery name="isOne" datasource="uam_god">
				select
					collection_object_id
				FROM
					flat
				where
					guid = '#related_to_number#'
			</cfquery>
			<cfcatch>
				<cfquery name="nope" datasource="uam_god">
					update cf_temp_relations set
						lasttrydate=sysdate,
						fail_reason='Catalog Number does not exist or is not in UAM Mamm 1234 format'
					WHERE
						collection_object_id=#collection_object_id# and
						related_to_number = '#related_to_number#' and
						related_to_num_type = '#related_to_num_type#' and
						relationship = '#relationship#'
				</cfquery>
				<cfset isOne = queryNew("collection_object_id")>
			</cfcatch>
			</cftry>
		<cfelse>
			<cfquery name="isOne" datasource="uam_god">
				select collection_object_id FROM coll_obj_other_id_num
				where other_id_type = '#related_to_num_type#' and display_value = '#related_to_number#'
			</cfquery>
		</cfif>
		<cfif #isOne.recordcount# is 0>
			<cfquery name="nope" datasource="uam_god">
				update cf_temp_relations set
					lasttrydate=sysdate,
					fail_reason='Related cataloged item does not exist.'
				WHERE
					collection_object_id=#collection_object_id# and
					related_to_number = '#related_to_number#' and
					related_to_num_type = '#related_to_num_type#' and
					relationship = '#relationship#'
			</cfquery>
		<cfelseif #isOne.recordcount# gt 1>
			<cfquery name="toomany" datasource="uam_god">
				update cf_temp_relations set
					lasttrydate=sysdate,
					fail_reason='More than one cataloged item matched.'
				WHERE
					collection_object_id=#collection_object_id# and
					related_to_number = '#related_to_number#' and
					related_to_num_type = '#related_to_num_type#' and
					relationship = '#relationship#'
			</cfquery>
		<cfelseif #isOne.recordcount# is 1>
			<cftry>
			<cfquery name="insNew" datasource="uam_god">
				INSERT INTO
					 BIOL_INDIV_RELATIONS (
					 	COLLECTION_OBJECT_ID,
					 	RELATED_COLL_OBJECT_ID,
					 	BIOL_INDIV_RELATIONSHIP )
					 VALUES (
					 	#collection_object_id#,
					 	#isOne.collection_object_id#,
					 	'#relationship#' )
			</cfquery>
			<cfquery name="justRight" datasource="uam_god">
				DELETE FROM cf_temp_relations
				WHERE
					collection_object_id=#collection_object_id# and
					related_to_number = '#related_to_number#' and
					related_to_num_type = '#related_to_num_type#' and
					relationship = '#relationship#'
			</cfquery>
			<cfcatch>
				<cfquery name="fail" datasource="uam_god">
					update cf_temp_relations set
						lasttrydate=sysdate,
						fail_reason='DB Error. #cfcatch.detail#'
					WHERE
						collection_object_id=#collection_object_id# and
						related_to_number = '#related_to_number#' and
						related_to_num_type = '#related_to_num_type#' and
						relationship = '#relationship#'
				</cfquery>
			</cfcatch>
			</cftry>
			<!---- insert into relationships ---->
		<cfelse>
			<cfquery name="faill" datasource="uam_god">
				update cf_temp_relations set
					lasttrydate=sysdate,
					fail_reason='unknown failure!'
				WHERE
					collection_object_id=#collection_object_id# and
					related_to_number = '#related_to_number#' and
					related_to_num_type = '#related_to_num_type#' and
					relationship = '#relationship#'
			</cfquery>
		</cfif>
	</cfloop>
</cfoutput>