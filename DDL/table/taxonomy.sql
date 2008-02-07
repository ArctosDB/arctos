drop index XIE9TAXONOMY;
create unique index u_tax_sci_name on taxonomy(scientific_name);

alter table taxonomy modify author_text varchar2(255);


/* used to make taxonomy.scientific_name unique

create table duptax as
select * FROM taxonomy where 
scientific_name IN (
select 
	scientific_name
	from taxonomy having count(scientific_name) > 1
	group by 
	scientific_name
	)		
	;
	
	
 DECLARE
 CURSOR t IS
select	*	from duptax;
	x duptax%ROWTYPE; 
 
	begin
	
	OPEN t;
  LOOP
    FETCH t INTO x;
    EXIT WHEN t%NOTFOUND;
    	--dbms_output.put_line('good: ' || x.scientific_name);
    	for r in (select scientific_name, taxon_name_id from taxonomy where taxon_name_id <> x.taxon_name_id and scientific_name = x.scientific_name) loop
			--dbms_output.put_line('bad: ' || r.scientific_name);
update IDENTIFICATION_TAXONOMY set TAXON_NAME_ID =  x.taxon_name_id  where TAXON_NAME_ID =  r.taxon_name_id;
update CITATION set CITED_TAXON_NAME_ID =  x.taxon_name_id  where CITED_TAXON_NAME_ID = r.taxon_name_id;
update TAXON_RELATIONS set TAXON_NAME_ID = x.taxon_name_id  where TAXON_NAME_ID = r.taxon_name_id;
update TAXON_RELATIONS set RELATED_TAXON_NAME_ID =x.taxon_name_id  where RELATED_TAXON_NAME_ID = r.taxon_name_id;
update COMMON_NAME set TAXON_NAME_ID = x.taxon_name_id where TAXON_NAME_ID =  r.taxon_name_id;
delete from TAXONOMY where TAXON_NAME_ID = r.taxon_name_id;
 dbms_output.put_line('');
		end loop;
   --dbms_output.put_line('-------------------------------------------------------');
  END LOOP;
  CLOSE t;
	end;
	/


-- insert 
 CREATE OR REPLACE PROCEDURE itis_ftn IS
 CURSOR t IS
select	*	from itis_taxonomy;
	x itis_taxonomy%ROWTYPE; 
	ftn  itis_taxonomy.FULL_TAXON_NAME%TYPE;
    spc varchar2(1);
    num number;
BEGIN
	OPEN t;
  LOOP
  
    FETCH t INTO x;
    EXIT WHEN t%NOTFOUND;
    select count(*) into num from taxonomy where scientific_name = x.scientific_name;
    if num = 0 then
    ftn := NULL;
    spc := NULL;
    if x.subspecies is not null then
    	ftn := x.subspecies;
    	spc := ' ';
    end if;
    if x.species is not null then
    	ftn := x.species || spc || ftn;
    	spc := ' ';
    end if;
    if x.subgenus is not null then
    	ftn := x.subgenus || spc || ftn;
    	spc := ' ';
    end if;
    if x.tribe is not null then
    	ftn := x.tribe || spc || ftn;
    	spc := ' ';
    end if;
     if x.subfamily is not null then
    	ftn := x.subfamily || spc || ftn;
    	spc := ' ';
    end if;
    if x.family is not null then
    	ftn := x.family || spc || ftn;
    	spc := ' ';
    end if;
     if x.suborder is not null then
    	ftn := x.suborder || spc || ftn;
    	spc := ' ';
    end if;
    if x.phylorder is not null then
    	ftn := x.phylorder || spc || ftn;
    	spc := ' ';
    end if;
    if x.phylclass is not null then
    	ftn := x.phylclass || spc || ftn;
    	spc := ' ';
    end if;
    if ftn is not null then
   -- dbms_output.put_line(x.scientific_name);
    insert into taxonomy (
		TAXON_NAME_ID ,
		PHYLCLASS,
		PHYLORDER,
		SUBORDER,
		FAMILY,
		SUBFAMILY,
		GENUS,
		SUBGENUS,
		SPECIES,
		SUBSPECIES,
		VALID_CATALOG_TERM_FG,
		SOURCE_AUTHORITY,
		FULL_TAXON_NAME,
		SCIENTIFIC_NAME,
		AUTHOR_TEXT,
		TRIBE ,
		TAXON_REMARKS )
	values (
		seq_taxon_name_id.nextval,
		x.phylclass,
		x.phylorder,
		x.suborder,
		x.family,
		x.subfamily,
		x.genus,
		x.subgenus,
		x.species,
		x.subspecies,
		x.VALID_CATALOG_TERM_FG,
		'ITIS',
		ftn,
		x.scientific_name,
		x.author,
		x.tribe,
		'Imported from ITIS 6 Feb 2007'
		);
		--dbms_output.put_line(ftn);
		commit;
		end if;
		end if;
  END LOOP;
  CLOSE t;
  
  END;
/
-- exec itis_ftn;

 CREATE OR REPLACE PROCEDURE itis_ftn IS
 CURSOR t IS
select	*	from itis_relationships;
	x itis_relationships%ROWTYPE; 
    goodname  varchar2(255);
    goodid number;
   badname  varchar2(255);
    badid number;
    num number;
BEGIN
	OPEN t;
  LOOP
    FETCH t INTO x;
    EXIT WHEN t%NOTFOUND;
    select count(*) into num from taxonomy where scientific_name = x.good_name;
    if num = 1 then
    	select count(*) into num from taxonomy where scientific_name = x.bad_name;
			if num = 1 then
				select taxon_name_id into goodid from taxonomy where scientific_name = x.good_name;
				select taxon_name_id into badid from taxonomy where scientific_name = x.bad_name;
				select count(*) into num from taxon_relations where TAXON_NAME_ID = goodid and
				RELATED_TAXON_NAME_ID = badid and TAXON_RELATIONSHIP = x.reason;
				if num = 0 then
	    			insert into taxon_relations (
						TAXON_NAME_ID,
						RELATED_TAXON_NAME_ID,
						TAXON_RELATIONSHIP,
						RELATION_AUTHORITY
					) values (
						goodid,
						badid,
						x.reason,
						'ITIS'
					);
					commit;
				end if;
			end if;
		end if;
  END LOOP;
  CLOSE t;
  
  END;
/
-- exec itis_ftn;


sho err



sho err



*/