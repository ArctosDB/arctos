<cfcomponent output="false">

  <!--- Lookup used for auto suggest --->
   <cffunction name="lookupname" access="remote" returntype="array">
<cfargument name="search" type="any" required="false" default="">

<!--- Define variables --->
<cfset var data="">
<cfset var result=ArrayNew(1)>

<!--- Do search --->
<cfquery datasource="uam_god" name="data">
SELECT agent_name || ' (' || agent_id || ')' name
FROM agent_name
WHERE UCase(agent_name) LIKE ('#ucase(ARGUMENTS.search)#%')
and rownum<100
ORDER BY agent_name
</cfquery>

<!--- Build result array --->
<cfloop query="data">
<cfset ArrayAppend(result, agent_name)>
</cfloop>

      <!--- And return it --->
<cfreturn result>
   </cffunction>
   
</cfcomponent>