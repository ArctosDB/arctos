<cfinclude template="/includes/_header.cfm">
<cfset title="Arctos API">
<cfoutput>
<cfif action is "nothing">
	<h2>
		Partial list of ways to talk to Arctos.
	</h2>
	<p>
		 <a href="/contact.cfm?ref=api">Contact us</a> for help or additional access.
	</p>
	<p>
		You may search specimens using the <a href="/api/specsrch">SpecimenResults.cfm API</a>.
	</p>
	<p>
		You may open KML files of Arctos data using the <a href="/api/kml">KML API</a>.
	</p>
	You may link to specimens with the following:
		<ul>
			<li>
				#Application.serverRootUrl#/guid/{guid_prefix}:{catnum}
				<ul>
					<li>
						Example: #Application.serverRootUrl#/guid/UAM:Mamm:1
					</li>
				</ul>
				<br>
			</li>
		</ul>
	or through Saved Searches (find specimens, click Save Search, provide a name, then click My Stuff/Saved Searches, then
	copy/paste/email/click the links.)
	<p>
		You may search taxonomy using the <a href="/api/taxsrch">taxonomy.cfm API</a>.
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
	<p>
		You may search Media using the <a href="/api/mediasrch">MediaSearch.cfm API</a>
	</p>
	<p>
		You may access DWC-format data at <a href="http://ipt.vertnet.org" target="_blank" class="external">http://ipt.vertnet.org</a>
	</p>
	<p>
		You may link to specific <a href="/api/collections">collection's portals</a>.
	</p>
</cfif>
<cfif action is "collections">
	<p>
		Specimen data in Arcto is segregated into Virtual Private Databases. The default public user has
		access to all portals (all collections) simultaneously. It is also possible to form URLs specific to
		individual portals.
	</p>
	You may redirect users (those without overriding login preferences) to a specific "portal" by using the links from
	<a href="/home.cfm">#Application.serverRootUrl#/home.cfm</a>
	<p>
		Generally, all collections have a portal of the format
		<ul>
			<li>
				#Application.serverRootUrl#/{guid_prefix, with colon replaced by underbar}
				<ul>
					<li>
						Example: #Application.serverRootUrl#/uam_mamm
					</li>
				</ul>
			</li>
		</ul>
	</p>
	A few "composite portals" also exist. For example, #Application.serverRootUrl#/mvz_all access all MVZ collections
	in Arctos.
	<p>
		The default all-access portal is #Application.serverRootUrl#/all_all
	</p>
</cfif>

<cfif action is "mediasrch">
	Base URL: #Application.serverRootUrl#/MediaSearch.cfm?action=search
	<table border>
		<tr>
			<th>term</th>
			<th>values</th>
			<th>comment</th>
		</tr>
		<tr>
			<td>media_uri</td>
			<td>&nbsp;</td>
			<td>substring match on URI where Media is stored</td>
		</tr>
		<cfquery name="ct" datasource="cf_dbuser">
			select media_type data from ctmedia_type order by media_type
		</cfquery>
		<tr>
			<td>media_type</td>
			<td>#valuelist(ct.data,"<br>")#</td>
			<td>&nbsp;</td>
		</tr>
		<cfquery name="ct" datasource="cf_dbuser">
			select mime_type data from ctmime_type order by mime_type
		</cfquery>
		<tr>
			<td>mime_type</td>
			<td>#valuelist(ct.data,"<br>")#</td>
			<td>&nbsp;</td>
		</tr>
		<cfquery name="ct" datasource="cf_dbuser">
			select media_relationship data from ctmedia_relationship order by media_relationship
		</cfquery>
		<tr>
			<td>relationship</td>
			<td>#valuelist(ct.data,"<br>")#</td>
			<td>substring searches are supported</td>
		</tr>
		<tr>
			<td>related_to</td>
			<td>&nbsp;</td>
			<td>
				Display value of relationship. Examples include:
				<ul>
					<li><strong>MVZ Birds 182924 (Buteogallus anthracinus anthracinus)</strong> (cataloged_item)</li>
					<li><strong>Stan Moore</strong> (agent)</li>
					<li><strong>North America, United States, California, Alameda County: STRAWBERRY CANYON, BERKELEY</strong> (locality)</li>
					<li><strong>A molecular view of pinniped relationships with particular emphasis on the true seals.</strong> (project)</li>
				</ul>
			</td>
		</tr>
		<cfquery name="ct" datasource="cf_dbuser">
			select media_label data from ctmedia_label order by media_label
		</cfquery>
		<tr>
			<td>label</td>
			<td>#valuelist(ct.data,"<br>")#</td>
			<td>substring searches are supported</td>
		</tr>
		<tr>
			<td>label_value</td>
			<td>&nbsp;</td>
			<td>
				Display value of label. Examples include:
				<ul>
					<li><strong>10 Jul 2007</strong> (made date)</li>
					<li><strong>prepared specimen</strong> (subject)</li>
					<li><strong>5000</strong> (image number)</li>
				</ul>
			</td>
		</tr>
	</table>
