<!----
this works
stop this works 





---->


<script src="/includes/dragzoom_packed.js" language="javascript" type="text/javascript"></script>
<cfoutput>
				<script type="text/javascript" src="http://www.google.com/jsapi?key=#application.gmap_api_key#"></script>
</cfoutput>

<label for="map_canvas">
	Click 'select' then click and drag for spatial query&nbsp;&nbsp;&nbsp;
	<span class="likeLink" onclick="getDocs('pageHelp/spatial_query')";>More Info</span>
</label>
<input type="text" style="font-weight:bold;border:none;width:100%" id="selectedCoords">
<input type="hidden" name="nwLat" id="nwLat">
<input type="hidden" name="nwlong" id="nwlong">
<input type="hidden" name="selat" id="selat">
<input type="hidden" name="selong" id="selong">
<div id="map_canvas" style="width: 100%; height: 400px;"></div>
<script language="javascript" type="text/javascript">
					google.load("maps", "2");
       						google.load("elements", "1", {packages : ["localsearch"]});
       				
					function initializeMap() {
						if (GBrowserIsCompatible()) {
							
							var map = new GMap2(document.getElementById("map_canvas"));
							var center = new GLatLng(55, -135);
							map.setCenter(center, 3);
							map.addControl(new GLargeMapControl(),new GControlPosition(G_ANCHOR_TOP_LEFT, new GSize(1,1)));
							map.addMapType(G_PHYSICAL_MAP);
							map.addControl(new GScaleControl(),new GControlPosition(G_ANCHOR_BOTTOM_LEFT, new GSize(125,1)));
							map.addControl(new GMapTypeControl(),new GControlPosition(G_ANCHOR_TOP_RIGHT, new GSize(1,1)));
							map.addControl(new google.elements.LocalSearch(),new GControlPosition(G_ANCHOR_BOTTOM_LEFT, new GSize(250,1)));
							
							var boxStyleOpts = {
								opacity:.0,
								border:"2px solid green"
							}
							var otherOpts = {
								overlayRemoveTime:99999999999999,  
								buttonHTML:"Turn on Select",
								buttonZoomingHTML:"Turn off Select",
								buttonStartingStyle:{left:'150px', border: '1px solid black', padding: '4px',fontSize:'small',color:'blue',fontWeight:'bold'},
								buttonZoomingStyle:{background: 'lightblue'},
								backButtonEnabled : true,
								backButtonHTML : 'Go Back',
								minDragSize:3
							};
							var callbacks = {
								dragend:function(nw,ne,se,sw,nwpx,nepx,sepx,swpx){
									jQuery('##nwLat').val(nw.lat());
									jQuery('##nwlong').val(nw.lng());
									jQuery('##selat').val(se.lat());
									jQuery('##selong').val(se.lng());
									jQuery('##selectedCoords').val('Selected Area: NW=' + nw + '; SE=' + se);
								}
							};
							
							map.addControl(new DragZoomControl(boxStyleOpts, otherOpts, callbacks),new GControlPosition(G_ANCHOR_BOTTOM_LEFT, new GSize(1,1)));
						}
					}
					//google.setOnLoadCallback(initializeMap);
									
				</script>
				
				<!-----
<script language="javascript" type="text/javascript">
	
	function initializeMap() {
		console.log('initializeMap');
		if (GBrowserIsCompatible()) {
		
							
		
		
		
			var map = new GMap2(document.getElementById("map_canvas"));
			map.setCenter(new google.maps.LatLng(37.4419, -122.1419), 13);
			map.setUIToDefault();
			//map.enableGoogleBar();			
			//map.enableGoogleBar(new GControlPosition(G_ANCHOR_BOTTOM_LEFT, new GSize(250,1)));
			//map.addControl(new GLargeMapControl(),new GControlPosition(G_ANCHOR_TOP_LEFT, new GSize(1,1)));
			map.addControl(new google.elements.LocalSearch(),new GControlPosition(G_ANCHOR_BOTTOM_LEFT, new GSize(250,1)));
			
			var boxStyleOpts = {
								opacity:.0,
								border:"2px solid green"
							}
							var otherOpts = {
								overlayRemoveTime:99999999999999,  
								buttonHTML:"Turn on Select",
								buttonZoomingHTML:"Turn off Select",
								buttonStartingStyle:{left:'150px', border: '1px solid black', padding: '4px',fontSize:'small',color:'blue',fontWeight:'bold'},
								buttonZoomingStyle:{background: 'lightblue'},
								backButtonEnabled : true,
								backButtonHTML : 'Go Back',
								minDragSize:3
							};
							var callbacks = {
								dragend:function(nw,ne,se,sw,nwpx,nepx,sepx,swpx){
									jQuery('##nwLat').val(nw.lat());
									jQuery('##nwlong').val(nw.lng());
									jQuery('##selat').val(se.lat());
									jQuery('##selong').val(se.lng());
									jQuery('##selectedCoords').val('Selected Area: NW=' + nw + '; SE=' + se);
								}
							};
						//	map.addControl(new DragZoomControl(boxStyleOpts, otherOpts, callbacks),new GControlPosition(G_ANCHOR_BOTTOM_LEFT, new GSize(30,50)));
					
		} else {
			alert('Your browser does not support Google Maps.');
		}
		function cb(){console.log('callback');}
			
		 	google.load("maps", "2");
		 	google.load("elements", "1", {packages : ["localsearch"]});
		 	
		  google.setOnLoadCallback(initializeMap);
		
	}
</script>
---->



<span onclick="initializeMap()">initializy</span>

<span onclick="GUnload();">GUnload();</span>


<!---- this works


<cfoutput>
	<cfhtmlhead text='<script type="text/javascript" src="http://www.google.com/jsapi?key=#application.gmap_api_key#"></script>'>

