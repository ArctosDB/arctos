<cfabort>


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