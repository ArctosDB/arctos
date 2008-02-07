-- experiment in materialized views - seems to work, but needs more tuning that I can devote time to 
-- somebody help me.....
-- DLM 15 May 2007
-- get rid of old table flat and it's triggers
drop procedure update_flat;
drop trigger  A_FLAT_ACCN;
drop trigger UP_FLAT_OTHERIDS;
drop PROCEDURE update_flat_locid;
drop TRIGGER UP_FLAT_COLLECTOR;
drop TRIGGER AD_FLAT_COLLECTOR;
drop TRIGGER A_FLAT_COLLECTOR;
drop TRIGGER B_FLAT_COLLECTOR;
drop TRIGGER UP_FLAT_RELN;
drop TRIGGER AD_FLAT_RELN;
drop TRIGGER A_FLAT_RELN ;
drop TRIGGER B_FLAT_RELN;
drop TRIGGER UP_FLAT_PART;
drop TRIGGER AD_FLAT_PART;
drop TRIGGER A_FLAT_PART;
drop TRIGGER B_FLAT_PART;
drop TRIGGER UP_FLAT_COLLOBJ;
drop TRIGGER A_FLAT_COLLOBJ;
drop TRIGGER B_FLAT_COLLOBJ;
drop TRIGGER B_FLAT_ACCN;
drop TRIGGER UP_FLAT_COLLEVNT ;
drop TRIGGER UP_FLAT_ACCN;
drop A_FLAT_COLLEVNT;
drop TRIGGER B_FLAT_COLLEVNT;
drop TRIGGER UP_FLAT_SEX;
drop TRIGGER AD_FLAT_SEX;
drop TRIGGER A_FLAT_SEX;
drop trigger B_FLAT_SEX;
drop TRIGGER TI_FLAT_CATITEM;
drop TRIGGER UP_FLAT_CATITEM
drop TRIGGER AD_FLAT_CATITEM;
drop TRIGGER A_FLAT_CATITEM;
drop trigger B_FLAT_CATITEM;
drop TRIGGER UP_FLAT_GEOG;
drop  TRIGGER A_FLAT_GEOG;
drop TRIGGER B_FLAT_GEOG;
drop TRIGGER UP_FLAT_LAT_LONG;
drop TRIGGER AD_FLAT_LAT_LONG ;
drop TRIGGER A_FLAT_LAT_LONG;
drop TRIGGER B_FLAT_LAT_LONG;
drop TRIGGER UP_FLAT_LOCALITY;
drop TRIGGER A_FLAT_LOCALITY;
drop TRIGGER B_FLAT_LOCALITY;
drop TRIGGER UP_FLAT_AGENTNAME;
drop TRIGGER AD_FLAT_AGENTNAME;
drop TRIGGER A_FLAT_AGENTNAME;
drop TRIGGER B_FLAT_AGENTNAME;
drop trigger UP_FLAT_OTHERIDS
drop trigger AD_FLAT_OTHERIDS;
drop TRIGGER A_FLAT_OTHERIDS;
drop TRIGGER B_FLAT_OTHERIDS;
drop TRIGGER UP_FLAT_CITATION;
drop TRIGGER AD_FLAT_CITATION;
drop TRIGGER A_FLAT_CITATION;
drop TRIGGER B_FLAT_CITATION;
drop trigger UP_FLAT_ID;
drop TRIGGER B_FLAT_ID ;
drop trigger A_FLAT_ID ;
drop TRIGGER UP_FLAT_ID;
drop TRIGGER B_FLAT_agnt_ID;
drop TRIGGER a_FLAT_AGNT_ID;
drop TRIGGER UP_FLAT_AGNT_ID;
drop TRIGGER UP_FLAT_REMARK;
drop  TRIGGER B_FLAT_REMARK;
drop TRIGGER AD_FLAT_REMARK;
drop TRIGGER A_FLAT_REMARK ;
 drop trigger UP_FLAT_CATITEM;
 drop trigger up_flat_agnt_id;
 drop trigger A_FLAT_COLLEVNT;
 
drop table flat;



