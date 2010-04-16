<cfinclude template = "/includes/functionLib.cfm">

<cfoutput>
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
	<cfelse>
		<cfquery name="n" dbtype="query">
			select distinct(scientific_name) n from d
		</cfquery>
	</cfif>
	<cfset internalPath="#Application.webDirectory#/bnhmMaps/tabfiles/">
	<cfset externalPath="#Application.ServerRootUrl#/bnhmMaps/tabfiles/">
	<cfset fn="#n.n#.kml">
		<cfset variables.encoding="UTF-8">

	<cfset variables.fileName=internalPath & fn>
	<cfscript>
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
		kml='<?xml version="1.0" encoding="UTF-8"?>' & chr(10) & 
			'<kml xmlns="http://earth.google.com/kml/2.2">' & chr(10) &
			chr(9) & '<Document>' & chr(10) &
			chr(9) & chr(9) & '<name>#n.n#</name>' & chr(10) &
			chr(9) & chr(9) & '<open>1</open>';
		variables.joFileWriter.writeLine(kml);      
	</cfscript>
	
	<cfloop query="d">
			
			<cfscript>
				kml=chr(9) & chr(9) & chr(9) & chr(9) & '<Placemark>  <name>#c# Specimens</name>
      <description>
        <![CDATA[
          <a href="http://arctos.database.museum/SpecimenResults.cfm?locality_id=#locality_id#&scientific_name=scientific_name##">Arctos</a>
        ]]>
      </description>
<Point>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<coordinates>#dec_long#,#dec_lat#</coordinates>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & '</Point></Placemark>';
				variables.joFileWriter.writeLine(kml);
				variables.joFileWriter.writeLine(kml);
			</cfscript>
		</cfloop>
		


	<cfscript>
		kml=chr(9) & '</Document>' & chr(10) &
			'</kml>';
		variables.joFileWriter.writeLine(kml);		
		variables.joFileWriter.close();
	</cfscript>
	
</cfoutput>