-- 10 Apr 2007 - DLM
-- add pkey to enable materialized view
alter table coll_obj_other_id_num add coll_obj_other_id_num_id number;

drop sequence coll_obj_other_id_num_seq;
create sequence coll_obj_other_id_num_seq start with 1;


begin
for r in (select rowid from coll_obj_other_id_num) loop
	update coll_obj_other_id_num set coll_obj_other_id_num_id =  coll_obj_other_id_num_seq.nextval  where rowid= r.rowid;
end loop;
end;
/



ALTER TABLE coll_obj_other_id_num ADD PRIMARY KEY (coll_obj_other_id_num_id);
ALTER TABLE coll_obj_other_id_num
add CONSTRAINT fk_coll_id_cat_item
  FOREIGN KEY (collection_object_id)
  REFERENCES cataloged_item(collection_object_id);




CREATE OR REPLACE TRIGGER coll_obj_other_id_num_pkey                                         
 before insert  ON coll_obj_other_id_num  
 for each row 
    begin     
    	if :NEW.coll_obj_other_id_num_id is null then                                                                                      
    		select coll_obj_other_id_num_seq.nextval into :new.coll_obj_other_id_num_id from dual;
    	end if;                                
    end;                                                                                            
/
sho err


-- alter coll_obj_other_id_num to include tripartite "numbers"
-- must get rid of triggers to alter the table
drop trigger other_id_ct_check;
-- clean up some garbage
delete from coll_obj_other_id_num where collection_object_id not in (
	select collection_object_id from cataloged_item);

alter table coll_obj_other_id_num add other_id_prefix varchar2(60);
alter table coll_obj_other_id_num add other_id_number number;
alter table coll_obj_other_id_num add other_id_suffix varchar2(60);
alter table coll_obj_other_id_num add concat_char char(1) default '-';
alter table coll_obj_other_id_num add display_value varchar2(255);

create unique index u_other_id on coll_obj_other_id_num (display_value);
drop index PKEY_COLL_OBJ_OTHER_ID_NUM;
-- save known numerics







select count(*) from coll_obj_other_id_num where OTHER_ID_TYPE='AF' 
	and is_number(OTHER_ID_NUM) = 0;

update coll_obj_other_id_num set other_id_number = OTHER_ID_NUM, display_value=OTHER_ID_NUM 
	where OTHER_ID_TYPE = 'AF';

update coll_obj_other_id_num set other_id_prefix = OTHER_ID_NUM, display_value=OTHER_ID_NUM where 
	OTHER_ID_TYPE NOT IN ('AF','USNPC','LMNM','FN int','NCSM','UAM','WNMU','MVZ','LSU',
	'UAZ','BMNH','UFC','CMNH','DNHM','UWZM','KU','ZIN','Skull Seal Number','Department of Fish and Game','SDMNH',
	'NMMNH','NK Number','NMNH','NMSU','USNM','KUMNH','UMMZ','LACM','KSU','OSUM','YPM','RBCM');
	
	
update coll_obj_other_id_num set other_id_number = OTHER_ID_NUM, display_value=OTHER_ID_NUM where OTHER_ID_TYPE = 'AF';
update coll_obj_other_id_num set other_id_number = OTHER_ID_NUM, display_value=OTHER_ID_NUM where OTHER_ID_TYPE = 'IF';

-- stuff everything else in prefix


update coll_obj_other_id_num set concat_char = '-';
alter table coll_obj_other_id_num modify concat_char char(1) not null;
alter table coll_obj_other_id_num modify display_value varchar2(255) not null;

CREATE OR REPLACE TRIGGER coll_obj_disp_val
BEFORE INSERT or UPDATE ON coll_obj_other_id_num
FOR EACH ROW
declare disp_val coll_obj_other_id_num.display_value%TYPE;
BEGIN
	if (:NEW.other_id_prefix is not null) then
		disp_val := :NEW.other_id_prefix;
	end if;
	
	if (:NEW.other_id_number is not null) then
 		if (disp_val is not null) then
 			disp_val := disp_val || :NEW.concat_char || :NEW.other_id_number;
		else
 			disp_val := :NEW.other_id_number;
 		end if;
 	end if;
 	
 	if (:NEW.other_id_suffix is not null) then
 		if (disp_val is not null) then
 			disp_val := disp_val || :NEW.concat_char || :NEW.other_id_suffix;
		else
 			disp_val := :NEW.other_id_suffix;
 		end if;
 	end if;
 	:NEW.display_value := disp_val; 	