-- create a table holding all the concatenated stuff, and
-- include it in the materialized view so we don't get in trouble 
-- with non-deterministic functions
create table concatenated_fields AS
	select
	cataloged_item.collection_object_id,
	concatEncumbrances(cataloged_item.collection_object_id) InformationWithheld,
	get_taxonomy(cataloged_item.collection_object_id,'full_taxon_name') HigherTaxon,
	get_taxonomy(cataloged_item.collection_object_id,'phylclass') Class,
	get_taxonomy(cataloged_item.collection_object_id,'phylorder') pOrder,
	get_taxonomy(cataloged_item.collection_object_id,'family') Family,
	get_taxonomy(cataloged_item.collection_object_id,'genus') Genus,
	get_taxonomy(cataloged_item.collection_object_id,'species') SpecificEpithet,
	get_taxonomy(cataloged_item.collection_object_id,'infraspecific_rank') InfraspecificRank,
	get_taxonomy(cataloged_item.collection_object_id,'subspecies') InfraSpecificEpithet,
	get_taxonomy(cataloged_item.collection_object_id,'author_text') AuthorYearOfScientificName,
	concatColl(cataloged_item.collection_object_id) Collector,
	CONCATACCEPTEDIDENTIFYINGAGENT(cataloged_item.collection_object_id) IdentifiedBy,
  	concatattributevalue(cataloged_item.collection_object_id,'sex') Sex,
  	concatattributevalue(cataloged_item.collection_object_id,'age class') LifeStage,
	concatattribute(cataloged_item.collection_object_id) Attributes,
	ConcatImageUrl(cataloged_item.collection_object_id) ImageURL,
	concatparts(cataloged_item.collection_object_id) Preparations,
	concattypestatus(cataloged_item.collection_object_id) TypeStatus,
	concatsingleotherid(cataloged_item.collection_object_id,'collector number') CollectorNumber,
	concatsingleotherid(cataloged_item.collection_object_id,'original field number') FieldNumber,
	concatgenbank(cataloged_item.collection_object_id) GenBankNumber,
 	concatotherid(cataloged_item.collection_object_id) OtherCatalogNumbers,
	concatDarwinRelations(cataloged_item.collection_object_id) RelatedCatalogedItems
FROM
	cataloged_item;
	
-- Triggers to maintain concatenated table

CREATE OR REPLACE TRIGGER ins_cataloged_item_c                                                     
AFTER insert ON cataloged_item                                                                      
FOR EACH ROW
	BEGIN
		INSERT INTO concatenated_fields (
			collection_object_id,
			InformationWithheld,
			HigherTaxon,
			Class,
			pOrder,
			Family,
			Genus,
			SpecificEpithet,
			InfraspecificRank,
			InfraSpecificEpithet,
			AuthorYearOfScientificName,
			Collector,
			IdentifiedBy,
			Sex,
			LifeStage,
			Attributes,
			ImageURL,
			Preparations,
			TypeStatus,
			CollectorNumber,
			FieldNumber,
			GenBankNumber,
			OtherCatalogNumbers
		) values (
			:NEW.collection_object_id,
			concatEncumbrances(:NEW.collection_object_id),
			get_taxonomy(:NEW.collection_object_id,'full_taxon_name'),
			get_taxonomy(:NEW.collection_object_id,'phylclass'),
			get_taxonomy(:NEW.collection_object_id,'phylorder'),
			get_taxonomy(:NEW.collection_object_id,'family'),
			get_taxonomy(:NEW.collection_object_id,'genus'),
			get_taxonomy(:NEW.collection_object_id,'species'),
			get_taxonomy(:NEW.collection_object_id,'infraspecific_rank'),
			get_taxonomy(:NEW.collection_object_id,'subspecies'),
			get_taxonomy(:NEW.collection_object_id,'author_text') ,
			concatColl(:NEW.collection_object_id),
			CONCATACCEPTEDIDENTIFYINGAGENT(:NEW.collection_object_id),
		  	concatattributevalue(:NEW.collection_object_id,'sex'),
		  	concatattributevalue(:NEW.collection_object_id,'age class'),
			concatattribute(:NEW.collection_object_id),
			ConcatImageUrl(:NEW.collection_object_id),
			concatparts(:NEW.collection_object_id),
			concattypestatus(:NEW.collection_object_id),
			concatsingleotherid(:NEW.collection_object_id,'collector number'),
			concatsingleotherid(:NEW.collection_object_id,'original field number'),
			concatgenbank(:NEW.collection_object_id),
		 	concatotherid(:NEW.collection_object_id)
		 );
	END;
/


create or replace trigger coll_obj_other_id_num_bi
    before insert or update or delete on coll_obj_other_id_num
   begin
            state_pkg.newRows := state_pkg.empty;
   end;
    /
create or replace trigger coll_obj_other_id_num_afrer
    after insert or update or delete on coll_obj_other_id_num for each row
    begin
           if updating or inserting then
          	 state_pkg.newRows( state_pkg.newRows.count+1 ) := :new.collection_object_id;
          elsif deleting then
           state_pkg.newRows( state_pkg.newRows.count+1 ) := :old.collection_object_id;
          end if;         
   end;
   /
   
