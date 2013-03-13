<cfinclude template="/includes/_header.cfm">


	    <style type="text/css">
	      html { height: 100% }
	      body { height: 100%; margin: 0; padding: 0 }
	      #map-canvas { height: 500px;width:600px; }
	    </style>
	<script src="http://maps.googleapis.com/maps/api/js?client=gme-museumofvertebrate1&sensor=false&libraries=geometry" type="text/javascript"></script>

	    <script type="text/javascript">
				    jQuery(document).ready(function() {
			 		var map;
			 		var mapOptions = {
			        	center: new google.maps.LatLng($("#s_dollar_dec_lat").val(), $("#s_dollar_dec_long").val()),
			         	mapTypeId: google.maps.MapTypeId.ROADMAP
			        };
			        var bounds = new google.maps.LatLngBounds();
					function initialize() {
			        	map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);
			      	}
					initialize();




				});




	    </script>

	  <body>
	    <div id="map-canvas"/>
	  </body>


	<cfinclude template="/includes/_footer.cfm">

