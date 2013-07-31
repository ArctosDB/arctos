<cfinclude template="/includes/_header.cfm">



<cfif action is "buildKML">

<cfoutput>


	<cfset internalPath="#Application.webDirectory#/bnhmMaps/tabfiles/">
	<cfset externalPath="#Application.ServerRootUrl#/bnhmMaps/tabfiles/">
    <cfset dlFile = "test2.kml">
	<cfset variables.fileName="#internalPath##dlFile#">
	<cfset variables.encoding="UTF-8">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			flat.guid,
			flat.dec_lat,
			flat.dec_long,
			flat.spec_locality
		 from
		 	flat
		 where
		 	dec_lat is not null and rownum < 101
	</cfquery>
	
	<?xml version="1.0" encoding="utf-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Placemark>
    <name>My office</name>
    <description>This is the location of my office.</description>
    <Point>
      <coordinates>-122.087461,37.422069</coordinates>
    </Point>
  </Placemark>



	<cfscript>
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
		kml='<?xml version="1.0" encoding="UTF-8"?>' & chr(10) &
		 	'<kml xmlns="http://www.opengis.net/kml/2.2">'  & chr(10);
		variables.joFileWriter.writeLine(kml);
	</cfscript>
	<cfloop query="data">
    	 <cfscript>
			kml=' <Placemark>' & chr(10) &
				'  <name>#spec_locality#</name>' & chr(10) &
				'   <description>#spec_locality#</description>' & chr(10) &
				'   <Point>' & chr(10) &
				'    <coordinates>#dec_long#,#dec_lat#</coordinates>' & chr(10) &
				'   </Point>' & chr(10) &
				' </Placemark>' & chr(10);
			variables.joFileWriter.writeLine(kml);
		</cfscript>
	</cfloop>
	
	
		<cfscript>
			kml = "</kml>";
			variables.joFileWriter.writeLine(kml);
		variables.joFileWriter.close();
	</cfscript>


	</cfoutput>


</cfif>


<cfif action is "nothing">
<style type="text/css">
	#map-canvas { height: 600px;width:800px; }
</style>


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
		
		 var bounds = map.getBounds();
 var sw = bounds.getSouthWest();
 var ne = bounds.getNorthEast();
 alert("minimum lat of current map view: " + sw.lat());
		
		
		
		
		

function loadMapFromCurrentBounds( map )
{
  // First, determine the map bounds
  var bounds = map.getBounds();

  // Then the points
  var swPoint = bounds.getSouthWest();
  var nePoint = bounds.getNorthEast();

  // Now, each individual coordinate
  var swLat = swPoint.lat();
  var swLng = swPoint.lng();
  var neLat = nePoint.lat();
  var neLng = nePoint.lng();

 var zoomlevel=map.getZoom();

  // Now, build a query-string to represent this data
  var qs = 'swLat=' + swLat + '&swLng=' + swLng + '&neLat=' + neLat + '&neLng=' + neLng + '&zoomlevel=' + zoomlevel;


console.log(qs);

jQuery.getJSON("/component/functions.cfc",
			{
				method : "getSpecimensForMap",
				returnformat : "json",
				queryformat : 'column',
				swLat: swLat,
				swLng: swLng,
				neLat: neLat,
				neLng: neLng,
				zoomlevel: zoomlevel
			},
			function (r) {
				console.log('return: ' + r);
			}
		);




  // Now you can use this query-string in your AJAX request  

  // AJAX-stuff here
}



 		var map;
		function initialize() {
			var mapOptions = {
				zoom: 6,
			    center: new google.maps.LatLng(-152.1166666667,63.6666666667),
			    mapTypeId: google.maps.MapTypeId.ROADMAP,
			    panControl: true,
			    scaleControl: true
			};
		  map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);
		}



 var ctaLayer = new google.maps.KmlLayer({
    url: 'http://arctos-test.tacc.utexas.edu/bnhmMaps/tabfiles/kmlfile4DA2DC9562.kml'
  });
  ctaLayer.setMap(map);





/*
google.maps.event.addListener(map, 'idle', function() {
loadMapFromCurrentBounds(map);

});
* */


google.maps.event.addDomListener(window, 'load', initialize);
	
	
	
	
	
	
		------------->
	<cfoutput>
	<script language="javascript" type="text/javascript">
	


function initialize() {
  var chicago = new google.maps.LatLng(64.8333333333,-147.7166666667);
  var mapOptions = {
    zoom: 3,
    center: chicago,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  }

  var map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);
layer = new google.maps.FusionTablesLayer({
  query: {
    select: 'Location',
    from: '1q1wAPJZajAsrEO9vklsDvofVUCFo8kJqzoR5a7A'
  },
  styles: [{
    polygonOptions: {
      fillColor: "#00FF00",
      fillOpacity: 0.3
    }
  }, {
    where: "birds > 300",
    polygonOptions: {
      fillColor: "#0000FF"
    }
  }, {
    where: "population > 5",
    polygonOptions: {
      fillOpacity: 1.0
    }
  }]
});
layer.setMap(map);
}

google.maps.event.addDomListener(window, 'load', initialize);



</script>
</cfoutput>
		<div id="map-canvas">i am a map</div>
		
	</cfif>	
		
		<cfinclude template="/includes/_footer.cfm">

