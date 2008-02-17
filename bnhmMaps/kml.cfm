<cfif isdefined("action") and #action# is "getFile">
<cfoutput>
	<cfheader name="Content-Disposition" value="attachment; filename=#f#">
	<cfcontent type="application/vnd.google-earth.kml+xml" file="#Application.webDirectory#/bnhmMaps/#f#">
</cfoutput>	
</cfif>
<!----------------------------------------------------------------->
<cfinclude  template="/includes/_header.cfm"> 
<cfinclude  template="/includes/functionLib.cfm"> 
<cffunction     name="kmlCircle"     access="public"    returntype="string" output="false">
     <cfargument
	     name="centerlat_form"
	     type="numeric"
	     required="true"/>
	<cfargument
	     name="centerlong_form"
	     type="numeric"
	     required="true"/>
	<cfargument
	     name="radius_form"
	     type="numeric"
	     required="true"/>
	<cfset retn = "
	<visibility>1</visibility>
	<Placemark>
	<name>Error</name>
	<visibility>1</visibility>
	<Style>
	<geomColor>ff0000ff</geomColor>
	<geomScale>1</geomScale></Style>
	<LineString>
	<coordinates>">
	<cfset lat = DegToRad(centerlat_form)>
	<cfset long = DegToRad(centerlong_form)>
	<cfset d = radius_form>
	<cfset d_rad=d/6378137>
	<cfloop from="0" to="360" index="i">
		<cfset radial = DegToRad(i)>
		<cfset lat_rad = asin(sin(lat)*cos(d_rad) + cos(lat)*sin(d_rad)*cos(radial))>
		<cfset dlon_rad = atan2(sin(radial)*sin(d_rad)*cos(lat),cos(d_rad)-sin(lat)*sin(lat_rad))>
		<cfset p="3.14">
		<cfset x=(long+dlon_rad + p)>
		<cfset y=(2*p)>
		<cfset lon_rad = ProperMod((long+dlon_rad + p), 2*p) - p>
		<cfset rLong = RadToDeg(lon_rad)>
		<cfset rLat = RadToDeg(lat_rad)>
		<cfset retn = '#retn# #rLong#,#rLat#,0'>	
	</cfloop>
	<cfset retn = '#retn#</coordinates></LineString></Placemark>'>	
	<cfreturn retn>
</cffunction>
<!------------------------------------------------------------->
<cfif #action# is "nothing">
<cfoutput>
	NOTE: Horizontal Datum is NOT transformed correctly. Positions will be misplaced for all non-WGS84 datum points.
	<form name="prefs" method="post" action="kml.cfm">
		<input type="hidden" name="action" value="make">
		<input type="hidden" name="table_name" value="#table_name#">
		<br>Show Error Circles? <input type="checkbox" name="showErrors" id="showErrors" value="1">
		<br>Show all specimens at each locality represented by query?
		<input type="checkbox" name="mapByLocality" id="mapByLocality" value="1">
		<br>Show only accepted coordinate determinations?
		<input type="checkbox" name="showOnlyAccepted" id="showOnlyAccepted" value="1">
		<input type="submit">
	</form>
