		<cfinclude template="/includes/_header.cfm">
<cfquery name="cf_global_settings" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
	select
		google_client_id,
		google_private_key
	from cf_global_settings
</cfquery>
<cfset title="Edit Locality">
<script language="JavaScript" src="/includes/jquery/scrollTo.js" type="text/javascript"></script>
<cfoutput>
	<cfhtmlhead text='<script src="http://maps.googleapis.com/maps/api/js?client=#cf_global_settings.google_client_id#&sensor=false&libraries=geometry" type="text/javascript"></script>'>
</cfoutput>



		<script language="javascript" type="text/javascript">
			rad = function(x) {return x*Math.PI/180;}
			distHaversine = function(p1, p2) {
			  var R = 6371; // earth's mean radius in km
			  var dLat  = rad(p2.lat() - p1.lat());
			  var dLong = rad(p2.lng() - p1.lng());

			  var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
			          Math.cos(rad(p1.lat())) * Math.cos(rad(p2.lat())) * Math.sin(dLong/2) * Math.sin(dLong/2);
			  var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
			  var d = R * c;

			  return d.toFixed(3);
			}



			function initialize() {
		        var mapOptions = {
		          center: new google.maps.LatLng(-34.397, 150.644),
		          zoom: 8,
		          mapTypeId: google.maps.MapTypeId.ROADMAP
		        };
		        var map = new google.maps.Map(document.getElementById("map-canvas"),
		            mapOptions);
		      }
		      google.maps.event.addDomListener(window, 'load', initialize);

</script>

<div id="map-canvas"></div>