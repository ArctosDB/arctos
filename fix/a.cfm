<cfinclude template="/includes/_header.cfm">
<cfset mb_token="pk.eyJ1IjoiYXJjdG9zIiwiYSI6ImNqdndnM2NrYjAwYXM0OHJnMDUyZnVvY3UifQ._Jg9O0eUm_HwS4o_Zb9Zeg">

 <link rel="stylesheet" href="https://unpkg.com/leaflet@1.5.1/dist/leaflet.css"
   integrity="sha512-xwE/Az9zrjBIphAcBb3F6JVqxf46+CDLwfLMHloNu6KEQCAWi6HcDUbeOfBIptF7tcCzusKFjFw2yuvEpDL9wQ=="
   crossorigin=""/>
 <!-- Make sure you put this AFTER Leaflet's CSS -->
 <script src="https://unpkg.com/leaflet@1.5.1/dist/leaflet.js"
   integrity="sha512-GffPMF3RvMeYyc1LWMHtK8EbPv0iNZ8/oTtHPx9/cc2ILxQ+u905qIwdpULaqDkyBKgOaB57QTMg7ztg8Jm2Og=="
   crossorigin=""></script>


<script src='https://cdnjs.cloudflare.com/ajax/libs/wicket/1.3.2/wicket.js'></script>
<script src='https://cdnjs.cloudflare.com/ajax/libs/wicket/1.3.2/wicket-leaflet.js'></script>


<style>
#map { height: 180px; }
</style>


<cfoutput>
<script>

	jQuery(document).ready(function() {
		var map = L.map('map').setView([51.505, -0.09], 13);

L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
}).addTo(map);

L.marker([51.5, -0.09]).addTo(map)
    .bindPopup('A pretty CSS3 popup.<br> Easily customizable.')
    .openPopup();



var wkt = new Wkt.Wkt();

var polygon = wkt.read('POLYGON((-0.10368 51.51654, -0.10557 51.50703, -0.08171 51.50543,  -0.08033 51.514808))').toObject();

window.console.log("Leaflet polygon: " + polygon);

polygon.addTo(map);

wkt = new Wkt.Wkt();
wkt.fromObject(polygon);
window.console.log("Wkt from Polygon: " + wkt.write());






		});
</script>

 <div id="map"></div>

</cfoutput>