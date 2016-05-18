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
	                	<textarea name="geog_remark" id="geog_remark" class="hugetextarea" rows="60" cols="10"></textarea>			</td>
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

		#map{
    width: 450px;
    height: 400px;
}

	</style>
<script>
	function clearTerm(id){
		$("#" + id).val('');
	}
	function asterisckificateisland(){
		$("#island").val("*" + $("#island").val());
	}

	jQuery(document).ready(function() {




/*
 		var map;

 		var mapOptions = {
        	center: new google.maps.LatLng("64, -148"),
         	mapTypeId: google.maps.MapTypeId.ROADMAP
        };

        var bounds = new google.maps.LatLngBounds();
		function initialize() {
        	map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);
      	}
		initialize();

*/
			/*

			var latLng1 = new google.maps.LatLng(64, -148);
			var marker1 = new google.maps.Marker({
			    position: latLng1,
			    map: map,
			    icon: 'http://maps.google.com/mapfiles/ms/icons/green-dot.png'
			});




			var circleOptions = {
	  			center: latLng1,
	  			radius: Math.round(600),
	  			map: map,
	  			editable: false
			};
			var circle = new google.maps.Circle(circleOptions);



bounds.extend(latLng1);
map.fitBounds(bounds);



			*/
		// add wkt if available

		/*
        var wkt=$("#wkt_polygon").val(); //this is your WKT string
        if (wkt.length>0){

        	console.log('going wkt...');
			//using regex, we will get the indivudal Rings
			var regex = /\(([^()]+)\)/g;
			var Rings = [];
			var results;
			while( results = regex.exec(wkt) ) {
			    Rings.push( results[1] );
			    console.log('added ring');
			}
			var ptsArray=[];
			var polyLen=Rings.length;
			//now we need to draw the polygon for each of inner rings, but reversed
			for(var i=0;i<polyLen;i++){
			    AddPoints(Rings[i]);
			    console.log('added polyring');
			}
			var poly = new google.maps.Polygon({
			    paths: ptsArray,
			    strokeColor: '#DC143C',
			    strokeOpacity: 0.8,
			    strokeWeight: 2,
			    fillColor: '#FF7F50',
			    fillOpacity: 0.35
			  });
			  poly.setMap(map);
        }
		//function to add points from individual rings, used in adding WKT to the map
		function AddPoints(data){
		    //first spilt the string into individual points
		    var pointsData=data.split(",");
		    //iterate over each points data and create a latlong
		    //& add it to the cords array
		    var len=pointsData.length;
		    for (var i=0;i<len;i++)
		    {
		        var xy=pointsData[i].trim().split(" ");
		        var pt=new google.maps.LatLng(xy[1],xy[0]);
		        ptsArray.push(pt);
		    }
		}

		*/




		// END add wkt if available
		// end map setup




var map;
var myOptions = {
    zoom: 9,
    center: new google.maps.LatLng(5,100.9),
    mapTypeId: 'terrain'
};
map = new google.maps.Map($('#map')[0], myOptions);

 var bounds = new google.maps.LatLngBounds();



//var wkt="POLYGON((100.54157334877087 5.124795579269911,100.50169157216737 5.175633231048347,100.48893060559693 5.190782519229377,100.48883685890004 5.190920674118928,100.48041685890006 5.206620683576352,100.48035625412166 5.206766524898229,100.48032538396345 5.206921338503033,100.48032543474828 5.207079174986367,100.48035640452454 5.207233968780704,100.48041710314108 5.207379771251712,100.48050519798412 5.207510979300314,100.48061730361823 5.20762255068534,100.48074911188677 5.20771019779251,100.4808955574719 5.207770552403195,100.4810510125519 5.2078012951316595,100.48120950307525 5.2078012445564505,100.48136493833998 5.2077704026211435,100.48151134505608 5.207709954559655,100.48164309689552 5.207622223348936,100.48175513070903 5.207510580439686,100.48184314109994 5.207379316194805,100.49022348868367 5.191753262740997,100.50293939440304 5.17665749276832,100.50295708150922 5.1766357380872146,100.55158138575345 5.114653464985341,100.61784836581363 5.047494669000269,100.63328064200411 5.045760273775513,100.63344538038619 5.045724117696659,100.63359900089658 5.045654696108101,100.63373481573457 5.045555031237853,100.63384691226155 5.045429461939012,100.64478691226155 5.030239472910412,100.64485714103375 5.030122067725934,100.64490643054278 5.029994524131959,100.64493336141338 5.029860514958455,100.64619300597558 5.018766440281411,100.89601933027687 4.76550530772389,100.90397540484798 4.76251382120199,100.904125498221 4.7624388147297605,100.90425680769607 4.762334529640712,100.90436366963635 4.762205463944471,100.91498366963637 4.746255474257608,100.9150580432529 4.746115668549328,100.91510356406134 4.74596407285823,100.91511847627667 4.745806534382425,100.91510220471923 4.745649129543159,100.9150553769999 4.7454979296113295,100.91497979931266 4.745358766531834,100.9148783867677 4.745237007978542,100.91475505095255 4.745137350316068,100.91461454905823 4.745063637454637,100.91446230038925 4.7450187125847965,100.9143041773355 4.745004308511336,100.91414627886799 4.745020980816285,100.91399469529519 4.74506808642927,100.91385527335358 4.745143808431712,100.91373339069273 4.745245226138226,100.89511556261954 4.764122863341007,100.89441924808347 4.764384677730915,100.92861460308248 4.729467265814491,100.94306861105032 4.717019660578351,100.94308862499464 4.717001837872207,100.9600648087706 4.70137140183913,100.97805150444233 4.690005163726286,101.0032978733881 4.688855369346559,101.02139744198907 4.698874409253193,101.02153571050398 4.698934873115156,101.02168284847642 4.698968658695525,101.02183372382656 4.698974587578459,101.02198307411716 4.698952452968966,101.02212569010408 4.698903026905675,101.0222565974315 4.698828033332999,101.02237123013421 4.698730087971819,101.02246558989572 4.698612607085813,101.03186692696475 4.684358662732975,101.04641937919912 4.681631913397546,101.04654522151539 4.6815976608810255,101.0466638985581 4.681543682997702,101.0626338985581 4.672663691919618,101.06265873346082 4.672649300079806,101.07193873346081 4.667049305582631,101.07206478644287 4.666955391993337,101.07217019642661 4.666838917858445,101.07225096922653 4.666704296595284,101.07230404420704 4.6665566292515965,101.07232741025584 4.66640151121859,101.07232018198869 4.666244820211681,101.07080124929709 4.655762184380661,101.06942217992568 4.64481956709879,101.06939272311594 4.6446829890795245,101.0693400432311 4.64455353405661,101.06926572348885 4.644435092618359,101.06457125429455 4.638224697426946,101.06319926512629 4.632065339533069,101.0631864279256 4.632015335107842,101.05965809799591 4.619901065378956,101.05729160630031 4.611301837098225,101.05827771116607 4.608078035110399,101.05837451798986 4.608017540493808,101.058489797227 4.607909126498835,101.05858164229866 4.607780378456879,101.0586465236503 4.607636244073435,101.05868194792791 4.607482262344451,101.05868655379639 4.607324350696963,101.05863655379638 4.60660435064062,101.05861127892128 4.606452707295678,101.05855757613483 4.606308606552095,101.05847739948697 4.606177291720301,101.0583736663157 4.606063540879937,101.05825015109548 4.605971493021525,101.05811134809807 4.605904497442384,101.05796230786196 4.605864991876384,101.05780845342177 4.60585441379272,101.05765538298354 4.605873148090809,101.05750866622635 4.605920513095127,101.05737364164183 4.60599478535917,101.05725522228572 4.606093262376247,101.05715771700969 4.6062123609150225,101.05708467367768 4.6063477474016885,101.05703875007214 4.60649449560441,101.05696615166936 4.606839338106436,101.05567666227104 4.611054977816131,101.05564623136308 4.611203092992834,101.05564409128449 4.611354267067325,101.05567031736118 4.611503179055542,101.05810031736118 4.6203331764030775,101.05810357207437 4.620344668666436,101.06162634972249 4.632439867617015,101.06303073487372 4.638744658859191,101.06308581972252 4.638907454598495,101.06317427651116 4.639054911411789,101.0678446649334 4.64523344260049,101.06919782007431 4.655970431325576,101.0691998180113 4.65598518148874,101.07064329274297 4.665947058557962,101.06183355569814 4.671263283392991,101.04599114859657 4.680072345516371,101.03123062080087 4.6828380888643055,101.03107509912326 4.682883713338254,101.030931837252 4.682959345378033,101.0308065956257 4.683061943874136,101.03070441010425 4.683187383417033,101.02152658363796 4.697102476341069,101.00388255801093 4.687335579811719,101.00374644848105 4.687275831277903,101.00360166061274 4.68724194258745,101.00345309409626 4.687235060553534,100.97776309409626 4.688405061901499,100.97762450889043 4.688423433455393,100.97749117130599 4.688465325320313,100.97736706846887 4.6885294848210455,100.95913706846886 4.700049496057161,100.95902137500535 4.700138148283603,100.9420012335367 4.715809084690873,100.9275313889497 4.728270349847366,100.92748140376511 4.728317234131123,100.89084289136436 4.765729386924607,100.88857903739637 4.7665805940663155,100.86875468604576 4.764747755821863,100.86852748525929 4.7647587762658,100.8479974852593 4.768688780791709,100.84779668516134 4.768755321284555,100.83633102855727 4.774306706231912,100.82703778821273 4.77294291672017,100.82687125841765 4.772935785811107,100.7928690382914 4.774982310566,100.7619067259743 4.772427068381073,100.76173502182992 4.772431140443018,100.7615680553451 4.772471265016521,100.76141336170892 4.772545631275547,100.76127792223743 4.772650883064091,100.7611678493072 4.772782270361311,100.6687278493072 4.910582361568241,100.66865301195101 4.91072185418806,100.66860697601827 4.910873227876582,100.6685915165044 4.911030646151936,100.66864137306756 4.972952505860876,100.66009346236922 4.9913004519727435,100.64595576422197 5.007756306956835,100.64586418982786 5.007887198342606,100.64580031240318 5.008033503784978,100.64576663858664 5.0081894820473565,100.64477291047628 5.016941706842589,100.61625125341138 5.0460532463404055,100.6130793579959 5.046409728012444,100.61291638011534 5.0464453024506675,100.61276420329115 5.046513443519312,100.61262930836556 5.0466112492457205,100.59598930836556 5.0615212630263375,100.59591729333239 5.061594575864115,100.58139729333239 5.078394589533011,100.5813745376085 5.078422128797729,100.568241718084 5.095052757503959,100.5558565329245 5.107692725364091,100.55190792815084 5.111630975719314,100.55184291849078 5.11170421172008,100.55150998857583 5.1121286259010175,100.50958140376511 5.154917596322795,100.50948245300847 5.155040676578281,100.50940948200127 5.155180602156629,100.50936528873167 5.155332007765464,100.50935156773907 5.155489087927182,100.50936884513898 5.155645819584137,100.50941645844956 5.155796193046173,100.509492581994 5.155934442424661,100.50959429690371 5.156055266717915,100.5097177030391 5.1561540330704085,100.50985806853575 5.156226954412539,100.51001001124239 5.156271234669731,100.51016770509305 5.1562851759732355,100.51032510350089 5.156268243762022,100.51047617120751 5.1562210872795635,100.51061511569779 5.156145514679759,100.51073660930729 5.156044423696323,100.54157334877087 5.124795579269911),(100.89871905240886 4.762767948943637,100.90896767267513 4.752376354194918,100.90316054789211 4.76109794021234,100.89871905240886 4.762767948943637),(100.64661349655054 5.015063009244003,100.64734548944385 5.008616000844607,100.66139423577802 4.992263705850945,100.66151334893807 4.99207906958164,100.67018334893807 4.973469079183367,100.67023954646196 4.9733033059172405,100.6702584834956 4.973129353908616,100.67020868057224 4.911274134430876,100.76224763699163 4.774072078648479,100.7927932740257 4.776592927682631,100.79290874158235 4.776594210842545,100.82688510588919 4.774549247104856,100.83634221178725 4.775937080726917,100.83650305821145 4.775944533666873,100.83666219668962 4.77592007401154,100.83681331483866 4.77586467197369,100.8484073218576 4.770251155446057,100.86871970000875 4.766362818665806,100.88843722762824 4.768185776370008,100.64661349655054 5.015063009244003),(100.89174944562149 4.767110780318271,100.89241584048753 4.766860216725576,100.83228546584598 4.827825906907718,100.89174944562149 4.767110780318271),(100.61964713897322 5.045671590739228,100.64435410761305 5.020630262940911,100.64335031023455 5.029471003274368,100.6327424559458 5.044199836724733,100.61964713897322 5.045671590739228),(100.57884271020993 5.084233488822919,100.58263439073833 5.079431891466035,100.59710904740169 5.062684368787789,100.61351808034122 5.047981338205527,100.61446663282223 5.047874732959801,100.57884271020993 5.084233488822919))";

var wkt=$("#wkt_polygon").val();



//using regex, we will get the indivudal Rings
var regex = /\(([^()]+)\)/g;
var Rings = [];
var results;
while( results = regex.exec(wkt) ) {
    Rings.push( results[1] );
}

var ptsArray=[];

var polyLen=Rings.length;

//now we need to draw the polygon for each of inner rings, but reversed
for(var i=0;i<polyLen;i++){
    AddPoints(Rings[i]);

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


  var scoords=$("#scoords").val();
  var arrSP = scoords.split( "|" );
	var points=[];


var geoid=$("#geog_auth_rec_id").val();

  for(var i=0;i<arrSP.length;i++){
  		//var latLng2 = new google.maps.LatLng($("#s_dollar_dec_lat").val(), $("#s_dollar_dec_long").val());
  		console.log(arrSP[i]);
		var xy=arrSP[i].split(",");
  		console.log('xy: ' + xy);

		var xyA=xy.toString().split(',');

		console.log('xyA: ' + xyA);

		var x=xyA[0];
		  		console.log('x: ' + x);
		var y=xyA[1];
  		console.log('y: ' + y);

		var thisrow="['" + xy + ",'/SpecimenResults.cfm?rcoords=" + xy + "']";
		console.log(thisrow);

//    	['name1', 59.9362384705039, 30.19232525792222, 12, 'www.google.com'],




  		var latLng2 = new google.maps.LatLng(x,y);

  			var marker2 = new google.maps.Marker({
		    position: latLng2,
		    url: '#Application.serverRootURL/SpecimenResults.cfm?rcoords=' + xy,
		    map: map,
		    icon: 'http://maps.google.com/mapfiles/ms/icons/red-dot.png'
		});

		console.log(marker2);



/*
		var x=xyA[0];









		*/

  	}






//function to add points from individual rings
function AddPoints(data){
    //first spilt the string into individual points
    var pointsData=data.split(",");


	//console.log('pointsData: ' + pointsData);


    //iterate over each points data and create a latlong
    //& add it to the cords array
    var len=pointsData.length;
    for (var i=0;i<len;i++)
    {


         var xy=pointsData[i].split(" ");



        var pt=new google.maps.LatLng(xy[1],xy[0]);


        ptsArray.push(pt);



        bounds.extend(pt);
    }


}


map.fitBounds(bounds);



	});

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
				round(dec_lat,2) || ',' || round(dec_long,2) rcords
			from
				locality
			where
				dec_lat is not null and
			 	geog_auth_rec_id=#geog_auth_rec_id#
		</cfquery>

		<cfdump var=#scoords#>

		<input type="hidden" id="scoords" value="#valuelist(scoords.rcords,"|")#">


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
	                	<label for="wkt_polygon">wkt_polygon</label>
	                	<textarea name="wkt_polygon" id="wkt_polygon" class="hugetextarea" rows="60" cols="10">#wkt_polygon#</textarea>
						<br>
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


			<br>imamap
	                	<div id="map-canvas"></div>
slashy


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
					geog_remark = '#escapeQuotes(geog_remark)#'
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