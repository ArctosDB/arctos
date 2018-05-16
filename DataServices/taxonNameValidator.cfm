<cfinclude template="/includes/_header.cfm">

<!----

drop table ds_temp_tax_validator;

create table ds_temp_tax_validator (
	taxon_name varchar2(4000),
	google varchar2(255)
	);

alter table ds_temp_tax_validator add wiki varchar2(255);
alter table ds_temp_tax_validator add gni varchar2(255);
alter table ds_temp_tax_validator add worms varchar2(255);
alter table ds_temp_tax_validator add eol varchar2(255);
alter table ds_temp_tax_validator add gbif varchar2(255);

create or replace public synonym ds_temp_tax_validator for ds_temp_tax_validator;
grant all on ds_temp_tax_validator to manage_taxonomy;


-- google has diallowed useful API access to search results


-- reset for testing
update ds_temp_tax_validator set gbif=null, eol=null,wiki=null,gni=null,worms=null;





---->
<cfif action is 'gpd'>
	<cfquery name="d" datasource="prod">
		select scientific_name from taxon_name where taxon_name_id > (select max(taxon_name_id)-5000 from taxon_name) order by taxon_name_id
	</cfquery>
	<cfloop query="d">
		<cfquery name="x" datasource="uam_god">
			insert into ds_temp_tax_validator(taxon_name) values ('#scientific_name#')
		</cfquery>
	</cfloop>

</cfif>
<cfif action is "nothing">
<p>
	Load CSV, one column "taxon_name"
</p>
<p>
	This app queryies various webservices for names.

	It will throw false positives (eg, because someone - perhaps Arctos - is supplying GBIF with bad data),
	and it will throw false negatives (obscure fossils are common - remember that Arctos taxonomony requires only "published", not
	any form of "accepted").
	<p>
		Names not found in any service are deserving of extra scrutiny and a note in a classification.
	</p>
	<p>
		This should not be your only source of validation.
	</p>


</p>
<p>
	File an Issue if you know of another useful taxonomy validation service.
</p>

	<form name="atts" method="post" enctype="multipart/form-data" action="taxonNameValidator.cfm">
		<input type="hidden" name="Action" value="getFile">
		<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" class="savBtn">
	</form>
</cfif>
<cfif action is "getFile">
<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from ds_temp_tax_validator
	</cfquery>


	<cfoutput>
		<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
        <cfset  util = CreateObject("component","component.utilities")>
		<cfset x=util.CSVToQuery(fileContent)>
        <cfset cols=x.columnlist>
        <cfloop query="x">
            <cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	            insert into ds_temp_tax_validator (#cols#) values (
	            <cfloop list="#cols#" index="i">
	            		'#stripQuotes(evaluate(i))#'
	            	<cfif i is not listlast(cols)>
	            		,
	            	</cfif>
	            </cfloop>
	            )
            </cfquery>
        </cfloop>
	</cfoutput>

	<a href="taxonNameValidator.cfm?action=parse">parse</a>
</cfif>
<cfif action is "showResults">
	<script src="/includes/sorttable.js"></script>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from ds_temp_tax_validator
	</cfquery>
	 <a href="taxonNameValidator.cfm?action=getCSV">getCSV</a>

	 <p>
		Names with 'not found' in all columns are probably not valid. Names with 'found' in at least one column are probably valid. Proceed with caution!
	</p>
	<table border id="t" class="sortable">
		<tr>
			<th>Name</th>
			<th>WikiData</th>
			<th>GNI</th>
			<th>WORMs</th>
			<th>GBIF</th>
			<th>EOL</th>
			<th>summary</th>
			<th>google</th>
		</tr>
		<cfoutput>
			<cfloop query="d">
				<tr>
					<td>#taxon_name#</td>
					<td>#wiki#</td>
					<td>#gni#</td>
					<td>#worms#</td>
					<td>#gbif#</td>
					<td>#eol#</td>
					<td>
						<cfif wiki is "not_found" and gni is "not_found" and worms is "not_found">
							probably not valid
						<cfelse>
							probably valid
						</cfif>
					</td>
					<td><a target="_blank" class="external" href='https://www.google.com/search?q="#taxon_name#"'>clicky</a></td>

				</tr>
			</cfloop>
		</cfoutput>
	</table>
</cfif>
<cfif action is "getCSV">
	<cflocation url="/Admin/CSVAnyTable.cfm?tableName=ds_temp_tax_validator">
</cfif>

<cfif action is "parse">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from ds_temp_tax_validator where taxon_name is not null and wiki is null and rownum<50
	</cfquery>
	<cfif d.recordcount is 0>
		Nothing found - 	<a href="taxonNameValidator.cfm?action=showResults">showResults</a> or
		 <a href="taxonNameValidator.cfm?action=getCSV">getCSV</a>
	<cfelse>
		Reload once the page fully loads to process the next batch. File an Issue if you need automation added.
	</cfif>

	<!----

	search?&q=%22#taxon_name#%22


	---->
	<cfoutput>
		<cfloop query="d">
			<br>#taxon_name#


			<cfhttp url="https://www.wikidata.org/w/api.php?action=wbsearchentities&search=#taxon_name#&language=en&format=json" method="get">
			<cfif cfhttp.filecontent contains '"search":[]'>
				<cfset vwiki='not_found'>
			<cfelse>
				<cfset vwiki='found'>
			</cfif>

			<cfhttp url="http://gni.globalnames.org/name_strings.json?search_term=exact:#taxon_name#" method="get">
			</cfhttp>

			<cfif cfhttp.filecontent contains '"name_strings_total":0'>
				<cfset vgni='not_found'>
			<cfelse>
				<cfset vgni='found'>
			</cfif>

			<cfhttp url="http://www.marinespecies.org/rest/AphiaIDByName/#taxon_name#?marine_only=false" method="get">
				<cfhttpparam type="header" name="accept" value="application/json">
			</cfhttp>


			<cfif len(cfhttp.filecontent) gt 0>
				<cfset vworms='found'>
			<cfelse>
				<cfset vworms='not_found'>
			</cfif>


			<cfhttp url="http://eol.org/api/search/1.0.json?page=1&q=/#taxon_name#&exact=true" method="get">
				<cfhttpparam type="header" name="accept" value="application/json">
			</cfhttp>
				<cfdump var=#cfhttp#>

			<cfif cfhttp.filecontent contains '"totalResults":0'>
				<cfset veol='not_found'>
			<cfelse>
				<cfset veol='found'>
			</cfif>

			<cfhttp url="http://api.gbif.org/v1/species?strict=true&name=#taxon_name#&nameType=scientific" method="get">
				<cfhttpparam type="header" name="accept" value="application/json">
			</cfhttp>

				<cfdump var=#cfhttp#>

			<cfif cfhttp.filecontent contains '"results":[]'>
				<cfset vgbif='not_found'>
			<cfelse>
				<cfset vgbif='found'>
			</cfif>





			<br>vgbif:#vgbif#
			<br>vgni:#vgni#
			<br>vwiki:#vwiki#
			<br>vworms:#vworms#
			<br>veol:#veol#

			<cfquery name="u" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update ds_temp_tax_validator set
					gbif='#vgbif#',
					eol='#veol#',
					wiki='#vwiki#',
					gni='#vgni#',
					worms='#vworms#'
				where taxon_name='#taxon_name#'
			</cfquery>

		</cfloop>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">
