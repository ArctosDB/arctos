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


<cffunction name="GetScheduledTasks" returntype="query" output="no">

    <!--- Local vars --->
    <cfset var tasks="">
    <cfset var result=QueryNew('path,file,resolveurl,url,publish,password,operation,username,interval,start_date,http_port,task,http_proxy_port,proxy_server,disabled,start_time,request_time_out')>
    <cfset var OuterStart="">
    <cfset var InnerStart="">
    <cfset var qRETest="">
    <cfset var qRETestinner="">
    <cfset var ScheduleItem="">

    <!--- This call is undocumented --->
    <cfsavecontent variable="tasks">
        <cfschedule action="run" task="__list">
    </cfsavecontent>

    <!--- The start for each schedule entry --->
    <cfset OuterStart=1>

    <!--- Be super careful when using an infinite loop in this manner.
        Actually, never use an infinite loop in this manner. --->
    <cfloop condition="OuterStart">
        <!--- Each schedule item is a text string followed by an = followed by a double {.
            The end of the item also has a double }
            Getting only the elements in an item removed the need for a negative lookahead later --->
        <cfset qRETest=REFind('\w+={{(.+?})}}', tasks, OuterStart, 1)>
        <!--- If there is a result, use it.
            Otherwise break out of the loop. VERY IMPORTANT!!! --->
        <cfif qRETest.Pos[1]>
            <!--- This is the string containing all of the
                elements in a schedule item --->
            <cfset ScheduleItem=Mid(tasks, qRETest.Pos[2], qRETest.len[2])>
            <!--- Set the start past the schedule item found --->
            <cfset OuterStart=qRETest.Pos[2]+qRETest.len[2]>

            <!--- The start for each element of a schedule item --->
            <cfset InnerStart=1>
            <!--- Add a row. We don't have so specify as we'll be
                adding 1 per schedule item --->
            <cfset QueryAddRow(result)>
        
            <!--- Be super careful when using an infinite loop in this manner.
                Actually, never use an infinite loop in this manner. --->
            <cfloop condition="InnerStart">
                <!--- A schedule element is text followed by an = followed by
                    a value inside of {}. Even though the schedule item string
                    can be seen as a list, we don't know if there will be a
                    comma inside one of the elements so we're doing it the
                    hard but safe way. --->
                <cfset qRETestinner=REFind('(\w+)={([^}]*)}', ScheduleItem, InnerStart, 1)>
    
                <!--- If there is a result, use it.
                    Otherwise break out of the loop. VERY IMPORTANT!!! --->
                <cfif qRETestinner.Pos[1]>
                    <!--- The QuerySetCell will automatically assign the value to the last row added so no need to specify row. The second element of the RegEx return is the column name and the third is the value--->
                    <cfset QuerySetCell(result,
                                        Mid(ScheduleItem, qRETestinner.Pos[2], qRETestinner.len[2]),
                                        Mid(ScheduleItem, qRETestinner.Pos[3], qRETestinner.len[3]))>
                    <!--- Set the start past the schedule element found --->
                    <cfset InnerStart=qRETestinner.Pos[1]+qRETestinner.len[1]>
                <cfelse>
                    <!--- Break out of our inner infinite loop --->
                    <cfbreak>
                </cfif>
            </cfloop>
        <cfelse>
            <!--- Break out of our inner infinite loop --->
            <cfbreak>
        </cfif>
    </cfloop>

    <cfreturn result>

</cffunction>

<cfset bla=GetScheduledTasks()>
<cfdump var="#bla#">