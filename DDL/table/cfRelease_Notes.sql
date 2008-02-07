create table cfRelease_notes (
	release_note_id number not null,
	release_number varchar2(20) not null,
	made_by_person varchar2(60),
	change_type varchar2(60),
	release_note varchar2(4000),
	code_change varchar2(4000)
);

create or replace public synonym cfRelease_notes for cfRelease_notes;
grant select on cfRelease_notes to public;
grant update,insert on cfRelease_notes to uam_update;

 CREATE OR REPLACE TRIGGER cfRelease_notes_id                                         
 before insert  ON cfRelease_notes  
 for each row 
    begin     
    	if :NEW.release_note_id is null then                                                                                      
    		select somerandomsequence.nextval into :new.release_note_id from dual;
    	end if;                       
    end;                                                                                            
/
sho err
	
	