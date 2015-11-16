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

	grant insert,update on cf_barcodeseries to manage_container;

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



	delete from cf_barcodeseries;


	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'to_number(barcode) between 2 and 405000',
		'all integers',
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
		'substr(barcode,0,1)=''C'' and is_number(substr(barcode,2))=1 and to_number(substr(barcode,2)) > 1 and to_number(substr(barcode,2))<=89000',
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
		'substr(barcode,0,1)=''T'' and is_number(substr(barcode,2))=1 and to_number(substr(barcode,2)) > 1000 and to_number(substr(barcode,2))<=3001',
		'T1001-T3001',
		'UAM',
		 'UAM T{number} series; Plastic laser-etched barcoded tag for attaching to specimens.  From National Band and Tag Co.',
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
		'DLM'
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
		'DLM'
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
		'DLM'
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
		'various UAM	Inconsistent leading zeroes',
		'2009-10-09',
		'DLM'
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
		'various UAM	Inconsistent leading zeroes',
		'2009-10-09',
		'DLM'
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
		'DLM'
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
		'DLM'
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
		'DLM'
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
		'DLM'
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
		'DLM'
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
		'DLM'
	);
	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^ES[0-9]*$'') and to_number(substr(barcode,3)) between 20000 and 54999',
		'ES20000 - ES54999',
		'UAM',
		'Updated Paleo specimen labels',
		'2009-10-09',
		'DLM'
	);

	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^UAM[0-9]*$'') and to_number(substr(barcode,4)) between 100000001 and 100050000',
		'UAM100000001 - UAM100050000',
		'UAM',
		'UAM Insects specimen labels',
		'2009-10-09',
		'DLM'
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
		'Kyndall'
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
		'Kyndall'
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
		'DLM'
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
		'regexp_like(barcode,''^MSB[0-9]*$'') and to_number(substr(barcode,4)) between 100001 and 150000',
		'MSB100001	- MSB150000',
		'MSB',
		'MSB birds',
		'2009-10-09',
		'abj'
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
		'MSB; Prefix for p for parasites, followed by all base-36 (A-Z0-9) values for small circular microscope-slide labels.  DataMatrix.',
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
		'regexp_like(barcode,''^KNWR[0-9]*$'')',
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
		'dunnum'
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
		'regexp_like(barcode,''^A[0-9]{5}$'') and to_number(substr(barcode,1)) between 1 and 5000',
		'A00001	- A05000',
		'NMU',
		'NMU 3 part barcode labels for use on cryotubes, parasite vials, and skull tags',
		'2015-07-07',
		'keg'
	);
	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'regexp_like(barcode,''^NMU[0-9]*$'') and to_number(substr(barcode,4)) between 10000 and 100000',
		'NMU10000 - NMU10000',
		'NMU',
		'NMU generic label for specimens and containers',
		'2015-07-07',
		'keg'
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
		'BOLD-???',
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
		'barcode=''VLSB 1143''',
		'VLSB 1143',
		'MVZ',
		'MVZ Generic barcode for the MVZ LN2 tissue collection facility.',
		'2015-07-07',
		'ccicero'
	);

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


select is_claimed_barcode('1') from dual;


sho err;


CREATE OR REPLACE PUBLIC SYNONYM is_iso8601 FOR is_iso8601;
GRANT EXECUTE ON is_iso8601 TO PUBLIC;

---->
<cfinclude template="/includes/_header.cfm">
<cfset title="barcodes!">
<script>
	function deleteCSeries(key){
		var r = confirm("Are you sure you want to delete this record? That is a Really Bad Idea if the series is used and not covered by another entry.");
		if (r == true) {
			document.location='barcodeseries.cfm?action=delete&key=' + key;
		}
	}
</script>
<cfsavecontent variable="sql">
	"barcodeseriessql" is the SQL statement that MUST return true when analyzed against any barcode in the intended series, and false
	against any other string.

	<p>
		Anything that's a valid Oracle SQL statement may be used for testing. There are many ways to test most everything.
	</p>
	<p>
		Use "barcode" (lower-case) as the SQL variable representing the barcode
	</p>
	<p>
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
				<td>Equality tests generally come with no surprises.</td>
			</tr>
			<tr>
				<td>1</td>
				<td>regexp_like(barcode,'[0-9]*')</td>
				<td>"1" is a number so matches the regular expression, but so do all other numbers.</td>
			</tr>

		</table>
	</p>
</cfsavecontent>
<cfoutput>
	<!------------------------------------------------->
	<cfif action is "delete">
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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

			<label for="barcodeseriessql">
				SQL - this will be processed as "select count(*) from dual where {whatever_you_type_here}. That MUST return
				1 for all of your intended barcodes, and 0 for any other
			</label>
			<textarea class="hugetextarea" name="barcodeseriessql">#d.barcodeseriessql#</textarea>

			<label for="barcodeseriestxt">
				Text - type a clear human-readable description of the series you are claiming
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
			<input type="action" value="saveNew">

			<label for="barcodeseriessql">
				SQL - this will be processed as "select count(*) from dual where {whatever_you_type_here}. That MUST return
				1 for all of your intended barcodes, and 0 for any other
			</label>
			<textarea class="hugetextarea" name="barcodeseriessql"></textarea>

			<label for="barcodeseriestxt">
				Text - type a clear human-readable description of the series you are claiming
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

	<p>
		<a href="barcodeseries.cfm?action=new">stake a claim</a>
	</p>
	<p>
		Claim barcodes and barcode series.
		<ul>
			<li>See documentation specifically http://arctosdb.org/documentation/container/##purchase before doing anything here.</li>
			<li>
				<a href="/contact.cfm">contact us</a> if you need help with any part of the barcoding process or anything in Arctos,
				including this form.
			</li>
			<li>If you claim XYZ1 through XYZ5, don't be surprised if someone else claims XYZ6. Claim what you might need.</li>
			<li>Don't be that guy. Contact the XYZ-folks before claiming what might be an intended series.</li>
			<li>
				Don't be redundant. If you already own XYZ1 through XYZ5 and you buy XYZ6 through XYZ10, edit the original
				 entry rather than adding a new entry. This thing is already hard enough to read!
			</li>
		</ul>
		<br>

	</p>
	<cfif action is "nothing">
		<cfparam name="barcode" default="">
		<form name="t" method="get" action="barcodeseries.cfm">
			<label for="barcode">Enter a barcode to test</label>
			<input type="text" value="#barcode#" name="barcode">
			<input type="submit" value="test this barcode">
		</form>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_barcodeseries order by key
		</cfquery>
		<p>
			Claimed barcodes (and test results if you entered something in the form).
		</p>
		<table border>
			<tr>
				<th>edit</th>
				<th>Txt</th>
				<th>sql</th>
				<th>testing</th>
				<th>status</th>
				<th>statusSQL</th>
				<th>Inst</th>
				<th>Date</th>
				<th>Who</th>
				<th>Note</th>
			</tr>
			<cfloop query="d">
				<tr>
					<td>
						<a href="barcodeseries.cfm?action=edit&key=#key#">edit</a>
						<span class="likeLink" onclick="deleteCSeries('#key#')">delete</span>
					</td>
					<td>#barcodeseriestxt#</td>
					<td>#barcodeseriessql#</td>
					<td>#barcode#</td>
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