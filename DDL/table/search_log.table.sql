create table search_log (
	log_id NUMBER NOT NULL,
	username varchar2(255),
	form_name varchar2(255),
	detail_level varchar2(255),
	select_clause varchar2(4000),
	join_clause varchar2(4000),
	where_clause varchar2(4000)
	);

create table search_log_terms (
	log_id number not null,
	term_name varchar2(4000),
	term_value varchar2(4000)
	);
	
create public synonym search_log for search_log;
grant select on search_log to public;
grant insert,update,delete on search_log to uam_update;


create public synonym search_log_terms for search_log_terms;
grant select on search_log_terms to public;
grant insert,update,delete on search_log_terms to uam_update;

create sequence search_log_seq;
create public synonym search_log_seq for search_log_seq;
grant select on search_log_seq to public;

	