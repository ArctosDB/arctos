-- path back to flat trigger-maintained table
DROP TABLE concatenated_fields;
DROP TRIGGER ins_cataloged_item_c ;
DROP  trigger coll_obj_other_id_num_bi;
DROP trigger coll_obj_other_id_num_afrer;
DROP TRIGGER up_other_id_c ;
DROP  trigger citation_bi;
DROP  trigger citation_afrer;
DROP TRIGGER up_citation_c;
DROP  trigger part_bi;
DROP trigger part_afrer;
DROP trigger up_parts_c;
DROP trigger binary_object_bi;
DROP  trigger binary_object_afrer;
DROP TRIGGER up_binary_object_c;
DROP trigger attributes_bi;
DROP  trigger attributes_afrer;
DROP TRIGGER up_attributes_c ;
DROP trigger identification_agent_bi;
DROP TRIGGER identification_agent_afrer;
DROP TRIGGER up_identification_agent_c;
DROP trigger collector_bi;
DROP trigger collector_afrer;
DROP TRIGGER up_collector_c;
DROP TRIGGER del_cataloged_item_c;
DROP TRIGGER biol_indiv_relations_bi;
DROP trigger biol_indiv_relations_afrer;
DROP TRIGGER up_relations_c;
DROP  trigger coll_object_encumbrance_bi;
DROP trigger coll_object_encumbrance_afrer;
DROP TRIGGER up_coll_object_encumbrance_c;
DROP trigger identification_bi;
DROP trigger identification_afrer;
DROP  trigger up_identification_c;
DROP  TRIGGER up_identification_c;

DROP  index one_preferred_name;
DROP  table preferred_agent_name ;
  alter table lat_long drop constraint fk_lat_long_determiner;
  DROP TRIGGER m_pref_agnt_name;
  
  DROP materialized view acc_lat_long ;
  DROP materialized view mvflat ;
  DROP VIEW flat;
  
  DROP VIEW filtered_flat;
  
  
 CREATE OR REPLACE  VIEW ACCEPTED_LAT_LONG
(LAT_LONG_ID, LOCALITY_ID, LAT_DEG, DEC_LAT_MIN, LAT_MIN, 
 LAT_SEC, LAT_DIR, LONG_DEG, DEC_LONG_MIN, LONG_MIN, 
 LONG_SEC, LONG_DIR, DEC_LAT, DEC_LONG, DATUM, 
 UTM_ZONE, UTM_EW, UTM_NS, ORIG_LAT_LONG_UNITS, DETERMINED_BY_AGENT_ID, 
 DETERMINED_DATE, LAT_LONG_REF_SOURCE, LAT_LONG_REMARKS, MAX_ERROR_DISTANCE, MAX_ERROR_UNITS, 
 NEAREST_NAMED_PLACE, LAT_LONG_FOR_NNP_FG, FIELD_VERIFIED_FG, ACCEPTED_LAT_LONG_FG, EXTENT, 
 GPSACCURACY, GEOREFMETHOD, VERIFICATIONSTATUS)
AS 
select LAT_LONG_ID,LOCALITY_ID,LAT_DEG,DEC_LAT_MIN,LAT_MIN,LAT_SEC,LAT_DIR,
  LONG_DEG,DEC_LONG_MIN,LONG_MIN,LONG_SEC,LONG_DIR,DEC_LAT,
DEC_LONG,DATUM,UTM_ZONE,UTM_EW,UTM_NS,ORIG_LAT_LONG_UNITS,DETERMINED_BY_AGENT_ID,
DETERMINED_DATE,LAT_LONG_REF_SOURCE,LAT_LONG_REMARKS,MAX_ERROR_DISTANCE,
MAX_ERROR_UNITS,NEAREST_NAMED_PLACE,LAT_LONG_FOR_NNP_FG,FIELD_VERIFIED_FG,
ACCEPTED_LAT_LONG_FG,EXTENT,GPSACCURACY,GEOREFMETHOD,VERIFICATIONSTATUS from lat_long where ACCEPTED_LAT_LONG_FG=1;

CREATE OR REPLACE PUBLIC SYNONYM ACCEPTED_LAT_LONG FOR ACCEPTED_LAT_LONG;
GRANT SELECT ON ACCEPTED_LAT_LONG TO PUBLIC;

 CREATE OR REPLACE  VIEW PREFERRED_AGENT_NAME
(AGENT_NAME, AGENT_ID)
AS 
( select agent_name, agent_id from agent_name where agent_name_type = 'preferred');

CREATE OR REPLACE PUBLIC SYNONYM PREFERRED_AGENT_NAME FOR PREFERRED_AGENT_NAME;
    GRANT SELECT ON PREFERRED_AGENT_NAME TO PUBLIC;

 
drop MATERIALIZED VIEW LOG ON cataloged_item;
drop MATERIALIZED VIEW LOG ON coll_object;
drop MATERIALIZED VIEW LOG ON collection;
drop MATERIALIZED VIEW LOG ON collecting_event;
drop MATERIALIZED VIEW LOG ON locality;
drop MATERIALIZED VIEW LOG ON geog_auth_rec;
drop MATERIALIZED VIEW LOG ON lat_long;
drop MATERIALIZED VIEW LOG ON identification;
drop MATERIALIZED VIEW LOG ON coll_object_remark;
drop MATERIALIZED VIEW LOG ON accn;
drop MATERIALIZED VIEW LOG ON trans;
drop MATERIALIZED VIEW LOG ON agent_name;
drop MATERIALIZED VIEW LOG ON taxonomy;
drop MATERIALIZED VIEW LOG ON encumbrance;
drop MATERIALIZED VIEW LOG ON coll_object_encumbrance;
drop MATERIALIZED VIEW LOG ON collector;
drop MATERIALIZED VIEW LOG ON attributes;
drop MATERIALIZED VIEW LOG ON biol_indiv_relations;
drop MATERIALIZED VIEW LOG ON coll_obj_other_id_num;
drop MATERIALIZED VIEW LOG ON citation;
drop MATERIALIZED VIEW LOG ON preferred_agent_name;
drop MATERIALIZED VIEW LOG ON lat_long;

