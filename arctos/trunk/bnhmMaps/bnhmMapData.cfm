<cfinclude template="/includes/alwaysInclude.cfm">
<div align="center">
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

<!----------------------------------------------------------------->
<cfif isdefined("action") and #action# IS "mapPoint">
	<!---- map a lat_long_id ---->
	<cfif not isdefined("lat_long_id") or len(#lat_long_id#) is 0>
		You can't map a point without a lat_long_id.
		<cfabort>
	</cfif>
	<cfoutput>
	<cfquery name="getMapData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT
			'All collections' Collection,
			0 collection_id,
			'000000' cat_num,
			'Lat Long ID: '||lat_long_id scientific_name,
			'none' verbatim_date,
			'none' spec_locality,
			dec_lat,
			dec_long,
			to_meters(max_error_distance,max_error_units) max_error_meters,
			datum,
			'000000' collection_object_id
		FROM lat_long WHERE
			lat_long_id=#lat_long_id#
	</cfquery>
	
	</cfoutput>
	
<cfelseif isdefined("action") and #action# IS "mapCfUserLoanItems">
	<cfif not isdefined("loan_id") OR len(#loan_id#) is 0>
		You didn't pass a loan ID!
		<cfabort>
	</cfif>
	<cfquery name="getMapData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT DISTINCT 
			collection,
			collection.collection_id,
			cat_num,
			identification.scientific_name,
			verbatim_date,
			spec_locality,
			dec_lat,
			dec_long,
			to_meters(max_error_distance,max_error_units) max_error_meters,
			datum,
			cataloged_item.collection_object_id
		FROM
			specimen_part,
			collection,
			cataloged_item,
			identification,
			cf_loan_item,
			cf_loan,
			collecting_event,
			locality,
			accepted_lat_long
		WHERE
			cataloged_item.collection_object_id = identification.collection_object_id AND
			sampled_from_obj_id is null and
			accepted_id_fg = 1 and
			cataloged_item.collection_id = collection.collection_id and
			cataloged_item.collection_object_id = specimen_part.derived_from_cat_item and
			cf_loan_item.loan_id = cf_loan.loan_id AND
			specimen_part.collection_object_id = cf_loan_item.collection_object_id and
			cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND 
			collecting_event.locality_id = locality.locality_id AND 
			locality.locality_id = accepted_lat_long.locality_id AND
			cf_loan_item.loan_id = #loan_id#
	</cfquery>
<cfelse><!--- regular mapping routine ---->
<!--- if they're mapping a specimen, turn observations on ---->
<cfif isdefined("collection_object_id") and len(#collection_object_id#) gt 0>
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
	#flatTableName#.collection_object_id">




<cfset basFrom = "	
FROM
	#flatTableName#">
<cfset basJoin = "INNER JOIN cataloged_item ON (#flatTableName#.collection_object_id =cataloged_item.collection_object_id)
INNER JOIN collecting_event flatCollEvent ON (#flatTableName#.collecting_event_id = flatCollEvent.collecting_event_id)">	
<cfset basWhere = " WHERE 
	dec_lat is not null AND
	dec_long is not null AND
	flatCollEvent.collecting_source = 'wild caught' ">			
<cfset basQual = "">
<cfif not isdefined("basJoin")>
	<cfset basJoin = "">
</cfif>
<cfinclude template="/includes/SearchSql.cfm">
<!---
<cfset SqlString = #basSelect# & #basFrom# & #basWhere# & #basQual#>
--->
<cfset SqlString = "#basSelect# #basFrom# #basJoin# #basWhere# #basQual#">	
<cfquery name="getMapData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	#preserveSingleQuotes(SqlString)#
</cfquery>
<cfoutput>
	<cf_getSearchTerms>
	<cfset log.query_string=returnURL>
	<cfset log.reported_count = #getMapData.RecordCount#>
	<cfinclude template="/includes/activityLog.cfm">
</cfoutput>
</cfif><!--- end point map option --->
<!-------------------------------------------->
<!---- write an XML config file specific to the critters they're mapping --->
<cfoutput>
	<cfset thisFileName = "BNHM#cftoken#.xml">
	<cfset thisFile = "#Application.webDirectory#/bnhmMaps/tabfiles/#thisFileName#">
	<cfset XMLFile = "#Application.serverRootUrl#/bnhmMaps/tabfiles/#thisFileName#">
	<cffile action="write" file="#thisFile#" addnewline="no" output="<bnhmmaps>">
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
	<cfset meta='<metadata>'>
	<cfset meta=meta & chr(10) & chr(9) & '<name>BerkeleyMapper Configuration File</name>'>
	<cfset meta=meta & chr(10) & chr(9) & '<relatedinformation>#Application.serverRootUrl#</relatedinformation>'>
	<cfset meta=meta & chr(10) & chr(9) & '<abstract> GIS configuration file for specimen query interface</abstract>'>
	<cfset meta=meta & chr(10) & chr(9) & '<mapkeyword keyword="specimens"/>'>
	<cfset meta=meta & chr(10) & chr(9) & '<header location="#Application.mapHeaderUrl#"/>'>
	<cfset meta=meta & chr(10) & chr(9) & '<linkbackheader location="#Application.serverRootUrl#"/>'>
	<cfset meta=meta & chr(10) & chr(9) & '<footer location="#Application.mapFooterUrl#"/>'>
	<cfset meta=meta & chr(10) & '</metadata>'>
	
	<cffile action="append" file="#thisFile#" addnewline="yes" output="#meta#">
	<!--- get coll codes --->
	<cfquery name="whatColls" dbtype="query">
		select Collection from getMapData
		group by Collection
	</cfquery>
	<cfset theseColls = valuelist(whatColls.Collection)>
<!--- 
	need something here for every collection in every installation of Arctos - 
	we'll have to make these data someday if Berkeleymapper doesn't get reasonable about legends
 --->
	<cfset colors = chr(10) & '<colors method="field" fieldname="darwin:collectioncode" label="Collection">'>
	<cfloop query="whatColls">
		<cfset colors=colors & chr(10) & chr(9)>
		<cfset colors=colors & '<color key="#collection#" red="#randRange(0,255)#" green="#randRange(0,255)#" blue="#randRange(0,255)#" symbol="1" label="#collection#"/>'>	
	</cfloop>
<!----
<!-------------------------- MVZ ------------------------------>	
	<cfif listcontains(theseColls,"MVZ Mamm",",")>
		<cfset colors = '#colors#
			
	</cfif>
	<cfif listcontains(theseColls,"MVZ Herp",",")>
		<cfset colors = '#colors#
			<color key="MVZ Herp" red="" green="255" blue="0" symbol="1" label="MVZ Herp Collection"/>'>	
	</cfif>
	<cfif listcontains(theseColls,"MVZ Page",",")>
		<cfset colors = '#colors#
			<color key="MVZ Page" red="" green="0" blue="255" symbol="1" label="MVZ Field Notebook Page"/>'>	
	</cfif>
	<cfif listcontains(theseColls,"MVZ Bird",",")>
		<cfset colors = '#colors#
			<color key="MVZ Bird" red="0" green="100" blue="100" symbol="1" label="MVZ Bird Collection"/>'>	
	</cfif>
	<cfif listcontains(theseColls,"MVZ Eggs",",")>
		<cfset colors = '#colors#
			<color key="MVZ Egg" red="120" green="0" blue="120" symbol="1" label="MVZ Egg/Nest Catalog"/>'>	
	</cfif>
	<cfif listcontains(theseColls,"MVZ Img",",")>
		<cfset colors = '#colors#
			<color key="MVZ Img" red="255" green="255" blue="120" symbol="1" label="MVZ Image Subject Catalog"/>'>	
	</cfif>
	<cfif listcontains(theseColls,"MVZ Hild",",")>
		<cfset colors = '#colors#
			<color key="MVZ Hild" red="64" green="120" blue="120" symbol="1" label="MVZ Hildebrand Collection"/>'>	
	</cfif>
<!----------------------------- WNMU ------------------------------->
<cfif listcontains(theseColls,"WNMU Mamm",",")>
		<cfset colors = '#colors#
			<color key="WNMU Mamm" red="255" green="0" blue="0" symbol="2" label="WNMU Mammal Collection"/>'>	
	</cfif>
	<cfif listcontains(theseColls,"WNMU Herb",",")>
		<cfset colors = '#colors#
			<color key="WNMU Herb" red="" green="255" blue="0" symbol="2" label="WNMU Plant Collection"/>'>	
	</cfif>
	<cfif listcontains(theseColls,"WNMU Herp",",")>
		<cfset colors = '#colors#
			<color key="WNMU Herp" red="" green="0" blue="255" symbol="2" label="WNMU Herptelogical Collection"/>'>	
	</cfif>
	<cfif listcontains(theseColls,"WNMU Bird",",")>
		<cfset colors = '#colors#
			<color key="WNMU Bird" red="0" green="100" blue="100" symbol="2" label="WNMU Bird Collection"/>'>	
	</cfif>	
<!------------------------ UAM ------------------------------------------>	
	<cfif listcontains(theseColls,"UAM Mamm",",")>
		<cfset colors = '#colors#
			<color key="UAM Mamm" red="255" green="0" blue="0" symbol="7" label="UAM Mammal Collection"/>'>	
	</cfif>
	<cfif listcontains(theseColls,"UAM Herb",",")>
		<cfset colors = '#colors#
			<color key="UAM Herb" red="" green="255" blue="0" symbol="7" label="ALA Plant Collection"/>'>	
	</cfif>
	<cfif listcontains(theseColls,"UAM Herp",",")>
		<cfset colors = '#colors#
			<color key="UAM Herp" red="" green="0" blue="255" symbol="7" label="UAM Herptelogical Collection"/>'>	
	</cfif>
	<cfif listcontains(theseColls,"UAM Bird",",")>
		<cfset colors = '#colors#
			<color key="UAM Bird" red="0" green="100" blue="100" symbol="7" label="UAM Bird Collection"/>'>	
	</cfif>
	<cfif listcontains(theseColls,"UAM Crus",",")>
		<cfset colors = '#colors#
			<color key="UAM Crus" red="120" green="0" blue="120" symbol="7" label="UAM Crustacean Collection"/>'>	
	</cfif>
	<cfif listcontains(theseColls,"UAM Ento",",")>
		<cfset colors = '#colors#
			<color key="UAM Ento" red="255" green="255" blue="120" symbol="7" label="UAM Entomology Collection"/>'>	
	</cfif>
	<cfif listcontains(theseColls,"UAM Bryo",",")>
		<cfset colors = '#colors#
			<color key="UAM Bryo" red="64" green="120" blue="120" symbol="7" label="UAM Bryozoan Collection"/>'>	
	</cfif>
	<cfif listcontains(theseColls,"UAM Moll",",")>
		<cfset colors = '#colors#
			<color key="UAM Moll" red="70" green="20" blue="70" symbol="7" label="UAM Mollusc Collection"/>'>	
	</cfif>
	<cfif listcontains(theseColls,"UAM Fish",",")>
		<cfset colors = '#colors#
			<color key="UAM Fish" red="0" green="0" blue="160" symbol="7" label="UAM Fish Collection"/>'>	
	</cfif>
	<cfif listcontains(theseColls,"KWP Ento",",")>
		<cfset colors = '#colors#
			<color key="KWP Ento" red="255" green="0" blue="255" symbol="6" label="KWP Lepidoptera Collection"/>'>	
	</cfif>
	<cfif listcontains(theseColls,"UAMObs Mamm",",")>
		<cfset colors = '#colors#
			<color key="UAMObs Mamm" red="255" green="0" blue="255" symbol="7" label="UAM Mammal Observations"/>'>	
	</cfif>
	
<!---- NBSB --->
	<cfif listcontains(theseColls,"NBSB Bird",",")>
		<cfset colors = '#colors#
			<color key="NBSB Bird" red="0" green="255" blue="255" symbol="4" label="NBSB Bird Collection"/>'>	
	</cfif>
<!--- MSB --->
	<cfif listcontains(theseColls,"MSB Mamm",",")>
		<cfset colors = '#colors#
			<color key="MSB Mamm" red="255" green="0" blue="0" symbol="3" label="MSB Mammal Collection"/>'>	
	</cfif>
	<cfif listcontains(theseColls,"MSB Bird",",")>
		<cfset colors = '#colors#
			<color key="MSB Bird" red="0" green="255" blue="0" symbol="3" label="MSB Bird Collection"/>'>	
	</cfif>
<!--- DGR --->
	<cfif listcontains(theseColls,"DGR Ento",",")>
		<cfset colors = '#colors#
			<color key="DGR Ento" red="255" green="0" blue="255" symbol="5" label="DGR Entomology Collection"/>'>	
	</cfif>
	<cfif listcontains(theseColls,"DGR Bird",",")>
		<cfset colors = '#colors#
			<color key="DGR Bird" red="0" green="255" blue="255" symbol="5" label="DGR Bird Collection"/>'>	
	</cfif>
	<cfif listcontains(theseColls,"DGR Mamm",",")>
		<cfset colors = '#colors#
			<color key="DGR Mamm" red="0" green="0" blue="255" symbol="5" label="DGR Mammal Collection"/>'>	
	</cfif>
	<cfif listcontains(theseColls,"DGR Herp",",")>
		<cfset colors = '#colors#
			<color key="DGR Herp" red="100" green="55" blue="100" symbol="5" label="DGR Herptile Collection"/>'>	
	</cfif>
	<cfif listcontains(theseColls,"DGR Fish",",")>
		<cfset colors = '#colors#
			<color key="DGR Fish" red="60" green="65" blue="130" symbol="5" label="DGR Fish Collection"/>'>	
	</cfif>
	
	
	<cfset colors = '#colors#
		
		

	'>
	<cffile action="append" file="#thisFile#" addnewline="yes" output="#colors#">
	---->
	<cfset colors=colors & chr(10) & chr(9) & '<color key="default" red="255" green="0" blue="0" symbol="2" label="Unspecified Collection"/>'>
	<cfset colors=colors & chr(10) & chr(9) & '<dominantcolor webcolor="9999cc"/>'>
	<cfset colors=colors & chr(10) & chr(9) & '<subdominantcolor webcolor="9999cc"/>'>
	<cfset colors=colors & chr(10) & '</colors>'>
	<cfset settings = '<settings>'>
	<cfset settings=settings & chr(10) & chr(9) &  '<setting name="landsat" show="0"></setting>'>
	<cfset settings=settings & chr(10) & chr(9) &  '<setting name="maxerrorinmeters" show="1"></setting>'>
	<cfset settings=settings & chr(10) & '</settings>'>
	<cfset settings=settings & chr(10) & '<recordlinkback>'>	
	<cfset settings=settings & chr(10) & chr(9) &  '<linkback method="entireurl" linkurl="Related Information"  fieldname="More Information (opens in new window)"/>'>
	<cfset settings=settings & chr(10) & '</recordlinkback>'>	
	<cffile action="append" file="#thisFile#" addnewline="yes" output="#settings#">
	
	<cfset anno='<annotation show="1">'>
	<cfset anno=anno & chr(10) & chr(9) & '<annotation_replyto_email value="#thisAddress#" />'>
	<cfset anno=anno & chr(10) & '</annotation>'>
	<cffile action="append" file="#thisFile#" addnewline="yes" output="#anno#">
	
	<cfset theRest = '<concepts>'>
	<cfset theRest=theRest & chr(10) & chr(9) & '<concept order="1" viewlist="0" colorlist="0" datatype="darwin:relatedinformation"  alias="Related Information" />'>
	<cfset theRest=theRest & chr(10) & chr(9) & '<concept order="2" viewlist="1" colorlist="1" datatype="darwin:scientificname" alias="Scientific Name"/>'>
	<cfset theRest=theRest & chr(10) & chr(9) & '<concept order="3" viewlist="1" colorlist="0" datatype="char120_1" alias="Verbatim Date"/>'>
	<cfset theRest=theRest & chr(10) & chr(9) & '<concept order="4" viewlist="1" colorlist="0" datatype="darwin:locality" alias="Specific Locality"/>'>
	<cfset theRest=theRest & chr(10) & chr(9) & '<concept order="5" viewlist="0" colorlist="0" datatype="darwin:decimallatitude" alias="Decimal Latitude"/>'>
	<cfset theRest=theRest & chr(10) & chr(9) & '<concept order="6" viewlist="0" colorlist="0" datatype="darwin:decimallongitude" alias="Decimal Longitude"/>'>
	<cfset theRest=theRest & chr(10) & chr(9) & '<concept order="7" viewlist="1" colorlist="0" datatype="darwin:coordinateuncertaintyinmeters" alias="Coordinate Uncertainty In Meters"/>'>
	<cfset theRest=theRest & chr(10) & chr(9) & '<concept order="8" viewlist="1" colorlist="0" datatype="darwin:horizontaldatum" alias="Horizontal Datum"/>'>
	<cfset theRest=theRest & chr(10) & chr(9) & '<concept order="9" viewlist="0" colorlist="0" datatype="darwin:collectioncode" alias="Collection Code"/>'>
	<cfset theRest=theRest & chr(10) & chr(9) & '<concept order="10" viewlist="1" colorlist="0" datatype="darwin:catalognumbertext" alias="Catalog Number"/>'>
	<cfset theRest=theRest & chr(10) & '</concepts>'>
	<cfif isdefined("showRangeMaps") and showRangeMaps is true>
		<cfdump var=#getMapData#>
		<cfquery name="species" dbtype="query">
			select distinct(scientific_name) from getMapData
		</cfquery>
		<cfdump var=#species#>
		<cfquery name="getClass" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select phylclass,scientific_name from taxonomy where scientific_name in
			 (#ListQualify(valuelist(species.scientific_name), "'")#)
		</cfquery>
		<cfdump var=#getClass#>
		<cfset g="<gisdata>">
		<cfset i=1>
		<cfloop query="getClass">
			<cfset name=''>
			<cfif phylclass is 'Amphibia'>
				<cfset name="gaa">
			<cfelseif phylclass is 'Mammalia'>
				<cfset name='mamm'>
			<cfelseif phylclass is 'Aves'>
				<cfset name='birds'>
			</cfif>
			<cfif len(name) gt 0>
				<cfset g=g & chr(10) & chr(9) & '<layer '>
				<cfset g=g & ' title="#scientific_name#" '>
				<cfset g=g & ' name="#name#" '>
				<cfset g=g & ' location="#scientific_name#" '>
				<cfset g=g & ' legend="#i#" '>
				<cfset g=g & ' active="1" '>
				<cfset g=g & ' url=""/> '>
				<cfset i=i+1>
			</cfif>			
		</cfloop>
		<cfset g=g & "</gisdata>">
		<cffile action="append" file="#thisFile#" addnewline="yes" output="#g#">	
	</cfif>
	<cfset theRest=theRest & chr(10) & '</bnhmmaps>'>
	<cffile action="append" file="#thisFile#" addnewline="yes" output="#theRest#">
</cfoutput>

<!-------------------------------------------->


<cfset dlPath = "#Application.webDirectory#/bnhmMaps/tabfiles/">
<cfset dlFile = "tabfile#cfid##cftoken#.txt">
<cffile action="write" file="#dlPath##dlFile#" addnewline="no" output="" nameconflict="overwrite">

<cfoutput query="getMapData">
	<cfset catalogNumber="#collection# #cat_num#">
	<cfset relInfo='<a href="#Application.serverRootUrl#/SpecimenDetail.cfm?collection_object_id=#collection_object_id#" target="_blank">#collection#&nbsp;#cat_num#</a>'>
	<cfset oneLine="#relInfo##chr(9)##scientific_name##chr(9)##verbatim_date##chr(9)##spec_locality##chr(9)##dec_lat##chr(9)##dec_long##chr(9)##COORDINATEUNCERTAINTYINMETERS##chr(9)##datum##chr(9)##collection##chr(9)##catalogNumber#">
		
		
	<cfset oneLine=trim(oneLine)>
	<cffile action="append" file="#dlPath##dlFile#" addnewline="yes" output="#oneLine#">
</cfoutput>
<cfoutput>
<cfquery name="distColl" dbtype="query">
	select collection from getMapData group by collection
	order by collection
</cfquery>
<cfset collList="">
<cfloop query="distColl">
	<cfif len(#collList#) is 0>
		<cfset collList="#collection#">
	<cfelse>
		<cfset CollList="#collList#, #collection#">
	</cfif>
</cfloop>
<cfset listColl=reverse(CollList)>
<cfset listColl=replace(listColl,",","dna ,","first")>
<cfset CollList=reverse(listColl)>
<cfset CollList="#CollList# data.">


	<cfset bnhmUrl="http://berkeleymapper.berkeley.edu/run.php?ViewResults=tab&tabfile=#Application.serverRootUrl#/bnhmMaps/tabfiles/#dlFile#&configfile=#XMLFile#&sourcename=#collList#&queryerrorcircles=1">
	<!----
	#bnhmUrl#
	<cfabort>
	
	<cfif isdefined("session.username") and #session.username# is "dlm">
	<cfdump var="#variables#">
	
	<cfabort></cfif>
	---->
	
	
	
	
	<script type="text/javascript" language="javascript">
		document.location='#bnhmUrl#';
	</script>
</cfoutput>