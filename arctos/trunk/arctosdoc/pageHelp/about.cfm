<cfinclude template="/includes/_helpHeader.cfm">
<cfset title = "About Arctos">

<font size="-2"><a href="../index.cfm">Help</a> >> <strong>About Arctos</strong> </font><br />
<font size="+2">About Arctos</font>
<p>Arctos is an ongoing database-development project that integrates
specimen data, scientific results, and extensive 
collection-management applications. 
Working data is accessible to the public, and
operators manage data through a suite of 
web applications.
These are intended to run on any up-to-date web browser,
independently of the client's operating system.
Institutions involved in Arctos include:
<ul>
<li>University of Alaska Museum of the North (UAM)</li>
<li>University of California's Museum of Vertebrate Zoology (MVZ)</li>
<li>University of New New Mexico's Museum of Southwestern Biology (MSB)</li>
<li>Western New Mexico University (WNMU)</li>
<li>Harvard Museum of Compartive Zoology (MCZ)</li>
</ul>

Arctos has potential as a multi-hosting system as demonstrated by
UAM, MSB, and WNMU's sharing of a single instance incorporating about
twenty specimen catalogs.</p>

<p>Arctos is a set ColdFusion &#174; applications 
running data in Oracle&#174; and based on the
<a href="http://mvz.berkeley.edu/cis/index.html">Collections Information System</a>
at MVZ.
All programming is freely available for use or evaluation. 
Potential users are welcome to contact either MVZ or UAM. </p>

<p><a name="requirements"></a>
<font size="+1">System Requirements</font><br/>
We attempt to keep the client-side of Arctos applications as generic as possible, 
but we have made some exceptions:
<ul>
	<li>
	<strong>JavaScript:</strong>
	We have used JavaScript throughout the applications. Your browser must be JavaScript 
	enabled to access all the features of such applications.
	</li>
	<li>
	<strong>Frames: </strong>
	We've used frames only when they clearly enhance our ability to present data in a meaningful format.
	Most framed applications are for data operators, not public users.
	</li>
	<li>
	<strong>Flash: </strong>
	   Printable documents are presented as FlashPaper documents. You must have Flash player installed on your computer to view these documents.
	</li>
	<li>
	<strong>Cookies: </strong>
	    We use cookies only to set and preserve user preferences and user rights. 
		In order benefit from all but the most basic public feautres, you must enable cookies. </li>
</ul>
</p>
<p>
<a name="browser_compatiblity"><strong>Browser Compatibility</strong></a>
<ul>
	<li>
	   <strong>Mozilla Firefox:</strong> All applications have been tested in Firefox.
	</li>
	<li>
		<strong>Netscape 6.x +:</strong> Should function the same as Firefox.
	</li>
	<li>
		 <strong>Netscape 4.x and older:</strong> Older versions of Netscape are JavaScript 
		 and CSS deficient and don't properly render many forms. We recommend upgrading.
	</li>
	<li>
		 <strong>Microsoft Internet Explorer:</strong> 
    		While we've attempted to support IE, we've chosen to follow 
		<a href="http://www.w3.org/" target="_blank">W3C</a> standards as closely as possible. Microsoft 
		tends to be less than standards-compliant, and some features of this site may not work in IE.
		<cfoutput>
		Please <a href="#Application.ServerRootUrl#/info/bugs.cfm" target="_blank">let us know</a> if
		</cfoutput>
		you have trouble accessing this site via IE. We'll fix it if we can!
	</li>
</ul></p>
<p>
<a name="suggest"></a>
<font size="+1">Suggestions?</font><br/>
 The utility of Arctos results from user input.
 If you have a suggestion to make, let's hear it.
 We accomodate many special requests through custom forms or custom queries,
 and many of these are then incorporated into Arctos.
Please send email to <a href="mailto:fndlm@uaf.edu">Dusty</a> or 
<a href="mailto:fnghj@uaf.edu">Gordon</a> if you have any questions, comments, or suggestions. 
</p>

