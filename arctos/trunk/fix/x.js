
	  	
	  	
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



					