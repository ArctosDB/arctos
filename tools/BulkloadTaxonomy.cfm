<cfinclude template="/includes/_header.cfm">
<cfset title="Bulkload Taxonomy">
<!---- make the table 

drop table cf_temp_taxonomy;

create table cf_temp_taxonomy (
	key number,
	status varchar2(4000),
 	PHYLCLASS                                                      VARCHAR2(20),
	SUBCLASS VARCHAR2(255),
	 PHYLORDER                                                      VARCHAR2(30),
	 SUBORDER                                                       VARCHAR2(30),
	 SUPERFAMILY VARCHAR2(255),
	 FAMILY                                                         VARCHAR2(30),
	 SUBFAMILY                                                      VARCHAR2(30),
	 GENUS                                                          VARCHAR2(30),
	 SUBGENUS                                                       VARCHAR2(20),
	 SPECIES                                                        VARCHAR2(40),
	 SUBSPECIES                                                     VARCHAR2(40),
	 VALID_CATALOG_TERM_FG                                NUMBER not null,
	 SOURCE_AUTHORITY                                     VARCHAR2(45) not null,
	 SCIENTIFIC_NAME                                      VARCHAR2(255),
	 AUTHOR_TEXT                                                    VARCHAR2(255),
	 TRIBE                                                          VARCHAR2(30),
	 INFRASPECIFIC_RANK                                             VARCHAR2(20),
	 TAXON_REMARKS                                                  VARCHAR2(255),
	 PHYLUM                                                         VARCHAR2(30),
	 KINGDOM                                                        VARCHAR2(255),
	 NOMENCLATURAL_CODE                                             VARCHAR2(255) not null,
	 INFRASPECIFIC_AUTHOR                                           VARCHAR2(255),
	 TAXON_STATUS VARCHAR2(255)
	 	);

	create or replace public synonym cf_temp_taxonomy for cf_temp_taxonomy;
	grant select,insert,update,delete on cf_temp_taxonomy to coldfusion_user;
	grant select on cf_temp_taxonomy to public;
	
	
CREATE OR REPLACE TRIGGER cf_temp_taxonomy_key                                         
 before insert  ON cf_temp_taxonomy
FOR EACH ROW
DECLARE
        nScientificName varchar2(4000);
        status varchar2(4000);
        nFullTaxonomy varchar2(4000);
        nDisplayName varchar2(4000);
        c NUMBER;
        stoopidX VARCHAR2(10):=CHR (215 USING NCHAR_CS);
