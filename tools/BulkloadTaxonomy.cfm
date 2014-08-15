<cfinclude template="/includes/_header.cfm">
<cfset title="Bulkload Taxonomy">
<!---- make the table 

 revision to deal with name+classification in new model - seems we're going to have to eventually

 approach: add NULLable columns for every conceiveable rank

alter table cf_temp_taxonomy add SUBPHYLUM varchar2(255);
alter table cf_temp_taxonomy modify VALID_CATALOG_TERM_FG null;
alter table cf_temp_taxonomy modify SOURCE_AUTHORITY null;
alter table cf_temp_taxonomy modify SUBSPECIES varchar2(255);
alter table cf_temp_taxonomy modify PHYLCLASS varchar2(255);
alter table cf_temp_taxonomy modify SUBCLASS varchar2(255);
alter table cf_temp_taxonomy modify PHYLORDER varchar2(255);
alter table cf_temp_taxonomy modify SUBORDER varchar2(255);
alter table cf_temp_taxonomy modify FAMILY varchar2(255);
alter table cf_temp_taxonomy modify SUBFAMILY varchar2(255);


alter table cf_temp_taxonomy modify GENUS varchar2(255);
alter table cf_temp_taxonomy modify SUBGENUS varchar2(255);
alter table cf_temp_taxonomy modify SPECIES varchar2(255);
alter table cf_temp_taxonomy modify SOURCE_AUTHORITY varchar2(255);
alter table cf_temp_taxonomy modify TRIBE varchar2(255);
alter table cf_temp_taxonomy modify INFRASPECIFIC_RANK varchar2(255);
alter table cf_temp_taxonomy modify PHYLUM varchar2(255);
alter table cf_temp_taxonomy modify PHYLCLASS varchar2(255);




 								    VARCHAR2(20)
 								    VARCHAR2(255)
 								    VARCHAR2(30)
 								    VARCHAR2(30)
 SUPERFAMILY								    VARCHAR2(255)
  								    VARCHAR2(30)
 								    VARCHAR2(30)
 									    VARCHAR2(30)
 								    VARCHAR2(20)
 								    VARCHAR2(40)
 SUBSPECIES								    VARCHAR2(255)
 VALID_CATALOG_TERM_FG							    NUMBER
 							    VARCHAR2(45)
 SCIENTIFIC_NAME							    VARCHAR2(255)
 AUTHOR_TEXT								    VARCHAR2(255)
 									    VARCHAR2(30)
 							    VARCHAR2(20)
 TAXON_REMARKS								    VARCHAR2(255)
  								    VARCHAR2(30)
 KINGDOM								    VARCHAR2(255)
 NOMENCLATURAL_CODE							    VARCHAR2(255)
 INFRASPECIFIC_AUTHOR							    VARCHAR2(255)
 TAXON_STATUS								    VARCHAR2(255)
 SUBPHYLUM								    VARCHAR2(255)
 DISPLAY_NAME								    VARCHAR2(255)
 SOURCE 								    VARCHAR2(255)

UAM@ARCTEST> 






alter table cf_temp_taxonomy modify NOMENCLATURAL_CODE null;

alter table cf_temp_taxonomy add display_name varchar2(255);
alter table cf_temp_taxonomy add source varchar2(255);


alter table cf_temp_taxonomy drop column INFRASPECIFIC_RANK;


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
    	output = "#t.columnlist#" addNewLine = "no">
	<cflocation url="/download.cfm?file=BulkTaxonomy.csv" addtoken="false">
