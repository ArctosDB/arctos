<cfinclude template="/includes/_header.cfm">
	<!---
		just georeference all shipping addresses
		alter table address add s$coordinates varchar2(255);
		alter table address add s$lastdate date;
	--->



	create table temp_loan_map as select
		guid_prefix collection,
		loan_number,
		s$coordinates
	from
		collection,
		trans,
		loan,
		shipment,
		address
	where
		collection.collection_id=trans.collection_id and
		trans.transaction_id=loan.transaction_id and
		loan.transaction_id=shipment.transaction_id and
		shipment.SHIPPED_TO_ADDR_ID=address.address_id and
		s$coordinates is not null
	;
		
	
<cfoutput>

	<cfquery name="cf_global_settings" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select
			google_client_id,
			google_private_key
		from cf_global_settings
	</cfquery>
	<cfoutput>
		<cfhtmlhead text='<script src="https://maps.googleapis.com/maps/api/js?client=#cf_global_settings.google_client_id#&libraries=geometry" type="text/javascript"></script>'>
	</cfoutput>
	<style>
		#map-canvas { height: 300px;width:500px; }
		#map{width: 450px;height: 400px;display:inline-block;}
		#wktfetch{
			background-color:black;
			color:green;
			padding:1em;
			margin:1em;
			font-family:courier;
			font-size:small;
		}
		#wktinstr{
			border:1px solid black;
			margin:1em;
			padding:1em;
		}
		#mapInst {
			border:1px solid green;
			font-size:smaller;
			margin:1em;
			padding:1em;
		}
	</style>
	<script>
		var map;
		var bounds = new google.maps.LatLngBounds();
		var markers = new Array();
		var ptsArray=[];
		var polygonArray = [];
		function clearTerm(id){
			$("#" + id).val('');
		}
		function asterisckificateisland(){
			$("#island").val("*" + $("#island").val());
		}
		function addAPolygon(inc,d){
			var lary=[];
			var da=d.split(",");
			for(var i=0;i<da.length;i++){
				var xy = da[i].trim().split(" ");
				var pt=new google.maps.LatLng(xy[1],xy[0]);
				lary.push(pt);
				bounds.extend(pt);
			}
			ptsArray.push(lary);
		}
		function initializeMap() {
			var wkt=$("#wkt_poly_data").val();
			var infowindow = new google.maps.InfoWindow();
			var mapOptions = {
				zoom: 3,
			    center: new google.maps.LatLng(55, -135),
			    mapTypeId: google.maps.MapTypeId.ROADMAP,
			    panControl: false,
			    scaleControl: true
			};
			map = new google.maps.Map(document.getElementById('map'),mapOptions);
			var regex = /\(([^()]+)\)/g;
			var Rings = [];
			var results;
			while( results = regex.exec(wkt) ) {
			    Rings.push( results[1] );
			}
			for(var i=0;i<Rings.length;i++){
				addAPolygon(i,Rings[i]);
			}
	 		var poly = new google.maps.Polygon({
			    paths: ptsArray,
			    strokeColor: '#1E90FF',
			    strokeOpacity: 0.8,
			    strokeWeight: 2,
			    fillColor: '#1E90FF',
			    fillOpacity: 0.35
			});
			poly.setMap(map);
			// for use in containsLocation
			polygonArray.push(poly);
			// now specimen points
			var cfgml=$("#scoords").val();
			if (cfgml.length==0){
				return false;
			}
			var arrCP = cfgml.split( ";" );
			for (var i=0; i < arrCP.length; i++){
				createMarker(arrCP[i]);
			}
			for (var i=0; i < markers.length; i++) {
			   bounds.extend(markers[i].getPosition());
			}
			// Don't zoom in too far on only one marker
		    if (bounds.getNorthEast().equals(bounds.getSouthWest())) {
		       var extendPoint1 = new google.maps.LatLng(bounds.getNorthEast().lat() + 0.05, bounds.getNorthEast().lng() + 0.05);
		       var extendPoint2 = new google.maps.LatLng(bounds.getNorthEast().lat() - 0.05, bounds.getNorthEast().lng() - 0.05);
		       bounds.extend(extendPoint1);
		       bounds.extend(extendPoint2);
		    }
			map.fitBounds(bounds);
		}
		function createMarker(p) {
			var cpa=p.split(",");
			var lat=cpa[0];
			var lon=cpa[1];
			var center=new google.maps.LatLng(lat, lon);
			var contentString='<a target="_blank" href="/SpecimenResults.cfm?geog_auth_rec_id=' + $("#geog_auth_rec_id").val() + '&coordinates=' + lat + ',' + lon + '">clickypop</a>';
			//we must use original coordinates from the database as the title
			// so we can recover them later; the position coordinates are math-ed
			// during the transform to latLng
			var marker = new google.maps.Marker({
				position: center,
				map: map,
				title: lat + ',' + lon,
				contentString: contentString,
				zIndex: 10
			});
			markers.push(marker);
		    var infowindow = new google.maps.InfoWindow({
		        content: contentString
		    });
		    google.maps.event.addListener(marker, 'click', function() {
		        infowindow.open(map,marker);
		    });
		}
		jQuery(document).ready(function() {
			 initializeMap();
		});
		function openOutsidePoints(){
			var opa=[];
			for(var i=0; i<this.markers.length; i++){
	        	for(var a=0; a<polygonArray.length; a++){
	        		if  (! google.maps.geometry.poly.containsLocation(this.markers[i].position, polygonArray[a]) ) {
						opa.push(this.markers[i].title);
		        	}
	        	}
	    	}
	    	if (opa.length>0){
	    		var opastr=opa.join('|');
	    		var theURL='/SpecimenResults.cfm?geog_auth_rec_id=' + $("#geog_auth_rec_id").val() + '&coordslist=' + opastr;
	    		window.open(theURL);
			} else {
				alert('no outside points detected!');
			}
		}
	</script>


	<!----


	init georeference



	<cfquery name="d" datasource="uam_god">
		select
			ADDRESS_ID,
			ADDRESS
		from
		ADDRESS where
		address_type='shipping' and
		 S$LASTDATE is null and rownum<200
	</cfquery>
	<cfset obj = CreateObject("component","component.functions")>
	<cfloop query="d">

		<cfset mAddress=address>

		<cfset mAddress=replace(mAddress,chr(10),", ","all")>

		<p>#mAddress#</p>
		<!----
			extract ZIP
			start at the end, take the "first" thing that's numbers
		 ---->

		<cfset ttu="">
	 	<cfloop index="i" list="#mAddress#">
			<cfif REFind("[0-9]+", i) gt 0>
				<cfset ttu=i>
			</cfif>
		</cfloop>
		<p>
			using #ttu#
		</p>

		<cfset signedURL = obj.googleSignURL(
			urlPath="/maps/api/geocode/json",
			urlParams="address=#URLEncodedFormat('#ttu#')#")>
		<cfhttp result="x" method="GET" url="#signedURL#"  timeout="20"/>
		<cfset llresult=DeserializeJSON(x.filecontent)>
		<cfif llresult.status is "OK">
			<cfset coords=llresult.results[1].geometry.location.lat & "," & llresult.results[1].geometry.location.lng>
		<cfelse>
			<cfset coords=''>
		</cfif>
		<p>
			update address set
				s$coordinates='#coords#',
				s$lastdate=sysdate
			where ADDRESS_ID=#ADDRESS_ID#
		</p>
		<cfquery name="upEsDollar" datasource="uam_god">
			update address set
				s$coordinates='#coords#',
				s$lastdate=sysdate
			where ADDRESS_ID=#ADDRESS_ID#
		</cfquery>



	END 	init georeference

---->


	</cfloop>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">