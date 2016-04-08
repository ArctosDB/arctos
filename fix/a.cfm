<cfinclude template="/includes/_header.cfm">



	<cfset obj = CreateObject("component","component.utilities")>

	<cfquery name="td" datasource="UAM_GOD">
		select *
      from ( select media_uri
               from media
                      order by dbms_random.value )
     where rownum <= 4
	</cfquery>
	<cfloop query="td">
		<p>#media_uri#</p>
		<cfset x=obj.exitLink(target=media_uri)>
		<cfdump var=#x#>
	</cfloop>


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