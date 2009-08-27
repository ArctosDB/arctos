<cfinclude template="/includes/_header.cfm">

<cfset apiKey="ABQIAAAAO1U4FM_13uDJoVwN--7J3xRt-ckefprmtgR9Zt3ibJoGF3oycxTHoy83TEZbPAjL1PURjC9X2BvFYg"> 

<cfoutput>
<script src="http://maps.google.com/maps?file=api&amp;v=2&amp;sensor=true&amp;key=#apiKey#" type="text/javascript"></script>

<div id="map_canvas" style="width: 500px; height: 300px"></div>


<script>
var map = new GMap2(document.getElementById("map_canvas"));
	map.setCenter(new GLatLng(37.4419, -122.1419), 13);
  map.setUIToDefault();
  
var marker = new GMarker(center, {draggable: true});

GEvent.addListener(marker, "dragstart", function() {
  map.closeInfoWindow();
  });

GEvent.addListener(marker, "dragend", function() {
  marker.openInfoWindowHtml("Just bouncing along...");
  });

map.addOverlay(marker);
</script>
</cfoutput>
