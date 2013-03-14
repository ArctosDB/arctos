<script type='text/javascript' src='/includes/gmaps.js'></script>
<label for="map">
		Click <img src="/images/selector.png"> (on the map!) to open spatial query tool, click <img src="/images/del.gif"> to cancel.
		<span class="likeLink" onclick="getDocs('pageHelp/spatial_query')";>More Info</span>
		<br>Click the Arctos Search button (at the top or bottom of the page), NOT the Google Search button on the map, to run your query.
	</label>
	<div id="search-panel">
		<input id="gmapsrchtarget" type="text" placeholder="Search the Map">
	</div>
	<input type="text" style="font-weight:bold;border:none;width:100%;color:red;"
		id="selectedCoords" name="selectedCoords" placeholder="NE coordinates; SW coordinates">
	<div id="map_canvas"></div>

	<form method="get" action="/SpecimenResults.cfm" target="_blank">
	NELat<input type="text" name="NELat" size="6" id="NELat">
	NELong<input type="text" name="NELong" size="6" id="NELong">
	SWLat<input type="text" name="SWLat" size="6" id="SWLat">
	SWLong<input type="text" name="SWLong" size="6" id="SWLong">
		<input type="submit">
	</form>