CREATE OR REPLACE TRIGGER up_other_id_c                                                     
AFTER update or insert or delete ON coll_obj_other_id_num                                                                      
	BEGIN
		for i in 1 .. state_pkg.newRows.count loop
			update concatenated_fields SET 
				CollectorNumber = concatsingleotherid(state_pkg.newRows(i),'collector number'),
				FieldNumber = concatsingleotherid(state_pkg.newRows(i),'original field number'),
				GenBankNumber = concatgenbank(state_pkg.newRows(i)),
				OtherCatalogNumbers = concatotherid(state_pkg.newRows(i))
			where
				collection_object_id = state_pkg.newRows(i);
	 	end loop;
	END;
/	
	
create or replace trigger citation_bi
    before insert or update or delete on citation
   begin
            state_pkg.newRows := state_pkg.empty;
   end;
    /
create or replace trigger citation_afrer
    after insert or update or delete on citation for each row
    begin
           if updating or inserting then
          	 state_pkg.newRows( state_pkg.newRows.count+1 ) := :new.collection_object_id;
          elsif deleting then
           state_pkg.newRows( state_pkg.newRows.count+1 ) := :old.collection_object_id;
          end if;         
   end;
   / 

create or replace trigger up_citation_c
    after insert or update or delete on citation
    begin
            for i in 1 .. state_pkg.newRows.count loop
                   update concatenated_fields SET 
						TypeStatus = concattypestatus(state_pkg.newRows(i))
					where
						collection_object_id = state_pkg.newRows(i);
            end loop;
    end;
   / 
   


create or replace trigger part_bi
    before insert or update or delete on specimen_part
   begin
            state_pkg.newRows := state_pkg.empty;
   end;
    /
create or replace trigger part_afrer
    after insert or update or delete on specimen_part for each row
    begin
           if updating or inserting then
          	 state_pkg.newRows( state_pkg.newRows.count+1 ) := :new.DERIVED_FROM_CAT_ITEM;
          elsif deleting then
           state_pkg.newRows( state_pkg.newRows.count+1 ) := :old.DERIVED_FROM_CAT_ITEM;
          end if;         
   end;
   / 
   
create or replace trigger up_parts_c
    after insert or update or delete on specimen_part
    begin
            for i in 1 .. state_pkg.newRows.count loop
                   update concatenated_fields SET 
						Preparations = concatparts(state_pkg.newRows(i))
					where
						collection_object_id = state_pkg.newRows(i);
            end loop;
    end;
   / 

create or replace trigger binary_object_bi
    before insert or update or delete on binary_object
   begin
            state_pkg.newRows := state_pkg.empty;
   end;
    /
create or replace trigger binary_object_afrer
    after insert or update or delete on binary_object for each row
    begin
           if updating or inserting then
          	 state_pkg.newRows( state_pkg.newRows.count+1 ) := :new.DERIVED_FROM_CAT_ITEM;
          elsif deleting then
           state_pkg.newRows( state_pkg.newRows.count+1 ) := :old.DERIVED_FROM_CAT_ITEM;
          end if;         
   end;
   / 
   
create or replace trigger up_binary_object_c
    after insert or update or delete on binary_object
    begin
            for i in 1 .. state_pkg.newRows.count loop
                   update concatenated_fields SET 
						ImageURL = ConcatImageUrl(state_pkg.newRows(i))
					where
						collection_object_id = state_pkg.newRows(i);
            end loop;
    end;
   / 

create or replace trigger attributes_bi
    before insert or update or delete on attributes
   begin
            state_pkg.newRows := state_pkg.empty;
   end;
    /
create or replace trigger attributes_afrer
    after insert or update or delete on attributes for each row
    begin
           if updating or inserting then
          	 state_pkg.newRows( state_pkg.newRows.count+1 ) := :new.collection_object_id;
          elsif deleting then
           state_pkg.newRows( state_pkg.newRows.count+1 ) := :old.collection_object_id;
          end if;         
   end;
   / 
 
CREATE OR REPLACE TRIGGER up_attributes_c                                                     
AFTER update or insert or delete ON attributes                                                                      
FOR EACH ROW
	BEGIN
		for i in 1 .. state_pkg.newRows.count loop
			update concatenated_fields SET 
				Sex = concatattributevalue(state_pkg.newRows(i),'sex'),
				LifeStage = concatattributevalue(state_pkg.newRows(i),'age class'),
				Attributes = concatattribute(state_pkg.newRows(i))
			where
				collection_object_id = state_pkg.newRows(i);
		end loop;
	END;
/


create or replace trigger identification_agent_bi
    before insert or update or delete on identification_agent
   begin
            state_pkg.newRows := state_pkg.empty;
   end;
    /
