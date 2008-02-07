CREATE OR REPLACE VIEW BSCIT_IMAGE_DATA (
    COLLECTION_OBJECT_ID,
	INSTITUTION_ACRONYM,
	COLLECTION_CDE,
    CAT_NUM,
    COLLECTOR,
    COUNTRY,
    STATE_PROV,
    COUNTY,
    SPEC_LOCALITY,
    ISLAND,
    ISLAND_GROUP,
    BEGAN_DATE,
    ENDED_DATE,
    VERBATIM_DATE,
    SUBJECT,
    DESCRIPTION,
    SCIENTIFIC_NAME)
AS SELECT
        ci.collection_object_id,
        c.institution_acronym,
        ci.collection_cde,
        ci.cat_num,
        concatColl(ci.collection_object_id) as collector,
        g.country,
        g.state_prov,
        g.county,
        l.spec_locality,
        g.island,
        g.island_group,
        ce.began_date,
        ce.ended_date,
        ce.verbatim_date,
        b.subject,
        a.attribute_value as description,
        decode(i.scientific_name,
            'unidentifiable', null, i.scientific_name) scientific_name
    FROM
        collection c,
        cataloged_item ci,
        geog_auth_rec g,
        locality l,
        collecting_event ce,
        bscit_image_subject b,
        attributes a,
        identification i
    WHERE
        c.collection_id = ci.collection_id and
        ci.collecting_event_id = ce.collecting_event_id and
        ce.locality_id = l.locality_id and
        l.geog_auth_rec_id = g.geog_auth_rec_id and
        ci.collection_object_id = i.collection_object_id and
        ci.collection_id = 7 and
        ci.collection_object_id = a.collection_object_id and
        a.attribute_type = 'title' and
        ci.collection_object_id = b.collection_object_id
        
        
1* select max(collection_object_id) from coll_object
uam@mvzldev> /

MAX(COLLECTION_OBJECT_ID)
-------------------------
                 11274070
        
uam@mvzldev> select count(*) from lam_coll_object_bak;

  COUNT(*)
----------
   1678869

Elapsed: 00:00:01.66
uam@mvzldev> select count(*) from lam_binary_object_bak;

  COUNT(*)
----------
         4
        
Elapsed: 00:00:00.02
uam@mvzldev> select count(*) from coll_object;

  COUNT(*)
----------
   1678869

Elapsed: 00:00:00.26
uam@mvzldev> select count(*) from lam_coll_object_bak;

  COUNT(*)
----------
   1678869

Elapsed: 00:00:02.47
uam@mvzldev> select max(collection_object_id) from coll_object;

MAX(COLLECTION_OBJECT_ID)
-------------------------
                 11274070

Elapsed: 00:00:00.01
uam@mvzldev> select count(*) from binary_object;

  COUNT(*)
----------
         4

Elapsed: 00:00:00.00

uam@mvzldev> select count(*) from lam_binary_object_bak;

  COUNT(*)
----------
         4

Elapsed: 00:00:00.01
uam@mvzldev> select max(collection_object_id) from binary_object;    

MAX(COLLECTION_OBJECT_ID)
-------------------------
                 11274070

Elapsed: 00:00:00.01
        
declare
    jwc     number;
begin
    for cn in (
        select
            ci.collection_object_id,
            bid.cat_num,
            bid.subject,
            bid.description,
            bid.made_date,
            bid.jpeg_full_url,
            bid.thumbnail_url
        from
            cataloged_item ci,
            bscit_image_data_vw bid
        where
            ci.collection_object_id = bid.collection_object_id
            and bid.made_date is not null
            and bid.jpeg_full_url is not null
    ) loop
        --
--      create coll_object for jpegs with cards
--
        select max(collection_object_id) + 1 into jwc from coll_object;
        dbms_output.put_line('jwc: ' || jwc);
        insert into coll_object (
            collection_object_id,
            coll_object_type,
            entered_person_id,
            coll_object_entered_date,
            last_edited_person_iD,
            last_edit_date,
            coll_obj_disposition,
            lot_count,
            condition,
            flags)
        values (
            jwc,
            'IO',
            14238,
            sysdate,
            null,
            null,
            'in collection',
            1,
            'unchecked',
            null);
        commit;
