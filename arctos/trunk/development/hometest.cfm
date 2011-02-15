<style>
	.noshow {
		display:none;
	}	
	.doshow {
		border:1px dotted green;
		font-size:small;
		margin-left:20px;
	}
	.q {
		font-variant: small-caps;
	}
	.a {
		font-size:smaller;
		margin-bottom:1em;
	}
	.collDescr {
		font-size:smaller;
		padding-left:1em;
	}
	.inst {
		font-size: large;
		font-weight: bold;
	}
	.portalborder{
		border:1px solid black;
	}
</style>
<script src="/includes/sorttable.js"></script>
<script>
	function showDet(collection_id) {
		//alert('show ' + collection_id);
		var theDivName = "det_div_" + collection_id;
		var theSpanName = "plus_minus_" + collection_id;
		var theDiv = document.getElementById(theDivName);
		var theSpan = document.getElementById(theSpanName);
		theDiv.className='doshow';
		theSpan.innerHTML='less...';
		theOnclickString = 'closeThis(' + collection_id + ')';
		theSpan.setAttribute('onclick',theOnclickString);		
	}
	function closeThis(collection_id) {
		var theDivName = "det_div_" + collection_id;
		var theSpanName = "plus_minus_" + collection_id;
		var theDiv = document.getElementById(theDivName);
		var theSpan = document.getElementById(theSpanName);
		theDiv.className='noshow';
		theSpan.innerHTML='more...';
		theOnclickString = 'showDet(' + collection_id + ')';
		theSpan.setAttribute('onclick',theOnclickString);
	}
</script>
<cfset title="Arctos Home">
<cfset metaDesc="Frequently-asked questions (FAQ), Arctos description, participation guidelines, usage policies, suggestions, and requirements for using Arctos or participating in the Arctos community.">
<cfinclude template="/includes/_header.cfm">
<cfquery  name="coll" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
	select * from cf_collection,collection
	where cf_collection.collection_id=collection.collection_id (+) and
	PUBLIC_PORTAL_FG = 1 order by cf_collection.collection
</cfquery>
<!---

<cfdump var=#coll#>


--->
<!--- hard-code some collections in for special treatment, but leave a default "the rest" query too --->
<cfquery name="pub" dbtype="query">
	select * from coll where cf_collection_id=0
</cfquery>
<cfset gotem=valuelist(pub.cf_collection_id)>
<cfquery name="uam" dbtype="query">
	select * from coll where collection like 'UAM %' order by collection
</cfquery>
<cfset gotem=listappend(gotem,valuelist(uam.cf_collection_id))>
<cfquery name="msb" dbtype="query">
	select * from coll where collection like 'MSB %' order by collection
</cfquery>
<cfset gotem=listappend(gotem,valuelist(msb.cf_collection_id))>
<cfquery name="mvz" dbtype="query">
	select * from coll where collection like 'MVZ %' and lower(portal_name) != 'mvz_all' order by collection
</cfquery>
<cfset gotem=listappend(gotem,valuelist(mvz.cf_collection_id))>
<cfquery name="mvz_all" dbtype="query">
	select * from coll where collection like 'MVZ %' and lower(portal_name) = 'mvz_all' order by collection
</cfquery>
<cfset gotem=listappend(gotem,valuelist(mvz_all.cf_collection_id))>
<cfquery name="wnmu" dbtype="query">
	select * from coll where collection like 'WNMU %' order by collection
</cfquery>
<cfset gotem=listappend(gotem,valuelist(wnmu.cf_collection_id))>
<cfquery name="dmns" dbtype="query">
	select * from coll where collection like 'DMNS %' order by collection
