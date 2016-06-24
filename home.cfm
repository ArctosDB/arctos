<cfset title="Arctos Home">
<cfinclude template="/includes/_header.cfm">
<style>
	 #menu {
		position:fixed;
		top:20%;
		left:0;
		width:6em;
		border:1px solid green;
		padding:1em;
		margin:1em;
		font-size:.8em;
	}
	#stayright{margin-left:12em;}
	.table {display:table;width:100%}
	.tr {display:table-row}
	.td {display:table-cell;}
	.institutiongroup {border:1px dotted green;margin: 1em;padding:1em;}
	.institutionheader {margin:.1em 0em .2em 0em;font-size:2em;font-weight:900;}
	.collectionrow {border:1px dotted black;margin:0em 2em 0em 2em;}
	.widecell{width:70%;}
	.collection_title{font-size:1.3em;}
	.collection_description{font-size:.9em;margin:1em 2em 1em 2em;font-size:.9em;}
	.anchortitle {
		font-weight:bold;
		margin-left:-.8em;
		border-bottom:1px solid black;
	}
	.q {
		font-variant: small-caps;
	}
	.a {
		font-size:smaller;
		margin-bottom:1em;
	}
	@media screen and (max-width: 500px) {
		#menu {
			display:none;
		}
		.browserCheck {font-size:}
		#stayright{margin-left:0em;}
		.institutiongroup {border:1px dotted green;margin: .1em;padding:.1em;}
		.institutionheader {margin:.1em 0em .2em 0em;font-size:1em;font-weight:500;}
		.collectionrow {border:1px dotted black;margin:0em .2em 0em .2em;}
		.collection_title{font-size:1.0em;}
		.table {display:block;}
		.tr {display:block;}
		.td {display:block;}
	}




