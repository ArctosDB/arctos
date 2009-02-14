<cfinclude template = "includes/_header.cfm">
<cfset title = "Publication Search Results">

<cfset uName = "getPubs#cfid##cftoken#">
<cfif not isdefined("newQuery")>
	<cfset newQuery = 1>
</cfif>
<cfif not isdefined("toproject_id")>
	<cfset toproject_id = -1>
</cfif>
<cfif #newQuery# is 1>
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
			agent_name,
			formatted_publication,
			publication_url">
		<cfset basWhere = "
		WHERE 
		publication.publication_id = project_publication.publication_id (+) 
		AND publication.publication_id = publication_author_name.publication_id (+) 
		AND publication_author_name.agent_name_id = agent_name.agent_name_id (+)
		AND formatted_publication.publication_id (+) = publication.publication_id 
		AND formatted_publication.format_style = 'full citation'
		AND publication.publication_id = publication_url.publication_id (+)">
		
	<cfif isdefined("pubTitle") AND len(#pubTitle#) gt 0>
		<cfset basWhere = "#basWhere# AND UPPER(publication_title) LIKE '%#ucase(pubTitle)#%'">
	</cfif>
	<cfif isdefined("onlyCitePubs") AND #onlyCitePubs# gt 0>
		<cfif #basFrom# does not contain "citation">
			<cfset basFrom = "#basFrom#,citation">
		</cfif>
		<cfset basWhere = "#basWhere# AND publication.publication_id = citation.publication_id">
	</cfif>
	<cfif isdefined("pubAuthor") AND len(#pubAuthor#) gt 0>
		<cfset pubAuthor = #replace(pubAuthor,"'","''","all")#>
		<cfset basWhere = "#basWhere# AND UPPER(agent_name) LIKE '%#ucase(pubAuthor)#%'">
	</cfif>
	<cfif isdefined("publication_author_id") AND len(#publication_author_id#) gt 0>
		<cfset basWhere = "#basWhere# AND publication_author_name.agent_name_id IN (#publication_author_id#)">
	</cfif>
	<cfif isdefined("pubYear") AND len(#pubYear#) gt 0>
		<cfset basWhere = "#basWhere# AND UPPER(PUBLISHED_YEAR) LIKE '%#ucase(pubYear)#%'">
	</cfif>
	<cfif isdefined("publication_id") AND len(#publication_id#) gt 0>
		<cfset basWhere = "#basWhere# AND publication.publication_id = #publication_id#">
	</cfif>
	<cfif isdefined("current_Sci_Name") AND len(#current_Sci_Name#) gt 0>
		<cfset basFrom = "#basFrom# ,
			citation CURRENT_NAME_CITATION, 
			cataloged_item,
			identification catItemTaxa">
		<cfset basWhere = "#basWhere# AND publication.publication_id = CURRENT_NAME_CITATION.publication_id (+)
		AND CURRENT_NAME_CITATION.collection_object_id = cataloged_item.collection_object_id (+)
		AND cataloged_item.collection_object_id = catItemTaxa.collection_object_id
		AND catItemTaxa.accepted_id_fg = 1
		AND upper(catItemTaxa.scientific_name) LIKE '%#ucase(current_Sci_Name)#%'">
	</cfif>
	<cfif isdefined("cited_Sci_Name") AND len(#cited_Sci_Name#) gt 0>
		<cfset basFrom = "#basFrom# ,
			citation CITED_NAME_CITATION, taxonomy CitTaxa">
			<cfset basWhere = "#basWhere# AND publication.publication_id = CITED_NAME_CITATION.publication_id (+)
				AND CITED_NAME_CITATION.cited_taxon_name_id = CitTaxa.taxon_name_id (+)
				AND upper(CitTaxa.scientific_name) LIKE '%#ucase(cited_Sci_Name)#%'">
	</cfif>
	<cfif isdefined("journal_name") AND len(#journal_name#) gt 0>
		<cfif #jnOper# is "LIKE">
			<cfset jname="'%#ucase(journal_name)#%'">
		<cfelse>
			<cfset jname = "'#ucase(journal_name)#'">
		</cfif>
		<cfset basFrom = "#basFrom# ,
			journal, journal_article">
		<cfset basWhere = "#basWhere# AND publication.publication_id = journal_article.publication_id 
			AND journal_article.journal_id = journal.journal_id AND
			upper(journal_name) #jnOper# #jname#">
	</cfif>
	<cfif isdefined("collection_id") AND len(#collection_id#) gt 0>
		<cfset basFrom = "#basFrom#,cataloged_item">
		<cfif #basFrom# does not contain "citation">
			<cfset basFrom = "#basFrom#,citation">
		</cfif>
		<cfset basWhere = "#basWhere# AND publication.publication_id = citation.publication_id 
			AND citation.collection_object_id = cataloged_item.collection_object_id AND
			cataloged_item.collection_id = #collection_id#">
	</cfif>
	
	
	<cfset basSql = "#basSQL# #basFrom# #basWhere# ORDER BY publication.publication_id">
	
	<cfquery name="getPubs#cfid##cftoken#" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,0,0)#">
		#preservesinglequotes(basSQL)#
	</cfquery>
	
	<cfquery name="getPubs#cfid##cftoken#" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,60,0)#">
		#preservesinglequotes(basSQL)#
	</cfquery>
	<cfset newQuery=0>
<cfset newSearch = 1><!---- assign a variable that says we've destroyed the cached query
	and should destroy the cache of it used to navigate pages ---->
<!---- kill the cached query since we're in the newquery loop ---->
</cfif>
<cfif isdefined("newSearch") and #newSearch# is 1>
<cfquery name="#uName#" dbtype="query" cachedwithin="#createtimespan(0,0,0,0)#">
	select * from getPubs#cfid##cftoken#
</cfquery>
</cfif>
<cfquery name="#uName#" dbtype="query" cachedwithin="#createtimespan(0,0,60,0)#">
	select * from getPubs#cfid##cftoken#
</cfquery>

<cfquery name="getPubs" dbtype="query">
	select * from getPubs#cfid##cftoken#
</cfquery>

<cfquery name="count" dbtype="query">
	select distinct(publication_id) from getPubs
</cfquery>
<cfparam name="StartRow" default="1">
<CFSET ToRow = StartRow + (session.DisplayRows - 1)>
<CFIF ToRow GT count.RecordCount>
	<CFSET ToRow = count.RecordCount>
</CFIF><CFOUTPUT>
	<P>
		<H4>
			Displaying records #StartRow# - #ToRow# from the #count.RecordCount# 
			total records that matched your criteria.
		</H4>
</CFOUTPUT>
<form name="form2">
	 <!--- update the values for the next and previous rows to be returned --->
	<CFSET Next = StartRow + session.DisplayRows>
	<CFSET Previous = StartRow - session.DisplayRows>
	<cf_log cnt=#count.RecordCount# coll=na>	 
	<!--- Create a previous records link if the records being displayed aren't the
		  first set --->	
	<table>
	
	<CFOUTPUT>
	  <tr>
	 
		<td><CFIF Previous GTE 1>
				
<form name="form3" action="PublicationResults.cfm">
				
				<input name="toproject_id" type="hidden" value="#toproject_id#">
				<input type="submit" 
					value="Previous #session.DisplayRows# Records" 
					class="lnkBtn"
					onmouseover="this.className='lnkBtn btnhov'" 
					onmouseout="this.className='lnkBtn'">
			
				<input name="StartRow" type="hidden" value="#Previous#">
				<input name="NewQuery" type="hidden" value="0">
				<input name="displayRows" type="hidden" value="#session.DisplayRows#">
				</form>
	</CFIF></td>
		<td><!--- Create a next records link if there are more records in the record set 
		  that haven't yet been displayed. --->
	<CFIF Next LTE getPubs.RecordCount>
				<form name="form4" action="PublicationResults.cfm">
				<input type="submit" 
					value="Next #session.DisplayRows# Records" 
					class="lnkBtn"
					onmouseover="this.className='lnkBtn btnhov'" 
					onmouseout="this.className='lnkBtn'">
				<input name="StartRow" type="hidden" value="#Next#">
				<input name="toproject_id" type="hidden" value="#toproject_id#">
				<input name="NewQuery" type="hidden" value="0">
				<input name="session.displayRows" type="hidden" value="#session.DisplayRows#">
				</form>
	</CFIF>
	</td>
	  </tr>
	  </CFOUTPUT>
	</table>
</form>
<table border="1">
	<cfoutput query="getPubs"  StartRow="#StartRow#" MaxRows="#session.DisplayRows#" group="publication_id">
		<tr #iif(currentrow MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
			<td valign="top">
				<table>
					<form action="ProjectList.cfm?src=pubs" method="post">
							<input name="toproject_id" type="hidden" value="#toproject_id#">
							<input name="Action" type="hidden">
							<input type="hidden" name="publication_id" value="#publication_id#">
					<tr valign="top">
						<td valign="top">							
							<input type="submit" 
									value="Projects" 
									class="lnkBtn"
									onmouseover="this.className='lnkBtn btnhov'" 
									onmouseout="this.className='lnkBtn'">
						</td>
					</tr>
					</form>
					<form action="SpecimenResults.cfm" method="post">
							<input name="Action" type="hidden">
							<input name="toproject_id" type="hidden" value="#toproject_id#">
							<input type="hidden" name="publication_id" value="#publication_id#">
					<tr>
						<td valign="top">
							
							<input type="submit" 
									value="Cited Specimens" 
									class="lnkBtn"
									onmouseover="this.className='lnkBtn btnhov'" 
									onmouseout="this.className='lnkBtn'">
						</td>
						</tr>
						</form>
						<cfif #toproject_id# gt 0>
						<form action="Project.cfm" method="post">
							<input name="project_id" type="hidden" value="#toproject_id#">
							<input type="hidden" name="Action" value="addPub">
							<input type="hidden" name="publication_id" value="#publication_id#">
						<tr>
						<td valign="top">
							<input type="submit" 
									value="Add to Project" 
									class="lnkBtn"
									onmouseover="this.className='lnkBtn btnhov'" 
									onmouseout="this.className='lnkBtn'">
						</td>
					</tr>
					</form>
					</cfif>
					<cfif  isdefined("session.roles") and listfindnocase(session.roles,"MANAGE_PUBLICATIONS")>
						<form action="Publication.cfm" method="post">
									<input type="hidden" name="publication_id" value="#publication_id#">
										<cfif #publication_type# is "Book">
											<cfset thisAction = "editBook">
										  <cfelseif #publication_type# is "Book Section">
										  	<cfset thisAction = "editBookSection">
										  <cfelseif #publication_type# is "Journal Article">
										  		<cfset thisAction = "editJournalArt">	
										</cfif>
									<input  type="hidden" name="Action" value="#thisAction#">
						<tr>
							<td valign="top">
								<input type="submit" 
										value="Edit Publication" 
										class="lnkBtn"
										onmouseover="this.className='lnkBtn btnhov'" 
										onmouseout="this.className='lnkBtn'">
								
							</td>
						</tr>
						</form>
						<form action="Citation.cfm" method="post">
									<input type="hidden" name="publication_id" value="#publication_id#">
						<tr>
							<td valign="top">
								
									<input type="submit" 
										value="Manage Citations" 
										class="lnkBtn"
										onmouseover="this.className='lnkBtn btnhov'" 
										onmouseout="this.className='lnkBtn'">
								
							</td>
						</tr>
					</form>
					</cfif>
				</table>
			</td>
			<td>
				#formatted_publication#
				<cfquery name="links" dbtype="query">
					select link, description from getPubs where publication_id = #publication_id#
					group by link, description
				</cfquery>
				<cfif len(#links.description#) gt 0>
					<blockquote>
					Links:
					<ul>
					<cfloop query="links">
					  <li><a href="#link#" target="_blank">#description#</a></li>
					</cfloop>
					</ul>
					</blockquote>
				</cfif>
				
			</td>
		</tr>
	</cfoutput>	
</table>

<form name="form2">
	 <!--- update the values for the next and previous rows to be returned --->
	<CFSET Next = StartRow + session.DisplayRows>
	<CFSET Previous = StartRow - session.DisplayRows>	 
	<!--- Create a previous records link if the records being displayed aren't the
		  first set --->	
	<table>
	<CFOUTPUT>
	  <tr>
		<td><CFIF Previous GTE 1>
				<form name="form3" action="PublicationResults.cfm">
				
				<input type="submit" 
					value="Previous #session.DisplayRows# Records" 
					class="lnkBtn"
					onmouseover="this.className='lnkBtn btnhov'" 
					onmouseout="this.className='lnkBtn'">
				<input name="StartRow" type="hidden" value="#Previous#">
				<input name="NewQuery" type="hidden" value="0">
				<input name="displayRows" type="hidden" value="#session.DisplayRows#">
				</form>
	</CFIF></td>
		<td><!--- Create a next records link if there are more records in the record set 
		  that haven't yet been displayed. --->
	<CFIF Next LTE getPubs.RecordCount>
				<form name="form4" action="PublicationResults.cfm">
				
				<input type="submit" 
					value="Next #session.DisplayRows# Records" 
					class="lnkBtn"
					onmouseover="this.className='lnkBtn btnhov'" 
					onmouseout="this.className='lnkBtn'">
				<input name="StartRow" type="hidden" value="#Next#">
				<input name="NewQuery" type="hidden" value="0">
				<input name="session.displayRows" type="hidden" value="#session.DisplayRows#">
				</form>
	</CFIF>
	</td>
	  </tr>
	  </CFOUTPUT>
	</table>
</form>

	<cf_getSearchTerms>
	<cfset log.query_string=returnURL>
	<cfset log.reported_count = #count.RecordCount#>
	<cfinclude template="/includes/activityLog.cfm">
<cfinclude template = "includes/_footer.cfm">
