<cfinclude template="/includes/_header.cfm">



<script>
(function(f){if(typeof exports==="object"&&typeof module!=="undefined"){module.exports=f()}else if(typeof define==="function"&&define.amd){define([],f)}else{var g;if(typeof window!=="undefined"){g=window}else if(typeof global!=="undefined"){g=global}else if(typeof self!=="undefined"){g=self}else{g=this}g.wellknown = f()}})(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
/*eslint-disable no-cond-assign */
module.exports = parse;
module.exports.parse = parse;
module.exports.stringify = stringify;

var numberRegexp = /[-+]?([0-9]*\.[0-9]+|[0-9]+)([eE][-+]?[0-9]+)?/;
// Matches sequences like '100 100' or '100 100 100'.
var tuples = new RegExp('^' + numberRegexp.source + '(\\s' + numberRegexp.source + '){1,}');

/*
 * Parse WKT and return GeoJSON.
 *
 * @param {string} _ A WKT geometry
 * @return {?Object} A GeoJSON geometry object
 */
function parse (input) {
  var parts = input.split(';');
  var _ = parts.pop();
  var srid = (parts.shift() || '').split('=').pop();

  var i = 0;

  function $ (re) {
    var match = _.substring(i).match(re);
    if (!match) return null;
    else {
      i += match[0].length;
      return match[0];
    }
  }

  function crs (obj) {
    if (obj && srid.match(/\d+/)) {
      obj.crs = {
        type: 'name',
        properties: {
          name: 'urn:ogc:def:crs:EPSG::' + srid
        }
      };
    }

    return obj;
  }

  function white () { $(/^\s*/); }

  function multicoords () {
    white();
    var depth = 0;
    var rings = [];
    var stack = [rings];
    var pointer = rings;
    var elem;

    while (elem =
           $(/^(\()/) ||
             $(/^(\))/) ||
               $(/^(,)/) ||
                 $(tuples)) {
      if (elem === '(') {
        stack.push(pointer);
        pointer = [];
        stack[stack.length - 1].push(pointer);
        depth++;
      } else if (elem === ')') {
        // For the case: Polygon(), ...
        if (pointer.length === 0) return null;

        pointer = stack.pop();
        // the stack was empty, input was malformed
        if (!pointer) return null;
        depth--;
        if (depth === 0) break;
      } else if (elem === ',') {
        pointer = [];
        stack[stack.length - 1].push(pointer);
      } else if (!elem.split(/\s/g).some(isNaN)) {
        Array.prototype.push.apply(pointer, elem.split(/\s/g).map(parseFloat));
      } else {
        return null;
      }
      white();
    }

    if (depth !== 0) return null;

    return rings;
  }

  function coords () {
    var list = [];
    var item;
    var pt;
    while (pt =
           $(tuples) ||
             $(/^(,)/)) {
      if (pt === ',') {
        list.push(item);
        item = [];
      } else if (!pt.split(/\s/g).some(isNaN)) {
        if (!item) item = [];
        Array.prototype.push.apply(item, pt.split(/\s/g).map(parseFloat));
      }
      white();
    }

    if (item) list.push(item);
    else return null;

    return list.length ? list : null;
  }

  function point () {
    if (!$(/^(point(\sz)?)/i)) return null;
    white();
    if (!$(/^(\()/)) return null;
    var c = coords();
    if (!c) return null;
    white();
    if (!$(/^(\))/)) return null;
    return {
      type: 'Point',
      coordinates: c[0]
    };
  }

  function multipoint () {
    if (!$(/^(multipoint)/i)) return null;
    white();
    var newCoordsFormat = _
      .substring(_.indexOf('(') + 1, _.length - 1)
      .replace(/\(/g, '')
      .replace(/\)/g, '');
    _ = 'MULTIPOINT (' + newCoordsFormat + ')';
    var c = multicoords();
    if (!c) return null;
    white();
    return {
      type: 'MultiPoint',
      coordinates: c
    };
  }

  function multilinestring () {
    if (!$(/^(multilinestring)/i)) return null;
    white();
    var c = multicoords();
    if (!c) return null;
    white();
    return {
      type: 'MultiLineString',
      coordinates: c
    };
  }

  function linestring () {
    if (!$(/^(linestring(\sz)?)/i)) return null;
    white();
    if (!$(/^(\()/)) return null;
    var c = coords();
    if (!c) return null;
    if (!$(/^(\))/)) return null;
    return {
      type: 'LineString',
      coordinates: c
    };
  }

  function polygon () {
    if (!$(/^(polygon(\sz)?)/i)) return null;
    white();
    var c = multicoords();
    if (!c) return null;
    return {
      type: 'Polygon',
      coordinates: c
    };
  }

  function multipolygon () {
    if (!$(/^(multipolygon)/i)) return null;
    white();
    var c = multicoords();
    if (!c) return null;
    return {
      type: 'MultiPolygon',
      coordinates: c
    };
  }

  function geometrycollection () {
    var geometries = [];
    var geometry;

    if (!$(/^(geometrycollection)/i)) return null;
    white();

    if (!$(/^(\()/)) return null;
    while (geometry = root()) {
      geometries.push(geometry);
      white();
      $(/^(,)/);
      white();
    }
    if (!$(/^(\))/)) return null;

    return {
      type: 'GeometryCollection',
      geometries: geometries
    };
  }

  function root () {
    return point() ||
      linestring() ||
      polygon() ||
      multipoint() ||
      multilinestring() ||
      multipolygon() ||
      geometrycollection();
  }

  return crs(root());
}

/**
 * Stringifies a GeoJSON object into WKT
 */
function stringify (gj) {
  if (gj.type === 'Feature') {
    gj = gj.geometry;
  }

  function pairWKT (c) {
    return c.join(' ');
  }

  function ringWKT (r) {
    return r.map(pairWKT).join(', ');
  }

  function ringsWKT (r) {
    return r.map(ringWKT).map(wrapParens).join(', ');
  }

  function multiRingsWKT (r) {
    return r.map(ringsWKT).map(wrapParens).join(', ');
  }

  function wrapParens (s) { return '(' + s + ')'; }

  switch (gj.type) {
    case 'Point':
      return 'POINT (' + pairWKT(gj.coordinates) + ')';
    case 'LineString':
      return 'LINESTRING (' + ringWKT(gj.coordinates) + ')';
    case 'Polygon':
      return 'POLYGON (' + ringsWKT(gj.coordinates) + ')';
    case 'MultiPoint':
      return 'MULTIPOINT (' + ringWKT(gj.coordinates) + ')';
    case 'MultiPolygon':
      return 'MULTIPOLYGON (' + multiRingsWKT(gj.coordinates) + ')';
    case 'MultiLineString':
      return 'MULTILINESTRING (' + ringsWKT(gj.coordinates) + ')';
    case 'GeometryCollection':
      return 'GEOMETRYCOLLECTION (' + gj.geometries.map(stringify).join(', ') + ')';
    default:
      throw new Error('stringify requires a valid GeoJSON Feature or geometry object as input');
  }
}

},{}]},{},[1])(1)
});
</script>

