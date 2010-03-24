/* Built from X 4.21 by XAG 1.0. 12Feb10 01:14 UT */
xLibrary = {
   version : "4.21", license : "GNU LGPL", url : "http://cross-browser.com/"};
function xCamelize(d) {
   var e, g, b, f;
   b = d.split("-");
   f = b[0];
   for(e = 1; e < b.length; ++e) {
      g = b[e].charAt(0);
      f += b[e].replace(g, g.toUpperCase());
   }
   return f;
}
function xClientHeight() {
   var b = 0, c = document, a = window;
   if((!c.compatMode || c.compatMode == "CSS1Compat") && c.documentElement && c.documentElement.clientHeight) {
      b = c.documentElement.clientHeight;
   }
   else {
      if(c.body && c.body.clientHeight) {
         b = c.body.clientHeight;
      }
      else {
         if(xDef(a.innerWidth, a.innerHeight, c.width)) {
            b = a.innerHeight;
            if(c.width > a.innerWidth) {
               b -= 16;
            }
         }
      }
   }
   return b;
}
function xClientWidth() {
   var b = 0, c = document, a = window;
   if((!c.compatMode || c.compatMode == "CSS1Compat") &&!a.opera && c.documentElement && c.documentElement.clientWidth) {
      b = c.documentElement.clientWidth;}
   else {
      if(c.body && c.body.clientWidth) {
         b = c.body.clientWidth;}
      else {
         if(xDef(a.innerWidth, a.innerHeight, c.height)) {
            b = a.innerWidth;
            if(c.height > a.innerHeight) {
               b -= 16;}
            }
         }
      }
   return b;}
function xDef() {
   for(var a = 0; a < arguments.length; ++a) {
      if(typeof(arguments[a]) == "undefined") {
         return false;}
      }
   return true;}
function xGetComputedStyle(g, f, c) {
   if(!(g = xGetElementById(g))) {
      return null;}
   var d, a = "undefined", b = document.defaultView;
   if(b && b.getComputedStyle) {
      d = b.getComputedStyle(g, "");
      if(d) {
         a = d.getPropertyValue(f);}
      }
   else {
      if(g.currentStyle) {
         a = g.currentStyle[xCamelize(f)];}
      else {
         return null;}
      }
   return c ? (parseInt(a) || 0) : a;}
function xGetElementById(a) {
   if(typeof(a) == "string") {
      if(document.getElementById) {
         a = document.getElementById(a);}
      else {
         if(document.all) {
            a = document.all[a];}
         else {
            a = null;}
         }
      }
   return a;}
function xGetElementsByClassName(l, k, b, h) {
   var g = [], d, j, a;
   d = new RegExp("(^|\\s)" + l + "(\\s|$)");
   j = xGetElementsByTagName(b, k);
   for(a = 0; a < j.length; ++a) {
      if(d.test(j[a].className)) {
         g[g.length] = j[a];
         if(h) {
            h(j[a]);}
         }
      }
   return g;}
function xGetElementsByTagName(a, c) {
   var b = null;
   a = a || "*";
   c = xGetElementById(c) || document;
   if(typeof c.getElementsByTagName != "undefined") {
      b = c.getElementsByTagName(a);
      if(a == "*" && (!b ||!b.length)) {
         b = c.all;}
      }
   else {
      if(a == "*") {
         b = c.all;}
      else {
         if(c.all && c.all.tags) {
            b = c.all.tags(a);}
         }
      }
   return b || [];}
function xHasPoint(f, i, g, j, a, h, d) {
   if(!xNum(j)) {
      j = a = h = d = 0;}
   else {
      if(!xNum(a)) {
         a = h = d = j;}
      else {
         if(!xNum(h)) {
            d = a;
            h = j;}
         }
      }
   var c = xPageX(f), k = xPageY(f);
   return(i >= c + d && i <= c + xWidth(f) - a && g >= k + j && g <= k + xHeight(f) - h)}
