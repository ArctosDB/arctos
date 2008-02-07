/* 
	This package runs against table FLAT as defined on 17-OCT-2007.	
	
	Requirements:
	
	create table flat_is_broken (
    	broke_date date,
    	collection_object_id number,
    	problem varchar2(255),
    	fixed number
    );
    
    OBJECTIVE: 
    	periodically check everything in flat against real data
    	record things that are or potentially are broken in table flat_is_broken
    	provide tools to fix said broken things
    	
    	Flat columnlist: delete from here as tools to find and deal with
    	the issues pop up here
    	

         CAT_NUM                                               NOT NULL NUMBER
         ACCN_ID                                               NOT NULL NUMBER
         COLLECTION_ID                                         NOT NULL NUMBER
         INSTITUTION_ACRONYM                                            VARCHAR2(20)
         COLLECTION_CDE                                                 VARCHAR2(5)
         COLLECTION                                                     VARCHAR2(20)
         COLLECTING_EVENT_ID                                            NUMBER
         BEGAN_DATE                                                     DATE
         ENDED_DATE                                                     DATE
         VERBATIM_DATE                                                  VARCHAR2(60)
         LAST_EDIT_DATE                                                 DATE
         INDIVIDUALCOUNT                                                NUMBER
         COLL_OBJ_DISPOSITION                                           VARCHAR2(20)
         COLLECTORS                                                     VARCHAR2(4000)
         FIELD_NUM                                                      VARCHAR2(4000)
         OTHERCATALOGNUMBERS                                            VARCHAR2(4000)
         GENBANKNUM                                                     VARCHAR2(4000)
         RELATEDCATALOGEDITEMS                                          VARCHAR2(4000)
         TYPESTATUS                                                     VARCHAR2(4000)
         SEX                                                            VARCHAR2(4000)
         PARTS                                                          VARCHAR2(4000)
         ENCUMBRANCES                                                   VARCHAR2(4000)
         ACCESSION                                                      VARCHAR2(81)
         GEOG_AUTH_REC_ID                                               NUMBER
         HIGHER_GEOG                                                    VARCHAR2(255)
         CONTINENT_OCEAN                                                VARCHAR2(50)
         COUNTRY                                                        VARCHAR2(50)
         STATE_PROV                                                     VARCHAR2(75)
         COUNTY                                                         VARCHAR2(50)
         FEATURE                                                        VARCHAR2(50)
         ISLAND                                                         VARCHAR2(50)
         ISLAND_GROUP                                                   VARCHAR2(50)
         QUAD                                                           VARCHAR2(30)
         SEA                                                            VARCHAR2(50)
         LOCALITY_ID                                                    NUMBER
         SPEC_LOCALITY                                                  VARCHAR2(255)
         MINIMUM_ELEVATION                                              NUMBER
         MAXIMUM_ELEVATION                                              NUMBER
         ORIG_ELEV_UNITS                                                VARCHAR2(2)
         MIN_ELEV_IN_M                                                  NUMBER
         MAX_ELEV_IN_M                                                  NUMBER
         DEC_LAT                                                        NUMBER(12,10)
         DEC_LONG                                                       NUMBER(13,10)
         DATUM                                                          VARCHAR2(55)
         ORIG_LAT_LONG_UNITS                                            VARCHAR2(20)
         VERBATIMLATITUDE                                               VARCHAR2(127)
         VERBATIMLONGITUDE                                              VARCHAR2(127)
         LAT_LONG_REF_SOURCE                                            VARCHAR2(255)
         COORDINATEUNCERTAINTYINMETERS                                  NUMBER
         GEOREFMETHOD                                                   VARCHAR2(255)
         LAT_LONG_REMARKS                                               VARCHAR2(4000)
         LAT_LONG_DETERMINER                                            VARCHAR2(184)
         IDENTIFICATION_ID                                              NUMBER
         SCIENTIFIC_NAME                                                VARCHAR2(255)
         IDENTIFIEDBY                                                   VARCHAR2(4000)
         MADE_DATE                                                      DATE
         REMARKS                                                        VARCHAR2(4000)
         HABITAT                                                        VARCHAR2(4000)
         ASSOCIATED_SPECIES                                             VARCHAR2(4000)
         TAXA_FORMULA                                                   VARCHAR2(10)
         GUID                                                           VARCHAR2(67)
         BASISOFRECORD                                                  VARCHAR2(17)
         DEPTH_UNITS                                                    VARCHAR2(20)
         MIN_DEPTH                                                      NUMBER
         MAX_DEPTH                                                      NUMBER
         MIN_DEPTH_IN_M                                                 NUMBER
         MAX_DEPTH_IN_M                                                 NUMBER
         COLLECTING_METHOD                                              VARCHAR2(255)
         COLLECTING_SOURCE                                              VARCHAR2(15)
         DAYOFYEAR                                                      NUMBER
         AGE_CLASS                                                      VARCHAR2(4000)
         ATTRIBUTES                                                     VARCHAR2(4000)
         VERIFICATIONSTATUS                                             VARCHAR2(40)
         SPECIMENDETAILURL                                              VARCHAR2(121)
         IMAGEURL                                                       VARCHAR2(121)
         FIELDNOTESURL                                                  VARCHAR2(121)
         CATALOGNUMBERTEXT                                              VARCHAR2(40)
         COLLECTORNUMBER                                                VARCHAR2(4000)
         VERBATIMELEVATION                                              VARCHAR2(84)
         YEAR                                                           NUMBER
         MONTH                                                          NUMBER
         DAY                                                            NUMBER

uam> 
*/
CREATE OR REPLACE PACKAGE flat_broke as
	/* show grouped problems */
	procedure show_stats;
	/* checks that flat and cataloged_item have the same number of records */
	PROCEDURE whurz_my_stuff;
	procedure fix_whurz_my_stuff;
	/* checks that flat taxonomy matches taxonomy for current identifications */
	procedure taxonomy_is_evil;
	procedure fix_taxonomy_is_evil;
