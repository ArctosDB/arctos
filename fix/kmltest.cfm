<cfinclude  template="/includes/_header.cfm"> 
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

/**
 * Converts radians to degrees.
 * 
 * @param radians 	 Angle (in radians) you want converted to degrees. 
 * @return Returns a simple value. 
 * @author Rob Brooks-Bilson (rbils@amkor.com) 
 * @version 1.0, July 18, 2001 
 */
function RadToDeg(radians)
{
  Return (radians*(180/Pi()));
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
	     
	
	<cfset retn = "<Folder>
	<name>KML Circle Generator Output</name>
	<visibility>1</visibility>
	<Placemark>
	<name>circle</name>
	<visibility>1</visibility>
	<Style>
	<geomColor>ff0000ff</geomColor>
	<geomScale>1</geomScale></Style>
	<LineString>
	<coordinates>">
	
	
	
	<cfset lat = DegToRad(centerlat_form)>
	<cfset long = DegToRad(centerlong_form)>
	

	<cfset d = radius_form>
	<cfset d_rad=d/6378137>
	<cfset retn = '<table border>'>
	<cfloop from="0" to="360" index="i">
		<cfset radial = DegToRad(i)>
		<cfset lat_rad = asin(sin(lat)*cos(d_rad) + cos(lat)*sin(d_rad)*cos(radial))>
		<cfset dlon_rad = atan2(sin(radial)*sin(d_rad)*cos(lat),cos(d_rad)-sin(lat)*sin(lat_rad))>
		<!---
		<cfset lon_rad = ((long+dlon_rad + 3.1415) mod (2*3.1415)) - 3.1415>
		--->
		<cfset lon_rad = ((long+dlon_rad + pi()) mod (2*pi())) - pi()>

		<cfset rLong = RadToDeg(lon_rad)>
		<cfset rLat = RadToDeg(lat_rad)>
		<cfset retn = '#retn#<tr><td>#i#</td><td>#dlon_rad#</td><td>#lon_rad#</td><td>#rLong#</td><td>#rLat#</td></tr>'>	
	</cfloop>
	

 $radial = deg2rad($i);
  $lat_rad = asin(sin($lat1)*cos($d_rad) + cos($lat1)*sin($d_rad)*cos($radial));
  $dlon_rad = atan2(sin($radial)*sin($d_rad)*cos($lat1),
                    cos($d_rad)-sin($lat1)*sin($lat_rad));
  $lon_rad = fmod(($long1+$dlon_rad + M_PI), 2*M_PI) - M_PI;
  fwrite( $fileappend, rad2deg($lon_rad).",".rad2deg($lat_rad).",0 ");
  }


	<cfset retn = '#retn#</table>'>
	
	<cfreturn retn>
	</cffunction>
<!---
<?php 
// make sure we have the information we need
if ((!$centerlat_form || !$centerlong_form) ||
    (!$circumlat_form && !$radius_form) )
{
  echo "Go back and make sure you have entered the values we need";
  exit(1);
}

// convert coordinates to radians
$lat1 = deg2rad($centerlat_form);
$long1 = deg2rad($centerlong_form);
$lat2 = deg2rad($circumlat_form);
$long2 = deg2rad($circumlong_form);

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
  $d = 6378137 * $c;
} else {
  $d = $radius_form;
}

$d_rad = $d/6378137;


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
<form name="a" method="post" action="kmltest.cfm">
	Lat:<input type="text" name="inlat">
	<br>Lon:<input type="text" name="inlong">
	<br>Rad:<input type="text" name="inrad">
	<input type="hidden" name="action" value="make">
	<input type="submit">
</form>
<cfif #action# is "make">
<cfdump var=#form#>
<cfoutput>
	<cfset k = kmlCircle(#inlat#,#inlong#,#inrad#)>
	<cfset theFile = '<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://earth.google.com/kml/2.2">
  <Folder>
  	<name>Big Folder</name>
  	<Folder>
  		<name>liler Folder</name>
  		<Placemark>
	    <name>One</name>
	    <description>Attached to the ground. Intelligently places itself 
	       at the height of the underlying terrain.</description>
	    <Point>
	      <coordinates>#inlong#,#inlat#,0</coordinates>
	    </Point>
	  </Placemark>
	  #k#
  	</Folder>
   </Folder>
</kml>
'>
<hr>
#theFile#
<hr>
<cffile action="write" file="#application.webDirectory#/temp/test.kml" output="#theFile#" nameconflict="overwrite">
<a href="/temp/test.kml">/temp/test.kml</a>
	</cfoutput>
	</cfif>
