<cfinclude template="/includes/_header.cfm">


	    <style type="text/css">
	      html { height: 100% }
	      body { height: 100%; margin: 0; padding: 0 }
	      #map_canvas { height: 500px;width:600px; }
	    </style>
	<script src="http://maps.googleapis.com/maps/api/js?client=gme-museumofvertebrate1&sensor=false" type="text/javascript"></script>

	    <script type="text/javascript">
			   var map;
      function initialize() {
        var mapOptions = {
          zoom: 8,
          center: new google.maps.LatLng(65, -10),
          mapTypeId: google.maps.MapTypeId.ROADMAP
        };
        map = new google.maps.Map(document.getElementById('map_canvas'),
            mapOptions);
      }

      google.maps.event.addDomListener(window, 'load', initialize);



       marker1 = new google.maps.Marker({
map: map,
position: new google.maps.LatLng(65, -10),
draggable: true,
title: 'Drag me!'
});
marker2 = new google.maps.Marker({
map: map,
position: new google.maps.LatLng(71, 10),
draggable: true,
title: 'Drag me!'
});

// Allow user to drag each marker to resize the size of the Rectangle.
google.maps.event.addListener(marker1, 'drag', redraw);
google.maps.event.addListener(marker2, 'drag', redraw);

// Create a new Rectangle overlay and place it on the map. Size
// will be determined by the LatLngBounds based on the two Marker
// positions.
rectangle = new google.maps.Rectangle({
map: map
});
redraw();







function redraw() {
var latLngBounds = new google.maps.LatLngBounds(
marker1.getPosition(),
marker2.getPosition()
);
rectangle.setBounds(latLngBounds);
//console.log(marker1.getPosition()+","+marker2.getPosition());
}




	    </script>

	  <body>

	    <div id="map_canvas"></div>
	  </body>


	<cfinclude template="/includes/_footer.cfm">