</cfif>
<!------------------------------------------------------->
<cfif action is "nothing">
	<cfoutput>
		Load names, optionally with classifications. This form will happily create garbage; use the Contact link below to ask questions and do not
		click any buttons unless you KNOW what they do.
		 
		Upload a comma-delimited text file (csv). <a href="BulkloadTaxonomy.cfm?action=makeTemplate">[ Get the Template ]</a>
		 <p>
		 	You can (and should) also pull classification from globalnames.
		 </p>
		 <p>subgeneric terms are multinomial</p>
		 <p>
		 	Source is <a href="/info/ctDocumentation.cfm?table=CTTAXONOMY_SOURCE">CTTAXONOMY_SOURCE</a>
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
	<cflocation url="BulkloadTaxonomy.cfm?action=show" addtoken="false">
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "show">
<cfoutput>	 
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_taxonomy
	</cfquery>
	<cfquery name="isProb" dbtype="query">
		select count(*) c from data where status ='valid'
	</cfquery>
	<p>
		This form will happily create garbage. CHECK <strong>ALL</strong> DATA CAREFULLY BEFORE LOADING!!!
	</p>
	<p>
		This form is not the preferred method of creating classifications. Use GNITE if you can.
	</p>
	<P>
		Some terms may not mean what you think they do. Ask us (contact link below) if you're uncertain.
	</P>
	
	<ul>
		<cfif isProb.c eq data.recordcount>
			<li><strong>Carefully</strong> check the table below, then <a href="BulkloadTaxonomy.cfm?action=loadData">continue to load</a></li>
		</cfif>
		<li>
			<a href="BulkloadTaxonomy.cfm?action=autogenmn">Click here to generate multinomials</a>
			<br>Do this BEFORE generating display_name
			<br>Do this BEFORE validation
			<br>CHECK THE RESULTS
		</li>
		
		<li>
			<a href="BulkloadTaxonomy.cfm?action=autogendispname">Click here to generate display_name</a> 
			Do this BEFORE validation and CHECK THE RESULTS. This may not do what you want if you don't specify nomenclatural_code.  
		</li>
		<li><a href="BulkloadTaxonomy.cfm?action=validate">validate</a></li>
		<li><a href="BulkloadTaxonomy.cfm?action=deleteDups">discard duplicate names</a></li>
		<li><a href="BulkloadTaxonomy.cfm?action=down">download</a></li>
		<li><a href="BulkloadTaxonomy.cfm?action=nothing">start over</a></li>
	</ul>		
	<cfdump var=#data#>
</cfoutput>
</cfif>

	

<!------------------------------------------------------->
<cfif action is "deleteDups">
	<cfoutput>
		<cfquery name="bad2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from cf_temp_taxonomy where trim(scientific_name) IN (select trim(scientific_name) from taxon_name)
		</cfquery>
		<cflocation url="BulkloadTaxonomy.cfm?action=show" addtoken="false">
	</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "autogenmn">
<cfoutput>


	<cfquery name="spwsp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) c from cf_temp_taxonomy where species is not null and species like '% %'
	</cfquery>
	<cfif spwsp.c gt 0>
		This app will only work if all species are monomials.
		<cfabort>
	</cfif>
	<cfquery name="sspwsp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) c from cf_temp_taxonomy where subspecies is not null and subspecies like '% %'
	</cfquery>
	<cfif sspwsp.c gt 0>
		This app will only work if all subspecies are monomials.
		<cfabort>
	</cfif>

	<cfquery name="sspwnsp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) c from cf_temp_taxonomy where species is null and subspecies is not null
	</cfquery>
	<cfif sspwnsp.c gt 0>
		Subspecies without species - aborting
		<cfabort>
	</cfif>

	<cfquery name="genwnsp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) c from cf_temp_taxonomy where genus is null and species is not null
	</cfquery>
	<cfif genwnsp.c gt 0>
		species without genus - aborting
		<cfabort>
	</cfif>
	<cfquery name="mksp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_taxonomy set species = genus || ' ' || species where genus is not null and species is not null
	</cfquery>
	
	<cfquery name="mksp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_taxonomy set subspecies = species || ' ' || subspecies where species is not null and subspecies is not null
	</cfquery>

	<cflocation url="BulkloadTaxonomy.cfm?action=show" addtoken="false">		
	
</cfoutput>
</cfif>



