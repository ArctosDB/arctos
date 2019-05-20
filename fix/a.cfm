<cfinclude template="/includes/_header.cfm">



<script>
			function wkt2geojson(wkt){
			str="";
		//POLYGON((0.0524887245 46.34721813,0.0524887245 48.938372,3.128101325 48.938372,3.128101325 46.34721813,0.0524887245 46.34721813))
			if (wkt.search("LINESTRING") == 0){
				geojson = {"type":"LineString", "coordinates":[]};
				str = wkt.substring("LINESTRING(".length, wkt.length-1);
				coord_list=str.split(",");
				for (var i in coord_list){
				    coord=coord_list[i].split(" ");
				    geojson.coordinates.push([parseFloat(coord[0]), parseFloat(coord[1])]);
				}
			} else if (wkt.search("MULTILINESTRING") == 0){
				geojson = {"type":"MultiLineString", "coordinates":[]};
				str = wkt.substring("MULTILINESTRING(((".length, wkt.length-3);
				linestring_list = str.split(")");
				for (p in linestring_list) {
				    parenthese_pos = linestring_list[p].search("\\(");
				    linestring_str = linestring_list[p].substring(parenthese_pos+1, linestring_list[p].length);
				    coord_list=linestring_str.split(",");
						geojson.coordinates[p] = [];
				    for (var i in coord_list){
				        coord=coord_list[i].split(" ");
				        geojson.coordinates[p].push([parseFloat(coord[0]), parseFloat(coord[1])]);
				    }
				}
			} else if (wkt.search("POINT") == 0){
				geojson = {"type":"Point", "coordinates":[]};
				coord_list = wkt.substring("POINT(".length, wkt.length-1);
			    coord = coord_list.split(" ");
				geojson.coordinates.push(parseFloat(coord[0]));
				geojson.coordinates.push(parseFloat(coord[1]));

			} else if (wkt.search("POLYGON") == 0){
				geojson = {"type":"Polygon", "coordinates":[[]]};
				str = wkt.substring("POLYGON((".length, wkt.length-2);
				coord_list=str.split(",");
				for (var i in coord_list){
				    coord=coord_list[i].split(" ");
				    geojson.coordinates[0].push([parseFloat(coord[0]), parseFloat(coord[1])]);
				}

			} else if (wkt.search("MULTIPOLYGON") == 0){
				geojson = {"type":"Polygon", "coordinates":[]};
				str = wkt.substring("MULTIPOLYGON(((".length, wkt.length-3);
				polygon_list = str.split(")");
				for (p in polygon_list) {
				    geojson.coordinates[p] = [];
				    parenthese_pos = polygon_list[p].search("\\(");
				    polygon_str = polygon_list[p].substring(parenthese_pos+1, polygon_list[p].length);
				    coord_list=polygon_str.split(",");
				    for (var i in coord_list){
				        coord=coord_list[i].split(" ");
				        geojson.coordinates[p].push([parseFloat(coord[0]), parseFloat(coord[1])]);
				    }
				}
			}
			return geojson;
		}




function isMarkerInsidePolygon(marker, poly) {
            var inside = false;
            var x = marker.getLatLng().lat, y = marker.getLatLng().lng;
            for (var ii=0;ii<poly.getLatLngs().length;ii++){
                var polyPoints = poly.getLatLngs()[ii];
                for (var i = 0, j = polyPoints.length - 1; i < polyPoints.length; j = i++) {
                    var xi = polyPoints[i].lat, yi = polyPoints[i].lng;
                    var xj = polyPoints[j].lat, yj = polyPoints[j].lng;

                    var intersect = ((yi > y) != (yj > y))
                        && (x < (xj - xi) * (y - yi) / (yj - yi) + xi);
                    if (intersect) inside = !inside;
                }
            }

            return inside;
        };

</script>







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
#map { height: 600px; }
</style>


