<script>
function bldSql() {
	var upFld = document.getElementById('upFld').value;
	var upTo = document.getElementById('upTo').value;
	var whr = document.getElementById('whr').value;
	var crit = document.getElementById('crit').value;
	var theSql = document.getElementById('theSql');
	var selectTest = document.getElementById('selectTest');
	
	var s = "update taxonomy \nset \n" + upFld;
	var st = "select * from taxonomy"
	s += " = ";
	if (upFld == 'VALID_CATALOG_TERM_FG') {
		s += upTo;
	} else {
		s += "'" + upTo + "'";
	}
	 s += '\nwhere\n' + whr + ' = ';
	if (whr == 'TAXON_NAME_ID') {
		s += crit;
		st += " where \n" + whr + " =" + crit;
	} else {
		s += "'" + crit + "'";
		st += " where \n" + whr + " = '"+ crit + "'";
	}
	theSql.value=s;
	selectTest.value=st;	
}
</script>


<!--- not that we don't trust anybody, but...

create table taxonomy_archive as select * from taxonomy where scientific_name='Sorex yukonicus';
 truncate  table taxonomy_archive;
alter table taxonomy_archive add when date not null;
alter table taxonomy_archive add who varchar2(255) not null;
create or replace trigger trg_up_tax after update on taxonomy
for each row
begin
	 insert into taxonomy_archive (
	 	when,
	 	who,
	 	TAXON_NAME_ID,
	 	PHYLCLASS,
	 	PHYLORDER,
	 	SUBORDER,
	 	FAMILY,
	 	SUBFAMILY,
	 	GENUS,
	 	SUBGENUS,
	 	SPECIES,
	 	SUBSPECIES,
	 	VALID_CATALOG_TERM_FG,
	 	SOURCE_AUTHORITY,
	 	FULL_TAXON_NAME,
	 	SCIENTIFIC_NAME,
	 	AUTHOR_TEXT,
	 	TRIBE,
	 	INFRASPECIFIC_RANK ,
	 	TAXON_REMARKS,
	 	PHYLUM 
	 ) values (
		sysdate,
		user,
		:OLD.TAXON_NAME_ID,
	 	:OLD.PHYLCLASS,
	 	:OLD.PHYLORDER,
	 	:OLD.SUBORDER,
	 	:OLD.FAMILY,
	 	:OLD.SUBFAMILY,
	 	:OLD.GENUS,
	 	:OLD.SUBGENUS,
	 	:OLD.SPECIES,
	 	:OLD.SUBSPECIES,
	 	:OLD.VALID_CATALOG_TERM_FG,
	 	:OLD.SOURCE_AUTHORITY,
	 	:OLD.FULL_TAXON_NAME,
	 	:OLD.SCIENTIFIC_NAME,
	 	:OLD.AUTHOR_TEXT,
	 	:OLD.TRIBE,
	 	:OLD.INFRASPECIFIC_RANK ,
	 	:OLD.TAXON_REMARKS,
	 	:OLD.PHYLUM 
	 );
end;
/
sho err

-- while we're here...

create or replace trigger trg_mk_sci_name before insert or update on taxonomy
for each row
declare nsn varchar2(4000);
nft varchar2(4000);