create or replace trigger identification_agent_afrer
    after insert or update or delete on identification_agent for each row
    begin
           if updating or inserting then
          	 state_pkg.newRows( state_pkg.newRows.count+1 ) := :new.identification_id;
          elsif deleting then
           state_pkg.newRows( state_pkg.newRows.count+1 ) := :old.identification_id;
          end if;         
   end;
   / 

create or replace trigger up_identification_agent_c
    after insert or update or delete on identification_agent
    DECLARE
	is_accepted number;
	colobjid number;
	begin
            for i in 1 .. state_pkg.newRows.count loop
            	select accepted_id_fg,collection_object_id INTO is_accepted,colobjid from identification 
					where identification_id = state_pkg.newRows(i);
			  if is_accepted = 1 then
                   update concatenated_fields SET IdentifiedBy = concatidentifiers(colobjid)
					where collection_object_id =colobjid;
				END IF;
            end loop;
    end;
   / 
   

create or replace trigger collector_bi
    before insert or update or delete on collector
   begin
            state_pkg.newRows := state_pkg.empty;
   end;
    /
create or replace trigger collector_afrer
    after insert or update or delete on collector for each row
    begin
           if updating or inserting then
          	 state_pkg.newRows( state_pkg.newRows.count+1 ) := :new.collection_object_id;
          elsif deleting then
           state_pkg.newRows( state_pkg.newRows.count+1 ) := :old.collection_object_id;
          end if;         
   end;
   / 
   
 CREATE OR REPLACE TRIGGER up_collector_c                                                     
AFTER update or insert or delete ON collector    
	BEGIN
		 for i in 1 .. state_pkg.newRows.count loop
		 	update concatenated_fields SET Collector = concatColl(state_pkg.newRows(i))
			where collection_object_id = state_pkg.newRows(i);
		  end loop;		
	END;
/
 
 

CREATE OR REPLACE TRIGGER del_cataloged_item_c
	AFTER DELETE ON cataloged_item                                                                      
	FOR EACH ROW
		BEGIN
			DELETE FROM concatenated_fields WHERE collection_object_id = :OLD.collection_object_id;
		END;
/

create or replace trigger biol_indiv_relations_bi
    before insert or update or delete on biol_indiv_relations
   begin
            state_pkg.newRows := state_pkg.empty;
   end;
    /
create or replace trigger biol_indiv_relations_afrer
    after insert or update or delete on biol_indiv_relations for each row
    begin
           if updating or inserting then
          	 state_pkg.newRows( state_pkg.newRows.count+1 ) := :new.collection_object_id;
          elsif deleting then
           state_pkg.newRows( state_pkg.newRows.count+1 ) := :old.collection_object_id;
          end if;         
   end;
   / 
   
   CREATE OR REPLACE TRIGGER up_relations_c                                                     
AFTER update or insert or delete ON biol_indiv_relations                                                                      
FOR EACH ROW
	BEGIN
		 for i in 1 .. state_pkg.newRows.count loop
			update concatenated_fields SET RelatedCatalogedItems = concatDarwinRelations(state_pkg.newRows(i))
			where collection_object_id = state_pkg.newRows(i);
		 end loop;
	END;
/	
 

create or replace trigger coll_object_encumbrance_bi
    before insert or update or delete on coll_object_encumbrance
   begin
            state_pkg.newRows := state_pkg.empty;
   end;
    /
create or replace trigger coll_object_encumbrance_afrer
    after insert or update or delete on coll_object_encumbrance for each row
    begin
           if updating or inserting then
          	 state_pkg.newRows( state_pkg.newRows.count+1 ) := :new.collection_object_id;
          elsif deleting then
           state_pkg.newRows( state_pkg.newRows.count+1 ) := :old.collection_object_id;
          end if;         
   end;
   / 
   
  

create or replace trigger up_coll_object_encumbrance_c
    after insert or update or delete on coll_object_encumbrance
    begin
            for i in 1 .. state_pkg.newRows.count loop
                   update concatenated_fields SET 
						InformationWithheld = concatEncumbrances(state_pkg.newRows(i))
					where
						collection_object_id = state_pkg.newRows(i);
            end loop;
    end;
   / 
 
 create or replace trigger identification_bi
    before insert or update or delete on identification
   begin
            state_pkg.newRows := state_pkg.empty;
   end;
    /
create or replace trigger identification_afrer
    after insert or update or delete on identification for each row
    begin
           if updating or inserting then
          	 state_pkg.newRows( state_pkg.newRows.count+1 ) := :new.collection_object_id;
          elsif deleting then
           state_pkg.newRows( state_pkg.newRows.count+1 ) := :old.collection_object_id;
          end if;         
   end;
   / 
   
  

