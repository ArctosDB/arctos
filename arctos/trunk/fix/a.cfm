<cfobject type="JAVA" action="Create" name="factory" class="coldfusion.server.ServiceFactory">
<cfset allTasks = factory.CronService.listAll()>  
<cfset numberOtasks = arraylen(allTasks)>
<cfloop index="i" from="1" to="#numberOtasks#">
	<cfschedule action="delete" task="#allTasks[i].task#">
</cfloop>
 

<cfschedule action = "update"
    task = "image_transfer" 
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/checkNew.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "#timeformat(now() + 10000)#"
    interval = "180"
    requestTimeOut = "600">
	
	
	<cfoutput>
	
		#timeformat(now() + 10000)#
	</cfoutput>