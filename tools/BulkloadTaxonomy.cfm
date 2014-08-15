<cfinclude template="/includes/_header.cfm">
<cfset title="Bulkload Taxonomy">
<!---- make the table 

 revision to deal with name+classification in new model - seems we're going to have to eventually

 approach: add NULLable columns for every conceiveable rank

alter table cf_temp_taxonomy add SUBPHYLUM varchar2(255);

------------- oldstuff follows ------------
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



	<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_taxonomy
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
	<cfquery name="t" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_taxonomy where 1=2
	</cfquery>
	<cffile action = "write" file = "#Application.webDirectory#/download/BulkTaxonomy.csv"
    	output = "#t.columlist#" addNewLine = "no">
	<cflocation url="/download.cfm?file=BulkTaxonomy.csv" addtoken="false">
</cfif>
<!------------------------------------------------------->
<cfif action is "nothing">
	<cfoutput>
		Load names, optionally with classifications later. 
		Upload a comma-delimited text file (csv). <a href="BulkloadTaxonomy.cfm?action=makeTemplate">[ Get the Template ]</a>
		 <p>
		 	You can also pull classification from globalnames.
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
		update cf_temp_taxonomy set status = 'duplicate' where trim(scientific_name) IN (select trim(scientific_name) from taxon_name)
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
	<cfdump var=#valData#>
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
	<cfset sql="insert all ">
	<cfloop query="data">		
		<cfset sql=sql & " into taxon_name (taxon_name_id,scientific_name) values (	sq_taxon_name_id.nextval,'#trim(scientific_name)#'">
		<cfset thisClassID=createUUID()>
		<cfset thisRank=1>
		<cfif len(KINGDOM) gt 0>
			<cfset sql=sql & " into taxon_term ( 
								TAXON_TERM_ID,taxon_name_id,CLASSIFICATION_ID,TERM,TERM_TYPE,SOURCE,POSITION_IN_CLASSIFICATION,LASTDATE
							) values (
								sq_taxon_temp_id.nextval,sq_taxon_name_id.currval,#thisClassID#,'#kingdom#','TEST',#thisRank#,sysdate
							)">
		
		</cfif>
	</cfloop>
	<cfset sql=sql & "SELECT 1 FROM DUAL">



<cfdump var=#sql#>



<!----
	
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
		
---->
	Spiffy, all done.
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">
