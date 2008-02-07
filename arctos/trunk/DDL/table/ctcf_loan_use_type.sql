create table ctcf_loan_use_type (use_type varchar2(30));
create public synonym ctcf_loan_use_type for ctcf_loan_use_type;
grant select on ctcf_loan_use_type to public;
grant update,insert,delete on ctcf_loan_use_type to manage_codetables;
insert into ctcf_loan_use_type values ('borrow');
insert into ctcf_loan_use_type values ('sample');
insert into ctcf_loan_use_type values ('destroy');