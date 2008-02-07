<cfinclude template="/includes/_helpHeader.cfm">
<cfset title = "Localities">

<font size="-2"><a href="index.cfm">Help</a> >> <a href="definitions_standards_index.cfm">Definitions and Standards</a> >> <strong>Localities</strong></font><br />
<font size="+2">Localities</font>
<p>
<table border="0" align="left" cellpadding="10">
<tr><td>
<cfinclude template="includes/locality_idx.cfm">
</td></tr></table>

A locality is a specific place associated with one or more 
<a href="collecting_event.cfm">Collecting Events</a>.
Ultimately, each locality should be a unique circle in geographic space.
The center is a point defined by latitude and longitude, 
and the radius is a linear estimate of error.
For electronic mapping, we convert such data to
decimal degrees with estimates of error in meters.
Interfaces to the data are more flexible.</p>
<p>A locality has these related elements:
	<ul>
		<li>a  description of <a href="higher_geography.cfm">higher geography</a></li>
		<li>one or more <a href="lat_long.cfm">georeferencing determinations</a></li>
	</ul>
Unfortunately, not all localities are even crudely georeferenced. 
Thus much of the descriptive data is hierarchical 
(e.g., continent, country, state, county, specific locality). 
Applying coordinates and errors (georeferencing) to such 
descriptions is error-prone and even subjective. 
Therefore, multiple georeferencing determinations can be applied to a single locality
even though only the "accepted" determination is routinely displayed.</p>

<p>Some caveats:
<ul>
<li>A locality documents one <i>or more</i> collecting events.</li>
<li>Separate but similar localities may differ only in the extent of their respective errors.
For example, if the specific locality "Barrow" is given for a lemming, it would be reasonable 
to assume the animal came from right in Barrow, or from somewhere on the limited road system
around Barrow. Five kilometers might be appropriate.
If Barrow were given for the specific locality of a bowhead whale, then an appropriate error
might be more like 50 kilometers because whalers travel several tens of kilometers.
In both cases, the latitude, longitude, specific locality, and higher geography are potentially
identical.</li>
<li>There are important differences between a Locality and a
<a href="collecting_event.cfm#verbatim_locality">Verbatim Locality</a>, 
though the verbage may often be the same.</li>
</ul>

<p>
<div class="fldDef">
	Locality . Spec_Locality<br/>
	VARCHAR2 (255) null
</div>
<a name="specific_locality" class="infoLink" href="#top">Top</a><br>
<strong>Specific Locality</strong>
refers to the locality from which the specimen 
was collected from the wild,  regardless of whether the animal was brought into 
captivity and killed at a different time and place.  
If the wildcaught locality is not known, put the location where the animal died, 
was killed, or was purchased (e.g., the zoo, aviary, pet store, lab, or market) 
in the Specific Locality field 
(see <a href="collecting_event.cfm">Collecting Events</a> for more details). 

<ol>
<li>When writing Specific Localities, the highest priority should be to 
maximize clarity and minimize confusion for a global audience.
</li>

<li> Do not include higher geography (continent, ocean, sea, island group, 
island, country, state, province, county, feature) in the Specific Locality 
unless it references a place name in another geopolitical subdivision, in which 
case include that subdivision in parentheses. The following example is located in California.
	<ul>
	<li><b>Example:</b> 10 mi below Ehrenberg (Arizona), Colorado River</li>
	</ul>
</li>
<li>There some situations in which no Specific Locality is given, or no Specific
Locality would be appropriate.  For example, collecting events on the high seas 
which are specified by geographic latitude and longitude.
	<ul>
	<li><b>Example:</b> North Pacific Ocean, 45 52' 24" N, 165 21' 48" W</li>
	</ul>
Or a collecting event on an island that is specified in the Higher Geography.
	<ul>
	<li><strong>Example:</strong> USA, Alaska, Petersburg quad, Thorne Island</li>
	</ul>
In these examples, as well as in records for which appropriate data are missing, the correct value for Specific Locality is,
"<strong>No specific locality recorded.</strong>" 
(In contrast to a normal locality, this is a sentence and therefore 
begins with a captital letter and ends with a period.)
</li>
<li>Do not anglicize words in Verbatim Locality or Specific Locality.
The database supports Unicode, so the limitation is input devices (your keyboard!)
or possibly your operating system. 
	<ul>
	<li><strong>Example:</strong> Las Montañas del Norte</li>
	<li><strong>Not:</strong> Mountains of the North</li>
	<li><strong>Not:</strong> Las Montanas del Norte</li>
	</ul>
This standard challenges the flexibility of input methods, 
but increasingly foreign data can be received in Unicode, and 
for many editing needs one can cut and paste.
</li>
<li> Enter Township, Range, Section (TRS), Lat/Long, and elevation data in the separate fields provided for them (see below).  Do not enter TRS data in the Specific Locality field.
</li>
<li>If an obsolete name for a geographic place is given in Verbatim Locality, put the current name in Specific Locality, followed immediately by the obsolete name in parentheses after an "=".
	<ul><li><b>Example:</b> Whistler (=Alta Lake=Mons), N of Vancouver, British Columbia</li>
	</ul>
	In this example, Whistler has historically been known as Alta Lake and Mons 