function xHeight(i, f) {
   var d, g = 0, c = 0, b = 0, j = 0, a;
   if(!(i = xGetElementById(i))) {
      return 0;}
   if(xNum(f)) {
      if(f < 0) {
         f = 0;}
      else {
         f = Math.round(f);}
      }
   else {
      f =- 1}
   d = xDef(i.style);
   if(i == document || i.tagName.toLowerCase() == "html" || i.tagName.toLowerCase() == "body") {
      f = xClientHeight();}
   else {
      if(d && xDef(i.offsetHeight) && xStr(i.style.height)) {
         if(f >= 0) {
            if(document.compatMode == "CSS1Compat") {
               a = xGetComputedStyle;
               g = a(i, "padding-top", 1);
               if(g !== null) {
                  c = a(i, "padding-bottom", 1);
                  b = a(i, "border-top-width", 1);
                  j = a(i, "border-bottom-width", 1);}
               else {
                  if(xDef(i.offsetHeight, i.style.height)) {
                     i.style.height = f + "px";
                     g = i.offsetHeight - f;}
                  }
               }
            f -= (g + c + b + j);
            if(isNaN(f) || f < 0) {
               return}
            else {
               i.style.height = f + "px"}
            }
         f = i.offsetHeight;}
      else {
         if(d && xDef(i.style.pixelHeight)) {
            if(f >= 0) {
               i.style.pixelHeight = f}
            f = i.style.pixelHeight;}
         }
      }
   return f}
function xLeft(c, a) {
   if(!(c = xGetElementById(c))) {
      return 0}
   var b = xDef(c.style);
   if(b && xStr(c.style.left)) {
      if(xNum(a)) {
         c.style.left = a + "px"}
      else {
         a = parseInt(c.style.left);
         if(isNaN(a)) {
            a = xGetComputedStyle(c, "left", 1);}
         if(isNaN(a)) {
            a = 0;}
         }
      }
   else {
      if(b && xDef(c.style.pixelLeft)) {
         if(xNum(a)) {
            c.style.pixelLeft = a;}
         else {
            a = c.style.pixelLeft;}
         }
      }
   return a;}
function xMoveTo(b, a, c) {
   xLeft(b, a);
   xTop(b, c);}
function xNum() {
   for(var a = 0; a < arguments.length; ++a) {
      if(isNaN(arguments[a]) || typeof(arguments[a]) != "number") {
         return false;}
      }
   return true;}
function xOpacity(a, b) {
   var c = xDef(b);
   if(!(a = xGetElementById(a))) {
      return 2;}
   if(xStr(a.style.opacity)) {
      if(c) {
         a.style.opacity = b + "";}
      else {
         b = parseFloat(a.style.opacity);}
      }
   else {
      if(xStr(a.style.filter)) {
         if(c) {
            a.style.filter = "alpha(opacity=" + (100 * b) + ")";}
         else {
            if(a.filters && a.filters.alpha) {
               b = a.filters.alpha.opacity / 100;}
            }
         }
      else {
         if(xStr(a.style.MozOpacity)) {
            if(c) {
               a.style.MozOpacity = b + "";}
            else {
               b = parseFloat(a.style.MozOpacity);}
            }
         else {
            if(xStr(a.style.KhtmlOpacity)) {
               if(c) {
                  a.style.KhtmlOpacity = b + "";}
               else {
                  b = parseFloat(a.style.KhtmlOpacity);}
               }
            }
         }
      }
   return isNaN(b) ? 1 : b;}
function xPageX(b) {
   var a = 0;
   b = xGetElementById(b);
   while(b) {
      if(xDef(b.offsetLeft)) {
         a += b.offsetLeft;}
      b = xDef(b.offsetParent) ? b.offsetParent : null;}
   return a;}
function xPageY(a) {
   var b = 0;
   a = xGetElementById(a);
   while(a) {
      if(xDef(a.offsetTop)) {
         b += a.offsetTop;}
      a = xDef(a.offsetParent) ? a.offsetParent : null;}
   return b;}
