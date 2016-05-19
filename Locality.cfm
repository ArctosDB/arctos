<cfinclude template="includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cf_customizeIFrame>
<script language="javascript" type="text/javascript">
	jQuery(document).ready(function() {
		$("#began_date").datepicker();
		$("#ended_date").datepicker();
	});
	function addGeoSrchTerm(){
		var n,h;
		n=parseInt($("#numGeogSrchTerms").val()) + 1;
		h='<tr id="gst' + n + '"><td colspan="4">';
		h+='<textarea name="new_geog_search_term_' + n + '" id="new_geog_search_term_' + n + '" class="longtextarea newRec" rows="30" cols="1"></textarea>'
		h+='</td></tr>';
		$( "#gst" + $("#numGeogSrchTerms").val()).after( h );
		$("#numGeogSrchTerms").val(n);
	}
</script>
<cfoutput>
<!--- see if action is duplicated --->
<cfif action contains ",">
	<cfset i=1>
	<cfloop list="#action#" delimiters="," index="a">
		<cfif i is 1>
			<cfset firstAction = a>
		<cfelse>
			<cfif a neq firstAction>
				An error has occured! Multiple Action in Locality. Please submit a bug report.
				<cfabort>
			</cfif>
		</cfif>
	</cfloop>
	<cfset action = firstAction>
</cfif>
<cfif isdefined("collection_object_id") AND collection_object_id gt 0 AND action is "nothing">
	<!--- probably got here from SpecimenDetail, make sure we're in a frame --->
	<script>
		var thePar = parent.location.href;
		var isFrame = thePar.indexOf('Locality.cfm');
		if (isFrame == -1) {
			// we're in a frame, action is NOTHING, we have a collection_object_id; redirect to
			// get a collecting_event_id
			//alert('in a frame');
			document.location='Locality.cfm?action=findCollEventIdForSpecDetail&collection_object_id=#collection_object_id#';
		}
	</script>
</cfif>

<cfif action is "massEditCollEvent">
	<cfquery name="locality" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
		SPEC_LOCALITY,
		DEC_LAT,
		DEC_LONG,
		DATUM
		from locality where locality_id=#locality_id#
	</cfquery>
	<cfquery name="events" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			count(*) c,
			VERBATIM_DATE,
			VERBATIM_LOCALITY,
			VERBATIM_COORDINATES,
			COLLECTING_EVENT_NAME
		from
			collecting_event
		where
			locality_id=#locality_id#
		group by
			VERBATIM_DATE,
			VERBATIM_LOCALITY,
			VERBATIM_COORDINATES,
			COLLECTING_EVENT_NAME
	</cfquery>
	Updating events used in verified specimen-events will fail. (You can mass-update verificationstatus from edit event.)
	<p>
		Use this form to update all specimens in the table below to the locality coordinates. If you need more control, use other tools.
	</p>
	<p>
		If you aren't absolutely sure what this form does, find out before clicking anything.
	</p>

	<p>Locality:</p>
	<ul>
		<li>Locality_ID: #locality_id#</li>
		<li>SPEC_LOCALITY: #locality.SPEC_LOCALITY#</li>
		<li>DEC_LAT: #locality.DEC_LAT#</li>
		<li>DEC_LONG: #locality.DEC_LONG#</li>
		<li>DATUM: #locality.DATUM#</li>
	</ul>

	<label for="et">Events using this Locality</label>
	<table id="et" border>
		<tr>
			<th>Count</th>
			<th>Nickname</th>
			<th>Date</th>
			<th>Coordinates</th>
		</tr>
		<cfloop query="events">
			<tr>
				<td>#c#</td>
				<td>#COLLECTING_EVENT_NAME#</td>
				<td>#VERBATIM_DATE#</td>
				<td>#verbatim_coordinates#</td>
			</tr>
		</cfloop>
	</table>
	<input type="button" value="Continue to update all events to these locality coordinates" class="savBtn"
		onclick="document.location='/Locality.cfm?action=reallyMassEditCollEvent&locality_id=#locality_id#'">
</cfif>
	<cfif action is "reallyMassEditCollEvent">
		<cfquery name="reallyMassEditCollEvent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update collecting_event set
				( ORIG_LAT_LONG_UNITS, DEC_LAT, DEC_LONG, DATUM)
				= (select 'decimal degrees', DEC_LAT, DEC_LONG, DATUM from locality where locality_id=#locality_id#)
			where locality_id=#locality_id#
		</cfquery>
		<cflocation addtoken="false" url="editLocality.cfm?locality_id=#locality_id#">
	</cfif>

<cfif action is "findCollEventIdForSpecDetail">
	<!--- get a collecting event ID and relocate to editCollEvnt --->
	<cfquery name="ceid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select collecting_event_id from cataloged_item where
		collection_object_id=#collection_object_id#
	</cfquery>
	<cflocation url="Locality.cfm?action=editCollEvnt&collecting_event_id=#ceid.collecting_event_id#" addtoken="false">
</cfif>
</cfoutput>
<cfif not isdefined("collection_object_id")>
	<cfset collection_object_id=-1>
</cfif>
<cfif not isdefined("anchor")>
	<cfset anchor="">
</cfif>
<!--------------------------- Code-table queries -------------------------------------------------->
<cfquery name="ctIslandGroup" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select island_group from ctisland_group order by island_group
</cfquery>
<cfquery name="ctElevUnit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select orig_elev_units from ctorig_elev_units order by orig_elev_units
</cfquery>
<cfquery name="ctCollecting_Source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select collecting_source from ctCollecting_Source order by collecting_source
</cfquery>
<cfquery name="ctFeature" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select distinct(feature) from ctfeature order by feature
</cfquery>
	<cfquery name="ctGeorefMethod" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select georefMethod from ctgeorefmethod order by georefMethod
</cfquery>
<cfquery name="ctVerificationStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select VerificationStatus from ctVerificationStatus order by VerificationStatus
</cfquery>
<cfquery name="ctlat_long_units" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select ORIG_LAT_LONG_UNITS from ctlat_long_units order by ORIG_LAT_LONG_UNITS
</cfquery>
<cfquery name="ctdatum" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select datum from ctdatum order by datum
</cfquery>

<!---------------------------------------------------------------------------------------------------->
<cfif action is "nothing">
<cfoutput>
<cfset title="Manage Localities">
<table border>
	<tr>
		<td>Higher Geography</td>
		<td>
			<form name="nothing" method="post" action="Locality.cfm">
				<input type="hidden" name="Action" value="findHG">
				<input type="submit" value="Find" class="lnkBtn">
			</form>
		</td>
		<td>
			<form name="nothing" method="post" action="Locality.cfm">
				<input type="hidden" name="Action" value="newHG">
				<input type="submit" value="New Higher Geog" class="insBtn">
			</form>
		</td>
		<td>
			<!---<a href="javascript:void(0);" onClick="getDocs('higher_geography')"><img src="/images/what.gif" border="0"></a>--->
			<span class="infoLink" onclick="getDocs('higher_geography');">Define</span>
		</td>
	</tr>
	<tr>
		<td>Localities</td>
		<td>
			<form name="nothing" method="post" action="Locality.cfm">
				<input type="hidden" name="Action" value="findLO">
				<input type="submit" value="Find" class="lnkBtn">
			</form>
		</td>
		<td>
			<form name="nothing" method="post" action="Locality.cfm">
				<input type="hidden" name="Action" value="newLocality">
				<input type="submit" value="New Locality" class="insBtn">
			</form>
		</td>
		<td>
			<span class="infoLink" onclick="getDocs('locality');">Define</span>
		</td>
	</tr>
	<tr>
		<td>Collecting Events</td>
		<td>
			<form name="nothing" method="post" action="Locality.cfm">
				<input type="hidden" name="Action" value="findCO">
				<input type="submit" value="Find" class="lnkBtn">
			</form>
		</td>
		<td>(Find and clone to create new)</td>
		<td>
			<span class="infoLink" onclick="getDocs('collecting_event');">Define</span>
		</td>
	</tr>
</table>
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "findHG">
	<cfoutput>
		<cfset title="Find Geography">
		<strong>Find Higher Geography:</strong>
		<form name="getCol" method="post" action="Locality.cfm">
		    <input type="hidden" name="Action" value="findGeog">
			<cfinclude template="/includes/frmFindLocation_guts.cfm">
		</form>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "newHG">
<cfoutput>
	<cfset title="Create Higher Geography">
	<b>Create Higher Geography:</b>
	<cfform name="getHG" method="post" action="Locality.cfm">
		<input type="hidden" name="Action" value="makeGeog">
		<table>
			<tr>
				<td align="right">Continent or Ocean:</td>
				<td>
					<input type="text" name="continent_ocean" <cfif isdefined("continent_ocean")> value = "#continent_ocean#"</cfif>>
				</td>
			</tr>
			<tr>
				<td align="right">Country:</td>
				<td>
					<input type="text" name="country" <cfif isdefined("country")> value = "#country#"</cfif>>
				</td>
			</tr>
			<tr>
				<td align="right">State:</td>
				<td>
					<input type="text" name="state_prov" <cfif isdefined("state_prov")> value = "#state_prov#"</cfif>>
				</td>
			</tr>
			<tr>
				<td align="right">County:</td>
				<td>
					<input type="text" name="county" <cfif isdefined("county")> value = "#county#"</cfif>>
				</td>
			</tr>
			<tr>
				<td align="right">Quad:</td>
				<td>
					<input type="text" name="quad" <cfif isdefined("quad")> value = "#quad#"</cfif>>
				</td>
			</tr>
			<tr>
				<td align="right">Feature:</td>
				<td>
				<cfif isdefined("feature")>
					<cfset thisFeature = feature>
				<cfelse>
					<cfset thisFeature = "">
				</cfif>
				<select name="feature">
					<option value=""></option>
						<cfloop query="ctFeature">
							<option
								<cfif thisFeature is ctFeature.feature> selected="selected" </cfif>
								value = "#ctFeature.feature#">#ctFeature.feature#</option>
						</cfloop>
				</select>
			</td>
			</tr>
			<tr>
				<td align="right">Island Group:</td>
				<td>
				<cfif isdefined("island_group")>
					<cfset  islandgroup=island_group>
				<cfelse>
					<cfset islandgroup=''>
				</cfif>

				<select name="island_group" size="1">
				<option value=""></option>
				<cfloop query="ctIslandGroup">
					<option <cfif ctIslandGroup.island_group is islandgroup> selected="selected" </cfif>
						value="#ctIslandGroup.island_group#">#ctIslandGroup.island_group#
					</option>
				</cfloop>
			</select></td>
			</tr>
			<tr>
				<td align="right">Island:</td>
				<td>
					<input type="text" name="island" <cfif isdefined("island")> value = "#island#"</cfif> size="50">
				</td>
			</tr>
			<tr>
				<td align="right">Sea:</td>
				<td>
					<input type="text" name="sea" <cfif isdefined("sea")> value = "#sea#"</cfif>>
				</td>
			</tr>
			<tr>
				<td align="right">Source Authority (Wikipedia URL - BE SPECIFIC!)</td>
				<td>
					<input name="source_authority" id="source_authority" class="reqdClr">
				</td>
			</tr>
			<tr>
			<td colspan="2">
				<label for="geog_remark">Remarks (why is this unique, how is it different from similar values, etc.)</label>
				<textarea name="geog_remark" id="geog_remark" class="hugetextarea" rows="60" cols="10"></textarea>
			</td>
		</tr><tr>
			<td colspan="2">
				<input type="submit" value="Create" class="insBtn">
				<input type="button" value="Quit" class="qutBtn" onclick="document.location='Locality.cfm';">
			</td>
		</tr>
	</table>
	</cfform>
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "findLO">
	<cfoutput>
		<cfset title="Find Locality">
		<cfset showLocality=1>
		<strong>Find Locality:</strong>
	    <form name="getCol" method="post" action="Locality.cfm">
			<input type="hidden" name="Action" value="findLocality">
			<cfinclude template="/includes/frmFindLocation_guts.cfm">
	     </form>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "findCO">
<cfoutput>
	<cfset title="Find Collecting Events">
	<cfset showLocality=1>
	<cfset showEvent=1>
	<strong>Find Collecting Events:</strong>
    <form name="getCol" method="post" action="Locality.cfm">
		<input type="hidden" name="Action" value="findCollEvent">
		<cfinclude template="/includes/frmFindLocation_guts.cfm">
     </form>
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "editGeog">
<cfquery name="cf_global_settings" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select
			google_client_id,
			google_private_key
		from cf_global_settings
	</cfquery>
	<cfoutput>
		<cfhtmlhead text='<script src="http://maps.googleapis.com/maps/api/js?client=#cf_global_settings.google_client_id#&libraries=geometry" type="text/javascript"></script>'>
	</cfoutput>
	<style>
		#map-canvas { height: 300px;width:500px; }
		#map{width: 450px;height: 400px;}
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

	/*
	function AddPoints(data){

		//var ptsArray=[];

		console.log('AddPoints: ' + data);


	    //first spilt the string into individual points


	   // var data='40 40,20 45,45 30,40 40';

	    		//console.log('newdata: ' + data);

	    var pointsData=data.split(",");


		console.log('pointsData: ' + pointsData);
	    //iterate over each points data and create a latlong
	    //& add it to the cords array
	    var len=pointsData.length;


	    		console.log('pointsData.length: ' + pointsData.length);


	    for(var i=0;i<pointsData.length;i++){
		   // console.log('i am i: ' + i);

		   // console.log('pointsData[i]:' + pointsData[i] + ':');


		    var tpd=pointsData[i];


		     var xy = tpd.split(" ");

		      var pt=new google.maps.LatLng(xy[1],xy[0]);

	        ptsArray.push(pt);
	        bounds.extend(pt);

 //console.log(xy);

 //console.log(pt);


		}

		console.log('leaving AddPoints - ptsArray is...');
		console.log(ptsArray);



	    for (var pi=0;pi<pointsData.length;pi++) {
			console.log('pi: ' || pi);










	        var pt=new google.maps.LatLng(xy[1],xy[0]);


	        console.log('pt: ' + pt);


	    }


	}
	*/


	function addAPolygon(inc,d){
		var lary=[];

		//console.log('hello I am addAPolygon');
		//console.log(d);
		var da=d.split(",");
		//console.log(da);
		for(var i=0;i<da.length;i++){
			var xy = da[i].trim().split(" ");
			//console.log('x');
			//console.log(xy[1]);
			//console.log('y');

			//console.log(xy[0]);
			var pt=new google.maps.LatLng(xy[1],xy[0]);
			lary.push(pt);
			bounds.extend(pt);
		}

		//console.log('I made a local array of LatLng (lary): ');
		//console.log(lary);
		//console.log('now im going to push it to the big array (ptsArray): ');
		ptsArray.push(lary);

		//console.log(ptsArray);



			//polygonArray.push(poly);

			//polygonArray[polygonArray.length-1].setMap(map);

			 //console.log('polygonArray');
			 //console.log(polygonArray);



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

		    //console.log('Ring thingee');
		}
		for(var i=0;i<Rings.length;i++){
			//console.log('set of points: Rings[i]');
			//console.log(Rings[i]);
			addAPolygon(i,Rings[i]);
			//var ptsArray=[];

		    ///AddPoints(Rings[i]);




		}


		//addAPolygon(poly1);


		//addAPolygon(poly2);

		//console.log('im back to initmap with the array containing all of the points');
		//console.log(ptsArray);

		/*
  		for (var i=0; i<ptsArray.length-1; i++) {
  			console.log('ptsArray[i]' + i);
  			console.log(ptsArray[i]);



  		}
*/

 var poly = new google.maps.Polygon({
			    paths: ptsArray,
			    strokeColor: '#1E90FF',
			    strokeOpacity: 0.8,
			    strokeWeight: 2,
			    fillColor: '#1E90FF',
			    fillOpacity: 0.35
			});




			poly.setMap(map);

			//console.log('i added the poly to the map');



  			/*


*/
/*
		//using regex, we will get the indivudal Rings
		var regex = /\(([^()]+)\)/g;
		var Rings = [];
		var results;
		while( results = regex.exec(wkt) ) {
		    Rings.push( results[1] );
		}

		console.log('Rings: ' );
		console.log(Rings);

		var polyLen=Rings.length;



		console.log(polyLen);

		//now we need to draw the polygon for each of inner rings, but reversed
		for(var i=0;i<polyLen;i++){

			//var ptsArray=[];

		    AddPoints(Rings[i]);




		}

 console.log('adding polygon: ' + ptsArray);

		    var poly = new google.maps.Polygon({
			    paths: ptsArray,
			    strokeColor: '#1E90FF',
			    strokeOpacity: 0.8,
			    strokeWeight: 2,
			    fillColor: '#1E90FF',
			    fillOpacity: 0.35
			});




			//poly.setMap(map);
			polygonArray.push(poly);

			polygonArray[polygonArray.length-1].setMap(map);

			 console.log('polygonArray');
			 console.log(polygonArray);





		//

	*/


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
		//var ns=cpa[0];
		var lat=cpa[0];
		var lon=cpa[1];
		//var r=cpa[3];
		var center=new google.maps.LatLng(lat, lon);

		var contentString='<a target="_blank" href="/SpecimenResults.cfm?geog_auth_rec_id=' + $("#geog_auth_rec_id").val() + '&rcoords=' + lat + ',' + lon + '">clickypop</a>';
		//we must use original coordinates from the database as the title
		// so we can recover them later; the position coordinates are math-ed
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
		console.log('this.markers.length');
		console.log(this.markers.length);

		console.log('ptsArray.length');
		console.log(ptsArray.length);


		for(var i=0; i<this.markers.length; i++){
			console.log('loopy ' + i);

        	for(var a=0; a<ptsArray.length; a++){
        		if  (! google.maps.geometry.poly.containsLocation(this.markers[i].position, ptsArray[a]) ) {
					// we have to use title here; position is math-ed and won't match coordinates in DB
        			opa.push(this.markers[i].title);
       			}
        	}
    	}
    	if (opa.length>0){
    		var opastr=opa.join('|');
    		var theURL='/SpecimenResults.cfm?geog_auth_rec_id=' + $("#geog_auth_rec_id").val() + '&coordslist=' + opastr;
    		window.open(theURL);
		} else {
			alert('no outside points detected');
		}
	}