END;
/
sho err
-- wtf????
 alter table cataloged_item modify COLLECTION_CDE varchar2(4);
 update cataloged_item set collection_cde=trim(collection_cde);
 -- wtf again???
alter table collection modify COLLECTION_CDE varchar2(4);
update collection set COLLECTION_CDE=trim(COLLECTION_CDE);

-- rebuild dropped trigger other_id_ct_check in DDL/schema/constraints.sql
-- rebuild function in DDL/function/concatGenBank.sql
-- rebuild function in DDL/function/concatsingleotherid.sql
-- rebuild function in DDL/function/concattherid.sql
--- keep the old column around, but disable constraints on it
alter table coll_obj_other_id_num modify other_id_num NULL;

drop table cn;
select count(*) from coll_obj_other_id_num where other_id_type='';
select count(*) from coll_obj_other_id_num where other_id_type='';
select distinct(other_id_type) from coll_obj_other_id_num;

create table collnums as select 
	n.collection_object_id,
	n.other_id_num coll_num, 
	i.other_id_num coll_int
from
	coll_obj_other_id_num n,
	coll_obj_other_id_num i
where
	n.collection_object_id = i.collection_object_id and
	n.other_id_type='Field Num' and
	i.other_id_type='FN int'
;

alter table collnums add p varchar2(30);
alter table collnums add n number;
alter table collnums add s varchar2(30);
alter table collnums add ff varchar2(30);


update collnums set n = coll_int; -- get it to numeric format
update collnums set ff=1 where coll_int=coll_num;

CREATE OR REPLACE Procedure parse_numbers
IS
    id number;
    num varchar2(255);
    int varchar2(255);
	pos number;
	lgth number;
	pre varchar2(255);
	cnum varchar2(255);
	suf varchar2(255);
    cursor c1 is
    select collection_object_id,coll_num,n
      from collnums
      where ff is null;

BEGIN

    open c1;
    LOOP
    fetch c1 into id,num,int;
    EXIT WHEN c1%NOTFOUND; 
   -- dbms_output.put_line('id: ' || id || '; num: ' || num || '; int: ' || int);
    
	lgth := length(int); --select length(c1.n) from dual;
   	pos := INSTR(num, int); -- select INSTR(c1.coll_num, 'int') from dual;
   	pre := substr(num,1,pos-1);
  	--dbms_output.put_line('---->' || substr(pre,(length(pre))));
   	if substr(pre,length(pre)) = '-' then
  	--	dbms_output.put_line('pre ends with -');
  		pre := substr(pre,1,length(pre)-1);
  	end if;
   	suf := substr(num,pos + length(int));
  	if substr(suf,1,1) = '-' then
  	--	dbms_output.put_line('suf starts with -');
  		suf := substr(suf,2);
  	end if;
  	update collnums set p = pre,n=int,s=suf,ff=1 where collection_object_id = id;
  	
 --  dbms_output.put_line('lgth: ' || lgth || '; pos: ' || pos || '; pre: ' || pre || '; int: ' || int || '; suf: ' || suf);
 --  dbms_output.put_line('-------------------------------------------------');
END LOOP; 
    close c1;
end;
/
sho err

exec parse_numbers;


-- should now have everything in table collnums, just need to get it back into the correct table
select count(*) from coll_obj_other_id_num where other_id_type = '' and
	collection_object_id not in (
		select collection_object_id  from coll_obj_other_id_num where other_id_type = 'Field Num'
		);
-- MUST be 0 - if so, proceed

-- get rid of those Field Nums that have a FN Int and will be updated from the new table

 delete from coll_obj_other_id_num where other_id_type='Field Num'
 and collection_object_id IN (
 	select collection_object_id  from coll_obj_other_id_num where other_id_type = 'FN int'
 	);
 	
 delete from coll_obj_other_id_num where other_id_type='FN int';
 
 

 -- clean up the crap
 delete from collnums where collection_object_id not in  (select COLLECTION_OBJECT_ID from cataloged_item);
 
 insert into coll_obj_other_id_num (
 	COLLECTION_OBJECT_ID,
 	OTHER_ID_TYPE,
 	OTHER_ID_PREFIX,
 	OTHER_ID_NUMBER,
 	OTHER_ID_SUFFIX    )
 	 ( select 
 	 COLLECTION_OBJECT_ID,
 	 'Field Num',
 	 p,
 	 n,
 	 s
 	  from collnums
 	 );
 	
 
	