<!------------------------------------------------------->
<cfif action is "autogendispname">
<cfoutput>
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_taxonomy
	</cfquery>
	<cfloop query="data">
		<!---- got species or better ---->
		<cfif len(species) gt 0>
			<cfset dn="<i>#species#</i>">
			<cfif nomenclatural_code is "icbn">
				<cfif len(AUTHOR_TEXT) gt 0>
					<cfset dn="#dn# #AUTHOR_TEXT#">
				</cfif>
				<cfif len(subspecies) gt 0>
					<cfset dn="#dn# <i>#replace(subspecies,species,'')#</i>">
				</cfif>
				<cfif len(INFRASPECIFIC_AUTHOR) gt 0>
					<cfset dn="#dn# #INFRASPECIFIC_AUTHOR#">
				</cfif>
			<cfelse>
				<cfif len(subspecies) gt 0>
					<cfset dn="#dn# <i>#replace(subspecies,species,'')#</i>">
				</cfif>
				<cfif len(AUTHOR_TEXT) gt 0>
					<cfset dn="#dn# #AUTHOR_TEXT#">
				</cfif>
			</cfif>
		<cfelseif len(genus) gt 0>
			<!---- got genus - italicize---->
			<cfset dn="<i>#genus#</i> #AUTHOR_TEXT#">
		<!--- now just run down the ranks until we find something ---->
		<cfelseif len(TRIBE) gt 0>
			<cfset dn="#TRIBE# #AUTHOR_TEXT#">
		<cfelseif len(SUBFAMILY) gt 0>
			<cfset dn="#SUBFAMILY# #AUTHOR_TEXT#">
		<cfelseif len(FAMILY) gt 0>
			<cfset dn="#FAMILY# #AUTHOR_TEXT#">
		<cfelseif len(SUPERFAMILY) gt 0>
			<cfset dn="#SUPERFAMILY# #AUTHOR_TEXT#">
		<cfelseif len(SUBORDER) gt 0>
			<cfset dn="#SUBORDER# #AUTHOR_TEXT#">
		<cfelseif len(PHYLORDER) gt 0>
			<cfset dn="#PHYLORDER# #AUTHOR_TEXT#">
		<cfelseif len(SUBCLASS) gt 0>
			<cfset dn="#SUBCLASS# #AUTHOR_TEXT#">
		<cfelseif len(PHYLCLASS) gt 0>
			<cfset dn="#PHYLCLASS# #AUTHOR_TEXT#">
		<cfelseif len(SUBPHYLUM) gt 0>
			<cfset dn="#SUBPHYLUM# #AUTHOR_TEXT#">
		<cfelseif len(PHYLUM) gt 0>
			<cfset dn="#PHYLUM# #AUTHOR_TEXT#">
		<cfelseif len(KINGDOM) gt 0>
			<cfset dn="#KINGDOM# #AUTHOR_TEXT#">
		</cfif>
		
		<cfset dn=replace(dn,'  ',' ','all')>
		<cfset dn=replace(dn,'</i> <i>','')>
		<cfset dn=replace(dn,'</i><i>','')>
		
		<cfset dn=replace(dn,'  ',' ','all')>
		<cfset dn=trim(dn)>
		<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_temp_taxonomy set display_name='#dn#' where key='#key#'	
		</cfquery>
	</cfloop>
	<cflocation url="BulkloadTaxonomy.cfm?action=show" addtoken="false">		
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "validate">
<cfoutput>
	<cfquery name="remainder" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_taxonomy set status = NULL
	</cfquery>
	<cfquery name="bad2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_taxonomy set status = 'duplicate' where trim(scientific_name) IN (select trim(scientific_name) from taxon_name)
	</cfquery>
	<cfquery name="bad2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_taxonomy set status = 'invalid source' where source not in (select source from CTTAXONOMY_SOURCE)
	</cfquery>
	<cfquery name="remainder" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_taxonomy set status = 'valid' where status is null
	</cfquery>
	<cflocation url="BulkloadTaxonomy.cfm?action=show" addtoken="false">
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "loadData">
<cfoutput>
	<cfquery name="data" datasource="user_login" username='#session.username#' password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_taxonomy
	</cfquery>
	<cfquery name="isv" dbtype="query">
		select count(*) c from data where status='valid'
	</cfquery>
	<cfif isv.c neq data.recordcount>
		validate first<cfabort>
	</cfif>
	
	<cfset orderedClassificationTerms="KINGDOM,PHYLUM,SUBPHYLUM,PHYLCLASS,SUBCLASS,PHYLORDER,SUBORDER,SUPERFAMILY,FAMILY,SUBFAMILY,TRIBE,GENUS,SUBGENUS,SPECIES,SUBSPECIES,SCIENTIFIC_NAME">
	<cfset nonClassificationTerms="display_name,AUTHOR_TEXT,INFRASPECIFIC_AUTHOR,SOURCE_AUTHORITY,NOMENCLATURAL_CODE,VALID_CATALOG_TERM_FG,TAXON_STATUS,TAXON_REMARKS">

	<cftransaction>
		<cfloop query="data">
			<cfquery name="tid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select sq_taxon_name_id.nextval x from dual
			</cfquery>
			<cfset taxon_name_id=tid.x>
			<cfset thisClassID=createUUID()>
			<cfset thisPosition=1>
			<cfquery name="n" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into taxon_name (taxon_name_id,scientific_name) values (#taxon_name_id#,'#trim(scientific_name)#')
			</cfquery>
			<cfloop list="#orderedClassificationTerms#" index="t">
				<cfset thisTermVal=evaluate("data." & t)>
				<cfif len(thisTermVal) gt 0>
					<cfif t is "phylclass">
						<cfset thisTerm='class'>
					<cfelseif t is "phylorder">
						<cfset thisTerm='order'>
					<cfelse>
						<cfset thisTerm=lcase(t)>
					</cfif>
					<cfquery name="term" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						insert into taxon_term ( 
							TAXON_TERM_ID,          taxon_name_id,           CLASSIFICATION_ID,TERM,         TERM_TYPE,    SOURCE,POSITION_IN_CLASSIFICATION,LASTDATE
						) values (
							sq_taxon_term_id.nextval,#taxon_name_id#,'#thisClassID#', '#thisTermVal#','#thisTerm#','TEST',#thisPosition#,sysdate
						) 
					</cfquery>
					<cfset thisPosition=thisPosition+1>
				</cfif>
			</cfloop>
			<cfloop list="#nonClassificationTerms#" index="t">
				<cfset thisTermVal=evaluate("data." & t)>
				<cfif len(thisTermVal) gt 0>
				<cfset thisTerm=lcase(t)>
					<cfquery name="term" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						insert into taxon_term ( 
							TAXON_TERM_ID,          taxon_name_id,           CLASSIFICATION_ID,TERM,         TERM_TYPE,    SOURCE,LASTDATE
						) values (
							sq_taxon_term_id.nextval,#taxon_name_id#,'#thisClassID#', '#thisTermVal#','#thisTerm#','TEST',sysdate
						) 
					</cfquery>
				</cfif>
			</cfloop>
		</cfloop>
	</cftransaction>
	
	
	<!--- sequences super wonky - do it with a billion connects for now....
	
	
	<cfset sql="insert all ">
	<cfloop query="data">		
		<cfset sql=sql & " into taxon_name (taxon_name_id,scientific_name) values (	sq_taxon_name_id.nextval,'#trim(scientific_name)#') ">
		<cfset thisClassID=createUUID()>
		<cfset thisRank=1>
		<cfif len(KINGDOM) gt 0>
			<cfset sql=sql & " into taxon_term ( 
								TAXON_TERM_ID,taxon_name_id,CLASSIFICATION_ID,TERM,TERM_TYPE,SOURCE,POSITION_IN_CLASSIFICATION,LASTDATE
							) values (
								sq_taxon_term_id.nextval,sq_taxon_name_id.currval,'#thisClassID#','#kingdom#','kingdom','TEST',#thisRank#,sysdate
							) ">
			<cfset thisRank=thisRank+1>
		</cfif>
		<cfif len(PHYLUM) gt 0>
			<cfset sql=sql & " into taxon_term ( 
								TAXON_TERM_ID,taxon_name_id,CLASSIFICATION_ID,TERM,TERM_TYPE,SOURCE,POSITION_IN_CLASSIFICATION,LASTDATE
							) values (
								sq_taxon_term_id.nextval,sq_taxon_name_id.currval,'#thisClassID#','#PHYLUM#','phylum','TEST',#thisRank#,sysdate
							) ">
			<cfset thisRank=thisRank+1>
		</cfif>
		<cfif len(SUBPHYLUM) gt 0>
			<cfset sql=sql & " into taxon_term ( 
								TAXON_TERM_ID,taxon_name_id,CLASSIFICATION_ID,TERM,TERM_TYPE,SOURCE,POSITION_IN_CLASSIFICATION,LASTDATE
							) values (
								sq_taxon_term_id.nextval,sq_taxon_name_id.currval,'#thisClassID#','#SUBPHYLUM#','subphylum','TEST',#thisRank#,sysdate
							) ">
			<cfset thisRank=thisRank+1>
		</cfif>
		<cfif len(PHYLCLASS) gt 0>
			<cfset sql=sql & " into taxon_term ( 
								TAXON_TERM_ID,taxon_name_id,CLASSIFICATION_ID,TERM,TERM_TYPE,SOURCE,POSITION_IN_CLASSIFICATION,LASTDATE
							) values (
								sq_taxon_term_id.nextval,sq_taxon_name_id.currval,'#thisClassID#','#PHYLCLASS#','class','TEST',#thisRank#,sysdate
							) ">
			<cfset thisRank=thisRank+1>
		</cfif>
		<cfif len(SUBCLASS) gt 0>
			<cfset sql=sql & " into taxon_term ( 
								TAXON_TERM_ID,taxon_name_id,CLASSIFICATION_ID,TERM,TERM_TYPE,SOURCE,POSITION_IN_CLASSIFICATION,LASTDATE
							) values (
								sq_taxon_term_id.nextval,sq_taxon_name_id.currval,'#thisClassID#','#SUBCLASS#','subclass','TEST',#thisRank#,sysdate
							) ">
			<cfset thisRank=thisRank+1>
		</cfif>
		<cfif len(PHYLORDER) gt 0>
			<cfset sql=sql & " into taxon_term ( 
								TAXON_TERM_ID,taxon_name_id,CLASSIFICATION_ID,TERM,TERM_TYPE,SOURCE,POSITION_IN_CLASSIFICATION,LASTDATE
							) values (
								sq_taxon_term_id.nextval,sq_taxon_name_id.currval,'#thisClassID#','#PHYLORDER#','order','TEST',#thisRank#,sysdate
							) ">
			<cfset thisRank=thisRank+1>
		</cfif>
		<cfif len(SUBORDER) gt 0>
			<cfset sql=sql & " into taxon_term ( 
								TAXON_TERM_ID,taxon_name_id,CLASSIFICATION_ID,TERM,TERM_TYPE,SOURCE,POSITION_IN_CLASSIFICATION,LASTDATE
							) values (
								sq_taxon_term_id.nextval,sq_taxon_name_id.currval,'#thisClassID#','#SUBORDER#','suborder','TEST',#thisRank#,sysdate
							) ">
			<cfset thisRank=thisRank+1>
		</cfif>
		<cfif len(SUPERFAMILY) gt 0>
			<cfset sql=sql & " into taxon_term ( 
								TAXON_TERM_ID,taxon_name_id,CLASSIFICATION_ID,TERM,TERM_TYPE,SOURCE,POSITION_IN_CLASSIFICATION,LASTDATE
							) values (
								sq_taxon_term_id.nextval,sq_taxon_name_id.currval,'#thisClassID#','#SUPERFAMILY#','superfamily','TEST',#thisRank#,sysdate
							) ">
			<cfset thisRank=thisRank+1>
		</cfif>
		<cfif len(FAMILY) gt 0>
			<cfset sql=sql & " into taxon_term ( 
								TAXON_TERM_ID,taxon_name_id,CLASSIFICATION_ID,TERM,TERM_TYPE,SOURCE,POSITION_IN_CLASSIFICATION,LASTDATE
							) values (
								sq_taxon_term_id.nextval,sq_taxon_name_id.currval,'#thisClassID#','#FAMILY#','family','TEST',#thisRank#,sysdate
							) ">
			<cfset thisRank=thisRank+1>
		</cfif>
		<cfif len(SUBFAMILY) gt 0>
			<cfset sql=sql & " into taxon_term ( 
								TAXON_TERM_ID,taxon_name_id,CLASSIFICATION_ID,TERM,TERM_TYPE,SOURCE,POSITION_IN_CLASSIFICATION,LASTDATE
							) values (
								sq_taxon_term_id.nextval,sq_taxon_name_id.currval,'#thisClassID#','#SUBFAMILY#','subfamily','TEST',#thisRank#,sysdate
							) ">
			<cfset thisRank=thisRank+1>
		</cfif>
		<cfif len(TRIBE) gt 0>
			<cfset sql=sql & " into taxon_term ( 
								TAXON_TERM_ID,taxon_name_id,CLASSIFICATION_ID,TERM,TERM_TYPE,SOURCE,POSITION_IN_CLASSIFICATION,LASTDATE
							) values (
								sq_taxon_term_id.nextval,sq_taxon_name_id.currval,'#thisClassID#','#TRIBE#','tribe','TEST',#thisRank#,sysdate
							) ">
			<cfset thisRank=thisRank+1>
		</cfif>
		<cfif len(GENUS) gt 0>
			<cfset sql=sql & " into taxon_term ( 
								TAXON_TERM_ID,taxon_name_id,CLASSIFICATION_ID,TERM,TERM_TYPE,SOURCE,POSITION_IN_CLASSIFICATION,LASTDATE
							) values (
								sq_taxon_term_id.nextval,sq_taxon_name_id.currval,'#thisClassID#','#GENUS#','genus','TEST',#thisRank#,sysdate
							) ">
			<cfset thisRank=thisRank+1>
		</cfif>
		<cfif len(SUBGENUS) gt 0>
			<cfset sql=sql & " into taxon_term ( 
								TAXON_TERM_ID,taxon_name_id,CLASSIFICATION_ID,TERM,TERM_TYPE,SOURCE,POSITION_IN_CLASSIFICATION,LASTDATE
							) values (
								sq_taxon_term_id.nextval,sq_taxon_name_id.currval,'#thisClassID#','#SUBGENUS#','subgenus','TEST',#thisRank#,sysdate
							) ">
			<cfset thisRank=thisRank+1>
		</cfif>
		<cfif len(SPECIES) gt 0>
			<cfset sql=sql & " into taxon_term ( 
								TAXON_TERM_ID,taxon_name_id,CLASSIFICATION_ID,TERM,TERM_TYPE,SOURCE,POSITION_IN_CLASSIFICATION,LASTDATE
							) values (
								sq_taxon_term_id.nextval,sq_taxon_name_id.currval,'#thisClassID#','#SPECIES#','species','TEST',#thisRank#,sysdate
							) ">
			<cfset thisRank=thisRank+1>
		</cfif>
		<cfif len(SUBSPECIES) gt 0>
			<cfset sql=sql & " into taxon_term ( 
								TAXON_TERM_ID,taxon_name_id,CLASSIFICATION_ID,TERM,TERM_TYPE,SOURCE,POSITION_IN_CLASSIFICATION,LASTDATE
							) values (
								sq_taxon_term_id.nextval,sq_taxon_name_id.currval,'#thisClassID#','#SUBSPECIES#','subspecies','TEST',#thisRank#,sysdate
							) ">
			<cfset thisRank=thisRank+1>
		</cfif>
		<cfif len(SCIENTIFIC_NAME) gt 0>
			<cfset sql=sql & " into taxon_term ( 
								TAXON_TERM_ID,taxon_name_id,CLASSIFICATION_ID,TERM,TERM_TYPE,SOURCE,POSITION_IN_CLASSIFICATION,LASTDATE
							) values (
								sq_taxon_term_id.nextval,sq_taxon_name_id.currval,'#thisClassID#','#SCIENTIFIC_NAME#','scientific_name','TEST',#thisRank#,sysdate
							) ">
			<cfset thisRank=thisRank+1>
		</cfif>
		
		
		<!---- end ordered terms ---->
		
		<cfif len(VALID_CATALOG_TERM_FG) gt 0>
			<cfset sql=sql & " into taxon_term ( 
								TAXON_TERM_ID,taxon_name_id,CLASSIFICATION_ID,TERM,TERM_TYPE,SOURCE,LASTDATE
							) values (
								sq_taxon_term_id.nextval,sq_taxon_name_id.currval,'#thisClassID#','#VALID_CATALOG_TERM_FG#','valid_catalog_term_fg','TEST',sysdate
							) ">
		</cfif>
		<cfif len(SOURCE_AUTHORITY) gt 0>
			<cfset sql=sql & " into taxon_term ( 
								TAXON_TERM_ID,taxon_name_id,CLASSIFICATION_ID,TERM,TERM_TYPE,SOURCE,LASTDATE
							) values (
								sq_taxon_term_id.nextval,sq_taxon_name_id.currval,'#thisClassID#','#SOURCE_AUTHORITY#','source_authority','TEST',sysdate
							) ">
		</cfif>
		<cfif len(SOURCE_AUTHORITY) gt 0>
			<cfset sql=sql & " into taxon_term ( 
								TAXON_TERM_ID,taxon_name_id,CLASSIFICATION_ID,TERM,TERM_TYPE,SOURCE,LASTDATE
							) values (
								sq_taxon_term_id.nextval,sq_taxon_name_id.currval,'#thisClassID#','#SOURCE_AUTHORITY#','source_authority','TEST',sysdate
							) ">
		</cfif>
		<cfif len(AUTHOR_TEXT) gt 0>
			<cfset sql=sql & " into taxon_term ( 
								TAXON_TERM_ID,taxon_name_id,CLASSIFICATION_ID,TERM,TERM_TYPE,SOURCE,LASTDATE
							) values (
								sq_taxon_term_id.nextval,sq_taxon_name_id.currval,'#thisClassID#','#AUTHOR_TEXT#','author_text','TEST',sysdate
							) ">
		</cfif>
		<cfif len(AUTHOR_TEXT) gt 0>
			<cfset sql=sql & " into taxon_term ( 
								TAXON_TERM_ID,taxon_name_id,CLASSIFICATION_ID,TERM,TERM_TYPE,SOURCE,LASTDATE
							) values (
								sq_taxon_term_id.nextval,sq_taxon_name_id.currval,'#thisClassID#','#AUTHOR_TEXT#','author_text','TEST',sysdate
							) ">
		</cfif>
		<cfif len(TAXON_REMARKS) gt 0>
			<cfset sql=sql & " into taxon_term ( 
								TAXON_TERM_ID,taxon_name_id,CLASSIFICATION_ID,TERM,TERM_TYPE,SOURCE,LASTDATE
							) values (
								sq_taxon_term_id.nextval,sq_taxon_name_id.currval,'#thisClassID#','#TAXON_REMARKS#','taxon_remarks','TEST',sysdate
							) ">
		</cfif>
		<cfif len(NOMENCLATURAL_CODE) gt 0>
			<cfset sql=sql & " into taxon_term ( 
								TAXON_TERM_ID,taxon_name_id,CLASSIFICATION_ID,TERM,TERM_TYPE,SOURCE,LASTDATE
							) values (
								sq_taxon_term_id.nextval,sq_taxon_name_id.currval,'#thisClassID#','#NOMENCLATURAL_CODE#','nomenclatural_code','TEST',sysdate
							) ">
		</cfif>
		<cfif len(INFRASPECIFIC_AUTHOR) gt 0>
			<cfset sql=sql & " into taxon_term ( 
								TAXON_TERM_ID,taxon_name_id,CLASSIFICATION_ID,TERM,TERM_TYPE,SOURCE,LASTDATE
							) values (
								sq_taxon_term_id.nextval,sq_taxon_name_id.currval,'#thisClassID#','#INFRASPECIFIC_AUTHOR#','infraspecific_author','TEST',sysdate
							) ">
		</cfif>
		<cfif len(TAXON_STATUS) gt 0>
			<cfset sql=sql & " into taxon_term ( 
								TAXON_TERM_ID,taxon_name_id,CLASSIFICATION_ID,TERM,TERM_TYPE,SOURCE,LASTDATE
							) values (
								sq_taxon_term_id.nextval,sq_taxon_name_id.currval,'#thisClassID#','#TAXON_STATUS#','infraspetaxon_statuscific_author','TEST',sysdate
							) ">
		</cfif>
		
		
		
	</cfloop>
	<cfset sql=sql & "SELECT 1 FROM DUAL">

<cfdump var=#sql#>


			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				#preservesinglequotes(sql)#
			</cfquery>

------>
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
