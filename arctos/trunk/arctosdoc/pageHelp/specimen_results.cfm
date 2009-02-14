<cfinclude template="/includes/_helpHeader.cfm">
<cfset title = "Specimen List">

<font size="-2"><a href="../index.shtml">Help</a> >> <strong>Specimen List</strong> </font><br />
<font size="+1">Specimen List</font><br/>
<font size="-2"><a href="#detail_level">Detail Level</a> | <a href="#berkeleymapper">Map Results</a> | <a href="#download">Download Data</a> | <a href="#remove_results">Remove Results</a></font>
<!--
<table align="left" border="1" bordercolor="#191970" cellspacing="1" cellpadding="5">
<tr><td>
	<a href="#detail_level">Detail Level</a><br/>
	<a href="#berkeleymapper">Map Results</a><br/>
	<a href="#download">Download Data</a><br/>
	<a href="#remove_results">Remove Results</a><br/>

</td></tr></table>
-->
<p>This form lists specimens that match the criteria of your query.
The first column displays the catalog number as a link
to the individual specimen record.
Individual specimen records display or link to virtually everything 
that has been recorded about a specimen.</p>

<p><a name="detail_level"><strong>Detail Level:</strong></a> There are four levels of detail available on the Specimen Results page. 
Level 1 is basic summary data and the default setting; 
Level 4 is most of the data available for a specimen and probably of little use
for anything except downloading specific attributes.
  
You can control detail level with the buttons at the bottom of Specimen Results, 
or you can set a higher default value from the Advanced Features page.</p>
<table border="1" bordercolor="191970" cellspacing="1">
	<tr>
	<td>Level 1</td><td>Level 2</td><td>Level 3</td><td>Level 4</td></tr>
	<tr valign="top">
	<td>Catalog&nbsp;Number<br />
    Scientific Name<br />
    Country<br />
    State<br />
    Specific Locality<br />
    Parts<br />
    Sex</td>
	<td>AF Number<br />
    Other Identifiers<br />
    Accession<br />
    Collectors<br />
    Latitude and Longitude<br />
    Map Name<br />
    Feature<br />
    County<br />
    Specimen Remarks<br />
    Specimen Disposition</td>
	<td>Attributes<br/></td>
	<td>Attribute Details<br/>
   	Coordinate Details<br />
   	Decimal Latitude and Decimal Longitude<br />
    Other Identifiers in individual columns<br /></td>	
	</tr> 
</table>

<p><a name="berkeleymapper"><strong>Map Results:</strong></a> 
Clicking on the "<a href="http://berkeleymapper.berkeley.edu/run.php">BerkeleyMapper</a>" 
button sends records that include latitude and longitude to a map server at 
the University of California at Berkeley.
Text at the top of the Specimen Results List tells you how many records in your 
result list include latitude and longitude.
(You can also use BerkeleyMapper from individual specimen records, or set
BerkeleyMapper as the direct output from Specimen Search.)</p>

<p><a name="download"><strong>Download Data:</strong></a> 
Data can be downloaded from Specimen Result List as a tab-delimited file.
The downloaded data will be the same as those displayed. 
If you want more data or less data, then adjust the 
<a href="#detail_level">Detail Level</a>.
When you click on the Download button at the bottom of the page,
you will be taken through a form which requires you to
(1) give us more information about yourself and
(2) agree that the data will not be repackaged, redistributed, or sold.</p>

<p><a name="remove_results"><strong>Remove Results:</strong></a>
Because the records listed on this screen are sometimes passed to
some form of report (<i>e.g.</i>, BerkeleyMapper, downloads, specimen labels),
you can add a column to the Specimen Results grid that allows you to remove 
individual records from the result set. 
This feature must be turned on in Advanced Features.
Use the checkboxes on the undesired rows, then click the scissors icon at the top of the column.
(This re-executes your query but includes the clause(s) "AND NOT Collection_Object_id = 99999.") 
</p>

<cfinclude template="/includes/_helpFooter.cfm">