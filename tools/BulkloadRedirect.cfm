<!----


drop table cf_temp_citation;

create table cf_temp_citation (
	KEY number not null,
	FULL_CITATION VARCHAR2(4000),
 	PUBLICATION_ID NUMBER,
 	GUID_PREFIX VARCHAR2(20),
	OTHER_ID_TYPE VARCHAR2(60),
 	OTHER_ID_NUMBER VARCHAR2(60),
 	COLLECTION_OBJECT_ID NUMBER,
 	TYPE_STATUS  VARCHAR2(60),
 	OCCURS_PAGE_NUMBER NUMBER,
 	CITATION_REMARKS VARCHAR2(255),
	SCIENTIFIC_NAME  VARCHAR2(60),
	taxonid1 number,
	taxonid2 number,
 	ACCEPTED_ID_FG NUMBER,
 	NATURE_OF_ID  VARCHAR2(60),
 	MADE_DATE  VARCHAR2(60),
 	IDENTIFICATION_REMARKS VARCHAR2(255),
 	IDENTIFIER_1 VARCHAR2(255),
 	agentid1 NUMBER,
 	IDENTIFIER_2 VARCHAR2(255),
 	agentid2 NUMBER,
 	IDENTIFIER_3 VARCHAR2(255),
 	agentid3 NUMBER,
	STATUS VARCHAR2(255)
);

ALTER TABLE cf_temp_citation add taxa_formula VARCHAR2(60);
ALTER TABLE cf_temp_citation add use_pub_authors number(1);

ALTER TABLE cf_temp_citation add CONSTRAINT pk_cf_temp_citation PRIMARY KEY (KEY);

CREATE OR REPLACE TRIGGER CF_TEMP_CITATION_KEY
before insert ON cf_temp_citation
for each row
begin
    if :NEW.key is null then
        select somerandomsequence.nextval
        into :new.key from dual;
    end if;
end;
/

create or replace public synonym CF_TEMP_CITATION for CF_TEMP_CITATION;

grant all ON CF_TEMP_CITATION to COLDFUSION_USER;

---->

<cfinclude template="/includes/_header.cfm">
<cfset title="Bulkload Redirects">

<cfif action is "makeTemplate">
	<cfset header="old_path,new_path">
	<cffile action = "write"
    file = "#Application.webDirectory#/download/BulkloadRedirect.csv"
    output = "#header#"
    addNewLine = "no">
	<cflocation url="/download.cfm?file=BulkloadRedirect.csv" addtoken="false">
</cfif>


<cfif action is "nothing">
	Step 1: Upload a comma-delimited text file (csv).
	Include CSV column headings.
	<ul>
		<li><a href="BulkloadRedirect.cfm?action=makeTemplate">Get a template</a></li>
	</ul>

	This app just loads stuff to the table. There's minimal checking, and failures will fail entirely - fix your CSV and try again.

	<table border>
		<tr>
			<th>ColumnName</th>
			<th>Required</th>
			<th>Explanation</th>
		</tr>
		<tr>
			<td>old_path</td>
			<td>yes</td>
			<td>
				Local path (without the http://arctos.database.museum bit) that you wish to redirect from. Must start with slash,
				and the resource must not exist for users to be redirected. ("mask record" encumbered specimens do not exist to non-operator
				users.) Must start with "/". Example: /guid/DGR:Mamm:49316
			</td>
		</tr>
		<tr>
			<td>new_path</td>
			<td>yes</td>
			<td>
				Local path or remote URL target. Examples: /guid/MSB:Mamm:194821 or http://arctosdb.wordpress.com/home/governance/joining-arctos/
			</td>
		</tr>
	</table>
	<p></p>
	<cfform name="oids" method="post" enctype="multipart/form-data">
		<input type="hidden" name="Action" value="getFile">
		<label for="FiletoUpload">Upload CSV</label>
		<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" class="insBtn">
	</cfform>
</cfif>
<!------------------------------------------------------->
<cfif action is "getFile">
<cfoutput>
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	<cfset fileContent=replace(fileContent,"'","''","all")>
	<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />
	<cfset colNames="">
	<cfloop from="1" to ="#ArrayLen(arrResult)#" index="o">
		<cfset colVals="">
			<cfloop from="1"  to ="#ArrayLen(arrResult[o])#" index="i">
				<cfset thisBit=arrResult[o][i]>
				<cfif #o# is 1>
					<cfset colNames="#colNames#,#thisBit#">
				<cfelse>
					<cfset colVals="#colVals#,'#thisBit#'">
				</cfif>
			</cfloop>
		<cfif #o# is 1>
			<cfset colNames=replace(colNames,",","","first")>
		</cfif>
		<cfif len(#colVals#) gt 1>
			<cfset colVals=replace(colVals,",","","first")>
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into redirect (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>
	all done
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">
