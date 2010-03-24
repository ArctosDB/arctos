<script type='text/javascript' src='/includes/gmaps.min.js'></script>
<div class="divlayer" id="zoomLayer" title="Drag to Move">
	<div id="Bar" class="Bar" title="Drag to Move"></div>
	<div id="ZoomBtn" class="ZoomBtn" title="Click to Zoom"></div>
	<div id="ResBtn" class="ResBtn" title="Drag to Resize"></div>
</div>
<label for="map">
	Click <img src="/images/selector.png"> (on the map by the pan tool) to open spatial query tool. Click it again to cancel.
	<span class="likeLink" onclick="getDocs('pageHelp/spatial_query')";>More Info</span>
</label>
<input type="text" style="font-weight:bold;border:none;width:100%" id="selectedCoords">
<input type="hidden" name="nwLat" id="nwLat">
<input type="hidden" name="nwlong" id="nwlong">
<input type="hidden" name="selat" id="selat">
<input type="hidden" name="selong" id="selong">
<div id="map" style="width: 100%; height: 400px;"></div>
<script language="javascript" type="text/javascript">
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