<cfinclude template="/includes/_header.cfm">
<style type="text/css"> html { height: 100% } body { height: 100%; margin: 0; padding: 0 } #map_canvas { height: 500px;width:600px; } </style>
<script src="http://maps.googleapis.com/maps/api/js?client=gme-museumofvertebrate1&sensor=false" type="text/javascript"></script> <script type="text/javascript">
	var map;
	var bounds;
	var rectangle;
	function initialize() {
		var mapOptions = {
			zoom: 8,
		    center: new google.maps.LatLng(44.490, -78.649),
		    mapTypeId: google.maps.MapTypeId.ROADMAP
		};

		map = new google.maps.Map(document.getElementById('map_canvas'),mapOptions);

		bounds = new google.maps.LatLngBounds(
	   		new google.maps.LatLng(44.490, -78.649),
			new google.maps.LatLng(44.599, -78.443)
		);
		rectangle = new google.maps.Rectangle({
			bounds: bounds,
			editable: true,
			draggable: true
		});

		rectangle.setMap(map);

		google.maps.event.addListener(rectangle,'bounds_changed',sdas);



	}

	function sdas () {
		console.log('bounds_changed');
		var NELat=rectangle.getBounds().getNorthEast().lat();
		var NELong=rectangle.getBounds().getNorthEast().lon();
		var SWLat=rectangle.getBounds().getSouthWest().lat();
		var SWLong=rectangle.getBounds().getSouthWest().lon();
		console.log(NELat + ' ' + NELong + ' ' +  SWLat   + ' ' + SWLong);
		}

<input id="nwLat" type="hidden" name="nwLat" value="67.474922384787">
<input id="nwlong" type="hidden" name="nwlong" value="-162.421875">
<input id="selat" type="hidden" name="selat" value="59.355596110016315">
<input id="selong" type="hidden" name="selong" value="-14


	google.maps.event.addDomListener(window, 'load', initialize);






//google.maps.event.addListener(rectangle, 'bounds_changed', sdas);



</script>
<body>
	<div id="map_canvas"></div>
</body>
<cfinclude template="/includes/_footer.cfm">
