	drop table loc_card_scan;
	
	create table loc_card_scan (
		loc_id number not null,
		accn_number varchar2(30) not null,
		accn_id number,
		barcode varchar2(255) not null,
		container_id number,
		dec_lat number,
		dec_long number,
		error_m number,
		age varchar2(255),
		formation varchar2(255),
		remark varchar2(255),
		who varchar2(255),
		when date
	);
	alter table loc_card_scan add localityID varchar2(255);
	
	alter table loc_card_scan add SeriesEpoch varchar2(255);
	alter table loc_card_scan add SystemPeriod varchar2(255);
	
	CREATE UNIQUE inded iu_loc_card_barcode ON loc_card_scan(barcode);
	
		<label for="">Series/Epoch</label>
		<select name="SeriesEpoch">
			<option value=""></option>
			<cfloop query="ctSeriesEpoch">
				<option value="#ATTRIBUTE_VALUE#">#ATTRIBUTE_VALUE#</option>
			</cfloop>
		</select>
		
		<label for="">Sy
	create unique index u_pi_l_c_s_barcode on loc_card_scan(barcode) tablespace uam_idx_1;
	
	create sequence sq_loc_card_scan_id;
	
	CREATE OR REPLACE TRIGGER tg_loc_card_scan_key                                         
 		before insert ON loc_card_scan
		 for each row
		    begin
		    	select
		    		sq_loc_card_scan_id.nextval,
		    		sys_context('USERENV', 'SESSION_USER'),
		    		sysdate 
		    	into 
		    		:new.loc_id,
		    		:new.who,
		    		:new.when
		    	from dual;
		    end;                                                                                            
		/
		

		CREATE PUBLIC SYNONYM loc_card_scan FOR loc_card_scan;
		GRANT all ON loc_card_scan to data_entry;
		
		drop table spec_scan;
		
		create table spec_scan (
			id number not null,
			loc_id number not null,
			idnum varchar2(255) not null,
			remark varchar2(255),
			barcode varchar2(255) not null,
			container_id number,
			taxon_name varchar2(255) not null,
			taxon_name_id number,
			part_name varchar2(255),
			who varchar2(255),
			when date
		);
		
		alter table spec_scan add collection_object_id number;
		alter table spec_scan add status varchar2(255);
		create unique index u_pi_spec_barcode on spec_scan(barcode) tablespace uam_idx_1;
	
	create sequence sq_spec_scan_id;
	
	CREATE OR REPLACE TRIGGER tg_spec_scan_key                                         
 		before insert ON spec_scan
		 for each row
		    begin
		    	select
		    		sq_spec_scan_id.nextval,
		    		sys_context('USERENV', 'SESSION_USER'),
		    		sysdate 
		    	into 
		    		:new.id,
		    		:new.who,
		    		:new.when
		    	from dual;
		    end;                                                                                            
		/
		

		CREATE PUBLIC SYNONYM spec_scan FOR spec_scan;
		GRANT all ON spec_scan to data_entry;
