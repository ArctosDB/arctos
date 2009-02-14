<cfinclude template = "includes/_header.cfm">

<cfif #action# is "nothing">
<cfset title = "Search for Results">
<!---
<span class="pageHelp">
	<a href="javascript:void(0);" 
		onClick="pageHelp('resultsearch'); return false;"
		onMouseOver="self.status='Click for Results help.';return true;"
		onmouseout="self.status='';return true;"><img src="/images/what.gif" border="0">
	</a>
</span>
--->
<span class="infoLink pageHelp" onclick="pageHelp('resultsearch');">Page Help</span>
<table width="75%">
	<tr valign="top">
	<td width="50%">
	<b><font size="+1">Publication / Project Search</font></b>
	<p>Search for projects and publications using this form. Use the links below to search
	using more criteria:
	
	<ul>
		<li>
			<a href="/ProjectSearch.cfm">Projects</a>
		</li>
		<li>
			<a href="/PublicationSearch.cfm">Publications</a>
		</li>
<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>					
		<form name="adminLinks" method="post" action="SpecimenUsage.cfm">
		
			<li>
				<input type="button" 
					value="New Project" 
					class="lnkBtn"
					onmouseover="this.className='lnkBtn btnhov'" 
					onmouseout="this.className='lnkBtn'"
					onclick="document.location='/Project.cfm?action=makeNew';">
			</li>
			<li>
				<input type="button" 
					value="New Book" 
					class="lnkBtn"
					onmouseover="this.className='lnkBtn btnhov'" 
					onmouseout="this.className='lnkBtn'"
					onclick="document.location='/Publication.cfm?action=newBook';">
			</li>
			<li>
				<input type="button" 
					value="New Journal" 
					class="lnkBtn"
					onmouseover="this.className='lnkBtn btnhov'" 
					onmouseout="this.className='lnkBtn'"
					onclick="document.location='/Publication.cfm?action=newJournal';">
			</li>
			<li>
				<input type="button" 
					value="New Journal Article" 
					class="lnkBtn"
					onmouseover="this.className='lnkBtn btnhov'" 
					onmouseout="this.className='lnkBtn'"
					onclick="document.location='/Publication.cfm?action=newJournalArt';">
			</li>
			<li>
				<input type="button" 
					value="Edit Journal" 
					class="lnkBtn"
					onmouseover="this.className='lnkBtn btnhov'" 
					onmouseout="this.className='lnkBtn'"
					onclick="document.location='/Publication.cfm?action=nothing';">
			</li>
		
		</form>
		
	</cfif>
	</ul>
	
	</td>
	<td>
	<form action="SpecimenUsage.cfm" method="post">
	<input name="action" type="hidden" value="search">

  <table>
  <tr>
    <td align="right">Title:</td>
    <td><input name="p_title" type="text"></td>
  </tr>
  <tr>
    <td align="right">Participant:</td>
    <td><input name="author" type="text"></td>
  </tr>
  <tr>
    <td align="right">Year:</td>
    <td><input name="year" type="text"></td>
  </tr>
  <tr>
    <td align="right">Anything:</td>
    <td><input name="keyword" type="text"></td>
  </tr>
  <tr>
    <td colspan="2" align="center">
		<input type="submit" 
			value="Search" 
			class="schBtn"
			onmouseover="this.className='schBtn btnhov'" 
			onmouseout="this.className='schBtn'">
		<input type="reset" 
			value="Clear Form" 
			class="clrBtn"
			onmouseover="this.className='clrBtn btnhov'" 
			onmouseout="this.className='clrBtn'">
	</td>
  </tr>
</table>
</form>
	</td>
