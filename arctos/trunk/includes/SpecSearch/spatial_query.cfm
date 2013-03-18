<script type='text/javascript' language="javascript" src='/includes/spatialquery.min.js'></script>
<script>
	jQuery(document).ready(function() {
	  	initialize();
	});
</script>
<label for="map">
	Click <img src="/images/selector.png" class="likeLink" onclick="selectControlClicked();"> to open spatial query tool,
	click <img src="/images/del.gif" class="likeLink" onclick="selectControlClicked();"> to cancel.
	<span class="likeLink" onclick="getDocs('pageHelp/spatial_query')";>More Info</span>
	<br>Click the Arctos Search button (at the top or bottom of the page), NOT the Google Search button on the map, to run your query.
</label>
<div id="search-panel">
	<input id="gmapsrchtarget" type="text" placeholder="Search the Map" onKeyPress="return noenter(event);">
</div>
<input type="text" style="font-weight:bold;border:none;width:100%;color:red;" id="selectedCoords" name="selectedCoords" placeholder="NE coordinates; SW coordinates">
<div id="map_canvas"></div>
<input type="hidden" name="NELat" size="6" id="NELat" value="">
<input type="hidden" name="NELong" size="6" id="NELong" value="">
<input type="hidden" name="SWLat" size="6" id="SWLat" value="">
<input type="hidden" name="SWLong" size="6" id="SWLong" value="">