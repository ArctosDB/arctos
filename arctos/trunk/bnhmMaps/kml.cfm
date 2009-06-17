<cfinclude  template="/includes/_header.cfm"> 
<cfset table_name=session.SpecSrchTab>
<cfset internalPath="#Application.webDirectory#/bnhmMaps/tabfiles/">
<cfset externalPath="#Application.ServerRootUrl#/bnhmMaps/tabfiles/">
<cfif not isdefined("method")>
	<cfset method="download">
</cfif>
<cfif not isdefined("showErrors")>
	<cfset showErrors=0>
</cfif>
<cfif not isdefined("mapByLocality")>
	<cfset mapByLocality=0>
</cfif>
<cfif not isdefined("showUnaccepted")>
	<cfset showUnaccepted=0>
</cfif>
<cfif not isdefined("userFileName")>
	<cfset userFileName="kmlfile#cfid##cftoken#">
</cfif>
<cfif not isdefined("next")>
	<cfset next="nothing">
</cfif>
<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>
	<cfset flatTableName = "flat">
<cfelse>
	<cfset flatTableName = "filtered_flat">
</cfif>
<!----------------------------------------------------------------->
<cffunction name="kmlCircle" access="public" returntype="string" output="false">
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
	<cfset retn = "<Placemark>">
	<cfset retn=retn & chr(10) & chr(9) & "<name>Error</name>">
	<cfset retn=retn & chr(10) & chr(9) & "<visibility>1</visibility>">
	<cfset retn=retn & chr(10) & chr(9) & "<styleUrl>##error-line</styleUrl>">
	<cfset retn=retn & chr(10) & chr(9) & "<LineString>">
	<cfset retn=retn & chr(10) & chr(9) & chr(9) & "<coordinates>">
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
		<cfset retn=retn & chr(10) & chr(9) & chr(9) & chr(9) & "#rLong#,#rLat#,0">
	</cfloop>
	<cfset retn=retn & chr(10) & chr(9) & chr(9) & "</coordinates>">
	<cfset retn=retn & chr(10) & chr(9) & "</LineString>">
	<cfset retn=retn & chr(10) & "</Placemark>">
	<cfreturn retn>
</cffunction>
<!------------------------------------------------------------------------------------------->
<cfif action is "api">
	<table border>
		<tr>
			<th>Variable</th>
			<th>Values</th>
			<th>Explanation</th>
		</tr>
		
		<tr>
			<td>action</td>
			<td>newReq</td>
			<td>Only acceptable value for webservice calls</td>
		</tr>
		
		<tr>
			<td>{saerch criteria}</td>
			<td>{various}</td>
			<td>{unpublished}</td>
		</tr>
		
		<tr>
			<td>userFileName</td>
			<td>Any string</td>
			<td>Non-default file name. Will be URL-encoded, so use alphanumeric characters for predictability.</td>
		</tr>	
		
		<tr>
			<td rowspan="3">next</td>
			<td>nothing</td>
			<td>Proceed to a form where you may set all other criteria</td>
		</tr>
		<tr>		
			<td>colorByCollection</td>
			<td>Map points are arranged by collection</td>
		</tr>
		<tr>		
			<td>colorBySpecies</td>
			<td>Map points are arranged by collection</td>
		</tr>
		
		<tr>
			<td rowspan="3">method</td>
			<td>download</td>
			<td>Download a full KML file</td>
		</tr>
		<tr>		
			<td>gmap</td>
			<td>Map in Google Maps</td>
		</tr>
		<tr>		
			<td>link</td>
			<td>Download a KML Linkfile</td>
		</tr>
		
		<tr>
			<td rowspan="2">showUnaccepted</td>
			<td>0</td>
			<td>Include only accepted coordinate determinations</td>
		</tr>
		<tr>		
			<td>1</td>
			<td>Include unaccepted coordinate determinations</td>
		</tr>
		
		<tr>
			<td rowspan="2">mapByLocality</td>
			<td>0</td>
			<td>Show only those specimens matching search criteria</td>
		</tr>
		<tr>		
			<td>1</td>
			<td>Include all specimens from each locality</td>
		</tr>
		
		<tr>
			<td rowspan="2">showErrors</td>
			<td>0</td>
			<td>Map points onle</td>
		</tr>
		<tr>		
			<td>1</td>
			<td>Include error radii as circles</td>
		</tr>
		
		<tr>		
			<td>link</td>
			<td>Download a KML Linkfile</td>
		</tr>
	</table>