begin
	if :NEW.subspecies is not null then
		nsn := :NEW.subspecies;
		nft := :NEW.subspecies;
	end if;
	if :NEW.infraspecific_rank is not null then
		nsn := :NEW.infraspecific_rank || ' ' || nsn;
		nft := :NEW.infraspecific_rank || ' ' || nft;
	end if;
	if :NEW.species is not null then
		nsn := :NEW.species || ' ' || nsn;
		nft := :NEW.species || ' ' || nft;
	end if;
	if :NEW.subgenus is not null then
		-- ignore for building scientific name
		nft := :NEW.subgenus || ' ' || nft;
	end if;
	if :NEW.genus is not null then
		nsn := :NEW.genus || ' ' || nsn;
		nft := :NEW.genus || ' ' || nft;
	end if;
	if :NEW.tribe is not null then
		if nsn is null then
			nsn := :NEW.tribe;
		end if;
		-- if we don't have a scientific name by now, just use the lowest term that we do have
		nft := :NEW.tribe || ' ' || nft;
	end if;
	if :NEW.subfamily is not null then
		if nsn is null then
			nsn := :NEW.subfamily;
		end if;
		nft := :NEW.subfamily || ' ' || nft;
	end if;
	if :NEW.family is not null then
		if nsn is null then
			nsn := :NEW.family;
		end if;
		nft := :NEW.family || ' ' || nft;
	end if;
	if :NEW.suborder is not null then
		if nsn is null then
			nsn := :NEW.suborder;
		end if;
		nft := :NEW.suborder || ' ' || nft;
	end if;
	if :NEW.phylorder is not null then
		if nsn is null then
			nsn := :NEW.phylorder;
		end if;
		nft := :NEW.phylorder || ' ' || nft;
	end if;
	if :NEW.phylclass is not null then
		if nsn is null then
			nsn := :NEW.phylclass;
		end if;
		nft := :NEW.phylclass || ' ' || nft;
	end if;
	if :NEW.phylum is not null then
		if nsn is null then
			nsn := :NEW.phylum;
		end if;
		nft := :NEW.phylum || ' ' || nft;
	end if;

	dbms_output.put_line(nsn);
	dbms_output.put_line(nft);
end;
/
sho err
 insert into taxonomy(
	 	TAXON_NAME_ID,
	 	PHYLCLASS,
	 	PHYLORDER,
	 	SUBORDER,
	 	FAMILY,
	 	SUBFAMILY,
	 	GENUS,
	 	SUBGENUS,
	 	SPECIES,
	 	SUBSPECIES,
	 	VALID_CATALOG_TERM_FG,
	 	SOURCE_AUTHORITY,
	 	TRIBE,
	 	PHYLUM 
	 ) values (
		2080181,
	 	'Mammalia',
	 	'Rodentia',
	 	'suborder',
	 	'family',
	 	'subfamily',
	 	'genus',
	 	'subgenus',
	 	'SPECIES',
	 	'SUBSPECIES',
	 	1,
	 	'UAM',
	 	'TRIBE',
	 	'PHYLUM' 
	 );

--->
 
<cfinclude template="/includes/_frameHeader.cfm">
<!--- no security --->
<cfif session.username is not "gordon" and session.username is not "dlm" and session.username is not "ccicero"
		and session.username is not "AlanBatten">
	Not yours. Go away.
	<cfabort>