</script>
<cfset title = "Edit Geography">
	<cfoutput>
		<cfquery name="geogDetails" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		 select * from geog_auth_rec where geog_auth_rec_id = #geog_auth_rec_id#
		</cfquery>
		<h3>Edit Higher Geography</h3>
		<span class="infoLink" onClick="getDocs('higher_geography')">help</span>
		<cfquery name="localities" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select count(*) c from locality where geog_auth_rec_id=#geog_auth_rec_id#
		</cfquery>
		<cfquery name="collecting_events" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select count(*) c from locality,collecting_event
			where
			locality.locality_id = collecting_event.locality_id AND
			geog_auth_rec_id=#geog_auth_rec_id#
		</cfquery>
		<cfquery name="specimen" datasource="uam_god">
			select
				collection.collection_id,
				collection.guid_prefix,
				count(*) c
			from
				locality,
				collecting_event,
				specimen_event,
				cataloged_item,
				collection
			where
				locality.locality_id = collecting_event.locality_id AND
				collecting_event.collecting_event_id = specimen_event.collecting_event_id AND
				specimen_event.collection_object_id=cataloged_item.collection_object_id AND
			 	cataloged_item.collection_id=collection.collection_id and
			 	geog_auth_rec_id=#geog_auth_rec_id#
			 group by
			 	collection.collection_id,
				collection.guid_prefix
			order by
				collection.guid_prefix
		</cfquery>
		<cfquery name="scoords" datasource="uam_god">
			select distinct
				--round(dec_lat,1) || ',' || round(dec_long,1) rcords
				dec_lat || ',' || dec_long rcords
			from
				flat
			where
				dec_lat is not null and
			 	geog_auth_rec_id=#geog_auth_rec_id#
		</cfquery>
		<input type="hidden" id="scoords" value="#valuelist(scoords.rcords,";")#">
		<cfquery name="sspe" dbtype="query">
			select sum(c) sct from specimen
		</cfquery>
		<div style="border:2px solid blue; background-color:red;">
			Altering this record will update:
			<ul>
				<li>#localities.c# <a href="Locality.cfm?geog_auth_rec_id=#geog_auth_rec_id#&action=findLocality">localities</a></li>
				<li>#collecting_events.c# <a href="Locality.cfm?geog_auth_rec_id=#geog_auth_rec_id#&action=findCollEvent">collecting events</a></li>
				<li>#sspe.sct# <a href="/SpecimenResults.cfm?geog_auth_rec_id=#geog_auth_rec_id#">specimens</a></li>
				<cfloop query="specimen">
					<li>
						<a href="/SpecimenResults.cfm?geog_auth_rec_id=#geog_auth_rec_id#&collection_id=#specimen.collection_id#">
							#specimen.c# #guid_prefix# specimens
						</a>
					</li>
				</cfloop>
			</ul>
		</div>
    </cfoutput>
	<cfoutput query="geogDetails">
		<br><em>#higher_geog#</em>
		<a target="_blank" class="external infoLink" href="https://google.com/search?q=#higher_geog#">search Google</a>
        <form name="editHG" id="editHG" method="post" action="Locality.cfm">
	        <input name="action" id="action" type="hidden" value="saveGeogEdits">
            <input type="hidden" id="geog_auth_rec_id" name="geog_auth_rec_id" value="#geog_auth_rec_id#">
            <table>
				<tr>
	                <td>
						<label for="continent_ocean" class="likeLink" onClick="getDocs('higher_geography','continent_ocean')">
							Continent or Ocean
						</label>
						<input type="text" name="continent_ocean" id="continent_ocean" value="#continent_ocean#" size="60"></td>
	                <td>
						<label for="country" class="likeLink" onClick="getDocs('higher_geography','country')">
							Country
						</label>
						<input type="text" name="country" id="country" size="60" value="#country#">
					</td>
				</tr>
				<tr>
					<td>
						<label for="state_prov">
							<span class="likeLink" onClick="getDocs('higher_geography','state_province')">State/Province</span>

							<cfif len(state_prov) gt 0>
								<a target="_blank" class="external" href="https://en.wikipedia.org/w/index.php?search=#state_prov#">search Wikipedia</a>
							</cfif>
						</label>
						<input type="text" name="state_prov" id="state_prov" value="#state_prov#" size="60">
					</td>
					<td>
						<label for="sea">
							<span class="likeLink" onClick="getDocs('higher_geography','sea')">Sea</span>
							<cfif len(sea) gt 0>
								<a target="_blank" class="external infoLink" href="https://en.wikipedia.org/w/index.php?search=#sea#">search Wikipedia</a>
							</cfif>
						</label>
						<input type="text" name="sea" id="sea" value="#sea#" size="60">
					</td>
				</tr>
				<tr>
					<td>
						<label for="county">
							<span class="likeLink" onClick="getDocs('higher_geography','county')">County</span>
							<cfif len(county) gt 0>
								<a target="_blank" class="external" href="https://en.wikipedia.org/w/index.php?search=#county#">search Wikipedia</a>
							</cfif>
						</label>
						<input type="text" name="county" id="county" value="#county#" size="60">
					</td>
                	<td>
						<label for="quad" class="likeLink" onClick="getDocs('higher_geography','map_name')">
							Quad
						</label>
						<input type="text" name="quad" id="quad" value="#quad#" size="60">
					</td>
				</tr>
				<tr>
					<td>
						<cfif isdefined("feature")>
							<cfset thisFeature = feature>
						<cfelse>
							<cfset thisFeature = "">
						</cfif>
						<label for="feature">
							<span class="likeLink" onClick="getDocs('higher_geography','feature')">Feature</span>
							<cfif len(feature) gt 0>
								<a target="_blank" class="external" href="https://en.wikipedia.org/w/index.php?search=#feature#">search Wikipedia</a>
							</cfif>
						</label>
						<select name="feature" id="feature">
							<option value=""></option>
							<cfloop query="ctFeature">
								<option	<cfif thisFeature is ctFeature.feature> selected="selected" </cfif>
									value = "#ctFeature.feature#">#ctFeature.feature#</option>
							</cfloop>
						</select>
					</td>
					<td>

					</td>
				</tr>
				<tr>
					<td>
						<label for="island_group">
							<span class="likeLink" onClick="getDocs('higher_geography','island_group')">Island Group</span>
							<cfif len(island_group) gt 0>
								<a target="_blank" class="external" href="https://en.wikipedia.org/w/index.php?search=#island_group#">search Wikipedia</a>
							</cfif>
						</label>
						<select name="island_group" id="island_group" size="1">
		                	<option value=""></option>
		                    <cfloop query="ctIslandGroup">
		                      <option
							<cfif geogdetails.island_group is ctislandgroup.island_group> selected="selected" </cfif>value="#ctIslandGroup.island_group#">#ctIslandGroup.island_group#</option>
		                    </cfloop>
		                  </select>
					</td>
					<td >
						<label for="island">
							<span class="likeLink" onClick="getDocs('higher_geography','island')">Island</span>
							<span class="likeLink" onClick="asterisckificateisland();">
								[ prefix with * ]
							</span>
							to override duplicate detection
							<cfif len(island) gt 0>
								<a target="_blank" class="external" href="https://en.wikipedia.org/w/index.php?search=#island#">search Wikipedia</a>
							</cfif>
						</label>
						<input type="text" name="island" id="island" value="#island#" size="60">
					</td>
				</tr>
				<tr>
	                <td colspan="2">
						<cfif len(source_authority) gt 0 and source_authority contains "wikipedia.org">
							<cfhttp method="get" url="#source_authority#"></cfhttp>
							<cfset flds="continent_ocean,country,state_prov,sea,county,quad,feature,island_group,island">
							<cfset errs="">
							<cfloop list="#flds#" index="f">
								<cfset fv=evaluate(f)>
								<cfif len(fv) gt 0>
									<cfif cfhttp.filecontent does not contain fv>
										<cfset errs=errs & "<li>#fv# (#f#) does not occur in Source!</li>">
									</cfif>
								</cfif>
							</cfloop>
							<cfif len(errs) gt 0>
								<div style="border:2px solid red; margin:1em;padding:1em;font-weight:bold;">
									Possible problems detected with this Source. Please double-check your data and the linked article
									and review the
									<a href="http://arctosdb.org/higher-geography/##guidelines" target="_blank" class="external">
										Geography Creation Guidelines
									</a>.
									<ul>#errs#</ul>
								</div>
							</cfif>
						</cfif>
						<label for="source_authority">
							Authority (pattern: http://{language}.wikipedia.org/wiki/{article} - BE SPECIFIC!)
						</label>
						<input type="url" name="source_authority" id="source_authority" class="reqdClr" required
							value="#source_authority#"  pattern="https?://[a-z]{2}.wikipedia.org/wiki/.{1,}" size="80">
						<cfif len(source_authority) gt 0 and source_authority contains 'http'>
							<a target="_blank" class="external" href="#source_authority#">clicky</a>
						</cfif>
					</td>
				</tr>
				<tr>
	                <td colspan="4">
	                	<label for="geog_remark">Remarks (why is this unique, how is it different from similar values, etc.)</label>
	                	<textarea name="geog_remark" id="geog_remark" class="hugetextarea" rows="60" cols="10">#geog_remark#</textarea>
	                </td>
				</tr>
				<tr>
	                <td colspan="4">
		                <cfset wktpolydata=wkt_polygon>
		                <cfif len(wkt_polygon) gt 0 and left(wkt_polygon,6) is 'FILE::'>
									<br>reading a file...
									<cfset filename=right(wkt_polygon,len(wkt_polygon)-6)>
									<br>filename: #filename#
									<cfhttp method="GET" url=#filename#></cfhttp>
									<cfdump var=#cfhttp#>
									<cfset wktpolydata=cfhttp.filecontent>
							</cfif>

						<input type="text" id="wkt_poly_data" value="#wktpolydata#">

	                	<label for="wkt_polygon">wkt_polygon</label>
	                	<textarea name="wkt_polygon" id="wkt_polygon" class="hugetextarea" rows="60" cols="10">#wkt_polygon#</textarea>
 						<div style="font-size:x-small">
							Error is not displayed here; examine the locality before doing anything.

							<cfif len(wkt_polygon) gt 0>
								<br>Large WKT (>~30K characters) will not work properly
								<br>The WKT was probably converted from KML or something and may be garbage
								<br><span class="likeLink" onclick="openOutsidePoints();">
									Find specimens with coordinates "outside" the WKT shape (new window)
								</span>

							</cfif>
						</div>
						<div id="map"></div>
	                </td>
				</tr>
				<cfquery name="geog_search_term" datasource="uam_god">
					select * from geog_search_term where geog_auth_rec_id=#geog_auth_rec_id#
				</cfquery>
				<tr>
	                <td colspan="4">
		                <div class="smaller">
		                	<strong>Geog Terms</strong> are "non-standard" terms that might be useful in finding stuff or clarifying an entry.
	                	</div>
	                </td>
				</tr>
					<input type="hidden" name="numGeogSrchTerms" id="numGeogSrchTerms" value="1">
				<tr id="gst1">
	                <td colspan="4">
	                	<label for="new_geog_search_term_1">
	                		Add Geog Search Term <span class="likeLink" onclick="addGeoSrchTerm();">[ add a row ]</span>
	                	</label>
	                	<textarea name="new_geog_search_term_1" id="new_geog_search_term_1" class="longtextarea newRec" rows="30" cols="1"></textarea>
	                </td>
				</tr>
				<tr>
	                <td colspan="4">
	                	<label for="">Existing Geog Search Term(s)</label>
	                </td>
				</tr>
				<cfloop query="geog_search_term">
					<tr>
		                <td colspan="4">
		                	<textarea name="geog_search_term_#geog_search_term_id#" id="geog_search_term_#geog_search_term_id#" class="longtextarea" rows="30" cols="1">#search_term#</textarea>
		                	<span class="infoLink" onclick="clearTerm('geog_search_term_#geog_search_term_id#');">delete</span>
		                </td>
					</tr>
				</cfloop>
				<tr>
	                <td colspan="4" nowrap align="center">

						<cfif session.roles contains "manage_geography">
							<input type="button"
								value="Save All"
								class="savBtn"
								onclick="$('##action').val('saveGeogEdits');$('##editHG').submit();">
							<cfset dloc="Locality.cfm?action=newHG&continent_ocean=#continent_ocean#&country=#country#&state_prov=#state_prov#&county=#county#&quad=#quad#&feature=#feature#&island_group=#island_group#&island=#island#&sea=#sea#">
							<input type="button" value="Create Clone" class="insBtn" onclick="document.location='#dloc#';">
							<input type="button" value="Delete" class="delBtn"
								onClick="document.location='Locality.cfm?Action=deleteGeog&geog_auth_rec_id=#geog_auth_rec_id#';">
						</cfif>
						<input type="button" value="See Localities" class="lnkBtn"
							onClick="document.location='Locality.cfm?Action=findLocality&geog_auth_rec_id=#geog_auth_rec_id#';">
						<input type="button"
							value="Save Search Terms (manage_locality OK)"
							class="savBtn"
							onclick="$('##action').val('saveSTOnly');$('##editHG').submit();">
					</td>
				</tr>
			</table>
		</form>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "saveSTOnly">
	<cfoutput>
		<cftransaction>
			<cfloop from ="1" to="#numGeogSrchTerms#" index="i">
				<cfset thisTerm=evaluate("new_geog_search_term_" & i)>
				<cfif len(thisTerm) gt 0>
					<cfquery name="ist1" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						insert into geog_search_term (geog_auth_rec_id,search_term) values (#geog_auth_rec_id#,trim('#escapeQuotes(thisTerm)#'))
					</cfquery>
				</cfif>
			</cfloop>
			<cfloop list="#form.FieldNames#" index="f">
				<cfif left(f,17) is "geog_search_term_">
					<cfset thisv=evaluate("form." & f)>
					<cfset thisID=replacenocase( f,"geog_search_term_","")>
					<cfif len(thisv) eq 0>
						<cfquery name="upst" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							delete from geog_search_term where geog_search_term_id=#thisID#
						</cfquery>
					<cfelse>
						<cfquery name="upst" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							update geog_search_term set search_term='#escapequotes(thisv)#' where geog_search_term_id=#thisID#
						</cfquery>
					</cfif>
				</cfif>
			</cfloop>
		</cftransaction>
		<cflocation addtoken="no" url="Locality.cfm?Action=editGeog&geog_auth_rec_id=#geog_auth_rec_id#">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "updateAllVerificationStatus">
	<cfoutput>
	    <cfquery name="upall" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update
				specimen_event
			set
				VerificationStatus='#VerificationStatus#'
			where
				COLLECTING_EVENT_ID='#COLLECTING_EVENT_ID#' and
				COLLECTION_OBJECT_ID in (select COLLECTION_OBJECT_ID from cataloged_item) -- keep things on the right side of the VPD
				<cfif isdefined("VerificationStatusIs") and len(VerificationStatusIs) gt 0>
					and VerificationStatus='#VerificationStatusIs#'
				</cfif>
		</cfquery>
		<cflocation addtoken="false" url="Locality.cfm?action=editCollEvnt&collecting_event_id=#collecting_event_id#">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "editCollEvnt">
<cfset title="Edit Collecting Event">
<cfoutput>
      <cfquery name="locDet" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
    	select
			higher_geog,
			spec_locality,
			locality_name,
			collecting_event.collecting_event_id,
			locality.locality_id,
			verbatim_locality,
			BEGAN_DATE,
			ENDED_DATE,
			VERBATIM_DATE,
			COLL_EVENT_REMARKS,
			Verbatim_coordinates,
			max_error_distance,
			max_error_units,
			collecting_event_name,
			locality.DEC_LAT loclat,
			locality.DEC_LONG loclong,
			LAT_DEG,
			DEC_LAT_MIN,
			LAT_MIN,
			LAT_SEC,
			LAT_DIR,
			LONG_DEG,
			DEC_LONG_MIN,
			LONG_MIN,
			LONG_SEC,
			LONG_DIR,
			locality.DATUM localityDATUM,
			collecting_event.DEC_LAT,
			collecting_event.DEC_LONG,
			collecting_event.DATUM,
			UTM_ZONE,
			UTM_EW,
			UTM_NS,
			ORIG_LAT_LONG_UNITS,
			caclulated_dlat,
			calculated_dlong,
			MINIMUM_ELEVATION,
			MAXIMUM_ELEVATION,
			ORIG_ELEV_UNITS,
			MIN_DEPTH,
			MAX_DEPTH,
			DEPTH_UNITS,
			LOCALITY_REMARKS,
			georeference_source,
			georeference_protocol
		from
			locality,
			geog_auth_rec,
			collecting_event
		where
			locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id and
			locality.locality_id=collecting_event.locality_id and
			collecting_event.collecting_event_id=<cfqueryparam value = "#collecting_event_id#" CFSQLType = "CF_SQL_INTEGER">
    </cfquery>
	<cfinvoke component="component.functions" method="getEventContents" returnvariable="contents">
	    <cfinvokeargument name="collecting_event_id" value="#collecting_event_id#">
	</cfinvoke>

	#contents#
	<br>
	<div style="border:5px solid red; background-color:red;">
		<br>Red is scary. This form is dangerous. Make sure you know what it's doing before you get all clicky.
		<cfquery name="vstat" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				verificationstatus,
				guid_prefix,
				count(*) c
			from
				specimen_event,
				cataloged_item,
				collection
			where
				specimen_event.collection_object_id=cataloged_item.collection_object_id and
				cataloged_item.collection_id=collection.collection_id and
				specimen_event.collecting_event_id=#locDet.collecting_event_id#
			group by
				verificationstatus,
				guid_prefix
		</cfquery>
		<label for="dfs">"Your" specimens in this collecting event:</label>
		<table id="dfs" border>
			<tr>
				<th>Collection</th>
				<th>VerificationStatus</th>
				<th>NumberSpecimenEvents</th>
			</tr>
			<cfloop query="vstat">
				<tr>
					<td>#guid_prefix#</td>
					<td>#verificationstatus#</td>
					<td>#c#</td>
				</tr>
			</cfloop>
		</table>
		<form name="x" method="post" action="Locality.cfm">
		    <input type="hidden" name="collecting_event_id" value="#locDet.collecting_event_id#">
	    	<input type="hidden" name="action" value="updateAllVerificationStatus">
	    	<span class="likeLink" onClick="getDocs('lat_long','verification_status')">[ verificationstatus documentation ]</span>
			<label for="VerificationStatus">
				Mass-update specimen-events in this collecting event to.....
			</label>
			<select name="VerificationStatus" id="verificationstatus" size="1" class="reqdClr">
				<option value=""></option>
				<cfloop query="ctVerificationStatus">
					<option value="#VerificationStatus#">#VerificationStatus#</option>
				</cfloop>
			</select>
			<label for="VerificationStatusIs">
				.....where current verificationstatus IS (leave blank to get everything)
			</label>
			<select name="VerificationStatusIs" id="VerificationStatusIs" size="1" class="reqdClr">
				<option value=""></option>
				<cfloop query="ctVerificationStatus">
					<option value="#VerificationStatus#">#VerificationStatus#</option>
				</cfloop>
			</select>
			where
			<br>
			<input type="submit" class="lnkBtn" value="Mass-update specimen-events">
		</form>
	</div>
	<cfform name="locality" method="post" action="Locality.cfm">
		<table width="100%"><tr><td valign="top">
			<h4>Edit this Collecting Event:</h4>
		    	<input type="hidden" name="action" value="saveCollEventEdit">
			    <input type="hidden" name="collecting_event_id" value="#locDet.collecting_event_id#">
				<input type="hidden" name="collection_object_id" value="#collection_object_id#">
				<input type="hidden" name="locality_id" id="locality_id" value="#locDet.locality_id#">
				<label for="verbatim_locality" class="likeLink" onclick="getDocs('collecting_event','verbatim_locality')">
					Verbatim Locality
				</label>
				<input type="text" name="verbatim_locality" id="verbatim_locality" value='#stripQuotes(locDet.verbatim_locality)#' size="50">
				<div id="specific_locality" style="display:none;border:2px solid red;">
					<label for="picked_spec_locality">
						If you're seeing this, you've picked the below specloc and havne't saved changes. Save to refresh
					 	locality information in the right pane and get rid of this annoying red box.
					</label>
					<input type="text" name="picked_spec_locality" id="picked_spec_locality" size="75" >
				</div>
				<label for="verbatim_date" class="likeLink" onclick="getDocs('collecting_event','verbatim_date')">
					Verbatim Date
				</label>
				<input type="text" name="VERBATIM_DATE" id="verbatim_date" value="#locDet.VERBATIM_DATE#" class="reqdClr">
				<table>
					<tr>
						<td>
							<label for="began_date" class="likeLink" onclick="getDocs('collecting_event','began_date')">
								Began Date/Time
							</label>
							<input type="text" name="began_date" id="began_date" value="#locDet.began_date#" size="20">
						</td>
						<td>
							<label for="ended_date" class="likeLink" onclick="getDocs('collecting_event','ended_date')">
								Ended Date/Time
							</label>
							<input type="text" name="ended_date" id="ended_date" value="#locDet.ended_date#" size="20">
						</td>
					</tr>
				</table>
				<label for="coll_event_remarks">Collecting Event Remark</label>
				<input type="text" name="coll_event_remarks" id="coll_event_remarks" value="#stripQuotes(locDet.COLL_EVENT_REMARKS)#" size="50">
				<label for="collecting_event_name">Collecting Event Nickname</label>
				<input type="text" name="collecting_event_name" id="collecting_event_name" value="#locDet.collecting_event_name#" size="50">
				<cfif len(locDet.collecting_event_name) is 0>
					<span class="infoLink" onclick="$('##collecting_event_name').val('#CreateUUID()#');">create GUID</span>
				</cfif>
				<label>Verbatim Coordinates (These are NOT necessarily the same as the mappable coordinate
				data given for Locality. Entering verbatim coordinates and picking an appropriate locality are separate tasks.)</label>
				<script>
					function useLocCoords(lat,lon,datum) {
						showLLFormat('decimal degrees');
						$("##DEC_LAT").val(lat);
						$("##DEC_LONG").val(lon);
						$("##datum").val(datum);
					}
					function showLLFormat(orig_units) {
						$("##dd").hide();
						$("##dms").hide();
						$("##dmm").hide();
						$("##utm").hide();
						<!----
						$("##DEC_LAT").val('');
						$("##DEC_LONG").val('');
						$("##LAT_DEG").val('');
						$("##LAT_MIN").val('');
						$("##LAT_SEC").val('');
						$("##LAT_DIR").val('');
						$("##LONG_DEG").val('');
						$("##LONG_MIN").val('');
						$("##LONG_SEC").val('');
						$("##LONG_DIR").val('');
						$("##dmLAT_DEG").val('');
						$("##DEC_LAT_MIN").val('');
						$("##dmLAT_DIR").val('');
						$("##dmLONG_DEG").val('');
						$("##DEC_LONG_MIN").val('');
						$("##dmLONG_DIR").val('');
						$("##UTM_ZONE").val('');
						$("##UTM_EW").val('');
						$("##UTM_NS").val('');
						---->
						if (orig_units == 'decimal degrees') {
							$("##dd").show();
						}
						else if (orig_units == 'UTM') {
							$("##utm").show();
						}
						else if (orig_units == 'degrees dec. minutes') {
							$("##dmm").show();
						}
						else if (orig_units == 'deg. min. sec.') {
							$("##dms").show();
						}
						$("##orig_lat_long_units").val(orig_units);
					}
				</script>

				<div style="border:2px solid black">
					<label for="orig_lat_long_units">Coordinate Units</label>
					<select name="orig_lat_long_units" id="orig_lat_long_units" size="1" class="reqdClr" onchange="showLLFormat(this.value);">
						<option value="">none</option>
						<cfloop query="ctlat_long_units">
							<option
								<cfif ctlat_long_units.orig_lat_long_units is locDet.orig_lat_long_units> selected="selected" </cfif>
								value="#ctlat_long_units.orig_lat_long_units#">#ctlat_long_units.orig_lat_long_units#</option>
						</cfloop>
					</select>
					<label for="datum">Datum</label>
					<select name="datum" id="datum" size="1" class="reqdClr">
						<option value="">none</option>
						<cfloop query="ctdatum">
							<option
								<cfif ctdatum.datum is locDet.datum> selected="selected" </cfif>
								value="#ctdatum.datum#">#ctdatum.datum#</option>
						</cfloop>
					</select>
					<table id="dd" style="display:none;">
						<tr>
							<td>
								<label for="DEC_LAT">Decimal Latitude</label>
								<input type="text" name="DEC_LAT" id="DEC_LAT" value="#locDet.DEC_LAT#" size="10">
							</td>
							<td>
								<label for="DEC_LONG">Decimal Longitude</label>
								<input type="text" name="DEC_LONG" id="DEC_LONG" value="#locDet.DEC_LONG#" size="10">
							</td>
						</tr>
					</table>
					<table id="dms" style="display:none;">
						<tr>
							<td>
								<label for="LAT_DEG">Degrees Latitude</label>
								<input type="text" name="LAT_DEG" id="LAT_DEG" value="#locDet.LAT_DEG#" size="10">
							</td>
							<td>
								<label for="LAT_MIN">Minutes Latitude</label>
								<input type="text" name="LAT_MIN" id="LAT_MIN" value="#locDet.LAT_MIN#" size="10">
							</td>
							<td>
								<label for="LAT_SEC">Seconds Latitude</label>
								<input type="text" name="LAT_SEC" id="LAT_SEC" value="#locDet.LAT_SEC#" size="10">
							</td>
							<td>
								<label for="LAT_DIR">Latitude Direction</label>
								<select name="LAT_DIR" id="LAT_DIR">
									<option></option>
									<option <cfif locDet.LAT_DIR is "N">selected="selected" </cfif> value="N">N</option>
									<option <cfif locDet.LAT_DIR is "S">selected="selected" </cfif> value="S">S</option>
								</select>
							</td>
							<td>
								<label for="LONG_DEG">Degrees Longitude</label>
								<input type="text" name="LONG_DEG" id="LONG_DEG" value="#locDet.LONG_DEG#" size="10">
							</td>
							<td>
								<label for="LONG_MIN">Minutes Longitude</label>
								<input type="text" name="LONG_MIN" id="LONG_MIN" value="#locDet.LONG_MIN#" size="10">
							</td>
							<td>
								<label for="LONG_SEC">Seconds Longitude</label>
								<input type="text" name="LONG_SEC" id="LONG_SEC" value="#locDet.LONG_SEC#" size="10">
							</td>
							<td>
								<label for="LONG_DIR">Longitude Direction</label>
								<select name="LONG_DIR" id="LONG_DIR">
									<option></option>
									<option <cfif locDet.LONG_DIR is "W">selected="selected" </cfif> value="W">W</option>
									<option <cfif locDet.LONG_DIR is "E">selected="selected" </cfif> value="E">E</option>
								</select>
							</td>
						</tr>
					</table>

					<table id="dmm" style="display:none;">
						<tr>
							<td>
								<label for="dmLAT_DEG">Degrees Latitude</label>
								<input type="text" name="dmLAT_DEG" id="dmLAT_DEG" value="#locDet.LAT_DEG#" size="10">
							</td>
							<td>
								<label for="DEC_LAT_MIN">Decimal Latitude Minutes</label>
								<input type="text" name="DEC_LAT_MIN" id="DEC_LAT_MIN" value="#locDet.DEC_LAT_MIN#" size="10">
							</td>
							<td>
								<label for="dmLAT_DIR">Latitude Direction</label>
								<select name="dmLAT_DIR" id="dmLAT_DIR">
									<option></option>
									<option <cfif locDet.LAT_DIR is "N">selected="selected" </cfif> value="N">N</option>
									<option <cfif locDet.LAT_DIR is "S">selected="selected" </cfif> value="S">S</option>
								</select>
							</td>
							<td>
								<label for="dmLONG_DEG">Degrees Longitude</label>
								<input type="text" name="dmLONG_DEG" id="dmLONG_DEG" value="#locDet.LONG_DEG#" size="10">
							</td>
							<td>
								<label for="DEC_LONG_MIN">Decimal Longitude Minutes</label>
								<input type="text" name="DEC_LONG_MIN" id="DEC_LONG_MIN" value="#locDet.DEC_LONG_MIN#" size="10">
							</td>
							<td>
								<label for="dmLONG_DIR">Degrees Longitude</label>
								<select name="dmLONG_DIR" id="dmLONG_DIR">
									<option></option>
									<option <cfif locDet.LONG_DIR is "W">selected="selected" </cfif> value="W">W</option>
									<option <cfif locDet.LONG_DIR is "E">selected="selected" </cfif> value="E">E</option>
								</select>
							</td>
						</tr>
					</table>

					<table id="utm" style="display:none;">
						<tr>
							<td>
								<label for="UTM_ZONE">UTM Zone</label>
								<input type="text" name="UTM_ZONE" id="UTM_ZONE" value="#locDet.UTM_ZONE#" size="10">
							</td>
							<td>
								<label for="UTM_EW">ETM East or West</label>
								<input type="text" name="UTM_EW" id="UTM_EW" value="#locDet.UTM_EW#" size="10">
							</td>

							<td>
								<label for="UTM_NS">UTM North or South</label>
								<input type="text" name="UTM_NS" id="UTM_NS" value="#locDet.UTM_NS#" size="10">
							</td>
						</tr>
					</table>
					<cfif len(locDet.loclat) gt 0>
						<div style="border:1px solid black;margin:.5em;padding:.5em">
							Locality coordinates are format <strong>decimal degrees</strong>, <strong>#locDet.loclat#</strong>/<strong>#locDet.loclong#</strong> datum <strong>#locDet.localityDATUM#</strong>
							<input type="button" onclick="useLocCoords('#locDet.loclat#','#locDet.loclong#','#locDet.localityDATUM#');"
								 style="insBtn" value="Use Locality coordinates for this event"></button>
						</div>
					</cfif>
				</div>

				<script>
					showLLFormat('#locDet.orig_lat_long_units#');
				</script>
		        <br>
				<input type="button" value="Save" class="savBtn" onClick="locality.action.value='saveCollEventEdit';locality.submit();">
					<input type="button" value="Quit" class="qutBtn" onClick="document.location='Locality.cfm';">
				<input type="button" value="Delete" class="delBtn"
					onClick="document.location='Locality.cfm?Action=deleteCollEvent&collecting_event_id=#locDet.collecting_event_id#';">
				<input type="button" value="Clone Event and Locality" class="insBtn"
					onClick="locality.action.value='cloneEventAndLocality';locality.submit();">
				<input type="button" value="Clone Event (new event under this locality)" class="insBtn"
					onClick="locality.action.value='cloneEventWithoutLocality';locality.submit();">


					<!---
				<cfset dLoc="Locality.cfm?action=newCollEvent&locality_id=#locDet.locality_id#&verbatim_locality=#locDet.verbatim_locality#&began_date=#locDet.began_date#&ended_date=#locDet.began_date#&verbatim_date=#locDet.verbatim_date#&coll_event_remarks=#locDet.coll_event_remarks#&collecting_source=#locDet.collecting_source#&collecting_method=#locDet.collecting_method#&habitat_desc=#locDet.habitat_desc#">
				<input type="button" value="Create Clone" class="insBtn" onClick="document.location='#dLoc#';">
				---->
		</td>
		<td valign="top"><!---------- right side ------------>
			<h4>
				Locality
				<a style="font-size:small;" href="/editLocality.cfm?locality_id=#locDet.locality_id#" target="_top">[ Edit Locality ]</a>
				<input type="button" value="Pick New Locality for this Collecting Event" class="picBtn"
					onclick="$('##specific_locality').show();
					LocalityPick('locality_id','picked_spec_locality','locality'); return false;" >

			</h4>
			<ul>
				<li>Higher Geog: #locDet.higher_geog#</li>
				<cfif len(locDet.locality_name) gt 0>
					<li>Locality Nickname: #locDet.locality_name#</li>
				</cfif>
				<cfif len(locDet.SPEC_LOCALITY) gt 0>
					<li>Specific Locality: #locDet.SPEC_LOCALITY#</li>
				</cfif>
				<cfif len(locDet.ORIG_ELEV_UNITS) gt 0>
					<li>Elevation: #locDet.MINIMUM_ELEVATION#-#locDet.MAXIMUM_ELEVATION# #locDet.ORIG_ELEV_UNITS#</li>
				</cfif>
				<cfif len(locDet.DEPTH_UNITS) gt 0>
					<li>Depth: #locDet.MIN_DEPTH#-#locDet.MAX_DEPTH# #locDet.DEPTH_UNITS#</li>
				</cfif>
				<cfif len(locDet.LOCALITY_REMARKS) gt 0>
					<li>Remark: #locDet.LOCALITY_REMARKS#</li>
				</cfif>
			</ul>

			<cfif len(locDet.loclat) gt 0>
				<cfinvoke component="component.functions" method="getMap" returnvariable="contents">
					<cfinvokeargument name="locality_id" value="#locDet.locality_id#">
				</cfinvoke>
				#contents#
				<div style="font-size:small;">
					<br>#locDet.loclat# / #locDet.loclong#
					<br>Datum: #locDet.DATUM#
					<br>Error : #locDet.MAX_ERROR_DISTANCE# #locDet.MAX_ERROR_UNITS#
					<br>Georeference Source : #locDet.georeference_source#
					<br>Georeference Protocol : #locDet.georeference_protocol#
				</div>
			</cfif>
		</td></tr></table>
	</cfform>
	<hr>
	<cfif isdefined("session.roles") and session.roles contains "manage_media">
		<span class="likeLink" onclick="addMedia('collecting_event_id','#collecting_event_id#');">Attach/Upload Media</span>
	</cfif>
	<div id="colEventMedia"></div>

	<script>
		getMedia('collecting_event','#collecting_event_id#','colEventMedia','5','1');
	</script>
  </cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "newCollEvent">
	<!--- create new empty collecting event, redirect to edit it ---->
	<cfquery name="nextColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select sq_collecting_event_id.nextval nextColl from dual
	</cfquery>
	<cfquery name="newCollEvent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		INSERT INTO collecting_event (
			COLLECTING_EVENT_ID,
			LOCALITY_ID
		) values (
			#nextColl.nextColl#,
			#locality_id#
		)
	</cfquery>
	<cflocation addtoken="no" url="Locality.cfm?Action=editCollEvnt&collecting_event_id=#nextColl.nextColl#">
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "cloneEventAndLocality">
	<cfoutput>
		<cfquery name="nextColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select sq_collecting_event_id.nextval nextColl from dual
		</cfquery>
		<cfquery name="newLocality" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			INSERT INTO locality (
				LOCALITY_ID,
				GEOG_AUTH_REC_ID,
				SPEC_LOCALITY,
				DEC_LAT,
				DEC_LONG,
				MINIMUM_ELEVATION,
				MAXIMUM_ELEVATION,
				ORIG_ELEV_UNITS,
				MIN_DEPTH,
				MAX_DEPTH,
				DEPTH_UNITS,
				MAX_ERROR_DISTANCE,
				MAX_ERROR_UNITS,
				DATUM,
				LOCALITY_REMARKS,
				GEOREFERENCE_SOURCE,
				GEOREFERENCE_PROTOCOL,
				LOCALITY_NAME
			) (
				select
					sq_locality_id.nextval,
					GEOG_AUTH_REC_ID,
					SPEC_LOCALITY,
					DEC_LAT,
					DEC_LONG,
					MINIMUM_ELEVATION,
					MAXIMUM_ELEVATION,
					ORIG_ELEV_UNITS,
					MIN_DEPTH,
					MAX_DEPTH,
					DEPTH_UNITS,
					MAX_ERROR_DISTANCE,
					MAX_ERROR_UNITS,
					DATUM,
					LOCALITY_REMARKS,
					GEOREFERENCE_SOURCE,
					GEOREFERENCE_PROTOCOL,
					LOCALITY_NAME
				from
					locality
				where
					locality_id=#locality_id#
			)
		</cfquery>
		<cfquery name="newCollEvent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			INSERT INTO collecting_event (
				COLLECTING_EVENT_ID,
				LOCALITY_ID,
				VERBATIM_DATE,
				VERBATIM_LOCALITY,
				COLL_EVENT_REMARKS,
				BEGAN_DATE,
				ENDED_DATE,
				VERBATIM_COORDINATES,
				COLLECTING_EVENT_NAME,
				LAT_DEG,
				DEC_LAT_MIN,
				LAT_MIN,
				LAT_SEC,
				LAT_DIR,
				LONG_DEG,
				DEC_LONG_MIN,
				LONG_MIN,
				LONG_SEC,
				LONG_DIR,
				DEC_LAT,
				DEC_LONG,
				DATUM,
				UTM_ZONE,
				UTM_EW,
				UTM_NS,
				ORIG_LAT_LONG_UNITS
			) (
				select
					#nextColl.nextColl#,
					sq_locality_id.currval,
					VERBATIM_DATE,
					VERBATIM_LOCALITY,
					COLL_EVENT_REMARKS,
					BEGAN_DATE,
					ENDED_DATE,
					VERBATIM_COORDINATES,
					COLLECTING_EVENT_NAME,
					LAT_DEG,
					DEC_LAT_MIN,
					LAT_MIN,
					LAT_SEC,
					LAT_DIR,
					LONG_DEG,
					DEC_LONG_MIN,
					LONG_MIN,
					LONG_SEC,
					LONG_DIR,
					DEC_LAT,
					DEC_LONG,
					DATUM,
					UTM_ZONE,
					UTM_EW,
					UTM_NS,
					ORIG_LAT_LONG_UNITS
				from
					collecting_event
				where
					collecting_event_id=#collecting_event_id#
			)
		</cfquery>
		<cflocation addtoken="no" url="Locality.cfm?Action=editCollEvnt&collecting_event_id=#nextColl.nextColl#">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "cloneEventWithoutLocality">
