<cfinclude template="/includes/_header.cfm">
<style type="text/css">
html { height: 100% }
body { height: 100%; margin: 0; padding: 0 } #map_canvas { height: 500px;width:600px; }

      #target {
        width: 345px;
      }
</style>

<!----------------
#search-panel {
        position: absolute;
        top: 5px;
        left: 50%;
        margin-left: -180px;
        width: 350px;
        z-index: 5;
        background-color: #fff;
        padding: 5px;
        border: 1px solid #999;
      }

--------------->
<script src="http://maps.googleapis.com/maps/api/js?client=gme-museumofvertebrate1&sensor=false&libraries=places"
		type="text/javascript"></script>

<script type="text/javascript">
	var map;
	var bounds;
	var rectangle;
	function initialize() {
		var mapOptions = {
			zoom: 3,
		    center: new google.maps.LatLng(55, -135),
		    mapTypeId: google.maps.MapTypeId.ROADMAP,
		     panControl: true,
		     scaleControl: true
 // zoomControl: true,
 // mapTypeControl: true,
 //,
//  streetViewControl: true,
 // overviewMapControl: true
		};




		map = new google.maps.Map(document.getElementById('map_canvas'),mapOptions);



var mcd = document.createElement('div');
mcd.id='mcd';
mcd.style.cursor="pointer";
var cImg=document.createElement("img");
//cImg.src='/images/selector.png';
cImg.src='/images/selector.png';
mcd.appendChild(cImg);


map.controls[google.maps.ControlPosition.TOP_LEFT].push(mcd);


google.maps.event.addDomListener(mcd, 'click', function() {
  selectControlClicked();
});


var input = document.getElementById('target');
        var searchBox = new google.maps.places.SearchBox(input);
        var markers = [];

        google.maps.event.addListener(searchBox, 'places_changed', function() {
          var places = searchBox.getPlaces();

          for (var i = 0, marker; marker = markers[i]; i++) {
            marker.setMap(null);
          }

          markers = [];
          var bounds = new google.maps.LatLngBounds();
          for (var i = 0, place; place = places[i]; i++) {
            var image = {
              url: place.icon,
              size: new google.maps.Size(71, 71),
              origin: new google.maps.Point(0, 0),
              anchor: new google.maps.Point(17, 34),
              scaledSize: new google.maps.Size(25, 25)
            };

            var marker = new google.maps.Marker({
              map: map,
              icon: image,
              title: place.name,
              position: place.geometry.location
            });

            markers.push(marker);

            bounds.extend(place.geometry.location);
          }

          map.fitBounds(bounds);
        });

        google.maps.event.addListener(map, 'bounds_changed', function() {
          var bounds = map.getBounds();
          searchBox.setBounds(bounds);
        });

	}

function selectControlClicked(){

	console.log('selectControlClicked');
 var theImage=$("#mcd").children('img').attr('src');

 	console.log(theImage);


 if (theImage=='/images/del.gif') {
 	// get rid of the select tool
 	// add select tool
	$("#mcd").html('').append('<img src="/images/selector.png">');
 	dieRectangleDie();
 } else {

	$("#mcd").html('').append('<img src="/images/del.gif">');
	addARectangle();

	}

/*
$('div.explorer_icon').dblclick(function(){
  editor($(this).children('img').attr('src'));
});
var mcd = document.createElement('div');
var cImg=document.createElement("img");
//cImg.src='/images/selector.png';
cImg.src='/images/del.gif';
mcd.appendChild(cImg);


map.controls[google.maps.ControlPosition.TOP_CENTER].push(mcd);


google.maps.event.addDomListener(mcd, 'click', function() {
  selectControlClicked();
});


*/


	}


