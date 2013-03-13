<cfinclude template="/includes/_header.cfm">


	    <style type="text/css">
	      html { height: 100% }
	      body { height: 100%; margin: 0; padding: 0 }
	      #map-canvas { height: 500px;width:600px; }
	    </style>
	<script src="http://maps.googleapis.com/maps/api/js?client=gme-museumofvertebrate1&sensor=false&libraries=geometry" type="text/javascript"></script>

	    <script type="text/javascript">
	      function initialize() {
	        var mapOptions = {
	          center: new google.maps.LatLng(-34.397, 150.644),
	          zoom: 8,
	          mapTypeId: google.maps.MapTypeId.ROADMAP
	        };
	        var map = new google.maps.Map(document.getElementById("map-canvas"),
	            mapOptions);
	      }

	       var bounds = new google.maps.LatLngBounds(
          new google.maps.LatLng(44.490, -78.649),
          new google.maps.LatLng(44.599, -78.443)
        );

        var rectangle = new google.maps.Rectangle({
          bounds: bounds,
          editable: true
        });

        rectangle.setMap(map);


	      google.maps.event.addDomListener(window, 'load', initialize);
	    </script>

	  <body>
	    <div id="map-canvas"/>
	  </body>


	<cfinclude template="/includes/_footer.cfm">