<script>
//var geojsonFeature = {"type":"Polygon","coordinates":[[[-95.4319,31.91362],[-95.43541,31.89528],[-95.43856,31.87634],[-95.44455,31.85071],[-95.41975,31.83575],[-95.40171,31.81688],[-95.39763,31.79429],[-95.39802,31.77313],[-95.3888,31.7582],[-95.36066,31.74526],[-95.36859,31.72938],[-95.33313,31.73164],[-95.33486,31.71553],[-95.31212,31.70175],[-95.28325,31.67641],[-95.2781,31.65465],[-95.28746,31.63306],[-95.26179,31.61811],[-95.2732,31.59289],[-95.27328,31.59288],[-95.30593,31.58872],[-95.33038,31.58561],[-95.33843,31.58458],[-95.35709,31.58227],[-95.37652,31.5794],[-95.39634,31.57698],[-95.41775,31.57436],[-95.45108,31.57029],[-95.4544,31.56988],[-95.46645,31.56839],[-95.49881,31.56379],[-95.51949,31.5607],[-95.53856,31.55792],[-95.55663,31.55528],[-95.58018,31.55202],[-95.60508,31.54868],[-95.62366,31.5459],[-95.63184,31.54469],[-95.65176,31.54179],[-95.64739,31.52772],[-95.6572,31.52454],[-95.67987,31.51888],[-95.70305,31.51312],[-95.70999,31.51138],[-95.73894,31.50414],[-95.73928,31.50406],[-95.7392,31.50412],[-95.73592,31.51511],[-95.74647,31.52386],[-95.75703,31.5314],[-95.75136,31.54276],[-95.74724,31.55299],[-95.73165,31.5511],[-95.71913,31.55397],[-95.71736,31.562],[-95.71915,31.57085],[-95.72708,31.58169],[-95.72236,31.58593],[-95.7166,31.59361],[-95.71117,31.60455],[-95.71232,31.61953],[-95.71746,31.63005],[-95.72529,31.6408],[-95.73672,31.65409],[-95.75107,31.64959],[-95.75498,31.64068],[-95.75097,31.62474],[-95.75347,31.61304],[-95.76052,31.60417],[-95.76723,31.59758],[-95.78322,31.60849],[-95.78726,31.61826],[-95.7873,31.61838],[-95.78739,31.61867],[-95.79347,31.65879],[-95.78971,31.69128],[-95.82511,31.68759],[-95.87354,31.69342],[-95.86968,31.71965],[-95.88102,31.73514],[-95.87472,31.75467],[-95.90267,31.76102],[-95.92127,31.76701],[-95.9532,31.77975],[-95.98357,31.78925],[-95.97791,31.83004],[-95.98706,31.85953],[-95.97002,31.87702],[-95.98899,31.8692],[-96.00424,31.87644],[-96.02746,31.88151],[-96.01415,31.90832],[-96.00426,31.91905],[-96.02088,31.9389],[-96.0304,31.95431],[-96.05615,31.95162],[-96.04291,31.96297],[-96.0625,31.9784],[-96.05266,32.00452],[-96.05279,32.00589],[-96.05268,32.0059],[-96.03556,32.00798],[-95.98857,32.01349],[-95.94355,32.01902],[-95.90943,32.02307],[-95.87524,32.02712],[-95.84707,32.03048],[-95.81191,32.03469],[-95.78744,32.03753],[-95.77023,32.03973],[-95.75044,32.04231],[-95.7446,32.04305],[-95.74032,32.04347],[-95.73641,32.044],[-95.72823,32.04533],[-95.72209,32.04588],[-95.71557,32.04667],[-95.70793,32.04781],[-95.6715,32.05233],[-95.63656,32.05689],[-95.59884,32.06176],[-95.57158,32.06532],[-95.53667,32.06986],[-95.49558,32.07484],[-95.45689,32.0804],[-95.42871,32.08445],[-95.42851,32.08447],[-95.42937,32.07601],[-95.423,32.04804],[-95.43499,32.03082],[-95.42843,32.01005],[-95.44603,31.99777],[-95.44613,31.96817],[-95.43224,31.93385],[-95.43187,31.91375]]]};



function test(point, vs) {
    // ray-casting algorithm based on
    // http://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html

    var x = point[0], y = point[1];

    var inside = false;
    for (var i = 0, j = vs.length - 1; i < vs.length; j = i++) {
        var xi = vs[i][0], yi = vs[i][1];
        var xj = vs[j][0], yj = vs[j][1];

        var intersect = ((yi > y) != (yj > y))
            && (x < (xj - xi) * (y - yi) / (yj - yi) + xi);
        if (intersect) inside = !inside;
    }

    return inside;
};

function checkIsInside(poly) {
  for(poly of poly.features) {
    var isInside = turf.inside(pt1, poly);
    if(isInside) {
      return true
    } else {
      return false
    }
  }
};

	jQuery(document).ready(function() {
		var map = L.map('map').setView([32.04588,-95.72209], 6);

L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
}).addTo(map);


 var pt = {
        "type": "Feature",
        "properties": {},
        "geometry": {
                "type": "Point",
                "coordinates": [32.04588,-95.72209]
        }
    }



