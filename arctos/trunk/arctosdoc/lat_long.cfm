<cfinclude template="/includes/_helpHeader.cfm">
<cfset title = "Arctos Help: Latitude and Longitude">

<font size="-2"><a href="index.cfm">Help</a> >> <a href="definitions_standards_index.cfm">Definitions and Standards</a> >> <strong>Latitude and Longitude</strong></font><br />
<font size="+1">Latitude and Longitude</font>
<p>
<table border="0" align="left" cellpadding="10">
<tr><td>
	<cfinclude template="includes/lat_long_idx.cfm">
</td></tr></table>
The application of latitudes and longitudes to verbal locality data is called georeferencing.
Latitude describes a position in degrees north or south of the equator.
Longitude describes a  position in degrees east or west of the Greenwich meridian.  
However, coordinates alone are of limited use without information on uncertainty
and the coordinate frame of reference (datum). 
The most thoroughly documented protocol for georeferencing  natural history collections
is the 
<a href="http://dlp.cs.berkeley.edu/manis/GeorefGuide.html">MaNIS Georeferencing Guidelines</a>,
which are also indexed <a href="#manis">below</a>. 
See also:<br/>
Chapman, A.D. and J. Wieczorek (eds). 2006. Guide to Best Practices for Georeferencing. Copenhagen: Global Biodiversity Information Facility.
<!--- broken link
(<a href="http://circa.gbif.net/irc/DownLoad/kderA1JDmRGBb4Gu1iPXPI0TcKfd8BcG/er6YRxozPUqShImuUCm9wVNb2hCxN0tr/YqSpi_SR/Georeferencing%20Best%20Practices.pdf">Download PDF</a>)
--->
<br/>
&nbsp;<br/>
Georeferences are treated as determinations.
That is, someone at some time determined these data, 
and more than one such opinion can be retained.
Thus, a locality may have several determinations that differ from each other
because the determiners have interpreted the verbatim locality differently,
or because original data are potentially incorrect.
<p>
<div class="fldDef">
	Lat_Long . Orig_Lat_long_Units<br/>
	VARCHAR(20) null<br/>
	ctlat_long_units<br/>
	DarwinCore2=<br/>
	&nbsp; &nbsp; VerbatimCoordinateSystem
</div>
<a name="original_units" class="infoLink" href="#top">Top</a><br>
<strong>Original Units</strong>
vary with the source of the data.
Coordinates are stored and displayed in their original format. 
Except for UTMs, coordinates are also translated to, and stored as, decimal 
degrees for standardization and mapping.
There is not yet programming to convert UTMs to decimal degrees.
Include as many digits of precision as are provided in the original data.
The format must be selected from the following choices:
<table border="1" bordercolor="#191970" cellpadding="5">
	<tr><td><div align="center"><strong>Format</strong></div></td><td><div align="center"><strong>Fairbanks, Alaska</strong></div></td><td><div align="center"><strong>Description</strong></div></td></tr>
	<tr><td>Degrees, minutes and seconds</td><td>&nbsp;64&deg;&nbsp;50'&nbsp;15"&nbsp;N<br/> 147&deg;&nbsp;43'&nbsp;08'&nbsp;W</td>
	<td><p>The traditional Royal Navy standard in which degrees are divided 
	into 60 minutes, and minutes are in turn divided into 60 seconds.
	Seconds can include decimal fractions.</p>
	  </td>
	</tr>
	<tr><td>Degrees and decimal minutes</td><td>&nbsp;64&deg;&nbsp;50.24'&nbsp;N<br/> 147&deg;&nbsp;43.13'&nbsp;W</td>
	<td>Degrees are given as integers, but minutes are given with decimal fractions.</td>
	</tr>
	<tr><td>Decimal degrees</td><td>&nbsp;&nbsp;64.8374&deg;<br/> -147.7188&deg;</td>
	<td>The standard for Geographic Information Systems (GIS) in which coordinates are only in degrees, 
		including decimal fractions thereof. Points of the compass are not included
		because latitudes south of the equator and longitudes west of Greenwich have negative values.</td></tr>
	<tr><td>Universal Transverse Mercator (<a href="http://www.uwgb.edu/DutchS/FieldMethods/UTMSystem.htm">UTM</a>)</td>
	<td>465898E<br/>7190521N<br/> Zone 6 </td>
	<td><p>UTM coordinates are a grid system based upon a cylindrical projection 
	of the earth's surface.
	Enter the complete data into the fields labeled "UTM_Zone", "UTM_EW" and "UTM_NS".  
	    The UTM Zone often is omitted in original data, but can be determined from 
      Higher Geography.</p>
	  </td>
	</tr>
