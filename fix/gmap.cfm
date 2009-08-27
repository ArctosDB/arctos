<cfinclude template="/includes/_header.cfm">

<cfset apiKey="ABQIAAAAO1U4FM_13uDJoVwN--7J3xRt-ckefprmtgR9Zt3ibJoGF3oycxTHoy83TEZbPAjL1PURjC9X2BvFYg"> 

<cfoutput>
<script src="http://maps.google.com/maps?file=api&amp;v=2&amp;sensor=true&amp;key=#apiKey#" type="text/javascript"></script>
<script src="http://gmaps-utility-library.googlecode.com/svn/trunk/dragzoom/release/src/dragzoom_packed.js" type="text/javascript"></script>
</cfoutput>
<div id="map_canvas" style="width: 500px; height: 300px"></div>


<script>
	
	function initialize() {
      if (GBrowserIsCompatible()) {
        var map = new GMap2(document.getElementById("map_canvas"));
        var center = new GLatLng(37.4419, -122.1419);
        map.setCenter(center, 13);
/*
        var marker = new GMarker(center, {draggable: true});

        GEvent.addListener(marker, "dragstart", function() {
          map.closeInfoWindow();
        });

        GEvent.addListener(marker, "dragend", function() {
          marker.openInfoWindowHtml("Just bouncing along...");
        });

        map.addOverlay(marker);
        */
         var boxStyleOpts = {
    opacity:.2,
    border:"2px solid red"
  }

  /* second set of options is for everything else */
  var otherOpts = {
    buttonHTML:"<img src='zoom-button.gif' />",
    buttonZoomingHTML:"<img src='zoom-button-activated.gif' />",
    buttonStartingStyle:{width:'24px',height:'24px'}
  };
        
         var callbacks = {
    buttonclick:function(){console.log("Looks like you activated DragZoom!")},
    dragstart:function(){console.log("Started to Drag . . .")},
    dragging:function(x1,y1,x2,y2){console.log("Dragging, currently x="+x2+",y="+y2)},
    dragend:function(nw,ne,se,sw,nwpx,nepx,sepx,swpx){console.log("Zoom! NE="+ne+";SW="+sw)}
  };
  
  map.addControl(new DragZoomControl(boxStyleOpts, otherOpts, callbacks));	
        
        
        
       // map.addControl(new GSmallMapControl());
		//map.addControl(new DragZoomControl());
        

      }
    }
	
	
	initialize();
</script>