--
--      create binary_object for jpegs with cards
--
        insert into binary_object (
            collection_object_id,
            viewer_id,
            derived_from_cat_item,
            derived_from_coll_obj,
            made_date,
            subject,
            aspect,
            description,
            full_url,
            made_agent_id,
            thumbnail_url)
        values (
            jwc,
            1,
            cn.collection_object_id,
            null,
            cn.made_date,
            cn.subject,
            null,
            cn.description,
            cn.jpeg_full_url,
            14683,
            cn.thumbnail_url);
        commit;
    end loop;
end;
        
/* CC only wants data for jpegs        
declare
    twc     number;
    twoc    number;
    jwc     number;
    tpwoc   number;
begin
    for cn in (
        select
            ci.collection_object_id,
            bid.cat_num,
            bid.subject,
            bid.description,
            bid.made_date,
            bid.jpeg_full_url,
            bid.tilepic_full_url,
            bid.thumbnail_url
        from
            cataloged_item ci,
            bscit_image_data_vw bid
        where
            ci.collection_object_id = bid.collection_object_id
            and bid.made_date is not null
            and bid.jpeg_full_url is not null
            and bid.tilepic_full_url is not null
    ) loop
--
--      create coll_object for tiffs with cards
--
        select max(collection_object_id) + 1 into twc from coll_object;
        dbms_output.put_line('twc: ' || twc);
        insert into coll_object (
            collection_object_id,
            coll_object_type,
            entered_person_id,
            coll_object_entered_date,
            last_edited_person_id,
            last_edit_date,
            coll_obj_disposition,
            lot_count,
            condition,
            flags)
        values (
            twc,
            'IO',
            14238,
            sysdate,
            null,
            null,
            'in collection',
            1,
            'unchecked',
            null);
        commit;
--
--      create binary_object for tiffs with cards
--
        insert into binary_object (
            collection_object_id,
            viewer_id,
            derived_from_cat_item,
            derived_from_coll_obj,
            made_date,
            subject,
            aspect,
            description,
            full_url,
            made_agent_id,
            thumbnail_url)
        values (
            twc,
            1,
            cn.collection_object_id,
            null,
            to_date('15 Aug 2007', 'DD Mon YYYY'),
            cn.subject,
            null,
            cn.description,
            'http://mvzarctos-dev.berkeley.edu/cfusion/images/noImageMVZ.png?twc'|| cn.cat_num ,
            14238,
            'http://mvzarctos-dev.berkeley.edu/cfusion/images/noThumb.jpg');
        commit;
--
--      create coll_object for tiffs without cards
--
        select max(collection_object_id) + 1 into twoc from coll_object;
        dbms_output.put_line('twoc: ' || twoc);
        insert into coll_object (
            collection_object_id,
            coll_object_type,
            entered_person_id,
            coll_object_entered_date,
            last_edited_person_iD,
            last_edit_date,
            coll_obj_disposition,
            lot_count,
            condition,
            flags)
        values (
            twoc,
            'IO',
            14238,
            sysdate,
            null,
            null,
            'in collection',
            1,
            'unchecked',
            null);
        commit;
--
--      create binary_object for tiffs without cards
--
        insert into binary_object (
            collection_object_id,
            viewer_id,
            derived_from_cat_item,
            derived_from_coll_obj,
            made_date,
            subject,
            aspect,
            description,
            full_url,
            made_agent_id,
            thumbnail_url)
        values (
            twoc,
            1,
            cn.collection_object_id,
            null,
            to_date('15 Aug 2007', 'DD Mon YYYY'),
            cn.subject,
            null,
            cn.description,
            'http://mvzarctos-dev.berkeley.edu/cfusion/images/noImageMVZ.png?twoc'|| cn.cat_num ,
            14238,
            cn.thumbnail_url);
        commit;
--
--      create coll_object for jpegs with cards
--
        select max(collection_object_id) + 1 into jwc from coll_object;
        dbms_output.put_line('jwc: ' || jwc);
        insert into coll_object (
            collection_object_id,
            coll_object_type,
            entered_person_id,
            coll_object_entered_date,
            last_edited_person_iD,
            last_edit_date,
            coll_obj_disposition,
            lot_count,
            condition,
            flags)
        values (
            jwc,
            'IO',
            14238,
            sysdate,
            null,
            null,
            'in collection',
            1,
            'unchecked',
            null);
        commit;
--
--      create binary_object for jpegs with cards
--
        insert into binary_object (
            collection_object_id,
            viewer_id,
            derived_from_cat_item,
            derived_from_coll_obj,
            made_date,
            subject,
            aspect,
            description,
            full_url,
            made_agent_id,
            thumbnail_url)
        values (
            jwc,
            1,
            cn.collection_object_id,
            twc,
            cn.made_date,
            cn.subject,
            null,
            cn.description,
            cn.jpeg_full_url,
            14238,
            'http://mvzarctos-dev.berkeley.edu/cfusion/images/noThumb.jpg');
        commit;
--
--      create coll_object for tilepics without cards
--
        select max(collection_object_id) + 1 into tpwoc from coll_object;
        dbms_output.put_line('tpwoc: ' || tpwoc);
        insert into coll_object (
            collection_object_id,
            coll_object_type,
            entered_person_id,
            coll_object_entered_date,
            last_edited_person_iD,
            last_edit_date,
            coll_obj_disposition,
            lot_count,
            condition,
            flags)
        values (
            tpwoc,
            'IO',
            14238,
            sysdate,
            null,
            null,
            'in collection',
            1,
            'unchecked',
            null);
        commit;
--
--      create binary_object for jpegs
--
        insert into binary_object (
            collection_object_id,
            viewer_id,
            derived_from_cat_item,
            derived_from_coll_obj,
            made_date,
            subject,
            aspect,
            description,
            full_url,
            made_agent_id,
            thumbnail_url)
        values (
            tpwoc,
            1,
            cn.collection_object_id,
            twoc,
            cn.made_date,
            cn.subject,
            null,
            cn.description,
            cn.tilepic_full_url,
            14238,
            cn.thumbnail_url);
        commit;
    end loop;
end;
*/



