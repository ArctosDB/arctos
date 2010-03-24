<cfinclude template="/includes/_header.cfm">
<cfhtmlhead text='<script src="http://maps.google.com/maps?file=api&amp;v=2.x&amp;sensor=false&amp;key=#application.gmap_api_key#" type="text/javascript"></script>'>


<script type='text/javascript' src='x_core.js'></script>

<script type='text/javascript' src='x_event.js'></script>
<script type='text/javascript' src='x_drag.js'></script>

<script type='text/javascript' src='x.js'></script>


<div class="divlayer" id="zoomLayer" title="Drag to Move">
	<div id="Bar" class="Bar" title="Drag to Move"></div>

	<!---
	<div id="ZoomBtn"></div>
	---><div id="ZoomBtn" class="ZoomBtn" title="Click to Zoom"></div>
	
	<div id="ResBtn" class="ResBtn" title="Drag to Resize"></div>
</div>
<!---<div id="map" style="width: 100%; height: 90%"></div>--->

<label for="map">
	Click 'select' then click and drag for spatial query&nbsp;&nbsp;&nbsp;
	<span class="likeLink" onclick="getDocs('pageHelp/spatial_query')";>More Info</span>
</label>
<input type="text" style="font-weight:bold;border:none;width:100%" id="selectedCoords">
<input type="text" name="nwLat" id="nwLat">
<input type="text" name="nwlong" id="nwlong">
<input type="text" name="selat" id="selat">
<input type="text" name="selong" id="selong">
<div id="map" style="width: 100%; height: 400px;"></div>
<script language="javascript" type="text/javascript">
	//jQuery(document).ready(function() {
	//  	initializeMap();
	//});
	jQuery(document.body).unload(function() {
		GUnload();
	});
	var map = new GMap2(document.getElementById("map"));
	map.addControl(new GLargeMapControl());
	map.addControl(new GMapTypeControl());
	map.addMapType(G_PHYSICAL_MAP);
	map.addControl(new GScaleControl());
	map.addControl(new ToggleZoomControl());
	map.enableGoogleBar();
	map.setCenter(new GLatLng(55, -135), 3);
	setDiv();
	GEvent.addListener(map, "moveend", function() {
		whurUB();
	});
</script>





<!---
</body>
</html>
--->

<cfinclude template="/includes/_footer.cfm">