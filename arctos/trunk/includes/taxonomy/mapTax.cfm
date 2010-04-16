<cfinclude template = "/includes/_frameHeader.cfm">
<style>
#mapTax{
border:2px solid red;
width:40%;
float:right;
}
</style>
<cfoutput>
	<cfset internalPath="#Application.webDirectory#/bnhmMaps/tabfiles/">
	<cfset externalPath="#Application.ServerRootUrl#/bnhmMaps/tabfiles/">
	<cfset fn="#replace(scientific_name,' ','-','all')#.kml">
	<cfif not fileexists("#internalPath##fn#")>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		 	select 
		 		count(*) c,
		 		locality_id,
		 		scientific_name, 
		 		dec_lat,
		 		dec_long 
		 	from flat
		 	where 
				dec_lat is not null and 
		 		dec_long is not null and
		 		flat.scientific_name like '#scientific_name#%'
		 	group by
		 		locality_id,
		 	 	scientific_name, 
		 		dec_lat,
		 		dec_long 
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
			        chr(9) & chr(9) & chr(9) & chr(9) & '<![CDATA[<a href="http://arctos.database.museum/SpecimenResults.cfm?locality_id=#locality_id#&scientific_name=#scientific_name#">Arctos Specimen Records</a>]]>' & chr(10) &
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
	<div id="map" style="width: 100%; height: 400px;"></div>
	<script language="javascript" type="text/javascript">
		jQuery(document.body).unload(function() {
			GUnload();
		});
		var map = new GMap2(document.getElementById("map"));
		map.addControl(new GLargeMapControl());
		map.addControl(new GMapTypeControl());
		map.addMapType(G_PHYSICAL_MAP);
		map.addControl(new GScaleControl());
		map.enableScrollWheelZoom();
        map.setCenter(new GLatLng(89.5,0.1), 11); 
var kmlfile='#externalPath##fn#';

 GEvent.addListener(geoxml,"load",function() {
    geoxml.gotoDefaultViewport(map);
  });



map.addOverlay(geoxml);



		
	</script>
</cfoutput>