create or replace trigger up_identification_c
    after insert or update or delete on identification
    begin
            for i in 1 .. state_pkg.newRows.count loop
            	update concatenated_fields SET 
					HigherTaxon = get_taxonomy(state_pkg.newRows(i),'full_taxon_name'),
					Class = get_taxonomy(state_pkg.newRows(i),'phylclass'),
					pOrder = get_taxonomy(state_pkg.newRows(i),'phylorder'),
					Family = get_taxonomy(state_pkg.newRows(i),'family'),
					Genus = get_taxonomy(state_pkg.newRows(i),'genus'),
					SpecificEpithet = get_taxonomy(state_pkg.newRows(i),'species'),
					InfraspecificRank = get_taxonomy(state_pkg.newRows(i),'infraspecific_rank'),
					InfraSpecificEpithet = get_taxonomy(state_pkg.newRows(i),'subspecies'),
					AuthorYearOfScientificName = get_taxonomy(state_pkg.newRows(i),'author_text')
				WHERE
					collection_object_id = state_pkg.newRows(i);
            end loop;
    end;
   / 
 
 
CREATE OR REPLACE TRIGGER up_identification_c                                                     
AFTER update or insert or delete ON identification                                                                      
FOR EACH ROW
	BEGIN
		dbms_output.put_line(:NEW.collection_object_id);
		dbms_output.put_line(:NEW.scientific_name);
		dbms_output.put_line(:OLD.scientific_name);
		
		IF :NEW.accepted_id_fg = 1 THEN
			update concatenated_fields SET 
				HigherTaxon = get_taxonomy(:NEW.collection_object_id,'full_taxon_name'),
				Class = get_taxonomy(:NEW.collection_object_id,'phylclass'),
				pOrder = get_taxonomy(:NEW.collection_object_id,'phylorder'),
				Family = get_taxonomy(:NEW.collection_object_id,'family'),
				Genus = get_taxonomy(:NEW.collection_object_id,'genus'),
				SpecificEpithet = get_taxonomy(:NEW.collection_object_id,'species'),
				InfraspecificRank = get_taxonomy(:NEW.collection_object_id,'infraspecific_rank'),
				InfraSpecificEpithet = get_taxonomy(:NEW.collection_object_id,'subspecies'),
				AuthorYearOfScientificName = get_taxonomy(:NEW.collection_object_id,'author_text')
			WHERE
				collection_object_id = :NEW.collection_object_id;
		END IF;
	END;
/	

/*
	Just in case....
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
*/

-- each table used in a fast refresh materialized view must have
-- a materialized view log with rowid, 
-- and rowid must appear in the materialized view

CREATE MATERIALIZED VIEW LOG ON cataloged_item with rowid;
CREATE MATERIALIZED VIEW LOG ON coll_object WITH rowid;
CREATE MATERIALIZED VIEW LOG ON collection  WITH rowid;
CREATE MATERIALIZED VIEW LOG ON collecting_event WITH rowid;
CREATE MATERIALIZED VIEW LOG ON locality WITH rowid;
CREATE MATERIALIZED VIEW LOG ON geog_auth_rec WITH rowid;
CREATE MATERIALIZED VIEW LOG ON identification with rowid;
CREATE MATERIALIZED VIEW LOG ON coll_object_remark with rowid;
CREATE MATERIALIZED VIEW LOG ON accn with rowid;
CREATE MATERIALIZED VIEW LOG ON trans with rowid;
CREATE MATERIALIZED VIEW LOG ON agent_name WITH primary key;
CREATE MATERIALIZED VIEW LOG ON lat_long WITH rowid;
CREATE MATERIALIZED VIEW LOG ON preferred_agent_name WITH rowid;

-- materialized view to replace preferred_agent_name
 -- drop materialized view preferred_agent_name;
 -- drop public synonym preferred_agent_name;
 
create table preferred_agent_name as select * from agent_name where agent_name_type='preferred';
ALTER TABLE preferred_agent_name ADD PRIMARY KEY (agent_id); 
ALTER TABLE preferred_agent_name drop primary key;

create unique index one_preferred_name on preferred_agent_name (agent_id);


ALTER TABLE lat_long
add CONSTRAINT fk_lat_long_determiner
  FOREIGN KEY (DETERMINED_BY_AGENT_ID)
  REFERENCES preferred_agent_name(agent_id);
  
  alter table lat_long drop constraint fk_lat_long_determiner;
  
  
