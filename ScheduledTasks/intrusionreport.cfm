<cfset rptprd=1>
<cfset mincount=10>
<cfoutput>
	<cfquery name="d" datasource="uam_god">
			SELECT
			regexp_replace(ip,'^([0-9]{1,3}\.[0-9]{1,3})\..*$','\1') subnet,
			count(*) attempts
		from
			blacklisted_entry_attempt
			where
			to_char(timestamp,'yyyy-mm-dd') >= sysdate-#rptprd#
		having
			count(*) > #mincount#
		group by
			regexp_replace(ip,'^([0-9]{1,3}\.[0-9]{1,3})\..*$','\1')
		 order by
		 	count(*) DESC
	</cfquery>

	<cfif d.recordcount is 0>
		nothing to report<cfabort>
	</cfif>

	<cfquery name="ma" dbtype="query">
		select max(attempts) as mat from d
	</cfquery>
	<cfquery name="sa" dbtype="query">
		select sum(attempts) as sat from d
	</cfquery>
	<cfif sa.sat lt 100>
		<cfset subj='blacklisted entry attempt report (#ma.mat#: #sa.sat#)'>
		<cfset mto=application.logEmail>
		<cfset intro="CHILL: low activity, nothing to worry about here.">
	<cfelseif sa.sat lt 250>
		<cfset subj='IMPORTANT: blacklisted entry attempt report (#ma.mat#: #sa.sat#)'>
		<cfset mto="#application.logEmail#,#Application.bugReportEmail#,#Application.DataProblemReportEmail#">
		<cfset intro="You are receiving this report because increased activity from blocked IP addresses was detected.">
	<cfelse>
		<cfset subj='URGENT: blacklisted entry attempt report (#ma.mat#: #sa.sat#)'>
		<cfset mto="#application.logEmail#,#Application.bugReportEmail#,#Application.DataProblemReportEmail#">
		<cfset intro="You are receiving this report because increased activity from blocked IP addresses was detected.
			Please take immediate action to ensure that the Arctos technical team is aware of this message.">
	</cfif>

	<cfmail subject="#subj#" to="#mto#" from="blacklistreport@#application.fromEmail#" type="html">
		<p>
			#intro#
		</p><p>
			blacklisted_entry_attempt for the last #rptprd# day(s), containing only those subnets originating > #mincount# attempts
		</p>
		<p>
			More info at <a href="#Application.serverRootURL#/info/blacklistattempt.cfm">#Application.serverRootURL#/info/blacklistattempt.cfm</a>
		</p>
		<cfloop query="d">
			<br>#subnet# (attempts: #attempts#)
		</cfloop>
	</cfmail>
</cfoutput>