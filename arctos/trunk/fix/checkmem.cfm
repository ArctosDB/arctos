<cfquery name="c" datasource="#Application.web_user#" username="" password="">
	select global_name from global_name
</cfquery>
<cfoutput>
	<table border=1><tr><td>#c.global_name#</td></tr>
</cfoutput>

<cfset runtime = CreateObject("java","java.lang.Runtime").getRuntime()>
<cfset freeMemory = runtime.freeMemory() / 1024 / 1024>
<cfset totalMemory = runtime.totalMemory() / 1024 / 1024>
<cfset maxMemory = runtime.maxMemory() / 1024 / 1024>

<cfoutput>
	<tr><td>Free Allocated Memory: #Round(freeMemory)#mb</td></tr>
    <tr><td>Total Memory Allocated: #Round(totalMemory)#mb</td></tr>
    <tr><td>Max Memory Available to JVM: #Round(maxMemory)#mb</td></tr>
</cfoutput>

<cfset percentFreeAllocated = Round((freeMemory / totalMemory) * 100)>
<cfset percentAllocated = Round((totalMemory / maxMemory ) * 100)>
<cfoutput>
    <tr><td>% of Free Allocated Memory: #percentFreeAllocated#%</td></tr>
    <tr><td>% of Available Memory Allocated: #percentAllocated#%</td></tr></table>
</cfoutput>

