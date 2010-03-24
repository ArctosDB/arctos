/* x_core.js compiled from X 4.0 with XC 0.27b. Distributed by GNU LGPL. For copyrights, license, documentation and more visit Cross-Browser.com */
var xOp7Up,xOp6Dn,xIE4Up,xIE4,xIE5,xNN4,xUA=navigator.userAgent.toLowerCase();if(window.opera){var i=xUA.indexOf('opera');if(i!=-1){var v=parseInt(xUA.charAt(i+6));xOp7Up=v>=7;xOp6Dn=v<7;}}else if(navigator.vendor!='KDE' && document.all && xUA.indexOf('msie')!=-1){xIE4Up=parseFloat(navigator.appVersion)>=4;xIE4=xUA.indexOf('msie 4')!=-1;xIE5=xUA.indexOf('msie 5')!=-1;}else if(document.layers){xNN4=true;}xMac=xUA.indexOf('mac')!=-1;function xBackground(e,c,i){if(!(e=xGetElementById(e))) return '';var bg='';if(e.style) {if(xStr(c)) {if(!xOp6Dn) e.style.backgroundColor=c;else e.style.background=c;}if(xStr(i)) e.style.backgroundImage=(i!='')? 'url('+i+')' : null;if(!xOp6Dn) bg=e.style.backgroundColor;else bg=e.style.background;}return bg;}function xClientHeight(){var h=0;if(xOp6Dn) h=window.innerHeight;else if(document.compatMode == 'CSS1Compat' && !window.opera && document.documentElement && document.documentElement.clientHeight)h=document.documentElement.clientHeight;else if(document.body && document.body.clientHeight)h=document.body.clientHeight;else if(xDef(window.innerWidth,window.innerHeight,document.width)) {h=window.innerHeight;if(document.width>window.innerWidth) h-=16;}return h;}function xClientWidth(){var w=0;if(xOp6Dn) w=window.innerWidth;else if(document.compatMode == 'CSS1Compat' && !window.opera && document.documentElement && document.documentElement.clientWidth)w=document.documentElement.clientWidth;else if(document.body && document.body.clientWidth)w=document.body.clientWidth;else if(xDef(window.innerWidth,window.innerHeight,document.height)) {w=window.innerWidth;if(document.height>window.innerHeight) w-=16;}return w;}function xClip(e,t,r,b,l){if(!(e=xGetElementById(e))) return;if(e.style) {if (xNum(l)) e.style.clip='rect('+t+'px '+r+'px '+b+'px '+l+'px)';else e.style.clip='rect(0 '+parseInt(e.style.width)+'px '+parseInt(e.style.height)+'px 0)';}}function xColor(e,s){if(!(e=xGetElementById(e))) return '';var c='';if(e.style && xDef(e.style.color)) {if(xStr(s)) e.style.color=s;c=e.style.color;}return c;}function xDef(){for(var i=0; i<arguments.length; ++i){if(typeof(arguments[i])=='undefined') return false;}return true;}function xDisplay(e,s){if(!(e=xGetElementById(e))) return null;if(e.style && xDef(e.style.display)) {if (xStr(s)) e.style.display = s;return e.style.display;}return null;}function xGetComputedStyle(oEle, sProp, bInt){var s, p = 'undefined';var dv = document.defaultView;if(dv && dv.getComputedStyle){s = dv.getComputedStyle(oEle,'');if (s) p = s.getPropertyValue(sProp);}else if(oEle.currentStyle) {var a = sProp.split('-');sProp = a[0];for (var i=1; i<a.length; ++i) {c = a[i].charAt(0);sProp += a[i].replace(c, c.toUpperCase());}   p = oEle.currentStyle[sProp];}else return null;return bInt ? (parseInt(p) || 0) : p;}function xGetElementById(e){if(typeof(e)!='string') return e;if(document.getElementById) e=document.getElementById(e);else if(document.all) e=document.all[e];else e=null;return e;}function xHasPoint(e,x,y,t,r,b,l){if (!xNum(t)){t=r=b=l=0;}else if (!xNum(r)){r=b=l=t;}else if (!xNum(b)){l=r; b=t;}var eX = xPageX(e), eY = xPageY(e);return (x >= eX + l && x <= eX + xWidth(e) - r &&y >= eY + t && y <= eY + xHeight(e) - b );}function xHeight(e,h){if(!(e=xGetElementById(e))) return 0;if (xNum(h)) {if (h<0) h = 0;else h=Math.round(h);}else h=-1;var css=xDef(e.style);if (e == document || e.tagName.toLowerCase() == 'html' || e.tagName.toLowerCase() == 'body') {h = xClientHeight();}else if(css && xDef(e.offsetHeight) && xStr(e.style.height)) {if(h>=0) {var pt=0,pb=0,bt=0,bb=0;if (document.compatMode=='CSS1Compat') {var gcs = xGetComputedStyle;pt=gcs(e,'padding-top',1);if (pt !== null) {pb=gcs(e,'padding-bottom',1);bt=gcs(e,'border-top-width',1);bb=gcs(e,'border-bottom-width',1);}else if(xDef(e.offsetHeight,e.style.height)){e.style.height=h+'px';pt=e.offsetHeight-h;}}h-=(pt+pb+bt+bb);if(isNaN(h)||h<0) return;else e.style.height=h+'px';}h=e.offsetHeight;}else if(css && xDef(e.style.pixelHeight)) {if(h>=0) e.style.pixelHeight=h;h=e.style.pixelHeight;}return h;}function xHide(e){return xVisibility(e,0);}function xLeft(e, iX){if(!(e=xGetElementById(e))) return 0;var css=xDef(e.style);if (css && xStr(e.style.left)) {if(xNum(iX)) e.style.left=iX+'px';else {iX=parseInt(e.style.left);if(isNaN(iX)) iX=0;}}else if(css && xDef(e.style.pixelLeft)) {if(xNum(iX)) e.style.pixelLeft=iX;else iX=e.style.pixelLeft;}return iX;}function xMoveTo(e,x,y){xLeft(e,x);xTop(e,y);}function xNum(){for(var i=0; i<arguments.length; ++i){if(isNaN(arguments[i]) || typeof(arguments[i])!='number') return false;}return true;}function xOffsetLeft(e){if (!(e=xGetElementById(e))) return 0;if (xDef(e.offsetLeft)) return e.offsetLeft;else return 0;}function xOffsetTop(e){if (!(e=xGetElementById(e))) return 0;if (xDef(e.offsetTop)) return e.offsetTop;else return 0;}function xPageX(e){if (!(e=xGetElementById(e))) return 0;var x = 0;while (e) {if (xDef(e.offsetLeft)) x += e.offsetLeft;e = xDef(e.offsetParent) ? e.offsetParent : null;}return x;}function xPageY(e){if (!(e=xGetElementById(e))) return 0;var y = 0;while (e) {if (xDef(e.offsetTop)) y += e.offsetTop;e = xDef(e.offsetParent) ? e.offsetParent : null;}return y;}function xParent(e, bNode){if (!(e=xGetElementById(e))) return null;var p=null;if (!bNode && xDef(e.offsetParent)) p=e.offsetParent;else if (xDef(e.parentNode)) p=e.parentNode;else if (xDef(e.parentElement)) p=e.parentElement;return p;}function xResizeTo(e,w,h){xWidth(e,w);xHeight(e,h);}function xScrollLeft(e, bWin){var offset=0;if (!xDef(e) || bWin || e == document || e.tagName.toLowerCase() == 'html' || e.tagName.toLowerCase() == 'body') {var w = window;if (bWin && e) w = e;if(w.document.documentElement && w.document.documentElement.scrollLeft) offset=w.document.documentElement.scrollLeft;else if(w.document.body && xDef(w.document.body.scrollLeft)) offset=w.document.body.scrollLeft;}else {e = xGetElementById(e);if (e && xNum(e.scrollLeft)) offset = e.scrollLeft;}return offset;}function xScrollTop(e, bWin){var offset=0;if (!xDef(e) || bWin || e == document || e.tagName.toLowerCase() == 'html' || e.tagName.toLowerCase() == 'body') {var w = window;if (bWin && e) w = e;if(w.document.documentElement && w.document.documentElement.scrollTop) offset=w.document.documentElement.scrollTop;else if(w.document.body && xDef(w.document.body.scrollTop)) offset=w.document.body.scrollTop;}else {e = xGetElementById(e);if (e && xNum(e.scrollTop)) offset = e.scrollTop;}return offset;}function xShow(e) {return xVisibility(e,1);}function xStr(s){for(var i=0; i<arguments.length; ++i){if(typeof(arguments[i])!='string') return false;}return true;}function xTop(e, iY){if(!(e=xGetElementById(e))) return 0;var css=xDef(e.style);if(css && xStr(e.style.top)) {if(xNum(iY)) e.style.top=iY+'px';else {iY=parseInt(e.style.top);if(isNaN(iY)) iY=0;}}else if(css && xDef(e.style.pixelTop)) {if(xNum(iY)) e.style.pixelTop=iY;else iY=e.style.pixelTop;}return iY;}function xVisibility(e, bShow){if(!(e=xGetElementById(e))) return null;if(e.style && xDef(e.style.visibility)) {if (xDef(bShow)) e.style.visibility = bShow ? 'visible' : 'hidden';return e.style.visibility;}return null;}function xWidth(e,w){if(!(e=xGetElementById(e))) return 0;if (xNum(w)) {if (w<0) w = 0;else w=Math.round(w);}else w=-1;var css=xDef(e.style);if (e == document || e.tagName.toLowerCase() == 'html' || e.tagName.toLowerCase() == 'body') {w = xClientWidth();}else if(css && xDef(e.offsetWidth) && xStr(e.style.width)) {if(w>=0) {var pl=0,pr=0,bl=0,br=0;if (document.compatMode=='CSS1Compat') {var gcs = xGetComputedStyle;pl=gcs(e,'padding-left',1);if (pl !== null) {pr=gcs(e,'padding-right',1);bl=gcs(e,'border-left-width',1);br=gcs(e,'border-right-width',1);}else if(xDef(e.offsetWidth,e.style.width)){e.style.width=w+'px';pl=e.offsetWidth-w;}}w-=(pl+pr+bl+br);if(isNaN(w)||w<0) return;else e.style.width=w+'px';}w=e.offsetWidth;}else if(css && xDef(e.style.pixelWidth)) {if(w>=0) e.style.pixelWidth=w;w=e.style.pixelWidth;}return w;}function xZIndex(e,uZ){if(!(e=xGetElementById(e))) return 0;if(e.style && xDef(e.style.zIndex)) {if(xNum(uZ)) e.style.zIndex=uZ;uZ=parseInt(e.style.zIndex);}return uZ;}

