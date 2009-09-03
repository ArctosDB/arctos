<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
    <title>Local Search Control for Google Maps - default.html</title>
    <!--
    * Load the Maps API
    * AJAX Search API
    * Local Search Control
    *
    * Note: IF you copy this sample, make sure you make the following
    * changes:
    * a) replace &key=internal with &key=YOUR-KEY
    * b) Path Prefix to gmlocalsearch.* should be
    *    http://www.google.com/uds/solutions/localsearch/
    * c) Path prefix to ../../api?file=uds.js and to ../../css/gsearch.css
    *    should be http://www.google.com/uds
    -->
    <script src="http://maps.google.com/maps?file=api&v=2&key=internal" type="text/javascript"></script>
    <script src="../../api?file=uds.js&v=1.0&key=internal" type="text/javascript"></script>

    <script src="gmlocalsearch.js" type="text/javascript"></script>
    <style type="text/css">
      @import url("../../css/gsearch.css");
      @import url("gmlocalsearch.css");

      #map {
        border : 1px solid #979797;
        width : 100%;
        height : 575px;
      }
    </style>

    <script type="text/javascript">

      //<![CDATA[
      function load() {
        if (GBrowserIsCompatible()) {

          // Create and Center a Map
          var map = new GMap2(document.getElementById("map"));
          map.setCenter(new GLatLng(48.8565, 2.3509), 13);
          map.addControl(new GLargeMapControl());
          map.addControl(new GMapTypeControl());

          /* Metal Mode */
          // set up pins, use the metalset
          var pins = new Array();
          pins["kml"] = "metalblue";
          pins["local"] = "metalred";

          var labels = new Array();
          labels["kml"] = "metalblue";
          labels["local"] = "metalred";

          // then in options pass:
          // pins : pins, labels : labels
          /**/
          var options = {
            listingTypes : GlocalSearch.TYPE_BLENDED_RESULTS,
            Xpins : pins,
            Xlabels : labels
          }
          map.addControl(new google.maps.LocalSearch(options));
        }
      }
      GSearch.setOnLoadCallback(load);
      //]]>
    </script>
  </head>
  <body onunload="GUnload()">
    <div id="map"></div>
  </body>

</html>
