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

	<cfloop query="unhandled">
		<cffile action="DELETE" file="#Application.webDirectory#/Reports/templates/#name#">
	</cfloop>

</cfif>
<cfif action is "emailNotifyNotUsed">

	<!-----
		find reports which haven't been accessed in 6 months
		on all 6-month anniversaries of last access
	---->
	<cfoutput>
		<cfset ndays="0">
		<cfset alist="">
		<cfloop from="1" to="10" index="i">
			<!--- 5 years is probably enough.... ---->
			<cfset ndays=ndays+180>
			<cfset alist=listappend(alist, ndays)>
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
		<cfif orphan.recordcount lt 1>
			<!--- save some processors ---->
			<cfabort>
		</cfif>
		<cfsavecontent variable="emailFooter">
			<div style="font-size:smaller;color:gray;">
				--
				<br>Don't want these messages? Update Collection Contacts.
				<br>Want these messages? Update Collection Contacts, make sure you have a valid email address.
				<br>Links not working? Log in, log out, or check encumbrances.
				<br>Need help? Send email to arctos.database@gmail.com
			</div>
		</cfsavecontent>
		<cfquery name="cc" datasource="uam_god">
			select
				get_address(collection_contacts.CONTACT_AGENT_ID,'email') address
			FROM
				collection_contacts
			where
				collection_contacts.contact_role='data quality'
			group by
				get_address(collection_contacts.CONTACT_AGENT_ID,'email')
		</cfquery>
		<cfif isdefined("Application.version") and  Application.version is "prod">
			<cfset maddr=valuelist(cc.ADDRESS)>
			<cfset subj="Potential Unused Reports">
		<cfelse>
			<cfset maddr=application.bugreportemail>
			<cfset subj="TEST PLEASE IGNORE: Potential Unused Reports">
		</cfif>
		<cfmail to="#maddr#" bcc="#Application.LogEmail#" subject="#subj#" from="report_report@#Application.fromEmail#" type="html">
			<p>
				The following Reports have not been accessed recently. Please delete the handlers (which will auto-delete the template)
				if they are no longer needed.
			</p>
			<cfloop query="orphan">
				<p>
					<a href="#Application.serverRootURL#/Reports/reporter.cfm?action=edit&report_id=#report_id#">
						#REPORT_TEMPLATE# - #REPORT_NAME#
					</a> (#days_since_access# days since last access)
				</p>
			</cfloop>
			#emailFooter#
		</cfmail>
	</cfoutput>
</cfif>