/* cf_user_roles */


/* replaced with finer-grained roles */
/*
drop role add_accn;
drop role add_identification;
drop role MANAGE_IDENTIFICATION;
drop role MANAGE_RANDOM;
drop role MANAGE_AUTHORITY;
drop role manage_transactions;
create role  manage_transactions;
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
    select 'grant insert,update,delete ON ' || table_name || ' to manage_codetables;' from user_tables where table_name like 'CT%';
*/
grant insert,update,delete ON CTACCN_STATUS to manage_codetables;
grant insert,update,delete ON CTACCN_TYPE to manage_codetables;
grant insert,update,delete ON CTADDR_TYPE to manage_codetables;
grant insert,update,delete ON CTAGENT_NAME_TYPE to manage_codetables;
grant insert,update,delete ON CTAGENT_RELATIONSHIP to manage_codetables;
grant insert,update,delete ON CTAGENT_TYPE to manage_codetables;
grant insert,update,delete ON CTAGE_CLASS to manage_codetables;
grant insert,update,delete ON CTATTRIBUTE_CODE_TABLES to manage_codetables;
grant insert,update,delete ON CTATTRIBUTE_TYPE to manage_codetables;
grant insert,update,delete ON CTBIN_OBJ_ASPECT to manage_codetables;
grant insert,update,delete ON CTBIN_OBJ_SUBJECT to manage_codetables;
grant insert,update,delete ON CTBIOL_RELATIONS to manage_codetables;
grant insert,update,delete ON CTBORROW_STATUS to manage_codetables;
grant insert,update,delete ON CTCF_LOAN_USE_TYPE to manage_codetables;
grant insert,update,delete ON CTCITATION_TYPE_STATUS to manage_codetables;
grant insert,update,delete ON CTCLASS to manage_codetables;
grant insert,update,delete ON CTCOLLECTING_SOURCE to manage_codetables;
grant insert,update,delete ON CTCOLLECTION_CDE to manage_codetables;
grant insert,update,delete ON CTCOLLECTOR_ROLE to manage_codetables;
grant insert,update,delete ON CTCOLL_CONTACT_ROLE to manage_codetables;
grant insert,update,delete ON CTCOLL_OBJ_DISP to manage_codetables;
grant insert,update,delete ON CTCOLL_OBJ_FLAGS to manage_codetables;
grant insert,update,delete ON CTCOLL_OTHER_ID_TYPE to manage_codetables;
grant insert,update,delete ON CTCONTAINER_TYPE to manage_codetables;
grant insert,update,delete ON CTCONTINENT to manage_codetables;
grant insert,update,delete ON CTDATUM to manage_codetables;
grant insert,update,delete ON CTDEPTH_UNITS to manage_codetables;
grant insert,update,delete ON CTDOWNLOAD_PURPOSE to manage_codetables;
grant insert,update,delete ON CTELECTRONIC_ADDR_TYPE to manage_codetables;
grant insert,update,delete ON CTENCUMBRANCE_ACTION to manage_codetables;
grant insert,update,delete ON CTEW to manage_codetables;
grant insert,update,delete ON CTFEATURE to manage_codetables;
grant insert,update,delete ON CTFLAGS to manage_codetables;
grant insert,update,delete ON CTFLUID_CONCENTRATION to manage_codetables;
grant insert,update,delete ON CTFLUID_TYPE to manage_codetables;
grant insert,update,delete ON CTGEOG_SOURCE_AUTHORITY to manage_codetables;
grant insert,update,delete ON CTGEOREFMETHOD to manage_codetables;
grant insert,update,delete ON CTINFRASPECIFIC_RANK to manage_codetables;
grant insert,update,delete ON CTISLAND_GROUP to manage_codetables;
grant insert,update,delete ON CTLAT_LONG_ERROR_UNITS to manage_codetables;
grant insert,update,delete ON CTLAT_LONG_REF_SOURCE to manage_codetables;
grant insert,update,delete ON CTLAT_LONG_UNITS to manage_codetables;
grant insert,update,delete ON CTLENGTH_UNITS to manage_codetables;
grant insert,update,delete ON CTLOAN_STATUS to manage_codetables;
grant insert,update,delete ON CTLOAN_TYPE to manage_codetables;
grant insert,update,delete ON CTNATURE_OF_ID to manage_codetables;
grant insert,update,delete ON CTNS to manage_codetables;
grant insert,update,delete ON CTNUMERIC_AGE_UNITS to manage_codetables;
grant insert,update,delete ON CTORIG_ELEV_UNITS to manage_codetables;
grant insert,update,delete ON CTPERMIT_TYPE to manage_codetables;
grant insert,update,delete ON CTPREFIX to manage_codetables;
grant insert,update,delete ON CTPROJECT_AGENT_ROLE to manage_codetables;
grant insert,update,delete ON CTPUBLICATION_TYPE to manage_codetables;
grant insert,update,delete ON CTSEX_CDE to manage_codetables;
grant insert,update,delete ON CTSHIPPED_CARRIER_METHOD to manage_codetables;
grant insert,update,delete ON CTSPECIMEN_PART_LIST_ORDER to manage_codetables;
grant insert,update,delete ON CTSPECIMEN_PART_MODIFIER to manage_codetables;
grant insert,update,delete ON CTSPECIMEN_PART_NAME to manage_codetables;
grant insert,update,delete ON CTSPECIMEN_PRESERV_METHOD to manage_codetables;
grant insert,update,delete ON CTSUFFIX to manage_codetables;
grant insert,update,delete ON CTTAXA_FORMULA to manage_codetables;
grant insert,update,delete ON CTTAXONOMIC_AUTHORITY to manage_codetables;
grant insert,update,delete ON CTTAXON_RELATION to manage_codetables;
grant insert,update,delete ON CTVERIFICATIONSTATUS to manage_codetables;
grant insert,update,delete ON CTWEIGHT_UNITS to manage_codetables;
grant insert,update,delete ON CTYES_NO to manage_codetables;
/****************************      COLDFUSION_USER ******************************************/
/* build with
    
 select 'grant insert,update,delete ON ' || table_name || ' to COLDFUSION_USER;' from user_tables where table_name like 'CF%';
*/
grant insert,update,delete ON CFFLAGS to COLDFUSION_USER;
grant insert,update,delete ON CF_ADDR to COLDFUSION_USER;
grant insert,update,delete ON CF_ADDRESS to COLDFUSION_USER;
grant insert,update,delete ON CF_BUGS to COLDFUSION_USER;
grant insert,update,delete ON CF_CANNED_SEARCH to COLDFUSION_USER;
grant insert,update,delete ON CF_DATABASE_ACTIVITY to COLDFUSION_USER;
grant insert,update,delete ON CF_DOWNLOAD to COLDFUSION_USER;
grant insert,update,delete ON CF_GENBANK_INFO to COLDFUSION_USER;
grant insert,update,delete ON CF_LABEL to COLDFUSION_USER;
grant insert,update,delete ON CF_LOAN to COLDFUSION_USER;
grant insert,update,delete ON CF_LOAN_ITEM to COLDFUSION_USER;
grant insert,update,delete ON CF_LOG to COLDFUSION_USER;
grant insert,update,delete ON CF_PROJECT to COLDFUSION_USER;
grant insert,update,delete ON CF_SEARCH_RESULTS to COLDFUSION_USER;
grant insert,update,delete ON CF_SPEC_RES_COLS to COLDFUSION_USER;
grant insert,update,delete ON CF_TEMP_ATTRIBUTES to COLDFUSION_USER;
grant insert,update,delete ON CF_TEMP_BARCODE_PARTS to COLDFUSION_USER;
grant insert,update,delete ON CF_TEMP_CITATION to COLDFUSION_USER;
grant insert,update,delete ON CF_TEMP_CONTAINER_LOCATION to COLDFUSION_USER;
grant insert,update,delete ON CF_TEMP_GEOREF to COLDFUSION_USER;
grant insert,update,delete ON CF_TEMP_LOAN to COLDFUSION_USER;
grant insert,update,delete ON CF_TEMP_LOAN_ITEM to COLDFUSION_USER;
grant insert,update,delete ON CF_TEMP_OIDS to COLDFUSION_USER;
grant insert,update,delete ON CF_TEMP_PARTS to COLDFUSION_USER;
grant insert,update,delete ON CF_TEMP_RELATIONS to COLDFUSION_USER;
grant insert,update,delete ON CF_TEMP_SCANS to COLDFUSION_USER;
grant insert,update,delete ON CF_USERS to COLDFUSION_USER;
grant insert,update,delete ON CF_USER_DATA to COLDFUSION_USER;
grant insert,update,delete ON CF_USER_LOAN to COLDFUSION_USER;
grant insert,update,delete ON CF_USER_LOG to COLDFUSION_USER;
grant insert,update,delete ON CF_USER_ROLES to COLDFUSION_USER;
grant insert,update,delete ON CF_VERSION to COLDFUSION_USER;
grant insert,update,delete ON CF_VERSION_LOG to COLDFUSION_USER;
/* all privileges on CF* tables, mostly used for bulkloading various things.
/****************************      manage_transactions ******************************************/
grant insert,update,delete ON accn to manage_transactions;
grant insert,update,delete ON loan to manage_transactions;
grant insert,update,delete ON loan_item to     manage_transactions;
grant insert,update,delete ON trans to manage_transactions;
grant insert,update,delete ON borrow to manage_transactions;
grant insert,update,delete ON encumbrance to manage_transactions;
grant insert,update,delete ON permit to manage_transactions;
grant insert,update,delete ON addr to manage_transactions;
grant insert,update,delete ON electronic_address to manage_transactions;
grant insert,update,delete ON SHIPMENT to manage_transactions;
grant insert,update,delete ON PROJECT_SPONSOR to manage_transactions;
grant insert,update,delete ON PROJECT_REMARK to manage_transactions;
grant insert,update,delete ON PROJECT_PUBLICATION to manage_transactions;
grant insert,update,delete ON PROJECT to manage_transactions;
grant insert,update,delete ON PROJECT_AGENT to manage_transactions;
grant insert,update,delete ON PERMIT_SHIPMENT to manage_transactions;
grant insert,update,delete ON PERMIT_TRANS to manage_transactions;    
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
grant insert,update,delete on VIEWER to global_admin;
grant insert,update,delete on temp_allow_cf_user to global_admin;
/* Friggin UCB's crappy-assed duct taped setup does not implicitly allow SELECT on PUBLIC - WTF??
No need to run this at UAM, or anywhere else with a semi-sane setup */
declare wtf VARCHAR2(3000);
begin
    for t in (select table_name from user_tables) loop
        wtf := 'grant select on ' || t.table_name || ' to public';
        execute immediate (wtf);
    end loop;
end;        