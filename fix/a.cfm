<cfinclude template="/includes/_header.cfm">


clobs suck
move tehm

create table temp_mc_log (cn varchar2(255));


<cfquery name="pd" datasource="prod">
	select * from temp_chas_mamm
</cfquery>

<cfquery name="td" datasource="UAM_GOD">
	select * from chas where cat_num not in (select cat_num from temp_chas_mamm) and rownum<10
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
<cfinclude template="/includes/_footer.cfm">