function addARectangle(){
	dieRectangleDie();
	$("#addARectangle").hide();
	$("#dieRectangleDie").show();

	var theBounds=map.getBounds();
	var NELat=theBounds.getNorthEast().lat();
	var NELong=theBounds.getNorthEast().lng();
	var SWLat=theBounds.getSouthWest().lat();
	var SWLong=theBounds.getSouthWest().lng();

	console.log(NELat + ' ' + NELong + ' ' +  SWLat   + ' ' + SWLong);

	// latitude is easy.....
	var latrange=NELat-SWLat;
	var nela=NELat-(latrange*.3);
	var swla=SWLat+(latrange*.3);

	// if longitudes are same sign....
	if ((NELong>0 && SWLong>0) || (NELong<0 && SWLong<0)){
		console.log('long same sign');
		var longrange=NELong-SWLong;
		var nelo=NELong-(longrange*.3);
		var swlo=SWLong+(longrange*.3);
	} else if (NELong<0 && SWLong>0) {
		console.log('NELong<0 && SWLong>0');
		var longrange=NELong+SWLong;
		var nelo=NELong-(longrange*.3);
		var swlo=SWLong+(longrange*.3);
	} else if (NELong>0 && SWLong<0) {
		console.log('NELong>0 && SWLong<0');
		var longrange=NELong+SWLong;
		var nelo=NELong-(longrange*.3);
		var swlo=SWLong+(longrange*.3);
	} else {
		console.log('this should never happen - aborting.....');
		return false;
	}

	/*
	var longrange=NELong-SWLong;



	if (NELong>0){

		var longrange=NELong-SWLong;
		var nelo=NELong+(longrange*.4);
	} else {

		var longrange=SWLong-NELong;
		var nelo=NELong-(longrange*.4);
	}

	if (SWLong>0){
		var swlo=SWLong+(longrange*.4);
	} else {
		var swlo=SWLong-(longrange*.4);
	}

*/

	console.log(NELat + ' ' + NELong + ' ' +  SWLat   + ' ' + SWLong);

	console.log('longrange='+longrange);

	console.log('nelo='+nelo);

	console.log('swlo='+swlo);

	console.log('NELat='+NELat);
	bounds = new google.maps.LatLngBounds(
	   		new google.maps.LatLng(nela, swlo ),
			new google.maps.LatLng(swla, nelo)
		);
		rectangle = new google.maps.Rectangle({
			bounds: bounds,
			editable: true,
			draggable: true
		});

		rectangle.setMap(map);



		google.maps.event.addListener(rectangle,'bounds_changed',whereIsTheRectangle);

		whereIsTheRectangle();
	}

function dieRectangleDie(){
	$("#addARectangle").show();
	$("#dieRectangleDie").hide();
	try {
		rectangle.setMap();
	} catch(e){}

}

	function whereIsTheRectangle () {
		var theBounds=rectangle.getBounds();

		var NELat=theBounds.getNorthEast().lat();
		var NELong=theBounds.getNorthEast().lng();
		var SWLat=theBounds.getSouthWest().lat();
		var SWLong=theBounds.getSouthWest().lng();
		console.log(NELat + ' ' + NELong + ' ' +  SWLat   + ' ' + SWLong);
		$("#NELat").val(NELat);
		$("#NELong").val(NELong);
		$("#SWLat").val(SWLat);
		$("#SWLong").val(SWLong);
		$("#selectedCoords").val(NELat + ', ' + NELong + '; ' + SWLat + ', ' + SWLong);

	}

	google.maps.event.addDomListener(window, 'load', initialize);






//google.maps.event.addListener(rectangle, 'bounds_changed', sdas);



</script>
<body>


<div id="bbControl">
	<img src="/images/selector.png">
</div>
	<div id="search-panel">
		<input id="target" type="text" placeholder="Search the Map">
	</div>
	<span id="addARectangle" class="likeLink" onclick="addARectangle()">[ add bounding box tool ]</span>
	<span id="dieRectangleDie" class="likeLink" style="display: none;" onclick="dieRectangleDie()">[ remove bounding box tool ]</span>
	<input type="text" style="font-weight:bold;border:none;width:100%;color:red;"
		id="selectedCoords" name="selectedCoords" placeholder="NE coordinates; SW coordinates">
	<div id="map_canvas"></div>

	<form method="get" action="/SpecimenResults.cfm" target="_blank">
	NELat<input type="text" name="NELat" size="6" id="NELat">
	NELong<input type="text" name="NELong" size="6" id="NELong">
	SWLat<input type="text" name="SWLat" size="6" id="SWLat">
	SWLong<input type="text" name="SWLong" size="6" id="SWLong">
		<input type="submit">
	</form>
</body>
<cfinclude template="/includes/_footer.cfm">
