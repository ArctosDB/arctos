<!--- first, get rid of everything --->
<cfobject type="JAVA" action="Create" name="factory" class="coldfusion.server.ServiceFactory">
<cfset allTasks = factory.CronService.listAll()>
<cfset numberOtasks = arraylen(allTasks)>
<cfloop index="i" from="1" to="#numberOtasks#">
	<cfschedule action="delete" task="#allTasks[i].task#">
</cfloop>




<cfschedule action = "update"
    task = "pendingRelations"
    operation = "HTTPRequest"
    url = "http://127.0.0.1/ScheduledTasks/processBulkloadClassification.cfm?action=fill_in_the_blanks_from_genus"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "0:03 AM"
    interval = "60"
    requestTimeOut = "60">



<cfschedule action = "update"
    task = "send_chris_email"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/send_chris_email.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "04:51 AM"
    interval = "daily"
    requestTimeOut = "600">
