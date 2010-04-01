<!--- 
	cleans up temp files more than 3 days old
	Run daily
 --->
<cfoutput>
<!---- berkeleymapper tabfiles more than 3 days ---->
<CFDIRECTORY ACTION="List" DIRECTORY="#Application.webDirectory#/bnhmMaps/tabfiles/" NAME="dir_listing"> 
	<cfloop query="dir_listing">
		<cfif (dateCompare(dateAdd("d",3,datelastmodified),now()) LTE 0) and left(name,1) neq "."
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
</cfoutput>