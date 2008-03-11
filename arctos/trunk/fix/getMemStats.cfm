<cfscript>
runtime = CreateObject("java","java.lang.Runtime").getRuntime();
freeMemory = Round(runtime.freeMemory() / 1024 / 1024);
totalMemory = Round(runtime.totalMemory() / 1024 / 1024);
maxMemory = Round(runtime.maxMemory() / 1024 / 1024);

percentFreeAllocated = Round((freeMemory / totalMemory) * 100);
percentAllocated = Round((totalMemory / maxMemory ) * 100);

datetime = now();

statRec = datetime & chr(9) &
	freeMemory & chr(9) & 
	totalMemory & chr(9) & 
	maxMemory & chr(9) & 
	percentFreeAllocated & chr(9) & 
	percentAllocated;

path = getdirectoryfrompath(gettemplatepath());
filepath = path & "memStats.txt";
</cfscript>

<!--- <cfoutput><p>#path#</p></cfoutput> --->

<!--- Delete file if specified --->
<cfif isdefined("form.delete")>
<cffile action="delete" file="#filepath#" >
</cfif>

<!---
<!--- Load file --->
<cfif fileexists(filepath)>
<cffile action="read" file="#filepath#" variable="wddxMemMonitor">
<cfwddx action="wddx2cfml" input="#wddxMemMonitor#" output="memorymonitor">
</cfif>

<cfscript>
if (not isdefined("memorymonitor"))
memorymonitor = structnew();

if (not structkeyexists(memorymonitor, "aStats"))
memorymonitor.aStats = arraynew(1);

/*
Stats Structure
- datetime
- freeAllocMem
- totAllocMem
- maxAllocMem
- freeAllocMemPerc
- availAllocMemPerc
*/

stStats = structnew();
stStats.datetime = datetime;
stStats.freeAllocMem = freeMemory;
stStats.usedAllocMem = totalMemory - freeMemory;
stStats.totAllocMem = totalMemory;
stStats.maxAllocMem = maxMemory;
stStats.freeAllocMemPerc = percentFreeAllocated;
stStats.usedAllocMemPerc = percentAllocated - percentFreeAllocated;
stStats.availAllocMemPerc = percentAllocated;

arrayappend(memorymonitor.aStats, stStats);

// convert array to query
lCols = "datetime,freeAllocMem,usedAllocMem,maxUsedMem,totAllocMem,maxAllocMem,freeAllocMemPerc,usedAllocMemPerc,availAllocMemPerc";
qStats = querynew(lCols);
maxUsedMem = 0;
for (i = 1; i lte arraylen(memorymonitor.aStats); i = i + 1)
{
 queryaddrow(qStats);
 for (key in memorymonitor.aStats[i])
 {
  if (isdate(memorymonitor.aStats[i][key]))
  value = dateformat(memorymonitor.aStats[i][key]) & ' ' & timeformat(memorymonitor.aStats[i][key], "HH:mm:ss");
  else if (listfindnocase("freeAllocMemPerc,usedAllocMemPerc,availAllocMemPerc", key))
  value = memorymonitor.aStats[i][key] / 100;
  else
  value = memorymonitor.aStats[i][key];
  
  querysetcell(qStats, key, value);
 }
 // max memory
 if (maxUsedMem lt memorymonitor.aStats[i].usedAllocMem)
 maxUsedMem = memorymonitor.aStats[i].usedAllocMem;
 
 querysetcell(qStats, "maxUsedMem", maxUsedMem);
 
}
</cfscript>

<cfwddx action="cfml2wddx" input="#memorymonitor#" output="wddxMemMonitor" usetimezoneinfo="yes">
<cffile action="write" addnewline="yes" file="#filepath#" output="#wddxMemMonitor#" >
--->

<cffile action="write" addnewline="yes" file="#filepath#" output="#statRec#" >

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="refresh" content="60"> <!--- 60 seconds --->

<title>Memory Usage</title>
</head>
<style type="text/css">
body, td {
 font-size: 10px;
 font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
}
</style>
<body bgcolor="white">

<h2>Current Values</h2>
<table>
<tr>
<td>Free Allocated Memory:</td>
<td>#freeMemory# MB</td>
</tr>
<tr>
<td>Total Memory Allocated:</td>
<td>#totalMemory# MB</td>
</tr>
<tr>
<td>Max Memory Available to JVM:</td>
<td>#maxMemory# MB</td>
</tr>
<tr>
	<!---
<td><strong>Max Memory Used:</strong></td>
<td><strong>#maxUsedMem# MB</strong></td>
--->
</tr>
</table>

<p>From these numbers we can also determine the percent of free allocated memory available, and also the percent of available memory allocated.</p>

<table>
<tr>
<td>% of Free Allocated Memory:</td>
<td>#percentFreeAllocated#%</td>
</tr>
<tr>
<td>% of Available Memory Allocated:</td>
<td>#percentAllocated#%</td>
</tr>
</table>
</cfoutput> 

<!--- 
<hr>

<h2>Historical Values - Memory Usage (Percentage)</h2>
</cfoutput> 

<cfchart format="flash" chartheight="500" chartwidth="750" scalefrom="0" scaleto="1" showxgridlines="yes" showygridlines="yes" gridlines="11" showborder="no" fontbold="no" fontitalic="no" labelformat="percent" xaxistitle="Date Time" yaxistitle="Percentage" show3d="yes" rotated="no" sortxaxis="no" showlegend="yes" showmarkers="no">
<cfchartseries type="line" query="qStats" itemcolumn="datetime" valuecolumn="USEDALLOCMEMPERC" serieslabel="Used Allocated Memory (%)">
<cfchartseries type="line" query="qStats" itemcolumn="datetime" valuecolumn="FREEALLOCMEMPERC" serieslabel="Free Allocated Memory (%)">
<cfchartseries type="line" query="qStats" itemcolumn="datetime" valuecolumn="AVAILALLOCMEMPERC" serieslabel="Available Allocated Memory (%)">
</cfchart>

<cfoutput>
<hr>
<h2>Historical Values - Memory Usage (Megabytes)</h2>
</cfoutput>

<cfchart format="flash" chartheight="500" chartwidth="750" scalefrom="0" scaleto="512" showxgridlines="yes" showygridlines="yes" gridlines="3" showborder="no" fontbold="no" fontitalic="no" xaxistitle="Date Time" yaxistitle="Megabytes" show3d="yes" rotated="no" sortxaxis="no" showlegend="yes" showmarkers="no">
<cfchartseries type="line" query="qStats" itemcolumn="datetime" valuecolumn="USEDALLOCMEM" serieslabel="Used Allocated Memory (MB)">
<cfchartseries type="line" query="qStats" itemcolumn="datetime" valuecolumn="MAXUSEDMEM" serieslabel="Max Used Memory (MB)">
<cfchartseries type="line" query="qStats" itemcolumn="datetime" valuecolumn="FREEALLOCMEM" serieslabel="Free Allocated Memory (MB)">
<cfchartseries type="line" query="qStats" itemcolumn="datetime" valuecolumn="TOTALLOCMEM" serieslabel="Total Allocated Memory (MB)">
<cfchartseries type="line" query="qStats" itemcolumn="datetime" valuecolumn="MAXALLOCMEM" serieslabel="Max Allocated Memory (MB)">
</cfchart>

--->
<cfoutput>
<hr>
<form action="#cgi.SCRIPT_NAME#" method="post">
<input type="submit" name="delete" value="Reset Stats">
</form>

</body>
</html>
</cfoutput>