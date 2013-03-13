<cfinclude template="/includes/_header.cfm">


	    <style type="text/css">
	      html { height: 100% }
	      body { height: 100%; margin: 0; padding: 0 }
	      #map-canvas { height: 500px;width:600px; }
	    </style>
	<script src="http://maps.googleapis.com/maps/api/js?client=gme-museumofvertebrate1&sensor=false" type="text/javascript"></script>

	    <script type="text/javascript">
			jQuery(document).ready(function() {
		 		var map;
		 		var mapOptions = {
		        	center: new google.maps.LatLng(32.321384, -64.75737),
		         	mapTypeId: google.maps.MapTypeId.ROADMAP
		        };

				function initialize() {
		        	map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);
		      	}
				initialize();


			});


	    </script>

	  <body>

	    <div id="map_canvas"></div>
	  </body>


	<cfinclude template="/includes/_footer.cfm">

