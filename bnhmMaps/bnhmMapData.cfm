<cfinclude template="/includes/alwaysInclude.cfm">
<cfset fn="arctos_#randRange(1,1000)#">
<cfset variables.localXmlFile="#Application.webDirectory#/bnhmMaps/tabfiles/#fn#.xml">
<cfset variables.localTabFile="#Application.webDirectory#/bnhmMaps/tabfiles/#fn#.txt">
<cfset variables.remoteXmlFile="#Application.serverRootUrl#/bnhmMaps/tabfiles/#fn#.xml">
<cfset variables.remoteTabFile="#Application.serverRootUrl#/bnhmMaps/tabfiles/#fn#.txt">
<cfset variables.encoding="UTF-8">
<div align="center" id="status">
	<span style="background-color:green;color:white; font-size:36px; font-weight:bold;">
		Fetching map data...
	</span>
</div>
<cfflush>
<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>
	<cfset flatTableName = "flat">
<cfelse>
	<cfset flatTableName = "filtered_flat">
</cfif>
<cfset mediaFlatTableName = "media_flat">
<!----------------------------------------------------------------->
<cfif isdefined("action") and action IS "mapPoint">
<cfoutput>
	<!---- map a lat_long_id ---->
	<cfif not isdefined("lat_long_id") or len(lat_long_id) is 0>
		<div class="error">
			You can't map a point without a lat_long_id.
		</div>
		<cfabort>
	</cfif>	
	<cfquery name="getMapData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT
			'All collections' Collection,
			0 collection_id,
			'000000' cat_num,
			'Lat Long ID: ' || lat_long_id scientific_name,
			'none' verbatim_date,
			'none' spec_locality,
			dec_lat,
			dec_long,
			to_meters(max_error_distance,max_error_units) max_error_meters,
			datum,
			'000000' collection_object_id,
			' ' collectors
		FROM 
			lat_long 
		WHERE
			lat_long_id=#lat_long_id#
	</cfquery>
</cfoutput>

<cfelseif isdefined("search") and search IS "MediaSearch">
<!-- 	<cfif isdefined("collection_object_id") and len(collection_object_id) gt 0>
		<cfset ShowObservations = "true">
	</cfif> -->
	
	<cfset ShowObservations = "true">

	<cfset basSelect = "SELECT DISTINCT 
		#flatTableName#.collection,
		#flatTableName#.collection_id,
		#flatTableName#.cat_num,
		#flatTableName#.scientific_name,
		#flatTableName#.verbatim_date,
		#flatTableName#.spec_locality,
		#flatTableName#.dec_lat,
		#flatTableName#.dec_long,
		#flatTableName#.COORDINATEUNCERTAINTYINMETERS,
		#flatTableName#.datum,
		#flatTableName#.collection_object_id,
		#flatTableName#.collectors">
	<cfset basFrom = "	FROM #flatTableName#, #mediaFlatTableName#">
	<cfset basWhere = " WHERE 
		#flatTableName#.collection_object_id IN (#mediaFlatTableName#.collecting_object_id) AND
		#flatTableName#.dec_lat is not null AND
		#flatTableName#.dec_long is not null AND
		#flatTableName#.collecting_source = 'wild caught' ">	
			
	<cfset srch = "">

	<cfinclude template="/development/MediaSearchSql.cfm">
	<cfset SqlString = "#basSelect# #basFrom# #basWhere# #srch#">	
	<cfquery name="getMapData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preserveSingleQuotes(SqlString)#
	</cfquery>

