<!--- exclude UAM Mammals users --->
<cfif session.portal_id is 1 or session.username is "pub_usr_uam_mamm" or session.username is 'lolson'>
	<cfabort>
</cfif>
	<!---- <cftry>
---->
<cfif session.block_suggest neq 1>
	<cfquery name="links" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" >
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