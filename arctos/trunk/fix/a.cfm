<cfinclude template="/includes/_header.cfm">


	    <style type="text/css">
	      html { height: 100% }
	      body { height: 100%; margin: 0; padding: 0 }
	      #map-canvas { height: 500px;width:600px; }
	    </style>
	<script src="http://maps.googleapis.com/maps/api/js?client=gme-museumofvertebrate1&sensor=false" type="text/javascript"></script>

	    <script type="text/javascript">


			jQuery(document).ready(function() {
				//var map;





			 	function mapsInitialize()
{
    startPoint = new google.maps.LatLng(lat,lon);
    options = { zoom: 16, center: startPoint, mapTypeId: google.maps.MapTypeId.HYBRID};
    map = new google.maps.Map(document.getElementById("map_canvas"), options);


    google.maps.event.addListener(map, 'click', function(event) {
        if (drawing == true){
            placeMarker(event.latLng);
            if (bottomLeft == null) {
                bottomLeft = new google.maps.LatLng(event.latLng.Oa, event.latLng.Pa);
            }
            else if (topRight == null){
                topRight = new google.maps.LatLng(event.latLng.Oa, event.latLng.Pa);
                drawing = false;
                rectangle = new google.maps.Rectangle();

                var bounds = new google.maps.LatLngBounds(bottomLeft, topRight);

                var rectOptions = {
                    strokeColor: "#FF0000",
                    strokeOpacity: 0.8,
                    strokeWeight: 2,
                    fillColor: "#FF0000",
                    fillOpacity: 0.35,
                    map: map,
                    bounds: bounds
                };
                rectangle.setOptions(rectOptions);
            }
        }
    });
}

function placeMarker(location) {
  var marker = new google.maps.Marker({
      position: location,
      map: map
  });



  mapsInitialize();
}


/*







			 	var mapOptions = {
          			center: new google.maps.LatLng(44.5452, -78.5389),
          			zoom: 9,
          			mapTypeId: google.maps.MapTypeId.ROADMAP
        		};
				function initialize() {
			       	map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);
			    }
				initialize();
				var bounds = new google.maps.LatLngBounds(
          			new google.maps.LatLng(44.490, -78.649),
          			new google.maps.LatLng(44.599, -78.443)
        		);
				var rectangle = new google.maps.Rectangle({
          			bounds: bounds,
          			editable: true,
          			setDraggable: true,
          			bounds_changed: logBounds
        		});

        		rectangle.setMap(map);

				function logBounds(){
					console.log('i am logBounds');
					}


				function getBounds() {
				var x=map.getBounds();
				console.log('x='+x);
				}

				function getBounds2() {
				var x=rectangle.getBounds();
				console.log('x='+x);
				}



				*/
			});


	    </script>

	  <body>
<span onclick="getBounds()">getBounds</span>


	<span onclick="getBounds2()">getBounds2</span>



		  <div id="rslt"></div>
	    <div id="map_canvas"/>
	  </body>


	<cfinclude template="/includes/_footer.cfm">

