

<!DOCTYPE html>
<html>
  <head>
    <title>Simple Map</title>
    <meta name="viewport" content="initial-scale=1.0, user-scalable=no">
    <meta charset="utf-8">
    <style>
      html, body, #map-canvas {
        margin: 0;
        padding: 0;
        height: 100%;
      }
    </style>
    <script src="https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=false"></script>
    <script>
var map;
function initialize() {
  var mapOptions = {
    zoom: 8,
    center: new google.maps.LatLng(-34.397, 150.644),
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };
  map = new google.maps.Map(document.getElementById('map-canvas'),
      mapOptions);
}

google.maps.event.addDomListener(window, 'load', initialize);

    </script>
  </head>
  <body>
    <div id="map-canvas"></div>
  </body>
</html>





<cfabort>



<cfinclude template="/includes/_header.cfm">



<cfquery name="cf_global_settings" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select
			google_client_id,
			google_private_key
		from cf_global_settings
	</cfquery>
	<cfoutput>
		<cfhtmlhead text='<script src="http://maps.googleapis.com/maps/api/js?client=#cf_global_settings.google_client_id#&sensor=false" type="text/javascript"></script>'>
	</cfoutput>
	
	<!----------
	
	
	
		var latLng1 = new google.maps.LatLng($("#dec_lat").val(), $("#dec_long").val());
		if ($("#dec_lat").val().length>0){
			var marker1 = new google.maps.Marker({
			    position: latLng1,
			    map: map,
			    icon: 'http://maps.google.com/mapfiles/ms/icons/green-dot.png'
			});
			var circleOptions = {
	  			center: latLng1,
	  			radius: Math.round($("#error_in_meters").val()),
	  			map: map,
	  			editable: false
			};
			var circle = new google.maps.Circle(circleOptions);
		}
		var latLng2 = new google.maps.LatLng($("#s_dollar_dec_lat").val(), $("#s_dollar_dec_long").val());
		if ($("#s_dollar_dec_lat").val().length>0){
			var marker2 = new google.maps.Marker({
			    position: latLng2,
			    map: map,
			    icon: 'http://maps.google.com/mapfiles/ms/icons/red-dot.png'
			});
		}
		bounds.extend(latLng1);
        bounds.extend(latLng2);
		// center the map on the points
		map.fitBounds(bounds);
		// and zoom back out a bit, if the points will still fit
		// because the centering zooms WAY in if the points are close together
		var p1 = new google.maps.LatLng($("#dec_lat").val(),$("#dec_long").val());
		var p2 = new google.maps.LatLng($("#s_dollar_dec_lat").val(),$("#s_dollar_dec_long").val());
		var tdis=distHaversine(p1,p2);
		$("#distanceBetween").val(tdis);

		if (tdis < 50) {
			// if hte points are close together autozoom goes too far
			var listener = google.maps.event.addListener(map, "idle", function() {
				if (map.getZoom() > 4) map.setZoom(4);
				google.maps.event.removeListener(listener);
			});
		}
		// end map setup

		$("select[id^='geology_attribute_']").each(function(e){
			populateGeology(this.id);
		});
	    $.each($("input[id^='geo_att_determined_date_']"), function() {
			$("#" + this.id).datepicker();
	    });
	    if (window.addEventListener) {
			window.addEventListener("message", getGeolocate, false);
		} else {
			window.attachEvent("onmessage", getGeolocate);
		}
		
		
		
		------------->
	
	<script language="javascript" type="text/javascript">
	


	jQuery(document).ready(function() {
 		var map;
function initialize() {
  var mapOptions = {
    zoom: 8,
    center: new google.maps.LatLng(-34.397, 150.644),
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };
  map = new google.maps.Map(document.getElementById('map-canvas'),
      mapOptions);
}




		initialize();


	});

	
	

</script>

		<div id="map-canvas">i am a map</div>
		
		
		
		<cfinclude template="/includes/_footer.cfm">