</cfquery>
<cfset gotem=listappend(gotem,valuelist(dmns.cf_collection_id))>
<cfquery name="rem" dbtype="query">
	select * from coll where cf_collection_id not in (#gotem#)
</cfquery>

<table width="100%" border="0" cellpadding="10" cellspacing="10">
	<tr>
		<td valign="top" nowrap="nowrap">
<ul>
	<li><a href="#features">Features</a></li>
	<li><a href="#participation">Participation</a></li>
	<li><a href="#nodes">Components</a></li>
	<li><a href="#requirements">System Requirements</a></li>
	<li><a href="#browser_compatiblity">Browser Compatability</a></li>
	<li><a href="#data_usage">Data Usage</a></li>
	<li><a href="#faq">FAQ</a></li>
	<li><a href="#suggest">Suggestions?</a></li>
</ul>
</td>
		<td valign="top">
<p>
Arctos is an ongoing effort to integrate access to specimen data, collection-management tools, and external resources on the Web.
 Nearly all that is known about a specimen can be included in Arctos, and, except for some data encumbered for 
proprietary reasons, data are open to the public.
</p>
<p>
	The following portals are available for querying specimen data. By querying Arctos, you accept the <a href="#data_usage">data usage policy.</a>
</p>
<cfoutput>
	<div class="portalborder">
	<ul>
	<cfif isdefined("pub") and pub.recordcount gt 0>
		<cfloop query="pub">
			<cfset coll_dir_name = "#lcase(portal_name)#">
			 <cfquery name="c" datasource="user_login" username="#DBUSERNAME#" password="#DBPWD#"  cachedwithin="#createtimespan(0,0,60,0)#">
				select count(*) c from cataloged_item
			</cfquery>
			<li>
				<span class="inst">#collection#</span>
				<cfif len(descr) gt 0>
					<div class="collDescr">
						#descr#
					</div>
				</cfif>
				<ul>
					<li><a href="/#coll_dir_name#" target="_top">Search #c.c# specimens</a></li>
					<cfif len(WEB_LINK) gt 0>
						<li><a href="#WEB_LINK#" class="external" target="_blank">Collection Home Page</a></li>
					</cfif>
					<cfif len(loan_policy_url) gt 0>
						<li><a href="#loan_policy_url#" class="external" target="_blank">Collection Loan Policy</a></li>
					</cfif>
				</ul>
			</li>
		</cfloop>
	</cfif>
	<cfif isdefined("uam") and uam.recordcount gt 0>
			<li><a href="http://www.uaf.edu/museum/" target="_blank" class="external inst">University of Alaska Museum</a>
				<ul>
					<cfloop query="uam">
						<cfset coll_dir_name = "#lcase(portal_name)#">
						 <cfquery name="c" datasource="user_login" username="#DBUSERNAME#" password="#DBPWD#"  cachedwithin="#createtimespan(0,0,60,0)#">
							select count(*) c from cataloged_item
						</cfquery>
						<li>
							#collection#
							<cfif len(descr) gt 0>
								<div class="collDescr">
									#descr#
								</div>
							</cfif>
							<ul>
								<li><a href="/#coll_dir_name#" target="_top">Search #c.c# specimens</a></li>
								<cfif len(WEB_LINK) gt 0>
									<li><a href="#WEB_LINK#" class="external" target="_blank">Collection Home Page</a></li>
								</cfif>
								<cfif len(loan_policy_url) gt 0>
									<li><a href="#loan_policy_url#" class="external" target="_blank">Collection Loan Policy</a></li>
								</cfif>
							</ul>
						</li>
					</cfloop>
				</ul>
			</li>
		</cfif>
		<cfif isdefined("msb") and msb.recordcount gt 0>
			<li><a href="http://www.msb.unm.edu/" target="_blank" class="external inst">Museum of Southwestern Biology</a>
				<ul>
					<cfloop query="msb">
						<cfset coll_dir_name = "#lcase(portal_name)#">
						 <cfquery name="c" datasource="user_login" username="#DBUSERNAME#" password="#DBPWD#"  cachedwithin="#createtimespan(0,0,60,0)#">
							select count(*) c from cataloged_item
						</cfquery>
						<li>
							#collection#
							<cfif len(descr) gt 0>
								<div class="collDescr">
									#descr#
								</div>
							</cfif>
							<ul>
								<li><a href="/#coll_dir_name#" target="_top">Search #c.c# specimens</a></li>
								<cfif len(WEB_LINK) gt 0>
									<li><a href="#WEB_LINK#" class="external" target="_blank">Collection Home Page</a></li>
								</cfif>
								<cfif len(loan_policy_url) gt 0>
									<li><a href="#loan_policy_url#" class="external" target="_blank">Collection Loan Policy</a></li>
								</cfif>
							</ul>
						</li>
					</cfloop>
				</ul>
			</li>
		</cfif>
		<cfif isdefined("mvz") and mvz.recordcount gt 0>
			<li><a href="http://mvz.berkeley.edu/" target="_blank" class="external inst">Museum of Vertebrate Zoology</a>
				<ul>
					<cfif isdefined("mvz_all") and mvz_all.recordcount gt 0>
						<cfloop query="mvz_all">
							<cfset coll_dir_name = "#lcase(portal_name)#">
							 <cfquery name="c" datasource="user_login" username="#DBUSERNAME#" password="#DBPWD#"  cachedwithin="#createtimespan(0,0,60,0)#">
								select count(*) c from cataloged_item
							</cfquery>
							<li>
								#collection#
								<cfif len(descr) gt 0>
									<div class="collDescr">
										#descr#
									</div>
								</cfif>
								<ul>
									<li><a href="/#coll_dir_name#" target="_top">Search #c.c# specimens</a></li>
									<cfif len(WEB_LINK) gt 0>
										<li><a href="#WEB_LINK#" class="external" target="_blank">Collection Home Page</a></li>
									</cfif>
									<cfif len(loan_policy_url) gt 0>
										<li><a href="#loan_policy_url#" class="external" target="_blank">Collection Loan Policy</a></li>
									</cfif>
								</ul>
							</li>
						</cfloop>
					</cfif>
					<cfloop query="mvz">
						<cfset coll_dir_name = "#lcase(portal_name)#">
						 <cfquery name="c" datasource="user_login" username="#DBUSERNAME#" password="#DBPWD#"  cachedwithin="#createtimespan(0,0,60,0)#">
							select count(*) c from cataloged_item
						</cfquery>
						<li>
							#collection#
							<cfif len(descr) gt 0>
								<div class="collDescr">
									#descr#
								</div>
							</cfif>
							<ul>
								<li><a href="/#coll_dir_name#" target="_top">Search #c.c# specimens</a></li>
								<cfif len(WEB_LINK) gt 0>
									<li><a href="#WEB_LINK#" class="external" target="_blank">Collection Home Page</a></li>
								</cfif>
								<cfif len(loan_policy_url) gt 0>
									<li><a href="#loan_policy_url#" class="external" target="_blank">Collection Loan Policy</a></li>
								</cfif>
							</ul>
						</li>
					</cfloop>
				</ul>
			</li>
		</cfif>
		
		<cfif isdefined("dmns") and dmns.recordcount gt 0>
			<li><a href="http://www.dmns.org/" target="_blank" class="external inst">Denver Museum of Nature and Science</a>
				<ul>
					<cfloop query="dmns">
						<cfset coll_dir_name = "#lcase(portal_name)#">
						 <cfquery name="c" datasource="user_login" username="#DBUSERNAME#" password="#DBPWD#"  cachedwithin="#createtimespan(0,0,60,0)#">
							select count(*) c from cataloged_item
						</cfquery>
						<li>
							#collection#
							<cfif len(descr) gt 0>
								<div class="collDescr">
									#descr#
								</div>
							</cfif>
							<ul>
								<li><a href="/#coll_dir_name#" target="_top">Search #c.c# specimens</a></li>
								<cfif len(WEB_LINK) gt 0>
									<li><a href="#WEB_LINK#" class="external" target="_blank">Collection Home Page</a></li>
								</cfif>
								<cfif len(loan_policy_url) gt 0>
									<li><a href="#loan_policy_url#" class="external" target="_blank">Collection Loan Policy</a></li>
								</cfif>
							</ul>
						</li>
					</cfloop>
				</ul>
			</li>
		</cfif>
		<cfif isdefined("wnmu") and wnmu.recordcount gt 0>
			<li><a href="http://www.wnmu.edu/univ/museum.htm" target="_blank" class="external inst">Western New Mexico University</a>
				<ul>
					<cfloop query="wnmu">
						<cfset coll_dir_name = "#lcase(portal_name)#">
						 <cfquery name="c" datasource="user_login" username="#DBUSERNAME#" password="#DBPWD#"  cachedwithin="#createtimespan(0,0,60,0)#">
							select count(*) c from cataloged_item
						</cfquery>
						<li>
							#collection#
							<cfif len(descr) gt 0>
								<div class="collDescr">
									#descr#
								</div>
							</cfif>
							<ul>
								<li><a href="/#coll_dir_name#" target="_top">Search #c.c# specimens</a></li>
								<cfif len(WEB_LINK) gt 0>
									<li><a href="#WEB_LINK#" class="external" target="_blank">Collection Home Page</a></li>
								</cfif>
								<cfif len(loan_policy_url) gt 0>
									<li><a href="#loan_policy_url#" class="external" target="_blank">Collection Loan Policy</a></li>
								</cfif>
							</ul>
						</li>
					</cfloop>
				</ul>
			</li>
		</cfif>
		<cfif isdefined("rem") and rem.recordcount gt 0>
			<li><span class="inst">Other Collections</span>
				<ul>
					<cfloop query="rem">
						<cfset coll_dir_name = "#lcase(portal_name)#">
						 <cfquery name="c" datasource="user_login" username="#DBUSERNAME#" password="#DBPWD#"  cachedwithin="#createtimespan(0,0,60,0)#">
							select count(*) c from cataloged_item
						</cfquery>
						<li>
							#collection#
							<cfif len(descr) gt 0>
								<div class="collDescr">
									#descr#
								</div>
							</cfif>
							<ul>
								<li><a href="/#coll_dir_name#" target="_top">Search #c.c# specimens</a></li>
								<cfif len(WEB_LINK) gt 0>
									<li><a href="#WEB_LINK#" class="external" target="_blank">Collection Home Page</a></li>
								</cfif>
								<cfif len(loan_policy_url) gt 0>
									<li><a href="#loan_policy_url#" class="external" target="_blank">Collection Loan Policy</a></li>
								</cfif>
							</ul>
						</li>
					</cfloop>
				</ul>
			</li>
		</cfif>
	</ul>
	</div>
</cfoutput>
<a name="features"></a>

<p>
Arctos is an ongoing effort to integrate access 
to specimen data, collection-management tools, and 
external resources on the Web.  
Nearly all that is known about a specimen can be 
included in Arctos, and, except for some data 
encumbered for proprietary reasons, data are open to the public.
</p>
<p><strong >Features:</strong>
<ul>
	<li>Vaporware-free since 2001. All this stuff, and much more, really exists in a usable state, and we'll never claim
		proposed or limited funtionality exists.
	</li>
	<li>
		<a href="MediaSearch.cfm">Media</a> links images, movies, sound files, and documents to 
		specimens, taxonomy, publications, projects, events, or people.
		<br>
		Multi-page documents organize, paginate, and print PDFs of scanned media such as field notes.
		<br>
		TAGs comment on specific areas of images, or relate them to nodes such as specimens, places, and people.
	</li>
	<li>
		Users may annotate specimens, taxonomy, projects, publications, and media.
	</li>
	<li>
		<a href="http://www.oracle.com/technology/obe/obe10gdb/security/vpd/vpd.htm" target="_blank" class="external">
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
		Save and e-mail  searches.</li>
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
	<li>Identifications can be formulaic combinations 
		of terms drawn from a separate taxonomic authority.</li>
	<li>Maintains history of determinations for taxonomic 
		identifications, georeferencing, and biological attributes.</li>
	<li>Specimen records, specimen parts, attributes, 
		citations, and much more can be entered or edited individually 
		or in batches.</li>
	<li>Object-tracking using nested-containers model, 
		bar codes, and container-condition history.</li>
	<li>
		E-mail <a href="http://arctosblog.blogspot.com/2009/08/suspect-data.html">reminders</a> for loans due, 
		permit expirations, etc. Intelligent reports detailing possible GenBank matches,
		missing citations, unlikely publications, and various other potentially faulty or missing data.
		<a href="/info/suspectData.cfm">more information</a> 
	</li>
	<li>Encumbrances can mask localities, collector names, 
		or entire records from unprivileged users.</li>
	<li>Design and print labels, reports, transaction documents, etc. with a 
		<a href="http://www.adobe.com/support/coldfusion/downloads.html" target="_blank" class="external">GUI interface</a>.</li>
	<li>Arctos is a 
		<a href="http://www.digir.net" target="_blank">DiGIR</a> 
		provider.</li>
</ul>
</p>
<a name="nodes"></a>
<p><strong>Nodes</strong></p>
<p>
	Arctos may be thought of as a number of overlapping nodes.
	<ul>
		<li>
			<strong>Specimens</strong> are the core of Arctos. Traditional museum
			"label data" lives here. Attributes allow collection-specific determinations
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
			attributes, and coordinates, create, authorize, and participate in tranactions, author publications, 
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
			<strong>Taxonomy</strong> forms the basis for identifications and citations. Taxa may be related to each other,
			and to any number of common names in any language.
		</li>
		<li>
			<strong>Media</strong> attaches digital resources to specimens, people, places, and publications. TAGs graphically
			reference images to specimens, places, and people. Documents paginate scanned publications, such as field notes.
		</li>
	</ul>
</p>
<p><a name="participation"><strong>Participation</strong></a><br/>
Arctos is currently two systems sharing the same code. 
One is a 
<a href="http://arctos.database.museum/SpecimenSearch.cfm" target="_blank">multi-hosting version</a> 
that includes collections 
at the 
<a href="http://www.uaf.edu/museum" target="_blank">University of Alaska Museum of the North</a>, 
the 
<a href="http://www.msb.unm.edu/" target="_blank">University of New Mexico's Museum of Southwestern Biology</a>,  
<a href="http://www.wnmu.edu/" target="_blank">Western New Mexico State University</a>, and
the 
<a href="http://mvz.berkeley.edu/" target="_blank">Museum of Vertebrate Zoology</a>. A second server at the
<a href="http://mczbase.mcz.harvard.edu" target="_blank">Harvard Museum of Comparative Zoology</a> hosts 
MCZ's Herp collection, with more collections coming soon.</p>

<p>Arctos is rooted in the 
<a href="http://mvz.berkeley.edu/cis/index.html" target="_blank" class="external">Collections Information System</a> at MVZ.  
Development efforts are shared, 
and programming is freely available.</p>

<p>Collections or institutions interested in having their 
data hosted in Arctos, or interested in participating in 
the development of Arctos should <a href="/info/participate.cfm">review the participation guidelines</a>, then
<a href="/contact.cfm">contact us</a> for additional information.</p>

<p><a name="requirements"><strong>System Requirements</strong></a><br/>
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
	 <li><strong>Popups:</strong>
		Users may wish to enable popups. Some informational windows use popups. We promise to only pop up things you ask for.
		<br>
		Operators must enable popups. Many browsers block this, sometimes cryptically, by default.
	</li>
</ul></p>

<p><a name="browser_compatiblity"><strong>Browser Compatibility</strong></a>
<ul>
	<li><strong>Mozilla Firefox:</strong> 
		All applications have been tested in Firefox. We highly recommend all users upgrade to the latest release
		of Firefox,
		 available from <a href="http://www.mozilla.com/firefox/" target="_blank" class="external">Mozilla</a>.</li>
	<li><strong>The Rest:</strong> 
    	Most of Arctos should work most of the time in most other browsers.
		<cfoutput><a href="#Application.ServerRootUrl#/info/bugs.cfm" target="_blank">Let us know</a></cfoutput> if
		you have trouble accessing this site in your browser, and we'll fix it if we can.
	</li>
</ul></p>

<p><a name="data_usage"><strong>Data Usage</strong></a><br/>
The collections data available through Arctos are separately 
copyrighted &#169; 2001 - 2011 by the University of Alaska Museum of the North 
(University of Alaska, Fairbanks, AK),
and by the Museum of Southwestern Biology (University of New Mexico, Albuquerque, NM),
and the Museum of Vertebrate Zoology (University of California, Berkeley, CA).
All rights are reserved. 
These data are intended for use in education and research and may not be repackaged, redistributed, or sold in any form without prior written consent from the appropriate museum(s). 
Those wishing to include these data in analyses or reports must acknowledge the provenance of the original data, notify the appropriate curator, and should ask questions prior to publication. 
These are secondary data, and their accuracy is not guaranteed. 
Citation of Arctos is no substitute for examination of specimens. 
The data providers are not responsible for loss or damages due to use of these data.</p>

<p><a name="faq"><strong>FAQ</strong></a><br/>

<div class="q">
	Q: Where can I find more information about Arctos?
</div>
<div class="a">
	A: <a href="https://sites.google.com/site/arctosdb/" class="external" target="_blank">https://sites.google.com/site/arctosdb/</a>
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
	at least 100,000 basic records with a single query. We have no idea why you'd want to. <a href="/contact.cfm" target="_blank">Let us know</a> 
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
<p><a name="suggest"><strong>Suggestions?</strong></a><br/>
 The utility of Arctos results from user input.
 If you have a suggestion to make, let's hear it.
 We accommodate many special requests through custom forms or custom queries,
 and many of these are then incorporated into Arctos.
Please <a href="/contact.cfm">contact us</a> if you have any questions, comments, or suggestions. 
</p>
	</td>
	<td valign="top"><img src="/images/arctos_schema.png"/></td>
	</tr>
</table>

<cfinclude template="/includes/_footer.cfm">