</table></p>

<p>Coordinates are stored and displayed in their original format. 
Also, they are translated to, and stored as, decimal 
degrees for mapping and exportation to federated portals.
Include as many digits of precision as are provided in the original data.</p>

<p>
<div class="fldDef">
	Lat_Long . Datum<br/>
	VARCHAR(40) null<br/>
	ctdatum<br/>
	DarwinCore2=GeodeticDatum
</div>

<a name="datum" class="infoLink" href="#top">Top</a><br>
<strong>Datum:</strong> The geodetic datum to which the latitude and longitude refer.
A geodetic datum describes the size, shape, origin, and orientation 
of a coordinate system for mapping the earth.  
Latitude and longitude data referenced to the wrong datum can result in 
positional errors of hundreds of meters.  
Therefore, when providing latitude and longitude data, 
it is important to know from which datum those data are derived. 
Most GPS units allow you to select the geodetic data from which its 
coordinates will be determined (default usually set to WGS84, but this 
should be checked in the field). 
Maps and gazetteers generally provide this information as well. </p>
<p>
<div class="fldDef">
	Lat_Long . Lat_Lon_Ref_Source<br/>
	VARCHAR(255) not null<br/>
	ctLat_Long_Ref_Source<br/>
	DarwinCore2=GeoreferenceSources
</div>
<a name="source" class="infoLink" href="#top">Top</a><br>
<strong>Source(s)</strong> 
refers to the source of the coordinates and not to the source of the error. 
Coordinates may be original data collected with the specimen, or they
may be provided by after-the-fact georeferencing efforts.
In the latter situation, data in Source(s)
should be specific enough to allow anyone in the future to use the 
same resources to validate the coordinates, or to georeference the same locality.
These data might be a list of maps, gazetteers or other resources used 
to georeference the locality. 
Examples:</p>
	<ul>
		<li>USGS 1:24000 Florence Montana Quad</li>
		<li>Dictionary of Alaska Place Names (Orth, 1967)</li>
		<li>Geographic Names Canada (NRC website)</li>
		<li>Geographic Names Information System (USGS website)</li>
	</ul>
In cases where the coordinates are original data, a description of 
the original source should be provided.
Again, these data should make the coordinates as verifiable as possible
by referring to records associated with the specimen.
Examples:
	<ul>
		<li>collector's notation</li>
		<li>preparator's notation</li>
		<li>specimen label</li>
		<li>accession file</li>
		<li>global positioning system (download)</li>
		<li>global positioning system (transcription)</li>
	</ul>
</p>	

<p>
<div class="fldDef">
	Lat_Long . GPSAccuracy<br/>
	NUMERIC(8,3) null
</div>
<a name="gps_accuracy" class="infoLink" href="#top">Top</a><br>
<strong>GPS Accuracy</strong> 
is the error reported by a Global Positioning System.
The original units for this distance should be recorded in the GPS 
Units field unless the GPS does not report accuracy, 
in which case a default GPS Accuracy of 30 m should be used under 
normal reception conditions. 
GPS Accuracy can be null, but it cannot be zero.
See <a href="http://dlp.cs.berkeley.edu/manis/GeorefGuide.html#gps_accuracy">discussion</a>.</p>

