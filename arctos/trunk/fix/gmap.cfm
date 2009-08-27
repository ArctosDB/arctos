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
        var center = new GLatLng(50, -148);
        map.setCenter(center, 1);
        
        map.addControl(new GSmallMapControl());
        
        
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
    opacity:.0,
    border:"2px solid red"
  }

  /* second set of options is for everything else */
  
  var otherOpts = {
    overlayRemoveTime:99999999999999,  
    buttonHTML:"select area",
    buttonZoomingHTML:"draw rectangle",
    buttonStartingStyle:{border: '1px solid black', padding: '2px'},
    buttonZoomingStyle:{background: '#FF0'}    
  };
        
         var callbacks = {
    //buttonclick:function(){console.log("Looks like you activated DragZoom!")},
    //dragstart:function(){console.log("Started to Drag . . .");G.map.removeOverlay(zoomAreaPoly);},
    //dragging:function(x1,y1,x2,y2){console.log("Dragging, currently x="+x2+",y="+y2)},
    dragend:function(nw,ne,se,sw,nwpx,nepx,sepx,swpx){console.log("Zoom! nw="+nw+";se="+se);
    var nwA='hi there';
    //nw.split(",");
    console.log(nw[1]); 
    }
  };
  
  map.addControl(new DragZoomControl(boxStyleOpts, otherOpts, callbacks));	
        
        
        
       // map.addControl(new GSmallMapControl());
		//map.addControl(new DragZoomControl());
        

      }
    }
	
	
	initialize();
</script>



	<td align="left" nowrap>
						<strong><em>NW Latitude:</em></strong> <input type="text" name="nwLat" id="nwLat" size="8">
						<strong><em>NW Longitude:</em></strong> <input type="text" name="nwlong" id="nwlong" size="8">						
					</td>
				</tr>
				<tr>
					<td align="left" nowrap>
						<strong><em>SE Latitude:</em></strong> <input type="text" name="selat" id="selat" size="8">
						<strong><em>SE Longitude:</em></strong> <input type="text" name="selong" id="selong" size="8">
