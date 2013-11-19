<cfinclude template="/includes/_header.cfm">
<cfif not FileExists("#Application.webDirectory#/log/request.txt")> 
	    <cffile action="write" file="#Application.webDirectory#/log/request.txt" output=""> 
	</cfif>
<cfinclude template="/includes/_footer.cfm">

