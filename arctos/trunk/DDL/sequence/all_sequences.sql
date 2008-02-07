drop sequence bulkloader_pkey;
select max(collection_object_id) + 1 from bulkloader;
create sequence bulkloader_pkey start with 56812;
drop public synonym bulkloader_pkey;
create public synonym bulkloader_pkey for bulkloader_pkey;
grant select on bulkloader_pkey to public;