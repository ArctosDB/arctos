<cfinclude template="/includes/_helpHeader.cfm">
<cfset title = "Higher Geography">
<font size="-2"><a href="index.cfm">Help</a> >> <a href="definitions_standards_index.cfm">Definitions and Standards</a> >> <strong>Higher Geography</strong></font><br />
<font size="+2">Higher Geography</font>
<p>
<table border="0" align="left" cellpadding="10">
<tr><td>
	<cfinclude template="includes/higher_geography_idx.cfm">
</td></tr></table>
Higher geography is most often seen as a concatenation of of geopolitical subdivisions.
These are ordered from  broadest to  most specific. 
The concatenated term is built from nine separate columns.
<p>Each <a href="locality.cfm">Locality</a> is related to a record in Higher Geography
that has been picked by the creator of the locality.  
If there is no appropriate Higher Geography record for a 
locality, then a new record must be created. This requires
priviliged access to the database.
Higher Geography should always include as much specific information as 
is provided with the Verbatim Locality.  
For example, if the Verbatim Locality is "near Snoqualmie Pass, King County, 
Washington", then the data entry person should pick the Higher Geography 
record that has "North America, United States, Washington, King County."  
If this record does not exist, then a new record 
must be created (rather than choosing the record that says only  
"North America, United States, Washington"). </p>
<table width="600" border="1" cellspacing="1" cellpadding="2">
   <tr>
    <th scope="col">Category</th>
    <th scope="col">Examples</th>
    <th scope="col">Short Definition </th>
  </tr>
  <tr>
    <td><a href="#continent_ocean">Continent/Ocean</a></td>
    <td>North America, Arctic Ocean </td>
    <td>A set of all-inclusive and  mutually exclusive divisions of the globe. </td>
  </tr>
  <tr>
    <td><a href="#country">Country</a></td>
    <td>United States, Iraq, Tibet</td>
    <td>Usually obvious, but not always. </td>
  </tr>
  <tr>
    <td><a href="#state_province">State/Province</a></td>
    <td>Florida, Magadanskaya oblast </td>
    <td>Primary subdivision of a country. </td>
  </tr>
  <tr>
    <td><a href="#sea">Sea</a></td>
    <td>Bering Sea, Gulf of Mexico </td>
    <td>A subdivision of an Ocean. </td>
  </tr>
  <tr>
    <td><a href="#county">County</a></td>
    <td>Lincoln County, Cajun Parish </td>
    <td>County, parish, or equivalent subdivision of a state or province. </td>
  </tr>
  <tr>
    <td><a href="#map_name">Map Name (Quad)</a></td>
    <td>Fairbanks, Beaver </td>
    <td>Names of quadrangles delineated by USGS 1:250,00 map series.</td>
  </tr>
  <tr>
    <td><a href="#feature">Feature</a></td>
    <td>Kenai National Wildlife Refuge, Anza Borrego State Park </td>
    <td>Miscellaneous named  entities below the level of state. </td>
  </tr>
  <tr>
    <td><a href="#island_group">Island Group</a></td>
    <td>Alexander Archipelago, Franz Joseph Land </td>
    <td>A named group of islands. </td>
  </tr>
  <tr>
    <td><a href="#island">Island</a></td>
    <td>Kodiak Island, Svalbard </td>
    <td>A single island.</td>
  </tr>
</table></p>