<p>
<div class="fldDef">
	Lat_Long . GPS_distance_units<br/>
	VARCHAR(20) null
</div>
<a name="gps_distance_units" class="infoLink" href="#top">Top</a><br>
<strong>GPS Units</strong> 
The GPS Units are original distance units for the GPS Accuracy reading. </p>
	
<p>
<div class="fldDef">
	Lat_Long . Extent<br/>
	NUMERIC(8,3) null
</div>	
<a name="extent" class="infoLink" href="#top">Top</a><br>
<strong>Extent</strong> 
of a named place is one component contributing to the value of Maximum Uncertainty.
It is a measure of the size of the feature of origin in the specific locality - the distance 
from the point defined by the coordinates to the outer perimeter of the feature of origin 
(e.g., from the center of town to the farthest point on the city limits). 
If the coordinates are taken from a GPS, then the extent is the distance from the point 
where the GPS coordinates were taken to the furthest distance from that point in which 
collection occurred (e.g., the distance to the furthest trap in a trap line from where 
the coordinates were taken). 
Extent and Maximum Uncertainty must share the same units. 
Extent cannot be zero if GPS Accuracy is null.
See <a href="http://dlp.cs.berkeley.edu/manis/GeorefGuide.html#extent_of_locality">discussion</a>.</p>

<p>
<div class="fldDef">
	Lat_Long . Max_Error_Units<br/>
	VARCHAR2(2) null
</div>
<a name="maximum_error_units" class="infoLink" href="#top">Top</a><br>
<strong>Distance Units</strong> 
The units for Extent and Maximum Uncertainty can be:
	<cf_getCodeTable table="ctlat_long_error_units" format="list">
The units should match those in the original description, 
because uncertainties due to distance precision depend on the units. 
For most usage, including exportation to federated portals, 
these data are converted meters.</p>

<p>
<div class="fldDef">
	Lat_Long . Max_Error_Distance<br/>
	NUMBER null<br/>
	DarwinCore2=<br/>
	&nbsp; &nbsp; CoordinateUncertaintyInMeters<br/>
</div>
<a name="maximum_error" class="infoLink" href="#top">Top</a><br>
<strong>Maximum Uncertainty Distance</strong> 
is the upper limit of the horizontal (as opposed to elevational) distance from the 
given latitude and longitude.
It describes a circle within which the 
whole of the described locality lies. 
Leave the value empty if the uncertainty is unknown, cannot be estimated, 
or is not applicable (because there are no coordinates). 
Zero is not a valid value. 
Maximum Uncertainty cannot be less than the sum of the Extent and the GPS Accuracy 
converted to the Uncertainty Units.</p>

<p>This is a simple concept, but there are several sources of error which, 
when combined, often result in underestimation of error. 
These are enumerated in the MaNIS Guidelines, and are combined into 
estimates of total error by the Georeferencing Calculator.</p>

<p>In some circumstances the greatest source of error is the behavior 
of the collector and/or any intermediary sources of the data. 
For example, if a locality names a village, the collector may have obtained 
specimens from a resident who forages over a large area near the village. 
The collector may even have provided coordinates for the village, 
often from some standard source, implying specificity equal to the extent of the village. 
Estimating error can therefore be subjective, and conservative interpretation 
demands large values for Maximum Uncertainty. 
To avoid ambiguous or misleading locality descriptions, 
see MVZ's <a href="http://mvz.berkeley.edu/Locality_Field_Recording.html">
guidelines</a>.</p>

<p>For most usage, including exportation to federated portals, the value 
for Maximum Uncertainty is converted from the original units (recorded here) 
to the value in meters.</p>

<p>
<div class="fldDef">
	Lat_Long . Determined_By_Agent_id<br/>
	INT not null