<p><a name="data_usage"></a>
<font size="+1">Data Usage</font><br/>
The collections data available through Arctos are separately copyrighted &#169; 2001 - 2007 
by the University of Alaska Museum of the North (University of Alaska, Fairbanks, AK),
and by the Museum of Southwestern Biology (University of New Mexico, Albuquerque, NM),
and the Museum of Vertebrate Zoology (University of California, Berkeley, CA).
  All rights are reserved. 
  These data are intended for use in education and research and may not be repackaged, redistributed, or sold in any form without prior written consent from the appropriate museum(s). 
  Those wishing to include these data in analyses or reports must acknowledge the provenance of the original data, notify the appropriate curator, and should ask questions prior to publication. 
  These are secondary data, and their accuracy is not guaranteed. 
  Citation of Arctos is no substitute for examination of specimens. 
The data providers are not responsible for loss or damages due to use of these data.</p>













<p><a name="cool_stuff"></a>
<h2>Selected Features</h2>
<h3>Data Organization</h3><a name="cool_data_stuff"></a>
<ul>
	<li>
		Identifications are formally separated from Taxonomy
		<ul>
			<li>External taxonomy resource possible</li>
			<li>Maintains a history of Identifications, including Who, When, How</li>
			<li>
				Allows determinations that are not strictly Taxonomy (hybrids, uncertainty, etc.) using strict taxonomy terms
			</li>
		</ul>
	</li>
	<li>Attributes (<em>e.g.</em>, sex, age, weight)
		<ul>
			<li>Easily customizable at the Collection level.</li>
			<li>
				Add and define new attributes (or entire collections) without code modification. Example: Curators can, 
				without programmer assistance, create a new Attribute (<em>e.g.</em>, "leaf length") and define 
				acceptable data for that attribute (<em>e.g.</em>, 
				numeric Attribute Value, Attribute Units in Code Table Length Units).
			</li>
			<li>Treated as Determinations: Who, When, How</li>
			<li>Apply any number of Attributes to a single specimen</li>
		</ul>
	</li>
	<li>Geographic coordinate determination history is maintained, including Who, When, How</li>
	<li>Part condition determination history is maintained,  including Who, When, How</li>
	<li>Encumbrances mask entire specimen records or parts thereof from public users</li>
	<li>
		Recursive Container object tracking model
		<ul>
			<li>As fine or coarse-grained location data as needed</li>
			<li>Maintain history of fluid container condition</li>
			<li>Maintain check history</li>
			<li>Integrated barcodes</li>
		</ul>
	</li>
	<li>Binary Objects include Images and Image Metadata. May link to remote repositories.</li>	
	<li>Accessions, Loans, Borrows, Projects, Publications, and Citations record acquisition and usage of specimens</li>
</ul>




<h3>Interface</h3><a name="cool_interface_stuff"></a>
<ul>
	<li>Everything is done online using any modern browser on any operating system. 
	Everything is real-time; raw data is always, at most, one click away.</li>
	<li>Many ways to locate specimens
		<ul>
			<li>Publications and Projects</li>
			<li>Specimen Search</li>
			<ul>
				<li>
					User-Customizable to include ca. 100 search terms
				</li>
			</ul>
		</ul>
	</li>
	<li>Savable searches</li>
	<li>Many ways to view Specimen Data
		<ul>
			<li>Online table (highly customizable)</li>
			<li>Individual Specimen Record</li>
			<li>Summary</li>
			<li>Graph</li>
			<li>Download (text, CSV, XML)</li>
		</ul>
	</li>
	<li>Print labels, reports, loan forms, etc.</li>
	<li>Accept user Annotations</li>
	<li>Customizable look and feel for individual collections via CSS and custom headers/footers</li>
</ul>
<h3>Usability</h3><a name="cool_usability_stuff"></a>
<ul>
	<li>Interoperable with other repositories
		<ul>
			<li>GenBank</li>
			<li>MorphBank</li>
			<li>Online publications</li>
		</ul>		
	</li>
	<li>
		Bulkload Capabilities
		<ul>
			<li>Specimens</li>
			<li>Parts</li>
			<li>Citations</li>
			<li>Attributes</li>
		</ul>
	</li>
	<li>
		Create and manage user access online
	</li>	
	<li>Documentation for most fields and forms; more all the time...</li>
	<li>Email reminders for loans due, permits expiring, etc.</li>
	<li>Batch processing: Perform many functions on >1 specimen simultaneously</li>
</ul>
<cfinclude template="/includes/_helpFooter.cfm">