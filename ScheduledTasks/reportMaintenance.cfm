<cfif not isdefined("action")>
	<cfabort>
</cfif>
<cfif action is "deleteUnused">
<!---
	DELETE reports with no handlers which are 3 days old.
	Run this every few days or something
 ---->
 <cfdirectory action="list" directory="#Application.webDirectory#/Reports/templates" filter="*.cfr" name="reportList" sort="name ASC">
	<!--- all reports ---->
	<cfquery name="allreports" datasource="uam_god">
		select
			REPORT_TEMPLATE
		from
			cf_report_sql
	</cfquery>

	<!---- all reports without handlers that are at least 3 days old ---->
	<cfquery name="unhandled" dbtype="query">
		select name from reportList where #dateDiff('d',reportList.DATELASTMODIFIED,now())# > 3
		and upper(NAME) not in (#listqualify(ucase(valuelist(allreports.REPORT_TEMPLATE)),"'")#)
	</cfquery>

	<cffile action="DELETE" file="#Application.webDirectory#/Reports/templates/#name#">

</cfif>
<cfif action is "emailNotifyNotUsed">
	<!-----
		find reports which haven't been accessed in 6 months
		on all 6-month anniversaries of last access
	---->
	<cfset ndays="0">
	<cfset alist="">
	<cfloop from="1" to="10" index="i">
		<!--- 5 years is probably enough.... ---->
		<cfset tv=ndays+180>
		<cfset alist=listappend(alist, tv)>
	</cfloop>
	<cfquery name="orphan" datasource="uam_god">
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
		where
			round(sysdate-last_access) in (#alist#)
	</cfquery>
	<cfdump var=#orphan#>


</cfif>

<cfif action is "emailArchive">
	<!---
		email everything to the Google account.
		Run this weekly or so
	---->
	<cfoutput>
#application.logemail#
		<cfmail to="#application.logemail#" subject="CFR Archive" from="cfr_archive@#Application.fromEmail#" type="html">
			test
		</cfmail>



	 <cfdirectory action="list" directory="#Application.webDirectory#/Reports/templates" filter="*.cfr" name="reportList" sort="name ASC">

	 <cfdump var=#reportList#>


<cfmail to="#application.logemail#" subject="CFR Archive" from="cfr_archive@#Application.fromEmail#" type="html">
		The following report templates exist as of #now()#
		<cfloop query="reportList">
			<cfmailparam file = "#Application.webDirectory#/Reports/templates/#name#" type="text/plain">
		</cfloop>
	</cfmail>





</cfoutput>
<!----

---->
</cfif>