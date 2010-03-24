<cfinclude template="/includes/_header.cfm">
<cfhtmlhead text='<script src="http://maps.google.com/maps?file=api&amp;v=2.x&amp;sensor=false&amp;key=#application.gmap_api_key#" type="text/javascript"></script>'>

<script type='text/javascript' src='x_core.js'></script>

<script type='text/javascript' src='x_event.js'></script>
<script type='text/javascript' src='x_drag.js'></script>


<!----
<link href="g.css" type="text/css" rel="stylesheet">





<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml">
<head>
	<title>Bounds Test</title>
	<meta http-equiv="content-type" content="text/html; charset=UTF-8">
	<meta name="robots" content="noindex,nofollow">
	
<style type="text/css">
      v\:* {
        behavior:url(#default#VML);
      }
    </style>
	---->
	<style type="text/css">
		<!--
		.divlayer {
		 border: 2px solid #ff0000;
		 background-color:#ffe4e1;
		 filter:alpha(opacity=50);
		 opacity: 0.5;
		 -moz-opacity:0.5;
		 z-index: 10000;
		 height: 100px;
		 width: 100px;
		 left: 0px;
		 top: 0px;
		 margin: 0px;
		 padding: 0px;
		 position: absolute;
		 line-height:0px;
		 cursor:move;
		}
		.Bar {
		  position:absolute;
		  overflow:hidden;
		  height:0px;
		  width:0px;
		}
		.ResBtn {
		  background-image: url(resize.gif);
		  background-repeat:no-repeat;
		  background-position:center;
		  position:absolute;
		  overflow:hidden;
		  width:20px;
		  height:20px;
		  margin:0;
		  padding:0;
		  cursor:se-resize;
		}
		.ZoomBtn {
		  background-image: url(magnify.png);
		  background-repeat:no-repeat;
		  background-position:center;
		  position:absolute;
		  overflow:hidden;
		  width:20px;
		  height:20px;
		  margin:0;
		  padding:0;
		  cursor:hand;
		  cursor:pointer;
		}
-->





html, BODY
{
    height:100%;
    margin: 0px auto;
}
body 
{
    font-family: verdana, helvetica, sans-serif;
    font-size: 12px;
    color: #555;
    background-color: #efefef;
}
.maintext
{
    font-family: verdana, helvetica, sans-serif;
    font-size: 12px;
    color: #555;
}

#wrapper 
{
    width : 100%;
    height: 100%;
}
#header 
{
    background-color: #000000;
    width: 100%;
    height: 5%;
}
.headercontent
{
    padding: 0px 0px 0px 30px;
    color: #efefef;
    font-weight: bold;
    font-size: 1.2em;
}
#leftcol 
{
    background-color: #000000;
    float: left;
    width: 400px;
    height: 95%;
}
#leftcolwrapper
{
    background-color: #efefef;
    overflow :auto;
    height: 98%;
}
#left
{
    margin: 20px 20px 20px 20px;
    z-index: 1;
}
#content 
{
    overflow:auto;
    height: 95%;
}
#mapwrapper
{
    margin: 20px 20px 0px 20px;
    height:100%;
}
#map 
{
    overflow:auto;
    height:100%;
}
#copy
{
    margin: 7px 0px 0px 10px;
    color: #efefef;
}
.accordianHeader
{
    border: 1px solid #cccccc;
    color: White;
    background-color: #000000;
    font-family: verdana, helvetica, sans-serif;
    font-size: 12px;
    font-weight: bold;
    padding: 5px;
    margin-top: 5px;
    cursor: pointer;  
}
.accordianContent
{
    background-color: #d3deef;
    border: 1px dashed #cccccc;
    border-top: none;
    padding: 5px;
    padding-top: 10px; 
}
.accordianLink
{
    color: #efefef;
}
#debug
{
    margin-left: 20px;
    margin-right: 20px;
    width: 90%;
    overflow: auto;
    height: 250px;
    font-family: Courier;
}
.Node, .NodeOver, .NodeSelected, .NodeLoading 
{ 
   cursor: hand; 
} 

.Node 
{ 
   color: #000000; 
} 

.NodeUnModerated 
{ 
   color: red; 
} 

.NodeOver 
{ 
   color: #000000; 
} 

.NodeSelected 
{ 
   background-color: #000000; 
   color: white; 
} 

.NodeLoading 
{ 
   color: red; 
}
.WinGridHeader
{
    font-size: 13px;
    background-color: #000000;
    color: #efefef;
    font-weight: bold;
}
.WinGridItem
{
    font-size: 12px;
    background-color: #efefef;
    color: #555;
}
.WinGridItemAlt
{
    font-size: 12px;
    background-color: #d3deef;
    color: #555;
}
.WinGridFooter
{
    font-size: 12px;
    color: #555;
}
.WinGridPager
{
    font-size: 10px;
    color: #555;
}
.WinGrid tr th, .WinGrid tr td
{
    border: solid 1px #555;
}
.rpheader 
{
	cursor: hand; 
	cursor: pointer; 
	color: #555;
	padding: 10px 10px 10px 10px; 
}
.rpdetails 
{ 
	display:none; 
	visibility:hidden; 
	padding: 10px 10px 10px 10px; 
}
/* Caption Images for TabControl etc */
.catItemsTabControlIcon
{
	background:transparent url(../images/tabicons/application_view_list.gif) no-repeat 0 0;
	padding-left:20px !important;
}
.catReadingTabControlIcon
{
	background:transparent url(../images/tabicons/book_open.gif) no-repeat 0 0;
	padding-left:20px !important;
}
.itemDetailsTabControlIcon
{
	background:transparent url(../images/tabicons/application_view_detail.gif) no-repeat 0 0;
	padding-left:20px !important;
}
.itemCommentsTabControlIcon
{
	background:transparent url(../images/tabicons/comments.gif) no-repeat 0 0;
	padding-left:20px !important;
}
.itemCommentsAddTabControlIcon
{
	background:transparent url(../images/tabicons/comments_add.gif) no-repeat 0 0;
	padding-left:20px !important;
}
.instructionsFlyoutPopup
{
    width:500px;
    background-color:white;
    border: solid 1px silver;
    padding:10px;
    z-index:2000;
}
.WinGridItemLight
{
    font-size: 12px;
    background-color: #efefef;
    color: #000000;
}
.contextMenu
{
    font-family: verdana, helvetica, sans-serif;
    font-size: 12px;
    color: #555;
}
.context 
{
    font-family:Arial, sans-serif;
    text-decoration:none;
    color:#4444ff;
    font-size:small;
}
a:link div
{
    text-decoration:none;
}
a:hover div 
{
    background:#eee;
}       





  	</style>
<script>

// ******************************* //
var fen1;
var gpstart, gpend;

// ******************************* //
// from the documentation here: http://cross-browser.com/x/examples/drag2.php
// ******************************* //
window.onunload = function()
{
    fen1.onunload();
}

// ******************************* //
// main object: http://cross-browser.com/x/examples/drag2.php
// ******************************* //

function xFenster(eleId, iniX, iniY, barId, resBtnId, zoomBtnId)
{
  // Private Properties
  var me = this;
  var ele = xGetElementById(eleId);
  var rBtn = xGetElementById(resBtnId);
  
  var zBtn = xGetElementById(zoomBtnId);

  // Public Methods
  this.onunload = function()
  {
    if (xIE4Up) { // clear cir refs
      xDisableDrag(barId);
      xDisableDrag(rBtn);
      zBtn.onclick = ele.onmousedown = null;
      me = ele = rBtn = zBtn = null;
    }
  }

  this.paint = function()
  {
    xMoveTo(rBtn, xWidth(ele) - xWidth(rBtn) - 2, xHeight(ele) - xHeight(rBtn) - 2);
    xMoveTo(zBtn, 0, xHeight(ele) - xHeight(zBtn) - 2);
  }

  // Private Event Listeners
  function barOnDrag(e, mdx, mdy)
  {
    xMoveTo(ele, xLeft(ele) + mdx, xTop(ele) + mdy);
    //console.log('barOnDrag: ' + mdx + '; ' + mdy + '; ' + e);
    //whereAreYou();
    whurUB();
  }

  function resOnDrag(e, mdx, mdy)
  {
    xResizeTo(ele, xWidth(ele) + mdx, xHeight(ele) + mdy);
    me.paint();
    //console.log('resOnDrag: ' + mdx + '; ' + mdy + '; ' + e + '; ' + xWidth(ele));
   // whereAreYou();
   whurUB();
  }

  function fenOnMousedown()
  {
    xZIndex(ele, xFenster.z++);
    console.log('fenOnMousedown');
  }

// ******************************* //
// added function to handle zoom on bounds
// with code taken from Mike Williams tutorial: http://www.econym.demon.co.uk/googlemaps/basic14.htm
// ******************************* //
 
  
  function ZoomOnClick()
  {
  	gpstart = getLatLonFromPixel(xLeft(ele), xTop(ele));
  	gpend = getLatLonFromPixel(xLeft(ele) + xWidth(ele), xTop(ele) + xHeight(ele));

        // ===== Start with an empty GLatLngBounds object =====
        var bounds = new GLatLngBounds();
        var tlpoint = new GLatLng(gpstart.lat(), gpstart.lng());
        bounds.extend(tlpoint);
        var brpoint = new GLatLng(gpend.lat(), gpend.lng());
        bounds.extend(brpoint);

        // ===== determine the zoom level from the bounds =====
          map.setZoom(map.getBoundsZoomLevel(bounds));

		// ===== determine the centre from the bounds ======
          var clat = (bounds.getNorthEast().lat() + bounds.getSouthWest().lat()) /2;
          var clng = (bounds.getNorthEast().lng() + bounds.getSouthWest().lng()) /2;
          map.setCenter(new GLatLng(clat,clng));

	// show the coords for params
	/*
	var	dMessage = document.getElementById("message");
	dMessage.innerHTML = "start x=" + gpstart.lat() + " - start y=" + gpstart.lng()
		+ "<br>end x=" + gpend.lat() + " - end y=" + gpend.lng();
		*/
		
		whurUB();
  }

  // Constructor Code
  xFenster.z++;
  this.paint();
  xEnableDrag(barId, null, barOnDrag, null);
  xEnableDrag(rBtn, null, resOnDrag, null);
  zBtn.onclick = ZoomOnClick;
  ele.onmousedown = fenOnMousedown;
  xShow(ele);
} // end xFenster object prototype

xFenster.z = 1000; // xFenster static property

// ******************************* //
// code taken from Dave: http://groups.google.com/group/Google-Maps-API/browse_thread/thread/2a760c375e1ff905/8ed93dddcecfbdb0?q=selection&rnum=8#8ed93dddcecfbdb0
// ******************************* //
function getLatLonFromPixel(x,y) {
var swpixel = map.getCurrentMapType().getProjection().fromLatLngToPixel(map.getBounds().getSouthWest(),map.getZoom());
var nepixel = map.getCurrentMapType().getProjection().fromLatLngToPixel(map.getBounds().getNorthEast(),map.getZoom());
 return map.getCurrentMapType().getProjection().fromPixelToLatLng(new GPoint(swpixel.x + x,nepixel.y + y),map.getZoom());
}


 function whurUB()
  {
  	  var ele = xGetElementById('zoomLayer');
  	
  	
  	gpstart = getLatLonFromPixel(xLeft(ele), xTop(ele));
  	gpend = getLatLonFromPixel(xLeft(ele) + xWidth(ele), xTop(ele) + xHeight(ele));

/*
        // ===== Start with an empty GLatLngBounds object =====
        var bounds = new GLatLngBounds();
        var tlpoint = new GLatLng(gpstart.lat(), gpstart.lng());
        bounds.extend(tlpoint);
        var brpoint = new GLatLng(gpend.lat(), gpend.lng());
        bounds.extend(brpoint);

        // ===== determine the zoom level from the bounds =====
          map.setZoom(map.getBoundsZoomLevel(bounds));

		// ===== determine the centre from the bounds ======
          var clat = (bounds.getNorthEast().lat() + bounds.getSouthWest().lat()) /2;
          var clng = (bounds.getNorthEast().lng() + bounds.getSouthWest().lng()) /2;
          map.setCenter(new GLatLng(clat,clng));
*/
	// show the coords for params
	var	dMessage = document.getElementById("message");
	dMessage.innerHTML = "start x=" + gpstart.lat() + " - start y=" + gpstart.lng()
		+ "<br>end x=" + gpend.lat() + " - end y=" + gpend.lng();
  }
  
  
  
// ******************************* //
// function to initiate the div layer
// ******************************* //
function setDiv() {
	fen1 = new xFenster('zoomLayer', 0, 0, 'zoomLayer', 'ResBtn', 'ZoomBtn');
	pos = new GControlPosition(G_ANCHOR_TOP_LEFT, new GSize(47,73));
	pos.apply(document.getElementById("zoomLayer"));
	map.getContainer().appendChild(document.getElementById("zoomLayer"));
	document.getElementById("zoomLayer").style.visibility = 'hidden'
}

// ******************************* //
// function to set the custom control
// ******************************* //
function ToggleZoomControl() {
}
ToggleZoomControl.prototype = new GControl();

ToggleZoomControl.prototype.initialize = function(map) {
	var container = document.createElement("div");
	var zoomToggle = document.createElement("img");
  	this.setImageStyle_(zoomToggle);
  	container.appendChild(zoomToggle);

  	GEvent.addDomListener(zoomToggle, "click", function() {
  		ToggleDisplay('zoomLayer');
  	});

	map.getContainer().appendChild(container);
	return container;
}

ToggleZoomControl.prototype.getDefaultPosition = function() {
  return new GControlPosition(G_ANCHOR_TOP_LEFT, new GSize(47, 47));
}

// Sets the proper CSS for the given img element.
ToggleZoomControl.prototype.setImageStyle_ = function(img) {
	img.src = "selector.png";
	img.style.cursor = "pointer";
	img.alt = "Show/Hide Selector Box";
}

function ToggleDisplay(id){
	var elem = document.getElementById(id);
	if (elem){
		if (elem.style.display != 'block'){
			elem.style.display = 'block';
			elem.style.visibility = 'visible';
		}
		else{
			elem.style.display = 'none';
			elem.style.visibility = 'hidden';
		}
	}
}

  </script>
<!---
  </head>
--->
<!---
<body onunload="GUnload()">
--->
				<div class="divlayer" id="zoomLayer" title="Drag to Move">
					<div id="Bar" class="Bar" title="Drag to Move"></div>

					<!---
					<div id="ZoomBtn"></div>
					---><div id="ZoomBtn" class="ZoomBtn" title="Click to Zoom"></div>
					
					<div id="ResBtn" class="ResBtn" title="Drag to Resize"></div>
				</div>
				<!---<div id="map" style="width: 100%; height: 90%"></div>--->
				<div id="message"></div>
<!----
<script>
	var map = new GMap2(document.getElementById("map"));
	map.addControl(new GLargeMapControl());
	map.addControl(new GMapTypeControl());
	map.addControl(new GScaleControl());
	map.addControl(new ToggleZoomControl());
	map.setCenter(new GLatLng(54.70235509327093, -3.2080078125), 6);
	setDiv();
	
	GEvent.addListener(map, "moveend", function() {
		  console.log('whurUB');
		  whurUB();
		});
			
	
	
</script>
---->
<label for="map">
	Click 'select' then click and drag for spatial query&nbsp;&nbsp;&nbsp;
	<span class="likeLink" onclick="getDocs('pageHelp/spatial_query')";>More Info</span>
</label>
<input type="text" style="font-weight:bold;border:none;width:100%" id="selectedCoords">
<input type="hidden" name="nwLat" id="nwLat">
<input type="hidden" name="nwlong" id="nwlong">
<input type="hidden" name="selat" id="selat">
<input type="hidden" name="selong" id="selong">
<div id="map" style="width: 100%; height: 400px;"></div>
<script language="javascript" type="text/javascript">
	jQuery(document).ready(function() {
	  	initializeMap();
	});
	jQuery(document.body).unload(function() {
		GUnload();
	});
	function initializeMap() {
		if (GBrowserIsCompatible()) {
			var map = new GMap2(document.getElementById("map"));
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
			/*
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
			*/
			/// newcode
			setDiv();
			
			
			GEvent.addListener(map, "moveend", function() {
		  console.log('whurUB');
		  whurUB();
		});
			
		}
	}
</script>



<!---
</body>
</html>
--->

<cfinclude template="/includes/_footer.cfm">