<script>
	jQuery(document).ready(function() {
		var wkt='POLYGON((-95.4319 31.91362,-95.43541 31.89528,-95.43856 31.87634,-95.44455 31.85071,-95.41975 31.83575,-95.40171 31.81688,-95.39763 31.79429,-95.39802 31.77313,-95.3888 31.7582,-95.36066 31.74526,-95.36859 31.72938,-95.33313 31.73164,-95.33486 31.71553,-95.31212 31.70175,-95.28325 31.67641,-95.2781 31.65465,-95.28746 31.63306,-95.26179 31.61811,-95.2732 31.59289,-95.27328 31.59288,-95.30593 31.58872,-95.33038 31.58561,-95.33843 31.58458,-95.35709 31.58227,-95.37652 31.5794,-95.39634 31.57698,-95.41775 31.57436,-95.45108 31.57029,-95.4544 31.56988,-95.46645 31.56839,-95.49881 31.56379,-95.51949 31.5607,-95.53856 31.55792,-95.55663 31.55528,-95.58018 31.55202,-95.60508 31.54868,-95.62366 31.5459,-95.63184 31.54469,-95.65176 31.54179,-95.64739 31.52772,-95.6572 31.52454,-95.67987 31.51888,-95.70305 31.51312,-95.70999 31.51138,-95.73894 31.50414,-95.73928 31.50406,-95.7392 31.50412,-95.73592 31.51511,-95.74647 31.52386,-95.75703 31.5314,-95.75136 31.54276,-95.74724 31.55299,-95.73165 31.5511,-95.71913 31.55397,-95.71736 31.562,-95.71915 31.57085,-95.72708 31.58169,-95.72236 31.58593,-95.7166 31.59361,-95.71117 31.60455,-95.71232 31.61953,-95.71746 31.63005,-95.72529 31.6408,-95.73672 31.65409,-95.75107 31.64959,-95.75498 31.64068,-95.75097 31.62474,-95.75347 31.61304,-95.76052 31.60417,-95.76723 31.59758,-95.78322 31.60849,-95.78726 31.61826,-95.7873 31.61838,-95.78739 31.61867,-95.79347 31.65879,-95.78971 31.69128,-95.82511 31.68759,-95.87354 31.69342,-95.86968 31.71965,-95.88102 31.73514,-95.87472 31.75467,-95.90267 31.76102,-95.92127 31.76701,-95.9532 31.77975,-95.98357 31.78925,-95.97791 31.83004,-95.98706 31.85953,-95.97002 31.87702,-95.98899 31.8692,-96.00424 31.87644,-96.02746 31.88151,-96.01415 31.90832,-96.00426 31.91905,-96.02088 31.9389,-96.0304 31.95431,-96.05615 31.95162,-96.04291 31.96297,-96.0625 31.9784,-96.05266 32.00452,-96.05279 32.00589,-96.05268 32.0059,-96.03556 32.00798,-95.98857 32.01349,-95.94355 32.01902,-95.90943 32.02307,-95.87524 32.02712,-95.84707 32.03048,-95.81191 32.03469,-95.78744 32.03753,-95.77023 32.03973,-95.75044 32.04231,-95.7446 32.04305,-95.74032 32.04347,-95.73641 32.044,-95.72823 32.04533,-95.72209 32.04588,-95.71557 32.04667,-95.70793 32.04781,-95.6715 32.05233,-95.63656 32.05689,-95.59884 32.06176,-95.57158 32.06532,-95.53667 32.06986,-95.49558 32.07484,-95.45689 32.0804,-95.42871 32.08445,-95.42851 32.08447,-95.42937 32.07601,-95.423 32.04804,-95.43499 32.03082,-95.42843 32.01005,-95.44603 31.99777,-95.44613 31.96817,-95.43224 31.93385,-95.43187 31.91375))';
		console.log('hello');
		console.log('wkt:' + wkt);

	});


