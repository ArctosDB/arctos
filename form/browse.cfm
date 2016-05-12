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
	<cfoutput>
		<div id="browseArctos">
			<div class="title">Try something random
			<span class="infoLink" onclick="blockSuggest(1)">Hide This</span></div>
			<ul>
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