<!----
drop table ds_temp_geog;

create table ds_temp_geog (
	key number not null,
	CONTINENT_OCEAN  varchar2(255),
	COUNTRY  varchar2(255),
	STATE_PROV  varchar2(255),
	COUNTY  varchar2(255),
	QUAD  varchar2(255),
	FEATURE  varchar2(255),
	ISLAND  varchar2(255),
	ISLAND_GROUP  varchar2(255),
	SEA  varchar2(255),
	HIGHER_GEOG  varchar2(255)
);

alter table ds_temp_geog rename column key to pkey;
alter table ds_temp_geog drop column HIGHER_GEOG;
alter table ds_temp_geog add calculated_higher_geog varchar2(255);
alter table ds_temp_geog add found_higher_geog varchar2(255);

create or replace public synonym ds_temp_geog for ds_temp_geog;
grant all on ds_temp_geog to coldfusion_user;
grant select on ds_temp_geog to public;

 CREATE OR REPLACE TRIGGER ds_temp_geog_key                                         
 before insert  ON ds_temp_geog
 for each row 
    begin     
    	if :NEW.pkey is null then                                                                                      
    		select somerandomsequence.nextval into :new.pkey from dual;
    	end if;                                
    end;                                                                                            
/
sho err


insert into ds_temp_geog (
CONTINENT_OCEAN,
COUNTRY,
STATE_PROV,
COUNTY,
QUAD,
FEATURE,
ISLAND,
ISLAND_GROUP,
SEA)
(select 
CONTINENT_OCEAN,
COUNTRY,
STATE_PROV,
COUNTY,
QUAD,
FEATURE,
ISLAND,
ISLAND_GROUP,
SEA
from geog_auth_rec where rownum<10
);

update ds_temp_geog set HIGHER_GEOG=select (
CONTINENT_OCEAN,
COUNTRY,
STATE_PROV,
COUNTY,
QUAD,
FEATURE,
ISLAND,
ISLAND_GROUP,
SEA)
(select 
CONTINENT_OCEAN,
COUNTRY,
STATE_PROV,
COUNTY,
QUAD,
FEATURE,
ISLAND,
ISLAND_GROUP,
SEA
from geog_auth_rec where rownum<10
);


---->
<cfinclude template="/includes/_header.cfm">

<cfif action is "nothing">
	
	Columns in <span style="color:red">red</span> are required; others are optional:
	<ul>
		<li>CONTINENT_OCEAN</li>
		<li>COUNTRY</li>
		<li>STATE_PROV</li>
		<li>COUNTY</li>
		<li>QUAD</li>
		<li>FEATURE</li>
		<li>ISLAND</li>
		<li>ISLAND_GROUP</li>
		<li>SEA</li>
	</ul>
	
	
	<cfform name="atts" method="post" enctype="multipart/form-data">
		<input type="hidden" name="Action" value="getFile">
		<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" class="savBtn">
	</cfform>

</cfif>

