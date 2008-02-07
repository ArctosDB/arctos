
create table cf_log (
log_id number not null,
username varchar2(255),
template varchar2(255),
access_date date,
query_string varchar2(4000),
reported_count number,
referring_url varchar2(4000)
)
;

create or replace public synonym cf_log for cf_log;
grant insert on cf_log to public;
grant select on cf_log to manage_authority,uam_update;

 CREATE OR REPLACE TRIGGER cf_log_id                                         
 before insert  ON cf_log  
 for each row 
    begin     
    	if :NEW.log_id is null then                                                                                      
    		select somerandomsequence.nextval into :new.log_id from dual;
    	end if;
		if :NEW.access_date is null then                                                                                      
    		:NEW.access_date:= sysdate;
    	end if;                                 
    end;                                                                                            
/
sho err