<cfelse><!--- regular mapping routine ---->
	<cfif isdefined("collection_object_id") and len(collection_object_id) gt 0>
		<cfset ShowObservations = "true">
	</cfif>
	<cfset basSelect = "SELECT DISTINCT 
		#flatTableName#.collection,
		#flatTableName#.collection_id,
		#flatTableName#.cat_num,
		#flatTableName#.scientific_name,
		#flatTableName#.verbatim_date,
		#flatTableName#.spec_locality,
		#flatTableName#.dec_lat,
		#flatTableName#.dec_long,
		#flatTableName#.COORDINATEUNCERTAINTYINMETERS,
		#flatTableName#.datum,
		#flatTableName#.collection_object_id,
		#flatTableName#.collectors">
	<cfset basFrom = "	FROM #flatTableName#">
	<!----
	<cfset basJoin = " INNER JOIN cataloged_item ON (#flatTableName#.collection_object_id =cataloged_item.collection_object_id)
		INNER JOIN collecting_event flatCollEvent ON (#flatTableName#.collecting_event_id = flatCollEvent.collecting_event_id)">	
	<cfset basWhere = " WHERE 
		dec_lat is not null AND
		dec_long is not null AND
		flatCollEvent.collecting_source = 'wild caught' ">
	---->	
	<cfset basJoin = " INNER JOIN cataloged_item ON (#flatTableName#.collection_object_id =cataloged_item.collection_object_id)">
	<cfset basWhere = " WHERE 
		#flatTableName#.dec_lat is not null AND
		#flatTableName#.dec_long is not null AND
		#flatTableName#.collecting_source = 'wild caught' ">		
	<cfset basQual = "">
	<cfif not isdefined("basJoin")>
		<cfset basJoin = "">
	</cfif>
	<cfinclude template="/includes/SearchSql.cfm">
	<cfset SqlString = "#basSelect# #basFrom# #basJoin# #basWhere# #basQual#">	
	<cfquery name="getMapData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preserveSingleQuotes(SqlString)#
	</cfquery>
</cfif><!--- end point map option --->
<cfif getMapData.recordcount is 0>
	<div class="error">
		Oops! We didn't find anything mappable. Only wild caught specimens with coordinates will map.
		File a <a href='/info/bugs.cfm'>bug report</a> if you think this message is in error.
	</div>
	<cfabort>
</cfif>
<!---- write an XML config file specific to the critters they're mapping --->
<cfoutput>
	<cfquery name="collID" dbtype="query">
		select collection_id from getMapData group by collection_id
	</cfquery>
	<cfset thisAddress = #Application.DataProblemReportEmail#>
	<cfif len(valuelist(collID.collection_id)) gt 0>
		<cfquery name="whatEmails" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select address from
				electronic_address,
				collection_contacts
			WHERE
				electronic_address.agent_id = collection_contacts.contact_agent_id AND
				collection_contacts.collection_id IN (#valuelist(collID.collection_id)#) AND
				address_type='e-mail' AND
				contact_role='data quality'
			GROUP BY address
		</cfquery>
		<cfloop query="whatEmails">
			<cfset thisAddress = listappend(thisAddress,address)>
		</cfloop>
	</cfif>	
	<cfscript>
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.localXmlFile, variables.encoding, 32768);
		a='<bnhmmaps>' & chr(10) & 
			chr(9) & '<metadata>' & chr(10) & 
			chr(9) & chr(9) & '<name>BerkeleyMapper Configuration File</name>' & chr(10) & 
			chr(9) & chr(9) & '<relatedinformation>#Application.serverRootUrl#</relatedinformation>' & chr(10) & 
			chr(9) & chr(9) & '<abstract>GIS configuration file for specimen query interface</abstract>' & chr(10) & 
			chr(9) & chr(9) & '<mapkeyword keyword="specimens"/>' & chr(10) & 
			chr(9) & chr(9) & '<header location="#Application.mapHeaderUrl#"/>' & chr(10) & 
			chr(9) & chr(9) & '<linkbackheader location="#Application.serverRootUrl#"/>' & chr(10) & 
			chr(9) & chr(9) & '<footer location="#Application.mapFooterUrl#"/>' & chr(10) & 
			chr(9) & chr(9) & '<charset name="UTF-8"></charset>' & chr(10) & 
			chr(9) &'</metadata>';
		variables.joFileWriter.writeLine(a);
	</cfscript>
	<cfquery name="whatColls" dbtype="query">
		select Collection from getMapData group by Collection
	</cfquery>
	<cfset theseColls = valuelist(whatColls.Collection)>
	<cfscript>
		a=chr(9) & '<colors method="field" fieldname="darwin:collectioncode" label="Collection">' & chr(10) &
			chr(9) & chr(9) & '<dominantcolor webcolor="9999cc"/>' & chr(10) & 
			chr(9) & chr(9) & '<subdominantcolor webcolor="9999cc"/>';
		variables.joFileWriter.writeLine(a);
	</cfscript>
	<cfset i=1>
	<cfloop query="whatColls">
		<cfscript>
			a=chr(9) & chr(9) & 
				'<color key="#whatColls.collection#" red="#randRange(0,255)#" green="#randRange(0,255)#" blue="#randRange(0,255)#" symbol="7" label="#whatColls.collection#"/>';
			variables.joFileWriter.writeLine(a);
		</cfscript>
	</cfloop>
	<cfscript>
		a=chr(9) & chr(9) &
			'<color key="default" red="255" green="0" blue="0" symbol="2" label="Unspecified Collection"/>' & chr(10) & 
			chr(9) & '</colors>';
		variables.joFileWriter.writeLine(a);
		a=chr(9) & '<recordlinkback>' & chr(10) & 
			chr(9) & chr(9) & '<linkback method="entireurl" linkurl="Related Information" fieldname="More Information (opens in new window)"/>' & chr(10) & 
			chr(9) & '</recordlinkback>';
		variables.joFileWriter.writeLine(a);
		a=chr(9) & '<annotation show="1">' & chr(10) & 
			chr(9) & chr(9) & '<annotation_replyto_email value="#thisAddress#" />' & chr(10) & 
			chr(9) & '</annotation>';		
		variables.joFileWriter.writeLine(a);
		a=chr(9) & '<concepts>' & chr(10) & 
			chr(9) & '<concept order="1" viewlist="0" colorlist="0" datatype="darwin:relatedinformation"  alias="Related Information" />' & chr(10) & 
			chr(9) & chr(9) & '<concept order="2" viewlist="1" colorlist="1" datatype="darwin:scientificname" alias="Scientific Name"/>' & chr(10) & 
			chr(9) & chr(9) & '<concept order="3" viewlist="1" colorlist="0" datatype="char120_1" alias="Verbatim Date"/>' & chr(10) & 
			chr(9) & chr(9) & '<concept order="4" viewlist="1" colorlist="0" datatype="darwin:locality" alias="Specific Locality"/>' & chr(10) & 
			chr(9) & chr(9) & '<concept order="5" viewlist="0" colorlist="0" datatype="darwin:decimallatitude" alias="Decimal Latitude"/>' & chr(10) & 
			chr(9) & chr(9) & '<concept order="6" viewlist="0" colorlist="0" datatype="darwin:decimallongitude" alias="Decimal Longitude"/>' & chr(10) & 
			chr(9) & chr(9) & '<concept order="7" viewlist="1" colorlist="0" datatype="darwin:coordinateuncertaintyinmeters" alias="Coordinate Uncertainty In Meters"/>' & chr(10) & 
			chr(9) & chr(9) & '<concept order="8" viewlist="1" colorlist="0" datatype="darwin:horizontaldatum" alias="Horizontal Datum"/>' & chr(10) & 
			chr(9) & chr(9) & '<concept order="9" viewlist="0" colorlist="0" datatype="darwin:collectioncode" alias="Collection Code"/>' & chr(10) & 
			chr(9) & chr(9) & '<concept order="10" viewlist="1" colorlist="0" datatype="darwin:catalognumbertext" alias="Catalog Number"/>' & chr(10) & 
			chr(9) & chr(9) & '<concept order="11" viewlist="1" colorlist="0" datatype="darwin:collector" alias="Collector"/>' & chr(10) & 
			chr(9) & '</concepts>';		
		variables.joFileWriter.writeLine(a);
	</cfscript>
	<cfif isdefined("showRangeMaps") and showRangeMaps is true>
		<cfquery name="species" dbtype="query">
			select distinct(scientific_name) from getMapData
		</cfquery>
		<cfquery name="getClass" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select phylclass,genus || ' ' || species scientific_name from taxonomy where scientific_name in
			 (#ListQualify(valuelist(species.scientific_name), "'")#)
			 group by 
			 phylclass,genus || ' ' || species
		</cfquery>
		<cfif getClass.recordcount is not 1 or (
				getClass.phylclass is not 'Amphibia' and getClass.phylclass is not 'Mammalia' and getClass.phylclass is not 'Aves'
			)>
			<div class="error">
				Rangemaps are only available for queries which return one species in Classes
				Amphibia, Aves or Mammalia.
				<br>Subspecies are ignored for rangemapping.
				<br>You may use the BerkeleyMapper or Google Maps options for any query.
				<br>Please use your browser's back button or close this window.
			</div>
			<script>
				document.getElementById('status').style.display='none';
			</script>
			<cfabort>
		</cfif>
		<cfscript>
			a=chr(9) & '<gisdata>';
			variables.joFileWriter.writeLine(a);
		</cfscript>
		<cfset i=1>
		<cfloop query="getClass">			
			<cfif phylclass is 'Amphibia'>
				<cfset name='gaa'>
			<cfelseif phylclass is 'Mammalia'>
				<cfset name='mamm'>
			<cfelseif phylclass is 'Aves'>
				<cfset name='birds'>
			<cfelse>
				<cfset name="">
			</cfif>
			<cfif len(name) gt 0>
				<cfscript>
					a = chr(9) & chr(9) &	'<layer title="#getClass.scientific_name#" name="#name#" location="#getClass.scientific_name#" legend="#i#" active="1" url=""/>';
					variables.joFileWriter.writeLine(a);
				</cfscript>
			</cfif>
			<cfset i=i+1>	
		</cfloop>
		<cfscript>
			a = chr(9) & '</gisdata>';
			variables.joFileWriter.writeLine(a);
		</cfscript>
	</cfif>
	<cfscript>
		a='</bnhmmaps>';
		variables.joFileWriter.writeLine(a);
		variables.joFileWriter.close();	
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.localTabFile, variables.encoding, 32768);
	</cfscript>
	<cfloop query="getMapData">
		<cfscript>
			a='<a href="#Application.serverRootUrl#/SpecimenDetail.cfm?collection_object_id=' & 
				collection_object_id & '"' &
				'target="_blank">' & 
				collection & '&nbsp;' & cat_num & '</a>' & 
				chr(9) & scientific_name &
				chr(9) & verbatim_date & 
				chr(9) & spec_locality & 
				chr(9) & dec_lat & 
				chr(9) & dec_long &
				chr(9) & COORDINATEUNCERTAINTYINMETERS &
				chr(9) & datum & 
				chr(9) & collection &
				chr(9) & collection & ' ' & cat_num &
				chr(9) & collectors;
			variables.joFileWriter.writeLine(a);
		</cfscript>
	</cfloop>
	<cfscript>		
		variables.joFileWriter.close();
	</cfscript>	
	<cfquery name="distColl" dbtype="query">
		select collection from getMapData group by collection
		order by collection
	</cfquery>
	<cfset collList=''>
	<cfloop query="distColl">
		<cfif len(collList) is 0>
			<cfset collList="#collection#">
		<cfelse>
			<cfset CollList="#collList#, #collection#">
		</cfif>
	</cfloop>
	<cfset listColl=reverse(CollList)>
	<cfset listColl=replace(listColl,",","dna ,","first")>
	<cfset CollList=reverse(listColl)>
	<cfset CollList="#CollList# data.">
	<cfset bnhmUrl="http://berkeleymapper.berkeley.edu/run.php?ViewResults=tab&tabfile=#variables.remoteTabFile#&configfile=#variables.remoteXmlFile#&sourcename=#collList#&queryerrorcircles=1&maxerrorinmeters=1">
	<script type="text/javascript" language="javascript">
		document.location='#bnhmUrl#';
	</script>
</cfoutput>
