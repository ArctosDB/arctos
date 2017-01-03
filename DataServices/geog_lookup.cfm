<cfinclude template="/includes/_header.cfm">
<script src="/includes/jquery/jquery-autocomplete/jquery.autocomplete.pack.js" language="javascript" type="text/javascript"></script>
<style>
	.possiblesTable {
		max-height:10em;
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
		font-weight:bold;
	}
	.onerec{
		border:1px solid black;
	}
	.goodsave{
		border:1px solid green;
		background-color:#FCFFFC;
	}
</style>
<script>
jQuery(document).ready(function() {
		$.each($("input[id^='geopickr']"), function() {
			$("#" + this.id).autocomplete("/ajax/higher_geog.cfm", {
				width: 600,
				max: 50,
				autofill: false,
				multiple: false,
				scroll: true,
				scrollHeight: 300,
				matchContains: true,
				minChars: 1,
				selectFirst:false
			});
	    });

	});
	function useThatOne(pkey,idx) {
		var d=$("#geopickr"+idx).val();
		useThisOne(pkey,d);
	}
	function useThatOneHG(pkey,idx) {
		var d=$("#geopickr"+idx).val();
		useThisOneHG(pkey,d);
	}

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
				$('#oadiv_' + pkey).removeClass().addClass('goodsave');
			}
		);
	}
	function useThisOneHG(pkey,geog) {
		$.getJSON("/component/DSFunctions.cfc",
			{
				method : "upDSGeogHG",
				pkey : pkey,
				geog : geog,
				returnformat : "json",
				queryformat : 'column'
			},
			function(r) {
				$('#oadiv_' + pkey).removeClass().addClass('goodsave');
			}
		);
	}
	function upStatusHG(pkey) {
		$.getJSON("/component/DSFunctions.cfc",
			{
				method : "upDSStatusHG",
				pkey : pkey,
				status : $("#status" + pkey).val(),
				returnformat : "json",
				queryformat : 'column'
			},
			function(r) {
				console.log('saved status');
				$('#oadiv_' + pkey).removeClass().addClass('goodsave');
			}
		);
	}

	function upStatus(pkey) {
		$.getJSON("/component/DSFunctions.cfc",
			{
				method : "upDSStatus",
				pkey : pkey,
				status : $("#status" + pkey).val(),
				returnformat : "json",
				queryformat : 'column'
			},
			function(r) {
				console.log('saved status');
				$('#oadiv_' + pkey).removeClass().addClass('goodsave');
			}
		);
	}
</script>
<!---
create table ds_temp_geog_hg (
	PKEY number not null,
	old_geog varchar2(4000),
	HIGHER_GEOG varchar2(4000),
	STATUS varchar2(4000)
);


create or replace public synonym ds_temp_geog_hg for ds_temp_geog_hg;
grant all on ds_temp_geog_hg to coldfusion_user;
grant select on ds_temp_geog_hg to public;

 CREATE OR REPLACE TRIGGER ds_temp_geog_hg_key
 before insert  ON ds_temp_geog_hg
 for each row
    begin
    	if :NEW.pkey is null then
    		select somerandomsequence.nextval into :new.pkey from dual;
    	end if;
    end;
/
sho err




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
alter table ds_temp_geog drop column calculated_higher_geog;

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



<cfif action is "nothing">
	Load random-ish geography; we'll try to find an appropriate Arctos higher_geog entry.
	<hr>Option One: Load "geog components"
	All columns are optional
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
	<form name="atts" method="post" enctype="multipart/form-data" action="geog_lookup.cfm">
		<input type="hidden" name="Action" value="getFile">
		<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" class="savBtn">
	</form>
	<hr>Option Two: Load "higher geography" strings
	<ul>
		<li>old_geog</li>
	</ul>


	<form name="atts2" method="post" enctype="multipart/form-data" action="geog_lookup.cfm">
		<input type="hidden" name="Action" value="getFile_HG">
		<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" class="savBtn">
	</form>
</cfif>