<cfoutput>
	<cfquery name="nextColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select sq_collecting_event_id.nextval nextColl from dual
	</cfquery>
	<cfquery name="newCollEvent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			INSERT INTO collecting_event (
				COLLECTING_EVENT_ID,
				LOCALITY_ID,
				VERBATIM_DATE,
				VERBATIM_LOCALITY,
				COLL_EVENT_REMARKS,
				BEGAN_DATE,
				ENDED_DATE,
				VERBATIM_COORDINATES,
				COLLECTING_EVENT_NAME,
				LAT_DEG,
				DEC_LAT_MIN,
				LAT_MIN,
				LAT_SEC,
				LAT_DIR,
				LONG_DEG,
				DEC_LONG_MIN,
				LONG_MIN,
				LONG_SEC,
				LONG_DIR,
				DEC_LAT,
				DEC_LONG,
				DATUM,
				UTM_ZONE,
				UTM_EW,
				UTM_NS,
				ORIG_LAT_LONG_UNITS
			) (
				select
					#nextColl.nextColl#,
					LOCALITY_ID,
					VERBATIM_DATE,
					VERBATIM_LOCALITY,
					COLL_EVENT_REMARKS,
					BEGAN_DATE,
					ENDED_DATE,
					VERBATIM_COORDINATES,
					decode(
						COLLECTING_EVENT_NAME,
						null,'',
						'clone of ' || COLLECTING_EVENT_NAME),
					LAT_DEG,
					DEC_LAT_MIN,
					LAT_MIN,
					LAT_SEC,
					LAT_DIR,
					LONG_DEG,
					DEC_LONG_MIN,
					LONG_MIN,
					LONG_SEC,
					LONG_DIR,
					DEC_LAT,
					DEC_LONG,
					DATUM,
					UTM_ZONE,
					UTM_EW,
					UTM_NS,
					ORIG_LAT_LONG_UNITS
				from
					collecting_event
				where
					collecting_event_id=#collecting_event_id#
			)
		</cfquery>
	<cflocation addtoken="no" url="Locality.cfm?Action=editCollEvnt&collecting_event_id=#nextColl.nextColl#">
