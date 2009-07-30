<cfobject type="JAVA" action="Create" name="factory" class="coldfusion.server.ServiceFactory">
 
<cfset allTasks = factory.CronService.listAll()>  
 
<cfset numberOtasks = arraylen(allTasks)>
<cfloop index="i" from="1" to="#numberOtasks#">
<cfoutput> #allTasks[i].task#  </cfoutput>
</cfloop>
 
or, see all details with:
<cfdump var="#allTasks#">



<cffile action = "read" file="#server.coldfusion.ROOTDIR#/lib/neo-cron.xml" variable="XMLCron"> <cfdump var="#XMLCron#">