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
	<Placemark>
	<name>Error</name><visibility>1</visibility>
	<styleUrl>##error-line</styleUrl>
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
		<cfset p=pi()>
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
	<form name="prefs" id="prefs" method="post" action="kml.cfm">
		<input type="hidden" name="action" id="action" value="make">
		<input type="hidden" name="table_name" value="#table_name#">
		<br>Show Error Circles? (Makes big filesizes) <input type="checkbox" name="showErrors" id="showErrors" value="1" checked="checked">
		<br>Show all specimens at each locality represented by query?
		<input type="checkbox" name="mapByLocality" id="mapByLocality" value="1">
		<br>Show only accepted coordinate determinations?
		<input type="checkbox" name="showOnlyAccepted" id="showOnlyAccepted" value="1">
		<br>File Name
		<input type="text" name="userFileName" id="userFileName" size="40" value="kmlfile#cfid##cftoken#">
		<br>
		
		<input type="submit" value="get KML" class="lnkBtn"
   					onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'">
   		<input type="button" value="species KML" class="lnkBtn" onclick="document.getElementById('action').value='speciesKML';submit();">	
	</form>
</cfoutput>
</cfif>
<!-------------------------------------------------------------------------->
<cfif #action# is "speciesKML">
<cfoutput>
    <cfif isdefined("client.roles") and listfindnocase(client.roles,"coldfusion_user")>
		<cfset flatTableName = "flat">
	<cfelse>
		<cfset flatTableName = "filtered_flat">
	</cfif>
	<cfset dlPath = "#Application.webDirectory#/bnhmMaps/">
	<cfif isdefined("userFileName") and len(#userFileName#) gt 0>
		<cfset dlFile = "#userFileName#.kml">
	<cfelse>
		<cfset dlFile = "kmlfile#cfid##cftoken#.kml">
	</cfif>
    <cfquery name="data" datasource="#Application.web_user#">
			select 
				#flatTableName#.collection_object_id,
				#flatTableName#.cat_num,
				to_char(#flatTableName#.began_date,'yyyy-mm-dd') began_date,
				to_char(#flatTableName#.ended_date,'yyyy-mm-dd') ended_date,
				lat_long.dec_lat,
				lat_long.dec_long,
				decode(lat_long.accepted_lat_long_fg,
					1,'yes',
					0,'no') isAcceptedLatLong,
				round(to_meters(lat_long.max_error_distance,lat_long.max_error_units)) errorInMeters,
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
	<cfif isdefined("userFileName") and len(#userFileName#) gt 0>
		<cfset dlFile = "#userFileName#.kml">
	<cfelse>
		<cfset dlFile = "kmlfile#cfid##cftoken#.kml">
	</cfif>	
	<cfif isdefined("mapByLocality") and #mapByLocality# is 1>
		<cfquery name="data" datasource="#Application.web_user#">
			select 
				#flatTableName#.collection_object_id,
				#flatTableName#.cat_num,
				to_char(#flatTableName#.began_date,'yyyy-mm-dd') began_date,
				to_char(#flatTableName#.ended_date,'yyyy-mm-dd') ended_date,
				lat_long.dec_lat,
				lat_long.dec_long,
				decode(lat_long.accepted_lat_long_fg,
					1,'yes',
					0,'no') isAcceptedLatLong,
				round(to_meters(lat_long.max_error_distance,lat_long.max_error_units)) errorInMeters,
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
				to_char(#flatTableName#.began_date,'yyyy-mm-dd') began_date,
				to_char(#flatTableName#.ended_date,'yyyy-mm-dd') ended_date,
				lat_long.dec_lat,
				lat_long.dec_long,
				decode(lat_long.accepted_lat_long_fg,
					1,'yes',
					0,'no') isAcceptedLatLong,
				round(to_meters(lat_long.max_error_distance,lat_long.max_error_units)) errorInMeters,
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
	<cfset kml = '<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://earth.google.com/kml/2.2"><Document><name>Localities</name>
	<open>1</open>
	<Style id="green-star">
		<IconStyle>
			<Icon>
				<href>http://maps.google.com/mapfiles/kml/paddle/grn-stars.png</href>
			</Icon>
		</IconStyle>		
	</Style>
	<Style id="red-star">
      <IconStyle>
        <Icon>
          <href>http://maps.google.com/mapfiles/kml/paddle/red-stars.png</href>
        </Icon>
      </IconStyle>
    </Style>
	<Style id="error-line">
	<LineStyle>
      <color>ff0000ff</color>
      <width>1</width>
    </LineStyle>
    </Style>
	'>
			
			
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
				lat_long_id,
				began_date,
				ended_date
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
				lat_long_id,
				began_date,
				ended_date
		</cfquery>
		<cfset kml = "<Folder><name>#collection#</name><visibility>1</visibility>">
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
				group by
					collection_object_id,
					cat_num,
					scientific_name,
					collection
			</cfquery>
			<cfset kml='<Placemark><name>#kmlStripper(spec_locality)# (#locality_id#)</name>
			<visibility>1</visibility><description>
			<Timespan><begin>#began_date#</begin><end>#ended_date#</end></Timespan>
			<![CDATA[Datum: #datum#<br/>
			Error: #errorInMeters# m<br/>'>
			<cfif isdefined("client.roles") and listfindnocase(client.roles,"coldfusion_user")>
				<cfset kml='#kml#<p><a href="#application.serverRootUrl#/editLocality.cfm?locality_id=#locality_id#">Edit Locality</a></p>'>
			</cfif>
			<cfloop query="sdet">
				<cfset kml='#kml#<a href="#application.serverRootUrl#/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">
					#collection# #cat_num# (<em>#scientific_name#</em>)
				</a><br/>'>
			</cfloop>
			<cfset kml='#kml#]]></description>
			<Point>
	      	<coordinates>#dec_long#,#dec_lat#,0</coordinates>
	    	</Point>'>
	    	<cfif #isAcceptedLatLong# is "yes">
	    		<cfset kml='#kml#<styleUrl>##green-star</styleUrl>
					<Icon><href>http://maps.google.com/mapfiles/kml/paddle/grn-stars.png</href></Icon>'>
	    	<cfelse>
	    	<cfset kml='#kml#<styleUrl>##red-star</styleUrl>
				<Icon><href>http://maps.google.com/mapfiles/kml/paddle/red-stars.png</href></Icon>'>
	    	</cfif>
	    	<cfset kml='#kml#</Placemark>'>
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
	
	
	<cfset kml='</Document></kml>'><!--- close specimens folder --->
			<cffile action="append" file="#dlPath##dlFile#" addnewline="yes" output="#kml#">
			
			<cfset linkFile = "link_#dlFile#">
			<cfset kml='<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://earth.google.com/kml/2.0">
				<NetworkLink>
				  <name>Arctos Locations</name>
				  <visibility>1</visibility>
				  <open>1</open>
					<Url>
			    <href>#Application.ServerRootUrl#/bnhmMaps/#dlFile#</href>
			    </Url>
			</NetworkLink>
			</kml>'>
			<cffile action="write" file="#dlPath##linkFile#" addnewline="no" output="#kml#" nameconflict="overwrite">
		<p>
		</p><a href="kml.cfm?action=getFile&p=#URLEncodedFormat("/bnmhMaps/")#&f=#URLEncodedFormat(dlFile)#">Download Entire KML</a> (requires <a href="http://earth.google.com/">Google Earth</a>)
			<blockquote>
				Download KML (#dlFile#) including all data to your hard drive
			</blockquote>
		<p>
		<a href="kml.cfm?action=getFile&p=#URLEncodedFormat("/bnmhMaps/")#&f=#URLEncodedFormat(linkFile)#">Download KML Link</a> (requires <a href="http://earth.google.com/">Google Earth</a>)
			<blockquote>
				Download KML Link data (#linkFile#). Data remains on Arctos and will be refreshed every time you build a KML with the same name.
				 Data on Arctos will be periodically purged.
			</blockquote>
		</p>
		<p>
			View in <a href="http://maps.google.com/maps?q=#Application.ServerRootUrl#/bnhmMaps/#dlFile#" target="_blank">Google Maps</a>
		</p>
	</cfoutput>
	</cfif>