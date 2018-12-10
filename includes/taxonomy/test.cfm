	<cfquery name="cf_global_settings" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select
			google_client_id,
			google_private_key
		from cf_global_settings
	</cfquery>
	<cfhtmlhead text='<script src="https://maps.googleapis.com/maps/api/js?client=#cf_global_settings.google_client_id#&sensor=false" type="text/javascript"></script>'>




<script type='text/javascript' language="javascript" src='https://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js'></script>
<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.9.2/jquery-ui.min.js"></script>
<script type='text/javascript' language="javascript" src='/includes/ajax.min.js?v=10.3262'></script>
<link rel="stylesheet" href="https://code.jquery.com/ui/1.9.2/themes/base/jquery-ui.css" />
<link rel="stylesheet" href="/includes/style.min.css?v1236" />

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
		 	order by
		 		locality_id
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

<cfoutput>
#externalPath##fn#
	<span style="font-size:smaller;color:red;">Encumbered records are excluded.</span>
	<div id="taxarangemap" style="width: 100%;; height: 400px;"></div>
	<script language="javascript" type="text/javascript">
		jQuery(document).ready(function() {
	 		var map;
			var myLatLng = new google.maps.LatLng(49.496675, -102.65625);
			var mapOptions = {
			  zoom: 4,
			  center: myLatLng,
			  mapTypeId: google.maps.MapTypeId.ROADMAP
			}
        	map = new google.maps.Map(document.getElementById("taxarangemap"), mapOptions);
			var georssLayer = new google.maps.KmlLayer('https://arctos.database.museum/cache/Nicrophorus-vespilloides.kml?x=1');
			georssLayer.setMap(map);
		});
	</script>


</cfoutput>
<cffile
action = "read"
file = "#application.webDirectory#/cache/_Nicrophorus-vespilloides.kml"
variable = "x">

<cffile
action = "read"
file = "#application.webDirectory#/cache/test.kml"
variable = "f">

			<textarea>#f#</textarea>




<table border>
	<tr>
		<td>
			<textarea>#f#</textarea>
		</td>
		<td>
			<textarea>#x#</textarea>
		</td>
	</tr>
</table>

	<span id="toggleExactmatch">
		<cfif method is "exact">
			Showing exact matches - <span class="likeLink" onclick="loadTaxonomyMap('#scientific_name#')"> show matches for '#scientific_name#%'</span>
		<cfelse>
			Showing fuzzy matches - <span class="likeLink" onclick="loadTaxonomyMap('#scientific_name#','exact')"> show matches for exactly '#scientific_name#'</span>
		</cfif>
	</span>
</cfoutput>