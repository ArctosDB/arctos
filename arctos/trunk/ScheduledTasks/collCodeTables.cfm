<!--- 
	builds collection-specific code tables to use in collection-specific searches. 
	Needs to run reqularly to keep everything in sync 
	Run at initial setup
--->
<cfquery name="allCollections" datasource="uam_god">
	select collection_cde,institution_acronym,collection_id from collection
</cfquery>
<cfoutput>
	<cfloop query="allCollections">
			<cfset thisTableName = "cctSpecimen_Part_Name#collection_id#">
			<cftry>
				<cfquery name="killSyn" datasource="uam_god">
					drop public synonym #thisTableName#
				</cfquery>
			<cfcatch>
				<P>COULD NOT DROP SYNONYM</P>
			</cfcatch>
			</cftry>
			<cftry>
				<cfquery name="killTab" datasource="uam_god">
					drop table #thisTableName#
				</cfquery>
			<cfcatch>
				<P>COULD NOT DROP TABLE</P>
			</cfcatch>
			</cftry>
			
			<cftry>
				<cfquery name="newTab" datasource="uam_god">
					CREATE TABLE #thisTableName# as
						select 
							part_name,
							collection.collection_cde
						from
							specimen_part,
							cataloged_item,
							collection
						where 
							specimen_part.derived_from_cat_item = cataloged_item.collection_object_id and
							cataloged_item.collection_id = collection.collection_id and 
							collection.collection_id=#collection_id#
						group by 
							part_name,
							collection.collection_cde
						order by 
							part_name
				</cfquery>
			<cfcatch>
				<P>COULD NOT CREATE TABLE</P>
			</cfcatch>
			</cftry>
			<cftry>
				<cfquery name="newSyn" datasource="uam_god">
					CREATE public synonym #thisTableName# for #thisTableName#
				</cfquery>
			<cfcatch>
				<P>COULD NOT CREATE SYNONYM</P>
			</cfcatch>
			</cftry>
			<cftry>
				<cfquery name="priv" datasource="uam_god">
					grant select on #thisTableName# to uam_query,uam_update
				</cfquery>
			<cfcatch>
				<P>COULD NOT GRANT</P>
			</cfcatch>
			</cftry>
			
	<cfset thisTableName = "cCTCOLL_OTHER_ID_TYPE#collection_id#">
			<cftry>
				<cfquery name="killSyn" datasource="uam_god">
					drop public synonym #thisTableName#
				</cfquery>
			<cfcatch>
				<P>COULD NOT DROP SYNONYM</P>
			</cfcatch>
			</cftry>
			<cftry>
				<cfquery name="killTab" datasource="uam_god">
					drop table #thisTableName#
				</cfquery>
			<cfcatch>
				<P>COULD NOT DROP TABLE</P>
			</cfcatch>
			</cftry>
			
			<cftry>
				<cfquery name="newTab" datasource="uam_god">
					CREATE TABLE #thisTableName# as
						select 
							OTHER_ID_TYPE,
							collection.collection_cde
						from
							coll_obj_other_id_num,
							cataloged_item,
							collection
						where 
							coll_obj_other_id_num.collection_object_id = cataloged_item.collection_object_id and
							cataloged_item.collection_id = collection.collection_id and 
							collection.collection_id=#collection_id#
						group by 
							OTHER_ID_TYPE,
							collection.collection_cde
						order by 
							OTHER_ID_TYPE
				</cfquery>
			<cfcatch>
				<P>COULD NOT CREATE TABLE</P>
			</cfcatch>
			</cftry>
			<cftry>
				<cfquery name="newSyn" datasource="uam_god">
					CREATE public synonym #thisTableName# for #thisTableName#
				</cfquery>
			<cfcatch>
				<P>COULD NOT CREATE SYNONYM</P>
			</cfcatch>
			</cftry>
			<cftry>
				<cfquery name="priv" datasource="uam_god">
					grant select on #thisTableName# to uam_query,uam_update
				</cfquery>
			<cfcatch>
				<P>COULD NOT GRANT</P>
			</cfcatch>
			</cftry>
			
	<cfset thisTableName = "cCTSPECIMEN_PRESERV_METHOD#collection_id#">
			<cftry>
				<cfquery name="killSyn" datasource="uam_god">
					drop public synonym #thisTableName#
				</cfquery>
			<cfcatch>
				<P>COULD NOT DROP SYNONYM</P>
			</cfcatch>
			</cftry>
			<cftry>
				<cfquery name="killTab" datasource="uam_god">
					drop table #thisTableName#
				</cfquery>
			<cfcatch>
				<P>COULD NOT DROP TABLE</P>
			</cfcatch>
			</cftry>
			
			<cftry>
				<cfquery name="newTab" datasource="uam_god">
					CREATE TABLE #thisTableName# as
						select 
							PRESERVE_METHOD,
							collection.collection_cde
						from
							specimen_part,
							cataloged_item,
							collection
						where 
							specimen_part.derived_from_cat_item = cataloged_item.collection_object_id and
							cataloged_item.collection_id = collection.collection_id and 
							collection.collection_id=#collection_id#
						group by 
							PRESERVE_METHOD,
							collection.collection_cde
						order by 
							PRESERVE_METHOD
				</cfquery>
			<cfcatch>
				<P>COULD NOT CREATE TABLE</P>
			</cfcatch>
			</cftry>
			<cftry>
				<cfquery name="newSyn" datasource="uam_god">
					CREATE public synonym #thisTableName# for #thisTableName#
				</cfquery>
			<cfcatch>
				<P>COULD NOT CREATE SYNONYM</P>
			</cfcatch>
			</cftry>
			<cftry>
				<cfquery name="priv" datasource="uam_god">
					grant select on #thisTableName# to uam_query,uam_update
				</cfquery>
			<cfcatch>
				<P>COULD NOT GRANT</P>
			</cfcatch>
			</cftry>
	<cfset thisTableName = "cCTSPECIMEN_PART_MODIFIER#collection_id#">
			<cftry>
				<cfquery name="killSyn" datasource="uam_god">
					drop public synonym #thisTableName#
				</cfquery>
			<cfcatch>
				<P>COULD NOT DROP SYNONYM</P>
			</cfcatch>
			</cftry>
			<cftry>
				<cfquery name="killTab" datasource="uam_god">
					drop table #thisTableName#
				</cfquery>
			<cfcatch>
				<P>COULD NOT DROP TABLE</P>
			</cfcatch>
			</cftry>
			
			<cftry>
				<cfquery name="newTab" datasource="uam_god">
					CREATE TABLE #thisTableName# as
						select 
							PART_MODIFIER
						from
							specimen_part,
							cataloged_item,
							collection
						where 
							specimen_part.derived_from_cat_item = cataloged_item.collection_object_id and
							cataloged_item.collection_id = collection.collection_id and 
							collection.collection_id=#collection_id#
						group by 
							PART_MODIFIER
						order by 
							PART_MODIFIER
				</cfquery>
			<cfcatch>
				<P>COULD NOT CREATE TABLE</P>
			</cfcatch>
			</cftry>
			<cftry>
				<cfquery name="newSyn" datasource="uam_god">
					CREATE public synonym #thisTableName# for #thisTableName#
				</cfquery>
			<cfcatch>
				<P>COULD NOT CREATE SYNONYM</P>
			</cfcatch>
			</cftry>
			<cftry>
				<cfquery name="priv" datasource="uam_god">
					grant select on #thisTableName# to uam_query,uam_update
				</cfquery>
			<cfcatch>
				<P>COULD NOT GRANT</P>
			</cfcatch>
			</cftry>
			
			
	</cfloop>
</cfoutput>