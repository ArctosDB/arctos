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
<cfset mediaFlatTableName = "t_media_flat">
<!----------------------------------------------------------------->
<cfoutput>
	
	<cfset srch = "">
	<cfinclude template="/development/MediaSearchSql.cfm">
	<cfset sqlS = "SELECT * FROM #mediaFlatTableName# WHERE 1=1 #srch# and coordinates is not null">
	
	#sqlS#
	<cfquery name = "tempMapData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preserveSingleQuotes(sqlS)#
	</cfquery>
	<cfdump var=#tempMapData#>
	<cfset md=queryNew("media_id,lat,long,desc,media_type,media_id,media_uri")>
	<cfset i=1>
	<cfloop query="tempMapData">
		<cfif listlen(coordinates,",") is 2>
			<cfset desc=''>
			<cfset t=queryAddRow(md,1)>
			<cfset temp = QuerySetCell(md, "media_id", media_id, i)>
			<cfset la=listgetat(coordinates,1)>
			<cfset lo=listgetat(coordinates,2)>
			<cfset temp = QuerySetCell(md, "lat", la, i)>
			<cfset temp = QuerySetCell(md, "long", lo, i)>
			<cfloop list="#labels#" index="l" delimiters="|">
				<cfif left(l,13) is 'description=='>
					<cfset desc=replace(l,'description==','')>
				</cfif>
			</cfloop>
			<cfset temp = QuerySetCell(md, "desc", desc, i)>
			<cfset temp = QuerySetCell(md, "media_type", media_type, i)>
			<cfset temp = QuerySetCell(md, "media_uri", media_uri, i)>
		</cfif>
		<cfset i=i+1>
	</cfloop>
	
	<!---
	<cfset temp = queryAddColumn(tempMapData,"labels", "VarChar", ArrayNew(1))>		
	<cfset temp = queryAddcolumn(tempMapData,"lat", "VarChar", ArrayNew(1))>
	<cfset temp = queryAddcolumn(tempMapData,"long", "VarChar", ArrayNew(1))>
	<cfset temp = queryAddcolumn(tempMapData,"datum", "VarChar", ArrayNew(1))>
	
			
	<cfset i=1>	
	<cfloop query ="tempMapData">
		<cfset labs = ListToArray(media_labels, ";")>
		<cfset lab_values = ListToArray(label_values, ";")>
		
		<cfset label_string = "">
		<cfloop from="1" to="#arraylen(labs)#" index="index">
			
			<cfif len(label_string) gt 0>
				<cfset label_string = label_string & "; " & labs[index] & "=" & lab_values[index]>
			<cfelse>
				<cfset label_string = labs[index] & "=" & lab_values[index]>
			</cfif>
		</cfloop>
		<cfset temp = QuerySetCell(tempMapData, "labels", label_string, i)>
		
		<cfset scPos = find(';', lat_long)>
		<cfif scPos gt 0>
			<cfset latS = left(lat_long, scPos-1)>
			<cfset longS = right(lat_long, len(lat_long) - scPos)>
			<cfset temp = QuerySetCell(tempMapData, "lat", latS, i)>
			<cfset temp = QuerySetCell(tempMapData, "long", longS, i)>
		</cfif>
		
		<cfset i=i+1>
	</cfloop>

	<cfquery name="getMapData" dbtype="query">
		select media_id,
				collecting_object_id,
				media_type,
				mime_type,
				cat_num,
				guid_string,	
				scientific_name,
				created_agent as created_by_agent,
				locality as created_from_collecting_event,
				lat as latitude,		
				long as longitude,
				labels,
				project_name as associated_with_project,
				shows_loc_name as shows_locality,	
				publication_name as shows_publication,
				taxonomy_description as describes_taxonomy,					
				media_uri,		
				preview_uri				
		from tempMapData
		where lat is not null AND
			long is not null
	</cfquery>
	
	---->

<cfif md.recordcount is 0>
	<div class="error">
		Oops! We didn't find anything mappable. Only wild caught specimens with coordintes will map.
		File a <a href='/info/bugs.cfm'>bug report</a> if you think this message is in error.
	</div>
	<cfabort>
</cfif>
<!---
<!---- write an XML config file specific to the critters they're mapping --->
	<cfquery name="collID" dbtype="query">
		select collecting_object_id from getMapData where collecting_object_id is not null group by collecting_object_id
	</cfquery>
--->
	<cfset thisAddress = #Application.DataProblemReportEmail#>
