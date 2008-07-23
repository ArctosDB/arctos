<!---- include this at the top of every page --->
<cfinclude template="/includes/_helpHeader.cfm">
<!---- provide a value here to display as a page title. Will be displayed and bookmarked as 
	"Arctos Help: {your title}" --->
<cfset title = "">
<!----
	"Breadcrumbs" div example:
--->
<div class="breadcrumbs">
<a href="../index.cfm">Help</a> >> <a href="searching.cfm">Specimen Search</a> >> Field Definitions
</div>
<!---Hi there.>
<!--- 
	standard anchor format. Note that #top is defined in _helpHeader and does not need to be included
	Use H2 for subheadings, H3 (if needed) for lower-level headings
	--->
<a name="date" class="infoLink" href="#top">Top</a><br>
<h2>Determined Date</h2> 


<!---- include this at the bottom of every page --->
<cfinclude template="/includes/_helpFooter.cfm">

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
