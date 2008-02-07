 drop table bulkloader_stage;
create table bulkloader_stage as select * from bulkloader;
 delete from bulkloader_stage;
drop public synonym bulkloader_stage;
create public synonym bulkloader_stage for bulkloader_stage;
 grant insert,update,delete,select on bulkloader_stage to uam_query;
