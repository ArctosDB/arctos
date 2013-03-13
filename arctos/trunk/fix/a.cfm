<cfinclude template="/includes/_header.cfm">


	    <style type="text/css">
	      html { height: 100% }
	      body { height: 100%; margin: 0; padding: 0 }
	      #map_canvas { height: 500px;width:600px; }
	    </style>
	<script src="http://maps.googleapis.com/maps/api/js?client=gme-museumofvertebrate1&sensor=false" type="text/javascript"></script>

	    <script type="text/javascript">
			   var map;

			   var marker1;
      var marker2;
      var rectangle;




      function initialize() {
        var mapOptions = {
          zoom: 8,
          center: new google.maps.LatLng(65, -10),
          mapTypeId: google.maps.MapTypeId.ROADMAP
        };
        map = new google.maps.Map(document.getElementById('map_canvas'),mapOptions);

        var bounds = new google.maps.LatLngBounds(
          new google.maps.LatLng(44.490, -78.649),
          new google.maps.LatLng(44.599, -78.443)
        );

        var rectangle = new google.maps.Rectangle({
          bounds: bounds,
          editable: true
        });

        rectangle.setMap(map);

      }

      google.maps.event.addDomListener(window, 'load', initialize);

rectangle = new google.maps.Rectangle();


	    </script>

	  <body>

	    <div id="map_canvas"></div>
	  </body>


	<cfinclude template="/includes/_footer.cfm">

