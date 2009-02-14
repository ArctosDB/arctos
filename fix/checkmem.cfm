<cfquery name="gn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT global_name FROM global_name 
</cfquery>
<cfset runtime = CreateObject("java","java.lang.Runtime").getRuntime()>
<cfset freeMemory = runtime.freeMemory() / 1024 / 1024>
<cfset totalMemory = runtime.totalMemory() / 1024 / 1024>
<cfset maxMemory = runtime.maxMemory() / 1024 / 1024>
<cfset percentFreeAllocated = Round((freeMemory / totalMemory) * 100)>
<cfset percentAllocated = Round((totalMemory / maxMemory ) * 100)>

<cfoutput>
	<table border=0>
	<tr><td colspan=2>#gn.global_name#</td></tr>
	<tr><td colspan=2>&nbsp;</td></tr>
    <tr><td>Free Allocated Memory: </td><td>#Round(freeMemory)#mb</td></tr>
    <tr><td>Total Memory Allocated: </td><td>#Round(totalMemory)#mb</td></tr>
    <tr><td>Max Memory Available to JVM: </td><td>#Round(maxMemory)#mb</td></tr>
    <tr><td>% of Free Allocated Memory: </td><td>#percentFreeAllocated#%</td></tr>
    <tr><td>% of Available Memory Allocated: </td><td>#percentAllocated#%</td></tr>
	</table>
</cfoutput>