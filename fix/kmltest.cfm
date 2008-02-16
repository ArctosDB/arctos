 <cfscript>
/**
 * Converts degrees to radians.
 * 
 * @param degrees 	 Angle (in degrees) you want converted to radians. 
 * @return Returns a simple value 
 * @author Rob Brooks-Bilson (rbils@amkor.com) 
 * @version 1.0, July 18, 2001 
 */
function DegToRad(degrees)
{
  Return (degrees*(Pi()/180));
}


/**
 * Calculates the arc tangent of the two variables, x and y.
 * 
 * @param x 	 First value. (Required)
 * @param y 	 Second value. (Required)
 * @return Returns a number. 
 * @author Rick Root (rick.root@webworksllc.com) 
 * @version 1, September 14, 2005 
 */
function atan2(firstArg, secondArg) {    
	var Math = createObject("java","java.lang.Math");    
	return Math.atan2(javacast("double",firstArg), javacast("double",secondArg)); 
}


</cfscript>

<cffunction     name="kmlCircle"     access="public"    returntype="string" output="false">
     <cfargument
	     name="centerlat_form"
	     type="numeric"
	     required="true"/>
	<cfargument
	     name="centerlong_form"
	     type="numeric"
	     required="true"/>
	<cfargument
	     name="radius_form"
	     type="numeric"
	     required="true"/>
    <cfset lat = DegToRad(centerlat_form)>
	<cfset long = DegToRad(centerlong_form)>
	<!---
	<cfset a = ((sin(lat/2))^ 2) + cos(lat) * ((sin(long/2)) ^ 2)>
	<cfset c = 2 * atan2(sqr(a), sqr(1-a))>
	--->
	<cfset d = radius_form>
	<cfset d_rad=d/6378137>
	
	<cfset retn = "<Folder>\n<name>KML Circle Generator Output</name>\n<visibility>1</visibility>\n<Placemark>\n<name>circle</name>\n<visibility>1</visibility>\n<Style>\n<geomColor>ff0000ff</geomColor>\n<geomScale>1</geomScale></Style>\n<LineString>\n<coordinates>">
	
	<cfloop from="1" to="360" index="i">
		<cfset radial = deg2rad(i)>
		<cfset lat_rad = asin(sin(lat)*cos(d_rad) + cos(lat)*sin(d_rad)*cos(radial))>
		<cfset dlon_rad = atan2(sin(radial)*sin(d_rad)*cos(lat),cos(d_rad)-sin(lat)*sin(lat_rad))>
		<cfset lon_rad = mod((long+dlon_rad + pi()), 2*pi()) - pi()>
		<cfset retn = '#retn#, rad2deg(lon_rad).",".rad2deg(lat_rad).",0 ")'>
	</cfloop>
	<!---
	for($i=0; $i<=360; $i++) {
  $radial = deg2rad($i);
  $lat_rad = asin(sin($lat1)*cos($d_rad) + cos($lat1)*sin($d_rad)*cos($radial));
  $dlon_rad = atan2(sin($radial)*sin($d_rad)*cos($lat1),
                    cos($d_rad)-sin($lat1)*sin($lat_rad));
  $lon_rad = fmod(($long1+$dlon_rad + M_PI), 2*M_PI) - M_PI;
  fwrite( $fileappend, rad2deg($lon_rad).",".rad2deg($lat_rad).",0 ");
  }
	--->
	<cfreturn retn>
	</cffunction>
<!---


// get the difference between lat/long coords
$dlat = $lat2-$lat1;
$dlong = $long2-$long1;

// if the radius of the circle wasn't given, we need to calculate it
if (!$radius_form) {
  // compute distance of great circle
  $a = pow((sin($dlat/2)), 2) + cos($lat1) * cos($lat2) *
       pow((sin($dlong/2)), 2);
  $c = 2 * atan2(sqrt($a), sqrt(1-$a));
  // get distance between points (in meters)
  
} else {
  $d = $radius_form;
}

$d_rad = $d/6378137;

// use a random 5-digit number appended to the date for the name of the kml file
$day = date("m-d-y-");
srand( microtime() * 1000000);
$randomnum = rand(10000,99999);
$file_ext = $day.$randomnum.'.kml';
$filename = ('temp/'.$file_ext);

// define initial write and appends
$filewrite = fopen($filename, "w");
$fileappend = fopen($filename, "a");

// open file and write header:
fwrite($filewrite, "<Folder>\n<name>KML Circle Generator Output</name>\n<visibility>1</visibility>\n<Placemark>\n<name>circle</name>\n<visibility>1</visibility>\n<Style>\n<geomColor>ff0000ff</geomColor>\n<geomScale>1</geomScale></Style>\n<LineString>\n<coordinates>\n");

// loop through the array and write path linestrings
for($i=0; $i<=360; $i++) {
  $radial = deg2rad($i);
  $lat_rad = asin(sin($lat1)*cos($d_rad) + cos($lat1)*sin($d_rad)*cos($radial));
  $dlon_rad = atan2(sin($radial)*sin($d_rad)*cos($lat1),
                    cos($d_rad)-sin($lat1)*sin($lat_rad));
  $lon_rad = fmod(($long1+$dlon_rad + M_PI), 2*M_PI) - M_PI;
  fwrite( $fileappend, rad2deg($lon_rad).",".rad2deg($lat_rad).",0 ");
  }

// write everything else and clean up
fwrite( $fileappend, "</coordinates>\n</LineString>\n</Placemark>\n</Folder>");
fclose( $fileappend );
if(file_exists($filename)) {
  echo ("<p>Your circle is <a href=\"temp/$file_ext\">right here</a>.</p>");
} else {
  echo( "If you can see this, something is wrong..." ); 
}

?>
---->

<cfoutput>
	<cfset k = kmlCircle(64,-147,12)>
	#k#
</cfoutput>