/* x_event.js compiled from X 4.0 with XC 0.27b. Distributed by GNU LGPL. For copyrights, license, documentation and more visit Cross-Browser.com */
function xAddEventListener(e,eT,eL,cap){if(!(e=xGetElementById(e))) return;eT=eT.toLowerCase();if((!xIE4Up && !xOp7Up) && e==window) {if(eT=='resize') { window.xPCW=xClientWidth(); window.xPCH=xClientHeight(); window.xREL=eL; xResizeEvent(); return; }if(eT=='scroll') { window.xPSL=xScrollLeft(); window.xPST=xScrollTop(); window.xSEL=eL; xScrollEvent(); return; }}var eh='e.on'+eT+'=eL';if(e.addEventListener) e.addEventListener(eT,eL,cap);else if(e.attachEvent) e.attachEvent('on'+eT,eL);else eval(eh);}function xResizeEvent(){if (window.xREL) setTimeout('xResizeEvent()', 250);var cw = xClientWidth(), ch = xClientHeight();if (window.xPCW != cw || window.xPCH != ch) { window.xPCW = cw; window.xPCH = ch; if (window.xREL) window.xREL(); }}function xScrollEvent(){if (window.xSEL) setTimeout('xScrollEvent()', 250);var sl = xScrollLeft(), st = xScrollTop();if (window.xPSL != sl || window.xPST != st) { window.xPSL = sl; window.xPST = st; if (window.xSEL) window.xSEL(); }}function xEvent(evt) {var e = evt || window.event;if(!e) return;if(e.type) this.type = e.type;if(e.target) this.target = e.target;else if(e.srcElement) this.target = e.srcElement;if (e.relatedTarget) this.relatedTarget = e.relatedTarget;else if (e.type == 'mouseover' && e.fromElement) this.relatedTarget = e.fromElement;else if (e.type == 'mouseout') this.relatedTarget = e.toElement;if(xOp6Dn) { this.pageX = e.clientX; this.pageY = e.clientY; }else if(xDef(e.pageX,e.pageY)) { this.pageX = e.pageX; this.pageY = e.pageY; }else if(xDef(e.clientX,e.clientY)) { this.pageX = e.clientX + xScrollLeft(); this.pageY = e.clientY + xScrollTop(); }if (xDef(e.offsetX,e.offsetY)) {this.offsetX = e.offsetX;this.offsetY = e.offsetY;}else if (xDef(e.layerX,e.layerY)) {this.offsetX = e.layerX;this.offsetY = e.layerY;}else {this.offsetX = this.pageX - xPageX(this.target);this.offsetY = this.pageY - xPageY(this.target);}if (e.keyCode) { this.keyCode = e.keyCode; } else if (xDef(e.which) && e.type.indexOf('key')!=-1) { this.keyCode = e.which; }this.shiftKey = e.shiftKey;this.ctrlKey = e.ctrlKey;this.altKey = e.altKey;}function xPreventDefault(e){if (e && e.preventDefault) e.preventDefault();else if (window.event) window.event.returnValue = false;}function xRemoveEventListener(e,eT,eL,cap){if(!(e=xGetElementById(e))) return;eT=eT.toLowerCase();if((!xIE4Up && !xOp7Up) && e==window) {if(eT=='resize') { window.xREL=null; return; }if(eT=='scroll') { window.xSEL=null; return; }}var eh='e.on'+eT+'=null';if(e.removeEventListener) e.removeEventListener(eT,eL,cap);else if(e.detachEvent) e.detachEvent('on'+eT,eL);else eval(eh);}function xStopPropagation(evt){if (evt && evt.stopPropagation) evt.stopPropagation();else if (window.event) window.event.cancelBubble = true;}

