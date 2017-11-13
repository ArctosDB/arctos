<cfinclude template="/includes/_header.cfm">
Application.logfile
<cfoutput>
<cfexecute name = "tail"
    arguments = "#Application.webDirectory#/fix/a.cfm">

</cfexecute>

ok...





</cfoutput>





<!----------------

<cfdump var=#x#>


#Application.logfile#
<!---
create table temp_test (u varchar2(255), p varchar2(255));
insert into temp_test (u,p) values ('dustylee','xxxxx');
---->


    <cfquery datasource='uam_god' name='p'>
		select
		higher_geog,
		spec_locality
			from flat where guid='CHAS:Egg:569'
	</cfquery>
	<cfdump var=#p#>
<cfloop query="p">
	<cfset x= IIf(spec_locality EQ ""),DE(""),IIf(spec_locality) EQ "no specific locality recorded"),DE(""),DE(", " & de(spec_locality))))) >
</cfloop>
	<cfoutput>
	#x#
	</cfoutput>
<!----------------------------

 IIf((higher_geog EQ "no higher geography recorded"),DE(""),
DE(REPLACE(higher_geog,"North America, United States","USA","all"))) &
IIf((spec_locality EQ ""),
DE(""),
DE(IIf((spec_locality EQ "no specific locality recorded"),DE(""),DE(", " & spec_locality)))) is not a valid ColdFusion expression.

 &
				IIf(
					p.spec_locality EQ "",
					"",
					IIf(
						p.spec_locality EQ "no specific locality recorded",
						"",
						", " & p.spec_locality
					)
				)>



<cfoutput>


    <cfquery datasource='uam_god' name='p'>
        select * from temp_test
    </cfquery>


    <cfhttp
        method="post"
        username="#p.u#"
        password="#p.p#"
        result="pr"
        url="https://web.corral.tacc.utexas.edu/irods-rest/rest/fileContents/corralZ/web/UAF/arctos/mediaUploads/cfUpload/chas.jpeg">
            <cfhttpparam type="header" name="accept" value="multipart/form-data">
            <cfhttpparam type="file" name="chas.jpeg" file="/usr/local/httpd/htdocs/wwwarctos/images/chas.jpeg">
    </cfhttp>

    <cfdump var=#pr#>
</cfoutput>


drop table temp_dnametest;

create table temp_dnametest (
	taxon_name_id number,
	scientific_name varchar2(255),
	display_name varchar2(255),
	gdisplay_name varchar2(255),
	cid varchar2(255)
);

-- data
-- only get stuff with display name
-- for stuff that doesn't match, figure out why


delete from temp_dnametest where gdisplay_name is null;


insert into temp_dnametest (
	taxon_name_id,
	scientific_name,
	display_name,
	cid
) (
	select distinct
		taxon_term.taxon_name_id,
		taxon_name.scientific_name,
		taxon_term.term display_name,
		taxon_term.classification_id
	from
		taxon_term,
		taxon_name
	where
		taxon_term.taxon_name_id=taxon_name.taxon_name_id and
		taxon_term.term_type='display_name'
	);


select
	'"' || display_name || '"' || chr(9) || chr(9) || chr(9) || '"' || gdisplay_name || '"'
from
	temp_dnametest where
	gdisplay_name not like 'ERROR%' and gdisplay_name is not null and display_name!=gdisplay_name;

update temp_dnametest set gdisplay_name=null where gdisplay_name not like 'ERROR%' and gdisplay_name!=display_name;


create index ix_temp_junk on temp_dnametest (taxon_name_id) tablespace uam_idx_1;


<cfset utilities = CreateObject("component","component.utilities")>
<cfquery name="d" datasource="uam_god">
	select * from temp_dnametest where gdisplay_name is null and rownum<1000
</cfquery>
<cfoutput>
	<cftransaction>
	<cfloop query="d">

		<cfset x=utilities.generateDisplayName(cid)>
		<cfif len(x) is 0>
			<cfset x='NORETURN'>
		</cfif>
	<!----
		<br>scientific_name=#scientific_name#
		<br>display_name=<pre>#display_name#</pre>
		<br>x=<pre>#x#</pre>
			<cfif x is not display_name>
			<br>NOMATCH!!
		</cfif>
		--->

		<cfquery name="b" datasource="uam_god">
			update temp_dnametest set gdisplay_name='#x#' where taxon_name_id=#taxon_name_id#
		</cfquery>

	</cfloop>
	</cftransaction>