BEGIN
	status:='';
	if :NEW.key is null then
		select somerandomsequence.nextval into :new.key from dual;
    end if;    
	if :NEW.nomenclatural_code != 'noncompliant' THEN
        IF :new.SUBORDER IS NOT NULL THEN
           IF NOT (regexp_like(:new.SUBORDER,'^[A-Z][a-z]*$')) THEN
                 status:=status || '; SUBORDER must be Proper Case.';
            END IF;
        END IF;
        IF :new.FAMILY IS NOT NULL THEN
                if :NEW.phylorder is null and :NEW.valid_catalog_term_fg = 1 then
                                status:=status || '; ' || 'Records with Family must have Order to be Accepted.';
                        end if;
                        IF NOT (regexp_like(:new.FAMILY,'^[A-Z][a-z]*$')) THEN
                 status:=status || '; ' || 'FAMILY (' || :new.FAMILY || ') must be Proper Case.';
            END IF;
        END IF;
		IF :new.SUBFAMILY IS NOT NULL THEN
           IF NOT (regexp_like(:new.SUBFAMILY,'^[A-Z][a-z]*$')) THEN
                 status:=status || '; ' || 'SUBFAMILY (' || :new.SUBFAMILY || ') must be Proper Case.';
            END IF;
        END IF;
        IF :new.SUBGENUS IS NOT NULL THEN
           IF NOT (regexp_like(:new.SUBGENUS,'^[A-Z][a-z]*$')) THEN
                 status:=status || '; ' || 'SUBGENUS (' || :new.SUBGENUS || ') must be Proper Case.';
            END IF;
        END IF;
        IF :new.TRIBE IS NOT NULL THEN
           IF NOT (regexp_like(:new.TRIBE,'^[A-Z][a-z]*$')) THEN
                status:=status || '; ' || 'TRIBE (' || :new.TRIBE || ') must be Proper Case.';
            END IF;
        END IF;    
        IF :new.PHYLUM IS NOT NULL THEN
           if :NEW.kingdom is null and :NEW.valid_catalog_term_fg = 1 then
                                status:=status || '; ' || 'Records with Phylum must have Kingdom to be Accepted.';
                        end if;
                        IF NOT (regexp_like(:new.PHYLUM,'^[A-Z][a-z]*$')) THEN
                 status:=status || '; ' || 'PHYLUM (' || :new.PHYLUM || ') must be Proper Case.';
            END IF;
        END IF;
        IF :new.KINGDOM IS NOT NULL THEN
           IF NOT (regexp_like(:new.KINGDOM,'^[A-Z][a-z]*$')) THEN
                status:=status || '; ' || 'KINGDOM (' || :new.KINGDOM || ') must be Proper Case.';
            END IF;
        END IF;
        IF :new.SUBCLASS IS NOT NULL THEN
           IF NOT (regexp_like(:new.SUBCLASS,'^[A-Z][a-z]*$')) THEN
                 status:=status || '; ' || 'SUBCLASS (' || :new.SUBCLASS || ') must be Proper Case.';
            END IF;
        END IF;
        IF :new.SUPERFAMILY IS NOT NULL THEN
           IF NOT (regexp_like(:new.SUPERFAMILY,'^[A-Z][a-z]*$')) THEN
                status:=status || '; ' || 'SUPERFAMILY (' || :new.SUPERFAMILY || ') must be Proper Case.';
            END IF;
        END IF;
        
        IF :new.PHYLORDER IS NOT NULL THEN
           if :NEW.phylclass is null and :NEW.valid_catalog_term_fg = 1 then
                  status:=status || '; Records with Order must have Class to be Accepted.';
           end if;
           iF NOT (regexp_like(:new.PHYLORDER,'^[A-Z][a-z]*$')) THEN
                         status:=status || '; ' || 'PHYLORDER (' || :new.PHYLORDER || ') must be Proper Case.';
            END IF;
        END IF;
        
        IF :new.phylclass IS NOT NULL THEN
                if :NEW.phylum is null and :NEW.valid_catalog_term_fg = 1 then
                                status:=status || '; ' || 'Records with Class must have Phylum to be Accepted.';
                        end if;   
                        IF NOT (regexp_like(:new.phylclass,'^[A-Z][a-z]*$')) THEN
                 status:=status || '; ' || 'phylclass (' || :new.phylclass || ') must be Proper Case.';
            END IF;
        END IF;
        
         IF :new.genus IS NOT NULL THEN
                if :NEW.family is null and :NEW.valid_catalog_term_fg = 1 then
                        status:=status || '; ' || 'Records with Genus must have Family or to be Accepted.';
                end if;
                
                if :NEW.nomenclatural_code='ICBN' then
                      if NOT ( regexp_like(:new.genus,'^[A-Z][a-z-]*[a-z]+$') or
                        (substr(:new.genus,1,1) = stoopidX and regexp_like(:new.genus,'^.[A-Z][a-z-]*[a-z]+$'))) then
                          status:=status || '; ' || 'genus (' || :new.genus || ') must be Proper Case, but may start with a multiplication sign and contain a dash.';
                    end if;                
                ELSIF :NEW.nomenclatural_code='ICZN' THEN
                    if NOT regexp_like(:new.genus,'^[A-Z][a-z]*$') then
                        status:=status || '; ' || 'genus (' || :new.genus || ') must be Proper Case.';
                    END IF;
                END IF;
        END IF;
    IF :new.species IS NOT NULL THEN
        if :NEW.nomenclatural_code='ICBN' then
            if NOT (
                regexp_like(:new.species,'^[a-z][a-z-]*[a-z]+$') or
                (substr(:new.species,1,1) = stoopidX and regexp_like(:new.species,'^.[a-z][a-z-]*[a-z]+$'))) then
               status:=status || '; ' || 'species (' || :new.species || ') must be lowercase letters, but may start with a multiplication sign and contain a dash.';
            end if;                
        ELSIF :NEW.nomenclatural_code='ICZN' THEN
            if NOT regexp_like(:new.species,'^[a-z]-{0,1}[a-z]*$') then
                status:=status || '; ' || 'species (' || :new.species || ')  must be lowercase letters, except the second character may be a hyphen.';
            END IF;
        END IF;
    END IF;
    IF :new.subspecies IS NOT NULL THEN
        if :NEW.nomenclatural_code='ICBN' then
            if NOT (
                regexp_like(:new.subspecies,'^[a-z][a-z-]*[a-z]+$') or
                (substr(:new.subspecies,1,1) = stoopidX and regexp_like(:new.subspecies,'^.[a-z][a-z-]*[a-z]+$'))) then
               status:=status || '; ' || 'subspecies (' || :new.subspecies || ') must be lowercase letters, but may start with a multiplication sign and contain a dash.';
            end if;                
        ELSIF :NEW.nomenclatural_code='ICZN' THEN
            if NOT regexp_like(:new.subspecies,'^[a-z]-{0,1}[a-z]*$') then
                status:=status || '; ' || 'subspecies (' || :new.subspecies || ')  must be lowercase letters, except the second character may be a hyphen.';
            END IF;
        END IF;
    END IF;