</cfif>
<cfif #action# is "nothing">
<cfoutput>
		<form name="buildIt" method="post" action="sqlTaxonomy_update.cfm">
			<input type="hidden" name="action" value="testUpdate">
			Build SQL...
			<cfset fldList = "TAXON_NAME_ID,PHYLUM,PHYLCLASS,PHYLORDER,SUBORDER,FAMILY,SUBFAMILY,TRIBE,GENUS,SUBGENUS,SPECIES,INFRASPECIFIC_RANK,SUBSPECIES,VALID_CATALOG_TERM_FG,SOURCE_AUTHORITY,FULL_TAXON_NAME,SCIENTIFIC_NAME,AUTHOR_TEXT,TAXON_REMARKS,nomenclatural_code">
			<cfset upList = "PHYLUM,PHYLCLASS,PHYLORDER,SUBORDER,FAMILY,SUBFAMILY,TRIBE,GENUS,SUBGENUS,SPECIES,INFRASPECIFIC_RANK,SUBSPECIES,VALID_CATALOG_TERM_FG,SOURCE_AUTHORITY,AUTHOR_TEXT,TAXON_REMARKS,nomenclatural_code">
			<br>UPDATE taxonomy SET
			<br><select name="upFld" id="upFld" size="1">
				<cfloop list="#upList#" index="f">
					<option value="#f#">#f#</option>
				</cfloop>
			</select>
			=
			<input type="text" name="upTo" id="upTo">
			<br>WHERE
			<br><select name="whr" id="whr" size="1">
				<cfloop list="#fldList#" index="f">
					<option value="#f#">#f#</option>
				</cfloop>
			</select>
			=
			<input type="text" name="crit" id="crit">
			<br><input type="button" onclick="bldSql()" value="build SQL">
			<label for="theSql">SQL (this is the update SQL. Type in here or use the widget above)</label>
			<textarea name="theSql" id="theSql" rows="4" cols="60"></textarea>
			<label for="selectTest">SQL Test (you'll see the results of this before the above runs. This is useless if you type in the SQL box.)</label>
			<textarea name="selectTest" id="selectTest" rows="4" cols="60"></textarea>
			<br><input type="submit" value="Make Changes">
		</td>
	</tr>
</table>
</cfoutput>
</cfif>
<cfif #action# is "testUpdate">
	<cfoutput>
	<cfquery name="test" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(selectTest)#
	</cfquery>
	Your test SQL statement:
	<blockquote>
		#selectTest#
	</blockquote>
	Produced the following table containing #test.recordcount# rows.
	<br>
	Your update statement is:
	<blockquote>
		#theSql#
	</blockquote>
	
	<form name="foReal" method="post" action="sqlTaxonomy_update.cfm">
		<input type="hidden" name="theSql" value="#theSql#">
		<input type='hidden' name='action' value="makeUpdate">
		If the table below contains ONLY those records you want to update, 
		<input type="submit" value="proceed to update taxonomy">
	</form>
	<table id="t" border="1">
			<tr>
				<th>TAXON_NAME_ID</th>
				<th>PHYLUM</th>
				<th>PHYLCLASS</th>
				<th>PHYLORDER</th>
				<th>SUBORDER</th>
				<th>FAMILY</th>
				<th>SUBFAMILY</th>
				<th>TRIBE</th>
				<th>GENUS</th>
				<th>SUBGENUS</th>
				<th>SPECIES</th>
				<th>INFRASPECIFIC_RANK</th>
				<th>SUBSPECIES</th>
				<th>VALID_CATALOG_TERM_FG</th>
				<th>AUTHOR_TEXT</th>
				<th>SOURCE_AUTHORITY</th>
				<th>TAXON_REMARKS</th>
				<th>SCIENTIFIC_NAME</th>				
				<th>nomenclatural_code</th>
			</tr>
		<cfloop query="test">
			<tr>
				<td>#TAXON_NAME_ID#</td>
				<td>#PHYLUM#</td>
				<td>#PHYLCLASS#</td>
				<td>#PHYLORDER#</td>
				<td>#SUBORDER#</td>
				<td>#FAMILY#</td>
				<td>#SUBFAMILY#</td>
				<td>#TRIBE#</td>
				<td>#GENUS#</td>
				<td>#SUBGENUS#</td>
				<td>#SPECIES#</td>
				<td>#INFRASPECIFIC_RANK#</td>
				<td>#SUBSPECIES#</td>
				<td>#VALID_CATALOG_TERM_FG#</td>
				<td>#AUTHOR_TEXT#</td>
				<td>#SOURCE_AUTHORITY#</td>
				<td>#TAXON_REMARKS#</td>
				<td>#SCIENTIFIC_NAME#</td>			
				<th>#nomenclatural_code#</th>
			</tr>
		</cfloop>
		</table>
	</cfoutput>
</cfif>
<cfif #action# is "makeUpdate">
	<cfoutput>
		<cfquery name="updatetaxa" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			#preservesinglequotes(theSql)#
		</cfquery>			
		<CFLOCATION url="sqlTaxonomy_update.cfm">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------>

