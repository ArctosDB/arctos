<cfinclude template="/includes/_header.cfm">
<style type="text/css"> html { height: 100% } body { height: 100%; margin: 0; padding: 0 } #map_canvas { height: 500px;width:600px; } </style>
<script src="http://maps.googleapis.com/maps/api/js?client=gme-museumofvertebrate1&sensor=false&libraries=drawing" type="text/javascript"></script> <script type="text/javascript">
	var map;
	var bounds;
	var rectangle;
	function initialize() {
		var mapOptions = {
			zoom: 3,
		    center: new google.maps.LatLng(55, -135),
		    mapTypeId: google.maps.MapTypeId.ROADMAP
		};

		map = new google.maps.Map(document.getElementById('map_canvas'),mapOptions);



	}


function addARectangle(){
	var NELat=map.getBounds().getNorthEast().lat();
	var NELong=map.getBounds().getNorthEast().lng();
	var SWLat=map.getBounds().getSouthWest().lat();
	var SWLong=map.getBounds().getSouthWest().lng();

	var latrange=NELat-SWLat;
	var longrange=NELong-SWLong;

	var nela=NELat-(latrange*.4);
	var swla=SWLat+(latrange*.4);

	if (NELong>0){

		var longrange=NELong-SWLong;
		var nelo=NELong+(longrange*.4);
	} else {

		var longrange=SWLong-NELong;
		var nelo=NELong-(longrange*.4);
	}

	if (SWLong>0){
		var swlo=SWLong+(longrange*.4);
	} else {
		var swlo=SWLong-(longrange*.4);
	}



	console.log(NELat + ' ' + NELong + ' ' +  SWLat   + ' ' + SWLong);

	console.log('longrange='+longrange);

	console.log('nelo='+nelo);

	console.log('swlo='+swlo);

	console.log('NELat='+NELat);
	bounds = new google.maps.LatLngBounds(
	   		new google.maps.LatLng(nela, swlo ),
			new google.maps.LatLng(swla, nelo)
		);
		rectangle = new google.maps.Rectangle({
			bounds: bounds,
			editable: true,
			draggable: true
		});

		rectangle.setMap(map);
whereIsTheRectangle();


		google.maps.event.addListener(rectangle,'bounds_changed',whereIsTheRectangle);


	}

function dieRectangleDie(){
	rectangle.setMap();
	}

	function whereIsTheRectangle () {
		var NELat=rectangle.getBounds().getNorthEast().lat();
		var NELong=rectangle.getBounds().getNorthEast().lng();
		var SWLat=rectangle.getBounds().getSouthWest().lat();
		var SWLong=rectangle.getBounds().getSouthWest().lng();
		console.log(NELat + ' ' + NELong + ' ' +  SWLat   + ' ' + SWLong);
		}

	google.maps.event.addDomListener(window, 'load', initialize);






//google.maps.event.addListener(rectangle, 'bounds_changed', sdas);



</script>
<body>


	<span onclick="addARectangle()">addARectangle</span>
	<span onclick="dieRectangleDie()">dieRectangleDie</span>
	<div id="map_canvas"></div>
</body>
<cfinclude template="/includes/_footer.cfm">