</li>
<li>Specific Locality should start  with the most specific part of the locality and end with the most general.
	<ul>
	<li><b>Example:</b> 0.25 mi S and 1.5 mi W Mt. Edith, Big Belt Mts.</li>
	<li><b>Not:</b> Big Belt Mts., 0.25 mi S and 1.5 mi W Mt. Edith</li>
	</ul>
</li>
<li> Use 'and' rather than '&amp;' when describing multiple directions in localities. Do not omit the 'and' in favor of a comma or any other separator.
	<ul>
	<li><b>Example 1:</b> Lauterwasser Creek, 1 mi N and 6 mi E Berkeley
  	<li><b>Not:</b> Lauterwasser Creek, 1 mi N, 6 mi E Berkeley	
 	<li><b>Example 2:</b> between Davis and Sacramento</li> <li><b>Not:</b> between Davis &amp; Sacramento</li>
	</ul>
</li>
<li> Do not abbreviate directions when they are part of a place name.
	<ul>
	<li><b>Example:</b> S of West Lansing</li>
	<li><b>Not:</b> S of W Lansing</li>
	</ul>
</li>
<li> Use 'of 'to clarify the intention of a locality description.
<ul>
<li><b>Example:</b> S of West Lansing</li>
</ul>
</li>
<li> Enter distances in decimals, not as fractions.
<ul>
<li><b>Examples:</b> 1/2 = 0.5; 1/4 = 0.25; 1/8 = 0.125, 1/3 = 0.33, 2/3 = 0.67 </li>
</ul>
</li>
<li>Put a "0" before the decimal in distances between 0 and 1 units (e.g., 0.5 mi, 0.75 km).
</li>
<li> Put a period after an abbreviation unless it is a direction or a unit of measure (e.g., mi, N, yds, etc.).
<ul>
<li><b>Example:</b> 1 mi N junction of Hwy. 580 and Hwy. 80</li>
<li><b>Not:</b> 1 mi. N. jct. Hwys 580 &amp; 80</li>
</ul>
</li>
<li>Do not put a period at the end of the specific locality except as part of an abbreviation.
</li>
<li> Include parentheses when giving a description such as "by road" or "by air," and place the parenthetical between the direction and the named place that it modifies.
<ul>
<li><b>Example:</b> 1 mi N (by road) Berkeley</li>
</ul>
</li>
<li>Capitalize "Junction" only for proper names.  When not a proper noun, "junction" should be spelled out and followed by "with" or "of."
<ul>
<li><b>Example 1:</b> 10 km S junction of Hwy. 1 and Hwy. 5</li>
<li><b>Example 2:</b> junction of Strawberry Creek with Oxford Ave.</li>
</ul>
</li>
<li>Use only the following abbreviations:
<table BORDER="2" CELLSPACING="2" bordercolor="#191970">

<tr><th>Word or phrase</th> <th>Abbreviation</th> <th>Comment</th></tr>
<tr><td>yards</td> <td>yds</td> 
<td>If space permits, spell out non-metric units. <i>E.g.,</i>"yards"</td>
</tr>
<tr><td>feet</td> <td>ft</td> 
<td>If space permits, spell out non-metric units. <i>E.g.,</i>"feet"</td>
</tr>
<tr><td>meters</td> <td>m</td> <td>&nbsp;</td></tr>
<tr><td>miles</td> <td>mi</td> 
<td>If space permits, spell out non-metric units. <i>E.g.,</i>"miles"</td>
</tr>
<tr><td>kilometers</td> <td>km</td> <td>&nbsp;</td></tr>
<tr><td>east (of)</td> <td>E</td> <td>&nbsp;</td></tr>
<tr><td>west (of)</td> <td>W</td> <td>&nbsp;</td></tr>
<tr><td>north (of)</td> <td>N</td> <td>&nbsp;</td></tr> <tr><td>south (of)</td> <td>S</td> <td>&nbsp;</td></tr> <tr><td>northeast (of)</td> <td>NE</td> <td>&nbsp;</td></tr>
<tr><td>northwest (of)</td> <td>NW</td> <td>&nbsp;</td></tr>
<tr><td>southeast (of)</td> <td>SE</td> <td>&nbsp;</td></tr>
<tr><td>southwest (of)</td> <td>SW</td> <td>&nbsp;</td></tr> <tr>
  <td>approximately, about, near, <i>circa</i></td> 
  <td>ca.</td> <td>&nbsp;</td></tr>
