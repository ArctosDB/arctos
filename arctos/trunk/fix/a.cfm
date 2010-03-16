<cfinclude template="/includes/_header.cfm">
<cfhtmlhead text='<script src="http://maps.google.com/maps?file=api&amp;v=2.x&amp;sensor=false&amp;key=#application.gmap_api_key#" type="text/javascript"></script>'>
<cfoutput>
	
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
	jQuery(document).ready(function() {
	  	initializeMap();
	});
	jQuery(document.body).unload(function() {
		GUnload();
	});
	function initializeMap() {
		if (GBrowserIsCompatible()) {
			var map = new GMap2(document.getElementById("map_canvas"));
			var center = new GLatLng(55, -135);
			map.setCenter(center, 3);
			map.addControl(new GLargeMapControl(),new GControlPosition(G_ANCHOR_TOP_LEFT, new GSize(1,1)));
			map.addMapType(G_PHYSICAL_MAP);
			map.addControl(new GScaleControl(),new GControlPosition(G_ANCHOR_BOTTOM_LEFT, new GSize(1,50)));
			map.addControl(new GMapTypeControl(),new GControlPosition(G_ANCHOR_TOP_RIGHT, new GSize(1,1)));
			
			map.enableGoogleBar();
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
					jQuery('#nwLat').val(nw.lat());
					jQuery('#nwlong').val(nw.lng());
					jQuery('#selat').val(se.lat());
					jQuery('#selong').val(se.lng());
					jQuery('#selectedCoords').val('Selected Area: NW=' + nw + '; SE=' + se);
				}
			};			
			map.addControl(new DragZoomControl(boxStyleOpts, otherOpts, callbacks),new GControlPosition(G_ANCHOR_BOTTOM_LEFT, new GSize(325,4)));
		}
	}
</script>



<cfinclude template = "includes/_footer.cfm">