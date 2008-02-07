<cfinclude template="/includes/_pickHeader.cfm">
<cfoutput>
<cfif #content# is "cat_num">
	<cfset title="Catalog Number Help">
	Catalog number is the permanent number assigned by one of the collections to an item. 
	This is the number most often used to designate specimens in publication and specimens from the 
	University of Alaska Museum often have their catalog numbers prefixed with UAM. The Herbarium is an 
	exception and uses the prefix ALA.<P>The format for this field is an integer with no prefix.
	<p>You may also enter a comma-delimited list of catalog numbers.
</cfif>


<cfif #content# is "collector">
	<cfset title="Collector Help">
	Collector is the name of the person, group, or agency credited with collecting a specimen. 
	Most specimens have one or more names of people as their collector.
</cfif>

<cfif #content# is "scientific_name">
<cfset title="Scientific Name Help">
The taxon name is the scientific name of the organism. A genus, species, and subspecies may be specified. Substrings will return records containing the specified substring in any of these three fields.<br>For example, searching on &quot;mus&quot; would return records for the following taxa (among others):<p>Mus musculus<br>Mustela ...<br>Arborimus ...<p>For information on the taxonomy used here, including common names and synonomies, see <a href="/TaxonomySearch.cfm" target="_blank">Arctos Taxonomy</a>.
</cfif>

<cfif #content# is "common_name">
<cfset title="Common Name Help">
Common Names have been opportunistically entered into Arctos. Common Name entries should not be viewed as complete, authoritative, or necessarily common. There may be one, many, or no common names for any taxon name.
</cfif>

<cfif #content# is "other_id_num">
<cfset title="Other Identifier Help">
Other ID. You can use Other ID even if you do not specify the Other ID Type, but you must specify at least one other parameter. For example, Taxon Name = Microtus and Other ID = AF163890 will return the record with GenBank sequence accession = AF163890. You can also search on incomplete strings. Taxon Name = Microtus and Other ID = AF163 will return records that have GenBank sequence accessions beginning with AF163.
</cfif>

<cfif #content# is "year_collected">
<cfset title="Year Collected Help">
You must specify a range of years. To specify one year, enter that year for both values.<p>The format is a four digit number, e.g., 1996.
</cfif>

<cfif #content# is "state_prov">
<cfset title="State or Province Help">
Examples: Alaska, British Columbia,  Chukotka
</cfif>

<cfif #content# is "island">
<cfset title="Island Help">
Many Alaska specimens were collected on an island and there are some duplicate (and even triplicate) island names among the thousands of islands in Alaska. You may therefore need to specify some other paramater in order to get a particular &quot;Green Island.&quot;
</cfif>


<cfif #content# is "county">
<cfset title="County Help">
County refers to a division of a state or province such as a county, parish, or &quot;department.&quot; Although much of Alaska is incorporated as boroughs, these are not yet all-inclusive and are not used here. (See USGS map names.)
</cfif>

<cfif #content# is "af_number">
<cfset title="AF Number Help">
AF number is a catalog for the Alaska Frozen Tissue Collection. An individual animal will often have both an AF number and a catalog number. AF numbers have been used to specify UAM specimens in the GenBank database and in some publications.<P>The format for this field is an integer with no prefix.<p>You may also enter a comma-delimited list of AF numbers.
</cfif>

<cfif #content# is "accn_number">
<cfset title="Accessin Number Help">
Accn. number. An accession number refers to a group of (one or more) specimens received at one time from one source. Many specimens do not have an accession number. This search feature is included primarily for use by state and federal agencies seeking data on particular contributions.<p>The format for this field is a year with a decimal fraction. For example, the first accession in 1998 would be 1998.001
</cfif>

<cfif #content# is "spec_locality">
<cfset title="Specific Locality Help">
A description of the specific locality.
</cfif>

<cfif #content# is "quad">
<cfset title="Quad Help">
USGS map names are the names of the U.S. Geological Survey\'s 1:250,000 series maps. These form a grid over the entire state and are often intuitive, e.g., Nome, Barrow, Sitka, etc.<p>
<a href="http://www.uaf.edu/museum/mammal/dbf/southeast.html" target="_blank">Southeast Alaska</a>
<br><a href="http://www.uaf.edu/museum/mammal/dbf/southcentral.html" target="_blank">Southcentral Alaska</a>
<br><a href="http://www.uaf.edu/museum/mammal/dbf/southwest.html" target="_blank">Southwest Alaska</a>
<br><a href="http://www.uaf.edu/museum/mammal/dbf/interior.html" target="_blank">Interior Alaska</a>
<br><a href="http://www.uaf.edu/museum/mammal/dbf/western.html" target="_blank">Western Alaska</a>
<br><a href="http://www.uaf.edu/museum/mammal/dbf/northern.html" target="_blank">Northern Alaska</a>
</cfif>

<cfif #content# is "parts">
<cfset title="parts Help">
Search for specimens having the selected part. Most mammal specimens have multiple parts (ie, skin; skull). Note that parts includes frozen tissue samples.
</cfif>

<cfif #content# is "higher_taxa">
<cfset title="Taxonomy Help">
Search for any part of the full taxon name (ie, family or subspecies)'
</cfif>
	
<cfif #content# is "cited_sci_name">
<cfset title="Cited Scientific Name Help">
Cited Scientific Name is the name applied to a specimen in a publication.
It may or may not be the same as the currently accepted name for the 
specimen or for the taxon.
</cfif>

<cfif #content# is "accepted_sci_name">
<cfset title="Accepted Scientific Name Help">
Accepted Scientific Name is the name now applied to a cited specimen.
It may or may not be the same as the name applied to the specimen in a 
publication.
</cfif>

<cfif #content# is "download">
<cfset title="Download Help">
<h2>Download Help</h2>
<ul>
	<li>
		With most browsers, right-click on the "Download these data" link and choose "Save Link As..." to save the file to your hard drive. Clicking the link will generally open the text file in your browser.
	</li>
	<li>
		The first line of the file contains the column headings.
	</li>
	<li>
		Note that verbatim_date is a text (not date) datatype and may contain non-date values (ie, "fall 2002").
	</li>
	<li>
		The file name is UAMData_{your unique session identifier}.txt where {your unique session identifier} is an integer generated by the application which uniquely identifies your browser. This convention allows many users to simultaneousy create and download data.
	</li>
</ul>

</cfif>

<br><a href="javascript: void(0);" onClick="javascript: self.close()">Close this window</a>

</cfoutput>

<cfinclude template="/includes/_pickFooter.cfm">