<tr><td>Highway</td> <td>Hwy.</td> <td>Only as part of a proper noun (e.g., "Hwy. 1", but not "on the highway").</td></tr>
<tr><td>Route</td> <td>Rte.</td> <td>Only as part of a proper noun (e.g., "Rte. 66").</td></tr>
<tr><td>Provincia, Province</td> <td>Prov.</td> <td>&nbsp;</td></tr> <tr><td>Departmento</td> <td>Depto.</td> <td>&nbsp;</td></tr>
<tr><td>Road</td> <td>Rd.</td> <td>Only as part of a proper noun (e.g., "Sunset Rd.", but not "on the road" or "by road").</td></tr>
<tr><td>Mount</td> <td>Mt.</td> <td>Only as part of proper noun in which it is spelled out (e.g., "Mount Holyoke").</td></tr>
<tr><td>Mountains</td> <td>Mts.</td> <td>Only as part of a proper noun (e.g., Rocky Mts., but not "in the mountains N Lake Tahoe").</td></tr>
<tr><td>Number, Número</td> <td>No.</td> <td>&nbsp;</td></tr> <tr><td>Avenue</td> <td>Ave.</td> <td>&nbsp;</td></tr>
<tr><td>Boulevard</td> <td>Blvd.</td> <td>&nbsp;</td></tr>
<tr><td>United States</td> <td>U.S.</td> <td>e.g., U. S. Forest Service </td></tr>
<tr><td>University of California</td> <td>U.C.</td> <td>Should be followed by a modifer, e.g., U.C. Berkeley</td></tr>
<tr><td>Doctor</td> <td>Dr.</td> <td>e.g., Dr. Pearson's house.  Do not use for "Drive" (e.g., "Sunset Drive").</td></tr>
</table>
</li>
</ol></p>

<p>
		<div class="fldDef">
			Locality . Maximum_Elevation<br/>
			Locality . Minimum_Elevation<br/>
			NUMBER null<br/>
			&nbsp;<br/>
			Locality . Orig_Elev_Units<br/>
			VARCHAR2 (2) null<br/>
			ctorig_elev_units
		</div>
<a name="elevation" class="infoLink" href="#top">Top</a><br>		
<strong>Elevations</strong> 
are a height above mean sea level.
If elevational data are part of the verbatim locality, 
they should be entered into  
Minimum Elevation, Maximum Elevation, and Elevation Units (ft, m).  
If the Verbatim Locality contains an elevational range, e.g., 500-600 ft, 
these values should be entered into the minimum and maximum elevation fields, 
respectively. 
If a single elevation is given in Verbatim Locality, put that value in both 
the minimum and maximum elevation fields.</p>

<p>
	<div class="fldDef">
		Locality . Max_Depth<br/>
		Locality . Min_Depth<br/>
		NUMBER null<br/>
		&nbsp;<br/>
		Locality . Depth_Units<br/>
		VARCHAR2 (2) null<br/>
		ctdepth_units
	</div>
<a name="depth" class="infoLink" href="#top">Top</a><br>			
<strong>Depths</strong> 
are a distance below the surface of a body of water.
The body of water may or may not be at sea level, <i>e.g.,</i> a mountain lake.
If depth data are part of the verbatim locality, 
they should be entered three fields for elevation: 
Minimum Depth, Maximum Depth, and Depth Units (ft, m).  
If the verbatim locality contains an depth range, e.g., 500-600 ft, 
these values should be entered into the minimum and maximum depth fields, 
respectively. 
If a single depth is given in the verbatim locality, put that value in both 
the minimum and maximum elevation fields.</p>
<p></p>
<a name="nogeorefbecause" class="infoLink" href="#top">Top</a><br>			
<strong>NoGeorefBecause</strong> is should always be NULL for localities with coordinate determinations. 
Otherwise, it may be used to indicate problems with georeferencing the locality, resources needed to 
georeference, or anything else about the lack of coordinate determinations.
<p>
<a name="trs_data" class="infoLink" href="#top">Top</a><br>			
<strong>Township, Range, and Section (TRS)</strong> information is sometimes given for  localities. 
If TRS data are part of the Verbatim Locality, they should be entered into the 
TRS fields associated with Specific Locality in the database.  
Legal descriptions to 1 mile square sections have 4 parts: 
the Meridian, Range, Township and Section. 
Note that an official legal description is always written from the smallest 
scale to the largest.  
For example, the NW1/4 SE1/4, sec. 12, T11N, R15E, San Bernardino Meridian 
is the northwest quarter of the southeast quarter of section 12, Township 11 
North, Range 15 East, San Bernardino Meridian. 
This example describes a square 1/16th of a mile on each side.  
Collectors often neglect the Meridian in TRS data, and we do not store 
this information in the database because it can usually be inferred from 
the state and county.  
There are 6 fields in the database to accommodate TRS data: 
1) Township, 2) Township Direction, 3) Range, 4) Range Direction, 5) Section, and 6) Part.  
In the above example, the data would be entered as:
<ol>
<li> 11</li>
<li> N</li>
<li> 15</li>
<li> E</li>
<li> 12</li>
<li> NW1/4 SE1/4 (variations on section part may be: SE 1/4, "western half," NW corner, etc.)</li>
</ol>
<p>A thorough description of TRS data, along with a tool to translate them to 
latitude and longitude can be found at the following URL:
<a HREF="http://www.esg.montana.edu/gl/trs-data.html">www.esg.montana.edu/gl/trs-data.html</a>.</p>

<p>Download the Museum of Vertebrate Zoology's field <a href="download/FieldLocalities5.pdf">guidelines</a> (PDF)
for describing localities.</p>

<cfinclude template="/includes/_helpFooter.cfm">
