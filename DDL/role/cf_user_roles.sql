/* cf_user_roles */

/* replaced with finer-grained roles */
/*
drop role add_accn;
drop role add_identification;
drop role manage_identification;
drop role manage_random;
drop role manage_authority;
drop role manage_transactions;
create role manage_transactions;
create role data_entry;
create role manage_agents;
create role manage_taxonomy;
create role global_admin;
create role dgr_locator;
create role manage_container;
create role manage_collection;
drop role manage_publications;
create role manage_publications;
drop role manage_specimens;
create role manage_specimens;
drop role manage_locality;
create  role manage_locality;
create role manage_geography;
*/
/****************************  manage_codetables ******************************************/
/*
create with:
select 'GRANT INSERT, UPDATE, DELETE ON ' || table_name || ' TO manage_codetables;' from user_tables where table_name like 'CT%';
*/
GRANT INSERT, UPDATE,delete ON CTACCN_STATUS to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTACCN_TYPE to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTADDR_TYPE to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTAGENT_NAME_TYPE to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTAGENT_RELATIONSHIP to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTAGENT_TYPE to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTAGE_CLASS to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTATTRIBUTE_CODE_TABLES to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTATTRIBUTE_TYPE to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTBIN_OBJ_ASPECT to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTBIN_OBJ_SUBJECT to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTBIOL_RELATIONS to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTBORROW_STATUS to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTCF_LOAN_USE_TYPE to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTCITATION_TYPE_STATUS to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTCLASS to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTCOLLECTING_SOURCE to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTCOLLECTION_CDE to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTCOLLECTOR_ROLE to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTCOLL_CONTACT_ROLE to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTCOLL_OBJ_DISP to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTCOLL_OBJ_FLAGS to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTCOLL_OTHER_ID_TYPE to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTCONTAINER_TYPE to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTCONTINENT to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTDATUM to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTDEPTH_UNITS to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTDOWNLOAD_PURPOSE to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTELECTRONIC_ADDR_TYPE to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTENCUMBRANCE_ACTION to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTEW to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTFEATURE to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTFLAGS to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTFLUID_CONCENTRATION to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTFLUID_TYPE to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTGEOG_SOURCE_AUTHORITY to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTGEOREFMETHOD to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTINFRASPECIFIC_RANK to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTISLAND_GROUP to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTLAT_LONG_ERROR_UNITS to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTLAT_LONG_REF_SOURCE to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTLAT_LONG_UNITS to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTLENGTH_UNITS to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTLOAN_STATUS to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTLOAN_TYPE to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTNATURE_OF_ID to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTNS to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTNUMERIC_AGE_UNITS to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTORIG_ELEV_UNITS to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTPERMIT_TYPE to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTPREFIX to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTPROJECT_AGENT_ROLE to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTPUBLICATION_TYPE to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTSEX_CDE to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTSHIPPED_CARRIER_METHOD to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTSPECIMEN_PART_LIST_ORDER to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTSPECIMEN_PART_MODIFIER to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTSPECIMEN_PART_NAME to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTSPECIMEN_PRESERV_METHOD to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTSUFFIX to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTTAXA_FORMULA to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTTAXONOMIC_AUTHORITY to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTTAXON_RELATION to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTVERIFICATIONSTATUS to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTWEIGHT_UNITS to manage_codetables;
GRANT INSERT, UPDATE,delete ON CTYES_NO to manage_codetables;
/****************************      COLDFUSION_USER ******************************************/
/* build with
    
 select 'GRANT INSERT, UPDATE,delete ON ' || table_name || ' to COLDFUSION_USER;' from user_tables where table_name like 'CF%';
*/
GRANT INSERT, UPDATE,delete ON CFFLAGS to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_ADDR to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_ADDRESS to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_BUGS to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_CANNED_SEARCH to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_DATABASE_ACTIVITY to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_DOWNLOAD to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_GENBANK_INFO to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_LABEL to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_LOAN to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_LOAN_ITEM to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_LOG to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_PROJECT to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_SEARCH_RESULTS to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_SPEC_RES_COLS to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_TEMP_ATTRIBUTES to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_TEMP_BARCODE_PARTS to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_TEMP_CITATION to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_TEMP_CONTAINER_LOCATION to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_TEMP_GEOREF to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_TEMP_LOAN to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_TEMP_LOAN_ITEM to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_TEMP_OIDS to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_TEMP_PARTS to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_TEMP_RELATIONS to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_TEMP_SCANS to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_USERS to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_USER_DATA to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_USER_LOAN to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_USER_LOG to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_USER_ROLES to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_VERSION to COLDFUSION_USER;
GRANT INSERT, UPDATE,delete ON CF_VERSION_LOG to COLDFUSION_USER;
/* all privileges on CF* tables, mostly used for bulkloading various things.
/****************************      manage_transactions ******************************************/
GRANT INSERT, UPDATE,delete ON accn to manage_transactions;
GRANT INSERT, UPDATE,delete ON loan to manage_transactions;
GRANT INSERT, UPDATE,delete ON loan_item to     manage_transactions;
GRANT INSERT, UPDATE,delete ON trans to manage_transactions;
GRANT INSERT, UPDATE,delete ON borrow to manage_transactions;
GRANT INSERT, UPDATE,delete ON encumbrance to manage_transactions;
GRANT INSERT, UPDATE,delete ON permit to manage_transactions;
GRANT INSERT, UPDATE,delete ON addr to manage_transactions;
GRANT INSERT, UPDATE,delete ON electronic_address to manage_transactions;
GRANT INSERT, UPDATE,delete ON SHIPMENT to manage_transactions;
GRANT INSERT, UPDATE,delete ON PROJECT_SPONSOR to manage_transactions;
GRANT INSERT, UPDATE,delete ON PROJECT_REMARK to manage_transactions;
GRANT INSERT, UPDATE,delete ON PROJECT_PUBLICATION to manage_transactions;
GRANT INSERT, UPDATE,delete ON PROJECT to manage_transactions;
GRANT INSERT, UPDATE,delete ON PROJECT_AGENT to manage_transactions;
GRANT INSERT, UPDATE,delete ON PERMIT_SHIPMENT to manage_transactions;
GRANT INSERT, UPDATE,delete ON PERMIT_TRANS to manage_transactions;    
--manage_users: Assign roles to users - how to do?
/****************************      data_entry ******************************************/

