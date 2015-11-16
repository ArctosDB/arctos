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



	select count(*) from dual where is_number('1')=1 and to_number('1') > 1 and to_number('1')<=405000;


	 varchar2(255) not null


	110000	125999	UAM	UAM: First batch of 2-piece wrap-around labels for cryovials (DigiTrax).	11/5/2008	Brandy
---->
<cfinclude template="/includes/_header.cfm">
<a href="barcodeseries.cfm?action=test">test</a>
<cfoutput>
	<cfif action is "test">
		<cfparam name="barcode" default="">
		<form name="t" method="get" action="barcodeseries.cfm">
			<input type="hidden" name="action" value="test">
			<label for="barcode">Enter a barcode to test</label>
			<input type="text" value="#barcode#" name="barcode">
			<input type="submit" value="go">
		</form>
		<cfif len(barcode) gt 0>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select * from cf_barcodeseries order by key
			</cfquery>
			<cfloop query="d">
				<cftry>
				<p>Testing #barcodeseriestxt# (#barcodeseriessql#)</p>
				<cfset bc=replace(barcodeseriessql,"barcode","'#barcode#'","all")>
				<br>select count(*) c from dual where #preserveSingleQuotes(bc)#
				<cfquery name="t" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select count(*) c from dual where #preserveSingleQuotes(bc)#
				</cfquery>
				<cfif t.c is gt 0>
					<br>PASS
				<cfelse>
					<br>FAIL: #t.c#
				</cfif>
				<cfcatch>
					<br>FAIL: #cfcatch.message# #cfcatch.detail#
				</cfcatch>
				</cftry>
			</cfloop>
		</cfif>
	</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">