end if;

    nScientificName:=prependTaxonomy(nScientificName, :NEW.subspecies);

    if :NEW.nomenclatural_code='ICBN' then
        nScientificName:=prependTaxonomy(nScientificName, :NEW.infraspecific_rank);
    end if;
    nScientificName:=prependTaxonomy(nScientificName, :NEW.species);
    
    if :new.subgenus is not null then
        nScientificName:=prependTaxonomy(nScientificName, '(' || :NEW.subgenus || ')');
    end if;
    
    nScientificName:=prependTaxonomy(nScientificName, :NEW.genus);
    
    nScientificName:=prependTaxonomy(nScientificName, :NEW.tribe,0,1);
    
    nScientificName:=prependTaxonomy(nScientificName, :NEW.subfamily,0,1);
    
    nScientificName:=prependTaxonomy(nScientificName, :NEW.family,0,1);
    
    nScientificName:=prependTaxonomy(nScientificName, :NEW.superfamily,0,1);
    
    nScientificName:=prependTaxonomy(nScientificName, :NEW.suborder,0,1);
    
    nScientificName:=prependTaxonomy(nScientificName, :NEW.phylorder,0,1);
    
    nScientificName:=prependTaxonomy(nScientificName, :NEW.subclass,0,1);
    
    nScientificName:=prependTaxonomy(nScientificName, :NEW.phylclass,0,1);
    
    nScientificName:=prependTaxonomy(nScientificName, :NEW.phylum,0,1);
    
    nScientificName:=prependTaxonomy(nScientificName, :NEW.kingdom,0,1);
    
    :new.scientific_name:=trim(nScientificName);
       
        if :NEW.nomenclatural_code in ('unknown','noncompliant') AND :NEW.valid_catalog_term_fg = 1 then
                status:=status || '; Nomenclatural Code -unknown- or -noncompliant- records may not be Accepted.';
        end if;
       :NEW.status:=status;
END;
/
sho err


        
------>

<!------------------------------------------------------->
<cfif action is "down">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
	<cfset header="PHYLCLASS,SUBCLASS,PHYLORDER,SUBORDER,SUPERFAMILY,FAMILY,SUBFAMILY,GENUS,SUBGENUS,SPECIES,SUBSPECIES,VALID_CATALOG_TERM_FG,SOURCE_AUTHORITY,AUTHOR_TEXT,TRIBE,INFRASPECIFIC_RANK,TAXON_REMARKS,PHYLUM,KINGDOM,NOMENCLATURAL_CODE,INFRASPECIFIC_AUTHOR,TAXON_STATUS">
	<cffile action = "write" file = "#Application.webDirectory#/download/BulkTaxonomy.csv"
    	output = "#header#" addNewLine = "no">
	<cflocation url="/download.cfm?file=BulkTaxonomy.csv" addtoken="false">
</cfif>
<!------------------------------------------------------->
<cfif action is "nothing">
	<cfoutput>
		Upload a comma-delimited text file (csv). <a href="BulkloadTaxonomy.cfm?action=makeTemplate">[ Get the Template ]</a>
		<p>Required fields:
			<ul>
				<li>VALID_CATALOG_TERM_FG (0 or 1)</li>
				<li><a href="/info/ctDocumentation.cfm?table=CTTAXONOMIC_AUTHORITY">SOURCE_AUTHORITY</a></li>
				<li><a href="/info/ctDocumentation.cfm?table=CTNOMENCLATURAL_CODE">NOMENCLATURAL_CODE</a></li>
			</ul>
		</p> 
		<cfform name="oids" method="post" enctype="multipart/form-data">
			<input type="hidden" name="Action" value="getFile">
			<input type="file" name="FiletoUpload" size="45">
			<input type="submit" value="Upload this file">
  </cfform>
</cfoutput>
</cfif>

