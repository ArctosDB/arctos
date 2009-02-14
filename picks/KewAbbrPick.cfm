<cfinclude template="../includes/_pickHeader.cfm">
<cfset title = "Kew Abbr. Pick">
	<cfoutput>
 <cfif not isdefined("tgt")><cfset tgt="author_text"></cfif>
<!--- build an agent id search --->
<form name="searchForAgent" action="KewAbbrPick.cfm" method="post">
	<input type="hidden" name="search" value="true">
	<input type="hidden" name="tgt" value='#tgt#'>
	<br>Name: <input type="text" name="agentname">
	<br>
	 <input type="submit" value="Find Matches" class="schBtn"
   onmouseover="this.className='schBtn btnhov'" onmouseout="this.className='schBtn'">
</form>
<cfif isdefined("search") and #search# is "true">
	<!--- make sure we're searching for something --->
	<cfif len(#agentname#) is 0>
		You must enter search criteria.
		<cfabort>
	</cfif>

		<cfquery name="getAgentId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT kewAbbr.agent_name agent_name FROM
			agent_name,
			agent_name kewAbbr
			where 
			agent_name.agent_id = kewAbbr.agent_id and
			upper(agent_name.agent_name) like '%#ucase(agentname)#%' and
			kewAbbr.agent_name_type='Kew abbr.'
			group by kewAbbr.agent_name
		</cfquery>

	<cfloop query="getAgentId">
		
<a href="##" onClick="javascript: opener.document.taxa.#tgt#.value='#agent_name#';self.close();">#agent_name#</a><br>
</cfloop>
</cfif>
</cfoutput>
<cfinclude template="../includes/_pickFooter.cfm">