<cfif action is "getFile">
<cfoutput>
	<!--- put this in a temp table --->
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		delete from ds_temp_geog
	</cfquery>
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	<cfset fileContent=replace(fileContent,"'","''","all")>
	<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />
	<cfset numberOfColumns = ArrayLen(arrResult[1])>
	<cfset colNames="">
	<cfloop from="1" to ="#ArrayLen(arrResult)#" index="o">
		<cfset colVals="">
			<cfloop from="1"  to ="#ArrayLen(arrResult[o])#" index="i">
				 <cfset numColsRec = ArrayLen(arrResult[o])>
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
		<cfif len(colVals) gt 1>
			<cfset colVals=replace(colVals,",","","first")>
			<cfif numColsRec lt numberOfColumns>
				<cfset missingNumber = numberOfColumns - numColsRec>
				<cfloop from="1" to="#missingNumber#" index="c">
					<cfset colVals = "#colVals#,''">
				</cfloop>
			</cfif>
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into ds_temp_geog (#colNames#) values (#preservesinglequotes(colVals)#)				
			</cfquery>
		</cfif>
	</cfloop>
</cfoutput>
<cflocation url="geog_lookup.cfm?action=validate" addtoken="false">

<!---
---->
</cfif>
<cfif action is "validate">
<cfoutput>

		
	<cfquery name="CDasdf" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from ds_temp_geog
	</cfquery>
	<cfloop query="CDasdf">
		
		
		<br>CONTINENT_OCEAN==#CONTINENT_OCEAN#
		<br>COUNTRY==#COUNTRY#
		<br>STATE_PROV==#STATE_PROV#
		<br>COUNTY==#COUNTY#
		<br>QUAD==#QUAD#
		<br>FEATURE==#FEATURE#
		<br>ISLAND==#ISLAND#
		<br>ISLAND_GROUP==#ISLAND_GROUP#
		<br>SEA==#SEA#
		
		
		
		
		
		
		<cfset thisgeog=''>
		<cfif len(continent_ocean) gt 0>
			<cfset thisgeog=listappend(thisGeog,continent_ocean,"|")>
		</cfif>
		<cfif len(sea) gt 0>
			<cfset thisgeog=listappend(thisGeog,sea,"|")>
		</cfif>
		<cfif len(country) gt 0>
			<cfset thiscountry=replace(country,'USA',"United States")>
			<cfset thisgeog=listappend(thisGeog,thiscountry,"|")>
		</cfif>
		<cfif len(state_prov) gt 0>
			<cfset thisgeog=listappend(thisGeog,state_prov,"|")>
		</cfif>
		<cfif len(county) gt 0>
			<Cfset thiscounty=county>
			<Cfset thiscounty=replace(thiscounty,' CO.','%','all')>
			<Cfset thiscounty=replace(thiscounty,' CO','%','all')>
			<cfset thisgeog=listappend(thisGeog,thiscounty,"|")>
		</cfif>
		<cfif len(quad) gt 0>
			<cfset thisgeog=listappend(thisGeog,quad & " Quad","|")>
		</cfif>
		<cfif len(feature) gt 0>
			<cfset thisgeog=listappend(thisGeog,feature,"|")>
		</cfif>
		<cfif len(island_group) gt 0>
			<cfset thisgeog=listappend(thisGeog,island_group,"|")>
		</cfif>
		<cfif len(island) gt 0>
			<cfset thisgeog=listappend(thisGeog,island,"|")>
		</cfif>
		
		<!----
		<cfset thisgeog=replace(thisgeog,",",", ","all")>
		<cfset thisgeog=replace(thisgeog,",",  ", ","all")>
		
		
		
		---->
		
		<cfset isNotNullBS='none'>
		<br>beforedelete---#thisgeog#
		<cfloop list="#isNotNullBS#" index="x">
			<cfloop from="1" to="#ListValueCountNoCase(thisgeog,x,"|")#" index="l">
				<br>beforedelete==#l#==---#thisgeog#
				<cfset thisgeog=listdeleteat(thisgeog,listfindnocase(thisgeog,x,"|"),"|")>
				<br>afterdelete==#l#==---#thisgeog#
			</cfloop>
			    
			  <!----
		<br>ListValueCountNoCase===#ListValueCountNoCase(thisgeog,x,"|")# 
			    
			<cfif listfindnocase(thisgeog,x,"|")>
				
			</cfif>
			---->
		</cfloop>
		

		<cfset thisgeog=replace(thisgeog,"|",  ", ","all")>
		
		<cfset thisgeog=trim(thisgeog)>
		
		
		<cfset thisgeog=REReplace(thisgeog,"[^A-Za-z, ]","X","all")>


		<br>#thisgeog#
		
		
		<cfquery name="mmmffssds" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select HIGHER_GEOG from geog_auth_rec where upper(HIGHER_GEOG) = upper('#thisgeog#')
		</cfquery>
		<cfif mmmffssds.recordcount is 1>
			<br>---------happy@------------
		<cfelse>
			<br>NOTFOUND:::#thisgeog#
		</cfif>
		
		
		<cfquery name="upr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			update
				ds_temp_geog
			set
				calculated_higher_geog='#thisgeog#',
				found_higher_geog='#mmmffssds.higher_geog#'
			where
				pkey=#pkey#
		</cfquery>
		<hr>
		
		<!-----------
		
		
		
		
<cfset sql="select HIGHER_GEOG from geog_auth_rec where trim(upper(HIGHER_GEOG))=trim(upper('NORTH AMERICA, United States, ALASKA'))">
		<br>#sql#
	:NEW.higher_geog := trim(hg);
END;

CREATE OR REPLACE TRIGGER TR_GEOGAUTHREC_AU_FLAT
AFTER UPDATE ON GEOG_AUTH_REC
FOR EACH ROW
BEGIN
    UPDATE flat SET
        stale_flag = 1,
        lastuser = sys_context('USERENV', 'SESSION_USER'),
        lastdate = SYSDATE
    WHERE geog_auth_rec_id = :NEW.geog_auth_rec_id;
END;



		<cfset thisCountry=country>
		<cfif len(country) gt 0>
			<cfif country is "USA">
				<cfset thisCountry="United States">
			</cfif>
		</cfif>
		
		<cfset thisCounty=county>
		<Cfset thisCounty=replace(thisCounty,'CO','','all')>
		
		<cfquery name="g1" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				HIGHER_GEOG from geog_auth_rec where
				upper(CONTINENT_OCEAN) = '#ucase(trim(CONTINENT_OCEAN))#' and
				upper(COUNTRY) = '#ucase(trim(thisCountry))#' and
				upper(STATE_PROV) = '#ucase(trim(STATE_PROV))#' and
				trim(upper(replace(COUNTY,'County'))) = '#ucase(trim(thisCounty))#' and
				upper(QUAD) = '#ucase(trim(QUAD))#' and
				upper(FEATURE) = '#ucase(trim(FEATURE))#' and
				upper(ISLAND) = '#ucase(trim(ISLAND))#' and
				upper(ISLAND_GROUP) = '#ucase(trim(ISLAND_GROUP))#' and
				upper(SEA) = '#ucase(trim(SEA))#'
		</cfquery>
		<cfdump var=#g1#>
		
		---->
	</cfloop>
	
		<cfquery name="getData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from ds_temp_geog
				order by
				found_higher_geog,
				calculated_higher_geog
		</cfquery>
		<cfset ac = getData.columnList>
		<!--- strip internal columns --->
		<cfif ListFindNoCase(ac,'PKEY')>
			<cfset ac = ListDeleteAt(ac, ListFindNoCase(ac,'PKEY'))>
		</cfif>
		<cfset fileDir = "#Application.webDirectory#">
		<cfset variables.encoding="UTF-8">
		<cfset fname = "geog_lookup.csv">
		<cfset variables.fileName="#Application.webDirectory#/download/#fname#">
		<cfset header=trim(ac)>
		<cfscript>
			variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
			variables.joFileWriter.writeLine(header); 
		</cfscript>
		<cfloop query="getData">
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
		<!---
		<cflocation url="/download.cfm?file=#fname#" addtoken="false">
		---->
		<a href="/download/#fname#">Click here if your file does not automatically download.</a>
		
</cfoutput>
</cfif>