/*
	24 Feb 2007 change:
	alter table bulkloader add utm_zone varchar2(3);
	alter table bulkloader add utm_ew varchar2(60);
	alter table bulkloader add utm_ns varchar2(60);
	alter table bulkloader add EXTENT varchar2(60);
	alter table bulkloader add GPSACCURACY varchar2(60);
	
*/

 alter table bulkloader modify part_lot_count_1 varchar2(5);