grant update,insert,delete ON bulkloader to data_entry;
grant update,insert,delete ON bulkloader_stage to data_entry;
/****************************      manage_agents ******************************************/
grant update,insert,delete ON agent to manage_agents;
grant update,insert,delete ON agent_name to manage_agents;
grant update,insert,delete ON agent_relations to manage_agents;
grant update,insert,delete ON person to manage_agents;
/****************************      manage_taxonomy ******************************************/
grant update,insert,delete ON taxonomy to manage_taxonomy;
grant update,insert,delete ON taxon_relations to manage_taxonomy;
grant update,insert,delete ON common_name to manage_taxonomy;
/****************************      manage_specimens ******************************************/
grant update,insert ON cataloged_item to manage_specimens;
grant update,insert,delete ON coll_object to manage_specimens;
grant update,insert,delete ON COLLECTOR to manage_specimens;
grant update,insert,delete ON ATTRIBUTES to manage_specimens;
grant update,insert,delete ON BINARY_OBJECT to manage_specimens;
grant update,insert,delete ON BIOL_INDIV_RELATIONS to manage_specimens;
grant update,insert,delete ON COLL_OBJECT_REMARK to manage_specimens;
grant update,insert,delete ON COLL_OBJECT_ENCUMBRANCE to manage_specimens;
grant update,insert,delete ON specimen_part to manage_specimens;
grant update,insert,delete ON coll_obj_cont_hist to manage_specimens;
grant update,insert,delete ON coll_obj_other_id_num to manage_specimens;
grant update,insert ON identification to manage_specimens;
grant update,insert,delete ON identification_agent to manage_specimens;
grant update ON container to manage_specimens;
grant update ON spec_with_loc to manage_specimens;
grant insert ON COLLECTING_EVENT to manage_specimens;
grant insert ON citation to manage_specimens;

/****************************      manage_locality ******************************************/
grant update,insert,delete ON locality to manage_locality;
grant update,insert,delete ON collecting_event to manage_locality;
grant update,insert,delete ON lat_long to manage_locality;
grant update,insert,delete ON VESSEL to manage_locality;
/****************************      manage_geography ******************************************/
grant update,insert,delete on geog_auth_rec to manage_geography;
/****************************      manage_publications ******************************************/
grant update,insert,delete ON CITATION to manage_publications;
grant update,insert,delete ON FIELD_NOTEBOOK_SECTION to manage_publications;
grant update,insert,delete ON JOURNAL to manage_publications;
grant update,insert,delete ON JOURNAL_ARTICLE to manage_publications;
grant update,insert,delete ON PAGE to manage_publications;
grant update,insert,delete ON PROJECT to manage_publications;
grant update,insert,delete ON PROJECT_AGENT to manage_publications;
grant update,insert,delete ON PROJECT_PUBLICATION to manage_publications;
grant update,insert,delete ON PROJECT_TRANS to manage_publications;
grant update,insert,delete ON PUBLICATION to manage_publications;
grant update,insert,delete ON PUBLICATION_AUTHOR_NAME to manage_publications;
grant update,insert,delete ON PUBLICATION_URL to manage_publications;
/****************************      manage_collection ******************************************/    
grant update,insert,delete ON collection to manage_collection;
grant update,insert,delete ON COLLECTION_CONTACTS to manage_collection;
grant delete ON cataloged_item to manage_collection;
grant delete ON identification to manage_collection;
grant delete ON identification_taxonomy to manage_collection;
/****************************      manage_container ******************************************/    
grant update,insert,delete ON container to manage_container;
grant update,insert,delete ON FLUID_CONTAINER_HISTORY to manage_container;
grant insert ON container_check to manage_container;
/****************************      dgr_locator ******************************************/    
grant update,insert,delete ON dgr_locator to dgr_locator;
/****************************      global_admin ******************************************/    
GRANT INSERT, UPDATE,delete on VIEWER to global_admin;
GRANT INSERT, UPDATE,delete on temp_allow_cf_user to global_admin;
/* Friggin UCB's crappy-assed duct taped setup does not implicitly allow SELECT on PUBLIC - WTF??
No need to run this at UAM, or anywhere else with a semi-sane setup */
declare wtf VARCHAR2(3000);
begin
    for t in (select table_name from user_tables) loop
        wtf := 'grant select on ' || t.table_name || ' to public';
        execute immediate (wtf);
    end loop;
end;        