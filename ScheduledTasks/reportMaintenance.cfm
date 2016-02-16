<cfif action is "deleteUnused">
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
</cfif>