</cfoutput>
</cfif>
<!-------------------------------------------------------------------->
<cfif action is "newLocality">
	<cfoutput>
		<h3>Create locality (edit to add more stuff)</h3>
		<form name="geog" action="Locality.cfm" method="post">
            <input type="hidden" name="Action" value="makenewLocality">
            <input type="hidden" name="geog_auth_rec_id">
			<label for="higher_geog">pick geography</label>
			<input type="text" name="higher_geog" class="readClr" size="50"  readonly="yes" >
			<input type="button" value="Pick" class="picBtn" onclick="GeogPick('geog_auth_rec_id','higher_geog','geog'); return false;">
           <label for="spec_locality">Specific Locality</label>
           <input type="text" name="spec_locality" id="spec_locality">
			<label for="minimum_elevation">Minimum Elevation</label>
            <input type="text" name="minimum_elevation" id="minimum_elevation">
			<label for="maximum_elevation">Maximum Elevation</label>
			<input type="text" name="maximum_elevation" id="maximum_elevation">
			<label for="orig_elev_units">Elevation Units</label>
			<select name="orig_elev_units" id="orig_elev_units" size="1">
				<option value=""></option>
                <cfloop query="ctElevUnit">
            	    <option value="#ctElevUnit.orig_elev_units#">#ctElevUnit.orig_elev_units#</option>
                </cfloop>
			</select>
			<label for="locality_remarks">Locality Remarks</label>
			<input type="text" name="locality_remarks" id="locality_remarks">
            <br><input type="submit" value="Save" class="savBtn">
		</form>
	</cfoutput>