<p>
<a name="continent_ocean" class="infoLink" href="#top">Top</a><br>
<strong>Continent/Ocean:</strong> 
All records in Higher Geography have a value in this field. 
A record with the value &quot;no higher geography&quot; is applied to
specimens with no geographic data. Western 
Russia is in Europe, eastern Russia is in Asia. </p>
<table width="400" border="1" cellspacing="1" cellpadding="2">
  <tr>
    <th scope="col"><a href="#terrestrial_marine">Terrestrial</a></th>
    <th scope="col"><a href="#terrestrial_marine">Marine</a></th>
  </tr>
  <tr>
    <td><div align="center">North America </div></td>
    <td><div align="center">North Pacific Ocean </div></td>
  </tr>
  <tr>
    <td><div align="center">Central America </div></td>
    <td><div align="center">South Pacific Ocean </div></td>
  </tr>
  <tr>
    <td><div align="center">South America </div></td>
    <td><div align="center">Arctic Ocean </div></td>
  </tr>
  <tr>
    <td><div align="center">Europe</div></td>
    <td><div align="center">South Atlantic Ocean </div></td>
  </tr>
  <tr>
    <td><div align="center">Asia</div></td>
    <td><div align="center">North Atlantic Ocean </div></td>
  </tr>
  <tr>
    <td><div align="center">Africa</div></td>
    <td><div align="center">&nbsp;</div></td>
  </tr>
  <tr>
    <td><div align="center">Australia</div></td>
    <td><div align="center"><strong>Missing Data</strong></div></td>
  </tr>
  <tr>
    <td><div align="center">Antarctica</div></td>
    <td><div align="center">no higher geography </div></td>
  </tr>
</table></p>

<p>
<a name="country" class="infoLink" href="#top">Top</a><br>
<strong>Country</strong> is a familar concept,
though various territorial claims complicate reality.
We currently recognize Greenland as a country and not as a state in Denmark.
(It would not occur to most users to search for muskox from Denmark.)</p>


<p>
<a name="state_province" class="infoLink" href="#top">Top</a><br>
<strong>State/Province:</strong> 
These are primary subdivisions of a country, be they states, provinces, departments,
or okrugs.  Format for Russia is transliteration.
<ul>
		<li><strong>Example:</strong> Magadanskaya oblast</li>
		<li><strong>Not:</strong> Magadan district</li>
		<li><strong>Not:</strong> Madanskaya Oblast</li>
		<li><strong>Example:</strong> Baja California Norte</li>
</ul>
</p>

