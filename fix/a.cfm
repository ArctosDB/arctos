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
          center: new google.maps.LatLng(-34.397, 150.644),
          mapTypeId: google.maps.MapTypeId.ROADMAP
        };
        map = new google.maps.Map(document.getElementById('map_canvas'),
            mapOptions);
      }

      google.maps.event.addDomListener(window, 'load', initialize);
	    </script>

	  <body>

	    <div id="map_canvas"></div>
	  </body>


	<cfinclude template="/includes/_footer.cfm">

