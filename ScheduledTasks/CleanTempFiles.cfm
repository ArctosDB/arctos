<!---
	cleans up temp files more than 3 days old
	Run daily
 --->
<cfoutput>
<!--- reports with no handlers which are 3 days old ---->
 <cfdirectory action="list" directory="#Application.webDirectory#/Reports/templates" filter="*.cfr" name="reportList" sort="name ASC">
	<!--- all reports ---->
	<cfquery name="allreports" datasource="uam_god">
		select
			REPORT_ID,
			REPORT_NAME,
			REPORT_TEMPLATE,
			SQL_TEXT,
			PRE_FUNCTION,
			LAST_ACCESS,
			round(sysdate-last_access) days_since_access
		from
			cf_report_sql
	</cfquery>

	<!---- all reports without handlers that are at least 30 days old ---->
	<cfquery name="unhandled" dbtype="query">
		select name from reportList where #dateDiff('d',reportList.DATELASTMODIFIED,now())# > 3
		and upper(NAME) not in (#listqualify(ucase(valuelist(allreports.REPORT_TEMPLATE)),"'")#)
	</cfquery>

	<cfdump var=#unhandled#>



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
		<cfif type is "file">
	 		<cffile action="DELETE" file="#Application.webDirectory#/download/#name#">
		<cfelse>
			<cfdirectory action="DELETE" recurse="true" directory="#Application.webDirectory#/download/#name#">
		</cfif>
	 </cfif>
</cfloop>
</cfoutput>

<CFDIRECTORY ACTION="List" DIRECTORY="#Application.webDirectory#/temp" NAME="dir_listing">
<cfloop query="dir_listing">
	<cfif dateCompare(dateAdd("d",3,datelastmodified),now()) LTE 0 and left(name,1) neq "."
		and not right(name,4) eq '.cfm'>
		<cfif type is "file">
	 		<cffile action="DELETE" file="#Application.webDirectory#/temp/#name#">
		<cfelse>
			<cfdirectory action="DELETE" recurse="true" directory="#Application.webDirectory#/temp/#name#">
		</cfif>
	 </cfif>
</cfloop>


<CFDIRECTORY ACTION="List" DIRECTORY="#Application.webDirectory#/sandbox" NAME="dir_listing">
<cfloop query="dir_listing">
	<cfif dateCompare(dateAdd("d",3,datelastmodified),now()) LTE 0 and left(name,1) neq ".">
		<cfif type is "file">
	 		<cffile action="DELETE" file="#Application.webDirectory#/sandbox/#name#">
		<cfelse>
			<cfdirectory action="DELETE" recurse="true" directory="#Application.webDirectory#/sandbox/#name#">
		</cfif>
	 </cfif>
</cfloop>

