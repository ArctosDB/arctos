<cfinclude template="/includes/_header.cfm">
	<form name="s" method="post" action="veritySearch.cfm">
		<input type="hidden" name="action" value="showResults">
		Search 
		<select name="cats" size="1">
			<option value="">All</option>
			<option value="specimen">Specimens</option>
			<option value="publication">Publications</option>
			<option value="project">Projects</option>
		</select>
		for
		<input type="text"  name="criteria" size="50" maxLength="50">
		<input type="submit" value="Search" class="schBtn"
   onmouseover="this.className='schBtn btnhov'" onmouseout="this.className='schBtn'">
   <cfif isdefined("criteria") and len(#criteria#) gt 0>
   		<br>Search within Results?<input type="checkbox" name="searchResults" value="1">
		<cfoutput>
			<input type="hidden" name="oldSearch" value="#criteria#">
		</cfoutput>
   </cfif>
   
   <a href="javascript:void(0);" 
									onClick="getHelp('verity'); return false;">
									<img src="/images/what.gif" border="0"></a>
	</form>
	
	
	<cfif #action# is "showResults">
	<cfif not isdefined("Cats")>
		<cfset cats="">
	</cfif>
	<cfoutput>
	<cfset srch = "">
			   
			   
	<cfif len(#Criteria#) is 0>
		You must enter search terms.
		<cfabort>
	</cfif>
	<cfif isdefined("searchResults") and #searchResults# is 1>
		<cfsearch category="#cats#"
				suggestions="10"
				status="info"
				CONTEXTPASSAGES="1"
				CONTEXTHIGHLIGHTBEGIN="<B STYLE='color: red'>"
				CONTEXTHIGHLIGHTEND="</B>"
				ContextBytes="500"
			   collection="veritysearchdata"
			   name="res"
			   criteria="#Criteria#"
			   		previousCriteria = "#oldSearch#"
			   maxrows="200"
				>
				
			<p>Your search for <b>#criteria#</b> within the results for <strong>#oldSearch#</strong> matched #res.RecordCount# item.</p>
	<cfelse>
		<cfsearch 
				 suggestions="10"
				 category="#cats#"
				status="info"
				CONTEXTPASSAGES="1"
				CONTEXTHIGHLIGHTBEGIN="<B STYLE='color: red'>"
				CONTEXTHIGHLIGHTEND="</B>"
				ContextBytes="500"
			   collection="veritysearchdata"
			   name="res"
			   criteria="#Criteria#"
			   maxrows="200"
				>
			<p>Your search for <b>#criteria#</b> matched #res.RecordCount# item.
			</p>
	</cfif>
	 <cfif info.FOUND LT 10 AND isDefined("info.SuggestedQuery")>
   <p> <strong>Did you mean: <a href="veritySearch.cfm?criteria=#info.SuggestedQuery#&action=showResults&cats=#cats#">#info.SuggestedQuery#</a></p></strong>
  </cfif>
</cfoutput>
				<table border>
				<cfoutput query="res">
					<!---
					<cfset thisSummary = replacenocase(#summary#,#criteria#,"<span class='showMe'>#criteria#</span>","all")>
					--->
					<tr>
						<td>
							<cfif listcontains(category,"data")>
								<cfif listcontains(category,"specimen")>
									<a href="/SpecimenDetail.cfm?collection_object_id=#key#">#custom1# #custom2# #custom3#</a>
									<br>#context#
								<cfelseif listcontains(category,"publication")>
									<a href="/PublicationResults.cfm?publication_id=#key#">#custom1#</a>
									<br>#context#
								<cfelseif listcontains(category,"project")>
									<a href="/ProjectDetail.cfm?project_id=#key#">#custom1#</a>
									<br>#context#
								<cfelse>
									-- not data: #category#
									
								</cfif>
							<cfelse>
								-- not data: #category#
							</cfif>
						</td>
					</tr>
					
		</cfoutput>
				</table>
				
	</cfif>
<cfinclude template="/includes/_footer.cfm">