</div>
<a name="determiner" class="infoLink" href="#top">Top</a><br>
<strong>Determiner</strong>
is the agent (usually a person) who determined that these coordinates
and measures of uncertainty apply to this locality.
Often, this is the collector or, dear reader, you.
The form will load with the currently logged-in user as a default for new records.</p>
<p>Sometimes, a determination is developed by two or more successive agents.
For example, one agent might locate a named place and provide the coordinates, 
but little or no information about the uncertainty. 
A second agent might then evaluate the determination 
(mapping it and comparing it to the Verbatim Locality) and then develop a Maximum Uncertainty.
In this case, we assume that the second agent has re-evaluated the coordinates, 
and the determination is considered to have been made by the second agent 
(<i>i.e.,</i> the agent who last modified the determination).
If there is a need to maintain the identity of the first agent, then the second agent
should create a second (separate) determination.</p>

<p>If the collector offered a determination in the original data, this determination
should not be modified even if it is no longer the accepted determination.

<p>
<div class="fldDef">
	Lat_Long . Determined_Date<br/>
	DATETIME null
</div>
<a name="date" class="infoLink" href="#top">Top</a><br>
<strong>Determination Date</strong>
is the day the determination was made.
If this is unknown, an approximation is adequate.
Entry/editing forms should load with the current date as a default for new records.</p>

<p>
<div class="fldDef">
	Lat_Long . Protocol<br/>
	VARCHAR(40) null<br/>
	DarwinCore2=GeoreferenceProtocol
</div>
<a name="protocol" class="infoLink" href="#top">Top</a><br>
<strong>Georeferencing Protocol</strong> 
Georeferencing Protocol describes a formal method for 
determining coordinates and associated information. 
Examples of georeferencing protocols are "MaNIS Georeferencing Guidelines," 
"MaPSTeDI," "GeoLocate," "INRAM," "BioGeomancer," and "GBIF Best Practices." 
If the protocol is not known, choose "not recorded."</p>

<p>
<div class="fldDef">
	Lat_Long . VerificationStatus<br/>
	VARCHAR(40) not null<br/>
	ctverificationstatus<br/>
	DarwinCore2=<br/>
	&nbsp; &nbsp; GeoreferenceVerificationStatus
</div>
<a name="verification_status" class="infoLink" href="#top">Top</a><br>
<strong>Verification Status:</strong> 
A categorical description of the extent to which the georeference has been 
verified to represent the location where the specimen or observation was collected. 
This element should be vocabulary-controlled. Accepted values:
<cf_getCodeTable table="ctverificationstatus" format="list">

<p>"Verified by collector" indicates that the person who removed the specimen
from nature has looked at the coordinates and uncertainty represented
on an appropriately scaled map, and believes that these data are accurate 
and that the represented uncertainty is as small as possible.</p>

<p>
<div class="fldDef">
	Lat_Long . Accepted_Lat_Long_fg<br/>
	TINYINT not null
</div>
<a name="accepted" class="infoLink" href="#top">Top</a><br>
<strong>Accepted?</strong> 
There can be more than one georeferencing determination per locality
but only the accepted determination is routinely displayed.
You can revert to an earlier determination by changing
its <i>accepted</i> flag from "no" to "yes."</p>

<p>
<div class="fldDef">
	Lat_Long . Lat_Long_Remarks<br/> 
	VARCHAR2(4000) null<br/>
	DarwinCore2=GeoreferenceRemarks
</div>
<a name="remarks" class="infoLink" href="#top">Top</a><br>
<strong>Remarks</strong>
about the spatial description determination, explaining assumptions made in addition or opposition to the those formalized in the method referred to in Georeferencing Protocol.</p>

