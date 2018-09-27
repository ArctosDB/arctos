<cfinclude template="/includes/_header.cfm">
<cfset title="Bulkload Taxonomy">
<!---- make the table
	create table cf_temp_taxon_name (
		username varchar2(255) not null,
		scientific_name varchar2(255) not null,
		status  varchar2(255)
	);

	create or replace public synonym cf_temp_taxon_name for cf_temp_taxon_name;

	grant all on cf_temp_taxon_name to manage_taxonomy;


create or replace trigger trg_cf_cf_temp_taxon_name before insert on cf_temp_taxon_name
	FOR EACH ROW
	begin
		if :NEW.username is null then
			select SYS_CONTEXT('USERENV', 'SESSION_USER') into :NEW.username from dual;
		end if;
	end;
/
sho err;
	------->
<!------------------------------------------------------->
<cfif action is "down">
	<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_taxon_name where upper(username)='#ucase(session.username)#'
	</cfquery>
	<cfset  util = CreateObject("component","component.utilities")>
	<cfset csv = util.QueryToCSV2(Query=mine,Fields=mine.columnlist)>
	<cffile action = "write"
	    file = "#Application.webDirectory#/download/BulkTaxaDown.csv"
    	output = "#csv#"
    	addNewLine = "no">
	<cflocation url="/download.cfm?file=BulkTaxaDown.csv" addtoken="false">
</cfif>
<!------------------------------------------------------->
<cfif action is "makeTemplate">
	<cfset c='SCIENTIFIC_NAME'>
	<cffile action = "write" file = "#Application.webDirectory#/download/BulkTaxonomy.csv"
    	output = "#c#" addNewLine = "no">
	<cflocation url="/download.cfm?file=BulkTaxonomy.csv" addtoken="false">
</cfif>
<!------------------------------------------------------->
<cfif action is "nothing">
	<cfoutput>
		Load names. Do NOT load identifications. You may load classifications separately after the names exist.
		 <p>
			Upload a comma-delimited text file (csv). <a href="BulkloadTaxonomy.cfm?action=makeTemplate">[ Get the Template ]</a>
		</p>
		<p>
			<a href="BulkloadTaxonomy.cfm?action=show">[ Manage existing data ]</a>
		</p>

		<cfform name="oids" method="post" enctype="multipart/form-data" action="BulkloadTaxonomy.cfm">
			<input type="hidden" name="action" value="getFile">
			<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
			<input type="submit" value="Upload this file">
		</cfform>
	</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "getFile">
<cfoutput>
	<!--- put this in a temp table --->
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from cf_temp_taxon_name
	</cfquery>
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	<cfset fileContent=replace(fileContent,"'","''","all")>
	<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />
	<cfset numberOfColumns = arraylen(arrResult[1])>
	<cfset colNames="">
	<cfloop from="1" to ="#ArrayLen(arrResult)#" index="o">
		<cfset colVals="">
			<cfloop from="1"  to ="#ArrayLen(arrResult[o])#" index="i">
				<cfset thisBit=arrResult[o][i]>
				<cfif o is 1>
					<cfset colNames="#colNames#,#thisBit#">
				<cfelse>
					<cfset colVals="#colVals#,'#thisBit#'">
				</cfif>
			</cfloop>
		<cfif o is 1>
			<cfset colNames=replace(colNames,",","","first")>
		</cfif>
		<cfif len(colVals) gt 1>
			<cfset colVals=replace(colVals,",","","first")>
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into cf_temp_taxon_name (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>
	<cflocation url="BulkloadTaxonomy.cfm?action=show" addtoken="false">
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "show">
<script src="/includes/sorttable.js"></script>
<cfoutput>

	<p>
		<a href="BulkloadTaxonomy.cfm?action=getFile">download CSV</a>
	</p>
	<p>
		<a href="BulkloadTaxonomy.cfm?action=makeTemplate">get a template</a> (or just load CSV with one column "scientific_name")
	</p>


	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_taxon_name  where upper(username)='#ucase(session.username)#'
	</cfquery>
	<cfquery name="isProb" dbtype="query">
		select status,count(*) c from data group by status
	</cfquery>
	Status:
	<ul>
		<cfloop query="isProb">
			<li>#status# (#c#)</li>
		</cfloop>
	</ul>
	<p>
		This form will happily create garbage. CHECK <strong>ALL</strong> DATA CAREFULLY BEFORE LOADING!!!
	</p>
	<p>
		You should <a href="BulkloadTaxonomy.cfm?action=validate">validate</a> before loading. The validation service queries various sources
		for the name. It fails, often, with both false positives and false negatives. You are solely responsible for the names you create.
		Only records with NULL status will be validated. You may need to reload a few times; the external services can be slow.
	</p>
	<p>
		If everything looks happy, you can <a href="BulkloadTaxonomy.cfm?action=loadData">load data</a>. Names will be deleted from this
		app as they load. You may have to reload a few times for very large datasets.
	<cfset h=data.columnlist>
	<table border id="t" class="sortable">
		<tr>
			<cfloop list="#h#" index="i">
				<th>#i#</th>
			</cfloop>
		</tr>
		<cfloop query="data">
			<tr>
				<cfloop list="#h#" index="i">
					<td>
						#evaluate("data." & i)#
					</td>
				</cfloop>
			</tr>
		</cfloop>
	</table>
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "validate">
<cfoutput>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from  cf_temp_taxon_name  where status is null and  upper(username)='#ucase(session.username)#'
	</cfquery>
	<cfset tc = CreateObject("component","component.taxonomy")>

	<cfloop query="d">
		<cfset result=tc.validateName(scientific_name)>
		<cfquery name="u" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_temp_taxon_name set status='#result.consensus#' where scientific_name='#scientific_name#'
		</cfquery>
	</cfloop>
	<cflocation url="BulkloadTaxonomy.cfm" addtoken="false">
</cfoutput>
</cfif>



<!------------------------------------------------------->
<cfif action is "loadData">
<cfoutput>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from  cf_temp_taxon_name  where  upper(username)='#ucase(session.username)#'
	</cfquery>
	<cfloop query="d">
		<cftransaction>
			<cfquery name="isn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into taxon_name (scientific_name) values ('#scientific_name#')
			</cfquery>
			<cfquery name="dup" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				delete from cf_temp_taxon_name  where scientific_name='#scientific_name#' and upper(username)='#ucase(session.username)#'
			</cfquery>
			<br>loaded #scientific_name#
		</cftransaction>
	</cfloop>
	Spiffy, all done.
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">