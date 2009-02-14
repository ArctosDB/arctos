<style>
	.noshow {
		display:none;
	}	
	.doshow {
		border:1px dotted green;
		font-size:small;
		margin-left:20px;
		}
</style>
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
<cfinclude template="/includes/_header.cfm">
<cfquery  name="coll" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from collection order by collection
</cfquery>
<table width="90%" border="0" cellpadding="10" cellspacing="10">
	<tr>
		<td valign="top" nowrap="nowrap">
			<ul>
			<li><a href="#participation">Participation</a></li>
			<li><a href="#requirements">System Requirements</a></li>
			<li><a href="#browser_compatiblity">Browser Compatability</a></li>
			<li><a href="#data_usage">Data Usage</a></li>
			<li><a href="#suggest">Suggestions?</a></li>
			<li>Search:
				<ul>
					<li>
						<a href="searchAll.cfm" target="_top">All Collections</a>
					</li>
					<cfoutput >
						<cfloop query="coll">
							<cfset coll_dir_name = "#lcase(institution_acronym)#_#lcase(collection_cde)#">
							<li>
									<a href="/#coll_dir_name#" target="_top">
											#collection#</a>
									<span id="plus_minus_#collection_id#" 
										class="infoLink"
										onclick="showDet('#collection_id#')" >
										more...
									</span>
									<div id="det_div_#collection_id#" class="noshow">
										#descr#
										<cfif len(#WEB_LINK#) gt 0>
											<br><a href="#WEB_LINK#" target="_blank">Collection Home Page <img src="/images/linkOut.gif" border="0"></a>
										</cfif>
										<cfif len(#loan_policy_url#) gt 0>
											<br><a href="#loan_policy_url#" target="_blank">Collection Loan Policy <img src="/images/linkOut.gif" border="0"></a>
										</cfif>
									</div>
							</li>
						</cfloop>
					</cfoutput>
				</ul>
			</li>
			</ul>	
		</td>
		<td valign="top">
			<!---<iframe src="http://curator.museum.uaf.edu/arctos_home.html" width="1000" height="1000" frameborder="0"></iframe>--->
			
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
	<li>Everything is over the web in real time, and 
		independent of client-side operating systems. 
		You need moderate band-width, a reasonably modern browser, 
		and nothing more.</li>
	<li>Specimen-search screen is user-customizable 
		to about 100 search terms.  
		Find specimens by project and/or publication.  
		Save and e-mail  searches.</li>
	<li>Customizable table for result sets,	summarize 
		and graph result sets, download (as text, CVS, or XML).</li>
	<li>Customizable by individual collection using 
		headers and footers of their own design, and CSS.</li>
	<li>Any catalog item can have any number of attributes, 
		and attributes are customized to collections.</li>
	<li>Reciprocal linkages with external resources 
		(<a href="http://berkeleymapper.berkeley.edu" target="_blank">BerkeleyMapper</a>, 
		<a href="http://www.ncbi.nlm.nih.gov/Genbank/" target="_blank">GenBank</a>, 
		and <a href="http://www.morphbank.net/" target="_blank">MorphBank</a>).</li>
	<li>Identifications can be formulaic combinations 
		of terms drawn from a separate taxonomic authority.</li>
	<li>Maintains history of determinations for taxonomic 
		identifications, georeferencing, and biological attributes.</li>
	<li>Specimen records, specimen parts, attributes, 
		and citations can be entered or edited individually, 
		or in batches.</li>
	<li>Object-tracking using nested-containers model, 
		bar codes, and container-condition history.</li>
	<li>E-mail reminders for loans due, permit expirations, etc.</li>
	<li>Encumbrances can mask localities, collector names, 
		or entire records from unprivileged users.</li>
	<li>Print labels, reports, transaction documents, etc.</li>
	<li>Arctos is a 
		<a href="http://www.digir.net" target="_blank">DiGIR</a> 
		provider.</li>
</ul>
</p>
<p><a name="participation"><strong>Participation</strong></a><br/>
Arctos is currently three systems sharing the same code. 
One is a 
<a href="http://arctos.database.museum/SpecimenSearch.cfm" target="_blank">multi-hosting version</a> 
that includes collections 
at the 
<a href="http://www.uaf.edu/museum" target="_blank">University of Alaska Museum of the North</a>, 
the 
<a href="http://www.msb.unm.edu/" target="_blank">University of New Mexico's Museum of Southwestern Biology</a>, 
and 
<a href="http://www.wnmu.edu/" target="_blank">Western New Mexico State University</a>.  
A second server in Berkeley is run by the 
<a href="http://mvz.berkeley.edu/" target="_blank">Museum of Vertebrate Zoology</a>, 
and a third is under development by the 
<a href="http://www.mcz.harvard.edu/" target="_blank">Harvard Museum of Comparative Zoology</a>.</p>

<p>Arctos is rooted in the 
<a href="http://mvz.berkeley.edu/cis/index.html" target="_blank">Collections Information System</a> at MVZ.  
Development efforts are being shared, 
and programming is freely available.</p>

<p>Collections or institutions interested in having their 
data hosted in Arctos, or interested in participating in 
the development of Arctos should contact 
<a href="mailto:gordon.jarrell@gmail.com">Gordon Jarrell</a>.</p>

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
</ul></p>

<p><a name="browser_compatiblity"><strong>Browser Compatibility</strong></a>
<ul>
	<li><strong>Mozilla Firefox:</strong> 
		All applications have been tested in Firefox.</li>
	<li><strong>Microsoft Internet Explorer:</strong> 
    	While we've attempted to support IE, we've chosen to follow 
		<a href="http://www.w3.org/" target="_blank">W3C</a> 
		standards as closely as possible. 
		Microsoft is not always standards-compliant, 
		and some features of this site may not work in IE.
		<cfoutput><a href="#Application.ServerRootUrl#/info/bugs.cfm" target="_blank">Let us know</a> if
		</cfoutput>
		you have trouble accessing this site via IE. We'll fix it if we can.</li>
		<li><strong>Safari:</strong>
		Public applications are fully supported.  
		Some AJAX applications for data operators do not work.</li>
</ul></p>

<p><a name="data_usage"><strong>Data Usage</strong></a><br/>
The collections data available through Arctos are separately 
copyrighted &#169; 2001 - 2007 by the University of Alaska Museum of the North 
(University of Alaska, Fairbanks, AK),
and by the Museum of Southwestern Biology (University of New Mexico, Albuquerque, NM),
and the Museum of Vertebrate Zoology (University of California, Berkeley, CA).
All rights are reserved. 
These data are intended for use in education and research and may not be repackaged, redistributed, or sold in any form without prior written consent from the appropriate museum(s). 
Those wishing to include these data in analyses or reports must acknowledge the provenance of the original data, notify the appropriate curator, and should ask questions prior to publication. 
These are secondary data, and their accuracy is not guaranteed. 
Citation of Arctos is no substitute for examination of specimens. 
The data providers are not responsible for loss or damages due to use of these data.</p>

<p><a name="suggest"><strong>Suggestions?</strong></a><br/>
 The utility of Arctos results from user input.
 If you have a suggestion to make, let's hear it.
 We accomodate many special requests through custom forms or custom queries,
 and many of these are then incorporated into Arctos.
Please send email to <a href="mailto:dustymc@gmail.com">Dusty</a> or 
<a href="mailto:gordon.jarrell@gmail.com">Gordon</a> if you have any questions, comments, or suggestions. 
</p>
<!---
<a href="/arctosdoc/pageHelp/about.cfm" target="_blank"><center><strong></strong></center></a>
--->
	</td>
	<td valign="top"><img src="images/arctos_schema.png"/></td>
	</tr>
</table>

<cfinclude template="/includes/_footer.cfm">
