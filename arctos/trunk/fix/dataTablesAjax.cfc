<cfcomponent>
<cffunction name="t" access="remote" returnformat="json" queryFormat="column">
	<cfquery name="result" datasource="uam_god">
		select
			agent_id PersonID,
			preferred_agent_name Name,
			agent_id Age,
			created_date RecordDate
		from agent where rownum<30
	</cfquery>


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

<cfreturn result>
</cffunction>

</cfcomponent>