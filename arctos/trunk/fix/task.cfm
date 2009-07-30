<cfobject type="JAVA" action="Create" name="factory" class="coldfusion.server.ServiceFactory">
 
<cfset allTasks = factory.CronService.listAll()>  
 
<cfset numberOtasks = arraylen(allTasks)>
<cfloop index="i" from="1" to="#numberOtasks#">
<cfoutput> #allTasks[i].task#  </cfoutput>
</cfloop>
 
or, see all details with:
<cfdump var="#allTasks#">



<cffile action = "read" file="#server.coldfusion.ROOTDIR#/lib/neo-cron.xml" variable="XMLCron"> <cfdump var="#XMLCron#">



<cflock name="alltasks" type="exclusive" timeout="10">
    <!--- http://www.anticlue.net/archives/000303.htm --->
    <cfscript>
        factory = CreateObject("java","coldfusion.server.ServiceFactory");
        cron_service = factory.CronService;
        services = cron_service.listALL();
    </cfscript>
</cflock>

Next, display the list to the screen. This is a temporary piece of code, we will replace with a filtered table later.
<cfdump var="#services#" label="All Scheduled Tasks">