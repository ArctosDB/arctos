<cfinclude template="/includes/_header.cfm">
<cfhtmlhead text='<script src="http://maps.google.com/maps?file=api&amp;v=3.x&amp;sensor=false&amp;key=#application.gmap_api_key#" type="text/javascript"></script>'>
	<!---
	<script src="/includes/dragzoom_packed.js" language="javascript" type="text/javascript"></script>
	--->
<label for="map_canvas">
	Click 'select' then click and drag for spatial query&nbsp;&nbsp;&nbsp;
	<span class="likeLink" onclick="getDocs('pageHelp/spatial_query')";>More Info</span>
</label>
<input type="text" style="font-weight:bold;border:none;width:100%" id="selectedCoords">
<input type="hidden" name="nwLat" id="nwLat">
<input type="hidden" name="nwlong" id="nwlong">
<input type="hidden" name="selat" id="selat">
<input type="hidden" name="selong" id="selong">
<div id="map" style="width: 600px; height: 400px;"></div>
<script language="javascript" type="text/javascript">
	jQuery(document).ready(function() {
	  	initializeMap();
	});
	jQuery(document.body).unload(function() {
		GUnload();
	});
	function initializeMap() {
		if (GBrowserIsCompatible()) {
			// A Rectangle is a simple overlay that outlines a lat/lng bounds on the
// map. It has a border of the given weight and color and can optionally
// have a semi-transparent background color.
function Rectangle(bounds, opt_weight, opt_color) {
  this.bounds_ = bounds;
  this.weight_ = opt_weight || 2;
  this.color_ = opt_color || "#888888";
}
Rectangle.prototype = new GOverlay();

// Creates the DIV representing this rectangle.
Rectangle.prototype.initialize = function(map) {
  // Create the DIV representing our rectangle
  var div = document.createElement("div");
  div.style.border = this.weight_ + "px solid " + this.color_;
  div.style.position = "absolute";

  // Our rectangle is flat against the map, so we add our selves to the
  // MAP_PANE pane, which is at the same z-index as the map itself (i.e.,
  // below the marker shadows)
  map.getPane(G_MAP_MAP_PANE).appendChild(div);

  this.map_ = map;
  this.div_ = div;
}

// Remove the main DIV from the map pane
Rectangle.prototype.remove = function() {
  this.div_.parentNode.removeChild(this.div_);
}

// Copy our data to a new Rectangle
Rectangle.prototype.copy = function() {
  return new Rectangle(this.bounds_, this.weight_, this.color_,
                       this.backgroundColor_, this.opacity_);
}

// Redraw the rectangle based on the current projection and zoom level
Rectangle.prototype.redraw = function(force) {
  // We only need to redraw if the coordinate system has changed
  if (!force) return;

  // Calculate the DIV coordinates of two opposite corners of our bounds to
  // get the size and position of our rectangle
  var c1 = this.map_.fromLatLngToDivPixel(this.bounds_.getSouthWest());
  var c2 = this.map_.fromLatLngToDivPixel(this.bounds_.getNorthEast());

  // Now position our DIV based on the DIV coordinates of our bounds
  this.div_.style.width = Math.abs(c2.x - c1.x) + "px";
  this.div_.style.height = Math.abs(c2.y - c1.y) + "px";
  this.div_.style.left = (Math.min(c2.x, c1.x) - this.weight_) + "px";
  this.div_.style.top = (Math.min(c2.y, c1.y) - this.weight_) + "px";
}

var map = new GMap2(document.getElementById("map"));
map.addControl(new GSmallMapControl());
map.addControl(new GMapTypeControl());
map.setCenter(new GLatLng(37.4419, -122.1419), 13);

// Display a rectangle in the center of the map at about a quarter of
// the size of the main map
var bounds = map.getBounds();
var southWest = bounds.getSouthWest();
var northEast = bounds.getNorthEast();
var lngDelta = (northEast.lng() - southWest.lng()) / 4;
var latDelta = (northEast.lat() - southWest.lat()) / 4;
var rectBounds = new GLatLngBounds(
    new GLatLng(southWest.lat() + latDelta, southWest.lng() + lngDelta),
    new GLatLng(northEast.lat() - latDelta, northEast.lng() - lngDelta));
map.addOverlay(new Rectangle(rectBounds));
			
			
			
			
			/*
			var map = new GMap2(document.getElementById("map_canvas"));
			var center = new GLatLng(55, -135);
			map.setCenter(center, 3);
			map.addControl(new GLargeMapControl(),new GControlPosition(G_ANCHOR_TOP_LEFT, new GSize(1,1)));
			map.addMapType(G_PHYSICAL_MAP);
			map.addControl(new GScaleControl(),new GControlPosition(G_ANCHOR_BOTTOM_LEFT, new GSize(1,50)));
			map.addControl(new GMapTypeControl(),new GControlPosition(G_ANCHOR_TOP_RIGHT, new GSize(1,1)));
			
			map.enableGoogleBar();
			
			
			*/
			/*
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
			*/	
			//map.addControl(new DragZoomControl(boxStyleOpts, otherOpts, callbacks),new GControlPosition(G_ANCHOR_BOTTOM_LEFT, new GSize(325,4)));
		}
	}
</script>



<cfinclude template = "/includes/_footer.cfm">