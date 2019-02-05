<!--- exclude UAM Mammals users --->
<cfif session.portal_id is 1 or session.username is "pub_usr_uam_mamm" or session.username is 'lolson'>
	<cfabort>
</cfif>
	<!---- <cftry>
---->
<cfif session.block_suggest neq 1>
	<cfquery name="links" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" >
		select link,display from (
			select
				link,display
			from
				browse
			 	sample(25)
			 order by
			 	dbms_random.value
			)
		WHERE rownum <= 25
	</cfquery>
	<cfif isdefined("session.roles") and session.roles contains "manage_collection">
		<cfquery name="admlnk" datasource="uam_god" >
			select * from (
				select
					cf_report_cache.GUID_PREFIX,
					cf_report_cache.REPORT_NAME,
					cf_report_cache.REPORT_URL,
					cf_report_cache.REPORT_DESCR,
					cf_report_cache.REPORT_DATE,
					cf_report_cache.SUMMARY_DATA
				from
					cf_report_cache,
					dba_role_privs
				where
					upper(replace(cf_report_cache.guid_prefix,':','_'))=dba_role_privs.GRANTED_ROLE and
					grantee=upper('#session.username#')
				order by
					SYS.DBMS_RANDOM.VALUE
			)
			where rownum <=2
		</cfquery>
		<cfif admlnk.recordcount gt 0>
			<cfset hasAdm=true>
		</cfif>
	</cfif>
	<cfoutput>
		<div id="browseArctos">
			<div class="title">Try something random
			<span class="infoLink" onclick="blockSuggest(1)">Hide This</span></div>
			<ul>
				<cfif hasAdm is true>
					<cfloop query="admlnk">
						<li>
							<a href="#REPORT_URL#">#SUMMARY_DATA#</a>
						</li>
					</cfloop>
				</cfif>
				<li>
					<a href="/SpecimenResults.cfm?month=#datePart('m',now())#&day=#datePart('d',now())#">on this day...</a>
				</li>
				<cfloop query="links">
					<li><a href="#link#">#display#</a></li>
				</cfloop>
			</ul>
		</div>
	</cfoutput>
</cfif>
<!---

<cfcatch>
<!--- not fatal - ignore --->
</cfcatch>
</cftry>

--->