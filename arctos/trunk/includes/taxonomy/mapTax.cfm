<style>
	#mapTax{
		width:40%;
		float:right;
	}
</style>
<cfoutput>
	<cfset internalPath="#Application.webDirectory#/cache/">
	<cfset externalPath="#Application.ServerRootUrl#/cache/">
	<cfif not isdefined("method")>
		<cfset method="">
	</cfif>
	<cfif method is "exact">
		<cfset fn="_#replace(scientific_name,' ','-','all')#.kml">
	<cfelse>
		<cfset fn="#replace(scientific_name,' ','-','all')#.kml">
	</cfif>
	<cfif not fileexists("#internalPath##fn#")>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		 	select 
		 		count(*) c,
		 		locality_id,
		 		scientific_name, 
		 		dec_lat,
		 		dec_long,
		 		datum,
		 		COORDINATEUNCERTAINTYINMETERS
		 	from filtered_flat
		 	where 
				dec_lat is not null and 
		 		dec_long is not null and
		 		<cfif method is "exact">
					scientific_name = '#scientific_name#'
				<cfelse>
					scientific_name like '#scientific_name#%'
				</cfif>
		 	group by
		 		locality_id,
		 	 	scientific_name, 
		 		dec_lat,
		 		dec_long,
		 		datum,
		 		COORDINATEUNCERTAINTYINMETERS
		</cfquery>
		<cfif d.recordcount is 0>
			<cfabort>
		</cfif>
		<cfset variables.encoding="UTF-8">
		<cfset variables.fileName=internalPath & fn>
		<cfscript>
			variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
			kml='<?xml version="1.0" encoding="UTF-8"?>' & chr(10) & 
				'<kml xmlns="http://earth.google.com/kml/2.2">' & chr(10) &
				chr(9) & '<Document>' & chr(10) &
				chr(9) & chr(9) & '<name>#scientific_name#</name>' & chr(10) &
				chr(9) & chr(9) & '<open>1</open>';
			variables.joFileWriter.writeLine(kml);      
		</cfscript>
		<cfloop query="d">
			<cfscript>
				kml=chr(9) & chr(9) & '<Placemark>' & chr(10) &
					chr(9) & chr(9) & chr(9) & '<name>#c# #scientific_name#</name>' & chr(10) &
	      			chr(9) & chr(9) & chr(9) & '<description>' & chr(10) &
			        chr(9) & chr(9) & chr(9) & chr(9) & '<![CDATA[' & chr(10) &
			        chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<a href="#application.serverRootUrl#/SpecimenResults.cfm?locality_id=#locality_id#&scientific_name=#scientific_name#">Arctos Specimen Records</a>' & chr(10) & 
			        chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<br><span style="font-size:smaller">Datum: #datum#; error: #COORDINATEUNCERTAINTYINMETERS# m</span>' & chr(10) &
			       	chr(9) & chr(9) & chr(9) & chr(9) & ' ]]>' & chr(10) &
			      	chr(9) & chr(9) & chr(9) & '</description>' & chr(10) &
					chr(9) & chr(9) & chr(9) & '<Point>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & '<coordinates>#dec_long#,#dec_lat#</coordinates>' & chr(10) &
					chr(9) & chr(9) &  chr(9) & '</Point>' & chr(10) &
					chr(9) & chr(9) & '</Placemark>';
				variables.joFileWriter.writeLine(kml);
			</cfscript>
		</cfloop>
		<cfscript>
			kml=chr(9) & '</Document>' & chr(10) &
				'</kml>';
			variables.joFileWriter.writeLine(kml);		
			variables.joFileWriter.close();
		</cfscript>
	</cfif>
	<span style="font-size:smaller;color:red;">Encumbered records are excluded.</span>
	<div id="taxarangemap" style="width: 100%;; height: 400px;"></div>
	<script language="javascript" type="text/javascript">
		jQuery(document.body).unload(function() {
			GUnload();
		});
		var map = new GMap2(document.getElementById("taxarangemap"));
		map.addControl(new GLargeMapControl());
		map.addControl(new GMapTypeControl());
		map.addMapType(G_PHYSICAL_MAP);
		map.addControl(new GScaleControl());
		map.enableScrollWheelZoom();
        map.setCenter(new GLatLng(89.5,0.1), 11); 
		var kmlfile='#externalPath##fn#';
 		geoxml = new GGeoXml(kmlfile);
		GEvent.addListener(geoxml,"load",function() {
			geoxml.gotoDefaultViewport(map);
		});
		map.addOverlay(geoxml);
		
		function reloadThis(method){
			$('##toggleExactmatch').html('<img src="/images/indicator.gif">');
			var ptl="/includes/taxonomy/mapTax.cfm?scientific_name=#scientific_name#&method=" + method;
			jQuery.get(ptl, function(data){
				 jQuery('##mapTax').html(data);
			})
		}	
	</script>
	<span id="toggleExactmatch">
		<cfif method is "exact">
			Showing exact matches - <span class="likeLink" onclick="reloadThis('')"> show matches for '#scientific_name#%'</span>
		<cfelse>
			Showing fuzzy matches - <span class="likeLink" onclick="reloadThis('exact')"> show matches for exactly '#scientific_name#'</span>
		</cfif>
	</span>
</cfoutput>