<!---	
	<cfif len(valuelist(collID.collecting_object_id)) gt 0>
		<cfquery name="whatEmails" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select address from
				electronic_address,
				collection_contacts
			WHERE
				electronic_address.agent_id = collection_contacts.contact_agent_id AND
				collection_contacts.collection_id IN (#valuelist(collID.collecting_object_id)#) AND
				address_type='e-mail' AND
				contact_role='data quality'
			GROUP BY address
		</cfquery>
		<cfloop query="whatEmails">
			<cfset thisAddress = listappend(thisAddress,address)>
		</cfloop>
	</cfif>	
	
--->
	<cfscript>
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.localXmlFile, variables.encoding, 32768);
		a='<bnhmmaps>' & chr(10) & 
			chr(9) & '<metadata>' & chr(10) & 
			chr(9) & chr(9) & '<name>BerkeleyMapper Configuration File</name>' & chr(10) & 
			chr(9) & chr(9) & '<relatedinformation>#Application.serverRootUrl#</relatedinformation>' & chr(10) & 
			chr(9) & chr(9) & '<abstract>GIS configuration file for media query interface</abstract>' & chr(10) & 
			chr(9) & chr(9) & '<mapkeyword keyword="media"/>' & chr(10) & 
			chr(9) & chr(9) & '<header location="#Application.mapHeaderUrl#"/>' & chr(10) & 
			chr(9) & chr(9) & '<linkbackheader location="#Application.serverRootUrl#"/>' & chr(10) & 
			chr(9) & chr(9) & '<footer location="#Application.mapFooterUrl#"/>' & chr(10) & 
			chr(9) & chr(9) & '<charset name="UTF-8"></charset>' & chr(10) & 
			chr(9) &'</metadata>';
		variables.joFileWriter.writeLine(a);
	</cfscript>


	<cfscript>
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
			chr(9) & chr(9) & '<concept order="2" viewlist="1" colorlist="0" datatype="char120_1" alias="Media Type"/>' & chr(10) & 
			//chr(9) & chr(9) & '<concept order="3" viewlist="1" colorlist="0" datatype="darwin:catalognumbertext" alias="Catalog Number"/>' & chr(10) & 
			//chr(9) & chr(9) & '<concept order="4" viewlist="1" colorlist="0" datatype="darwin:scientificname" alias="Scientific Name"/>' & chr(10) & 
			//chr(9) & chr(9) & '<concept order="5" viewlist="0" colorlist="0" datatype="darwin:collector" alias="Collector"/>' & chr(10) &   
			//chr(9) & chr(9) & '<concept order="6" viewlist="0" colorlist="0" datatype="char120_2" alias="Project Name"/>' & chr(10) &
			//chr(9) & chr(9) & '<concept order="7" viewlist="1" colorlist="0" datatype="darwin:locality" alias="Created from Collecting Event"/>' & chr(10) & 
			//chr(9) & chr(9) & '<concept order="8" viewlist="0" colorlist="0" datatype="char120_3" alias="Shows Locality"/>' & chr(10) & 
			//chr(9) & chr(9) & '<concept order="9" viewlist="0" colorlist="0" datatype="char120_4" alias="Shows Publication"/>' & chr(10) & 
			//chr(9) & chr(9) & '<concept order="10" viewlist="0" colorlist="0" datatype="char120_5" alias="Describes Taxonomy"/>' & chr(10) & 
			chr(9) & chr(9) & '<concept order="11" viewlist="0" colorlist="0" datatype="char120_6" alias="Media uri"/>' & chr(10) & 
			chr(9) & chr(9) & '<concept order="12" viewlist="0" colorlist="0" datatype="darwin:decimallatitude" alias="Decimal Latitude"/>' & chr(10) & 
			chr(9) & chr(9) & '<concept order="13" viewlist="0" colorlist="0" datatype="darwin:decimallongitude" alias="Decimal Longitude"/>' & chr(10) & 
			chr(9) & '</concepts>';		
		variables.joFileWriter.writeLine(a);
	</cfscript>


	<cfscript>
		a='</bnhmmaps>';
		variables.joFileWriter.writeLine(a);
		variables.joFileWriter.close();	
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.localTabFile, variables.encoding, 32768);
	</cfscript>
	<cfloop query="md">
		<cfscript>
			a='<a href="#Application.serverRootUrl#/development/MediaSearch.cfm?action=search&media_id=' & 
				media_id & '"' &
				'target="_blank">' & 'Media' & '&nbsp;' & media_id & '</a>' & 
				chr(9) & media_type &
				//chr(9) & cat_num & 
				//chr(9) & scientific_name &
				//chr(9) & created_by_agent &  
				//chr(9) & associated_with_project &
				//chr(9) & created_from_collecting_event &
				//chr(9) & shows_locality &
				//chr(9) & shows_publication &
				//chr(9) & describes_taxonomy &
				chr(9) & media_uri & 
				chr(9) & latitude &
				chr(9) & longitude;
			variables.joFileWriter.writeLine(a);
		</cfscript>
	</cfloop>
	<cfscript>		
		variables.joFileWriter.close();
	</cfscript>		

	<cfset collList='Media Results'>

	<cfset bnhmUrl="http://berkeleymapper.berkeley.edu/run.php?ViewResults=tab&tabfile=#variables.remoteTabFile#&configfile=#variables.remoteXmlFile#&sourcename=#collList#&queryerrorcircles=1&maxerrorinmeters=1">
	<script type="text/javascript" language="javascript">
		document.location='#bnhmUrl#';
	</script>
</cfoutput>