END;
/
sho err

CREATE OR REPLACE PACKAGE BODY flat_broke as
error_msg varchar2(255);
some_number number;
some_other_number number;
some_varchar varchar2 (4000);
---------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE whurz_my_stuff 
is
begin
	select count(*) into some_number from flat;
	select count(*) into some_other_number from cataloged_item;
	
	if some_number != some_other_number then
		for m in (select collection_object_id from flat where collection_object_id not in (
			select collection_object_id from cataloged_item)) LOOP
			insert into flat_is_broken 
				(broke_date,problem,collection_object_id) 
			values 
				(sysdate,'cataloged item not in cataloged_item',m.collection_object_id);
		END LOOP;
		for m in (select collection_object_id from cataloged_item where collection_object_id not in (
			select collection_object_id from flat)) LOOP
			insert into flat_is_broken 
				(broke_date,problem,collection_object_id) 
			values 
				(sysdate,'cataloged item not in flat',m.collection_object_id);
		END LOOP;
	end if;
end;
----------------------------------------------------------------------
PROCEDURE fix_whurz_my_stuff 
is
begin
	delete from flat where
		collection_object_id IN (
			select collection_object_id from flat_is_broken
			where problem='cataloged item not in cataloged_item'
			and fixed is null
		);
	update flat_is_broken set fixed=1
		where problem='cataloged item not in cataloged_item';
	

	insert into flat (
		COLLECTION_OBJECT_ID,
		CAT_NUM,
		ACCN_ID,
		COLLECTION_ID,
		collection_cde,
		catalognumbertext
	)( select
		cataloged_item.COLLECTION_OBJECT_ID,
		CAT_NUM,
		ACCN_ID,
		COLLECTION_ID,
		collection_cde,
		to_char(cat_num)	
	from 
		cataloged_item,
		flat_is_broken
	where
		cataloged_item.collection_object_id = flat_is_broken.collection_object_id and
		problem='cataloged item not in flat'
	);
	update flat_is_broken set fixed=1
		where problem='cataloged item not in flat';
