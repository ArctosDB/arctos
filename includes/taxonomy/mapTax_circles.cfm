failed experiment in error circles

<cfabort>

<style>
	#mapTax{
		width:40%;
		float:right;
	}
</style>
<cfoutput>
<cftry>


		<cfinclude template="/includes/functionLib.cfm">



s
	i like tatertots.
<!----

	<cfinclude template="/includes/_header.cfm">
		<cfinclude template="/includes/functionLib.cfm">



	---->
	<cfset internalPath="#Application.webDirectory#/cache/">
	<cfset externalPath="#Application.ServerRootUrl#/cache/">
	<cfif not isdefined("method")>
		<cfset method="">
	</cfif>
	<cfif method is "exact">
		<cfset fn="_#replace(scientific_name,' ','-','all')#.csv">
	<cfelse>
		<cfset fn="#replace(scientific_name,' ','-','all')#.csv">
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
		 		coordinateuncertaintyinmeters
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
		 		coordinateuncertaintyinmeters
		</cfquery>
		<cfif d.recordcount is 0>
			<cfabort>
		</cfif>
		<cfset variables.encoding="UTF-8">
		<cfset variables.fileName=internalPath & fn>
		<cfscript>
			variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
			//x='"c","locality_id","scientific_name","dec_lat","dec_long","datum","coordinateuncertaintyinmeters"';
			//variables.joFileWriter.writeLine(x);
		</cfscript>
		<cfloop query="d">
			<cfscript>
				x='"#c#","#locality_id#","#scientific_name#","#dec_lat#","#dec_long#","#datum#","#coordinateuncertaintyinmeters#"';
				variables.joFileWriter.writeLine(x);
			</cfscript>
		</cfloop>
		<cfscript>
			variables.joFileWriter.close();
		</cfscript>
	</cfif>
	<cffile action="READ" file="#internalPath#/#fn#" variable="fileContent">
	<cfset fileContent=replace(fileContent,"'","''","all")>
	<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />
	<!--- loop across the array, build JS for the map ---->
	<cfset theJS="">
	<cfloop from="1" to ="#ArrayLen(arrResult)#" index="o">
		<cfset c=arrResult[o][1]>
		<cfset locality_id=arrResult[o][2]>
		<cfset scientific_name=arrResult[o][3]>
		<cfset dec_lat=arrResult[o][4]>
		<cfset dec_long=arrResult[o][5]>
		<cfset datum=arrResult[o][6]>
		<cfset coordinateuncertaintyinmeters=arrResult[o][7]>
		<cfset theJS=theJS & 'var latLng#o# = new google.maps.LatLng(#dec_lat#, #dec_long#);'>
		<cfset theJS=theJS & "var marker#o# = new google.maps.Marker({position: latLng#o#,map: map,icon: 'https://maps.google.com/mapfiles/ms/icons/green-dot.png'});">
		<cfset theJS=theJS & 'var circleOptions = {center: latLng#o#,radius: Math.round(#coordinateuncertaintyinmeters#),map: map,editable: false};'>
		<cfset theJS=theJS & 'var circle = new google.maps.Circle(circleOptions);'>
		<cfset theJS=theJS & 'bounds.extend(latLng#o#);'>
	</cfloop>
	<script>


	jQuery(document).ready(function() {
 		var map;
			var defaultcenter = new google.maps.LatLng(49.496675, -102.65625);

 		var mapOptions = {
        	center: defaultcenter,
         	mapTypeId: google.maps.MapTypeId.ROADMAP
        };
        var bounds = new google.maps.LatLngBounds();
		function initialize() {
        	map = new google.maps.Map(document.getElementById("taxarangemap"), mapOptions);
      	}
		initialize();

#theJS#

		// center the map on the points
		map.fitBounds(bounds);
		// and zoom back out a bit, if the points will still fit
		// because the centering zooms WAY in if the points are close together

	});
	</script>

	<span style="font-size:smaller;color:red;">Encumbered records are excluded.</span>
		<div id="taxarangemap" style="width: 100%;; height: 400px;"></div>

	<span id="toggleExactmatch">
		<cfif method is "exact">
			Showing exact matches - <span class="likeLink" onclick="reloadThis('')"> show matches for '#scientific_name#%'</span>
		<cfelse>
			Showing fuzzy matches - <span class="likeLink" onclick="reloadThis('exact')"> show matches for exactly '#scientific_name#'</span>
		</cfif>
	</span>


	<cfcatch>
	<cfdump var=#cfcatch#>
	</cfcatch>

	</cftry>
</cfoutput>