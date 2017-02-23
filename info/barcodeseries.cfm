<!----

	drop table cf_barcodeseries;

	create table cf_barcodeseries (
		key number not null,
		barcodeseriessql varchar2(255) not null,
		barcodeseriestxt varchar2(255) not null,
		institution  varchar2(255) not null,
		notes varchar2(4000),
		createdate date not null,
		whodunit varchar2(255) not null
	);

	create or replace public synonym cf_barcodeseries for cf_barcodeseries;

	grant all on cf_barcodeseries to manage_container;

	grant select on cf_barcodeseries to public;

	create unique index pk_cf_barcodeseries on cf_barcodeseries (key) tablespace uam_idx_1;

	 CREATE OR REPLACE TRIGGER trg_cf_barcodeseries_key
	 before insert  ON cf_barcodeseries
	 for each row
	    begin
	    	select somerandomsequence.nextval into :new.key from dual;
	    end;
	/
	sho err

	-- old data from https://docs.google.com/spreadsheets/d/1Rmj7NCudfdpo2DWwMHZk4FOYM-_anrElznYnjK4nWtY/edit#gid=0



update cf_barcodeseries set whodunit='jmetzgar' where barcodeseriestxt='H1000000-H1279999';








	delete from cf_barcodeseries;


	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^[0-9]*$'') and to_number(substr(barcode,2)) between 2 and 405000',
		'all integers (above 1)',
		'UAM',
		 'All UAM bare-number barcodes including original pre-Arctos catalog number barcodes and subsequent integer-only series Exclude 0 and 1 (used for "trashcans").',
		 '2008-11-05',
		 'brandy'
	);



	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^C[0-9]*$'') and to_number(substr(barcode,2)) between 1 and 89000',
		'C1-C89000',
		'UAM',
		 'UAM C{number} series used for various purposes',
		 '2008-11-05',
		 'brandy'
	);


	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^H[0-9]*$'') and to_number(substr(barcode,2)) between 100001 and 1279999',
		'H1000000-H1279999',
		'UAM',
		 'Herbarium sheet labels',
		 '2008-11-05',
		 'brandy'
	);





	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'barcode=''0''',
		'0',
		'UAM',
		'UAM "trashcan"',
		'2008-11-05',
		'dlm'
	);

	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^R[0-9]*C[0-9]*$'')',
		'R[number]C[number]',
		'UAM',
		'various UAM range cases; inconsistent format (R36C01; R131C6) due to legacy data and space constraints.',
		'2009-10-09',
		'dlm'
	);
	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^RANGE[0-9]*$'')',
		'RANGE[number]',
		'UAM',
		'various UAM	Ranges. Cases are children.',
		'2009-10-09',
		'dlm'
	);
	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^ROOM[0-9]*$'')',
		'ROOM[number]',
		'UAM',
		'various UAM Inconsistent leading zeroes',
		'2009-10-09',
		'dlm'
	);

	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^T[0-9]*$'') and to_number(substr(barcode,2)) between 1001 and 3000',
		'T1001-T3000',
		'UAM',
		'Fish?',
		'2009-10-09',
		'dlm'
	);


	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^L[0-9]*$'') and to_number(substr(barcode,2)) between 32400 and 761304',
		'L032400 - L761304',
		'UAM',
		'THESE WERE THE FIRST BARCODES WE CREATED FOR SHELVES AND TRAYS IN THE RANGE IN THE 1990''S.  "L" FOR LOCATION, AND THE FIRST 2 DIGITS REFERRED TO THE RANGE NUMBER, DIGITS 3 AND 4 WERE THE CASE NUMBER AND THE LAST TWO WERE THE SHELF OR TRAY.  Probably mammals only.  AFTER WE ARE FINISHED MOVING SPECIMENS INTO NEW CABINETS WE CAN PROBABLY GET RID OF THESE.',
		'2009-10-09',
		'dlm'
	);

	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^LN2-[0-9]-[A-Z][0-9]$'')',
		'LN2-2-A1 - LN2-3-F2',
		'UAM',
		'Nitrogen freezers positions (these are older labels that will be replaced by barcodes without the dashes when LN2 freezers 2 and 3 are in use.',
		'2009-10-09',
		'dlm'
	);

	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^LN2[0-9][A-Z][0-9]$'')',
		'LN21A1	- LN23F5',
		'UAM',
		'UAM Nitrogen freezer positions',
		'2009-10-09',
		'dlm'
	);

	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^LN2FRZR[0-9]$'')',
		'LN2FRZR1 - LN2FRZR3',
		'UAM',
		'UAM Nitrogen freezers',
		'2009-10-09',
		'dlm'
	);
	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^ES [0-9]*$'') and to_number(substr(barcode,4)) between 1 and 19999',
		'ES 000001 - ES 019999',
		'UAM',
		'Paleo specimen labels',
		'2009-10-09',
		'dlm'
	);
	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^ES[0-9]*$'') and to_number(substr(barcode,3)) between 1 and 60999',
		'ES1 - ES500000',
		'UAM',
		'Updated Paleo specimen labels',
		'2009-10-09',
		'dlm'
	);



	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^MLFRZ[0-9]{1}$'') and to_number(substr(barcode,6)) between 1 and 4',
		'MLFRZ[1-4]',
		'UAM',
		'freezers in the UAM molecular lab',
		'2009-10-09',
		'fskbh'
	);

	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^UAM[0-9]*$'') and to_number(substr(barcode,4)) between 100000001 and 109000000',
		'UAM100000001 - UAM109000000',
		'UAM',
		'UAM Insects specimen labels',
		'2009-10-09',
		'dlm'
	);
	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^FRZR[0-9]$'')',
		'FRZR1 - FRZR9',
		'UAM',
		'UAM freezers',
		'2009-10-09',
		'fskbh1'
	);


	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^FRZR[0-9]-[0-9]{1,2}[A-D]$'')',
		'FRZR1-01A - FRZR9-12D',
		'UAM',
		'UAM freezers',
		'2009-10-09',
		'fskbh1'
	);


	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^MSB [0-9]*$'') and to_number(substr(barcode,5)) between 140837 and 140841',
		'MSB 140837	- MSB 140841',
		'MSB',
		'MSB	jars?',
		'2009-10-09',
		'dlm'
	);

	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^MVZ[0-9]*$'') and to_number(substr(barcode,4)) between 1000 and 500000',
		'MVZ1000 - MVZ500000',
		'MVZ',
		'MVZ: various',
		'2009-10-14',
		'ccicero'
	);
	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'barcode=''1''',
		'1',
		'MVZ',
		'MVZ: trashcan',
		'2009-10-14',
		'ccicero'
	);

	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^MSB[0-9]*$'') and to_number(substr(barcode,4)) between 100001 and 1050000',
		'MSB100001	- MSB1050000',
		'MSB',
		'MSB birds',
		'2009-10-09',
		'andy'
	);

	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^DGR[0-9]*$'') and to_number(substr(barcode,4)) between 10001 and 20001',
		'DGR10001	- DGR20001',
		'MSB',
		'MSB DGR',
		'2009-10-09',
		'gordon'
	);


	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^P[A-Z0-9]{1,14}$'')',
		'P0	- PZZZZZZZZZZZZZZ',
		'MSB',
		'MSB; Prefix P for parasites, followed by all base-36 (A-Z0-9) values for small circular microscope-slide labels.  DataMatrix.',
		'2009-10-09',
		'gordon'
	);

	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^KNWRC[0-9]*$'')',
		'KNWRC[number]',
		'KNWR',
		'generic container label for KNWR containers, used in both KNWR:Herb and KNWR:Ento collections.',
		'2013-03-12',
		'mbowser'
	);


	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^UDCC_TCN [0-9]*$'')',
		'UDCC_TCN [number]',
		'KNWR',
		'These are 2D barcode labels used by the University of Delaware Entomology Collection (UDCC), added to specimens loaned from KNWR to UDCC.',
		'2013-04-26',
		'mbowser'
	);

	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^UDCC_NRI [0-9]*$'')',
		'UDCC_NRI [number]',
		'KNWR',
		'These are 2D barcode labels used by the University of Delaware Entomology Collection (UDCC), added to specimens loaned from KNWR to UDCC.',
		'2013-04-26',
		'mbowser'
	);

	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^A[A-Z0-9]{4}$'')',
		'A24E3 - A36YY',
		'MSB',
		'50,000 cryotube labels in base-36 Datamatrix',
		'2013-04-26',
		'jldunnum'
	);


	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^BOWIE [0-9]{1,3}$'') and to_number(substr(barcode,7)) between 1 and 500',
		'BOWIE 1 - BOWIE 500',
		'MVZ',
		'MVZ uncataloged bird samples collected by Raurie Bowie and colleagues, labels for his freezer boxes',
		'2015-04-16',
		'ccicero'
	);


	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^BIRD [0-9]{1,3}$'') and to_number(substr(barcode,6)) between 1 and 500',
		'BIRD 1	- BIRD 500',
		'MVZ',
		'MVZ uncataloged bird samples (non-Bowie accns), labels for freezer boxes',
		'2015-04-16',
		'ccicero'
	);

	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^A0[0-9]{4}$'') and to_number(substr(barcode,3)) between 1 and 5000',
		'A00001	- A05000',
		'NMU',
		'NMU 3 part barcode labels for use on cryotubes, parasite vials, and skull tags',
		'2015-07-07',
		'ftkeg'
	);
	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit£
	) values (
		'regexp_like(barcode,''^NMU[0-9]*$'') and to_number(substr(barcode,4)) between 1 and 100000',
		'NMU1 - NMU100000',
		'NMU',
		'NMU generic label for specimens and containers',
		'2015-07-07',
		'ftkeg'
	);








	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^BOLD-[0-9A-Z]{3}$'')',
		'BOLD-NNN',
		'KNWR',
		'These are 2D barcode labels on lifescanner vials (http://lifescanner.net/)',
		'2015-07-07',
		'mbowser'
	);
	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^DGR[0-9]{1,2}-[0-9]{1,2}-[0-9]{1.2}$'')',
		'DGR1-1-1 - DGR18-33-12',
		'MSB',
		'MSB:DGR	Barcodes for legacy DGR freezer racks for mechanical freezers',
		'2015-07-07',
		'campmlc'
	);

	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'barcode  in (''VLSB 1143'',''CAS'',''MTEC'',''SEMC'',''USDA-ARS'',''USNM'',''OSAC'',''PMJ-Phyletisches-Museum'')',
		'various rooms n junk',
		'MVZ',
		'Random pile of random barcodes used for weird one-off things.',
		'2015-07-07',
		'ccicero'
	);

	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^BBSL[0-9]*$'') to_number(substr(barcode,5)) between 700000 and 800000',
		'UAM',
		'MSB',
		'USDA ARS for UAM:Ento',
		'2015-07-07',
		'ffdss'
	);

	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^JPS[0-9]*$'') to_number(substr(barcode,4)) between 30000 and 40000',
		'UAM',
		'MSB',
		'USDA ARS for UAM:Ento',
		'2015-07-07',
		'ffdss'
	);

