<p><table  border="1" cellpadding="3" bordercolor="midnightblue">
<tr><td><center><a name="manis"><font size="+2">MaNIS Georeferencing Guidelines<br />Table of Contents</font></a></center>
	<ul>
		<li><a href="http://dlp.cs.berkeley.edu/manis/GeorefGuide.html#det_lat_long"><strong>Determining Latitude &amp; Longitude</strong></a></li>
			<ul>

				<li><a href="http://dlp.cs.berkeley.edu/manis/GeorefGuide.html#named_places">Named Places</a></li>
				<li><a href="http://dlp.cs.berkeley.edu/manis/GeorefGuide.html#offsets">Offsets</a></li>
				<li><a href="http://dlp.cs.berkeley.edu/manis/GeorefGuide.html#vagueness">Vagueness</a></li>
			</ul>
		<li><a href="http://dlp.cs.berkeley.edu/manis/GeorefGuide.html#det_error"><strong>Determining Error Distance from Uncertainties</strong></a></li>
			<ul>
				<li><a href="http://dlp.cs.berkeley.edu/manis/GeorefGuide.html#extent_of_locality">extent of a locality</a></li>

				<li><a href="http://dlp.cs.berkeley.edu/manis/GeorefGuide.html#gps_accuracy">GPS accuracy</a></li>
				<li><a href="http://dlp.cs.berkeley.edu/manis/GeorefGuide.html#unknown_datum">unknown datum</a></li>
				<li><a href="http://dlp.cs.berkeley.edu/manis/GeorefGuide.html#imprecision_in_distance">imprecision in distance measurements</a></li>
				<li><a href="http://dlp.cs.berkeley.edu/manis/GeorefGuide.html#imprecision_in_coordinates">imprecision in coordinate measurements</a></li>
				<li><a href="http://dlp.cs.berkeley.edu/manis/GeorefGuide.html#map_scale">map scale</a></li>
				<li><a href="http://dlp.cs.berkeley.edu/manis/GeorefGuide.html#imprecision_in_direction">imprecision in direction measurements</a></li>

				<li><a href="http://dlp.cs.berkeley.edu/manis/GeorefGuide.html#combinations_of_uncertainties_distances">combinations of uncertainties: distances</a></li>
				<li><a href="http://dlp.cs.berkeley.edu/manis/GeorefGuide.html#combinarions_of_uncertainties_directions">combinations of uncertainties: distance and direction</a></li>
			</ul>
		<li><a href="http://dlp.cs.berkeley.edu/manis/GeorefGuide.html#summary"><strong>Summary</strong></a></li>
		<li><strong>Appendices</strong></li>
			<ul>
				<li><a href="http://dlp.cs.berkeley.edu/manis/GeorefGuide.html#glossary"><strong>Glossary</strong></a></li>

				<li><a href="http://dlp.cs.berkeley.edu/manis/GeorefGuide.html#essential_attributes"><strong>Essential Attributes of Coordinate Data</strong></a></li>
				<li><a href="http://dlp.cs.berkeley.edu/manis/GeorefGuide.html#calculation_examples"><strong>Calculation Examples</strong></a></li>
					<ul>
						<li><a href="http://dlp.cs.berkeley.edu/manis/GeorefGuide.html#coordinates_only">Coordinates Only</a></li>
						<li><a href="http://dlp.cs.berkeley.edu/manis/GeorefGuide.html#named_place_only">Named Place Only</a></li>
						<li><a href="http://dlp.cs.berkeley.edu/manis/GeorefGuide.html#distance_only">Distance Only</a></li>

						<li><a href="http://dlp.cs.berkeley.edu/manis/GeorefGuide.html#distance_along_a_path">Distance Along a Path</a></li>
						<li><a href="http://dlp.cs.berkeley.edu/manis/GeorefGuide.html#distance_along_orthogonal_directions">Distance Along Orthogonal Directions</a></li>
						<li><a href="http://dlp.cs.berkeley.edu/manis/GeorefGuide.html#distance_at_a_heading">Distance at a Heading</a></li>
					</ul>
			</ul>			
		<li><a href="http://dlp.cs.berkeley.edu/manis/GeorefGuide.html#references"><strong>References</strong></a></li>
	</ul>

</td></tr></table></p>
<cfinclude template="/includes/_helpFooter.cfm">
