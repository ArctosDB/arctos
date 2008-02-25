<cfset runtime = CreateObject("java","java.lang.Runtime").getRuntime()>
<cfset freeMemory = runtime.freeMemory() / 1024 / 1024>
<cfset totalMemory = runtime.totalMemory() / 1024 / 1024>
<cfset maxMemory = runtime.maxMemory() / 1024 / 1024>

<cfoutput>
    Free Allocated Memory: #Round(freeMemory)#mb<br>
    Total Memory Allocated: #Round(totalMemory)#mb<br>
    Max Memory Available to JVM: #Round(maxMemory)#mb<br>
</cfoutput>