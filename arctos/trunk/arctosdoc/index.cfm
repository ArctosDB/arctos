<cfinclude template="/includes/_helpHeader.cfm">
<cfset title = "Table of Contents">

<p>
<font size="+2">Arctos Help: Table of Contents</font></p>
<!--#include virtual="../includes/icon_trans.cfm" -->
<p><a href="search_examples_TOC.cfm"><strong>Examples of Searches</strong></a></p>
<!--
<p><strong>Form-level Help:</strong> 
<ul>
<li><a href="pageHelp/searching.cfm"><strong> Specimen Search</strong></a></li>
<li><a href="pageHelp/specimen_results.cfm"><strong> Specimen List</strong></a></li>
<li><a href="pageHelp/resultsearch.cfm"><strong> Result Search</strong></a></li>
<li><a href="pageHelp/customize.cfm"><strong> Advanced Features</strong></a></li>
</ul></p>
-->

<p><strong>Operator Help:</strong></p>
<ul>
<li><a href="Bulkloader/index.cfm">
<strong>Add New Records</strong></a> (Bulk-loading)</li>
<li><a href="definitions_standards_index.cfm">
<strong>Definitions and Standards</strong></a></li>
<li><a href="http://arctosblog.blogspot.com/">
<strong>Procedures</strong></a>
</ul>

<p><a href="pageHelp/about.cfm">
<strong>About the Database</strong></a></p>
<ul>	
	<li><a href="pageHelp/about.cfm#requirements">
	<strong>System Requirements</strong></a></li>

	<li><a href="pageHelp/about.cfm#browser_compatiblity">
	<strong>Browser Compatibility</strong></a></li>
	
	<li><a href="pageHelp/about.cfm#suggest">
	<strong>Suggestions</strong></a></li>

	<li><a href="pageHelp/about.cfm#data_usage">
	<strong>Data Usage</strong></a></li>
	
	<li>
		<cfoutput>
			<a href="#Application.ServerRootUrl#/info/bugs.cfm" target="_parent">
		</cfoutput>
	<strong>Report Bugs</strong></a></li>
</ul>	

<p><strong>Specimen-use Policies</strong></p>
<ul>
<li><a href="http://www.uaf.edu/museum/af/using.html"><strong>U.A. Museum of the North</strong></a></li>
<li><a href="http://www.msb.unm.edu/policy.html#2"><strong>U.N.M. Museum of SW Biology</strong></a></li>
</ul>

<!--
<p><strong>Report Crummy Data</strong></p>
-->
<cfinclude template="/includes/_helpFooter.cfm">