CREATE OR REPLACE TRIGGER m_pref_agnt_name                                                     
AFTER update or insert or delete ON agent_name                                                                      
FOR EACH ROW
	BEGIN
		IF :NEW.agent_name_type='preferred' OR :old.agent_name_type='preferred' THEN
			IF INSERTING THEN
			
			    insert into preferred_agent_name (
			    	AGENT_NAME_ID,
			    	AGENT_ID,
			    	AGENT_NAME_TYPE,
			    	AGENT_NAME
			    ) values (
			    	:NEW.AGENT_NAME_ID,
			    	:NEW.AGENT_ID,
			    	:NEW.AGENT_NAME_TYPE,
			    	:NEW.AGENT_NAME
			    );
			ELSIF UPDATING THEN
			    update  preferred_agent_name SET
			    	AGENT_NAME_ID = :NEW.AGENT_NAME_ID,
			    	AGENT_NAME_TYPE = :NEW.AGENT_NAME_TYPE,
			    	AGENT_NAME = :NEW.AGENT_NAME
			    WHERE
			    	AGENT_ID = :NEW.agent_id;	    
			ELSIF DELETING THEN
			    DELETE FROM 
			    	preferred_agent_name
			    WHERE
			    	AGENT_ID = :OLD.agent_id;	 
			END IF;
		END IF;
	END;
/

create public synonym preferred_agent_name for preferred_agent_name;
grant select on preferred_agent_name to public;



	
-- materialized view of accepted lat/long and determiner

alter materialized view acc_lat_long refresh fast on demand;
alter materialized view acc_lat_long refresh fast on commit;

-- drop materialized view acc_lat_long;
create materialized view acc_lat_long 
	build immediate 
	refresh fast on commit 
	enable query rewrite
as select 
	preferred_agent_name.rowid pnamerowid,
	lat_long.rowid llrowid,
	preferred_agent_name.agent_id,
	LAT_LONG_ID,
	LOCALITY_ID,
	LAT_DEG ,
	DEC_LAT_MIN,
	LAT_MIN,
	LAT_SEC,
	LAT_DIR,
	LONG_DEG,
	DEC_LONG_MIN,
	LONG_MIN,
	LONG_SEC,
	LONG_DIR,
	DEC_LAT,
	DEC_LONG,
	DATUM,
	UTM_ZONE,
	UTM_EW,
	UTM_NS,
	ORIG_LAT_LONG_UNITS,
	DETERMINED_BY_AGENT_ID,
	agent_name LAT_LONG_DETERMINER,
	DETERMINED_DATE,
	LAT_LONG_REF_SOURCE,
	LAT_LONG_REMARKS,
	MAX_ERROR_DISTANCE,
	MAX_ERROR_UNITS,
	NEAREST_NAMED_PLACE,
	LAT_LONG_FOR_NNP_FG,
	FIELD_VERIFIED_FG,
	ACCEPTED_LAT_LONG_FG,
	EXTENT,
	GPSACCURACY,
	GEOREFMETHOD,
	VERIFICATIONSTATUS,
	LAT_LONG_SOURCE_TYPE,
	SPATIALFIT,
	decode(orig_lat_long_units,
		'decimal degrees',to_char(dec_lat) || 'd',
		'deg. min. sec.', to_char(lat_deg) || 'd ' || to_char(lat_min) || 'm ' || to_char(lat_sec) || 's ' || lat_dir,
		'degrees dec. minutes', to_char(lat_deg) || 'd ' || to_char(dec_lat_min) || 'm ' || lat_dir
	)  VERBATIMLATITUDE,
	decode(orig_lat_long_units,
		'decimal degrees',to_char(dec_long) || 'd',
		'deg. min. sec.', to_char(long_deg) || 'd ' || to_char(long_min) || 'm ' || to_char(long_sec) || 's ' || long_dir,
		'degrees dec. minutes', to_char(long_deg) || 'd ' || to_char(dec_long_min) || 'm ' || long_dir
	)  VERBATIMLONGITUDE,
	decode(max_error_units,
		'm',max_error_distance,
		'ft',max_error_distance * .3048,
		'km',max_error_distance * 1000,
		'mi',max_error_distance * 1609.344,
		'yd',max_error_distance * .9144) COORDINATEUNCERTAINTYINMETERS
 from 
 	lat_long,
 	preferred_agent_name
  where 
  	lat_long.DETERMINED_BY_AGENT_ID = preferred_agent_name.agent_id
  	 AND
	ACCEPTED_LAT_LONG_FG = 1;

  
  alter materialized view mvflat refresh fast on demand;
  
    alter materialized view mvflat refresh fast on commit;
    ;
    
    
-- materialized view of flattenable specimen data 
-- drop materialized view mvflat;
create materialized view mvflat 
	build immediate 
	refresh fast on COMMIT 
	enable query rewrite
