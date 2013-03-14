<style>
	.possiblesTable {
		max-height:20em;
		overflow:auto;
	}
	.rawdata {
		font-size:small;
	}
	.interpreteddata {
		font-size:small;
		padding-left:1em;
	}
	.r_status {
		font-size:small;
		padding-left:1em;
		font-style:bold;
	}

</style>
<script>
	function useThisOne(pkey,geog) {
		$.getJSON("/component/DSFunctions.cfc",
			{
				method : "upDSGeog",
				pkey : pkey,
				geog : geog,
				returnformat : "json",
				queryformat : 'column'
			},
			function(r) {
				$('#chooseTab_' + r).hide();
			}
		);
	}
</script>
<!---
drop table ds_temp_geog;

create table ds_temp_geog (
	pkey number not null,
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
alter table ds_temp_geog add status varchar2(255);
alter table ds_temp_geog rename column found_higher_geog to higher_geog;

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
	Load random-ish geography; we'll try to find an appropriate Arctos higher_geog entry.
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
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
	things that resolve to one match have been updated.
	<br>Things with multiple possibilities may be selected.
	<br>Accuracy varies by method
	<br>full_component_match > componentMatch_noCont > componentMatch_noSea > componentMatch_noCountry > componentMatch_JustIsland
	<br>Manually select suggestions; the more you do here, the fewer problems later.
	<br><a href="geog_lookup.cfm?action=csv">download CSV</a>
	<br><a href="/contact.cfm">contact us</a> if we could make something unstoopider
	<hr>



	<cfquery name="qdata" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from ds_temp_geog
	</cfquery>
	<cfset isNotNullBS='none'>

	<cfset result = QueryNew("method,higher_geog")>



	<cfloop query="qdata">
		<cfquery name="result" dbtype="query">
			select * from result where 1=2
		</cfquery>
		<cfset n=1>
		<!----
		<table border>
			<tr>
				<th>CONTINENT_OCEAN</th>
				<th>COUNTRY</th>
				<th>STATE_PROV</th>
				<th>COUNTY</th>
				<th>QUAD</th>
				<th>FEATURE</th>
				<th>ISLAND</th>
				<th>ISLAND_GROUP</th>
				<th>SEA</th>
			</tr>
			<tr>
				<td>#CONTINENT_OCEAN#</td>
				<td>#COUNTRY#</td>
				<td>#STATE_PROV#</td>
				<td>#COUNTY#</td>
				<td>#QUAD#</td>
				<td>#FEATURE#</td>
				<td>#ISLAND#</td>
				<td>#ISLAND_GROUP#</td>
				<td>#SEA#</td>
			</tr>
		</table>
		---->
		<cfset thisStatus="">
		<cfset fhg=''>

		<cfset thiscontinent=continent_ocean>
		<cfloop list="#isNotNullBS#" index="i">
			<cfif thiscontinent is i>
				<cfset thisContinent=''>
			</cfif>
		</cfloop>

		<cfset thisSea=sea>
		<cfloop list="#isNotNullBS#" index="i">
			<cfif thisSea is i>
				<cfset thisSea=''>
			</cfif>
		</cfloop>

		<cfset thisCountry=country>
		<cfloop list="#isNotNullBS#" index="i">
			<cfif thisCountry is i>
				<cfset thisCountry=''>
			</cfif>
		</cfloop>
		<cfif len(thisCountry) gt 0>
			<cfset thisCountry=replace(thisCountry,'USA',"United States")>
		</cfif>

		<cfset thisState=state_prov>
		<cfloop list="#isNotNullBS#" index="i">
			<cfif thisState is i>
				<cfset thisState=''>
			</cfif>
		</cfloop>

		<cfif len(thisState) gt 0>
			<cfset thisState=replace(thisState,'Prov.',"")>
			<cfset thisState=replace(thisState,'Community',"")>
			<cfset thisState=replace(thisState,'Island',"")>
			<cfset thisState=replace(thisState,'kray',"")>
			<cfset thisState=replace(thisState,'Ward',"")>
			<cfset thisState=replace(thisState,'Territory',"")>
			<cfset thisState=replace(thisState,'autonomous oblast',"")>
			<cfset thisState=replace(thisState,'Republic of',"")>
			<cfset thisState=replace(thisState,'Oblast',"")>
			<cfset thisState=replace(thisState,'Parish',"")>
			<cfset thisState=replace(thisState,'Municipality',"")>
			<cfset thisState=replace(thisState,'Pref.',"")>
			<cfset thisState=replace(thisState,'City',"")>
			<cfset thisState=replace(thisState,'Depto.',"")>

			<cfset thisState=rereplace(thisState,'\(.*\)','')>


			<cfset thisState=trim(thisState)>
		</cfif>

		<cfset thisQuad=quad>
		<cfloop list="#isNotNullBS#" index="i">
			<cfif thisQuad is i>
				<cfset thisQuad=''>
			</cfif>
		</cfloop>


		<cfset thisFeature=feature>
		<cfloop list="#isNotNullBS#" index="i">
			<cfif thisFeature is i>
				<cfset thisFeature=''>
			</cfif>
		</cfloop>


		<cfset thisIslandGroup=island_group>
		<cfloop list="#isNotNullBS#" index="i">
			<cfif thisIslandGroup is i>
				<cfset thisIslandGroup=''>
			</cfif>
		</cfloop>

		<cfif len(thisIslandGroup) gt 0>
			<cfset thisIslandGroup=replace(thisIslandGroup,' IS.','','all')>
			<cfset thisIslandGroup=replace(thisIslandGroup,' ISL.','','all')>
			<cfset thisIslandGroup=replace(thisIslandGroup,' IS','','all')>
			<cfset thisIslandGroup=replace(thisIslandGroup,' ISL','','all')>
		</cfif>

		<cfset thisIsland=island>
		<cfloop list="#isNotNullBS#" index="i">
			<cfif thisIsland is i>
				<cfset thisIsland=''>
			</cfif>
		</cfloop>
		<cfif len(thisIsland) gt 0>
			<cfset thisIsland=replace(thisIsland,' IS.','','all')>
			<cfset thisIsland=replace(thisIsland,' ISL.','','all')>
			<cfset thisIsland=replace(thisIsland,' IS','','all')>
			<cfset thisIsland=replace(thisIsland,' ISL','','all')>
		</cfif>


		<cfset thisCounty=county>
		<cfloop list="#isNotNullBS#" index="i">
			<cfif thisCounty is i>
				<cfset thisCounty=''>
			</cfif>
		</cfloop>
		<cfif len(thisCounty) gt 0>
			<cfset thisCounty=replace(thiscounty,' CO.','','all')>
			<cfset thisCounty=replace(thiscounty,' CO','','all')>
			<cfset thisCounty=replace(thiscounty,' County','','all')>
			<cfset thisCounty=replace(thiscounty,' Province','','all')>
			<cfset thisCounty=replace(thiscounty,' Parish','','all')>
			<cfset thisCounty=replace(thiscounty,' District','','all')>
			<cfset thisCounty=replace(thiscounty,' Territory','','all')>
			<cfset thisCounty=replace(thiscounty,' Prov.','','all')>
			<cfset thisCounty=replace(thiscounty,' Dist.','','all')>
			<cfset thisCounty=replace(thiscounty,' PROV','','all')>
			<cfset thisCounty=replace(thiscounty,' DIST','','all')>
			<cfset thisCounty=replace(thiscounty,' TERR','','all')>
		</cfif>
		<div class="rawdata">
			RawData==#CONTINENT_OCEAN#:#SEA#:#COUNTRY#:#STATE_PROV#:#COUNTY#:#QUAD#:#FEATURE#:#ISLAND#:#ISLAND_GROUP#
		</div>
		<div class="interpreteddata">
			InterpretedData==#thiscontinent#:#thisSea#:#thisCountry#:#thisState#:#thisCounty#:#thisQuad#:#thisFeature#:#thisIsland#:#thisIslandGroup#:
		</div>


		<cfset thisMethod="full_component_match">
		<cfquery name="componentMatch" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select HIGHER_GEOG from geog_auth_rec where
			<cfif len(thiscontinent) gt 0>
				upper(continent_ocean) = '#ucase(thiscontinent)#' and
			<cfelse>
				continent_ocean is null and
			</cfif>
			<cfif len(thisSea) gt 0>
				upper(sea) = '#ucase(thisSea)#' and
			<cfelse>
				sea is null and
			</cfif>
			<cfif len(thisCountry) gt 0>
				upper(country) = '#ucase(thisCountry)#' and
			<cfelse>
				country is null and
			</cfif>
			<cfif len(thisState) gt 0>
				upper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(state_prov,'Prov.'),'Community'),'Island'),'kray'),'Ward'),'Territory'),'autonomous oblast'),'okrug'),'Republic of'),'Oblast'),'Parish'),'Municipality'),'Pref.'),'City'),'Depto.')))
				= '#ucase(thisState)#' and
			<cfelse>
				state_prov is null and
			</cfif>
			<cfif len(thisQuad) gt 0>
				upper(quad) = '#ucase(thisQuad)#' and
			<cfelse>
				quad is null and
			</cfif>
			<cfif len(thisFeature) gt 0>
				upper(feature) = '#ucase(thisFeature)#' and
			<cfelse>
				feature is null and
			</cfif>
			<cfif len(thisIslandGroup) gt 0>
				upper(trim(replace(island_group,'Island'))) = '#ucase(thisIslandGroup)#' and
			<cfelse>
				 island_group is null and
			</cfif>
			<cfif len(thisIsland) gt 0>
				upper(trim(replace(island,'Island'))) = '#ucase(thisIsland)#' and
			<cfelse>
				island is null and
			</cfif>
			<cfif len(thisCounty) gt 0>
				upper(trim(replace(replace(replace(replace(replace(county,'County'), 'Province'),'Parish'),'District'), 'Territory'))) = '#ucase(thisCounty)#'
			<cfelse>
				county is null
			</cfif>
		</cfquery>
		<cfloop query="componentMatch">
			<cfset QueryAddRow(result, 1)>
			<cfset QuerySetCell(result, "method", thisMethod,n)>
			<cfset QuerySetCell(result, "higher_geog", higher_geog,n)>
			<cfset n=n+1>
		</cfloop>
		<cfif n eq 1>
			<cfset thisMethod="componentMatch_noCont">
			<cfquery name="componentMatch" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select HIGHER_GEOG from geog_auth_rec where
				<cfif len(thisSea) gt 0>
					upper(sea) = '#ucase(thisSea)#' and
				<cfelse>
					sea is null and
				</cfif>
				<cfif len(thisCountry) gt 0>
					upper(country) = '#ucase(thisCountry)#' and
				<cfelse>
					country is null and
				</cfif>
				<cfif len(thisState) gt 0>
					upper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(state_prov,'Prov.'),'Community'),'Island'),'kray'),'Ward'),'Territory'),'autonomous oblast'),'okrug'),'Republic of'),'Oblast'),'Parish'),'Municipality'),'Pref.'),'City'),'Depto.')))
					= '#ucase(thisState)#' and
				<cfelse>
					state_prov is null and
				</cfif>
				<cfif len(thisQuad) gt 0>
					upper(quad) = '#ucase(thisQuad)#' and
				<cfelse>
					quad is null and
				</cfif>
				<cfif len(thisFeature) gt 0>
					upper(feature) = '#ucase(thisFeature)#' and
				<cfelse>
					feature is null and
				</cfif>
				<cfif len(thisIslandGroup) gt 0>
					upper(trim(replace(island_group,'Island'))) = '#ucase(thisIslandGroup)#' and
				<cfelse>
					 island_group is null and
				</cfif>
				<cfif len(thisIsland) gt 0>
					upper(trim(replace(island,'Island'))) = '#ucase(thisIsland)#' and
				<cfelse>
					island is null and
				</cfif>
				<cfif len(thisCounty) gt 0>
					upper(trim(replace(replace(replace(replace(replace(county,'County'), 'Province'),'Parish'),'District'), 'Territory'))) = '#ucase(thisCounty)#'
				<cfelse>
					county is null
				</cfif>
			</cfquery>
			<cfloop query="componentMatch">
				<cfset QueryAddRow(result, 1)>
				<cfset QuerySetCell(result, "method", thisMethod,n)>
				<cfset QuerySetCell(result, "higher_geog", higher_geog,n)>
				<cfset n=n+1>
			</cfloop>
		</cfif>
		<cfif n eq 1>
			<cfset thisMethod="componentMatch_noSea">
			<cfquery name="componentMatch" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select HIGHER_GEOG from geog_auth_rec where
				<cfif len(thisCountry) gt 0>
					upper(country) = '#ucase(thisCountry)#' and
				<cfelse>
					country is null and
				</cfif>
				<cfif len(thisState) gt 0>
					upper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(state_prov,'Prov.'),'Community'),'Island'),'kray'),'Ward'),'Territory'),'autonomous oblast'),'okrug'),'Republic of'),'Oblast'),'Parish'),'Municipality'),'Pref.'),'City'),'Depto.')))
					= '#ucase(thisState)#' and
				<cfelse>
					state_prov is null and
				</cfif>
				<cfif len(thisQuad) gt 0>
					upper(quad) = '#ucase(thisQuad)#' and
				<cfelse>
					quad is null and
				</cfif>
				<cfif len(thisFeature) gt 0>
					upper(feature) = '#ucase(thisFeature)#' and
				<cfelse>
					feature is null and
				</cfif>
				<cfif len(thisIslandGroup) gt 0>
					upper(trim(replace(island_group,'Island'))) = '#ucase(thisIslandGroup)#' and
				<cfelse>
					 island_group is null and
				</cfif>
				<cfif len(thisIsland) gt 0>
					upper(trim(replace(island,'Island'))) = '#ucase(thisIsland)#' and
				<cfelse>
					island is null and
				</cfif>
				<cfif len(thisCounty) gt 0>
					upper(trim(replace(replace(replace(replace(replace(county,'County'), 'Province'),'Parish'),'District'), 'Territory'))) = '#ucase(thisCounty)#'
				<cfelse>
					county is null
				</cfif>
			</cfquery>
			<cfloop query="componentMatch">
				<cfset QueryAddRow(result, 1)>
				<cfset QuerySetCell(result, "method", thisMethod,n)>
				<cfset QuerySetCell(result, "higher_geog", higher_geog,n)>
				<cfset n=n+1>
			</cfloop>
		</cfif>

		<cfif n eq 1>
			<cfset thisMethod="componentMatch_noCountry">
			<cfquery name="componentMatch" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select HIGHER_GEOG from geog_auth_rec where
				<cfif len(thisState) gt 0>
					upper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(state_prov,'Prov.'),'Community'),'Island'),'kray'),'Ward'),'Territory'),'autonomous oblast'),'okrug'),'Republic of'),'Oblast'),'Parish'),'Municipality'),'Pref.'),'City'),'Depto.')))
					= '#ucase(thisState)#' and
				<cfelse>
					state_prov is null and
				</cfif>
				<cfif len(thisQuad) gt 0>
					upper(quad) = '#ucase(thisQuad)#' and
				<cfelse>
					quad is null and
				</cfif>
				<cfif len(thisFeature) gt 0>
					upper(feature) = '#ucase(thisFeature)#' and
				<cfelse>
					feature is null and
				</cfif>
				<cfif len(thisIslandGroup) gt 0>
					upper(trim(replace(island_group,'Island'))) = '#ucase(thisIslandGroup)#' and
				<cfelse>
					 island_group is null and
				</cfif>
				<cfif len(thisIsland) gt 0>
					upper(trim(replace(island,'Island'))) = '#ucase(thisIsland)#' and
				<cfelse>
					island is null and
				</cfif>
				<cfif len(thisCounty) gt 0>
					upper(trim(replace(replace(replace(replace(replace(county,'County'), 'Province'),'Parish'),'District'), 'Territory'))) = '#ucase(thisCounty)#'
				<cfelse>
					county is null
				</cfif>
			</cfquery>
			<cfloop query="componentMatch">
				<cfset QueryAddRow(result, 1)>
				<cfset QuerySetCell(result, "method", thisMethod,n)>
				<cfset QuerySetCell(result, "higher_geog", higher_geog,n)>
				<cfset n=n+1>
			</cfloop>
		</cfif>

		<cfif n eq 1 and len(thisIsland) gt 0>
			<cfset thisMethod="componentMatch_JustIsland">
			<cfquery name="componentMatch" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select HIGHER_GEOG from geog_auth_rec where
				<cfif len(thisIsland) gt 0>
					upper(trim(replace(island,'Island'))) = '#ucase(thisIsland)#'
				</cfif>
			</cfquery>
			<cfloop query="componentMatch">
				<cfset QueryAddRow(result, 1)>
				<cfset QuerySetCell(result, "method", thisMethod,n)>
				<cfset QuerySetCell(result, "higher_geog", higher_geog,n)>
				<cfset n=n+1>
			</cfloop>
		</cfif>
		<cfif result.recordcount is 1>
			<cfquery name="upr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update
					ds_temp_geog
				set
					FOUND_HIGHER_GEOG='#result.higher_geog#',
					status='#result.method#'
				where
					pkey=#qdata.pkey#
			</cfquery>
			<div class="r_status">
				found one - autoupdate
			</div>
		<cfelseif result.recordcount gt 1>
			<cfquery name="result" dbtype="query">
				select * from result order by higher_geog
			</cfquery>
			<div class="possiblesTable">
				<table border id="chooseTab_#qdata.pkey#">
					<tr>
						<th>Method</th>
						<th>Geog</th>
						<th>x</th>
					</tr>
					<cfloop query="result">
						<tr>
							<td>#method#</td>
							<td>#higher_geog#</td>
							<td><span class="likeLink" onclick="useThisOne('#qdata.pkey#','#higher_geog#');">[ use this ]</span></td>
						</tr>
					</cfloop>

				</table>
			</div>
		<cfelse>
			<div class="r_status">
				found nothing
			</div>
		</cfif>
	</cfloop>
</cfoutput>
</cfif>
<cfif action is "csv">
	<cfquery name="getData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from ds_temp_geog
			order by
			FOUND_HIGHER_GEOG,
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
	<cfoutput>
		<cflocation url="/download.cfm?file=#fname#" addtoken="false">
		<a href="/download/#fname#">Click here if your file does not automatically download.</a>
	</cfoutput>
</cfif>