<p>
<a name="sea" class="infoLink" href="#top">Top</a><br>
<strong>Seas</strong> are defined as primary divisions of 
<a href="#continent_ocean">oceans</a>
but not all oceanic regions are included in a Sea. 
For example, the waters north of Point Barrow, Alaska are in 
the Arctic Ocean but are in neither the Chukchi nor Bering seas. 
Similarly, the coastal waters of California, and the east coast 
of Japan can be designated only as North Pacific Ocean. 
There have been efforts to formally delineate seas and oceans 
(e.g., the U. S. Navy's "Chart of Seas and Oceans" and the U. S.
Defense Intelligence Agency's "Geopolitical Data Elements and Related Features")
These should be consulted if there is a question about whether a locality
is appropriately included in a particular sea, though in their
effort to be comprehensive they occasionally offend common sense.</p>

<p>
<a name="county" class="infoLink" href="#top">Top</a><br>
<strong>Counties:</strong> 
Localities within the United States (except <a href="#map_name">Alaska</a>) should be 
referenced to county, parish or equivalent political subdivision.   
Counties also may be used for countries besides the U.S. (e.g., United Kingdom).</p>

<p>
<a name="map_name" class="infoLink" href="#top">Top</a><br>
<strong>Map Name (Quad):</strong> 
The name of the U. S. Geological Survey maps in the 1:250,000 series.  
Because Alaska lacks anythings as inclusive counties, "quads" have
been used extensively in organizing the collection and interrogating data.
See the 
<cfoutput >
	<a href="#Application.ServerRootUrl#/info/quad.cfm">user help document</a> 
</cfoutput>

on Map Name for a complete listing of names plus regional maps.</p>

<p>
<a name="feature" class="infoLink" href="#top">Top</a><br>
<strong>Feature:</strong> Features include entities such as parks, preserves, refuges, 
 and other delineated geo-political features. 
Feature may also be used to describe recognized 
<a href="#island_group">sub-groups of islands</a>. 
Many administrative units included in Feature
(e.g., Alaska Game Management Units)
 have ephemeral boundaries, if not an ephemeral existance.
Their past and future use may be inconsistent.
Therefore, avoid using Feature if the locality is well
georeferenced and/or unequivocal in the absence of Feature.</p>

<p>
<a name="island_group" class="infoLink" href="#top">Top</a><br>
<strong>Island Group</strong> 
is defined as the largest island group or 
Archipelago to which an island belongs. 
Island groups within island groups should be indicated in 
<a href="#feature">Feature</a>. 

<table width="600" border="1" cellspacing="1" cellpadding="2">
  <tr>
    <th scope="col">Sea</th>
    <th scope="col">Island Group </th>
    <th scope="col">Feature</th>
    <th scope="col">Island</th>
  </tr>
  <tr>
    <td><div align="center">Bering Sea </div></td>
    <td><div align="center">Aleutian Islands </div></td>
    <td><div align="center">Andreaonof Islands </div></td>
    <td><div align="center">Adak Island </div></td>
  </tr>
</table>
</p>

<p>
<a name="island" class="infoLink" href="#top">Top</a><br>
<strong>Island:</strong>
When a locality includes an island name, and the locality is on or near an island, 
then the name of the island should be included in this field.
An island is included in this field if a locality has the word "island" in
its proper name even though (depending on the tides) it may be a peninsula.
(Rhode Island is nevertheless a state.)
An offshore locality that is associated with, and near, an island should include 
the island.  
For example, if the Verbatim Locality is "100 yds off of the beach, 
Bay Farm Island, Alameda Co., California", then the Higher Geography 
record should include: 
<table width="600" border="1" cellspacing="1" cellpadding="2">
  <tr>
    <th scope="col">Country</th>
    <th scope="col">State</th>
    <th scope="col">County</th>
    <th scope="col">Island</th>
	<th scope="col">Specific Locality</th>
  </tr>
  <tr>
    <td><div align="center">United States</div></td>
    <td><div align="center">California</div></td>
    <td><div align="center">Alameda County</div></td>
    <td><div align="center">Bay Farm Island</div></td>
	<td><div align="center">100 yds off of the beach, Bay Farm Island</div></td>
  </tr>
</table>
On the other hand, a locality description may include an island only as a point of reference, 
<i>e.g.,</i>&quot;456 nautical miles SSE of Midway Island.&quot;
In this case, inclusion of data in the island field is inappropriate.

<p>The island name should be included in the island field even though it 
may be the same as the specific locality, <i>e.g.,</i>

<table width="600" border="1" cellspacing="1" cellpadding="2">
  <tr>
    <th scope="col">Country</th>
    <th scope="col">State</th>
    <th scope="col">County</th>
    <th scope="col">Island</th>
	<th scope="col">Specific Locality</th>
  </tr>
  <tr>
    <td><div align="center">United States</div></td>
    <td><div align="center">California</div></td>
    <td><div align="center">Alameda County</div></td>
    <td><div align="center">Pin Head Island</div></td>
	<td><div align="center">Pin Head Island</div></td>
  </tr>
</table>

</p>

<p>Names should be spelled out, including the word &quot;island&quot; when it is part of the name. Some valid island names:
<ul>
		<li>Saint Lawrence Island</li>
		<li>Spitzbergen</li>
		<li>Dangerous Reef</li>
</ul>

There are some unnamed islands specified by their latitude and longitude; 
treatment of a theoretical example is shown below. 
<table width="600" border="1" cellspacing="1" cellpadding="2">
  <tr>
    <th scope="col">Sea</th>
    <th scope="col">Island Group </th>
    <th scope="col">Feature</th>
    <th scope="col">Island</th>
  </tr>
  <tr>
    <td><div align="center">Bering Sea </div></td>
    <td><div align="center">Aleutian Islands </div></td>
    <td><div align="center">Andreaonof Islands </div></td>
    <td><div align="center">unnamed island </div></td>
  </tr>
</table></li>
</ul>
</p>
<p>
<a name="terrestrial_marine" class="infoLink" href="#top">Top</a><br>
<strong>Terrestrial versus marine descriptors:</strong> 
Coastal localities should be described with terrestrial descriptors.
For offshore localities, the Higher Geography should include at least the ocean 
in <a href="#continent_ocean">Continent/Ocean</a> and, 
if applicable, it should also include 
<a href="#sea">Sea</a>.</p> 
<cfinclude template="/includes/_helpFooter.cfm">