</cfoutput>

<cfabort>



	<cfset Application.docURL = 'http://handbook.arctosdb.org/documentation'>





<cfquery name="d" datasource="prod">
	select * from temp_dl_up where status is null
</cfquery>

<cfoutput>
	<cfloop query="d">
		<cfset nl=newlink>
		<hr>
		<br>#newlink#
		<cfif newlink contains "##">
			<cfset anchor=listgetat(newlink,2,'##')>
		<cfelse>
			<cfset anchor=''>
			<cfset as='noanchor'>
		</cfif>


		<cfhttp url="#newlink#" method="GET"></cfhttp>

			<cfdump var=#cfhttp#>


		<cfset s=left(cfhttp.statuscode,3)>
		<cfif len(anchor) gt 0>
			<cfif cfhttp.fileContent does not contain 'id="#anchor#"'>

			<br>cfhttp.fileContent does not contain 'id="#anchor#"'



				<cfset as='anchor_notfound'>
				<cfif anchor contains "_">
					<br>gonna try anchor magic....
					<cfset anchor=replace(anchor,"_","-","all")>
					<cfset nl=listdeleteat(nl,2,'##')>
					<cfset nl=nl & '##' & anchor>
					<br>nl is now #nl#
					<cfhttp url="#nl#" method="GET"></cfhttp>


					<cfdump var=#cfhttp#>

					<cfif cfhttp.fileContent contains 'id="#anchor#"'>
						happy!!
						<cfset as='anchor_mod'>
					</cfif>

				</cfif>
			<cfelse>
				<cfset as='anchorhappy'>
			</cfif>
		</cfif>

		<cfquery name="ud" datasource="prod">
			update temp_dl_up set status='#s#',anchorstatus='#as#' where newlink='#newlink#'
		</cfquery>

		<br>update temp_dl_up set newlink='#nl#',status='#s#',anchorstatus='#as#' where newlink='#newlink#'
	</cfloop>
</cfoutput>




<cfquery name="d" datasource="uam_god">
with rws as (
SELECT SYS_CONNECT_BY_PATH(t || '##' || level , ',') || ',' pth
FROM test
where t like 'Sorex%'
START WITH pid is null
CONNECT BY PRIOR id = pid
), vals as (
  select
  substr(pth,
    instr(pth, '##', 1, column_value) + 2,
    ( instr(pth, ',', 1, column_value + 1) - instr(pth, '##', 1, column_value) - 2 )
  ) - 1 levl,
  substr(pth,
    instr(pth, ',', 1, column_value) + 1,
    ( instr(pth, '##', 1, column_value) - instr(pth, ',', 1, column_value) - 1 )
  ) valv
  from rws, table ( cast ( multiset (
    select level l
    from   dual
    connect by level <= length(pth) - length(replace(pth, ','))
  ) as sys.odcinumberlist)) t
)
  select distinct lpad(' ', levl * 2) || valv valv, levl
  from   vals
  where  valv is not null
  order  by levl

</cfquery>

<cfoutput>
<cfloop query="d">
	<br>#valv#
</cfloop>

Upload state CSV:
	<form name="getFile" method="post" action="a.cfm" enctype="multipart/form-data">
		<input type="hidden" name="action" value="getfish2">
		 <input type="file"
			   name="FiletoUpload"
			   size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" class="savBtn">
	</form>
	create table temp_geostate (
	name varchar2(4000),
	id varchar2(4000),
	geometry clob
	);


<cfif action is "getfish2">
	<cfoutput>
		<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
        <cfset  util = CreateObject("component","component.utilities")>
		<cfset x=util.CSVToQuery(fileContent)>
        <cfset cols=x.columnlist>
		<br>x.recordcount: #x.recordcount#
		<cfflush>
		<cftransaction>
	        <cfloop query="x">
	            <cfquery name="ins" datasource="uam_god">
		            insert into temp_geostate (#cols#) values (
		            <cfloop list="#cols#" index="i">
		               <cfif i is "geometry">
		            		<cfqueryparam value="#evaluate(i)#" cfsqltype="cf_sql_clob">
		                <cfelse>
		            		'#escapeQuotes(evaluate(i))#'
		            	</cfif>
		            	<cfif i is not listlast(cols)>
		            		,
		            	</cfif>
		            </cfloop>
		            )
	            </cfquery>
	        </cfloop>
		</cftransaction>
		loaded to temp_geostate go go gadget sql
	</cfoutput>