</cfif>

<!---------------------------------------------------------------------------------------------------->
<cfif action is "deleteGeog">
<cfoutput>
	<cfquery name="isLocality" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select geog_auth_rec_id from locality where geog_auth_rec_id=#geog_auth_rec_id#
	</cfquery>
<cfif len(#isLocality.geog_auth_rec_id#) gt 0>
	There are active localities for this Geog. It cannot be deleted.
	<br><a href="Locality.cfm?Action=editGeog&geog_auth_rec_id=#geog_auth_rec_id#">Return</a> to editing.
	<cfabort>
<cfelseif len(#isLocality.geog_auth_rec_id#) is 0>
	<cfquery name="deleGeog" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	delete from geog_auth_rec where geog_auth_rec_id=#geog_auth_rec_id#
	</cfquery>
</cfif>
<cflocation addtoken="no" url="#cgi.HTTP_REFERER#">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "deleteCollEvent">
<cfoutput>
	<cfquery name="isSpec" datasource="uam_god">
		select specimen_event_id from specimen_event where collecting_event_id=#collecting_event_id#
	</cfquery>
<cfif len(#isSpec.specimen_event_id#) gt 0>
	There are specimens for this collecting event. It cannot be deleted. If you can't see them, perhaps they aren't in
	the collection list you've set in your preferences.
	<br><a href="Locality.cfm?Action=editCollEvent&collecting_event_id=#collecting_event_id#">Return</a> to editing.
	<cfabort>
<cfelseif len(#isSpec.specimen_event_id#) is 0>
	<cfquery name="deleCollEv" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	delete from collecting_event where collecting_event_id=#collecting_event_id#
	</cfquery>
</cfif>
You deleted a collecting event.
<br>Go back to <a href="Locality.cfm">localities</a>.
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "changeLocality">
<cfoutput>
	<cfquery name="upColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		UPDATE collecting_event SET locality_id=#locality_id# where collecting_event_id=#collecting_event_id#
	</cfquery>
		 <cfif not isdefined("collection_object_id")>
		 	<cfset collection_object_id=-1>
		 </cfif>
	<cflocation addtoken="no" url="Locality.cfm?collection_object_id=#collection_object_id#&action=editCollEvnt&collecting_event_id=#collecting_event_id#">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "saveCollEventEdit">
	<cfoutput>



	<cfquery name="upColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		UPDATE
			collecting_event
		SET
			locality_id=#locality_id#,
			BEGAN_DATE = '#BEGAN_DATE#',
			ENDED_DATE = '#ENDED_DATE#',
			VERBATIM_DATE = '#escapeQuotes(VERBATIM_DATE)#',
			verbatim_locality = '#escapeQuotes(verbatim_locality)#',
			COLL_EVENT_REMARKS = '#escapeQuotes(COLL_EVENT_REMARKS)#',
			collecting_event_name = '#escapeQuotes(collecting_event_name)#',
			orig_lat_long_units = '#escapeQuotes(orig_lat_long_units)#',
			<cfif orig_lat_long_units is "degrees dec. minutes">
				LAT_DEG=#dmLAT_DEG#,
				LONG_DEG=#dmLONG_DEG#,
				LAT_DIR = '#dmLAT_DIR#',
				LONG_DIR = '#dmLONG_DIR#',
				DEC_LAT_MIN=#DEC_LAT_MIN#,
				dec_long_min=#dec_long_min#,
				LAT_MIN=NULL,
				LAT_SEC=NULL,
				LONG_MIN=NULL,
				LONG_SEC=NULL,
				UTM_EW=NULL,
				UTM_NS=NULL,
				UTM_ZONE = NULL,
			<cfelseif orig_lat_long_units is "UTM">
				dec_lat=NULL,
				DEC_LONG=NULL,
				LAT_DEG=NULL,
				LONG_DEG=NULL,
				LAT_MIN=NULL,
				LAT_SEC=NULL,
				LONG_MIN=NULL,
				LONG_SEC=NULL,
				DEC_LAT_MIN=NULL,
				dec_long_min=NULL,
				UTM_EW=#UTM_EW#,
				UTM_NS=#UTM_NS#,
				UTM_ZONE = '#UTM_ZONE#',
			<cfelseif orig_lat_long_units is "decimal degrees">
				dec_lat=#dec_lat#,
				DEC_LONG=#DEC_LONG#,
				LAT_DEG=NULL,
				LAT_MIN=NULL,
				LAT_SEC=NULL,
				LONG_DEG=NULL,
				LONG_MIN=NULL,
				LONG_SEC=NULL,
				DEC_LAT_MIN=NULL,
				dec_long_min=NULL,
				UTM_EW=NULL,
				UTM_NS=NULL,
				UTM_ZONE = NULL,
				LAT_DIR=NULL,
				LONG_DIR=NULL,
			<cfelseif orig_lat_long_units is "deg. min. sec.">
				LAT_DEG=#LAT_DEG#,
				LAT_MIN=#LAT_MIN#,
				LAT_SEC=#LAT_SEC#,
				LONG_DEG=#LONG_DEG#,
				LONG_MIN=#LONG_MIN#,
				LONG_SEC=#LONG_SEC#,
				dec_lat=NULL,
				DEC_LONG=NULL,
				DEC_LAT_MIN=NULL,
				dec_long_min=NULL,
				UTM_EW=NULL,
				UTM_NS=NULL,
				UTM_ZONE = NULL,
			<cfelse>
				dec_lat=NULL,
				DEC_LONG=NULL,
				LAT_DEG=NULL,
				LAT_MIN=NULL,
				LAT_SEC=NULL,
				LONG_DEG=NULL,
				LONG_MIN=NULL,
				LONG_SEC=NULL,
				DEC_LAT_MIN=NULL,
				dec_long_min=NULL,
				UTM_EW=NULL,
				UTM_NS=NULL,
				UTM_ZONE = NULL,
				LAT_DIR=NULL,
				LONG_DIR=NULL,
			</cfif>
			datum = '#escapeQuotes(datum)#'
		where collecting_event_id = <cfqueryparam value = "#collecting_event_id#" CFSQLType = "CF_SQL_INTEGER">
	</cfquery>

	<cfif #cgi.HTTP_REFERER# contains "editCollEvnt">
		<cfset refURL = "#cgi.HTTP_REFERER#">
	<cfelse>
		<cfset refURL = "#cgi.HTTP_REFERER#?collection_object_id=#collection_object_id#&action=editCollEvnt&collecting_event_id=#collecting_event_id#">
	</cfif>
	<cflocation addtoken="no" url="#refURL#">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "saveGeogEdits">
	<cfoutput>
		<cfparam name="overrideSemiUniqueSource" default="false">
		<cfif overrideSemiUniqueSource is false>

			<cfquery name="iscrap" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select geog_auth_rec_id,higher_geog from geog_auth_rec where source_authority='#escapeQuotes(source_authority)#' and
					geog_auth_rec_id != #geog_auth_rec_id#
			</cfquery>
			<cfif iscrap.recordcount gt 0>
				<p>
					The source_authority you specified has been used in other geography entries. That's probably an indication of
					linking to the wrong thing. Please carefully review
					<a target="_blank" class="external" href="http://arctosdb.org/higher-geography/##guidelines">the higher geography creation guidelines</a>
					and consider editing your entry and/or the links below before proceeding.
				</p>
				Geography using #source_authority#:
				<ul>
					<cfloop query="iscrap">
						<li><a href="/Locality.cfm?Action=editGeog&geog_auth_rec_id=#geog_auth_rec_id#">#higher_geog#</a></li>
					</cfloop>
				</ul>
				<form name="editHG" id="editHG" method="post" action="Locality.cfm">
			        <input name="overrideSemiUniqueSource" id="overrideSemiUniqueSource" type="hidden" value="true">
			        <cfloop list="#form.FieldNames#" index="f">
				        <cfset thisVal=evaluate(f)>
						<input type="hidden" name="#f#" id="#f#" value="#thisVal#" size="60">
					</cfloop>
					<p>
						Use your back button, or <input type="submit" value="click here to force-use the specified source">
					</p>
				</form>
				<cfabort>
			</cfif>
		</cfif>
		<cftransaction>
			<cfquery name="edGe" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				UPDATE
					geog_auth_rec
				SET
					source_authority = '#escapeQuotes(source_authority)#',
					valid_catalog_term_fg = 1,
					continent_ocean = '#escapeQuotes(continent_ocean)#',
					country = '#escapeQuotes(country)#',
					state_prov = '#escapeQuotes(state_prov)#',
					county = '#escapeQuotes(county)#',
					quad = '#escapeQuotes(quad)#',
					feature = '#escapeQuotes(feature)#',
					island_group = '#escapeQuotes(island_group)#',
					island = '#escapeQuotes(island)#',
					sea = '#escapeQuotes(sea)#',
					geog_remark = '#escapeQuotes(geog_remark)#',
					wkt_polygon=<cfqueryparam value="#wkt_polygon#" cfsqltype="cf_sql_clob">
				where
					geog_auth_rec_id = #geog_auth_rec_id#
			</cfquery>
			<cfloop from ="1" to="#numGeogSrchTerms#" index="i">
				<cfset thisTerm=evaluate("new_geog_search_term_" & i)>
				<cfif len(thisTerm) gt 0>
					<cfquery name="ist1" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						insert into geog_search_term (geog_auth_rec_id,search_term) values (#geog_auth_rec_id#,trim('#escapeQuotes(thisTerm)#'))
					</cfquery>
				</cfif>
			</cfloop>
			<cfloop list="#form.FieldNames#" index="f">
				<cfif left(f,17) is "geog_search_term_">
					<cfset thisv=evaluate("form." & f)>
					<cfset thisID=replacenocase( f,"geog_search_term_","")>
					<cfif len(thisv) eq 0>
						<cfquery name="upst" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							delete from geog_search_term where geog_search_term_id=#thisID#
						</cfquery>
					<cfelse>
						<cfquery name="upst" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							update geog_search_term set search_term='#escapequotes(thisv)#' where geog_search_term_id=#thisID#
						</cfquery>
					</cfif>
				</cfif>
			</cfloop>
		</cftransaction>
		<cflocation addtoken="no" url="Locality.cfm?Action=editGeog&geog_auth_rec_id=#geog_auth_rec_id#">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "makeGeog">
	<cfoutput>
	<cfparam name="overrideSemiUniqueSource" default="false">
	<cfif overrideSemiUniqueSource is false>
		<cfquery name="iscrap" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select geog_auth_rec_id,higher_geog from geog_auth_rec where source_authority='#escapeQuotes(source_authority)#'
		</cfquery>
		<cfif iscrap.recordcount gt 0>
			<p>
				The source_authority you specified has been used in other geography entries. That's probably an indication of
				linking to the wrong thing. Please carefully review
				<a target="_blank" class="external" href="http://arctosdb.org/higher-geography/##guidelines">the higher geography creation guidelines</a>
				and consider editing your entry and/or the links below before proceeding.
			</p>
			Geography using #source_authority#:
			<ul>
				<cfloop query="iscrap">
					<li><a href="/Locality.cfm?Action=editGeog&geog_auth_rec_id=#geog_auth_rec_id#">#higher_geog#</a></li>
				</cfloop>
			</ul>
			<form name="editHG" id="editHG" method="post" action="Locality.cfm">
		        <input name="overrideSemiUniqueSource" id="overrideSemiUniqueSource" type="hidden" value="true">
		        <cfloop list="#form.FieldNames#" index="f">
			        <cfset thisVal=evaluate(f)>
					<input type="hidden" name="#f#" id="#f#" value="#thisVal#" size="60">
				</cfloop>
				<p>
					Use your back button, or <input type="submit" value="click here to force-use the specified source">
				</p>
			</form>
			<cfabort>
		</cfif>
	</cfif>


		<cfquery name="nextGEO" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select sq_geog_auth_rec_id.nextval nextid from dual
		</cfquery>
		<cfquery name="newGeog" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			INSERT INTO geog_auth_rec (
				geog_auth_rec_id
				<cfif len(#continent_ocean#) gt 0>
					,continent_ocean
				</cfif>
				<cfif len(#country#) gt 0>
					,country
				</cfif>
				<cfif len(#state_prov#) gt 0>
					,state_prov
				</cfif>
				<cfif len(#county#) gt 0>
					,county
				</cfif>
				<cfif len(#quad#) gt 0>
					,quad
				</cfif>
				<cfif len(#feature#) gt 0>
					,feature
				</cfif>
				<cfif len(#island_group#) gt 0>
					,island_group
				</cfif>
				<cfif len(#island#) gt 0>
					,island
				</cfif>
				<cfif len(#sea#) gt 0>
					,sea
				</cfif>
				,SOURCE_AUTHORITY,
				geog_remark
					)
				VALUES (
					#nextGEO.nextid#
					<cfif len(#continent_ocean#) gt 0>
					,'#escapeQuotes(continent_ocean)#'
				</cfif>
				<cfif len(#country#) gt 0>
					,'#escapeQuotes(country)#'
				</cfif>
				<cfif len(#state_prov#) gt 0>
					,'#escapeQuotes(state_prov)#'
				</cfif>
				<cfif len(#county#) gt 0>
					,'#escapeQuotes(county)#'
				</cfif>
				<cfif len(#quad#) gt 0>
					,'#escapeQuotes(quad)#'
				</cfif>
				<cfif len(#feature#) gt 0>
					,'#escapeQuotes(feature)#'
				</cfif>
				<cfif len(#island_group#) gt 0>
					,'#escapeQuotes(island_group)#'
				</cfif>
				<cfif len(#island#) gt 0>
					,'#escapeQuotes(island)#'
				</cfif>
				<cfif len(#sea#) gt 0>
					,'#escapeQuotes(sea)#'
				</cfif>
				,'#escapeQuotes(SOURCE_AUTHORITY)#',
				'#escapeQuotes(geog_remark)#'
			)
		</cfquery>
		<cflocation addtoken="no" url="Locality.cfm?Action=editGeog&geog_auth_rec_id=#nextGEO.nextid#">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "makenewLocality">
	<cfoutput>
		<cfquery name="nextLoc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select sq_locality_id.nextval nextLoc from dual
		</cfquery>
		<cfquery name="newLocality" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			INSERT INTO locality (
				LOCALITY_ID,
				GEOG_AUTH_REC_ID
				,MAXIMUM_ELEVATION
				,MINIMUM_ELEVATION
				,ORIG_ELEV_UNITS
				,SPEC_LOCALITY
				,LOCALITY_REMARKS
			)	VALUES (
				#nextLoc.nextLoc#,
				#GEOG_AUTH_REC_ID#
				<cfif len(#MAXIMUM_ELEVATION#) gt 0>
					,#MAXIMUM_ELEVATION#
				<cfelse>
					,NULL
				</cfif>
				<cfif len(#MINIMUM_ELEVATION#) gt 0>
					,#MINIMUM_ELEVATION#
				<cfelse>
					,NULL
				</cfif>
					,'#orig_elev_units#'
					,'#escapeQuotes(SPEC_LOCALITY)#'
					,'#escapeQuotes(LOCALITY_REMARKS)#')
		</cfquery>
		<cflocation addtoken="no" url="editLocality.cfm?locality_id=#nextLoc.nextLoc#">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "findCollEvent">
	<cfoutput>
		<cfset title="collecting events: search results">
		<form name="tools" method="post" action="Locality.cfm">
			<input type="hidden" name="action" value="" />
			<cf_findLocality type="event">
			Found #localityResults.recordcount# records
			<cfif localityResults.recordcount lt 1000>
				<a href="/bnhmMaps/bnhmPointMapper.cfm?locality_id=#valuelist(localityResults.locality_id)#" target="_blank">Map <strong>localities</strong> @BerkeleyMapper</a>
			<cfelse>
				1000 record limit on mapping, sorry...
			</cfif>
			<span class="likeLink" onclick="tools.action.value='csvCollEvent';tools.submit();">[ csv ]</span>
			<cfif isdefined("locality_id") and len(locality_id) gt 0>
				<a href="/tools/mergeDuplicateEvents.cfm?locality_id=#locality_id#">[ find and merge duplicates ]</a>
			</cfif>
<table border>
	<tr>
		<td><b>Geog</b></td>
		<td><b>Locality</b></td>
		<td><b>LocalityMap</b></td>
		<td><b>Verbatim&nbsp;Locality</b></td>
		<td><b>Began&nbsp;Date</b></td>
		<td><b>End&nbsp;Date</b></td>
		<td><b>Verb.&nbsp;Date</b></td>
	</tr>
	<cfloop query="localityResults">
		<input type="hidden" name="collecting_event_id" value="#collecting_event_id#" />
		<tr>
			<td> <div class="smaller">#higher_geog#
				(<a href="Locality.cfm?Action=editGeog&geog_auth_rec_id=#geog_auth_rec_id#">#geog_auth_rec_id#</a>)
				</div>
			</td>
			<td>
				 <div class="smaller">
				 	<cfif len(spec_locality) gt 0>Specific Locality: #spec_locality#</cfif>
				 	<cfif len(LOCALITY_NAME) gt 0><br>Locality Nickname: #LOCALITY_NAME#</cfif>
				 	<cfif len(DEC_LAT) gt 0>
					 	<br>Coordinates: #DEC_LAT# / #DEC_LONG#
					 	<br>Error: #MAX_ERROR_DISTANCE# #MAX_ERROR_UNITS#
					 	<br>Datum: #DATUM#
					 	<br>GeorefSource: #GEOREFERENCE_SOURCE#
					 	<br>GeorefProtocol: #GEOREFERENCE_PROTOCOL#
					</cfif>
				 	<cfif len(ORIG_ELEV_UNITS) gt 0><br>Elevation: #MINIMUM_ELEVATION#-#MAXIMUM_ELEVATION# #ORIG_ELEV_UNITS#</cfif>
				 	<cfif len(DEPTH_UNITS) gt 0><br>Depth: #MIN_DEPTH#-#MAX_DEPTH# #DEPTH_UNITS#</cfif>
				 	<cfif len(LOCALITY_REMARKS) gt 0><br>Remark: #LOCALITY_REMARKS#</cfif>
				 	 <cfif len(geolAtts) gt 0><br>[#geolAtts#]</cfif>
					<br><a href="editLocality.cfm?locality_id=#locality_id#">Edit #locality_id#</a>
					<br><a href="duplicateLocality.cfm?locality_id=#locality_id#">Find Duplicates</a>
				</div>
			</td>
			<td>
				<cfif len(DEC_LAT) gt 0>
					<cfinvoke component="component.functions" method="getMap" returnvariable="contents">
						<cfinvokeargument name="locality_id" value="#locality_id#">
					</cfinvoke>
					#contents#
				</cfif>
			</td>
			<td>
				<div class="smaller">
				 	#verbatim_locality#
					<br><a href="Locality.cfm?Action=editCollEvnt&collecting_event_id=#collecting_event_id#">Edit #collecting_event_id#</a>
					~ <a href="/tools/mergeDuplicateEvents.cfm?locality_id=#locality_id#">Find Duplicates</a>
					<cfif len(#Verbatim_coordinates#) gt 0>
						<br>#Verbatim_coordinates#
					</cfif>
				</div>
			</td>
			<td>#began_date#</td>
			<td>#ended_date#</td>
			<td>#verbatim_date#</td>
			<td nowrap>
				<cfquery name="spc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select count(distinct(collection_object_id)) c from specimen_event where collecting_event_id=#collecting_event_id#
				</cfquery>
				<a href="/SpecimenResults.cfm?collecting_event_id=#collecting_event_id#">#spc.c# specimens</a>
				<cfquery name="mc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select count(*) c from media_relations where media_relationship like '% collecting_event' and
					related_primary_key=#collecting_event_id#
				</cfquery>
				<br><a href="/MediaSearch.cfm?action=search&collecting_event_id=#collecting_event_id#">#mc.c# media</a>
			</td>
		</tr>
	</cfloop>
</table>
			<input type="button" value="Move These Collecting Events to new Locality" class="savBtn"
				onclick="tools.action.value='massMoveCollEvent';tools.submit();">
		</form>
	</cfoutput>
</cfif>


<!---------------------------------------------------------------------------------------------------->
<cfif action is "csvCollEvent">
	<cfoutput>
		<cfquery name="getData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				collecting_event.COLLECTING_EVENT_ID,
				VERBATIM_DATE,
				VERBATIM_LOCALITY,
				COLL_EVENT_REMARKS,
				BEGAN_DATE,
				ENDED_DATE,
				VERBATIM_COORDINATES,
				COLLECTING_EVENT_NAME,
				locality.locality_id,
				SPEC_LOCALITY,
				locality.DEC_LAT,
				locality.DEC_LONG,
				MINIMUM_ELEVATION,
				MAXIMUM_ELEVATION,
				ORIG_ELEV_UNITS,
				MIN_DEPTH,
				MAX_DEPTH,
				DEPTH_UNITS,
				MAX_ERROR_DISTANCE,
				MAX_ERROR_UNITS,
				locality.DATUM,
				LOCALITY_REMARKS,
				GEOREFERENCE_SOURCE,
				GEOREFERENCE_PROTOCOL,
				LOCALITY_NAME,
				S$ELEVATION,
				S$GEOGRAPHY,
				S$DEC_LAT,
				S$DEC_LONG,
				S$LASTDATE,
				geog_auth_rec.GEOG_AUTH_REC_ID,
				CONTINENT_OCEAN,
				COUNTRY,
				STATE_PROV,
				COUNTY,
				QUAD,
				FEATURE,
				ISLAND,
				ISLAND_GROUP,
				SEA,
				SOURCE_AUTHORITY,
				HIGHER_GEOG
			from
				collecting_event,
				locality,
				geog_auth_rec
			where
				collecting_event.locality_id=locality.locality_id and
				locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
				collecting_event.collecting_event_id in (#collecting_event_id#)
		</cfquery>
		<cfset clist="COLLECTING_EVENT_ID,VERBATIM_DATE,VERBATIM_LOCALITY,COLL_EVENT_REMARKS,BEGAN_DATE,ENDED_DATE,VERBATIM_COORDINATES,COLLECTING_EVENT_NAME,LOCALITY_ID,SPEC_LOCALITY,DEC_LAT,DEC_LONG,MINIMUM_ELEVATION,MAXIMUM_ELEVATION,ORIG_ELEV_UNITS,MIN_DEPTH,MAX_DEPTH,DEPTH_UNITS,MAX_ERROR_DISTANCE,MAX_ERROR_UNITS,DATUM,LOCALITY_REMARKS,GEOREFERENCE_SOURCE,GEOREFERENCE_PROTOCOL,LOCALITY_NAME,S$ELEVATION,S$GEOGRAPHY,S$DEC_LAT,S$DEC_LONG,S$LASTDATE,GEOG_AUTH_REC_ID,CONTINENT_OCEAN,COUNTRY,STATE_PROV,COUNTY,QUAD,FEATURE,ISLAND,ISLAND_GROUP,SEA,SOURCE_AUTHORITY,HIGHER_GEOG">

		<cfset fileDir = "#Application.webDirectory#">
		<cfset variables.encoding="UTF-8">
		<cfset fname = "downloadCollectingEvent.csv">
		<cfset variables.fileName="#Application.webDirectory#/download/#fname#">
		<cfscript>
			variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
			variables.joFileWriter.writeLine(ListQualify(clist,'"'));
		</cfscript>
		<cfloop query="getData">
			<cfset oneLine = "">
			<cfloop list="#clist#" index="c">
				<cfset thisData = evaluate("getData." & c)>
				<cfset thisData=replace(thisData,'"','""','all')>
				<cfif len(oneLine) is 0>
					<cfset oneLine = '"#thisData#"'>
				<cfelse>
					<cfset oneLine = '#oneLine#,"#thisData#"'>
				</cfif>
			</cfloop>
			<cfset oneLine = trim(oneLine)>
			<cfscript>
				variables.joFileWriter.writeLine(oneLine);
			</cfscript>
		</cfloop>
		<cfscript>
			variables.joFileWriter.close();
		</cfscript>
		<cflocation url="/download.cfm?file=#fname#" addtoken="false">
		<a href="/download/#fname#">Click here if your file does not automatically download.</a>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "massMoveCollEvent">
	<cfoutput>
		<cfset numCollEvents = listlen(collecting_event_id)>
		<cfloop list="#collecting_event_id#" index="c">
			<cfinvoke component="component.functions" method="getEventContents" returnvariable="contents">
			  	<cfinvokeargument name="collecting_event_id" value="#c#">
			  </cfinvoke>
			#contents#
			<br>
		</cfloop>


		<cfquery name="cd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
  			select * from collecting_event
				inner join locality on (collecting_event.locality_id = locality.locality_id)
				inner join geog_auth_rec on (locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id)
				where collecting_event.collecting_event_id IN (#collecting_event_id#)
  		</cfquery>
		<p></p>Current Data:
		<table border>
			<tr>
				<td>Spec Loc</td>
				<td>Geog</td>
				<td>Lat/Long</td>
			</tr>
			<cfloop query="cd">
				<tr>
					<td><a href="editLocality.cfm?locality_id=#locality_id#">#spec_locality#</a></td>
					<td>#higher_geog#</td>
					<td>#dec_lat# #dec_long#</td>
				</tr>
			</cfloop>
		</table>
		<p>
		<form name="mlc" method="post" action="Locality.cfm">
			<input type="hidden" name="action" value="mmCollEvnt2" />
			<input type="hidden" name="collecting_event_id" value="#collecting_event_id#" />
			<input type="hidden" name="locality_id" />
			<input type="button"
				value="Pick New Locality"
				class="picBtn"
				onclick="document.getElementById('theSpanSaveThingy').style.display='';LocalityPick('locality_id','spec_locality','mlc'); return false;" >
				<input type="text" name="spec_locality" readonly="readonly" border="0" size="60"/>
				<span id="theSpanSaveThingy" style="display:none;">
					<input type="submit" value="Save" />
				</span>
		</form>
		</p>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "mmCollEvnt2">
	<cfoutput>
		<cftransaction>
		<cfloop list="#collecting_event_id#" index="ceid">
			<cfquery name="upCollLoc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update collecting_event set locality_id = #locality_id#
			where collecting_event_id = #ceid#
			</cfquery>
		</cfloop>
		</cftransaction>
		<cflocation url="Locality.cfm?Action=findCollEvent&locality_id=#locality_id#" addtoken="false">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "csv">
	<cf_findLocality type="locality">
	<cfset  util = CreateObject("component","component.utilities")>
	<cfset csv = util.QueryToCSV2(Query=localityResults,Fields=localityResults.columnlist)>
	<cffile action = "write"
	    file = "#Application.webDirectory#/download/LocalityResults.csv"
    	output = "#csv#"
    	addNewLine = "no">
	<cflocation url="/download.cfm?file=LocalityResults.csv" addtoken="false">
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "findLocality">
	<script>
		jQuery(document).ready(function() {
			$.each($("div[id^='mapgohere-']"), function() {
				var theElemID=this.id;
				var theIDType=this.id.split('-')[1];
				var theID=this.id.split('-')[2];
			  	var ptl='/component/functions.cfc?method=getMap&showCaption=false&returnformat=plain&size=150x150&' + theIDType + '=' + theID;
			    jQuery.get(ptl, function(data){
					jQuery("#" + theElemID).html(data);
				});
			});
		});
	</script>

<cfoutput>
	<form name="csv" method="post" action="Locality.cfm">
		<input type="hidden" name="action" value="csv">
		<cfloop list="#StructKeyList(form)#" index="key">
			<cfif len(form[key]) gt 0 and key is not "action">
				<input type="hidden" name="#key#" value ="#form[key]#">
			</cfif>
		</cfloop>
		<input type="submit" value="getCSV">
	</form>
	<cf_findLocality type="locality">
	<cfset title="Locality Search Results">
	<cfif localityResults.recordcount lt 1000>
		<a href="/bnhmMaps/bnhmPointMapper.cfm?locality_id=#valuelist(localityResults.locality_id)#" target="_blank">BerkeleyMapper</a>
	<cfelse>
		1000 record limit on mapping, sorry...
	</cfif>
	<br /><strong>Your query found #localityResults.recordcount# localities.</strong>
	<br><a href="/duplicateLocality.cfm?action=detectdups&locality_id=#valuelist(localityResults.locality_id)#" target="_blank">Find Duplicates in Results</a>
	<table border id="t" class="sortable">
		<tr>
			<th><b>Geog</b></th>
	    	<th><b>Locality</b></th>
	    	<th><b>Map</b></th>
		</tr>
		<cfset i=1>
		<cfset getMap = CreateObject("component","component.functions")>
		<cfloop query="localityResults">
			<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
				<td>
					#higher_geog# <a href="Locality.cfm?Action=editGeog&geog_auth_rec_id=#geog_auth_rec_id#">(#geog_auth_rec_id#)</a>
				</td>
				<td>
					<div class="smaller">
					 	<cfif len(spec_locality) gt 0>Specific Locality: #spec_locality#</cfif>
					 	<cfif len(LOCALITY_NAME) gt 0><br>Locality Nickname: #LOCALITY_NAME#</cfif>
					 	<cfif len(DEC_LAT) gt 0>
						 	<br>Coordinates: #DEC_LAT# / #DEC_LONG#
						 	<br>Error: #MAX_ERROR_DISTANCE# #MAX_ERROR_UNITS#
						 	<br>Datum: #DATUM#
						 	<br>GeorefSource: #GEOREFERENCE_SOURCE#
						 	<br>GeorefProtocol: #GEOREFERENCE_PROTOCOL#
						</cfif>
					 	<cfif len(ORIG_ELEV_UNITS) gt 0><br>Elevation: #MINIMUM_ELEVATION#-#MAXIMUM_ELEVATION# #ORIG_ELEV_UNITS#</cfif>
					 	<cfif len(DEPTH_UNITS) gt 0><br>Depth: #MIN_DEPTH#-#MAX_DEPTH# #DEPTH_UNITS#</cfif>
					 	<cfif len(LOCALITY_REMARKS) gt 0><br>Remark: #LOCALITY_REMARKS#</cfif>
					 	 <cfif len(geolAtts) gt 0><br>[#geolAtts#]</cfif>
						<br><a href="/editLocality.cfm?locality_id=#locality_id#">Edit #locality_id#</a>
						<br><a href="/duplicateLocality.cfm?locality_id=#locality_id#">check for duplicates</a>
					</div>
				</td>
				<td>
					<div>
						<cfif len(dec_lat) gt 0 and len(dec_long) gt 0>
							<div id="mapgohere-locality_id-#locality_id#">
								<img src="/images/indicator.gif">
							</div>
							<br>
							#dec_lat# #dec_long#
							(#georeference_source# - #georeference_protocol#)
						</cfif>
					</div>
				</td>
			</tr>
			<cfset i=i+1>
		</cfloop>
	</table>
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "findGeog">
<cfset title="Geography Search Results">
<cfoutput>
<cf_findLocality type="geog">
<script src="/includes/sorttable.js"></script>

<table border id="t" class="sortable">
	<tr>
		<th>Geog ID</th>
		<th>Higher Geog</th>
		<th>Continent</th>
		<th>Country</th>
		<th>State</th>
		<th>County</th>
		<th>Quad</th>
		<th>Feature</th>
		<th>IslandGroup</th>
		<th>Island</th>
		<th>Sea</th>
		<th>Authority</th>
		<th>Remark</th>
		<th>SrchTerm</th>
	</tr>
<cfloop query="localityResults">
<tr>
	<td><a href="Locality.cfm?Action=editGeog&geog_auth_rec_id=#geog_auth_rec_id#">#geog_auth_rec_id#</a></td>
	<td>
		<!--- make this as input that looks like test to make copying easier --->
		<input style="border:none;" value="#higher_geog#" size="80" readonly="yes"/>
	</td>
	<td>#CONTINENT_OCEAN#</td>
	<td>#COUNTRY#</td>
	<td>#STATE_PROV#</td>
	<td>#COUNTY#</td>
	<td>#QUAD#</td>
	<td>#FEATURE#</td>
	<td>#ISLAND_GROUP#</td>
	<td>#ISLAND#</td>
	<td>#SEA#</td>
	<td>
		<cfif left(SOURCE_AUTHORITY,4) is 'http'>
			<a href="#SOURCE_AUTHORITY#" class="external" target="_blank">#SOURCE_AUTHORITY#</a>
		<cfelse>
			#SOURCE_AUTHORITY#
		</cfif>
	</td>
	<td>#geog_remark#</td>
	<cfquery name="searchterm" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select SEARCH_TERM from geog_search_term where geog_auth_rec_id=#geog_auth_rec_id# order by SEARCH_TERM
	</cfquery>
	<td valign="top">
		<cfloop query="searchterm">
			<div style="border:1px dashed gray; font-size:x-small;">
				#SEARCH_TERM#
			</div>
		</cfloop>
	</td>



  </tr>
</cfloop>
</cfoutput>
</table>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfinclude template="includes/_footer.cfm">