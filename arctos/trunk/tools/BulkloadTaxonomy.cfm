<cfinclude template="/includes/_header.cfm">
<cfset title="Bulkload Taxonomy">
<!---- make the table 

drop table cf_temp_taxonomy;

create table cf_temp_taxonomy (
	key number,
	status varchar2(4000),
 	SCIENTIFIC_NAME VARCHAR2(255)
);

	create or replace public synonym cf_temp_taxonomy for cf_temp_taxonomy;
	grant select,insert,update,delete on cf_temp_taxonomy to coldfusion_user;
	grant select on cf_temp_taxonomy to public;
	
	
CREATE OR REPLACE TRIGGER cf_temp_taxonomy_key                                         
 before insert  ON cf_temp_taxonomy
FOR EACH ROW
DECLARE
BEGIN
	if :NEW.key is null then
		select somerandomsequence.nextval into :new.key from dual;
    end if;    
	
END;
/
sho err

-------- classifications

drop table cf_temp_taxonomy;

create table cf_temp_taxonomy (
	key number,
	status varchar2(4000),
 	SCIENTIFIC_NAME VARCHAR2(255)
);

	create or replace public synonym cf_temp_taxonomy for cf_temp_taxonomy;
	grant select,insert,update,delete on cf_temp_taxonomy to coldfusion_user;
	grant select on cf_temp_taxonomy to public;
	
	
CREATE OR REPLACE TRIGGER cf_temp_taxonomy_key                                         
 before insert  ON cf_temp_taxonomy
FOR EACH ROW
DECLARE
BEGIN
	if :NEW.key is null then
		select somerandomsequence.nextval into :new.key from dual;
    end if;    
	
END;
/
sho err


        
		
		
        
------>

<!------------------------------------------------------->
<cfif action is "down">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_taxonomy
	</cfquery>
	<cfset ac = d.columnlist>
	<cfif ListFindNoCase(ac,'KEY')>
		<cfset ac = ListDeleteAt(ac, ListFindNoCase(ac,'KEY'))>
	</cfif>
	<cfset variables.encoding="UTF-8">
	<cfset fname = "BulkTaxaDown.csv">
	<cfset variables.fileName="#Application.webDirectory#/download/#fname#">
	<cfset header=trim(ac)>
	<cfscript>
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
		variables.joFileWriter.writeLine(header); 
	</cfscript>
	<cfloop query="d">
		<cfset oneLine = "">
		<cfloop list="#ac#" index="c">
			<cfset thisData = evaluate(c)>
			<cfif len(oneLine) is 0>
				<cfset oneLine = '"#thisData#"'>
			<cfelse>
				<cfset thisData=replace(thisData,'"','""','all')>
				<cfset oneLine = '#oneLine#,"#thisData#"'>
			</cfif>
		</cfloop>
		<cfset oneLine = trim(oneLine)>
		<cfscript>
			variables.joFileWriter.writeLine(oneLine);
		</cfscript>
	</cfloop>
	<cfscript>	
		variables.joFileWriter.close();
	</cfscript>
	<cflocation url="/download.cfm?file=#fname#" addtoken="false">
	<a href="/download/#fname#">Click here if your file does not automatically download.</a>
</cfif>
<!------------------------------------------------------->
<cfif action is "makeTemplate">
	<cfset header="SCIENTIFIC_NAME">
	<cffile action = "write" file = "#Application.webDirectory#/download/BulkTaxonomy.csv"
    	output = "#header#" addNewLine = "no">
	<cflocation url="/download.cfm?file=BulkTaxonomy.csv" addtoken="false">
</cfif>
<!------------------------------------------------------->
<cfif action is "nothing">
	<cfoutput>
		Load bare names. You can add classifications later. Or not. 
		Upload a comma-delimited text file (csv). <a href="BulkloadTaxonomy.cfm?action=makeTemplate">[ Get the Template ]</a>
		<p>Required fields:
			<ul>
				<li>SCIENTIFIC_NAME</li>
			</ul>
		</p>
		
		 <p>
		 	Need to load Classifications? <a href="/contact.cfm">Contact us</a>.
		 </p>
		 <p>
		 	You can pull pull classification from globalnames.
		 </p>
		<cfform name="oids" method="post" enctype="multipart/form-data">
			<input type="hidden" name="Action" value="getFile">
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
		delete from cf_temp_taxonomy
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
				insert into cf_temp_taxonomy (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>
	<cflocation url="BulkloadTaxonomy.cfm?action=validate" addtoken="false">
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "validate">
<cfoutput>	
	<cfquery name="bad2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_taxonomy set status = 'duplicate' where trim(scientific_name) IN (select trim(scientific_name) from taxonomy)
	</cfquery>
	
	<cfquery name="valData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_taxonomy
	</cfquery>
	<cfquery name="isProb" dbtype="query">
		select count(*) c from valData where status is not null
	</cfquery>
	<cfif #isProb.c# is 0 or isprob.c is "">
		Data validated. Carefully check the table below, then
		<a href="BulkloadTaxonomy.cfm?action=loadData">continue to load</a>.
	<cfelse>
		The data you loaded do not validate. See STATUS column below. Fix them all.
		<a href="BulkloadTaxonomy.cfm?action=down">[ download ]</a>
	</cfif>
		<table border>
			<tr>
				<th>KEY</th>
				<th>STATUS</th>
				<th>SCIENTIFIC_NAME</th>
			</tr>
			<cfloop query="valData">
				<tr>
					<td>#KEY#</td>
					<td>#STATUS#</td>
					<td>#SCIENTIFIC_NAME#</td>
				</tr>
			</cfloop>
		</table>
		<!---
	<cflocation url="BulkloadCitations.cfm?action=loadData">
	---->
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif #action# is "loadData">

<cfoutput>
	<cfquery name="data" datasource="user_login" username='#session.username#' password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_taxonomy
	</cfquery>
	<cftransaction>
	<cfloop query="data">
		<cfquery name="newTaxa" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			INSERT INTO taxon_name (
				taxon_name_id,
				scientific_name
			) values (
				sq_taxon_name_id.nextval,
				'#trim(scientific_name)#'
			)
		</cfquery>
		</cfloop>
	</cftransaction>
		

	Spiffy, all done.
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">