select BARCODESERIESSQL from cf_barcodeseries where key=102284020;

update cf_barcodeseries set barcodeseriessql='regexp_like(barcode,''^[0-9]*$'') and to_number(barcode) between 2 and 405000' where key=102284020;





	CREATE OR REPLACE FUNCTION is_claimed_barcode (barcode in varchar) return varchar
as
	r varchar2(255);
	c number;
begin
	for r in (select barcodeseriessql from cf_barcodeseries) loop
		dbms_output.put_line(r.barcodeseriessql);
		execute immediate 'select count(*) into c from dual where ' || r.barcodeseriessql;
		dbms_output.put_line(c);
	end loop;

	return r;
	--exception	when others then return 0;
end;
/


create table temp_all_barcode as select barcode from container where barcode is not null;


CREATE OR REPLACE PROCEDURE temp_update_junk IS
	rslt varchar2(255):='FAIL';
		rsql varchar2(255);
		ssmt varchar2(255);
		c number;
BEGIN
		for r in (select barcodeseriessql from cf_barcodeseries) loop
		begin
				--rsql:=replace(r.barcodeseriessql,'barcode','''' || barcode || '''');
				ssmt := 'delete from temp_all_barcode where ' || r.barcodeseriessql;
				dbms_output.put_line(ssmt);
				execute immediate ssmt;

				exception when others then
					dbms_output.put_line('FAIL: ' || ssmt);

		end;
		end loop;
	end;
/
sho err;

exec temp_update_junk;


delete from temp_all_barcode where is_claimed_barcode(barcode)='PASS';

select barcode from temp_all_barcode order by barcode;

select barcode from temp_all_barcode where trim(barcode) != barcode;

select barcode from container where trim(barcode) != barcode;

select is_claimed_barcode('1') from dual;



alter table temp_all_barcode add institution_acronym varchar2(20);

update temp_all_barcode set institution_acronym=(select institution_acronym from container where temp_all_barcode.barcode=container.barcode);

update temp_all_barcode set barcode=trim(barcode) where trim(barcode) != barcode;

-- cleanup

delete from container where barcode='UAM100290396';
delete from container where barcode='UAM100306951';
update container set barcode='UAM100290396' where barcode='6UAM100290396';
update container set barcode='UAM100306951' where barcode='6UAM100306951';


BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'J_temp_update_junk',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'temp_update_junk',
    enabled     => TRUE,
    end_date    => NULL
  );