end;
------------------------------------------------------------------------------------------------------------------------
PROCEDURE taxonomy_is_evil 
is
begin
	insert into flat_is_broken (broke_date,problem,collection_object_id)
	(select sysdate,'bad taxonomy',flat.collection_object_id
	from
		flat,
		identification,
		identification_taxonomy,
		taxonomy
	where 
		flat.collection_object_id = identification.collection_object_id AND
		identification.identification_id = identification_taxonomy.identification_id AND
		identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id AND
		identification.accepted_id_fg=1 AND
		variable='A' and (
			flat.full_taxon_name is null OR 
			flat.full_taxon_name != 
				case when identification.TAXA_FORMULA like '%B' then 
		    		get_taxonomy(flat.collection_object_id,'full_taxon_name')
		    	else
		    		taxonomy.full_taxon_name
		    	end
		   	OR
			flat.phylclass != 
				case when identification.TAXA_FORMULA like '%B' then 
		    		get_taxonomy(flat.collection_object_id,'phylclass')
		    	else
		    		taxonomy.phylclass
		    	end
		   	OR
			flat.Kingdom != 
				case when identification.TAXA_FORMULA like '%B' then 
		    		get_taxonomy(flat.collection_object_id,'Kingdom')
		    	else
		    		taxonomy.Kingdom
		    	end
		    OR
			flat.Phylum != 
				case when identification.TAXA_FORMULA like '%B' then 
		    		get_taxonomy(flat.collection_object_id,'Phylum')
		    	else
		    		taxonomy.Phylum
		    	end
		    OR
			flat.phylOrder != 
				case when identification.TAXA_FORMULA like '%B' then 
		    		get_taxonomy(flat.collection_object_id,'phylOrder')
		    	else
		    		taxonomy.phylOrder
		    	end
    		OR
			flat.Family != 
				case when identification.TAXA_FORMULA like '%B' then 
		    		get_taxonomy(flat.collection_object_id,'Family')
		    	else
		    		taxonomy.Family
		    	end
		    OR
			flat.Genus != 
				case when identification.TAXA_FORMULA like '%B' then 
		    		get_taxonomy(flat.collection_object_id,'Genus')
		    	else
		    		taxonomy.Genus
		    	end
		     OR
			flat.Species != 
				case when identification.TAXA_FORMULA like '%B' then 
		    		get_taxonomy(flat.collection_object_id,'Species')
		    	else
		    		taxonomy.Species
		    	end
		     OR
			flat.Subspecies != 
				case when identification.TAXA_FORMULA like '%B' then 
		    		get_taxonomy(flat.collection_object_id,'Subspecies')
		    	else
		    		taxonomy.Subspecies
		    	end
		    OR
			flat.author_text != 
				case when identification.TAXA_FORMULA like '%B' then 
		    		get_taxonomy(flat.collection_object_id,'author_text')
		    	else
		    		taxonomy.author_text
		    	end
		    OR
			flat.nomenclatural_code != 
				case when identification.TAXA_FORMULA like '%B' then 
		    		get_taxonomy(flat.collection_object_id,'nomenclatural_code')
		    	else
		    		taxonomy.nomenclatural_code
		    	end
		    OR
			flat.infraspecific_rank != 
				case when identification.TAXA_FORMULA like '%B' then 
		    		get_taxonomy(flat.collection_object_id,'infraspecific_rank')
		    	else
		    		taxonomy.infraspecific_rank
		    	end

    	)
    );

end;
--------------------------------------------------------------------------
PROCEDURE fix_taxonomy_is_evil 
is
begin
	FOR r IN (SELECT collection_object_id FROM flat_is_broken
	    WHERE problem='bad taxonomy' AND
	    fixed IS NULL) LOOP
	    -- probably should have something more specific, but for now
	    -- just update the whole damned thing
	    update_flat(r.collection_object_id);
	    update flat_is_broken set fixed=1 where problem='bad taxonomy' AND collection_object_id=r.collection_object_id;
	    -- likely to die many times; commit after every fix
	    COMMIT;
	END LOOP;
end;
------------------------------------------------------------------------------------------
procedure show_stats is begin
	for r in (
	select problem,
	decode(fixed,
		null,'pending',
		'complete') fixed,
		count(*) c from
	flat_is_broken
	group by
	problem,fixed
	order by problem,fixed) loop
		dbms_output.put_line('Status: ' || r.fixed || '; Problem: ' || r.problem || '; count: ' || r.c);
	end loop;
end;
--------------------------------------------------------------------------

end;
/
sho err

-------------------------------------------------

--  exec flat_broke.whurz_my_stuff;
--  exec flat_broke.fix_whurz_my_stuff;
--  exec flat_broke.taxonomy_is_evil;
--  exec flat_broke.fix_taxonomy_is_evil;
--  exec flat_broke.show_stats;
