<cfinclude template="/includes/_header.cfm">
		<iframe 
			width="1000" 
			height="1000" 
			id="gl" 
			src="http://www.museum.tulane.edu/geolocate/web/webgeoreflight.aspx?state=alaska&locality=fairbanks&georef=run">
		</iframe>
http://www.museum.tulane.edu/geolocate/web/WebGeoref.aspx?v=1&Country=USA&State=Alaska&Locality=Fairbanks
<script>
	function getit() {
		var lat=$("#lat_id").val();
		console.log(lat);
		$("#a").val(lat);
	}
	function getit2() {
		var lat=$("#gl").contents().find('#lat_id').val();
		console.log(lat);
		$("#a").val(lat);
	}
	
	  if (window.addEventListener) {
	        // For standards-compliant web browsers
	        window.addEventListener("message", displayMessage, false);
	    }
	    else {
	        window.attachEvent("onmessage", displayMessage);
	    }
	    
	    
	    
	      function displayMessage(evt) {
	        var message;
	        if (evt.origin !== "http://www.museum.tulane.edu") {
	            message = "iframe url does not have permision to interact with me";
	        }
	        else {
	            message = "From GEOLocate @ " + evt.origin + "<br />" + evt.data + "<br /><br />Parsed Results:<br />";
	            

	            var breakdown = evt.data.split("|");
                if (breakdown.length == 4)
                {
                    message += "Lat:" + breakdown[0] + "<br />";
                    message += "Lon:" + breakdown[1] + "<br />";
                    message += "Uncertainty Radius (meters):" + breakdown[2] + "<br />";
                    message += "Uncertainty Polygon:" + breakdown[3] + "<br />";
                }
                 
	            
	            
	            
	            
	        }
	        document.getElementById("received-message").innerHTML = message;
	    }
	
</script>
<cfoutput>
	
	
<div id="received-message" style="border:2px solid red;"></div>

<form>
	<input name="a" id="a" type="text">
</form>
<span onclick="getit()">getit</span>
<span onclick="getit2()">getit2</span>

</cfoutput>