<cfif action is "getFile_HG">
<cfoutput>

	<!--- put this in a temp table --->
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from ds_temp_geog_hg
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
				insert into ds_temp_geog_hg (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>
</cfoutput>
<cflocation url="geog_lookup.cfm?action=validateHG" addtoken="false">

<!---
---->
</cfif>


<!-------------------------------------------------------------------------------------------->
<cfif action is "validateHG">
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from (select * from ds_temp_geog_hg where HIGHER_GEOG is null and STATUS is null order by higher_geog) where rownum<26
		</cfquery>
		<cfset sint=1>
		<cfloop query="d">
			<p>
				OLD_GEOG: #OLD_GEOG#
				<cfquery name="sr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select higher_geog from geog_auth_rec where stripGeogRanks(higher_geog)=stripGeogRanks('#OLD_GEOG#')
				</cfquery>
				<cfif sr.recordcount is 1 and len(sr.higher_geog) gt 0>
					<cfquery name="k" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						update ds_temp_geog_hg set higher_geog='#sr.higher_geog#',status='stripGeogRanks_match' where OLD_GEOG='#OLD_GEOG#'
					</cfquery>
					<br>--autoupdated: #sr.higher_geog#
				<cfelse>
					<!--- try the last term --->
					<cfset thisTerm=listlast(OLD_GEOG,",")>
					<br>thisTerm: #thisTerm#
					<cfquery name="gst" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						select
							SEARCH_TERM,
							higher_geog
						from
							geog_search_term,
							geog_auth_rec
						where
							geog_auth_rec.GEOG_AUTH_REC_ID=geog_search_term.GEOG_AUTH_REC_ID and
							stripGeogRanks(SEARCH_TERM)=stripGeogRanks('#thisTerm#')
					</cfquery>
					<cfquery name="gst_u" dbtype="query">
						select higher_geog from gst group by higher_geog order by higher_geog
					</cfquery>

					<div id="oadiv_#d.pkey#">
						<cfloop query="gst_u">
							<br>#higher_geog#
							<span class="likeLink" onclick="useThisOneHG('#d.pkey#','#higher_geog#');">use this one</span>
							<cfquery name="gst_t" dbtype="query">
								select SEARCH_TERM from gst where higher_geog='#higher_geog#' group by SEARCH_TERM order by SEARCH_TERM
							</cfquery>
							<cfloop query="gst_t">
								<br>------#SEARCH_TERM#
							</cfloop>

						</cfloop>

					</div>
						<label for="geopickr#sint#">Type to Pick</label>
						<input type="text" name="geopickr" id="geopickr#sint#" size="80">
						<span class="likeLink" id="ut#sint#" onclick="useThatOneHG('#d.pkey#','#sint#');">[ save ]</span>
						<label for="status#sint#">Status</label>
						<input type="text" name="status" placeholder="type here to change status" id="status#d.pkey#" size="80" value="#d.status#" onchange="upStatusHG('#d.pkey#');">

						<cfset sint=sint+1>

				</cfif>


			</p>
			<hr>
		</cfloop>


	</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------------------->


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

<!-------------------------------------------------------------------------------------------->
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
	<cfparam name="rows" default="100">
	<cfparam name="hidestatus" default="yes">
	<cfparam name="debug" default="no">
	<cfparam name="blocksrch" default="geogSearchTerm,NoRankAnythingMatch">

	<form name="f" method="get" action="geog_lookup.cfm">
		<input type="hidden" name="action" value="validate">
		<label for="rows">##Rows</label>
		<input type="numeric" name="rows" value="#rows#">
		<label for="hidestatus">Hide records with status?</label>
		<select name="hidestatus">
			<option <cfif hidestatus is "yes"> selected="selected" </cfif>value="yes">yes</option>
			<option <cfif hidestatus is "no"> selected="selected" </cfif>value="no">no</option>
		</select>
		<label for="debug">Debug?</label>
		<select name="debug">
			<option <cfif debug is "yes"> selected="selected" </cfif>value="yes">yes</option>
			<option <cfif debug is "no"> selected="selected" </cfif>value="no">no</option>
		</select>
		<label for="blocksrch">Block Search</label>
		<select name="blocksrch" multiple="multiple">
			<option <cfif listfindnocase(blocksrch,"geogSearchTerm")> selected="selected" </cfif>value="geogSearchTerm">geogSearchTerm</option>
			<option <cfif listfindnocase(blocksrch,"NoRankAnythingMatch")> selected="selected" </cfif>value="NoRankAnythingMatch">NoRankAnythingMatch</option>
		</select>
		<br><input type="submit" value="go">
	</form>

	<cfif debug is "yes">
		<cfset rows=10>
	</cfif>
	<cfquery name="qdata" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from (
			select * from ds_temp_geog where
			HIGHER_GEOG is null
			<cfif hidestatus is "yes">
				and status is null
			</cfif>
			order by
			 CONTINENT_OCEAN,COUNTRY , STATE_PROV , COUNTY  , QUAD , FEATURE ,ISLAND_GROUP, ISLAND  ,  SEA
		) where rownum<=#rows#
	</cfquery>
	<!--- various strings used to mean "nothing" --->
	<cfset isNotNullBS='none'>
	<cfset result = QueryNew("method,higher_geog")>
	<cfset sint=1>
	<cfloop query="qdata">
		<div class="onerec" id="oadiv_#pkey#">
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

			<!----
			<cfif len(thisState) gt 0>
				<cfset thisState=replace(thisState,'Prov.',"")>
				<cfset thisState=replace(thisState,'Provincia',"")>
				<cfset thisState=replace(thisState,'Province',"")>
				<cfset thisState=replace(thisState,'Parish',"")>
				<cfset thisState=replace(thisState,'Community',"")>
				<cfset thisState=replace(thisState,'Island',"")>
				<cfset thisState=replace(thisState,'Islands',"")>
				<cfset thisState=replace(thisState,'kray',"")>
				<cfset thisState=replace(thisState,'Ward',"")>
				<cfset thisState=replace(thisState,'Territory',"")>
				<cfset thisState=replace(thisState,'autonomous oblast',"")>
				<cfset thisState=replace(thisState,'Republic of',"")>
				<cfset thisState=replace(thisState,'Oblast',"")>
				<cfset thisState=replace(thisState,'Municipality',"")>
				<cfset thisState=replace(thisState,'Pref.',"")>
				<cfset thisState=replace(thisState,'City',"")>
				<cfset thisState=replace(thisState,'Depto.',"")>
				<cfset thisState=replace(thisState,'Departamento',"")>
				<cfset thisState=replace(thisState,'Kabupaten',"")>
				<cfset thisState=replace(thisState,'La',"")>
				<cfset thisState=replace(thisState,'Del',"")>
				<cfset thisState=replace(thisState,'De',"")>
				<cfset thisState=replace(thisState,'De',"")>
				<cfset thisState=replace(thisState,'District',"")>
				<cfset thisState=replace(thisState,'Governorate',"")>
			</cfif>
			---->

			<cfset thisState=rereplace(thisState,'\(.*\)','')>
			<cfset thisState=trim(thisState)>

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

			<!---
			<cfif len(thisIslandGroup) gt 0>
				<cfset thisIslandGroup=replace(thisIslandGroup,' IS.','','all')>
				<cfset thisIslandGroup=replace(thisIslandGroup,' ISL.','','all')>
				<cfset thisIslandGroup=replace(thisIslandGroup,' IS','','all')>
				<cfset thisIslandGroup=replace(thisIslandGroup,' ISL','','all')>
			</cfif>
			---->

			<cfset thisIsland=island>
			<cfloop list="#isNotNullBS#" index="i">
				<cfif thisIsland is i>
					<cfset thisIsland=''>
				</cfif>
			</cfloop>
			<!---
			<cfif len(thisIsland) gt 0>
				<cfset thisIsland=replace(thisIsland,' IS.','','all')>
				<cfset thisIsland=replace(thisIsland,' ISL.','','all')>
				<cfset thisIsland=replace(thisIsland,' IS','','all')>
				<cfset thisIsland=replace(thisIsland,' ISL','','all')>
			</cfif>
			--->


			<cfset thisCounty=county>
			<cfloop list="#isNotNullBS#" index="i">
				<cfif thisCounty is i>
					<cfset thisCounty=''>
				</cfif>
			</cfloop>
			<!---
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
	            <cfset thisCounty=replace(thiscounty,' Borough','','all')>
			</cfif>
			--->
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
				<!----
				upper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(state_prov,'Prov.'),'Community'),'Island'),'kray'),'Ward'),'Territory'),'autonomous oblast'),'okrug'),'Republic of'),'Oblast'),'Parish'),'Municipality'),'Pref.'),'City'),'Depto.')))
				= '#ucase(thisState)#' and
				---->
				stripGeogRanks(state_prov)=stripGeogRanks('#thisState#') and
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
				<!----
				upper(trim(replace(replace(replace(replace(replace(replace(county,'Borough'), 'County'), 'Province'),'Parish'),'District'), 'Territory'))) = '#ucase(thisCounty)#'
				---->
				stripGeogRanks(county)=stripGeogRanks('#thisCounty#')
			<cfelse>
				county is null
			</cfif>
		</cfquery>
		<cfif debug is "yes">
			<cfdump var=#componentMatch#>
		</cfif>


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
					stripGeogRanks(state_prov)=stripGeogRanks('#thisState#') and
					<!----
					upper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(state_prov,'Prov.'),'Community'),'Island'),'kray'),'Ward'),'Territory'),'autonomous oblast'),'okrug'),'Republic of'),'Oblast'),'Parish'),'Municipality'),'Pref.'),'City'),'Depto.')))
					= '#ucase(thisState)#' and
					---->
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
					<!----
					upper(trim(replace(replace(replace(replace(replace(replace(county,'Borough'), 'County'), 'Province'),'Parish'),'District'), 'Territory'))) = '#ucase(thisCounty)#'
					---->
					stripGeogRanks(county)=stripGeogRanks('#thisCounty#')
				<cfelse>
					county is null
				</cfif>
			</cfquery>

		<cfif debug is "yes">
			<cfdump var=#componentMatch#>
		</cfif>

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
					<!----
					upper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(state_prov,'Prov.'),'Community'),'Island'),'kray'),'Ward'),'Territory'),'autonomous oblast'),'okrug'),'Republic of'),'Oblast'),'Parish'),'Municipality'),'Pref.'),'City'),'Depto.')))
					= '#ucase(thisState)#' and
					---->
					stripGeogRanks(state_prov)=stripGeogRanks('#thisState#') and

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
					<!----
					upper(trim(replace(replace(replace(replace(replace(replace(county,'Borough'), 'County'), 'Province'),'Parish'),'District'), 'Territory'))) = '#ucase(thisCounty)#'
					---->
					stripGeogRanks(county)=stripGeogRanks('#thisCounty#')
				<cfelse>
					county is null
				</cfif>
			</cfquery>

			<cfif debug is "yes">
				<cfdump var=#componentMatch#>
			</cfif>

			<cfloop query="componentMatch">
				<cfset QueryAddRow(result, 1)>
				<cfset QuerySetCell(result, "method", thisMethod,n)>
				<cfset QuerySetCell(result, "higher_geog", higher_geog,n)>
				<cfset n=n+1>
			</cfloop>
		</cfif>
		<cfif n eq 1>
			<cfset thisMethod="componentMatch_noCountry">
			<cfset gotsomething=false><!---- make sure we don't just return kinda everything --->
			<cfquery name="componentMatch" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select HIGHER_GEOG from geog_auth_rec where
				<cfif len(thisState) gt 0>
					<cfset gotsomething=true>
					<!----
					upper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(state_prov,'Prov.'),'Community'),'Island'),'kray'),'Ward'),'Territory'),'autonomous oblast'),'okrug'),'Republic of'),'Oblast'),'Parish'),'Municipality'),'Pref.'),'City'),'Depto.')))
					= '#ucase(thisState)#' and
					---->
					stripGeogRanks(state_prov)=stripGeogRanks('#thisState#') and
				<cfelse>
					state_prov is null and
				</cfif>
				<cfif len(thisQuad) gt 0>
                    <cfset gotsomething=true>
					upper(quad) = '#ucase(thisQuad)#' and
				<cfelse>
					quad is null and
				</cfif>
				<cfif len(thisFeature) gt 0>
                    <cfset gotsomething=true>
					upper(feature) = '#ucase(thisFeature)#' and
				<cfelse>
					feature is null and
				</cfif>
				<cfif len(thisIslandGroup) gt 0>
                    <cfset gotsomething=true>
					upper(trim(replace(island_group,'Island'))) = '#ucase(thisIslandGroup)#' and
				<cfelse>
					 island_group is null and
				</cfif>
				<cfif len(thisIsland) gt 0>
                    <cfset gotsomething=true>
					upper(trim(replace(island,'Island'))) = '#ucase(thisIsland)#' and
				<cfelse>
					island is null and
				</cfif>
				<cfif len(thisCounty) gt 0>
                    <cfset gotsomething=true>
					<!----
					upper(trim(replace(replace(replace(replace(replace(replace(county,'Borough'), 'County'), 'Province'),'Parish'),'District'), 'Territory'))) = '#ucase(thisCounty)#'
					---->
					stripGeogRanks(county)=stripGeogRanks('#thisCounty#')

				<cfelse>
					county is null
				</cfif>
				<cfif gotsomething is false>
				    and 1=2
				</cfif>
			</cfquery>

			<cfif debug is "yes">
				<cfdump var=#componentMatch#>
			</cfif>

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

		<cfif debug is "yes">
			<cfdump var=#componentMatch#>
		</cfif>

			<cfloop query="componentMatch">
				<cfset QueryAddRow(result, 1)>
				<cfset QuerySetCell(result, "method", thisMethod,n)>
				<cfset QuerySetCell(result, "higher_geog", higher_geog,n)>
				<cfset n=n+1>
			</cfloop>
		</cfif>
		<cfif n eq 1 and len(thisCountry) gt 0 and len(thisState) gt 0 and len(thisCounty) gt 0>
            <cfset thisMethod="componentMatch_CountryStateCounty">
            <cfquery name="componentMatch" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
                select HIGHER_GEOG from geog_auth_rec where
                   upper(trim(Country)) = '#ucase(thisCountry)#' and
									stripGeogRanks(state_prov)=stripGeogRanks('#thisState#') and
