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


	insert into cf_barcodeseries (
		barcodeseriessql,
		barcodeseriestxt,
		institution,
		notes,
		createdate,
		whodunit
	) values (
		'is_number(barcode)=1 and to_number(barcode) > 1 and to_number(barcode)<=405000',
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
		'substr(barcode,0,1)=''H'' and is_number(substr(barcode,2))=1 and to_number(substr(barcode,2)) >= 1000000 and to_number(substr(barcode,2))<=1249999',
		'H1000000-H1249999',
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
		 'brandy'
	);



	select substr('C124',0,1) from dual;
		select substr('C1',2) from dual;



		UAM:Herb	 - Gordon ordered from EIM	11/5/2008	Brandy
0	0	UAM:Mamm	reserved for "unknown location" container	10/9/2009	DLM
R[number]C[number]	various	UAM	range cases; inconsistent format (R36C01; R131C6) due to legacy data and space constraints.	10/9/2009	DLM
R[number]-[number]	various	unknown	range cases? Likely Herbarium cases; coordination needed to avoid imminent disaster and very grumpy herbarium folks.	10/9/2009	DLM
RANGE[number]	various	UAM	Ranges. Cases are children. (But see Bad Botanical Idea above.)	10/9/2009	DLM
ROOM[number]	various	UAM	Inconsistent leading zeroes	10/9/2009	DLM
T1001	T3000	unknown	specimen label	10/9/2009	DLM
L032400	L761304	UAM	inconsistent; L090207 and L0903007 exist; THESE WERE THE FIRST BARCODES WE CREATED FOR SHELVES AND TRAYS IN THE RANGE IN THE 1990'S.  "L" FOR LOCATION, AND THE FIRST 2 DIGITS REFERRED TO THE RANGE NUMBER, DIGITS 3 AND 4 WERE THE CASE NUMBER AND THE LAST TWO WERE THE SHELF OR TRAY.  Probably mammals only.  AFTER WE ARE FINISHED MOVING SPECIMENS INTO NEW CABINETS WE CAN PROBABLY GET RID OF THESE.	10/9/2009	DLM
LN2-2-A1	LN2-3-F2	UAM	Nitrogen freezers positions (these are older labels that will be replaced by barcodes without the dashes when LN2 freezers 2 and 3 are in use.	10/9/2009	DLM
LN21A1	LN23F5	UAM	Nitrogen freezer positions	10/9/2009	DLM
LN2FRZR1	LN2FRZR3	UAM	Nitrogen freezers	10/9/2009	DLM
ES 000001	ES 019999	UAM:ES	UAM Paleo specimen labels	10/9/2009	DLM
ES20000	ES54999	UAM:ES	Updated UAM Paleo specimen labels
UAM100000001	UAM100050000	UAM:Ento	UAM Insects specimen labels	10/9/2009	DLM
FRZR1	FRZR9	UAM	freezers	9/22/2014	Kyndall
FRZR1-01A	"FRZR9-12D
"	UAM	freezer positions	9/22/2014	Kyndall
MSB 140837	MSB 140841	MSB	jars?	10/9/2009	DLM
2	ca. 50000	UAM:Mamm	legacy catalog number barcodes; not all scanned into Arctos yet	10/14/2009	dlm
MVZ1000	MVZ3715	MVZ	MVZ tissue collection: LN2 racks	10/14/2009	CC
MVZ4000	MVZ6999	MVZ	MVZ tissue collection: boxes	10/14/2009	CC
MVZ100000	MVZ200000	MVZ	MVZ tissue collection: cryovials	10/14/2009	CC
MVZ[number]	MVZ[number]	MVZ	Reserved MVZ as a barcode prefix for MVZ specimens	10/14/2009	CC
1	1	MVZ	reserved for MVZ "unknown location" container	10/14/2009	CC
MSB100001	MSB150000	MSB Birds		5/22/2012	ABJ
DGR10001	DGR20001	MSB:DGR	Divison of Genomic Resources, labels for freezer racks and freezer boxes.	6/13/2013	Jarrell
p0	pzzzzzzzzzzzzzz	MSB Parasites	Prefix for p for parasites, followed by all base-36 (A-Z0-9) values for small circular microscope-slide labels.  DataMatrix.	3/4/2013	Jarrell
	p2cvk	MSB Parasites	Parasites, next 10,000 base-36 values for 2"X1/2" slide-box labels. Code 128.	3/4/2013
KNWRC[number]	various	KNWR	generic container label for KNWR containers, used in both KNWR:Herb and KNWR:Ento collections.	3/12/2013	Matt Bowser
UDCC_TCN [number]	various	KNWR	These are 2D barcode labels used by the University of Delaware Entomology Collection (UDCC), added to specimens loaned from KNWR to UDCC.	4/26/2013	Matt Bowser
UDCC_NRI [number]	various	KNWR	These are 2D barcode labels used by the University of Delaware Entomology Collection (UDCC), added to specimens loaned from KNWR to UDCC.	4/26/2013	Matt Bowser
H1250000	H1279999	UAM:Herb	Herbarium sheet labels, ordered from EIM.	9/11/2013	JSM
A24E3 (16895163)	A36YY	MSB:Mamm	"50,000 cryotube labels in base-36 Datamatrix,
"	7/7/2014
BOWIE 1	BOWIE 500	MVZ Birds	MVZ uncataloged bird samples collected by Raurie Bowie and colleagues, labels for his freezer boxes	4/16/2015	CC
BIRD 1	BIRD 500	MVZ Birds	MVZ uncataloged bird samples (non-Bowie accns), labels for freezer boxes	4/16/2015	CC
A36YZ	A49JU	MSB Mamm	MSB Mamm and DGR base 36 3 part barcode labels for use on cryotubes, parasite vials, and skull tags; equivalent to base 10 numbers 16945163 to 16995162	6/1/2015	"MLC
"
A00001	A05000	NMU	NMU 3 part barcode labels for use on cryotubes, parasite vials, and skull tags	7/7/2015	KEG
NMU10000	NMU19999	NMU	NMU generic label for specimens and containers	7/7/2015	KEG
BOLD-???	BOLD-???	KNWR:Ento	These are 2D barcode labels on lifescanner vials (http://lifescanner.net/).	9/18/2015	Matt Bowser
DGR1-1-1	DGR18-33-12	MSB:DGR	Barcodes for legacy DGR freezer box positions in mechanical freezers	11/4/2015	"MLC
"
DGR1-1	DGR1-33	MSB:DGR	Barcodes for legacy DGR freezer racks for mechanical freezers	11/4/2015	"MLC
"
VLSB 1143	VLSB 1143	MVZ	Generic barcode for the MVZ LN2 tissue collection facility.	11/11/2015	CC










































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































	select count(*) from dual where is_number('1')=1 and to_number('1') > 1 and to_number('1')<=405000;


	 varchar2(255) not null


	110000	125999	UAM	UAM: First batch of 2-piece wrap-around labels for cryovials (DigiTrax).	11/5/2008	Brandy
---->
<cfinclude template="/includes/_header.cfm">
<a href="barcodeseries.cfm?action=test">test</a>
<cfoutput>
	<cfif action is "nothing">
		<cfparam name="barcode" default="">
		<form name="t" method="get" action="barcodeseries.cfm">
			<input type="hidden" name="action" value="test">
			<label for="barcode">Enter a barcode to test</label>
			<input type="text" value="#barcode#" name="barcode">
			<input type="submit" value="test this barcode">
		</form>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_barcodeseries order by key
		</cfquery>

		<table border>
			<tr>
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
					<td>#barcodeseriestxt#</td>
					<td>#barcodeseriessql#</td>
					<td>#barcode#</td>
					<cfif len(barcode) gt 0>
						<cftry>
						<cfset statusSQL=replace(barcodeseriessql,"barcode","'#barcode#'","all")>
						<cfquery name="t" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							select count(*) c from dual where #preserveSingleQuotes(bc)#
						</cfquery>
						<cfif t.c gt 0>
							<cfset tststts='PASS'>
						<cfelse>
							<cfset tststts='FAIL (count: #t.c#)'>
						</cfif>
						<cfcatch>
							<cfset tststts='FAIL: #cfcatch.message# #cfcatch.detail#'>
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