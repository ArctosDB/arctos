create table project_sponsor (
	project_sponsor_id number not null,
	project_id number not null,
	agent_name_id number not null,
	acknowledgement varchar2(255) not null);
	
ALTER TABLE project_sponsor ADD PRIMARY KEY (project_sponsor_id);

ALTER TABLE project_sponsor
add CONSTRAINT fk_project_id
  FOREIGN KEY (project_id)
  REFERENCES project(project_id);

ALTER TABLE project_sponsor
add CONSTRAINT fk_agent_name_id
  FOREIGN KEY (agent_name_id)
  REFERENCES agent_name(agent_name_id);

create sequence project_sponsor_seq;
create public synonym project_sponsor_seq for project_sponsor_seq;
grant select on project_sponsor_seq to public;

CREATE OR REPLACE TRIGGER trig_project_sponsor_id
	before INSERT on project_sponsor
	for each row
	BEGIN
	if :NEW.project_sponsor_id is null then                                                                                      
	    		select project_sponsor_seq.nextval into :new.project_sponsor_id from dual;
	end if;
END;
/

create public synonym project_sponsor for project_sponsor;

grant select on project_sponsor to public;

grant insert,update,delete on project_sponsor to uam_update;

