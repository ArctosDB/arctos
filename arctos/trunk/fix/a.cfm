<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml">

<head>
<meta http-equiv="content-type" content="text/html; charset=iso-8859-1"/>
<title>Google Maps</title>

<style>
body {font: normal 12px verdana;}
.link {color:blue;text-decoration:underline;cursor:pointer};
</style>

<script src="http://maps.google.com/maps?file=api&amp;v=2.x&amp;sensor=false&amp;key=#application.gmap_api_key#" type="text/javascript"></script>


<script src="MStatusControl.js"></script>
<script src="MPolyDragControl.js"></script>



	
<script type="text/javascript">
//<![CDATA[

var appRoot = 'http://' + window.location.host + '/';


var map;
var container;
var zoom = 5;
var centerPoint = new GLatLng(36.184609,-106.316406);
var polyDragControl;

function load() {
	doLoad();
}

function doLoad() {
	if (GBrowserIsCompatible()) {
		container = document.getElementById("mapDiv");
		map = new GMap2(container, {draggableCursor:"crosshair"});
		map.addMapType(G_PHYSICAL_MAP)

		map.setCenter(centerPoint, zoom);

		map.addControl(new GScaleControl());
		map.addControl(new GLargeMapControl());
		map.addControl(new GMapTypeControl());

		map.enableScrollWheelZoom();		

		var pos = new GControlPosition(G_ANCHOR_BOTTOM_LEFT, new GSize(0, -85));
		map.addControl(new MStatusControl({position:pos}));

		polyDragControl = new MPolyDragControl({map:map,type:'rectangle'});
		polyDragControl.ondragend = getParameters;
	}
}

function getParameters() {
	var params = polyDragControl.getParams();
	var url = 'http://' + window.location.host + '/myServerSideScript.php?' + params;
	GLog.write(url);
}


//////////////////////////////////////////////////////////////////////



function unload() {
	GUnload();
}


//]]>

</script>
</head>

<body>

<a href="/">Home (More maps)</a> ::: <a href="/mailme/index.php">Send me a message</a>

<div style="margin:5px;border-bottom:1px dashed navy"></div>

<center>
<table cellspacing="2" cellpadding="2">
	<tr>
		<td valign="top" style="border: 1px solid gray;padding:5px;">
			Select 'circle' or 'rectangle' and click on the map to place markers.<br>
			Then drag the markers to define a polygon.<br><br>
			<span class="link" onclick="polyDragControl.clear()">Clear All</span>&nbsp;&nbsp;&nbsp;

			<span class="link" onclick="polyDragControl.setType('rectangle')">Rectangle</span>&nbsp;&nbsp;&nbsp;
			<span class="link" onclick="polyDragControl.setType('circle')">Circle</span>
		</td>
	</tr>
	<tr>
		<td valign="top" style="border: 2px solid #860084">
			<div id="mapDiv" style="width: 600px; height: 600px"></div>
		</td>

		<td valign="top" style="border: 1px solid gray;padding:5px;">
<pre>For a radius search use it like this:
-----------------------------------------------
select *,
	acos(cos(centerLat * (PI()/180)) *
	 cos(centerLon * (PI()/180)) *
	 cos(lat * (PI()/180)) *
	 cos(lon * (PI()/180))
	 +
	 cos(centerLat * (PI()/180)) *
	 sin(centerLon * (PI()/180)) *
	 cos(lat * (PI()/180)) *
	 sin(lon * (PI()/180))
	 +
	 sin(centerLat * (PI()/180)) *
	 sin(lat * (PI()/180))
	) * 3959 as Dist
from TABLE_NAME
having Dist < radius
order by Dist
-----------------------------------------------
3959 is the Earth radius in Miles. Replace this value with
radius in KM, or any unit, to get results on the same unit.
centerLat and centerLon are the center of the search (your
input), while lat and lon are fields in the table.

*******************************************

For a rectangular search use it like this:
-----------------------------------------------
select * from TABLE_NAME 
where lat >= lat1 
and lat <= lat2 
and lon >= lon1 
and lon <= lon2
-----------------------------------------------
lat1, lon1, lat2 and lon2 are your input.
lat and lon are fields in the table.
</pre>
		</td>
	</tr>
</table>
</center>


<script>
	window.onload = load;
	window.onunload = unload;
</script>

</body>
</html>