END;
/

select STATE,LAST_START_DATE,NEXT_RUN_DATE from all_scheduler_jobs where JOB_NAME='J_TEMP_UPDATE_JUNK';


select count(*) from temp_all_barcode;


select barcode from temp_all_barcode order by barcode;






sho err;


CREATE OR REPLACE PUBLIC SYNONYM is_iso8601 FOR is_iso8601;
GRANT EXECUTE ON is_iso8601 TO PUBLIC;

---->
<cfinclude template="/includes/_header.cfm">
<cfset title="barcodes!">
<script>
	function deleteCSeries(key){
		var msg='Are you sure you want to delete this record?';
		msg+=' That is a Really Bad Idea if the series is used and not covered by another entry.';
		var r = confirm(msg);
		if (r == true) {
			document.location='barcodeseries.cfm?action=delete&key=' + key;
		}
	}
</script>
<cfsavecontent variable="doc_barcodeseriessql">
	<div style="max-height:10em;overflow:scroll;">
		<a style="font-weight:bold;size:large" href="/contact.cfm">Contact us for help in writing SQL</a>
		<p>
			"barcodeseriessql" is the SQL statement that MUST return true when analyzed against any barcode in the intended series, and false
			against any other string. It is evaluated as "select count(*) from dual where {whatever_you_type}". That MUST return
			1 for all of your intended barcodes, and 0 for any other.
		</p>
		<p>
			Anything that's a valid Oracle SQL statement may be used for testing. There are many ways to test most everything.
		</p>
		<p>
			Use "barcode" (lower-case) as the SQL variable representing the each barcode.
		</p>
		Examples:

		<table border>
			<tr>
				<th>Series</th>
				<th>SQL (what to type)</th>
				<th>What's it mean?</th>
			</tr>
			<tr>
				<td>1</td>
				<td>barcode='1'</td>
				<td>Equality tests come with no surprises; this is ideal.</td>
			</tr>
			<tr>
				<td>1</td>
				<td>regexp_like(barcode,'[0-9]*')</td>
				<td>
					"1" is a number, matches the regular expression, and your intended barcodes will pass -
					as will all other numbers. This is a very bad choice.
				</td>
			</tr>
			<tr>
				<td>
					ABC123 - ABC456
				</td>
				<td>
					regexp_like(barcode,'^ABC[0-9]{3}') and to_number(substr(barcode,4)) between 123 and 456
				</td>
				<td>
					First, consider claiming the entire "ABC{number}" series (but coordinate large "grabs" with the Arctos community).
					<ul>
						<li>
							<strong>regexp_like(</strong> - a regular expression follows
						</li>
						<li>
							<strong>barcode,</strong> - "barcode" (the variable, not the string) is the subject of the evaluation
						</li>
						<li>
							<strong>'^</strong> - "anchor" to the beginning of the string
						</li>
						<li>
							<strong>ABC</strong> - the next (from the beginning) three characters must be "ABC"
						</li>
						<li>
							<strong>[0-9]</strong> - any number
						</li>
						<li>
							<strong>{3}</strong> - three of the proceeding (so three numbers)
						</li>
						<li>
							<strong>') and </strong> - multiple operations are OK; it's easier to do the rest outside regex.
						</li>
						<li>
							<strong>to_number(</strong> - convert some CHAR data to NUMBER (or fail if a conversion is not possible)
						</li>
						<li>
							<strong>substr(</strong> - extract some characters
						</li>
						<li>
							<strong>barcode,</strong> - variable from which to extract
						</li>
						<li>
							<strong>4)</strong> - "start at the 4th character and proceed to the end of the data"
						</li>
						<li>
							<strong>between 123 and 456</strong> - shortcut for "greater than or equal to 4th-and-subsequent characters
							 AND less than or equal to 4th-and-subsequent characters"
						</li>
					</ul>
				</td>
			</tr>
		</table>
	</div>
</cfsavecontent>
<cfoutput>
	<!------------------------------------------------->
	<cfif action is "delete">
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_barcodeseries where key=#val(key)#
		</cfquery>
		<cfif d.whodunit is not session.username>
			Only #d.whodunit# may edit this record. <a href="contact.cfm">Contact a DBA</a> to update.
			<cfabort>
		</cfif>
		<cfquery name="dlt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from cf_barcodeseries where key=#key#
		</cfquery>
		<cflocation url="barcodeseries.cfm" addtoken="false">
	</cfif>
	<!------------------------------------------------->
	<cfif action is "saveNew">
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into cf_barcodeseries (
				barcodeseriessql,
				barcodeseriestxt,
				institution,
				notes,
				createdate,
				whodunit
			) values (
				'#escapeQuotes(barcodeseriessql)#',
				'#escapeQuotes(barcodeseriestxt)#',
				'#institution#',
				'#escapeQuotes(notes)#',
				sysdate,
				'#session.username#'
			)
		</cfquery>
		<cflocation url="barcodeseries.cfm" addtoken="false">
	</cfif>
	<!------------------------------------------------->
	<cfif action is "saveEdit">
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_barcodeseries set
				barcodeseriessql='#escapeQuotes(barcodeseriessql)#',
				barcodeseriestxt='#escapeQuotes(barcodeseriestxt)#',
				notes='#escapeQuotes(notes)#'
			where
				key=#key#
		</cfquery>
		<cflocation url="barcodeseries.cfm?action=edit&key=#key#" addtoken="false">
	</cfif>

	<!------------------------------------------------->
	<cfif action is "edit">
		<p>
			<a href="barcodeseries.cfm">back to table</a>
		</p>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_barcodeseries where key=#val(key)#
		</cfquery>
		<cfif d.whodunit is not session.username>
			Only #d.whodunit# may edit this record. <a href="contact.cfm">Contact a DBA</a> to update.
			<cfabort>
		</cfif>
		<form name="t" method="post" action="barcodeseries.cfm">
			<input type="hidden" name="action" value="saveEdit">
			<input type="hidden" name="key" value="#d.key#">
			<div style="border:1px solid black; margin:1em; padding:1em">
				<label for="barcodeseriessql">
					SQL
				</label>
				<textarea class="hugetextarea" name="barcodeseriessql">#d.barcodeseriessql#</textarea>
				#doc_barcodeseriessql#
			</div>
			<label for="barcodeseriestxt">
				Text - type a clear human-readable (and sortable) description of the series you are claiming
			</label>
			<textarea class="hugetextarea" name="barcodeseriestxt">#d.barcodeseriestxt#</textarea>
			<label for="institution">institution</label>
			<a href="contact.cfm">Contact a DBA</a> to change institution.
			<label for="notes">
				Notes
			</label>
			<textarea class="hugetextarea" name="notes">#d.notes#</textarea>
			<input type="submit" value="save edits">
		</form>
	</cfif>
	<!------------------------------------------------->
	<cfif action is "new">
		<cfquery name="ctinstitution" datasource="uam_god">
			select distinct institution from collection order by institution
		</cfquery>

		<form name="t" method="post" action="barcodeseries.cfm">
			<input type="hidden" name="action" id="action" value="saveNew">
			<div style="border:1px solid black; margin:1em; padding:1em">
				<label for="barcodeseriessql">
					SQL
				</label>
				<textarea class="hugetextarea" name="barcodeseriessql"></textarea>
				#doc_barcodeseriessql#
			</div>
			<label for="barcodeseriestxt">
				Text - type a clear human-readable (and sortable) description of the series you are claiming
			</label>
			<textarea class="hugetextarea" name="barcodeseriestxt"></textarea>
			<label for="institution">institution</label>
			<select name="institution">
				<option value="">pick one</option>
				<cfloop query="ctinstitution">
					<option value="#institution#">#institution#</option>
				</cfloop>
			</select>
			<label for="notes">
				Notes
			</label>
			<textarea class="hugetextarea" name="notes"></textarea>
			<input type="submit" value="create">
		</form>
	</cfif>

	<!------------------------------------------------->
	<cfif action is "nothing">
		<script src="/includes/sorttable.js"></script>
		<p>
			<a href="barcodeseries.cfm?action=new">stake a claim</a>
		</p>
		<p>
			Claim barcodes and barcode series.
			<ul>
				<li>
					Review container documentation, especially
					<span class="likeLink" onclick="getDocs('container','purchase')">container purchase guidelines</span>
					, before doing anything here.</li>
				<li>
					<a href="/contact.cfm">contact us</a> if you need help with any part of the barcoding process or anything in Arctos,
					including this form.
				</li>
				<li>
					If you claim XYZ1 through XYZ5, don't be surprised if someone else claims XYZ6. Claim what you might need,
					not only what you currently have.
				</li>
				<li>Don't be "that guy"; contact the XYZ-folks before claiming what might be part of an intended series.</li>
				<li>
					Don't be redundant. If you already own XYZ1 through XYZ5 and you buy XYZ6 through XYZ10, edit the original
					 entry rather than adding a new entry. This thing is already hard enough to read!
				</li>
			</ul>
		</p>

		<cfparam name="barcode" default="">
		<form name="t" method="get" action="barcodeseries.cfm">
			<label for="barcode">Enter a barcode to test</label>
			<input type="text" value="#barcode#" name="barcode">
			<input type="submit" value="test this barcode">
		</form>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_barcodeseries order by barcodeseriestxt
		</cfquery>
		<p>
			Claimed barcodes (and test results if you entered something in the form).
		</p>
		<table border id="t2" class="sortable">
			<tr>
				<th>edit</th>
				<th>Txt</th>
				<th>sql</th>
				<th>status</th>
				<th>statusSQL</th>
				<th>Inst</th>
				<th>Date</th>
				<th>Who</th>
				<th>Note</th>
			</tr>
			<cfloop query="d">
				<cfif len(barcode) gt 0>
					<cftry>
					<cfset statusSQL=replace(barcodeseriessql,"barcode","'#barcode#'","all")>
					<cfquery name="t" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						select count(*) c from dual where #preserveSingleQuotes(statusSQL)#
					</cfquery>
					<cfif t.c gt 0>
						<cfset tststts='PASS'>
					<cfelse>
						<cfset tststts='FAIL (count: #t.c#)'>
					</cfif>
					<cfcatch>
						<cfset m=cfcatch.detail>
						<cfset m=replace(m,'[Macromedia][Oracle JDBC Driver][Oracle]','','all')>
						<cfset tststts='FAIL: #m#'>
					</cfcatch>
					</cftry>
				<cfelse>
					<cfset statusSQL='Enter a barcode in the form above to test'>
					<cfset tststts='-'>
				</cfif>
				<tr <cfif tststts is "PASS"> style="background:##b3ffb3;"</cfif>>
					<td>
						<a href="barcodeseries.cfm?action=edit&key=#key#">edit</a>
						<span class="likeLink" onclick="deleteCSeries('#key#')">delete</span>
					</td>
					<td nowrap>#barcodeseriestxt#</td>
					<td>#barcodeseriessql#</td>
					<td>#tststts#</td>
					<td>#statusSQL#</td>
					<td>#institution#</td>
					<td>#createdate#</td>
					<td>#whodunit#</td>
					<td>#notes#</td>
				</tr>
			</cfloop>
		</table>





	</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">