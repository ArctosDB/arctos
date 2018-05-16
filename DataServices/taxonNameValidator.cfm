<cfinclude template="/includes/_header.cfm">

<!----

drop table ds_temp_tax_validator;

create table ds_temp_tax_validator (
	taxon_name varchar2(4000),
	google varchar2(255)
	);

alter table ds_temp_tax_validator add wiki varchar2(255);
alter table ds_temp_tax_validator add gni varchar2(255);

create or replace public synonym ds_temp_tax_validator for ds_temp_tax_validator;
grant all on ds_temp_tax_validator to manage_taxonomy;

---->
<cfif action is "nothing">
<p>
	Load CSV, one column "taxon_name"
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
<cfif action is "parse">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from ds_temp_tax_validator where taxon_name is not null and wiki is null and rownum<10
	</cfquery>
	<!----

	search?&q=%22#taxon_name#%22


	---->
	<cfoutput>
		<cfloop query="d">
			<br>#taxon_name#
			<cfhttp url="https://www.wikidata.org/w/api.php?action=wbsearchentities&search=#taxon_name#&language=en&format=json" method="get">


			<cfdump var=#cfhttp#>

			<cfif cfhttp.filecontent contains '"search":[]'>
				<cfset w='wiki_not_found'>
			<cfelse>
				<cfset w='wiki_found'>
			</cfif>

			<cfhttp url="http://gni.globalnames.org/name_strings.json?search_term=exact:#taxon_name#" method="get">
			</cfhttp>

			<cfdump var=#cfhttp#>
			<cfif cfhttp.filecontent contains '"name_strings_total":0'>
				<cfset g='gni_not_found'>
			<cfelse>
				<cfset g='gni_found'>
			</cfif>





			<cfquery name="u" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update ds_temp_tax_validator set wiki='#w#',gni='#g#' where taxon_name='#taxon_name#'
			</cfquery>

		</cfloop>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">
