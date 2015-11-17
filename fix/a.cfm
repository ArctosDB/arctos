<cfinclude template="/includes/_header.cfm">


clobs suck
move tehm

create table temp_mc_log (cn varchar2(255));


<cfquery name="pd" datasource="prod">
	select * from temp_chas_mamm
</cfquery>

<cfdump var=#pd#>
<cfquery name="td" datasource="UAM_GOD">
	select * from chas where WKT_POLYGON is not null and rownum<10
</cfquery>
<cfloop query="instdone">
	<cfquery name="pd" datasource="prod">
		insert into temp_chas_mamm (#td.columnlist#) values (
		<cfloop list="#td.columnlist#" index="i">
		               <cfif i is "wkt_polygon">
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



<!---------------------------------------------------------------------------------------------------->
<cfinclude template="/includes/_footer.cfm">