</cfif>



Upload county CSV:
	<form name="getFile" method="post" action="a.cfm" enctype="multipart/form-data">
		<input type="hidden" name="action" value="getfish">
		 <input type="file"
			   name="FiletoUpload"
			   size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" class="savBtn">
	</form>
<cfif action is "getfish">
	<cfoutput>
		<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
        <cfset  util = CreateObject("component","component.utilities")>
		<cfset x=util.CSVToQuery(fileContent)>
        <cfset cols=x.columnlist>
		<br>x.recordcount: #x.recordcount#
		<cfflush>
		<cftransaction>
	        <cfloop query="x">
	            <cfquery name="ins" datasource="uam_god">
		            insert into temp_geocounty (#cols#) values (
		            <cfloop list="#cols#" index="i">
		               <cfif i is "geometry">
		            		<cfqueryparam value="#evaluate(i)#" cfsqltype="cf_sql_clob">
		                <cfelse>
		            		'#escapeQuotes(evaluate(i))#'
		            	</cfif>
		            	<cfif i is not listlast(cols)>
		            		,
		            	</cfif>
		            </cfloop>
		            )
	            </cfquery>
	        </cfloop>
		</cftransaction>
		loaded to temp_geocounty go go gadget sql
	</cfoutput>
</cfif>

create table temp_geocounty (
	CountyName varchar2(4000),
	StateCounty varchar2(4000),
	stateabbr varchar2(4000),
	StateAbbrToo varchar2(4000),
	geometry clob,
	value varchar2(4000),
	GEO_ID varchar2(4000),
	GEO_ID2 varchar2(4000),
	GeographicName varchar2(4000),
	STATEnum varchar2(4000),
	COUNTYnum varchar2(4000),
	FIPSformula varchar2(4000),
	Haserror varchar2(4000)
	);
</cfoutput>
<!--------------------


<cfhttp method="post" url="https://api.opentreeoflife.org/v2/tnrs/match_names">

	<cfhttpparam type="header"
        name ="application/json"
       value ="content-type">

	<cfhttpparam type="Formfield"
        value="Annona cherimola"
        name="names">
	<cfhttpparam type="Formfield"
        value="Aberemoa dioica"
        name="names">
	<cfhttpparam type="Formfield"
        value="Annona acuminata"
        name="names">


</cfhttp>

<cfdump var=#cfhttp#>


<cfset jr=DeserializeJSON(cfhttp.filecontent)>

<cfdump var=#jr#>

?names=Annona cherimola" \
-H "" -d \
'{"names":["Aster","Symphyotrichum","Erigeron","Barnadesia"]}'



https://api.opentreeoflife.org/v2/tnrs/match_names?names=

clobs suck
move tehm

create table temp_mc_log (cn varchar2(255));



<cfquery name="td" datasource="UAM_GOD">
	select * from (select * from chas where cat_num not in (select cn from temp_mc_log)) where rownum<500
</cfquery>
<cfloop query="td">
	<cfquery name="insthis" datasource="prod">
		insert into temp_chas_mamm (#td.columnlist#) values (
		<cfloop list="#td.columnlist#" index="i">
            <cfif i is "wkt_polygon">
           		<cfqueryparam value="#evaluate(i)#" cfsqltype="cf_sql_clob">
            <cfelse>
           		'#escapeQuotes(evaluate(i))#'
           	</cfif>
           	<cfif i is not listlast(td.columnlist)>
           		,
           	</cfif>
		</cfloop>
		)
	</cfquery>
	<cfquery name="l" datasource="UAM_GOD">
		insert into temp_mc_log (cn) values ('#td.cat_num#')
	</cfquery>
</cfloop>
<!---------------------------------------------------------------------------------------------------->

--------->
--------->
--------->

<cfinclude template="/includes/_footer.cfm">