<script src="/includes/dragzoom_packed.js" language="javascript" type="text/javascript"></script>

<label for="map_canvas">
	Click 'select' then click and drag for spatial query&nbsp;&nbsp;&nbsp;
	<span class="likeLink" onclick="getDocs('pageHelp/spatial_query')";>More Info</span>
</label>
<input type="text" style="font-weight:bold;border:none;width:100%" id="selectedCoords">
<input type="hidden" name="nwLat" id="nwLat">
<input type="hidden" name="nwlong" id="nwlong">
<input type="hidden" name="selat" id="selat">
<input type="hidden" name="selong" id="selong">
<div id="map_canvas" style="width: 100%; height: 400px;"></div>
<script language="javascript" type="text/javascript">
	google.load("maps", "2.x");
   	function initializeMap() {
    	var map = new google.maps.Map2(document.getElementById("map_canvas"));
    	map.setCenter(new google.maps.LatLng(55, -135), 3);
    	
    	var boxStyleOpts = {
								opacity:.0,
								border:"2px solid green"
							}
							var otherOpts = {
								overlayRemoveTime:99999999999999,  
								buttonHTML:"Turn on Select",
								buttonZoomingHTML:"Turn off Select",
								buttonStartingStyle:{left:'150px', border: '1px solid black', padding: '4px',fontSize:'small',color:'blue',fontWeight:'bold'},
								buttonZoomingStyle:{background: 'lightblue'},
								backButtonEnabled : true,
								backButtonHTML : 'Go Back',
								minDragSize:3
							};
							var callbacks = {
								dragend:function(nw,ne,se,sw,nwpx,nepx,sepx,swpx){
									jQuery('##nwLat').val(nw.lat());
									jQuery('##nwlong').val(nw.lng());
									jQuery('##selat').val(se.lat());
									jQuery('##selong').val(se.lng());
									jQuery('##selectedCoords').val('Selected Area: NW=' + nw + '; SE=' + se);
								}
							};
							map.addControl(new DragZoomControl(boxStyleOpts, otherOpts, callbacks),new map.controlPosition(G_ANCHOR_BOTTOM_LEFT, new GSize(1,1)));
					
	}
  	google.setOnLoadCallback(initializeMap);
</script>
</cfoutput>



<span onclick="initializeMap()">initializy</span>
end works --->

<!----


if (GBrowserIsCompatible()) {
			initializeMap();
		}
<script src="/includes/dragzoom_packed.js" language="javascript" type="text/javascript"></script>

<cfinclude template="/includes/_header.cfm">

<script src="http://maps.google.com/maps?file=api&amp;v=2&amp;sensor=false&amp;key=" type="text/javascript"></script>


<script>
jQuery(document.body).unload(function() {
		if (GBrowserIsCompatible()) {
			GUnload();
		}
	});
	
	
	jQuery(document).ready(function() {
	  	initializeMap();
	});
</script>
	<label for="map_canvas">
					Click 'select' then click and drag for spatial query&nbsp;&nbsp;&nbsp;
					<span class="likeLink" onclick="getDocs('pageHelp/spatial_query')";>More Info</span>
					
				</label>				
				<input type="text" style="font-weight:bold;border:none;width:100%" id="selectedCoords">
				<input type="hidden" name="nwLat" id="nwLat">
				<input type="hidden" name="nwlong" id="nwlong">
				<input type="hidden" name="selat" id="selat">
				<input type="hidden" name="selong" id="selong">


				<script language="javascript" type="text/javascript">
					google.load("maps", "2");
       				google.load("elements", "1", {packages : ["localsearch"]});
       				function initializeMap() {
						if (GBrowserIsCompatible()) {
							var map = new GMap2(document.getElementById("map_canvas"));
							var center = new GLatLng(55, -135);
							map.setCenter(center, 3);
							map.addControl(new GLargeMapControl(),new GControlPosition(G_ANCHOR_TOP_LEFT, new GSize(1,1)));
							map.addMapType(G_PHYSICAL_MAP);
							map.addControl(new GScaleControl(),new GControlPosition(G_ANCHOR_BOTTOM_LEFT, new GSize(125,1)));
							map.addControl(new GMapTypeControl(),new GControlPosition(G_ANCHOR_TOP_RIGHT, new GSize(1,1)));
							map.addControl(new google.elements.LocalSearch(),new GControlPosition(G_ANCHOR_BOTTOM_LEFT, new GSize(250,1)));
							
							
							
							
							GMapType.G_SATELLITE_3D_MAP
							
							
							
							
							var boxStyleOpts = {
								opacity:.0,
								border:"2px solid green"
							}
							var otherOpts = {
								overlayRemoveTime:99999999999999,  
								buttonHTML:"Turn on Select",
								buttonZoomingHTML:"Turn off Select",
								buttonStartingStyle:{left:'150px', border: '1px solid black', padding: '4px',fontSize:'small',color:'blue',fontWeight:'bold'},
								buttonZoomingStyle:{background: 'lightblue'},
								backButtonEnabled : true,
								backButtonHTML : 'Go Back',
								minDragSize:3
							};
							var callbacks = {
								dragend:function(nw,ne,se,sw,nwpx,nepx,sepx,swpx){
									jQuery('##nwLat').val(nw.lat());
									jQuery('##nwlong').val(nw.lng());
									jQuery('##selat').val(se.lat());
									jQuery('##selong').val(se.lng());
									jQuery('##selectedCoords').val('Selected Area: NW=' + nw + '; SE=' + se);
								}
							};
							map.addControl(new DragZoomControl(boxStyleOpts, otherOpts, callbacks),new GControlPosition(G_ANCHOR_BOTTOM_LEFT, new GSize(1,1)));
						}
					}					
				</script>
---->
