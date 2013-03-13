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
          			editable: true
        		});

        		rectangle.setMap(map);



function getBounds() {
				var x=map.getBounds();
				console.log('x='+x);
				}

				function getBounds2() {
				var x=rectangle.getBounds();
				console.log('x='+x);
				}
			});


	    </script>

	  <body>
<span onclick="getBounds()">getBounds</span>


	<span onclick="getBounds2()">getBounds2</span>



		  <div id="rslt"></div>
	    <div id="map-canvas"/>
	  </body>


	<cfinclude template="/includes/_footer.cfm">

