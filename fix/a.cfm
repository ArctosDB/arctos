	<cfset Application.docURL = 'http://handbook.arctosdb.org/documentation'>


<cfabort>




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


----------->
<cfinclude template="/includes/_footer.cfm">