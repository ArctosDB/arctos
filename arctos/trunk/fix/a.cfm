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
		        	center: new google.maps.LatLng(55,55),
		         	mapTypeId: google.maps.MapTypeId.ROADMAP
		        };
		        var bounds = new google.maps.LatLngBounds();
				function initialize() {
		        	map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);
		      	}
				initialize();



			});


	    </script>

	  <body>
<span onclick="getBounds()">getBounds</span>


	<span onclick="getBounds2()">getBounds2</span>



		  <div id="rslt"></div>
	    <div id="map_canvas"></div>
	  </body>


	<cfinclude template="/includes/_footer.cfm">

