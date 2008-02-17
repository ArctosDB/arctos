<cfif isdefined("action") and #action# is "getFile">
<cfoutput>
	<cfheader name="Content-Disposition" value="inline; filename=#file#">
	<cfcontent type="application/vnd.google-earth.kml+xml" file="#file#">
</cfoutput>

		
		
		
</cfif>
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
	<!---
	<cfset retn = '<table border><tr><td>i</td><td>x</td><td>y</td><td>dlon_rad</td><td>lon_rad</td><td>rLong</td><td>rLat</td></tr>'>	
			---->
	<cfloop from="0" to="360" index="i">
		<cfset radial = DegToRad(i)>
		<cfset lat_rad = asin(sin(lat)*cos(d_rad) + cos(lat)*sin(d_rad)*cos(radial))>
		<cfset dlon_rad = atan2(sin(radial)*sin(d_rad)*cos(lat),cos(d_rad)-sin(lat)*sin(lat_rad))>
		<!---
		<cfset lon_rad = ((long+dlon_rad + 3.1415) mod (2*3.1415)) - 3.1415>
		--->
		<cfset p="3.14">
		<cfset x=(long+dlon_rad + p)>
		<cfset y=(2*p)>
		<!---
		<cfset lon_rad = (x mod y) - p>
---->
  <cfset lon_rad = ProperMod((long+dlon_rad + p), 2*p) - p>
		<cfset rLong = RadToDeg(lon_rad)>
		<cfset rLat = RadToDeg(lat_rad)>
		<!---
		<cfset retn = '#retn#<tr><td>#i#</td><td>#x#</td><td>#y#</td><td>#dlon_rad#</td><td>#lon_rad#</td><td>#rLong#</td><td>#rLat#</td></tr>'>	
	--->
		<cfset retn = '#retn# #rLong#,#rLat#,0'>	
	</cfloop>
	


	<cfset retn = '#retn#</coordinates></LineString></Placemark>'>
				
	<cfreturn retn>
	</cffunction>
<form name="a" method="post" action="kmltest.cfm">
	Lat:<input type="text" name="inlat">
	<br>Lon:<input type="text" name="inlong">
	<br>Rad:<input type="text" name="inrad">
	<input type="hidden" name="action" value="make">
	<input type="submit">
</form>
<cfif #action# is "make">
	<cfset kml = '<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://earth.google.com/kml/2.2"><Folder><name>Specimens</name>'>
Retrieving map data - please wait....
<cfflush>
<cfoutput>
	<cfif isdefined("client.roles") and listfindnocase(client.roles,"coldfusion_user")>
		<cfset flatTableName = "flat">
	<cfelse>
		<cfset flatTableName = "filtered_flat">
	</cfif>
	<cfset dlPath = "#Application.webDirectory#/bnhmMaps/">
	<cfset dlFile = "kmlfile#cfid##cftoken#.kml">
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
		 	#flatTableName#.locality_id IN (
		 		select #flatTableName#.locality_id from #table_name#,#flatTableName#
		 		where #flatTableName#.collection_object_id = #table_name#.collection_object_id)
	</cfquery>
	<cffile action="write" file="#dlPath##dlFile#" addnewline="no" output="#kml#" nameconflict="overwrite">
	<cfquery name="colln" dbtype="query">
		select collection from data group by collection
	</cfquery>
	<cfloop query="colln">
		<cfset kml = "<Folder><name>#collection#</name>">
		<cffile action="append" file="#dlPath##dlFile#" addnewline="yes" output="#kml#">
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
			<cfset kml="<Placemark><name>#spec_locality# (#locality_id#)</name><description>">
			<cfloop query="sdet">
				<cfset kml='#kml#<a href="#application.serverRootUrl#/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">
					#collection# #cat_num# (<em>#scientific_name#</em>)
				</a><br/>'>
			</cfloop>
			<cfset kml='#kml#</description>
			<Point>
	      	<coordinates>#dec_long#,#dec_lat#,0</coordinates>
	    	</Point>
	  		</Placemark>'>
	  		<cffile action="append" file="#dlPath##dlFile#" addnewline="yes" output="#kml#">
		</cfloop>
		<cfif 1 is 1><!---- turn off errors here --->
			<cfquery name="errors" dbtype="query">
				select locality_id,errorInMeters,dec_lat,dec_long
				from data 
				where errorInMeters>0
				and dec_lat is not null and dec_long is not null
				and locality_id = #locality_id#
				group by locality_id,errorInMeters,dec_lat,dec_long
			</cfquery>
			<cfset kml="<Folder><name>#Collection# Error</name>">
			<cfloop query="errors">
				<cfset k = kmlCircle(#dec_lat#,#dec_long#,#errorInMeters#)>
				<cfset kml="#kml# #k#">
			</cfloop>
			<cffile action="append" file="#dlPath##dlFile#" addnewline="yes" output="#kml#">
			<cfset kml = "</Folder>">
		</cfif>
		<cfset kml = "</Folder>"><!--- close collection folder --->
		<cffile action="append" file="#dlPath##dlFile#" addnewline="yes" output="#kml#">
	</cfloop>
	
	
	
	<cfset kml='#kml#</Folder></Folder></kml>'>
			<cffile action="append" file="#dlPath##dlFile#" addnewline="yes" output="#kml#">
		<p>
		</p><a href="/bnhmMaps/#dlFile#">file</a>
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