</script>



<cfabort>



<cfset mb_token="pk.eyJ1IjoiYXJjdG9zIiwiYSI6ImNqdndnM2NrYjAwYXM0OHJnMDUyZnVvY3UifQ._Jg9O0eUm_HwS4o_Zb9Zeg">

 <link rel="stylesheet" href="https://unpkg.com/leaflet@1.5.1/dist/leaflet.css"
   integrity="sha512-xwE/Az9zrjBIphAcBb3F6JVqxf46+CDLwfLMHloNu6KEQCAWi6HcDUbeOfBIptF7tcCzusKFjFw2yuvEpDL9wQ=="
   crossorigin=""/>
 <!-- Make sure you put this AFTER Leaflet's CSS -->
 <script src="https://unpkg.com/leaflet@1.5.1/dist/leaflet.js"
   integrity="sha512-GffPMF3RvMeYyc1LWMHtK8EbPv0iNZ8/oTtHPx9/cc2ILxQ+u905qIwdpULaqDkyBKgOaB57QTMg7ztg8Jm2Og=="
   crossorigin=""></script>


<script src='https://cdnjs.cloudflare.com/ajax/libs/wicket/1.3.2/wicket.js'></script>
<script src='https://cdnjs.cloudflare.com/ajax/libs/wicket/1.3.2/wicket-leaflet.js'></script>


<style>
#map { height: 600px; }
</style>