/* x_drag.js compiled from X 4.0 with XC 0.27b. Distributed by GNU LGPL. For copyrights, license, documentation and more visit Cross-Browser.com */
function xDisableDrag(id, last){if (!window._xDrgMgr) return;var ele = xGetElementById(id);ele.xDraggable = false;ele.xODS = null;ele.xOD = null;ele.xODE = null;xRemoveEventListener(ele, 'mousedown', _xOMD, false);if (_xDrgMgr.mm && last) {_xDrgMgr.mm = false;xRemoveEventListener(document, 'mousemove', _xOMM, false);}}var _xDrgMgr = {ele:null, mm:false};function xEnableDrag(id,fS,fD,fE){var ele = xGetElementById(id);ele.xDraggable = true;ele.xODS = fS;ele.xOD = fD;ele.xODE = fE;xAddEventListener(ele, 'mousedown', _xOMD, false);if (!_xDrgMgr.mm) {_xDrgMgr.mm = true;xAddEventListener(document, 'mousemove', _xOMM, false);}}function _xOMD(e) {var evt = new xEvent(e);var ele = evt.target;while(ele && !ele.xDraggable) {ele = xParent(ele);}if (ele) {xPreventDefault(e);ele.xDPX = evt.pageX;ele.xDPY = evt.pageY;_xDrgMgr.ele = ele;xAddEventListener(document, 'mouseup', _xOMU, false);if (ele.xODS) {ele.xODS(ele, evt.pageX, evt.pageY);}}}function _xOMM(e) {var evt = new xEvent(e);if (_xDrgMgr.ele) {xPreventDefault(e);var ele = _xDrgMgr.ele;var dx = evt.pageX - ele.xDPX;var dy = evt.pageY - ele.xDPY;ele.xDPX = evt.pageX;ele.xDPY = evt.pageY;if (ele.xOD) {ele.xOD(ele, dx, dy);}else {xMoveTo(ele, xLeft(ele) + dx, xTop(ele) + dy);}}  }function _xOMU(e) {if (_xDrgMgr.ele) {xPreventDefault(e);xRemoveEventListener(document, 'mouseup', _xOMU, false);if (_xDrgMgr.ele.xODE) {var evt = new xEvent(e);_xDrgMgr.ele.xODE(_xDrgMgr.ele, evt.pageX, evt.pageY);}_xDrgMgr.ele = null;}  }


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
	img.src = "/images/selector.png";
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



					