</style>
<cfoutput>
	<cfquery name="raw" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select
			cf_collection.cf_collection_id,
			cf_collection.collection,
			cf_collection.collection_id,
			cf_collection.descr,
			web_link,
			web_link_text,
			loan_policy_url,
			portal_name,
			count(cat_num) as cnt,
			guid_prefix,
			cf_collection.institution,
			replace(replace(collection.institution_acronym,'Obs'),'UAMb','UAM') institution_acronym,
			CF_COLLECTION.DBUSERNAME,
			CF_COLLECTION.DBPWD
		from
			cf_collection,
			collection,
			cataloged_item
		where
			cf_collection.collection_id=collection.collection_id (+) and
			collection.collection_id=cataloged_item.collection_id (+) and
			cf_collection.PUBLIC_PORTAL_FG = 1
		group by
			cf_collection.cf_collection_id,
			cf_collection.collection,
			cf_collection.collection_id,
			cf_collection.descr,
			web_link,
			web_link_text,
			loan_policy_url,
			portal_name,
			guid_prefix,
			cf_collection.institution,
			replace(replace(collection.institution_acronym,'Obs'),'UAMb','UAM'),
			CF_COLLECTION.DBUSERNAME,
			CF_COLLECTION.DBPWD
	</cfquery>


	<cfquery name="inst" dbtype="query">
		select
			institution,
			institution_acronym
		from
			raw
		where
			institution is not null and
			institution_acronym  is not null
		group by
			institution,
			institution_acronym
		order by
			institution
	</cfquery>
	<cfquery name="insta" dbtype="query">
		select institution_acronym from raw where institution_acronym is not null group by institution_acronym order by institution_acronym
	</cfquery>
	<div id="menu">
		<a href="##top">top</a>
		<div class="anchortitle">Collections</div>
		<cfloop query="insta">
			<br><a href="###institution_acronym#">#institution_acronym#</a>
		</cfloop>
		<div class="anchortitle">Topics</div>
		<br><a href="##features">Features</a>
		<br><a href="##nodes">Nodes</a>
		<br><a href="##participation">Participation</a>
		<br><a href="##requirements">Requirements</a>
		<br><a href="##browser_compatiblity">Browsers</a>
		<br><a href="##data_usage">Usage</a>
		<br><a href="##faq">FAQ</a>
		<br><a href="##suggest">Suggestions</a>
	</div>
	<div id="stayright">
		<a name="top"></a>
		Arctos is an ongoing effort to integrate access to specimen data, collection-management tools, and external resources on the internet.
		Read more about Arctos at our <a href="https://arctosdb.wordpress.com/">Documentation Site</a>, explore some <a href="/random.cfm">random content</a>,
		or use the links in the header to search for specimens, media, taxonomy, projects and publications, and more. Sign in or create an account to save
		preferences and searches.
		<cfquery name="summary" dbtype="query">
			select
				sum(cnt) as total_specimens,
				count(guid_prefix) as numCollections
			 from raw
		</cfquery>
		<p>
			Arctos is currently #numberformat(summary.total_specimens,"999,999")# specimens and observations in #summary.numCollections# collections.
			<p>
				<b>
					Following the search links below will set your preferences to filter by a specific collection or portal. You may click
					<a href="/all_all">[ search all collections ]</a> at any time to re-set your preferences.
				</b>
			</p>
		</p>
		<cfloop query="inst">
			<cfquery name="coln" dbtype="query">
				select * from raw where collection_id is not null and institution<cfif len(institution) is 0> is null <cfelse> ='#institution#'</cfif> order by collection
			</cfquery>
			<cfquery name="coln_portals" dbtype="query">
				select * from raw where collection_id is null and institution<cfif len(institution) is 0> is null <cfelse> ='#institution#'</cfif> order by collection
			</cfquery>
			<a name="#institution_acronym#"></a>
			<div class="institutiongroup">
				<div class="institutionheader">
					#institution#
				</div>
				<cfloop query="coln_portals">
					<cfset coll_dir_name = "#lcase(portal_name)#">
					<div class="collectionrow">
						<div class="table">
							<div class="tr">
								<div class="td widecell">
									<div class="collection_title">#collection#</div>
									<div class="collection_description">
										#descr#
									</div>
								</div>
								<cfquery name="PortalSpecimenCount" datasource="user_login" username="#coln_portals.dbusername#" password="#coln_portals.dbpwd#" cachedwithin="#createtimespan(0,0,60,0)#">
									select count(*) c from cataloged_item
								</cfquery>
								<div class="td">
									<ul>
										<li><a href="/#coll_dir_name#" target="_top">Search&nbsp;#PortalSpecimenCount.c#&nbsp;Specimens</a></li>
									</ul>
								</div>
							</div>
						</div>
					</div>
				</cfloop>
				<cfloop query="coln">
					<cfset coll_dir_name = "#lcase(portal_name)#">
					<div class="collectionrow">
						<div class="table">
							<a name="#guid_prefix#"></a>
							<a name="#ucase(guid_prefix)#"></a>
							<a name="#lcase(guid_prefix)#"></a>
							<div class="tr">
								<div class="td widecell">
									<div class="collection_title">#collection# (#guid_prefix#)</div>
									<div class="collection_description">#descr#</div>
								</div>
								<div class="td">
									<ul>
										<cfif listlast(collection,' ') is not 'Portal'>
											<li><a href="/#coll_dir_name#" target="_top">Search&nbsp;#cnt#&nbsp;Specimens</a></li>
										<cfelse>
											<li><a href="/#coll_dir_name#" target="_top">Search&nbsp;Specimens</a></li>
										</cfif>
										<cfif len(web_link) gt 0>
											<li><a href="#web_link#"  class="external" target="_blank">Collection&nbsp;Home&nbsp;Page&nbsp;</a></li>
										<cfelse>
											<li>no home page</li>
										</cfif>
										<cfif len(loan_policy_url) gt 0>
											<li><a href="#loan_policy_url#" class="external" target="_blank">Collection&nbsp;Loan&nbsp;Policy</a></li>
										<cfelse>
											<li>no loan policy</li>
										</cfif>
										<li><a href="/info/publicationbycollection.cfm?collection_id=#collection_id#" target="_blank">Collection Publications</a></li>
									</ul>
								</div>

							</div>
						</div>
					</div>
				</cfloop>
			</div>
		</cfloop>
		<a name="features"></a>
		<p><strong >Features:</strong></p>
		<ul>
			<li>Vaporware-free since 2001. All this stuff and much more really exists in a usable state, and we'll never claim
				proposed or limited functionality exists.
			</li>
			<li>
				<a href="http://arctosdb.org/documentation/media/" target="_blank" class="external">Media</a>
				link images, movies, sound files, and documents to
				specimens, taxonomy, publications, projects, events, or people.
				<br>
				Multi-page documents organize, paginate, and print PDFs of scanned media such as field notes.
				TAGs comment on specific areas of images, or relate them to nodes such as specimens, places, and people.
			</li>
			<li>
				Users may annotate specimens, taxonomy, projects, publications, and media.
			</li>
			<li>
				<a href="http://www.google.com/search?q=oracle+virtual+private+database" target="_blank" class="external">
				Virtual Private Databases</a> (VPD), also known as Row-Level Security (RLS), allow collections to maintain
				control of their data while sharing certain nodes, such as Agents and Taxonomy. The cool kids call this
				Cloud Computing or Grid Computing. It allows us to confidently support most any application, not just
				the ones we write.
			</li>
			<li>Everything is over the web in real time, and
				independent of client-side operating systems.
				You need moderate bandwidth, a modern browser,
				and nothing more.</li>
			<li>Specimen-search screen is user-customizable
				to about 100 search terms.
				Find specimens by project, publication, usage, taxonomy, spatial attributes, and much more.
				Searches can be saved and emailed.</li>
			<li>Customizable table for result sets,	summarize
				and graph result sets, download (as text, CSV, or XML), map in
				<a href="http://berkeleymapper.berkeley.edu"  target="_blank" class="external">BerkeleyMapper</a>,
				<a href="http://maps.google.com/"  target="_blank" class="external">Google Maps</a>,
				or download
				<a href="http://code.google.com/apis/kml/documentation/"  target="_blank" class="external">KML</a>
				for
				<a href="http://earth.google.com/"  target="_blank" class="external">Google Earth</a>.
			</li>
			<li>Customizable by individual collection using
				headers and footers of their own design, and CSS.</li>
			<li>Any cataloged item can have any number of attributes,
				and attributes are customized to collections.</li>
			<li>Reciprocal linkages with external resources
				(<a href="http://berkeleymapper.berkeley.edu"  target="_blank" class="external">BerkeleyMapper</a>,
				<a href="http://www.ncbi.nlm.nih.gov/Genbank/"  target="_blank" class="external">GenBank</a>,
				<a href="http://www.tacc.utexas.edu"  target="_blank" class="external">TACC</a>,
				and <a href="http://www.morphbank.net/"  target="_blank" class="external">MorphBank</a>).</li>
			<li><a href="http://arctosdb.wordpress.com/documentation/identification/" target="_blank" class="external">Identifications</a>
				can be formulaic combinations
				of terms drawn from a separate taxonomic authority.</li>
			<li>Maintains history of determinations for taxonomic
				identifications, georeferencing, and biological attributes.</li>
			<li>Specimen records, specimen parts, attributes,
				citations, and much more can be entered or edited individually
				or in batches.</li>
			<li>
				<a href="http://arctosdb.org/documentation/container/" target="_blank" class="external">Object-tracking</a>
				using nested-containers model,
				bar codes, and container-condition history.</li>
			<li>
				E-mail <a href="http://arctosdb.org/how-to/notifications/">reminders</a> for loans due,
				permit expirations, etc. Intelligent reports detailing possible GenBank matches,
				missing citations, unlikely publications, and various other potentially faulty or missing data.
			</li>
			<li>
				<a href="http://arctosdb.org/documentation/encumbrance/" target="_blank" class="external">Encumbrances</a>
				 can mask localities, collector names,
				or entire records from unprivileged users.</li>
			<li>Design and print labels, reports, transaction documents, etc. with a
				<a href="http://www.adobe.com/support/coldfusion/downloads.html" target="_blank" class="external">GUI interface</a>.</li>
			<li>Arctos is an IPT provider.</li>
			<LI>Arctos supports <a href="http://en.wikipedia.org/wiki/Content_negotiation" target="_blank" class="external">content negotiation</a>
			 and will provide specimen data in the form of
			 <a href="http://en.wikipedia.org/wiki/Resource_Description_Framework" target="_blank" class="external">RDF</a> upon client request.</LI>
		</ul>


		<a name="nodes"></a>
		<p><strong>Nodes</strong></p>
		<p>Arctos may be thought of as a number of overlapping nodes.</p>
		<ul>
			<li>
				<strong>Specimens</strong> are the core of Arctos. Traditional museum
				"label data" live here.
				<a href="http://arctosdb.org/documentation/attributes/" target="_blank" class="external">Attributes</a>
				 allow collection-specific determinations
				of most anything that can be recorded from a specimen, such as sex, weight, age, and various
				measurements. Specimen Parts are the physical objects, and are grouped as Cataloged Items, which represent
				one or more biological individuals. Cataloged items may be encumbered in order to restrict access to objects or data.
				Other Identifiers record any number assigned to a specimen, and may form links to external resources such as GenBank.
			</li>
			<li>
				<strong>Containers</strong> hold specimen parts and other containers in a flexible recursive model. Containers may
				be barcoded. Some containers hold fluid, and record a history of concentration and monitored dates. All
				containers maintain a position and condition history.
			</li>
			<li>
				<strong>Transactions</strong> consist of loans, accessions, and borrows, and may be grouped through projects.
			</li>
			<li>
				<strong>Localities</strong> record descriptive spatial and coordinate data, along with collecting methods,
				habitat, and dates.
			</li>
			<li>
				<strong>Agents</strong> are people, groups, or organizations that collect specimens, determine identifications,
				attributes, and coordinates, create, authorize, and participate in transactions, author publications,
				and act in various other roles.
			</li>
			<li>
				<strong>Publications</strong> are attached to specimens by way of citations, and are often created by projects.
			</li>
			<li>
				<strong>Projects</strong> create and use specimens, produce publications, group taxonomy into checklists, and record usage of specimens
				in the absence of formal citations.
			</li>
			<li>
				<strong>Taxonomy</strong> forms the basis for identifications and citations. Taxa may be related to each other
				and to any number of common names in any language.
			</li>
			<li>
				<strong>Media</strong> attaches digital resources to specimens, people, places, and publications. TAGs graphically
				reference images to specimens, places, and people. Documents paginate scanned publications, such as field notes.
			</li>
		</ul>

		<a name="participation"></a>
		<p><strong>Participation</strong></p>
		Please see <a href="http://arctosdb.org/home/governance/joining-arctos/">http://arctosdb.org/home/governance/joining-arctos/</a>
		for information about joining or using Arctos.



		<a name="requirements"></a>
		<p><strong>System Requirements</strong></p>

		We attempt to keep the client-side of Arctos applications as generic as possible,
		but we have made some exceptions:
		<ul>
			<li><strong>JavaScript:</strong>
			We have used JavaScript throughout the applications.
			Your browser must be JavaScript enabled to access all
			the features of such applications.</li>
			<li><strong>Cookies: </strong>
			 We use cookies only to set and preserve user preferences and user rights.
			 In order to benefit from all but the most basic public features,
			 you must enable cookies.</li>
			 <li><strong>Pop-ups:</strong>
				Users may wish to enable pop-ups. Some informational windows use pop-ups. We promise to only "pop up" things you ask for.
				<br>
				Operators must enable pop-ups. Many browsers block this, sometimes cryptically, by default.
			</li>
		</ul>

		<a name="browser_compatiblity"></a>

		<p><strong>Browser Compatibility</strong></p>
		<ul>
			<li><strong>Mozilla Firefox:</strong>
				All applications have been tested in Firefox. We recommend all users upgrade to the latest release
				of Firefox,
				 available from <a href="http://www.mozilla.com/firefox/" target="_blank" class="external">Mozilla</a>.</li>
			<li><strong>The Rest:</strong>
		    	Most of Arctos should work most of the time in most other browsers.
				<cfoutput><a href="#Application.ServerRootUrl#/contact.cfm" target="_blank">Let us know</a></cfoutput> if
				you have trouble accessing this site in your browser, and we'll fix it if we can.
			</li>
		</ul>


		<a name="data_usage"></a>

		<p><strong>Data Usage</strong></p>
		Please see <a href="http://arctosdb.org/home/data/">http://arctosdb.org/home/data/</a> for more information on using Arctos data.

		<a name="faq"></a>
		<p><strong>FAQ</strong></p>

		<div class="q">
			Q: I hear Arctos is really complicated. What's up with that?
		</div>
		<div class="a">
			A: Arctos is complicated, as are the data it strives to accurately represent. There is a steep learning curve to understanding
			all functionality. Basic functionality - such as that available from other collections management systems - is pretty simple,
			and we think we do a pretty good job of making it intuitive. Perhaps more noticeable is the level of precision required
			to use Arctos. Rather than (mis!)typing a string, you may have to pick a value from a list, or you may have to supply metadata
			qualifying your assertions. We strongly believe that this is a necessary part of managing the specimens and data with which
			we have been entrusted.
		</div>

		<div class="q">
			Q: Where can I find more information about Arctos?
		</div>
		<div class="a">
			A: <a href="http://arctosdb.wordpress.com" class="external" target="_blank">http://arctosdb.wordpress.com</a>
		</div>
		<div class="q">
			Q: Are these live data?
		</div>
		<div class="a">
			A: Almost. Live data are stored in a <a href="http://code.google.com/p/arctos/downloads/list" class="external" target="_blank">
			highly normalized relational structure</a> - fabulous for
			organization, not so hot for query. Some data are then optimized for
			query performance by way of Database Triggers. Presentation data are generally less than one minute stale.
		</div>
		<div class="q">
			Q: Is there a limit on the number of records I can return in a search?
		</div>
		<div class="a">
			A: We impose no strict limits. Queries almost always take less than 5 seconds. Getting the data to your browser often then
			becomes a bottleneck. If you have a reasonably fast browser and connection, it should be possible to return
			at least 100,000 basic records with a single query. <a href="/contact.cfm" target="_blank">Let us know</a>
			if you find something excessively slow.
		</div>
		<div class="q">
			Q: What's a VPD?
		</div>
		<div class="a">
			A: A Virtual Private Database allows us to share resources, like programmers and hardware, along with some data,
			such as Taxonomy and Agents. We all end up with more than we could afford by ourselves, and operators generally can't tell that
			they're in a shared environment.
		</div>
		<div class="q">
			Q: What's Media? Can I store images or video in Arctos?
		</div>
		<div class="a">
			Media, loosely defined, is anything you can produce a URI for. Web pages, Internet-accessible images, and
			documents stored on FTP sites are all potentially Media. Media may form relationships with any "node" in Arctos.
			<br>
			Arctos proper offers little in the way of storage. However, we have a partnership with the
			<a href="http://www.tacc.utexas.edu/" class="external" target="_blank">
			Texas Advanced Computing Center</a> which provides us access to essentially unlimited storage space. Arctos currently
			links to around 10 terabytes of Media, primarily high-resolution images of ALA herbarium sheets and historical MVZ images, both
			on TACC's servers.
		</div>
		<div class="q">
			Q: Why Oracle and ColdFusion?
		</div>
		<div class="a">
			Because they work. We've tried many other solutions along the way. Oracle is rock-solid and stable, and allows us to
			do things like share/control data via VPDs, maintain current data to our query environments, and
			sleep at night. ColdFusion is a very robust rapid development environment that fits our programming style perfectly
			while providing very close to 100% uptime and reliability. On a more practical level, implementing an open-source solution
			would necessitate hiring at least one additional person to mange software, while compromising stability
			and security.
		</div>
		<div class="q">
			Q: How does Arctos compare with Specify?
		</div>
		<div class="a">
			While sharing a common ancestor, Arctos and Specify now differ almost every level - software,
			hardware, security model, data model,
			development strategy, and support community. A <a href="/info/avs.html">comparison</a> is available.
		</div>
		<div class="q">
			Q: What about security and backups?
		</div>
		<div class="a">
			Arctos has multiple levels of security. A lightweight application security package controls access to forms, while Oracle
			partitions data by user, roles, and context, and provides auditing. Incremental backup logs are maintained on mirrored disks,
			and daily backups are maintained in 3 geographically separate secure locations.
		</div>

		<a name="suggest"></a>
		<p><strong>Suggestions?</strong></p>
			 The utility of Arctos results from user input.
			 If you have a suggestion to make, let's hear it.
			 We accommodate many special requests through custom forms or custom queries,
			 and many of these are then incorporated into Arctos.
			Please <a href="/contact.cfm">contact us</a> if you have any questions, comments, or suggestions.

	</div>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">