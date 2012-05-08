<!----
KEY									    NUMBER
 								    

drop table cf_temp_citation;

create table cf_temp_citation (
	KEY number not null.
	FULL_CITATION VARCHAR2(4000),
 	PUBLICATION_ID NUMBER,
 	GUID_PREFIX	VARCHAR2(20),
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

grant insert,update,delete ON CF_TEMP_CITATION to COLDFUSION_USER;

---->

<cfinclude template="/includes/_header.cfm">
<cfset title="Bulkload Citations">

<cfif action is "makeTemplate">
	<cfset header="FULL_CITATION,PUBLICATION_ID,GUID_PREFIX,OTHER_ID_TYPE,OTHER_ID_NUMBER,TYPE_STATUS,OCCURS_PAGE_NUMBER,CITATION_REMARKS,SCIENTIFIC_NAME,ACCEPTED_ID_FG,NATURE_OF_ID,MADE_DATE,IDENTIFIER_1,IDENTIFIER_2,IDENTIFIER_3,IDENTIFICATION_REMARKS">
	<cffile action = "write" 
    file = "#Application.webDirectory#/download/BulkCitationsTemplate.csv"
    output = "#header#"
    addNewLine = "no">
	<cflocation url="/download.cfm?file=BulkCitationsTemplate.csv" addtoken="false">
</cfif>


<cfif action is "csv">
	<cfoutput>
		<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_temp_citation
		</cfquery>
		<cfset variables.encoding="UTF-8">
		<cfset variables.fileName="#Application.webDirectory#/download/BulkCitationsDown.csv">
		<cfscript>
			variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
			variables.joFileWriter.writeLine(mine.columnList); 
		</cfscript>
		<cfloop query="mine">
			<cfset d=''>
			<cfloop list="#mine.columnList#" index="i">
				<cfif i is "loaded_media_id">
				<cfset t='"' & evaluate("mine." & i) & '"'>
				<cfset d=listappend(d,t,",")>
			</cfloop>
			<cfscript>
				variables.joFileWriter.writeLine(d); 
			</cfscript>
		</cfloop>
		<cfscript>	
			variables.joFileWriter.close();
		</cfscript>
		<cflocation url="/download.cfm?file=BulkCitationsDown.csv" addtoken="false">
		<a href="/download/BulkCitationsDown.csv">Click here if your file does not automatically download.</a>
	</cfoutput>
</cfif>


<cfif action is "nothing">
	Step 1: Upload a comma-delimited text file (csv). 
	Include column headings. <a href="BulkloadCitations.cfm?action=makeTemplate">Get a template</a>
	
	<table border>
		<tr>
			<th>ColumnName</th>
			<th>Required</th>
			<th>Explanation</th>
			<th>Documentation</th>
		</tr>
		<tr>
			<td>guid_prefix</td>
			<td>yes</td>
			<td>find under Manage Collections - things like "UAM:Mamm"</td>
			<td><a href="http://arctosdb.org/documentation/catalog/#guid">docs</a></td>
		</tr>
		<tr>
			<td>other_id_type</td>
			<td>yes</td>
			<td>"catalog number" is valid but not in teh code table</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTCOLL_OTHER_ID_TYPE">CTCOLL_OTHER_ID_TYPE</a></td>
		</tr>
		<tr>
			<td>other_id_number</td>
			<td>yes</td>
			<td>the value of the identifier/catalog number</td>
			<td></td>
		</tr>
		<tr>
			<td>full_citation</td>
			<td>conditionally</td>
			<td>includes markup, etc. - use either this or publication_id, not both</td>
			<td></td>
		</tr>
		<tr>
			<td>publication_id</td>
			<td>conditionally</td>
			<td>find in URLs - eg, http://arctos.database.museum/publication/<strong>1</strong> - use either this or full_citation, not both</td>
			<td></td>
		</tr>
		<tr>
			<td>type_status</td>
			<td>yes</td>
			<td></td>
			<td><a href="/info/ctDocumentation.cfm?table=CTCITATION_TYPE_STATUS">CTCITATION_TYPE_STATUS</a></td>
		</tr>
		<tr>
			<td>occurs_page_number</td>
			<td>no</td>
			<td>numeric page number value on which the citation occurs</td>
			<td></td>
		</tr>
		<tr>
			<td>citation_remarks</td>
			<td>no</td>
			<td>remarks concerning the citation, or linkage between the specimen and publication</td>
			<td></td>
		</tr>
		<tr>
			<td>scientific_name</td>
			<td>yes</td>
			<td>Identification.scientific_name to apply to the specimen</td>
			<td><a href="http://arctosdb.org/documentation/identification/#scientific_name">identification.scientific_name</a></td>
		</tr>
		<tr>
			<td>accepted_id_fg</td>
			<td>yes</td>
			<td>Should the citation-identification become the specimen's accepted ID?</td>
			<td>0 or 1</td>
		</tr>
		<tr>
			<td>nature_of_id</td>
			<td>yes</td>
			<td></td>
			<td><a href="/info/ctDocumentation.cfm?table=ctnature_of_id">ctnature_of_id</a></td>
		</tr>
		
		<tr>
			<td>made_date</td>
			<td>no</td>
			<td>ISO8601 data on which the ID was made (usually publication year)</td>
			<td></td>
		</tr>
		<tr>
			<td>identifier_1</td>
			<td>no</td>
			<td>First agent responsible for the identification</td>
			<td></td>
		</tr>
		<tr>
			<td>identifier_2</td>
			<td>no</td>
			<td></td>
			<td></td>
		</tr>
		<tr>
			<td>identifier_3</td>
			<td>no</td>
			<td>edit the specimen after loading Citations if >3 identifiers are deemed important</td>
			<td></td>
		</tr>
		<tr>
			<td>identification_remarks</td>
			<td>no</td>
			<td>remarks concerning the application of the taxon name(s) to the specimen</td>
			<td></td>
		</tr>
	</table>
	<cfform name="oids" method="post" enctype="multipart/form-data">
		<input type="hidden" name="Action" value="getFile">
		<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" class="insBtn">
	</cfform>
</cfif>
<!------------------------------------------------------->
<cfif #action# is "getFile">
<cfoutput>


	<!--- put this in a temp table --->
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from cf_temp_citation
	</cfquery>

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
				insert into cf_temp_citation (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>
	<cflocation url="BulkloadCitations.cfm?action=validate" addtoken="false">
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "validate">
<cfoutput>
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_citation set status='missing data'
		where
		other_id_type is null or
		other_id_number is null or
		guid_prefix is null or
		(full_citation is null and publication_id is null) or
		SCIENTIFIC_NAME is null or
		TYPE_STATUS is null or
		ACCEPTED_ID_FG is null or
		NATURE_OF_ID is null
	</cfquery>
	<cfquery name="ctcitation_TYPE_STATUS" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_citation set status='TYPE_STATUS invalid'
		where
		TYPE_STATUS not in (select TYPE_STATUS from ctcitation_TYPE_STATUS
	</cfquery>
	<cfquery name="NATURE_OF_ID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_citation set status='NATURE_OF_ID invalid'
		where
		NATURE_OF_ID not in (select NATURE_OF_ID from ctNATURE_OF_ID
	</cfquery>
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_citation where status is null
	</cfquery>
	<cfloop query="data">
		<cfset problem="">
		<cfquery name="collObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select 
				cataloged_item.COLLECTION_OBJECT_ID
			from
				cataloged_item,
				collection,
				coll_obj_other_id_num
			where
				cataloged_item.collection_id=collection.collection_id and
				cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id (+) AND
				upper(cataloged_item.guid_prefix)='#ucase(guid_prefix)#' and
				<cfif other_id_type is "catalog number">
					cat_num=#trim(other_id_number)#
				<cfelse>
					other_id_type = '#trim(other_id_type)#' and
					display_value = '#trim(other_id_number)#'
				</cfif>
		</cfquery>
		<cfset thisColObjId=collObj.COLLECTION_OBJECT_ID>
		
		<cfif len(publication_id) is 0>
			<cfquery name="isPub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select publication_id from publication where full_citation = '#full_citation#'
				group by publication_id
			</cfquery>
			<cfset thisPubId=isPub.publication_id>
		<cfelse>
			<cfset thisPubId=publication_id>
		</cfif>
		<cfinvoke component="component.functions" method="parseTaxonName" returnvariable="tn">
			<cfinvokeargument name="taxon_name" value="#SCIENTIFIC_NAME#">
		</cfinvoke>
		<cfset thisTNID1=tn.taxon_name_id_1>
		<cfset thisTNID2=tn.taxon_name_id_2>
		<cfset thisTNID2=tn.taxon_name_id_2>
		
		<cfset problem = listappend(problem,tn.status,";")>
		
		<cfinvoke component="component.functions" method="getAgentId" returnvariable="a">
			<cfinvokeargument name="agent_name" value="#IDENTIFIER_1#">
		</cfinvoke>
		<cfset problem = listappend(problem,a.status,";")>
		<cfset aid1=a.agent_id>
		<cfinvoke component="component.functions" method="getAgentId" returnvariable="a">
			<cfinvokeargument name="agent_name" value="#IDENTIFIER_2#">
		</cfinvoke>
		<cfset problem = listappend(problem,a.status,";")>
		<cfset aid2=a.agent_id>
		<cfinvoke component="component.functions" method="getAgentId" returnvariable="a">
			<cfinvokeargument name="agent_name" value="#IDENTIFIER_3#">
		</cfinvoke>
		<cfset problem = listappend(problem,a.status,";")>
		<cfset aid3=a.agent_id>
			
			
		
		<cfquery name="ss" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			UPDATE cf_temp_citation SET 
				collection_object_id = #thisColObjId#,
				publication_id=#thisPubId#
				<cfif len(aid1) gt 0>
					,agentid1=#aid1#
				</cfif>
				<cfif len(aid2) gt 0>
					,agentid2=#aid2#
				</cfif>
				<cfif len(aid3) gt 0>
					,agentid3=#aid3#
				</cfif>
				,status = '#problem#'
			 where
				key = #key#
		</cfquery>
	</cfloop>
	<cfquery name="valData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_citation set status='duplicate' where key in (				
			select distinct k from cf_temp_citation a,
			 (select min(key) k, collection_object_id,publication_id  
			from cf_temp_citation having count(*) >  1 group by 
			collection_object_id,publication_id) b
			where a.collection_object_id = b.collection_object_id and
			a.publication_id = b.publication_id
		)
	</cfquery>
	<cfquery name="valData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_citation order by status,
		other_id_type,
		other_id_number,
		full_citation
	</cfquery>
		<cfquery name="isProb" dbtype="query">
			select count(*) c from valData where status is not null
		</cfquery>
		 #isProb.c#
		<cfif #isProb.c# is 0 or len(isprob.c) is 0>
			Data validated. Double-check below. If everything looks OK, <a href="BulkloadCitations.cfm?action=loadData">proceed to load</a>
		<cfelse>
			The data you loaded do not validate. See STATUS column below.
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
	
		
	<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_citation
	</cfquery>
	
	<cftransaction>
	<cfloop query="getTempData">
		<cfquery name="insert" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into citation (
				PUBLICATION_ID,
				COLLECTION_OBJECT_ID,
				CITED_TAXON_NAME_ID,
				CIT_CURRENT_FG
				<cfif len(#OCCURS_PAGE_NUMBER#) gt 0>
					,OCCURS_PAGE_NUMBER
				</cfif>
				<cfif len(#TYPE_STATUS#) gt 0>
					,TYPE_STATUS
				</cfif>
				<cfif len(#CITATION_REMARKS#) gt 0>
					,CITATION_REMARKS
				</cfif>
			) values (
				#PUBLICATION_ID#,
				#COLLECTION_OBJECT_ID#,
				#CITED_TAXON_NAME_ID#,
				1
				<cfif len(#OCCURS_PAGE_NUMBER#) gt 0>
					,#OCCURS_PAGE_NUMBER#
				</cfif>
				<cfif len(#TYPE_STATUS#) gt 0>
					,'#TYPE_STATUS#'
				</cfif>
				<cfif len(#CITATION_REMARKS#) gt 0>
					,'#CITATION_REMARKS#'
				</cfif>
			)
		</cfquery>
		<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_temp_citation set status='loaded' where key=#key#			
		</cfquery>
	</cfloop>
	</cftransaction>
<cflocation url="BulkloadCitations.cfm?action=allDone">
</cfoutput>
</cfif>
<!-------------------------------------------------------------------------->
<cfif #action# is "allDone">
	<cfoutput>
		<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select publication_id,full_citation,status from cf_temp_citation group by publication_id,full_citation,status 	
		</cfquery>
		<cfif #getTempData.recordcount# is 0>
			something very strange happened. Contact a sysadmin.
		</cfif>
		<cfloop query="getTempData">
			<cfif #status# is not "loaded">
				Something bad happened with #full_citation#. Contact your friendly local sysadmin.
			<cfelse>
				Everything seems to have worked! View citations for <a href="/Citation.cfm?publication_id=#publication_id#">#full_citation#</a>
			</cfif>
		</cfloop>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">
