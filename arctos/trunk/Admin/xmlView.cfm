<cffile action="read" file="#Application.webDirectory#/log/#log#.txt" variable="logtxt">
<cfoutput>
<logs>#logtxt#</logs>
</cfoutput>