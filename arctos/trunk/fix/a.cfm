<!DOCTYPE html>
<html>
<body>

<audio controls>
  <source src="http://web.corral.tacc.utexas.edu/MVZ/audio/mp3/D6230_Cicero_26Jun2006_Pmaculatus2.mp3" type="audio/mpeg">
  Your browser does not support this audio format.
</audio>

</body>
</html>

















<cfabort>

<cfinclude template="/includes/_header.cfm">

<script>

function test () {
	// save edited - this happens only from edit and 
	// returns only to edit
		$.ajax({
		    url: "/component/Bulkloader.cfc",
		    dataType: "json",
			type: "POST",
		    data: {
				method: "test",
				queryformat : "column",
				returnformat : "json",
				q : "collection_object_id=12"
			},
			success: function( r ){
				console.log(r);
			}
		});
}
</script>


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
	  var a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.cos(rad(p1.lat())) * Math.cos(rad(p2.lat())) * Math.sin(dLong/2) * Math.sin(dLong/2);
	  var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
	  var d = R * c;
	  return d.toFixed(3);
	}
	jQuery(document).ready(function() {
 		var map;
 		var mapOptions = {
        	center: new google.maps.LatLng($("#s_dollar_dec_lat").val(), $("#s_dollar_dec_long").val()),
         	mapTypeId: google.maps.MapTypeId.ROADMAP
        };
        var bounds = new google.maps.LatLngBounds();
		function initialize() {
        	map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);
      	}
		initialize();
		var latLng1 = new google.maps.LatLng($("#dec_lat").val(), $("#dec_long").val());
		if ($("#dec_lat").val().length>0){
			var marker1 = new google.maps.Marker({
			    position: latLng1,
			    map: map,
			    icon: 'http://maps.google.com/mapfiles/ms/icons/green-dot.png'
			});
			var circleOptions = {
	  			center: latLng1,
	  			radius: Math.round($("#error_in_meters").val()),
	  			map: map,
	  			editable: false
			};
			var circle = new google.maps.Circle(circleOptions);
		}
		var latLng2 = new google.maps.LatLng($("#s_dollar_dec_lat").val(), $("#s_dollar_dec_long").val());
		if ($("#s_dollar_dec_lat").val().length>0){
			var marker2 = new google.maps.Marker({
			    position: latLng2,
			    map: map,
			    icon: 'http://maps.google.com/mapfiles/ms/icons/red-dot.png'
			});
		}
		bounds.extend(latLng1);
        bounds.extend(latLng2);
		// center the map on the points
		map.fitBounds(bounds);
		// and zoom back out a bit, if the points will still fit
		// because the centering zooms WAY in if the points are close together
		var p1 = new google.maps.LatLng($("#dec_lat").val(),$("#dec_long").val());
		var p2 = new google.maps.LatLng($("#s_dollar_dec_lat").val(),$("#s_dollar_dec_long").val());
		var tdis=distHaversine(p1,p2);
		$("#distanceBetween").val(tdis);

		if (tdis < 50) {
			// if hte points are close together autozoom goes too far
			var listener = google.maps.event.addListener(map, "idle", function() {
				if (map.getZoom() > 4) map.setZoom(4);
				google.maps.event.removeListener(listener);
			});
		}
		// end map setup

		$("select[id^='geology_attribute_']").each(function(e){
			populateGeology(this.id);
		});
	    $.each($("input[id^='geo_att_determined_date_']"), function() {
			$("#" + this.id).datepicker();
	    });
	    if (window.addEventListener) {
			window.addEventListener("message", getGeolocate, false);
		} else {
			window.attachEvent("onmessage", getGeolocate);
		}
	});

	function useAutoCoords(){
		$("#dec_lat").val($("#s_dollar_dec_lat").val());
		$("#dec_long").val($("#s_dollar_dec_long").val());
	}

	function geolocate(method) {
		alert('This opens a map. There is a help link at the top. Use it. The save button will create a new determination.');
		var guri='http://www.museum.tulane.edu/geolocate/web/webgeoreflight.aspx?georef=run';
		if (method=='adjust'){
			guri+="&tab=result&points=" + $("#dec_lat").val() + "|" + $("#dec_long").val() + "|||" + $("#error_in_meters").val();
		} else {
			guri+="&state=" + $("#state_prov").val();
			guri+="&country="+$("#country").val();
			guri+="&county="+$("#county").val().replace(" County", "");
			guri+="&locality="+$("#spec_locality").val();
		}
		var bgDiv = document.createElement('div');
		bgDiv.id = 'bgDiv';
		bgDiv.className = 'bgDiv';
		bgDiv.setAttribute('onclick','closeGeoLocate("clicked closed")');
		document.body.appendChild(bgDiv);
		var popDiv=document.createElement('div');
		popDiv.id = 'popDiv';
		popDiv.className = 'editAppBox';
		document.body.appendChild(popDiv);
		var cDiv=document.createElement('div');
		cDiv.className = 'fancybox-close';
		cDiv.id='cDiv';
		cDiv.setAttribute('onclick','closeGeoLocate("clicked closed")');
		$("#popDiv").append(cDiv);
		var hDiv=document.createElement('div');
		hDiv.className = 'fancybox-help';
		hDiv.id='hDiv';
		hDiv.innerHTML='<a href="https://arctosdb.wordpress.com/how-to/create/data-entry/geolocate/" target="blank">[ help ]</a>';
		$("#popDiv").append(hDiv);
		$("#popDiv").append('<img src="/images/loadingAnimation.gif" class="centeredImage">');
		var theFrame = document.createElement('iFrame');
		theFrame.id='theFrame';
		theFrame.className = 'editFrame';
		theFrame.src=guri;
		$("#popDiv").append(theFrame);
	}
	function getGeolocate(evt) {
		var message;
		if (evt.origin !== "http://www.museum.tulane.edu") {
	    	alert( "iframe url does not have permision to interact with me" );
	        closeGeoLocate('intruder alert');
	    }
	    else {
	    	var breakdown = evt.data.split("|");
			if (breakdown.length == 4) {
			    var glat=breakdown[0];
			    var glon=breakdown[1];
			    var gerr=breakdown[2];
			    useGL(glat,glon,gerr)
			} else {
				alert( "Whoa - that's not supposed to happen. " +  breakdown.length);
				closeGeoLocate('ERROR - breakdown length');
	 		}
	    }
	}
	function closeGeoLocate(msg) {
		$('#bgDiv').remove();
		$('#bgDiv', window.parent.document).remove();
		$('#popDiv').remove();
		$('#popDiv', window.parent.document).remove();
		$('#cDiv').remove();
		$('#cDiv', window.parent.document).remove();
		$('#theFrame').remove();
		$('#theFrame', window.parent.document).remove();
	}
	function populateGeology(id) {
		if (id=='geology_attribute') {
			var idNum='';
			var thisValue=$("#geology_attribute").val();
			var dataValue=$("#geo_att_value").val();
			var theSelect="geo_att_value";
		} else {
			var idNum=id.replace('geology_attribute_','');
			var thisValue=$("#geology_attribute_" + idNum).val();;
			var dataValue=$("#geo_att_value_" + idNum).val();
			var theSelect="geo_att_value_";
		}
		jQuery.getJSON("/component/functions.cfc",
			{
				method : "getGeologyValues",
				attribute : thisValue,
				returnformat : "json",
				queryformat : 'column'
			},
			function (r) {
				var s='';
				for (i=0; i<r.ROWCOUNT; ++i) {
					s+='<option value="' + r.DATA.ATTRIBUTE_VALUE[i] + '"';
					if (r.DATA.ATTRIBUTE_VALUE[i]==dataValue) {
						s+=' selected="selected"';
					}
					s+='>' + r.DATA.ATTRIBUTE_VALUE[i] + '</option>';
				}
				$("select#" + theSelect + idNum).html(s);
			}
		);
	}

	function cloneLocality(locality_id) {
		if(confirm('Are you sure you want to create a copy of this locality which you may then edit?')) {
			var rurl='editLocality.cfm?action=clone&locality_id=' + locality_id;
			document.location=rurl;
		}
	}
	function convertToDD(format){
		if (format=='dms'){
		var lat_deg=$("#lat_deg").val();
		if(lat_deg==''){
			lat_deg=0;
		}
		var lat_min=$("#lat_min").val();
		if(lat_min==''){
			lat_min=0;
		}
		var lat_sec=$("#lat_sec").val();
		if(lat_sec==''){
			lat_sec=0;
		}
		var dms_latdir=$("#dms_latdir").val();
		var long_deg=$("#long_deg").val();
		if(long_deg==''){
			long_deg=0;
		}
		var long_min=$("#long_min").val();
		if(long_min==''){
			long_min=0;
		}
		var long_sec=$("#long_sec").val();
		if(long_sec==''){
			long_sec=0;
		}
		var dms_longdir=$("#dms_longdir").val();

		var dec_lat = parseFloat(lat_deg) + (parseFloat(lat_min) / 60) + (parseFloat(lat_sec) / 3600);
           if (dms_latdir == 'S'){
               dec_lat = dec_lat * -1;
           }
		var dec_long = parseFloat(long_deg) + (parseFloat(long_min) / 60) + (parseFloat(long_sec) / 3600);
            if (dms_longdir == 'W'){
               dec_long = dec_long * -1;
           }
       }
       if (format=='dm'){
			var dec_lat_deg=$("#dec_lat_deg").val();
			if(dec_lat_deg==''){
				dec_lat_deg=0;
			}
			var dec_lat_min=$("#dec_lat_min").val();
			if(dec_lat_min==''){
				dec_lat_min=0;
			}
			var dm_latdir=$("#dm_latdir").val();
			var dec_long_deg=$("#dec_long_deg").val();
			if(dec_long_deg==''){
				dec_long_deg=0;
			}
			var dec_long_min=$("#dec_long_min").val();
			if(dec_long_min==''){
				dec_long_min=0;
			}
			var dm_longdir=$("#dm_longdir").val();
			var dec_lat = parseFloat(dec_lat_deg) + (parseFloat(dec_lat_min) / 60);
			if (dm_latdir == 'S'){
			    dec_lat = dec_lat * -1;
			}
			var dec_long = parseFloat(dec_long_deg) + (parseFloat(dec_long_min) / 60);
		    if (dm_longdir == 'W'){
		        dec_long = dec_long * -1;
		    }
		}
		$("#dec_lat").val(dec_lat);
		$("#dec_long").val(dec_long);
	}

</script>


<span onclick="test();">test</span>