as select 
 	cataloged_item.collection_object_id	collection_object_id,
 	coll_object.collection_object_id coll_object_pkey,
 	collection.collection_id,
 	collecting_event.collecting_event_id,
 	locality.locality_id,
 	geog_auth_rec.geog_auth_rec_id,
 	identification.identification_id,
 	coll_object_remark.collection_object_id coll_object_remark_pkey,
	accn.transaction_id accn_pkey,
	trans.transaction_id, 
	cataloged_item.rowid	r_a,
 	coll_object.rowid r_b,
 	collection.rowid r_c,
 	collecting_event.rowid r_d,
 	locality.rowid r_e,
 	geog_auth_rec.rowid r_f,
 	identification.rowid r_g,
 	coll_object_remark.rowid r_h,
	accn.rowid r_i,
	trans.rowid r_j, 		
 	decode(coll_object.last_edit_date,
 		NULL,COLL_OBJECT_ENTERED_DATE,
 		LAST_EDIT_DATE) DateLastModified,
	decode(coll_object.COLL_OBJECT_TYPE,
		'CI','PreservedSpecimen',
		'HO','HumanObservation',
		'OtherSpecimen') BasisOfRecord,
	collection.institution_acronym,
	collection.collection_cde,
	cat_num,
	coll_object_remarks,
	identification.scientific_name,
	nature_of_id,
	higher_geog,
	continent_ocean,
	island_group ,
	island,
	country,
	state_prov,
	county,
	sea,
	quad,
	feature,
	spec_locality,
	to_meters(minimum_elevation,orig_elev_units) MinimumElevationInMeters,
	to_meters(maximum_elevation,orig_elev_units) MaximumElevationInMeters,
	to_meters(MIN_DEPTH,DEPTH_UNITS) MinimumDepthInMeters,
	to_meters(MAX_DEPTH,DEPTH_UNITS) MaximumDepthInMeters,
  	collecting_method,
  	began_date,
  	ended_date,
	identification.made_date,
	verbatim_date,
	decode (ORIG_ELEV_UNITS,
		NULL,NULL,
		MINIMUM_ELEVATION || '-' || MAXIMUM_ELEVATION || ' ' || ORIG_ELEV_UNITS) VerbatimElevation,
	decode (DEPTH_UNITS,
		NULL,NULL,
		MIN_DEPTH || '-' || MAX_DEPTH || ' ' || DEPTH_UNITS) VerbatimDepth,
	coll_object.COLL_OBJ_DISPOSITION,
	coll_object.lot_count,
	trans.INSTITUTION_ACRONYM || ' ' || accn_number as accession,
	habitat,
	associated_species
 from 
 	cataloged_item, 
 	coll_object,
 	collection,
 	collecting_event,
 	locality,
 	geog_auth_rec,
 	identification,
 	coll_object_remark,
	accn,
	trans
where 
	cataloged_item.collection_object_id = coll_object.collection_object_id and
	cataloged_item.accn_id = accn.transaction_id and 
	accn.transaction_id = trans.transaction_id AND
	cataloged_item.collection_id = collection.collection_id and
	cataloged_item.collecting_event_id = collecting_event.collecting_event_id and
	collecting_event.locality_id = locality.locality_id and
	locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id and
	cataloged_item.collection_object_id = identification.collection_object_id and
	accepted_id_fg=1 AND
	cataloged_item.collection_object_id = coll_object_remark.collection_object_id (+)
;
 	
 -- trusty old table flat as a view combining out one trigger-maintained 
 -- concatenations table and
 -- two materialized views
 

 
 create or replace view flat as select 
 	mvflat.COLLECTION_OBJECT_ID,
 	collection_id,
 	mvflat.locality_id,
 	mvflat.collecting_event_id,
 	CAT_NUM,
 	INSTITUTION_ACRONYM,
 	COLLECTION_CDE,
 	DateLastModified LAST_EDIT_DATE,
 	lot_count INDIVIDUALCOUNT,
 	COLL_OBJ_DISPOSITION,
 	Collector COLLECTORS,
 	FieldNumber FIELD_NUM,
 	OtherCatalogNumbers OTHERCATALOGNUMBERS ,
 	GenBankNumber GENBANKNUM,
 	RelatedCatalogedItems RELATEDCATALOGEDITEMS,
 	TYPESTATUS,
 	SEX,
 	Preparations PARTS,
 	ACCESSION,
 	InformationWithheld ENCUMBRANCES,
 	BEGAN_DATE,
 	ENDED_DATE,
 	VERBATIM_DATE,
 	HIGHER_GEOG,
 	CONTINENT_OCEAN,
 	COUNTRY,
 	STATE_PROV,
 	COUNTY,
 	FEATURE,
 	ISLAND,
 	ISLAND_GROUP,
 	QUAD,
 	SEA,
 	SPEC_LOCALITY,
 	MinimumElevationInMeters MIN_ELEV_IN_M,
	MaximumElevationInMeters MAX_ELEV_IN_M,
	MinimumDepthInMeters,
	MaximumDepthInMeters,
	DEC_LAT,
	DEC_LONG,
	DATUM,
	ORIG_LAT_LONG_UNITS,
	VERBATIMLATITUDE,
	VERBATIMLONGITUDE,
	LAT_LONG_REF_SOURCE,
	COORDINATEUNCERTAINTYINMETERS,
	GEOREFMETHOD,
	LAT_LONG_REMARKS,
	LAT_LONG_DETERMINER,
	SCIENTIFIC_NAME,
	IDENTIFIEDBY,
	MADE_DATE,
	coll_object_remarks remarks,
	HABITAT,
	ASSOCIATED_SPECIES