L.marker([32.04588,-95.72209]).addTo(map)
    .bindPopup('A pretty CSS3 popup.<br> Easily customizable.')
    .openPopup();

//L.geoJSON(geojsonFeature).addTo(map);


		var wkt='POLYGON((-95.4319 31.91362,-95.43541 31.89528,-95.43856 31.87634,-95.44455 31.85071,-95.41975 31.83575,-95.40171 31.81688,-95.39763 31.79429,-95.39802 31.77313,-95.3888 31.7582,-95.36066 31.74526,-95.36859 31.72938,-95.33313 31.73164,-95.33486 31.71553,-95.31212 31.70175,-95.28325 31.67641,-95.2781 31.65465,-95.28746 31.63306,-95.26179 31.61811,-95.2732 31.59289,-95.27328 31.59288,-95.30593 31.58872,-95.33038 31.58561,-95.33843 31.58458,-95.35709 31.58227,-95.37652 31.5794,-95.39634 31.57698,-95.41775 31.57436,-95.45108 31.57029,-95.4544 31.56988,-95.46645 31.56839,-95.49881 31.56379,-95.51949 31.5607,-95.53856 31.55792,-95.55663 31.55528,-95.58018 31.55202,-95.60508 31.54868,-95.62366 31.5459,-95.63184 31.54469,-95.65176 31.54179,-95.64739 31.52772,-95.6572 31.52454,-95.67987 31.51888,-95.70305 31.51312,-95.70999 31.51138,-95.73894 31.50414,-95.73928 31.50406,-95.7392 31.50412,-95.73592 31.51511,-95.74647 31.52386,-95.75703 31.5314,-95.75136 31.54276,-95.74724 31.55299,-95.73165 31.5511,-95.71913 31.55397,-95.71736 31.562,-95.71915 31.57085,-95.72708 31.58169,-95.72236 31.58593,-95.7166 31.59361,-95.71117 31.60455,-95.71232 31.61953,-95.71746 31.63005,-95.72529 31.6408,-95.73672 31.65409,-95.75107 31.64959,-95.75498 31.64068,-95.75097 31.62474,-95.75347 31.61304,-95.76052 31.60417,-95.76723 31.59758,-95.78322 31.60849,-95.78726 31.61826,-95.7873 31.61838,-95.78739 31.61867,-95.79347 31.65879,-95.78971 31.69128,-95.82511 31.68759,-95.87354 31.69342,-95.86968 31.71965,-95.88102 31.73514,-95.87472 31.75467,-95.90267 31.76102,-95.92127 31.76701,-95.9532 31.77975,-95.98357 31.78925,-95.97791 31.83004,-95.98706 31.85953,-95.97002 31.87702,-95.98899 31.8692,-96.00424 31.87644,-96.02746 31.88151,-96.01415 31.90832,-96.00426 31.91905,-96.02088 31.9389,-96.0304 31.95431,-96.05615 31.95162,-96.04291 31.96297,-96.0625 31.9784,-96.05266 32.00452,-96.05279 32.00589,-96.05268 32.0059,-96.03556 32.00798,-95.98857 32.01349,-95.94355 32.01902,-95.90943 32.02307,-95.87524 32.02712,-95.84707 32.03048,-95.81191 32.03469,-95.78744 32.03753,-95.77023 32.03973,-95.75044 32.04231,-95.7446 32.04305,-95.74032 32.04347,-95.73641 32.044,-95.72823 32.04533,-95.72209 32.04588,-95.71557 32.04667,-95.70793 32.04781,-95.6715 32.05233,-95.63656 32.05689,-95.59884 32.06176,-95.57158 32.06532,-95.53667 32.06986,-95.49558 32.07484,-95.45689 32.0804,-95.42871 32.08445,-95.42851 32.08447,-95.42937 32.07601,-95.423 32.04804,-95.43499 32.03082,-95.42843 32.01005,-95.44603 31.99777,-95.44613 31.96817,-95.43224 31.93385,-95.43187 31.91375))';
		console.log('hello');
		console.log('wkt:' + wkt);


		var gj=wkt2geojson(wkt);


		console.log('gj:');
		console.log(gj);

		//L.geoJSON(gj).addTo(map);

		var myLayer = L.geoJSON().addTo(map);
myLayer.addData(gj);

     var testpoint='[32.04588,-95.72209]';


     console.log(JSON.stringify(testPoint) + '\tin parentCoordinate\t' + test(testPoint, gj));


//var im=isMarkerInsidePolygon(testpoint,myLayer);

	//	console.log('im:' + im);



		});
</script>

 <div id="map"></div>

