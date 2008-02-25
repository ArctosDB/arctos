<!---- include this at the top of every page --->
<cfinclude template="/includes/_helpHeader.cfm">
<!---- provide a value here to display as a page title. Will be displayed and bookmarked as 
	"Arctos Help: {your title}" --->
<cfset title = "Other Identifier Type">
<!----
	"Breadcrumbs" div example:
--->
<!---
<div class="breadcrumbs">
<a href="../index.cfm">Help</a> >> <a href="searching.cfm">Specimen Search</a> >> Field Definitions
</div>
--->
<!---Hi there.--->
<!--- 
	standard anchor format. Note that #top is defined in _helpHeader and does not need to be included
	Use H2 for subheadings, H3 (if needed) for lower-level headings
	--->
<a name="date" class="infoLink" href="#top">Top</a><br>
<h1>Other Identifying Number</h1> 
You can use Other ID even if you do not specify the Other ID Type. For example, Taxon Name = Microtus and Other ID = AF163890 will return the record with GenBank sequence accession = AF163890. You can also search on incomplete strings. Taxon Name = Microtus and Other ID = AF163 will return records that have GenBank sequence accessions beginning with AF163. Expect data inconsistencies.
<P>
	You may specify a string or a comma-separated list of strings. Examples:
	<ul>
		<li>123</li>
		<li>JJB 123</li>
		<li>JJB123</li>
		<li>JJB-123</li>
		<li>JJB-123,JJB-124,JJB-125</li>
	</ul>
</P>


<!---- include this at the bottom of every page --->
<cfinclude template="/includes/_helpFooter.cfm">
<!---
<!--- 
	points to the base URL of the server. Must be wrapped in cfoutput tags:
	
	<cfoutput>
		<a href="#Application.ServerRootUrl#/some/random/thing.cfm">clicky me</a>
	</cfoutput>
	
	You must escape # by using ## inside cfoutput, so:
	<cfoutput>
		<a href="#Application.ServerRootUrl#/some/random/thing.cfm##someAnchor">clicky me</a>
	</cfoutput>
--->
#Application.ServerRootUrl#

<!--- class="fldDef" is defined in /includes/style.css for use with DIVs. 
	Currently produces a fine-bordered box on the
	right side of the page. Example below:
 --->

<div class="fldDef">
	Attributes . Determined_Date<br/>
	datetime, null
</div>



<!--- getCodeTable is a Custom Tag that displays code table values inline. May be used to poduce an 
	unordered list: --->
<cf_getCodeTable table="ctverificationstatus" format="list">
<!---- or a table: --->
<cf_getCodeTable table="ctverificationstatus" format="table">
<!--- format is not required and defaults to table. --->
<cf_getCodeTable table="ctverificationstatus">
<!---- will produce the same results as above. --->
--->