</cfif>
<!------------------------------------------------------------------------------------------------>
<!--- handle direct calls --->
<cfif action is "newReq">
	<cfoutput>
		<cfset basSelect = " SELECT distinct #flatTableName#.collection_object_id">
		<cfquery name="reqd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from cf_spec_res_cols where category='required'
		</cfquery>
		<cfset basSelect = listappend(basSelect,valuelist(reqd.SQL_ELEMENT))>
		<cfset basFrom = " FROM #flatTableName#">
		<cfset basJoin = "INNER JOIN cataloged_item ON (#flatTableName#.collection_object_id =cataloged_item.collection_object_id)">
		<cfset basWhere = " WHERE #flatTableName#.collection_object_id IS NOT NULL ">	
		<cfset basQual = "">
		<cfset mapurl="">
		<cfinclude template="/includes/SearchSql.cfm">
		<cfset SqlString = "#basSelect# #basFrom# #basJoin# #basWhere# #basQual#">
		<cfset sqlstring = replace(sqlstring,"flatTableName","#flatTableName#","all")>
		<cfset srchTerms="">
		<cfloop list="#mapurl#" delimiters="&" index="t">
			<cfset tt=listgetat(t,1,"=")>
			<cfset srchTerms=listappend(srchTerms,tt)>
		</cfloop>
		<cfif listcontains(srchTerms,"ShowObservations")>
			<cfset srchTerms=listdeleteat(srchTerms,listfindnocase(srchTerms,'ShowObservations'))>
		</cfif>
		<cfif listcontains(srchTerms,"collection_id")>
			<cfset srchTerms=listdeleteat(srchTerms,listfindnocase(srchTerms,'collection_id'))>
		</cfif>
		<cfif len(srchTerms) is 0>
			<CFSETTING ENABLECFOUTPUTONLY=0>			
			<font color="##FF0000" size="+2">You must enter some search criteria!</font>	  
			<cfabort>
		</cfif>
		<cfset thisTableName = "SearchResults_#cfid#_#cftoken#">	
		<cftry>
			<cfquery name="die" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				drop table #session.SpecSrchTab#
			</cfquery>
			<cfcatch>
				<!--- not there, so what? --->
			</cfcatch>
		</cftry>
		<cfset checkSql(SqlString)>	
		<cfset SqlString = "create table #session.SpecSrchTab# AS #SqlString#">
		<cfquery name="buildIt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			#preserveSingleQuotes(SqlString)#
		</cfquery>
		
		<cfset burl="kml.cfm?method=#method#&showErrors=#showErrors#&mapByLocality=#mapByLocality#">
		<cfset burl=burl & "&showUnaccepted=#showUnaccepted#&userFileName=#userFileName#&action=#next#">	
		<cflocation url="#burl#" addtoken="false">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------>
<cfif isdefined("action") and #action# is "getFile">
	<cfoutput>
		<cfheader name="Content-Disposition" value="attachment; filename=#f#">
		<cfcontent type="application/vnd.google-earth.kml+xml" file="#internalPath##f#">
	</cfoutput>	
</cfif>
<!------------------------------------------------------------->
<cfif #action# is "nothing">
	<cfoutput>
		<span style="color:red;">
			NOTE: Horizontal Datum is NOT transformed. Positions will be misplaced for all non-WGS84 datum points.
		</span>
		<form name="prefs" id="prefs" method="post" action="kml.cfm">
			<table>
				<tr>
					<td align="right">Show Error Circles? (Makes big filesizes)</td>
					<td>
						<input type="checkbox" 
							<cfif showErrors is 1> checked="checked"</cfif>
							name="showErrors" id="showErrors" value="1">
					</td>
				</tr>
				<tr>
					<td align="right">Show all specimens at each locality represented by query?</td>
					<td>
						<input type="checkbox" 
							<cfif mapByLocality is 1> checked="checked"</cfif>
							name="mapByLocality" id="mapByLocality" value="1">
					</td>
				</tr>
				<tr>
					<td align="right">Show unaccepted coordinate determinations?</td>
					<td>
						<input type="checkbox" 
							<cfif showUnaccepted is 1> checked="checked"</cfif>
							name="showUnaccepted" id="showUnaccepted" value="1"></td>
				</tr>
				<tr>
					<td align="right">File Name</td>
					<td><input type="text" name="userFileName" id="userFileName" size="40" value="#URLEncodedFormat(userFileName)#"></td>
				</tr>
				<tr>
					<td align="right">Method</td>
					<td>
						<select name="method" id="method">
							<option <cfif method is "download"> selected="selected"</cfif> value="download">Download KML</option>
							<option <cfif method is "link"> selected="selected"</cfif> value="link">Download linkfile</option>
							<option <cfif method is "gmap"> selected="selected"</cfif> value="gmap">Google Maps</option>
						</select>
					</td>
				</tr>
				<tr>
					<td align="right">Color by</td>
					<td>
						<select name="action" id="action">
							<option <cfif next is "colorByCollection"> selected="selected"</cfif> value="colorByCollection">Collection</option>
							<option <cfif next is "colorBySpecies"> selected="selected"</cfif> value="colorBySpecies">Species</option>
						</select>
					</td>
				</tr>
				<tr>
					<td colspan="2" align="center">
						<input type="submit" value="Go" class="lnkBtn"
	   						onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'">
					</td>
				</tr>
			</table>		
	    </form>
	</cfoutput>