FROM
	mvflat,
	concatenated_fields,
	acc_lat_long
WHERE
	mvflat.collection_object_id = concatenated_fields.collection_object_id (+) AND
	mvflat.locality_id = acc_lat_long.locality_id (+)
;

create or replace public synonym flat for flat;
grant select on flat to public;


create or replace view filtered_flat as select 
 	mvflat.COLLECTION_OBJECT_ID,
 	collection_id,
 	mvflat.locality_id,
 	mvflat.collecting_event_id,
 	CAT_NUM,
 	INSTITUTION_ACRONYM,
 	COLLECTION_CDE,
 	DateLastModified LAST_EDIT_DATE,
 	lot_count INDIVIDUALCOUNT,
 	COLL_OBJ_DISPOSITION,
 	case when InformationWithheld like '%mask collector%' then
         'Anonymous'
     else
         Collector
     end COLLECTORS,
    case when InformationWithheld like '%mask original field number%' then
         'Anonymous'
     else
         FieldNumber
     end FIELD_NUM,
 	OtherCatalogNumbers OTHERCATALOGNUMBERS ,
 	GenBankNumber GENBANKNUM,
 	RelatedCatalogedItems RELATEDCATALOGEDITEMS,
 	TYPESTATUS,
 	SEX,
 	Preparations PARTS,
 	ACCESSION,
 	InformationWithheld ENCUMBRANCES,
 	 case when InformationWithheld like '%mask year collected%' then
		to_date(to_char(began_date,'dd')||'-'||to_char(began_date,'Mon')||'-9999')
     else
         began_date
     end began_date,
      case when InformationWithheld like '%mask year collected%' then
		to_date(to_char(ended_date,'dd')||'-'||to_char(ended_date,'Mon')||'-9999')
     else
         ended_date
     end ended_date,
	 case when InformationWithheld like '%mask year collected%' then
         'Masked'
     else
         verbatim_date
     end verbatim_date,
 	HIGHER_GEOG,
 	CONTINENT_OCEAN,
 	COUNTRY,
 	STATE_PROV,
 	COUNTY,
 	FEATURE,
 	ISLAND,
 	ISLAND_GROUP,
 	QUAD,
 	SEA,
 	SPEC_LOCALITY,
 	MinimumElevationInMeters MIN_ELEV_IN_M,
	MaximumElevationInMeters MAX_ELEV_IN_M,
	MinimumDepthInMeters,
	MaximumDepthInMeters,
	 case when InformationWithheld like '%mask coordinates%' then
         0
     else
         dec_lat
     end dec_lat,
     case when InformationWithheld like '%mask coordinates%' then
         0
     else
         dec_long
     end dec_long,
     datum ,
     orig_lat_long_units,
      case when InformationWithheld like '%mask coordinates%' then
         'Masked'
     else
         VERBATIMLATITUDE
     end VERBATIMLATITUDE,
     case when InformationWithheld like '%mask coordinates%' then
         'Masked'
     else
         VERBATIMLONGITUDE
     end VERBATIMLONGITUDE,
	LAT_LONG_REF_SOURCE,
	COORDINATEUNCERTAINTYINMETERS,
	GEOREFMETHOD,
	LAT_LONG_REMARKS,
	LAT_LONG_DETERMINER,
	SCIENTIFIC_NAME,
	IDENTIFIEDBY,
	MADE_DATE,
	coll_object_remarks remarks,
	HABITAT,
	ASSOCIATED_SPECIES
FROM
	mvflat,
	concatenated_fields,
	acc_lat_long
WHERE
	mvflat.collection_object_id = concatenated_fields.collection_object_id (+) AND
	mvflat.locality_id = acc_lat_long.locality_id (+) AND
     (InformationWithheld is null OR InformationWithheld NOT LIKE '%mask record%');
;

create or replace public synonym filtered_flat for filtered_flat;
grant select on filtered_flat to public;

