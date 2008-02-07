create role manage_locality;
grant update,insert,delete on LAT_LONG to manage_locality;
grant update,insert,delete on LOCALITY to manage_locality;
grant update,insert,delete on COLLECTING_EVENT to manage_locality;
grant update on cataloged_item to manage_locality;