<!------------------------------------------------------->
<cfif action is "getFile">
<cfoutput>
	<!--- put this in a temp table --->
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
	<cfquery name="bad2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update cf_temp_taxonomy set status = status || '; Invalid taxon_status'
		where taxon_status is not null and taxon_status NOT IN (
			select taxon_status from CTtaxon_status
			)
	</cfquery>
	<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update cf_temp_taxonomy set status = status || '; Invalid source_authority'
		where source_authority NOT IN (
			select SOURCE_AUTHORITY from CTTAXONOMIC_AUTHORITY
			)
	</cfquery>
	<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update cf_temp_taxonomy set status = status || '; Invalid VALID_CATALOG_TERM_FG'
		where VALID_CATALOG_TERM_FG is null or  VALID_CATALOG_TERM_FG NOT IN (0,1)
	</cfquery>
	<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update cf_temp_taxonomy set status = status || '; invalid nomenclatural_code'
		where nomenclatural_code NOT IN (
			select nomenclatural_code from CTnomenclatural_code
			)
	</cfquery>
	
	<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update cf_temp_taxonomy set status = status || '; already exists'
		where scientific_name IN (select scientific_name from taxonomy)
	</cfquery>
	<!---
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from cf_temp_taxonomy where status is null
	</cfquery>
	<cfloop query="data">
		<cfset problem="">
			
		<cfif len(#problem#) gt 0>
			<cfquery name="insColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				UPDATE cf_temp_taxonomy SET status = '#problem#' where
				key = #key#
			</cfquery>
		</cfif>
	</cfloop>
	--->
	
		<cfquery name="valData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
				<th>PHYLCLASS</th>
				<th>PHYLORDER</th>
				<th>SUBORDER</th>
				<th>FAMILY</th>
				<th>SUBFAMILY</th>
				<th>GENUS</th>
				<th>SUBGENUS</th>
				<th>SPECIES</th>
				<th>SUBSPECIES</th>
				<th>VALID_CATALOG_TERM_FG</th>
				<th>SOURCE_AUTHORITY</th>
				<th>SCIENTIFIC_NAME</th>
				<th>AUTHOR_TEXT</th>
				<th>TRIBE</th>
				<th>INFRASPECIFIC_RANK</th>
				<th>PHYLUM</th>
				<th>KINGDOM</th>
				<th>NOMENCLATURAL_CODE</th>
				<th>INFRASPECIFIC_AUTHOR</th>
				<th>TAXON_REMARKS</th>
				<th>taxon_status</th>
				<th>SUBCLASS</th>
				<th>SUPERFAMILY</th>
			</tr>
			<cfloop query="valData">
				<tr>
					<td>#KEY#</td>
					<td>#STATUS#</td>
					<td>#PHYLCLASS#</td>
					<td>#PHYLORDER#</td>
					<td>#SUBORDER#</td>
					<td>#FAMILY#</td>
					<td>#SUBFAMILY#</td>
					<td>#GENUS#</td>
					<td>#SUBGENUS#</td>
					<td>#SPECIES#</td>
					<td>#SUBSPECIES#</td>
					<td>#VALID_CATALOG_TERM_FG#</td>
					<td>#SOURCE_AUTHORITY#</td>
					<td>#SCIENTIFIC_NAME#</td>
					<td>#AUTHOR_TEXT#</td>
					<td>#TRIBE#</td>
					<td>#INFRASPECIFIC_RANK#</td>
					<td>#PHYLUM#</td>
					<td>#KINGDOM#</td>
					<td>#NOMENCLATURAL_CODE#</td>
					<td>#INFRASPECIFIC_AUTHOR#</td>
					<td>#TAXON_REMARKS#</td>
					<td>#taxon_status#</td>
					<td>#SUBCLASS#</td>
					<td>#SUPERFAMILY#</td>
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
	<cfquery name="data" datasource="user_login" username='#session.username#' password="#decrypt(session.epw,cfid)#">
		select * from cf_temp_taxonomy
	</cfquery>
	<cftransaction>
	<cfloop query="data">
		<cfquery name="newTaxa" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			INSERT INTO taxonomy (
				taxon_name_id,
				PHYLCLASS,
				SUBCLASS,
				PHYLORDER,
				SUBORDER,
				SUPERFAMILY,
				FAMILY,
				SUBFAMILY,
				GENUS,
				SUBGENUS,
				SPECIES,
				SUBSPECIES,
				VALID_CATALOG_TERM_FG,
				SOURCE_AUTHORITY,
				AUTHOR_TEXT,
				TRIBE,
				INFRASPECIFIC_RANK,
				TAXON_REMARKS,
				PHYLUM,
				KINGDOM,
				NOMENCLATURAL_CODE,
				INFRASPECIFIC_AUTHOR,
				TAXON_STATUS
			) values (
				sq_taxon_name_id.nextval,
				'#PHYLCLASS#',
				'#SUBCLASS#',
				'#PHYLORDER#',
				'#SUBORDER#',
				'#SUPERFAMILY#',
				'#FAMILY#',
				'#SUBFAMILY#',
				'#GENUS#',
				'#SUBGENUS#',
				'#SPECIES#',
				'#SUBSPECIES#',
				#VALID_CATALOG_TERM_FG#,
				'#SOURCE_AUTHORITY#',
				'#escapeQuotes(AUTHOR_TEXT)#',
				'#TRIBE#',
				'#INFRASPECIFIC_RANK#',
				'#escapeQuotes(TAXON_REMARKS)#',
				'#PHYLUM#',
				'#KINGDOM#',
				'#NOMENCLATURAL_CODE#',
				'#escapeQuotes(INFRASPECIFIC_AUTHOR)#',
				'#TAXON_STATUS#'
			)
		</cfquery>
		</cfloop>
	</cftransaction>
		

	Spiffy, all done.
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">