function xResizeTo(c, a, b) {
   return {
      w : xWidth(c, a), h : xHeight(c, b);}
   }
function xScrollLeft(c, b) {
   var a, d = 0;
   if(!xDef(c) || b || c == document || c.tagName.toLowerCase() == "html" || c.tagName.toLowerCase() == "body") {
      a = window;
      if(b && c) {
         a = c;}
      if(a.document.documentElement && a.document.documentElement.scrollLeft) {
         d = a.document.documentElement.scrollLeft;}
      else {
         if(a.document.body && xDef(a.document.body.scrollLeft)) {
            d = a.document.body.scrollLeft;}
         }
      }
   else {
      c = xGetElementById(c);
      if(c && xNum(c.scrollLeft)) {
         d = c.scrollLeft;}
      }
   return d;}
function xScrollTop(c, b) {
   var a, d = 0;
   if(!xDef(c) || b || c == document || c.tagName.toLowerCase() == "html" || c.tagName.toLowerCase() == "body") {
      a = window;
      if(b && c) {
         a = c;}
      if(a.document.documentElement && a.document.documentElement.scrollTop) {
         d = a.document.documentElement.scrollTop;}
      else {
         if(a.document.body && xDef(a.document.body.scrollTop)) {
            d = a.document.body.scrollTop;}
         }
      }
   else {
      c = xGetElementById(c);
      if(c && xNum(c.scrollTop)) {
         d = c.scrollTop;}
      }
   return d;}
function xStr(b) {
   for(var a = 0; a < arguments.length; ++a) {
      if(typeof(arguments[a]) != "string") {
         return false;}
      }
   return true;}
function xStyle(c, a) {
   var b, f;
   for(b = 2; b < arguments.length; ++b) {
      f = xGetElementById(arguments[b]);
      if(f.style) {
         try {
            f.style[c] = a;}
         catch(d) {
            f.style[c] = "";}
         }
      }
   }
function xTop(b, c) {
   if(!(b = xGetElementById(b))) {
      return 0;}
   var a = xDef(b.style);
   if(a && xStr(b.style.top)) {
      if(xNum(c)) {
         b.style.top = c + "px";}
      else {
         c = parseInt(b.style.top);
         if(isNaN(c)) {
            c = xGetComputedStyle(b, "top", 1);}
         if(isNaN(c)) {
            c = 0;}
         }
      }
   else {
      if(a && xDef(b.style.pixelTop)) {
         if(xNum(c)) {
            b.style.pixelTop = c;}
         else {
            c = b.style.pixelTop;}
         }
      }
   return c;}
function xWidth(g, b) {
   var d, f = 0, i = 0, h = 0, c = 0, a;
   if(!(g = xGetElementById(g))) {
      return 0;}
   if(xNum(b)) {
      if(b < 0) {
         b = 0;}
      else {
         b = Math.round(b);}
      }
   else {
      b =- 1;}
   d = xDef(g.style);
   if(g == document || g.tagName.toLowerCase() == "html" || g.tagName.toLowerCase() == "body") {
      b = xClientWidth();}
   else {
      if(d && xDef(g.offsetWidth) && xStr(g.style.width)) {
         if(b >= 0) {
            if(document.compatMode == "CSS1Compat") {
               a = xGetComputedStyle;
               f = a(g, "padding-left", 1);
               if(f !== null) {
                  i = a(g, "padding-right", 1);
                  h = a(g, "border-left-width", 1);
                  c = a(g, "border-right-width", 1);}
               else {
                  if(xDef(g.offsetWidth, g.style.width)) {
                     g.style.width = b + "px";
                     f = g.offsetWidth - b;}
                  }
               }
            b -= (f + i + h + c);
            if(isNaN(b) || b < 0) {
               return;}
            else {
               g.style.width = b + "px";}
            }
         b = g.offsetWidth;}
      else {
         if(d && xDef(g.style.pixelWidth)) {
            if(b >= 0) {
               g.style.pixelWidth = b;}
            b = g.style.pixelWidth;}
         }
      }
   return b;};