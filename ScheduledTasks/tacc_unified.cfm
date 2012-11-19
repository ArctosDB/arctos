<!----

	this replaces all previous attempts to link TACC Media to specimens
	
	-- this table holds original discovery of folders
	
	create table tacc_unified_folder (
		folder varchar2(255),
		file_count number,
		lastdate date default sysdate
	);
	
---->