<cfinclude template="/includes/_header.cfm">
<cfset title="Arctos API">
<cfoutput>
<cfif action is "nothing">
	<h2>
		Partial list of ways to talk to Arctos & Arctos-related products:
	</h2>
	<p>
		You may search specimens using the <a href="/api/specsrch">SpecimenResults.cfm API</a>. 
	</p>
	<p>
		You may open KML files of Arctos data using the <a href="/api/kml">KML API</a>. 
	</p>
	You may link to specimens with any of the following:
		<ul>
			<li>
				#Application.serverRootUrl#/guid/{institution}:{collection}:{catnum}
				<ul>
					<li>
						Example: #Application.serverRootUrl#/guid/UAM:Mamm:1
					</li>
				</ul>
				<br>
			</li>
			<li>
				#Application.serverRootUrl#/specimen/{institution}/{collection}/{catnum}
				<ul>
					<li>
						Example: #Application.serverRootUrl#/specimen/UAM/Mamm/1
					</li>
				</ul>
				<br>
			</li>
			<li>
				#Application.serverRootUrl#/SpecimenDetail.cfm?guid={institution}:{collection}:{catnum}
				<ul>
					<li>
						Example: #Application.serverRootUrl#/SpecimenDetail.cfm?guid=UAM:Mamm:1
					</li>
				</ul>
				<br>
			</li>
		</ul>
	<p>
		You may search taxonomy using the <a href="/api/taxsrch">TaxonomyResults.cfm API</a>. 
	</p>
	<p>
		You may link to taxon detail pages with URLs of the format:
		<ul>
			<li>
				#Application.serverRootUrl#/name/{taxon name}
				<ul>
					<li>
						Example: #Application.serverRootUrl#/name/Alces alces
					</li>
				</ul>
			</li>
		</ul>		
	</p>
</cfif>
<cfif action is "taxsrch">
	Base URL: #Application.serverRootUrl#/TaxonomyResults.cfm
	<table border>
		<tr>
			<th>term</th>
			<th>comment</th>
		</tr>
		<tr>
			<td>common_name</td>
			<td></td>
		</tr>
		<tr>
			<td>scientific_name</td>
			<td></td>
		</tr>
		<tr>
			<td>genus</td>
			<td></td>
		</tr>
		<tr>
			<td>species</td>
			<td></td>
		</tr>
		<tr>
			<td>subspecies</td>
			<td></td>
		</tr>
		<tr>
			<td>full_taxon_name</td>
			<td></td>
		</tr>
		<tr>
			<td>phylum</td>
			<td></td>
		</tr>
		<tr>
			<td>phylclass</td>
			<td></td>
		</tr>
		<tr>
			<td>phylorder</td>
			<td></td>
		</tr>
		<tr>
			<td>suborder</td>
			<td></td>
		</tr>
		<tr>
			<td>family</td>
			<td></td>
		</tr>
		<tr>
			<td>subfamily</td>
			<td></td>
		</tr>
		<tr>
			<td>tribe</td>
			<td></td>
		</tr>
		<tr>
			<td>subgenus</td>
			<td></td>
		</tr>
		<tr>
			<td>author_text</td>
			<td></td>
		</tr>
		<tr>
			<td>we_have_some</td>
			<td>Boolean. True=limits returns to taxonomy that have been used for identifications in Arctos.</td>
		</tr>
	</table>
</cfif>
<cfif action is "specsrch">
	<cfquery name="st" datasource="cf_dbuser">
		select * from cf_search_terms order by term
	</cfquery>
		Base URL: #Application.serverRootUrl#/SpecimenResults.cfm
	<table border>
		<tr>
			<th>term</th>
			<th>display</th>
			<th>values</th>
			<th>comment</th>
		</tr>
		<cfloop query="st">
			<cfif left(code_table,2) is "CT">
				<cftry>
				<cfquery name="docs" datasource="cf_dbuser">
					select * from #code_table#
				</cfquery>
				<cfloop list="#docs.columnlist#" index="colName">
					<cfif #colName# is not "COLLECTION_CDE" and #colName# is not "DESCRIPTION">
						<cfset theColumnName = #colName#>
					</cfif>
				</cfloop>
				<cfquery name="theRest" dbtype="query">
					select #theColumnName# from docs
						group by #theColumnName#
						order by #theColumnName#
				</cfquery>
				<cfset ct="">
				<cfloop query="theRest">
					<cfset ct=ct & evaluate(theColumnName) & "<br>">
				</cfloop>
				<cfcatch>
					<cfset ct="fail: #code_table#: #cfcatch.message# #cfcatch.detail# #cfcatch.sql#">
				</cfcatch>
				</cftry>
			<cfelse>
				<cfset ct=code_table>
			</cfif>
			<tr>				
				<td valign="top">#term#</td>
				<td valign="top">#display#</td>
				<td valign="top">#ct#</td>
				<td valign="top">#definition#</td>
			</tr>
		</cfloop>
	</table>
</cfif>
<cfif action is "kml">
	Base URL: #Application.serverRootUrl#/bnhmMaps/kml.cfm
	<table border>
		<tr>
			<th>Variable</th>
			<th>Values</th>
			<th>Explanation</th>
		</tr>
		
		<tr>
			<td>action</td>
			<td>newReq</td>
			<td>Only acceptable value for webservice calls</td>
		</tr>
		
		<tr>
			<td>{search criteria}</td>
			<td>{various}</td>
			<td><a href="/api/specsrch">API</a></td>
		</tr>
		
		<tr>
			<td>userFileName</td>
			<td>Any string</td>
			<td>Non-default file name. Will be URL-encoded, so use alphanumeric characters for predictability.</td>
		</tr>	
		
		<tr>
			<td rowspan="3">next</td>
			<td>nothing</td>
			<td>Proceed to a form where you may set all other criteria</td>
		</tr>
		<tr>		
			<td>colorByCollection</td>
			<td>Map points are arranged by collection</td>
		</tr>
		<tr>		
			<td>colorBySpecies</td>
			<td>Map points are arranged by collection</td>
		</tr>
		
		<tr>
			<td rowspan="3">method</td>
			<td>download</td>
			<td>Download a full KML file</td>
		</tr>
		<tr>		
			<td>gmap</td>
			<td>Map in Google Maps</td>
		</tr>
		<tr>		
			<td>link</td>
			<td>Download a KML Linkfile</td>
		</tr>
		
		<tr>
			<td rowspan="2">includeTimeSpan</td>
			<td>0</td>
			<td>Do not include time information</td>
		</tr>
		<tr>		
			<td>1</td>
			<td>Include time information</td>
		</tr>
		
		<tr>
			<td rowspan="2">showUnaccepted</td>
			<td>0</td>
			<td>Include only accepted coordinate determinations</td>
		</tr>
		<tr>		
			<td>1</td>
			<td>Include unaccepted coordinate determinations</td>
		</tr>
		
		<tr>
			<td rowspan="2">mapByLocality</td>
			<td>0</td>
			<td>Show only those specimens matching search criteria</td>
		</tr>
		<tr>		
			<td>1</td>
			<td>Include all specimens from each locality</td>
		</tr>
		
		<tr>
			<td rowspan="2">showErrors</td>
			<td>0</td>
			<td>Map points onle</td>
		</tr>
		<tr>		
			<td>1</td>
			<td>Include error radii as circles</td>
		</tr>
		
		<tr>		
			<td>link</td>
			<td>Download a KML Linkfile</td>
		</tr>
	</table>
</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
