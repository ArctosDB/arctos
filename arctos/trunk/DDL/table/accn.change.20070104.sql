 -- not quite ready to get rid of tripartite accn numbers yet,
 -- but we can disable the constraints on them to allow the new 
 -- forms to work
 
 alter table accn modify accn_num number null;
 alter table accn modify ACCN_NUMBER VARCHAR2(60) not null;
 
 