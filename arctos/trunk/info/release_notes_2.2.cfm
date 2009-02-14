<cfinclude template="/includes/_header.cfm">
<h2>
	Version 2.2 Release Notes:
</h2>
<span class="infoLink" onclick="document.getElementById('v2.2Code').style.display='block';">Show Code</span>
<div class="code" id="v2.2Code" style="display:none;"><!--------------------------- code ------------------>
	alter table flat add identification_id number;
	<br>
	 update flat set (identification_id) = (select
        identification_id from identification where
        accepted_id_fg=1 and
        identification.collection_object_id = flat.collection_object_id
        );
	<br>CREATE OR REPLACE PROCEDURE update_flat ....
	<br>drop trigger UP_FLAT_ID;
	<br>
	CREATE OR REPLACE FUNCTION CONCATIDRBYIDID ...
		<br>
		CREATE OR REPLACE TRIGGER A_FLAT_ID ....   
		<br>
		CREATE OR REPLACE TRIGGER update_id_after_taxon_change ....
		<br>update flat set (scientific_name) = (select
		     scientific_name from identification where
		     accepted_id_fg=1 and
		     identification.collection_object_id = flat.collection_object_id
		     );
		   <br>
			 create or replace view spec_with_loc.... 
			<br>create or replace trigger up_spec_with_loc ...

<br>
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

</div><!------------------------------------------------- /code div --------------------------------------->
<ul>
	<li>
		Add permits to loans
	</li>
	<li>
		Add Project Sponsors - searchable from projects and specimensearch, displayed in UAM Mammal Loan Form 
	</li>
	<li>
		Add loan sponsor acknowledgement
	</li>	
	<li>
		CF-based SNV INFO and SVN UP access
	</li>
	<li>
		Added dynamic creation of 800px high JPG at image upload
	</li>
	<li>
		DB handling of updated taxonomy propagation to identification
	</li>
	<li>
		Locality editing for single specimen.
	 	This is a huge change - read the documentation and make sure you understand what it does 
	 	before you start mashing buttons. 
		Note links to the traditional locality and geog forms - this is an addition, not a replacement.
	</li>
	<li>
		Data Entry handles UTM format (still missing: a tool to convert UTM to DD for mapping)
	</li>
	<li>
		Data Entry allows picking pre-existing locality (patched into v2.1)
	</li>
	<li>
		Data Entry has new criteria to define acceptable georeferences (matches table structure)
	</li>
	<li>
		MVZ can map, download, etc. from all instances (dynamic creation of application.ServerRootUrl)
	</li>
	<li>
		Bulkload parts updated to better handle existing parts and containers
	</li>
	<li>
		User logging enabled - see Tools/user access data
	</li>
	<li>
		Compressed library files and images should significantly decrease load time on slower connections
	</li>
	<li>
		Better handling of quotes in locality strings
	</li>
	<li>
		Better handling of bulk-change collecting events
	</li>
	<li>
		User loans fixed (MVZ)
	</li>
	<li>
		Better loan forms (MVZ)
	</li>
	<li>
		Revived HTML container search
	</li>
	<li>
		rebuilt Locality pick 
	</li>
</ul> 

<cfinclude template="/includes/_footer.cfm">