</tr></table>
</center>
</cfif>
<!-------------------------------------------------------------------------------------->
<cfif #action# is "search">
<cfset title = "Usage Search Results">
<!--- first, get projects --->
<cfset sql = "SELECT 
					project.project_id,
					project_name,
					start_date,
					end_date,
					agent_name,
					project_agent_role,
					agent_position
				FROM 
					project,
					project_agent,
					agent_name
				WHERE 
					project.project_id = project_agent.project_id (+) AND 
					project_agent.agent_name_id = agent_name.agent_name_id (+)">
	<cfif isdefined("p_title") AND len(#p_title#) gt 0>
		<cfset sql = "#sql# AND upper(project_name) like '%#ucase(escapeQuotes(p_title))#%'">
	</cfif>
	<cfif isdefined("keyword") AND len(#keyword#) gt 0>
		<cfset sql = "#sql# AND 
			(upper(project_name) like '%#ucase(keyword)#%' 
			OR upper(project_description) like '%#ucase(keyword)#%'
			OR upper(project_remarks) like '%#ucase(keyword)#%') ">
	</cfif>
	<cfif isdefined("author") AND len(#author#) gt 0>
		<cfset sql = "#sql# AND project.project_id IN 
			( select project_id FROM project_agent
				WHERE agent_name_id IN 
					( select agent_name_id FROM agent_name WHERE 
					upper(agent_name) like '%#ucase(author)#%' ))">
			
	</cfif>
	<cfif isdefined("year") AND isnumeric(#year#)>
		<cfset sql = "#sql# AND (
			#year# between to_number(to_char(start_date,'YYYY')) AND to_number(to_char(end_date,'YYYY'))
			)">
	</cfif>
	<cfset sql = "#sql# ORDER BY project_name">
<cftry>
	<cfquery name="projects" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(sql)#
	</cfquery>
	<cfcatch>
		<cfset sql=cfcatch.sql>
		<cfset message=cfcatch.message>
		<cfset queryError=cfcatch.queryError>
		<cf_queryError>
	</cfcatch>
</cftry>
<cfquery name="projNames" dbtype="query">
		SELECT 
			project_id,
			project_name,
			start_date,
			end_date
		FROM
			projects
		GROUP BY
			project_id,
			project_name,
			start_date,
			end_date
		ORDER BY
			project_name
	</cfquery>
<cfoutput>
<center>
<table width="600">
<tr>
	<td colspan="2"><font size="+2"><b>Projects</b></font></td>
</tr>

	<cfset i=1>
	<cfif projNames.recordcount is 0>
		<td colspan="2"><i><font color="##FF0000">&nbsp;&nbsp;&nbsp;No projects matched your criteria.</font></i></td>
	</cfif>
	
	<cfloop query="projNames">
		<cfquery name="thisAuth" dbtype="query">
			SELECT 
				agent_name, 
				project_agent_role 
			FROM 
				projects 
			WHERE 
				project_id = #project_id# 
			GROUP BY 
				agent_name, 
				project_agent_role 
			ORDER BY 
				agent_position
		</cfquery>
		<tr>
			<td>
				<img src="images/nada.gif" width="30">
			</td>
			<td #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>

		<a href="/ProjectDetail.cfm?project_id=#project_id#">
		<div style="text-indent:-2em;padding-left:2em; "><b>
		#project_name#</b></div></a>
		
		
		
		<cfloop query="thisAuth">
			&nbsp;&nbsp;&nbsp;#agent_name# (#project_agent_role#)<br>
		</cfloop>
		&nbsp;&nbsp;&nbsp;#dateformat(start_date,"dd mmm yyyy")# - #dateformat(end_date,"dd mmm yyyy")#
<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>					
			<br>&nbsp;&nbsp;&nbsp;<input type="button" 
					value="Edit" 
					class="lnkBtn"
					onmouseover="this.className='lnkBtn btnhov'" 
					onmouseout="this.className='lnkBtn'"
					onclick="document.location='/Project.cfm?Action=editProject&project_id=#project_id#';">
		</cfif>
		
		</td>
		</tr>
		<cfset i=#i#+1>
	</cfloop>
<!--- publications --->
<cfset basSQL = "SELECT DISTINCT 
			publication.publication_id,
			publication.publication_type,
			formatted_publication,
			description,
			link ">
		<cfset basFrom = "
		FROM 
			publication,
			publication_author_name,
			project_publication,
			agent_name pubAuth,
			agent_name searchAuth,
			formatted_publication,
			publication_url">
		<cfset basWhere = "
		WHERE 
		publication.publication_id = project_publication.publication_id (+) 
		AND publication.publication_id = publication_author_name.publication_id (+) 
		AND publication.publication_id = publication_url.publication_id (+) 
		AND publication_author_name.agent_name_id = pubAuth.agent_name_id (+)
		AND pubAuth.agent_id = searchAuth.agent_id
		AND formatted_publication.publication_id (+) = publication.publication_id 
		AND formatted_publication.format_style = 'full citation'">
		
	<cfif isdefined("p_title") AND len(#p_title#) gt 0>
		<cfset basWhere = "#basWhere# AND UPPER(publication_title) LIKE '%#ucase(escapeQuotes(p_title))#%'">
	</cfif>
	<cfif isdefined("keyword") AND len(#keyword#) gt 0>
		<cfset basWhere = "#basWhere# AND 
			(upper(publication_title) like '%#ucase(keyword)#%' 
			OR upper(publication_remarks) like '%#ucase(keyword)#%') ">
	</cfif>
	<cfif isdefined("author") AND len(#author#) gt 0>
		<cfset author = #replace(author,"'","''","all")#>
		<cfset basWhere = "#basWhere# AND UPPER(searchAuth.agent_name) LIKE '%#ucase(author)#%'">
	</cfif>
	<cfif isdefined("year") AND isnumeric(#year#)>
		<cfset basWhere = "#basWhere# AND PUBLISHED_YEAR = #year#">
	</cfif>
	<cfset basSql = "#basSQL# #basFrom# #basWhere# ORDER BY formatted_publication,publication_id">
<cftry>
	<cfquery name="publication" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(basSQL)#
	</cfquery>
	<cfcatch>
		<cfset sql=cfcatch.sql>
		<cfset message=cfcatch.message>
		<cfset queryError=cfcatch.queryError>
		<cf_queryError>
	</cfcatch>
</cftry>
	<tr>
		<td colspan="2"><font size="+2"><b>Publications</b></font></td>
	</tr>
	<cfif publication.recordcount is 0>
		<td colspan="2"><i><font color="##FF0000">&nbsp;&nbsp;&nbsp;No publications matched your criteria.</font></i></td>
	</cfif>
	<cfquery name="pubs" dbtype="query">
		SELECT
			publication_id,
			publication_type,
			formatted_publication
		FROM
			publication
		GROUP BY
			publication_id,
			publication_type,
			formatted_publication
		ORDER BY
			formatted_publication
	</cfquery>
	<cfloop query="pubs">
	<tr>
		<td>
				<img src="images/nada.gif" width="30">
			</td>
		<td #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
		<p style="text-indent:-2em;padding-left:2em; ">
		#formatted_publication#
		<br><input type="button" 
					value="Details" 
					class="lnkBtn"
					onmouseover="this.className='lnkBtn btnhov'" 
					onmouseout="this.className='lnkBtn'"
					onclick="document.location='/PublicationResults.cfm?publication_id=#publication_id#';">
		<input type="button" 
					value="Cited Specimens" 
					class="lnkBtn"
					onmouseover="this.className='lnkBtn btnhov'" 
					onmouseout="this.className='lnkBtn'"
					onclick="document.location='/SpecimenResults.cfm?publication_id=#publication_id#';">
		<cfif isdefined("session.roles") and listfindnocase(session.roles,"manage_publications")>
			<cfif #publication_type# is "Book">
				<cfset thisAction = "editBook">
		 	<cfelseif #publication_type# is "Book Section">
				<cfset thisAction = "editBookSection">
		  	<cfelseif #publication_type# is "Journal Article">
				<cfset thisAction = "editJournalArt">	
			</cfif>
			<input type="button" 
					value="Edit" 
					class="lnkBtn"
					onmouseover="this.className='lnkBtn btnhov'" 
					onmouseout="this.className='lnkBtn'"
					onclick="document.location='/Publication.cfm?Action=#thisAction#&publication_id=#publication_id#';">
			<input type="button" 
					value="Citations" 
					class="lnkBtn"
					onmouseover="this.className='lnkBtn btnhov'" 
					onmouseout="this.className='lnkBtn'"
					onclick="document.location='/Citation.cfm?publication_id=#publication_id#';">
		</cfif>
		</p>
		<cfquery name="links" dbtype="query">
			select description,
			link from publication
			where publication_id=#publication_id#
		</cfquery>
		<cfif len(#links.description#) gt 0>
			<ul>
				<cfloop query="links">
					<li><a href="#link#" target="_blank">#description#</a></li>
				</cfloop>
			</ul>
		</cfif>
			
		
		
		</td>
	</tr>
	<cfset i=#i#+1>
	</cfloop>
	</table>
</cfoutput>


	<cf_getSearchTerms>
	<cfset log.query_string=returnURL>
	<cfset log.reported_count = #pubs.RecordCount# + #projNames.RecordCount#>
	<cfinclude template="/includes/activityLog.cfm">
</cfif>
<!-------------------------------------------------------------------------------------->
<cfinclude template = "/includes/_footer.cfm">