</cfoutput>
</cfif>
<!-------------------------------------------------------------------------->
<cfif #action# is "make">
<cfoutput>
	<cfif isdefined("client.roles") and listfindnocase(client.roles,"coldfusion_user")>
		<cfset flatTableName = "flat">
	<cfelse>
		<cfset flatTableName = "filtered_flat">
	</cfif>
	<cfset dlPath = "#Application.webDirectory#/bnhmMaps/">
	<cfset dlFile = "kmlfile#cfid##cftoken#.kml">
	<cfif isdefined("mapByLocality") and #mapByLocality# is 1>
		<cfquery name="data" datasource="#Application.web_user#">
			select 
				#flatTableName#.collection_object_id,
				#flatTableName#.cat_num,
				lat_long.dec_lat,
				lat_long.dec_long,
				decode(lat_long.accepted_lat_long_fg,
					1,'yes',
					0,'no') isAcceptedLatLong,
				to_meters(lat_long.max_error_distance,lat_long.max_error_units) errorInMeters,
				lat_long.datum,
				#flatTableName#.scientific_name,
				#flatTableName#.collection,
				#flatTableName#.spec_locality,
				#flatTableName#.locality_id,
				#flatTableName#.verbatimLatitude,
				#flatTableName#.verbatimLongitude,
				lat_long.lat_long_id
			 from 
			 	#flatTableName#,
			 	lat_long
			 where
			 	#flatTableName#.locality_id = lat_long.locality_id and
			 	<cfif isdefined("showOnlyAccepted") and #showOnlyAccepted# is 1>
			 		lat_long.accepted_lat_long_fg = 1 AND
			 	</cfif>
			 	lat_long.dec_lat is not null and lat_long.dec_long is not null and
			 	#flatTableName#.locality_id IN (
			 		select #flatTableName#.locality_id from #table_name#,#flatTableName#
			 		where #flatTableName#.collection_object_id = #table_name#.collection_object_id)
		</cfquery>
	<cfelse>
		<cfquery name="data" datasource="#Application.web_user#">
			select 
				#flatTableName#.collection_object_id,
				#flatTableName#.cat_num,
				lat_long.dec_lat,
				lat_long.dec_long,
				decode(lat_long.accepted_lat_long_fg,
					1,'yes',
					0,'no') isAcceptedLatLong,
				to_meters(lat_long.max_error_distance,lat_long.max_error_units) errorInMeters,
				lat_long.datum,
				#flatTableName#.scientific_name,
				#flatTableName#.collection,
				#flatTableName#.spec_locality,
				#flatTableName#.locality_id,
				#flatTableName#.verbatimLatitude,
				#flatTableName#.verbatimLongitude,
				lat_long.lat_long_id
			 from 
			 	#flatTableName#,
			 	lat_long,
			 	#table_name#
			 where
			 	#flatTableName#.locality_id = lat_long.locality_id and
			 	<cfif isdefined("showOnlyAccepted") and #showOnlyAccepted# is 1>
			 		lat_long.accepted_lat_long_fg = 1 AND
			 	</cfif>
			 	lat_long.dec_lat is not null and 
			 	lat_long.dec_long is not null and
			 	#flatTableName#.collection_object_id = #table_name#.collection_object_id
		</cfquery>
	</cfif>
	<cfset kml = '<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://earth.google.com/kml/2.2"><Folder><name>Specimens</name>'>
	<cffile action="write" file="#dlPath##dlFile#" addnewline="no" output="#kml#" nameconflict="overwrite">
	<cfquery name="colln" dbtype="query">
		select collection from data group by collection
	</cfquery>
	<cfloop query="colln">
		<cfquery name="loc" dbtype="query">
			select 
				dec_lat,
				dec_long,
				isAcceptedLatLong,
				errorInMeters,
				datum,
				spec_locality,
				locality_id,
				verbatimLatitude,
				verbatimLongitude,
				lat_long_id
			from
				data
			where
				collection='#collection#'
			group by
				dec_lat,
				dec_long,
				isAcceptedLatLong,
				errorInMeters,
				datum,
				spec_locality,
				locality_id,
				verbatimLatitude,
				verbatimLongitude,
				lat_long_id
		</cfquery>
		<cfset kml = "<Folder><name>#collection#</name>">
		<cffile action="append" file="#dlPath##dlFile#" addnewline="yes" output="#kml#">
		<cfloop query="loc">
			<cfquery name="sdet" dbtype="query">
				select 
					collection_object_id,
					cat_num,
					scientific_name,
					collection
				from
					data
				where
					locality_id = #locality_id#
			</cfquery>
			<cfset kml='<Placemark><name>#spec_locality# (#locality_id#)</name><description>Datum: #datum#<br/>
			Error: #round(errorInMeters)# m<br/>'>
			<cfif isdefined("client.roles") and listfindnocase(client.roles,"coldfusion_user")>
				<cfset kml='#kml#<p><a href="#application.serverRootUrl#/editLocality.cfm?locality_id=#locality_id#">Edit Locality</a></p>'>
			</cfif>
			<cfloop query="sdet">
				<cfset kml='#kml#<a href="#application.serverRootUrl#/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">
					#collection# #cat_num# (<em>#scientific_name#</em>)
				</a><br/>'>
			</cfloop>
			<cfset kml='#kml#</description>
			<Point>
	      	<coordinates>#dec_long#,#dec_lat#,0</coordinates>
	    	</Point>
	    	<icon><href>http://maps.google.com/mapfiles/kml/paddle/grn-blank.png</href></icon>
	  		</Placemark>'>
	  		<cffile action="append" file="#dlPath##dlFile#" addnewline="yes" output="#kml#">
		</cfloop>
		
		<cfset kml = "</Folder>"><!--- close collection folder --->
		<cffile action="append" file="#dlPath##dlFile#" addnewline="yes" output="#kml#">
	</cfloop>
	
	<cfif isdefined("showErrors") and #showErrors# is 1><!---- turn off errors here --->
		<cfquery name="errors" dbtype="query">
			select errorInMeters,dec_lat,dec_long
			from data 
			where errorInMeters>0
			group by errorInMeters,dec_lat,dec_long
		</cfquery>
		<cfset kml="<Folder><name>Error Circles</name>"><!------made error circles folder--------->
		<cffile action="append" file="#dlPath##dlFile#" addnewline="yes" output="#kml#">
		<cfloop query="errors">
			<cfset k = kmlCircle(#dec_lat#,#dec_long#,#errorInMeters#)>
			<cfset kml=" #k#">
			<cffile action="append" file="#dlPath##dlFile#" addnewline="yes" output="#kml#">
		</cfloop>
		<cfset kml = "</Folder>"><!--- close error folder --->
		<cffile action="append" file="#dlPath##dlFile#" addnewline="yes" output="#kml#">
	</cfif>
	
	
	<cfset kml='</Folder></kml>'><!--- close specimens folder --->
			<cffile action="append" file="#dlPath##dlFile#" addnewline="yes" output="#kml#">
		<p>
		</p><a href="kml.cfm?action=getFile&p=#URLEncodedFormat("/bnmhMaps/")#&f=#URLEncodedFormat(dlFile)#">Download KML</a> (requires <a href="http://earth.google.com/">Google Earth</a>)
		<p>
			View in <a href="http://maps.google.com/maps?q=http://mvzarctos-dev.berkeley.edu/bnhmMaps/#dlFile#" target="_blank">Google Maps</a>
		</p>
	<!----

	<cfdump var=#data#>
	table_name: #table_name#
	
	

	<cfloop query="loc">
		
		<cfset specLink = "">
		<cfloop query="sdet">
			<cfif len(#specLink#) is 0>
				<cfset specLink = "#collection# #cat_num# #scientific_name#">
			<cfelse>
				<cfset specLink = "#specLink#<br>#collection# #cat_num# #scientific_name#">
			</cfif>
		</cfloop>
		<cfset relInfo='<a href="#Application.ServerRootUrl#/editLocality.cfm?locality_id=#locality_id#" target="_blank">#spec_locality#</a>'>
		<cfset oneLine="#relInfo##chr(9)##locality_id##chr(9)##lat_long_id##chr(9)##spec_locality##chr(9)##dec_lat##chr(9)##dec_long##chr(9)##errorInMeters##chr(9)##datum##chr(9)##isAcceptedLatLong##chr(9)##specLink##chr(9)##verbatimLatitude#/#verbatimLongitude#">
		<cfset oneLine=trim(oneLine)>
		<cffile action="append" file="#dlPath##dlFile#" addnewline="yes" output="#oneLine#">
	</cfloop>

	<cfset bnhmUrl="http://berkeleymapper.berkeley.edu/index.php?ViewResults=tab&tabfile=#Application.ServerRootUrl#/bnhmMaps/#dlFile#&configfile=#Application.ServerRootUrl#/bnhmMaps/SpecByLoc.xml&sourcename=Locality">
	

	<script type="text/javascript" language="javascript">
		document.location='#bnhmUrl#';
	</script>
</cfoutput>



















<cfdump var=#form#>
<cfoutput>
	
	<cfset theFile = '<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://earth.google.com/kml/2.2">
  <Folder>
  	<name>Big Folder</name>
  	<Folder>
  		<name>liler Folder</name>
  		<Placemark>
	    <name>One</name>
	    <description>Attached to the ground. Intelligently places itself 
	       at the height of the underlying terrain.</description>
	    <Point>
	      <coordinates>#inlong#,#inlat#,0</coordinates>
	    </Point>
	  </Placemark>
	  #k#
  	</Folder>
   </Folder>
</kml>
'>
<hr>
#theFile#
<hr>
<cffile action="write" file="#application.webDirectory#/temp/test.kml" output="#theFile#" nameconflict="overwrite">
<a href="/temp/test.kml">/temp/test.kml</a>

---->
	</cfoutput>
	</cfif>
