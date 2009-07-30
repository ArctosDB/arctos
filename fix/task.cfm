<cfobject type="JAVA" action="Create" name="factory" class="coldfusion.server.ServiceFactory">
<cfset allTasks = factory.CronService.listAll()>  
 
<cfset numberOtasks = arraylen(allTasks)>
<cfloop index="i" from="1" to="#numberOtasks#">
	<cfoutput> 
		<cfschedule action="delete" task="#allTasks[i].task#">
	 </cfoutput>
</cfloop>
 