</cfif>
<!--------------------------------------------------------------------------------->
<cfif #action# is "colorBySpecies">
	<cfoutput>
    <cfset dlFile = "#userFileName#.kml">
	<cfset variables.fileName="#internalPath##dlFile#">
	<cfset variables.encoding="UTF-8">
	
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			#flatTableName#.collection_object_id,
			#flatTableName#.cat_num,
			to_char(#flatTableName#.began_date,'yyyy-mm-dd') began_date,
			to_char(#flatTableName#.ended_date,'yyyy-mm-dd') ended_date,
			lat_long.dec_lat,
			lat_long.dec_long,
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
		 	lat_long.accepted_lat_long_fg = 1 AND
		 	lat_long.dec_lat is not null and 
		 	lat_long.dec_long is not null and
		 	#flatTableName#.collection_object_id = #table_name#.collection_object_id
	</cfquery>
    <cfquery name="species" dbtype="query">
    	select scientific_name from data group by scientific_name
    </cfquery>
	<cfscript>
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
	</cfscript>
	<cfscript>
		 kml='<?xml version="1.0" encoding="UTF-8"?>' & chr(10) & 
		 	'<kml xmlns="http://earth.google.com/kml/2.2">' & chr(10) & 
		 	chr(9) & '<Document>' & chr(10) & 
		 	chr(9) & chr(9) & '<name>Localities</name>' & chr(10) & 
		 	chr(9) & chr(9) & '<open>1</open>';
		variables.joFileWriter.writeLine(kml);
	</cfscript>		
	<cfloop query="species">
    	<cfset thisName=replace(scientific_name," ","_","all")>
        <cfset thisColor=randomHexColor()> 
        <cfscript>
			kml=chr(9) & chr(9) & '<Style id="icon_#thisName#">' & chr(10) & 
				chr(9) & chr(9) & chr(9) & '<IconStyle>' & chr(10) &
				chr(9) & chr(9) & chr(9) & chr(9) & '<color>ff#thisColor#</color>' & chr(10) & 
				chr(9) & chr(9) & chr(9) & chr(9) & '<scale>1.1</scale>' & chr(10) & 
				chr(9) & chr(9) & chr(9) & chr(9) & '<Icon>' & chr(10) & 
				chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<href>#application.serverRootUrl#/images/whiteBalloon.png</href>' & chr(10) & 
				chr(9) & chr(9) & chr(9) & chr(9) & '</Icon>'  & chr(10) &
				chr(9) & chr(9) & chr(9) & '<IconStyle>'  & chr(10) &
				chr(9) & chr(9) & '</Style';
			variables.joFileWriter.writeLine(kml);
		</cfscript>	
	</cfloop>
	<cfloop query="species">
		<cfset thisName=replace(scientific_name," ","_","all")>
		<cfscript>
			kml = chr(9) & chr(9) & "<Folder>" & chr(10) &
				chr(9) & chr(9) & chr(9) & '<name>#thisName#</name>' & chr(10) &
				chr(9) & chr(9) & chr(9) & '<visibility>1</visibility>';
			variables.joFileWriter.writeLine(kml);
		</cfscript>
		<cfquery name="loc" dbtype="query">
			select 
				dec_lat,
				dec_long,
				errorInMeters,
				datum,
				spec_locality,
				locality_id,
				verbatimLatitude,
				verbatimLongitude,
				lat_long_id,
				began_date,
				ended_date,
		              collection_object_id,
				cat_num,
				scientific_name,
				collection
			from
				data
			where
				scientific_name='#scientific_name#'
			group by
				dec_lat,
				dec_long,
				errorInMeters,
				datum,
				spec_locality,
				locality_id,
				verbatimLatitude,
				verbatimLongitude,
				lat_long_id,
				began_date,
				ended_date,
		              collection_object_id,
				cat_num,
				scientific_name,
				collection
		</cfquery>
		<cfloop query="loc">
			<cfscript>
				kml=chr(9) & chr(9) & chr(9) & '<Placemark>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & '<name>#collection# #cat_num# (#scientific_name#)</name>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & '<visibility>1</visibility>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & '<styleUrl>##icon_#thisName#</styleUrl>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & '<description>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<Timespan>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<begin>#began_date#</begin>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<end>#ended_date#</end>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '</Timespan>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<![CDATA[Datum: #datum#<br/>Error: #errorInMeters# m<br/>]]>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & '</description>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & '<Point>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<coordinates>#dec_long#,#dec_lat#,0</coordinates>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & '</Point>' & chr(10) &
					chr(9) & chr(9) & chr(9) & '</Placemark>';
				variables.joFileWriter.writeLine(kml);
			</cfscript>
		</cfloop>
		<cfscript>
			kml='</Folder>';
			variables.joFileWriter.writeLine(kml);
		</cfscript>
	</cfloop>
	<cfscript>
		kml='</Document>' & chr(10) & 
		'</kml>';
		variables.joFileWriter.writeLine(kml);		
		variables.joFileWriter.close();
	</cfscript>
	
	
	<cfset linkFile = "link_#dlFile#">
	<cfset variables.fileName="#internalPath##linkFile#">	
	<cfscript>
		 variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
		 kml='<?xml version="1.0" encoding="UTF-8"?>' & chr(10) & 
		 '<kml xmlns="http://earth.google.com/kml/2.0">' & chr(10) & 
		 chr(9) & '<NetworkLink>' & chr(10) & 
		 chr(9) & chr(9) & '<name>Arctos Locations</name>' & chr(10) & 
		 chr(9) & chr(9) & '<visibility>1</visibility>' & chr(10) & 
		 chr(9) & chr(9) & '<open>1</open>' & chr(10) & 
		 chr(9) & chr(9) & '<Url>' & chr(10) & 
		 chr(9) & chr(9) & chr(9) & '<href>#externalPath##dlFile#</href>' & chr(10) & 
		 chr(9) & chr(9) & '</Url>' & chr(10) & 
		 chr(9) & '</NetworkLink>' & chr(10) & 
		 '</kml>';		 
		variables.joFileWriter.writeLine(kml);				
		variables.joFileWriter.close();
	</cfscript>	
	<cfif method is "link">
		<cfset durl="kml.cfm?action=getFile&p=#URLEncodedFormat("/bnmhMaps/")#&f=#URLEncodedFormat(linkFile)#">
		<cflocation url="#durl#" addtoken="false">
	<cfelseif method is "gmap">
		<cfset durl="http://maps.google.com/maps?q=#externalPath##dlFile#?r=#randRange(1,10000)#">
		<script type="text/javascript" language="javascript">
			window.open('#durl#',"_blank")
		</script>
	<cfelse>	
		<cfset durl="kml.cfm?action=getFile&p=#URLEncodedFormat("/bnmhMaps/")#&f=#URLEncodedFormat(dlFile)#">
		<cflocation url="#durl#" addtoken="false">
	</cfif>	
	</cfoutput>
</cfif>
<!-------------------------------------------------------------------------->
<cfif #action# is "colorByCollection">
<cfoutput>
	<cfset dlFile = "#userFileName#.kml">
	<cfset variables.fileName="#internalPath##dlFile#">
	<cfset variables.encoding="UTF-8">
	<cfif mapByLocality is 1>
		<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
			 	<cfif showUnaccepted is 0>
			 		lat_long.accepted_lat_long_fg = 1 AND
			 	</cfif>
			 	lat_long.dec_lat is not null and lat_long.dec_long is not null and
			 	#flatTableName#.locality_id IN (
			 		select #flatTableName#.locality_id from #table_name#,#flatTableName#
			 		where #flatTableName#.collection_object_id = #table_name#.collection_object_id)
		</cfquery>
	<cfelse>
		<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
			 	<cfif showUnaccepted is 0>
			 		lat_long.accepted_lat_long_fg = 1 AND
			 	</cfif>
			 	lat_long.dec_lat is not null and 
			 	lat_long.dec_long is not null and
			 	#flatTableName#.collection_object_id = #table_name#.collection_object_id
		</cfquery>
	</cfif>
	<cfscript>
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
		kml='<?xml version="1.0" encoding="UTF-8"?>' & chr(10) & 
			'<kml xmlns="http://earth.google.com/kml/2.2">' & chr(10) &
			chr(9) & '<Document>' & chr(10) &
			chr(9) & chr(9) & '<name>Localities</name>' & chr(10) &
			chr(9) & chr(9) & '<open>1</open>' & chr(10) &
			chr(9) & chr(9) & '<Style id="green-star">' & chr(10) &
			chr(9) & chr(9) & chr(9) & '<IconStyle>' & chr(10) &
			chr(9) & chr(9) & chr(9) & chr(9) & '<Icon>' & chr(10) &
			chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<href>http://maps.google.com/mapfiles/kml/paddle/grn-stars.png</href>' & chr(10) &
			chr(9) & chr(9) & chr(9) & chr(9) & '</Icon>' & chr(10) &
			chr(9) & chr(9) & chr(9) & '</IconStyle>' & chr(10) &
			chr(9) & chr(9) & '</Style>' & chr(10) &			
			chr(9) & chr(9) & '<Style id="red-star">' & chr(10) &
			chr(9) & chr(9) & chr(9) & '<IconStyle>' & chr(10) &
			chr(9) & chr(9) & chr(9) & chr(9) & '<Icon>' & chr(10) &
			chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<href>http://maps.google.com/mapfiles/kml/paddle/red-stars.png</href>' & chr(10) &
			chr(9) & chr(9) & chr(9) & chr(9) & '</Icon>' & chr(10) &
			chr(9) & chr(9) & chr(9) & '</IconStyle>' & chr(10) &
			chr(9) & chr(9) & '</Style>' & chr(10) &
			chr(9) & chr(9) & '<Style id="error-line">' & chr(10) &
			chr(9) & chr(9) & chr(9) & '<LineStyle>' & chr(10) &
			chr(9) & chr(9) & chr(9) & chr(9) & '<color>ff0000ff</color>' & chr(10) &
			chr(9) & chr(9) & chr(9) & chr(9) & '<width>1</width>' & chr(10) &
			chr(9) & chr(9) & chr(9) & '</LineStyle>' & chr(10) &
			chr(9) & chr(9) & '</Style>';
		variables.joFileWriter.writeLine(kml);      
	</cfscript>
	
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
		<cfscript>
			kml=chr(9) & chr(9) & '<Folder>' & chr(10) &
				chr(9) & chr(9) & chr(9) & '<name>#collection#</name>' & chr(10) &
				chr(9) & chr(9) & chr(9) & '<visibility>1</visibility>';
			variables.joFileWriter.writeLine(kml);      
		</cfscript>
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
			<cfscript>
				kml=chr(9) & chr(9) & chr(9) & '<Placemark>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & '<name>#kmlStripper(spec_locality)# (#locality_id#)</name>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & '<visibility>1</visibility>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & '<description>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<Timespan>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<begin>#began_date#</begin>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<end>#ended_date#</end>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '</Timespan>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<![CDATA[Datum: #datum#<br/>Error: #errorInMeters# m<br/>';
			</cfscript>
			<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>
				<cfscript>
					kml=kml & '<p><a href="#application.serverRootUrl#/editLocality.cfm?locality_id=#locality_id#">Edit Locality</a></p>';
				</cfscript>
			</cfif>
			<cfloop query="sdet">
				<cfscript>
					kml=kml & '<a href="#application.serverRootUrl#/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">' &
						'#collection# #cat_num# (<em>#scientific_name#</em>)</a><br/>';
				</cfscript>				
			</cfloop>
			<cfscript>
				kml=kml & ']]>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & '</description>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & '<Point>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<coordinates>#dec_long#,#dec_lat#,0</coordinates>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & '</Point>';
				variables.joFileWriter.writeLine(kml);
				if (isAcceptedLatLong is "yes") {
					kml=chr(9) & chr(9) & chr(9) & chr(9) & '<styleUrl>##green-star</styleUrl>' & chr(10) &
						chr(9) & chr(9) & chr(9) & chr(9) & '<Icon>' & chr(10) &
						chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<href>http://maps.google.com/mapfiles/kml/paddle/grn-stars.png</href>' & chr(10) &
						chr(9) & chr(9) & chr(9) & chr(9) & '</Icon>';					
				} else {
					kml=chr(9) & chr(9) & chr(9) & chr(9) & '<styleUrl>##red-star</styleUrl>' & chr(10) &
						chr(9) & chr(9) & chr(9) & chr(9) & '<Icon>' & chr(10) &
						chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<href>http://maps.google.com/mapfiles/kml/paddle/red-stars.png</href>' & chr(10) &
						chr(9) & chr(9) & chr(9) & chr(9) & '</Icon>';
				}
				kml=kml & chr(10) &
					chr(9) & chr(9) & chr(9) & '</Placemark>';
				variables.joFileWriter.writeLine(kml);
			</cfscript>
		</cfloop>
		<cfscript>
			kml=chr(9) & chr(9) & '</Folder>';
			variables.joFileWriter.writeLine(kml);
		</cfscript>
	</cfloop>	
	<cfif showErrors is 1>
		<cfquery name="errors" dbtype="query">
			select errorInMeters,dec_lat,dec_long
			from data 
			where errorInMeters>0
			group by errorInMeters,dec_lat,dec_long
		</cfquery>
		<Cfscript>
			kml=chr(9) & chr(9) & '<Folder>' & chr(10) &
				chr(9) & chr(9) & chr(9) & '<name>Error Circles</name>';
			variables.joFileWriter.writeLine(kml);				
		</Cfscript>
		<cfloop query="errors">
			<cfset k = kmlCircle(#dec_lat#,#dec_long#,#errorInMeters#)>
			<cfscript>
				kml=chr(9) & chr(9) & chr(9) & k;
				variables.joFileWriter.writeLine(kml);
			</cfscript>
		</cfloop>
		<cfscript>
			kml=chr(9) & chr(9) & '</Folder>';
			variables.joFileWriter.writeLine(kml);
		</cfscript>
	</cfif>
	<cfscript>
		kml=chr(9) & '</Document>' & chr(10) &
			'</kml>';
		variables.joFileWriter.writeLine(kml);		
		variables.joFileWriter.close();
	</cfscript>
	
	
	<cfset linkFile = "link_#dlFile#">
	<cfset variables.fileName="#internalPath##linkFile#">
	<cfscript>
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
		kml='<?xml version="1.0" encoding="UTF-8"?>' & chr(10) & 
			'<kml xmlns="http://earth.google.com/kml/2.0">' & chr(10) &
			chr(9) & '<NetworkLink>' & chr(10) &
			chr(9) & chr(9) & '<name>Arctos Locations</name>' & chr(10) &
			chr(9) & chr(9) & '<visibility>1</visibility>' & chr(10) &
			chr(9) & chr(9) & '<open>1</open>' & chr(10) &
			chr(9) & chr(9) & '<Url>' & chr(10) &
			chr(9) & chr(9) & chr(9) & '<href>#externalPath##dlFile#</href>' & chr(10) &
			chr(9) & chr(9) & '</Url>' & chr(10) &
			chr(9) & '</NetworkLink>' & chr(10) &
			'</kml>';
		variables.joFileWriter.writeLine(kml);		
		variables.joFileWriter.close();
	</cfscript>		
	<cfif method is "link">
		<cfset durl="kml.cfm?action=getFile&p=#URLEncodedFormat("/bnmhMaps/")#&f=#URLEncodedFormat(linkFile)#">
		<cflocation url="#durl#" addtoken="false">
	<cfelseif method is "gmap">
		<cfset durl="http://maps.google.com/maps?q=#externalPath##dlFile#?r=#randRange(1,10000)#">
		<script type="text/javascript" language="javascript">
			window.open('#durl#',"_blank")
		</script>
	<cfelse>	
		<cfset durl="kml.cfm?action=getFile&p=#URLEncodedFormat("/bnmhMaps/")#&f=#URLEncodedFormat(dlFile)#">
		<cflocation url="#durl#" addtoken="false">
	</cfif>
	</cfoutput>
</cfif>