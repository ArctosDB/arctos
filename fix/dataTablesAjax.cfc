<cfcomponent>
<cffunction name="t" access="remote" returnformat="json" queryFormat="column">
	<cfquery name="d" datasource="uam_god">
		select
			agent_id PersonID,
			preferred_agent_name Name,
			agent_id Age,
			created_date RecordDate
		from agent where rownum<30
	</cfquery>


<cfoutput>
	<!--- CF and jtable don't play well together, so roll our own.... ---->
	
	<cfset x='{
				"Result":"OK",
				"Records":['>
	<cfloop query="d">
		<cfset trow="">
		<cfloop list="#d.columnlist#" index="i">
			<cfset temp & '"#i#":"' & evaluate("d." & i) & '"'>
			<cfset trow=listappend(trow,temp)>
		</cfloop>
		<p>#trow#</p>
	</cfloop>
<cfset x=x & ''>
<!----
<cfset x='{
 "Result":"OK",
 "Records":[
  {"PersonId":1,"Name":"Benjamin Button","Age":17,"RecordDate":"\/Date(1320259705710)\/"},
  {"PersonId":2,"Name":"Douglas Adams","Age":42,"RecordDate":"\/Date(1320259705710)\/"},
  {"PersonId":3,"Name":"Isaac Asimov","Age":26,"RecordDate":"\/Date(1320259705710)\/"},
  {"PersonId":4,"Name":"Thomas More","Age":65,"RecordDate":"\/Date(1320259705710)\/"}
 ]
}'>

<cfreturn x>

---->


</cfoutput>

<cfreturn result>
</cffunction>

</cfcomponent>