<!----
                   upper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(state_prov,'Prov.'),'Community'),'Island'),'kray'),'Ward'),'Territory'),'autonomous oblast'),'okrug'),'Republic of'),'Oblast'),'Parish'),'Municipality'),'Pref.'),'City'),'Depto.')))
				 = '#ucase(thisState)#' and
				                 upper(trim(replace(replace(replace(replace(replace(replace(county,'Borough'), 'County'), 'Province'),'Parish'),'District'), 'Territory'))) = '#ucase(thisCounty)#'

				 ---->
				stripGeogRanks(county)=stripGeogRanks('#thisCounty#')
            </cfquery>

			<cfif debug is "yes">
				<cfdump var=#componentMatch#>
			</cfif>

            <cfloop query="componentMatch">
                <cfset QueryAddRow(result, 1)>
                <cfset QuerySetCell(result, "method", thisMethod,n)>
                <cfset QuerySetCell(result, "higher_geog", higher_geog,n)>
                <cfset n=n+1>
            </cfloop>
        </cfif>
		<!---- try country:state ---->
		<cfif n eq 1 and len(thisCountry) gt 0 and len(thisState) gt 0 and len(thisCounty) is 0>
            <cfset thisMethod="componentMatch_CountryState_NoCounty">
            <cfquery name="componentMatch" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
                select HIGHER_GEOG from geog_auth_rec where
                   upper(trim(Country)) = '#ucase(thisCountry)#' and
				<!----
				   upper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(state_prov,'Prov.'),'Community'),'Island'),'kray'),'Ward'),'Territory'),'autonomous oblast'),'okrug'),'Republic of'),'Oblast'),'Parish'),'Municipality'),'Pref.'),'City'),'Depto.')))
                = '#ucase(thisState)#' and
				---->
								stripGeogRanks(state_prov)=stripGeogRanks('#thisState#') and

				county is null
            </cfquery>

			<cfif debug is "yes">
				<cfdump var=#componentMatch#>
			</cfif>

            <cfloop query="componentMatch">
                <cfset QueryAddRow(result, 1)>
                <cfset QuerySetCell(result, "method", thisMethod,n)>
                <cfset QuerySetCell(result, "higher_geog", higher_geog,n)>
                <cfset n=n+1>
            </cfloop>
        </cfif>
		<!---- now try unranked junk ---->

		<cfif n eq 1>
            <cfset thisMethod="componentMatch_NoRankSubstringMatch">
			 <cfquery name="componentMatch" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
                select HIGHER_GEOG from geog_auth_rec where 1=1
				   <cfif len(thisCountry) gt 0>
					  and upper(trim(Country)) like '%#ucase(thisCountry)#%'
					</cfif>
					<cfif len(thisState) gt 0>
						and stripGeogRanks(state_prov)=stripGeogRanks('#thisState#')
						<!----
                        and upper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(state_prov,'Prov.'),'Community'),'Island'),'kray'),'Ward'),'Territory'),'autonomous oblast'),'okrug'),'Republic of'),'Oblast'),'Parish'),'Municipality'),'Pref.'),'City'),'Depto.')))
						like '%#ucase(thisState)#%'
						---->
                    </cfif>
                    <cfif len(thisCounty) gt 0>
						<!----
					   and upper(trim(replace(replace(replace(replace(replace(replace(county,'Borough'), 'County'), 'Province'),'Parish'),'District'), 'Territory')))
					       like '%#ucase(thisCounty)#%'
					       ---->
					       and stripGeogRanks(county)=stripGeogRanks('#thisCounty#')
                     </cfif>
            </cfquery>

			<cfif debug is "yes">
				<cfdump var=#componentMatch#>
			</cfif>

            <cfloop query="componentMatch">
                <cfset QueryAddRow(result, 1)>
                <cfset QuerySetCell(result, "method", thisMethod,n)>
                <cfset QuerySetCell(result, "higher_geog", higher_geog,n)>
                <cfset n=n+1>
            </cfloop>
        </cfif>
		<cfif not listfindnocase(blocksrch,"NoRankAnythingMatch")>

			<!---- all somewhere in higher geog, everything stripped ---->

			<cfif n eq 1>
	            <cfset thisMethod="componentMatch_NoRankAnythingMatch">
				 <cfquery name="componentMatch" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	                select HIGHER_GEOG from geog_auth_rec where 1=1
					   <cfif len(thisCountry) gt 0>
						  and (
						  	stripGeogRanks(country)=stripGeogRanks('#thisCountry#') or
						  	stripGeogRanks(state_prov)=stripGeogRanks('#thisCountry#') or
						  	stripGeogRanks(county)=stripGeogRanks('#thisCountry#') or
						  	stripGeogRanks(island)=stripGeogRanks('#thisCountry#') or
						  	stripGeogRanks(island_group)=stripGeogRanks('#thisCountry#')
						  )
						</cfif>
						<cfif len(thisState) gt 0>
							 and (
							  	stripGeogRanks(country)=stripGeogRanks('#thisState#') or
							  	stripGeogRanks(state_prov)=stripGeogRanks('#thisState#') or
							  	stripGeogRanks(county)=stripGeogRanks('#thisState#') or
							  	stripGeogRanks(island)=stripGeogRanks('#thisState#') or
							  	stripGeogRanks(island_group)=stripGeogRanks('#thisState#')
							  )
							<!----
	                        and upper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(state_prov,'Prov.'),'Community'),'Island'),'kray'),'Ward'),'Territory'),'autonomous oblast'),'okrug'),'Republic of'),'Oblast'),'Parish'),'Municipality'),'Pref.'),'City'),'Depto.')))
							like '%#ucase(thisState)#%'
							---->
	                    </cfif>
	                    <cfif len(thisCounty) gt 0>
							 and (
							  	stripGeogRanks(country)=stripGeogRanks('#thisCounty#') or
							  	stripGeogRanks(state_prov)=stripGeogRanks('#thisCounty#') or
							  	stripGeogRanks(county)=stripGeogRanks('#thisCounty#') or
							  	stripGeogRanks(island)=stripGeogRanks('#thisCounty#') or
							  	stripGeogRanks(island_group)=stripGeogRanks('#thisCounty#')
							  )
							<!----
						   and upper(trim(replace(replace(replace(replace(replace(replace(county,'Borough'), 'County'), 'Province'),'Parish'),'District'), 'Territory')))
						       like '%#ucase(thisCounty)#%'

						       					       and stripGeogRanks(county)=stripGeogRanks('#thisCounty#')



						       ---->
	                     </cfif>
	            </cfquery>

				<cfif debug is "yes">
					<cfdump var=#componentMatch#>
				</cfif>

	            <cfloop query="componentMatch">
	                <cfset QueryAddRow(result, 1)>
	                <cfset QuerySetCell(result, "method", thisMethod,n)>
	                <cfset QuerySetCell(result, "higher_geog", higher_geog,n)>
	                <cfset n=n+1>
	            </cfloop>
	        </cfif>
	   </cfif>
		<!--- geog_search_term --->
		<cfif not listfindnocase(blocksrch,"geogSearchTerm")>
			<cfif n eq 1>
	            <cfset thisMethod="geogSearchTerm">
				 <cfquery name="componentMatch" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	                select HIGHER_GEOG from geog_auth_rec,geog_search_term where
					geog_auth_rec.geog_auth_rec_id=geog_search_term.geog_auth_rec_id and (
					1=2
					   <cfif len(thisCountry) gt 0>
						  or stripGeogRanks(SEARCH_TERM) like stripGeogRanks('#thisCountry#')
						</cfif>
						<cfif len(thisState) gt 0>
							or stripGeogRanks(SEARCH_TERM) like stripGeogRanks('#thisState#')
	                    </cfif>
	                    <cfif len(thisCounty) gt 0>
							or stripGeogRanks(SEARCH_TERM) like stripGeogRanks('#thisCounty#')
	                     </cfif>
						)
	            </cfquery>


				<cfif debug is "yes">
					<cfdump var=#componentMatch#>
				</cfif>

				 <cfloop query="componentMatch">
	                <cfset QueryAddRow(result, 1)>
	                <cfset QuerySetCell(result, "method", thisMethod,n)>
	                <cfset QuerySetCell(result, "higher_geog", higher_geog,n)>
	                <cfset n=n+1>
	            </cfloop>
			</cfif>
		</cfif>
		<cfif result.recordcount is 1>
			<cfquery name="upr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update
					ds_temp_geog
				set
					HIGHER_GEOG='#result.higher_geog#',
					status='#result.method#'
				where
					pkey=#qdata.pkey#
			</cfquery>
			<div class="r_status">
				found one - autoupdate
				<script>
					$('##oadiv_#pkey#').removeClass().addClass('goodsave');
				</script>
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
							<td><span class="likeLink" id="ut#sint#" onclick="useThisOne('#qdata.pkey#','#higher_geog#');">[ use this ]</span></td>
							<cfset sint=sint+1>
						</tr>
					</cfloop>

				</table>
				<label for="geopickr#sint#">Type to Pick</label>
				<input type="text" name="geopickr" id="geopickr#sint#" size="80">
				<span class="likeLink" id="ut#sint#" onclick="useThatOne('#qdata.pkey#','#sint#');">[ save ]</span>
				<cfset sint=sint+1>
			</div>
		<cfelse>
			<div class="r_status">
				found nothing
				<label for="geopickr#sint#">Type to Pick</label>
				<input type="text" name="geopickr" placeholder="type here to pick" id="geopickr#sint#" size="80">
				<span class="likeLink" id="ut#sint#" onclick="useThatOne('#qdata.pkey#','#sint#');">[ save ]</span>
				<cfset sint=sint+1>
			</div>
		</cfif>
		<label for="status#sint#">Status</label>
		<input type="text" name="status" placeholder="type here to change status" id="status#qdata.pkey#" size="80" value="#status#" onchange="upStatus('#qdata.pkey#');">
		<!---
		<span class="likeLink" id="usts#qdata.pkey#" onclick="upStatus('#qdata.pkey#');">[ savestatus ]</span>
		---->
		</div>
	</cfloop>
</cfoutput>
</cfif>
<cfif action is "csv">
	<cfquery name="getData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			CONTINENT_OCEAN,
			COUNTRY,
			STATE_PROV,
			COUNTY,
			QUAD,
			FEATURE,
			ISLAND,
			ISLAND_GROUP,
			SEA,
			HIGHER_GEOG,
			STATUS
		from ds_temp_geog
			order by
			HIGHER_GEOG
	</cfquery>
	<cfset  util = CreateObject("component","component.utilities")>
	<cfset csv = util.QueryToCSV2(Query=getData,Fields=data.getData)>
	<cffile action = "write"
	    file = "#Application.webDirectory#/download/geog_lookup.csv"
	   	output = "#csv#"
	   	addNewLine = "no">

	<!----
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
	---->
	<cfoutput>
		<cflocation url="/download.cfm?file=geog_lookup.csv" addtoken="false">
		<a href="/download/#fname#">Click here if your file does not automatically download.</a>
	</cfoutput>
</cfif>