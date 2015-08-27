<!---
	cleans up temp files more than 3 days old
	Run daily
 --->
<cfoutput>
<!---- berkeleymapper tabfiles more than 7 days ---->
<CFDIRECTORY ACTION="List" DIRECTORY="#Application.webDirectory#/cache/" NAME="dir_listing">
<cfloop query="dir_listing">
	<cfif (dateCompare(dateAdd("d",30,datelastmodified),now()) LTE 0) and left(name,1) neq ".">
	 	<cffile action="DELETE" file="#Application.webDirectory#/cache/#name#">
	 </cfif>
</cfloop>
<CFDIRECTORY ACTION="List" DIRECTORY="#Application.webDirectory#/bnhmMaps/tabfiles/" NAME="dir_listing">
<cfloop query="dir_listing">
	<cfif (dateCompare(dateAdd("d",7,datelastmodified),now()) LTE 0) and left(name,1) neq "."
		and not right(name,4) eq '.cfm'>
	 	<cffile action="DELETE" file="#Application.webDirectory#/bnhmMaps/tabfiles/#name#">
	 </cfif>
</cfloop>
<!---- specimen downloads more than 3 days old ---->
<CFDIRECTORY ACTION="List" DIRECTORY="#Application.webDirectory#/download" NAME="dir_listing">
<cfloop query="dir_listing">
	<cfif dateCompare(dateAdd("d",3,datelastmodified),now()) LTE 0 and left(name,1) neq "."
		and not right(name,4) eq '.cfm'>
	 	<cffile action="DELETE" file="#Application.webDirectory#/download/#name#">
	 </cfif>
</cfloop>
</cfoutput>

<CFDIRECTORY ACTION="List" DIRECTORY="#Application.webDirectory#/temp" NAME="dir_listing">
<cfloop query="dir_listing">
	<cfif dateCompare(dateAdd("d",3,datelastmodified),now()) LTE 0 and left(name,1) neq "."
		and not right(name,4) eq '.cfm'>
	 	<cffile action="DELETE" file="#Application.webDirectory#/temp/#name#">
	 </cfif>
</cfloop>


<CFDIRECTORY ACTION="List" DIRECTORY="#Application.webDirectory#/sandbox" NAME="dir_listing">
<cfloop query="dir_listing">
	<cfif dateCompare(dateAdd("d",3,datelastmodified),now()) LTE 0 and left(name,1) neq ".">
	 	<cffile action="DELETE" file="#Application.webDirectory#/sandbox/#name#">
	 </cfif>
</cfloop>