</cfif>
<cfif action is "taxsrch">
	Base URL: #Application.serverRootUrl#/taxonomy.cfm
	<p>
		Accepted Variables
	</p>
	<table border>
		<tr>
			<th>term</th>
			<th>comment</th>
		</tr>
		<tr>
			<td>taxon_name</td>
			<td>Formal taxon name available for use in identifications.</td>
		</tr>
		<tr>
			<td>taxon_term</td>
			<td>Any term from metadata. Author, kingdom, etc.</td>
		</tr>
		<tr>
			<td>term_type</td>
			<td>
				Rank of term. Local terms are controlled by a
				<a href="/info/ctDocumentation.cfm?table=CTTAXON_TERM">Code-Table</a>;
				those imported from GlobalNames are any string.
			</td>
		</tr>
		<tr>
			<td>source</td>
			<td>
				Includes both <a href="/info/ctDocumentation.cfm?table=CTTAXONOMY_SOURCE">local sources</a> and
				<a href="http://resolver.globalnames.org/data_sources" target="_blank" class="external">GlobalNames sources</a>

			</td>
		</tr>
		<tr>
			<td>common_name</td>
			<td>
				Any recorded "common" name.
			</td>
		</tr>
	</table>



</cfif>
<cfif action is "specsrch">
	<script src="/includes/sorttable.js"></script>
	<cfif isdefined("session.roles") and listfindnocase(session.roles,'manage_documentation')>
		<cfset mdoc=true>
	<cfelse>
		<cfset mdoc=false>
	</cfif>
	<cfquery name="st" datasource="cf_dbuser">
		select * from ssrch_field_doc where SPECIMEN_QUERY_TERM=1 order by cf_variable
	</cfquery>
	Base URLs:
	<ul>
		<li>#Application.serverRootUrl#/SpecimenResults.cfm = HTML</li>
		<li>#Application.serverRootUrl#/SpecimenResultsJSON.cfm = JSON</li>
		<li>#Application.serverRootUrl#/SpecimenResultsJSON.cfm?gocsv=true = CSV</li>
		<li>#Application.serverRootUrl#/SpecimenResultsJSON.cfm?goxml=true = XML</li>
	</ul>

	<table border id="t" class="sortable">
		<tr>
			<th>term</th>
			<th>display</th>
			<th>values</th>
			<th>definition</th>
			<th>documentation</th>
			<th>searchhint</th>
		</tr>
		<cfoutput>
			<cfloop query="st">
				<tr>
					<td valign="top">
						<cfif mdoc>
							<a href="/doc/field_documentation.cfm?cf_variable=#CF_VARIABLE#">#CF_VARIABLE#</a>
						<cfelse>
							#CF_VARIABLE#
						</cfif>
					</td>
					<td valign="top">#DISPLAY_TEXT#</td>
					<td valign="top">
						<cfif left(CONTROLLED_VOCABULARY,2) is "ct">
							<a href="/info/ctDocumentation.cfm?table=#CONTROLLED_VOCABULARY#">#CONTROLLED_VOCABULARY#</a>
						<cfelse>
							#CONTROLLED_VOCABULARY#
						</cfif>
					</td>
					<td valign="top">#definition#</td>
					<td valign="top">
						<cfif len(DOCUMENTATION_LINK) gt 0>
							<a href="#DOCUMENTATION_LINK#">#DOCUMENTATION_LINK#</a>
						</cfif>
					</td>
					<td valign="top">#SEARCH_HINT#</td>
				</tr>
			</cfloop>
		</cfoutput>
	</table>
</cfif>
<cfif action is "kml">
	Base URL: #Application.serverRootUrl#/bnhmMaps/kml.cfm?action=newReq
	<table border>
		<tr>
			<th>Variable</th>
			<th>Values</th>
			<th>Explanation</th>
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
			<td>Map points only</td>
		</tr>
		<tr>
			<td>1</td>
			<td>Include error radii as circles</td>
		</tr>
	</table>
</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">