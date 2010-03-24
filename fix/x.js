var fen1;
var gpstart, gpend;
window.onunload = function()
{
    fen1.onunload();
}

function xFenster(eleId, iniX, iniY, barId, resBtnId, zoomBtnId)
{
  var me = this;
  var ele = xGetElementById(eleId);
  var rBtn = xGetElementById(resBtnId);  
  var zBtn = xGetElementById(zoomBtnId);

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

  function barOnDrag(e, mdx, mdy)
  {
    xMoveTo(ele, xLeft(ele) + mdx, xTop(ele) + mdy);
    whurUB();
  }

  function resOnDrag(e, mdx, mdy)
  {
    xResizeTo(ele, xWidth(ele) + mdx, xHeight(ele) + mdy);
    me.paint();
    whurUB();
  }

  function fenOnMousedown()
  {
    xZIndex(ele, xFenster.z++);
  }
  
  function ZoomOnClick()
  {
  	gpstart = getLatLonFromPixel(xLeft(ele), xTop(ele));
  	gpend = getLatLonFromPixel(xLeft(ele) + xWidth(ele), xTop(ele) + xHeight(ele));
        var bounds = new GLatLngBounds();
        var tlpoint = new GLatLng(gpstart.lat(), gpstart.lng());
        bounds.extend(tlpoint);
        var brpoint = new GLatLng(gpend.lat(), gpend.lng());
        bounds.extend(brpoint);
          map.setZoom(map.getBoundsZoomLevel(bounds));
          var clat = (bounds.getNorthEast().lat() + bounds.getSouthWest().lat()) /2;
          var clng = (bounds.getNorthEast().lng() + bounds.getSouthWest().lng()) /2;
          map.setCenter(new GLatLng(clat,clng));
          whurUB();
  }

  xFenster.z++;
  this.paint();
  xEnableDrag(barId, null, barOnDrag, null);
  xEnableDrag(rBtn, null, resOnDrag, null);
  zBtn.onclick = ZoomOnClick;
  ele.onmousedown = fenOnMousedown;
  xShow(ele);
} // end xFenster object prototype

xFenster.z = 1000; // xFenster static property

function getLatLonFromPixel(x,y) {
	var swpixel = map.getCurrentMapType().getProjection().fromLatLngToPixel(map.getBounds().getSouthWest(),map.getZoom());
	var nepixel = map.getCurrentMapType().getProjection().fromLatLngToPixel(map.getBounds().getNorthEast(),map.getZoom());
	return map.getCurrentMapType().getProjection().fromPixelToLatLng(new GPoint(swpixel.x + x,nepixel.y + y),map.getZoom());
}

function whurUB() {
	var ele = xGetElementById('zoomLayer');
  	gpstart = getLatLonFromPixel(xLeft(ele), xTop(ele));
  	gpend = getLatLonFromPixel(xLeft(ele) + xWidth(ele), xTop(ele) + xHeight(ele));

  	var selectedCoords=gpstart.lat() + ", " + gpstart.lng() + "; " + gpend.lat() + ", " + gpend.lng();
  	document.getElementById('selectedCoords').value=selectedCoords;
  	document.getElementById('nwLat').value=gpstart.lat();
  	document.getElementById('nwlong').value=gpstart.lng();
  	document.getElementById('selat').value=gpend.lat();
  	document.getElementById('selong').value=gpend.lng();
  }

function ubGone() {
	document.getElementById('selectedCoords').value='';
  	document.getElementById('nwLat').value='';
  	document.getElementById('nwlong').value='';
  	document.getElementById('selat').value='';
  	document.getElementById('selong').value='';
}

function setDiv() {
	fen1 = new xFenster('zoomLayer', 0, 0, 'zoomLayer', 'ResBtn', 'ZoomBtn');
	pos = new GControlPosition(G_ANCHOR_TOP_LEFT, new GSize(47,73));
	pos.apply(document.getElementById("zoomLayer"));
	map.getContainer().appendChild(document.getElementById("zoomLayer"));
	document.getElementById("zoomLayer").style.visibility = 'hidden'
}

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
			whurUB();
		}
		else{
			elem.style.display = 'none';
			elem.style.visibility = 'hidden';
			ubGone();
		}
	}
}



					