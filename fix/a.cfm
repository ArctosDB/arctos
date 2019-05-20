<cfinclude template="/includes/_header.cfm">
<cfset mb_token="pk.eyJ1IjoiYXJjdG9zIiwiYSI6ImNqdndnM2NrYjAwYXM0OHJnMDUyZnVvY3UifQ._Jg9O0eUm_HwS4o_Zb9Zeg">

 <link rel="stylesheet" href="https://unpkg.com/leaflet@1.5.1/dist/leaflet.css"
   integrity="sha512-xwE/Az9zrjBIphAcBb3F6JVqxf46+CDLwfLMHloNu6KEQCAWi6HcDUbeOfBIptF7tcCzusKFjFw2yuvEpDL9wQ=="
   crossorigin=""/>
 <!-- Make sure you put this AFTER Leaflet's CSS -->
 <script src="https://unpkg.com/leaflet@1.5.1/dist/leaflet.js"
   integrity="sha512-GffPMF3RvMeYyc1LWMHtK8EbPv0iNZ8/oTtHPx9/cc2ILxQ+u905qIwdpULaqDkyBKgOaB57QTMg7ztg8Jm2Og=="
   crossorigin=""></script>



<script src='https://api.mapbox.com/mapbox.js/plugins/leaflet-omnivore/v0.2.0/leaflet-omnivore.min.js'></script>



<style>
#mapid { height: 180px; }
</style>


<cfoutput>
<script>

	jQuery(document).ready(function() {
L.mapbox.accessToken = 'pk.eyJ1IjoiYXJjdG9zIiwiYSI6ImNqdndnM2NrYjAwYXM0OHJnMDUyZnVvY3UifQ._Jg9O0eUm_HwS4o_Zb9Zeg';
var map = L.mapbox.map('map')
    .setView([0, -80], 8)
    .addLayer(L.mapbox.styleLayer('mapbox://styles/mapbox/streets-v11'));
// The Well Known Text format is commonly used in database systems,
// and can represent geometries. Unlike other formats, it cannot
// represent properties.
omnivore.wkt.parse('POINT(-80 0)').addTo(map);

		});
</script>

 <div id="mapid"></div>

</cfoutput>