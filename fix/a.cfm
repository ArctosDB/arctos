<cfinclude template="/includes/_header.cfm">
<cfhtmlhead text='<script src="http://maps.google.com/maps?file=api&amp;v=2.x&amp;sensor=false&amp;key=#application.gmap_api_key#" type="text/javascript"></script>'>

<style>


.jqHandle {
   background: red;
   height:15px;
z-index:3001;
}

.jqDrag {
  width: 100%;
  cursor: move;
}

.jqResize {
   width: 15px;
   position: absolute;
   bottom: 0;
   right: 0;
   cursor: se-resize;
}

.jqDnR {
    z-index: 3000;
    position: relative;
    
    width: 180px;
    font-size: 0.77em;
    color: #618d5e;
    margin: 5px 10px 10px 10px;
    padding: 8px;
    background-color: #EEE;
    border: 1px solid #CCC;
}
</style>





<script type='text/javascript' language="javascript" src='dd.js'></script>
    <script type="text/javascript">

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
     // var div = document.createElement("div");
     // div.style.border = this.weight_ + "px solid " + this.color_;
     // div.style.position = "absolute";
	
      // Our rectangle is flat against the map, so we add our selves to the
      // MAP_PANE pane, which is at the same z-index as the map itself (i.e.,
      // below the marker shadows)
     // map.getPane(G_MAP_MAP_PANE).appendChild(div);
	
	
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
	
		var sw=this.map_.fromDivPixelToLatLng(c1);
		var ne=this.map_.fromDivPixelToLatLng(c2)
	console.log('c1: ' + c1 + '; c2: ' + c2);
	console.log('SW: ' + sw);
	console.log('NE: ' + ne);
	
	
      // Now position our DIV based on the DIV coordinates of our bounds
      this.div_.style.width = Math.abs(c2.x - c1.x) + "px";
      this.div_.style.height = Math.abs(c2.y - c1.y) + "px";
      this.div_.style.left = (Math.min(c2.x, c1.x) - this.weight_) + "px";
      this.div_.style.top = (Math.min(c2.y, c1.y) - this.weight_) + "px";
    }


    function initialize() {
      if (GBrowserIsCompatible()) {
        var map = new GMap2(document.getElementById("map_canvas"));
        map.setCenter(new GLatLng(37.4419, -122.1419), 13);

        // Display a rectangle in the center of the map at about a quarter of
        // the size of the main map
        var bounds = map.getBounds();
        var southWest = bounds.getSouthWest();
        var northEast = bounds.getNorthEast();
        var lngDelta = (northEast.lng() - southWest.lng()) / 4;
        var latDelta = (northEast.lat() - southWest.lat()) / 4;
        var rectBounds = new GLatLngBounds(
            new GLatLng(southWest.lat() + latDelta,
                        southWest.lng() + lngDelta),
            new GLatLng(northEast.lat() - latDelta,
                        northEast.lng() - lngDelta));
       // map.addOverlay(new Rectangle(rectBounds));
      }
    }


$().ready(function() {
  var div = document.createElement("div");
	div.id='ex3';
	div.className='jqDnR';
	
	
var div2 = document.createElement("div");
	div2.className='jqHandle jqDrag';

var div3 = document.createElement("div");
	div3.className='jqHandle jqResize';
  document.body.appendChild(div);
  div.appendChild(div2);
		div.appendChild(div3);
		
		
  $('#ex3').jqDrag('.jqDrag').jqResize('.jqResize');
});
    </script>
  </head>

  <body onload="initialize()" onunload="GUnload()">
    <div id="map_canvas" style="width: 500px; height: 300px"></div>
  </body>
</html>


<!----------------
<script src="dragzoom_mod.js" language="javascript" type="text/javascript"></script>

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
---------------->
<cfinclude template="/includes/_footer.cfm">