<script>
var geojsonFeature = {"type":"Polygon","coordinates":[[[-95.4319,31.91362],[-95.43541,31.89528],[-95.43856,31.87634],[-95.44455,31.85071],[-95.41975,31.83575],[-95.40171,31.81688],[-95.39763,31.79429],[-95.39802,31.77313],[-95.3888,31.7582],[-95.36066,31.74526],[-95.36859,31.72938],[-95.33313,31.73164],[-95.33486,31.71553],[-95.31212,31.70175],[-95.28325,31.67641],[-95.2781,31.65465],[-95.28746,31.63306],[-95.26179,31.61811],[-95.2732,31.59289],[-95.27328,31.59288],[-95.30593,31.58872],[-95.33038,31.58561],[-95.33843,31.58458],[-95.35709,31.58227],[-95.37652,31.5794],[-95.39634,31.57698],[-95.41775,31.57436],[-95.45108,31.57029],[-95.4544,31.56988],[-95.46645,31.56839],[-95.49881,31.56379],[-95.51949,31.5607],[-95.53856,31.55792],[-95.55663,31.55528],[-95.58018,31.55202],[-95.60508,31.54868],[-95.62366,31.5459],[-95.63184,31.54469],[-95.65176,31.54179],[-95.64739,31.52772],[-95.6572,31.52454],[-95.67987,31.51888],[-95.70305,31.51312],[-95.70999,31.51138],[-95.73894,31.50414],[-95.73928,31.50406],[-95.7392,31.50412],[-95.73592,31.51511],[-95.74647,31.52386],[-95.75703,31.5314],[-95.75136,31.54276],[-95.74724,31.55299],[-95.73165,31.5511],[-95.71913,31.55397],[-95.71736,31.562],[-95.71915,31.57085],[-95.72708,31.58169],[-95.72236,31.58593],[-95.7166,31.59361],[-95.71117,31.60455],[-95.71232,31.61953],[-95.71746,31.63005],[-95.72529,31.6408],[-95.73672,31.65409],[-95.75107,31.64959],[-95.75498,31.64068],[-95.75097,31.62474],[-95.75347,31.61304],[-95.76052,31.60417],[-95.76723,31.59758],[-95.78322,31.60849],[-95.78726,31.61826],[-95.7873,31.61838],[-95.78739,31.61867],[-95.79347,31.65879],[-95.78971,31.69128],[-95.82511,31.68759],[-95.87354,31.69342],[-95.86968,31.71965],[-95.88102,31.73514],[-95.87472,31.75467],[-95.90267,31.76102],[-95.92127,31.76701],[-95.9532,31.77975],[-95.98357,31.78925],[-95.97791,31.83004],[-95.98706,31.85953],[-95.97002,31.87702],[-95.98899,31.8692],[-96.00424,31.87644],[-96.02746,31.88151],[-96.01415,31.90832],[-96.00426,31.91905],[-96.02088,31.9389],[-96.0304,31.95431],[-96.05615,31.95162],[-96.04291,31.96297],[-96.0625,31.9784],[-96.05266,32.00452],[-96.05279,32.00589],[-96.05268,32.0059],[-96.03556,32.00798],[-95.98857,32.01349],[-95.94355,32.01902],[-95.90943,32.02307],[-95.87524,32.02712],[-95.84707,32.03048],[-95.81191,32.03469],[-95.78744,32.03753],[-95.77023,32.03973],[-95.75044,32.04231],[-95.7446,32.04305],[-95.74032,32.04347],[-95.73641,32.044],[-95.72823,32.04533],[-95.72209,32.04588],[-95.71557,32.04667],[-95.70793,32.04781],[-95.6715,32.05233],[-95.63656,32.05689],[-95.59884,32.06176],[-95.57158,32.06532],[-95.53667,32.06986],[-95.49558,32.07484],[-95.45689,32.0804],[-95.42871,32.08445],[-95.42851,32.08447],[-95.42937,32.07601],[-95.423,32.04804],[-95.43499,32.03082],[-95.42843,32.01005],[-95.44603,31.99777],[-95.44613,31.96817],[-95.43224,31.93385],[-95.43187,31.91375]]]};

	jQuery(document).ready(function() {
		var map = L.map('map').setView([32.04588,-95.72209], 6);

L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
}).addTo(map);

L.marker([32.04588,-95.72209]).addTo(map)
    .bindPopup('A pretty CSS3 popup.<br> Easily customizable.')
    .openPopup();

L.geoJSON(geojsonFeature).addTo(map);



		});
</script>

 <div id="map"></div>

