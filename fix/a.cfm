<cfoutput>
	<cfset dlFile = "test.kml">
	<cfset internalPath="#Application.webDirectory#/bnhmMaps/tabfiles/">
<cfset externalPath="#Application.ServerRootUrl#/bnhmMaps/tabfiles/">

	<cfset variables.fileName="#internalPath##dlFile#">
	<cfset variables.encoding="UTF-8">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			FLAT.guid,
			FLAT.dec_lat,
			FLAT.dec_long,
			FLAT.scientific_name
		from
		 	FLAT
		 where
		 	FLAT.dec_lat is not null
		 	and rownum < 100
	</cfquery>
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
		<cfscript>
			kml=chr(9) & chr(9) & '<Folder>' & chr(10) &
				chr(9) & chr(9) & chr(9) & '<name>everything</name>' & chr(10) &
				chr(9) & chr(9) & chr(9) & '<visibility>1</visibility>';
			variables.joFileWriter.writeLine(kml);
		</cfscript>	
		
		<cfloop query="data">
		
		
			<cfscript>
				kml=chr(9) & chr(9) & chr(9) & '<Placemark>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & '<name>#guid#</name>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & '<visibility>1</visibility>' & 
					chr(9) & chr(9) & chr(9) & chr(9) & '<Point>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<coordinates>#dec_long#,#dec_lat#</coordinates>' & chr(10) &
					chr(9) & chr(9) & chr(9) & chr(9) & '</Point>';
				variables.joFileWriter.writeLine(kml);
				kml=chr(9) & chr(9) & chr(9) & chr(9) & '<styleUrl>##green-star</styleUrl>';
				kml=kml & chr(10) &
					chr(9) & chr(9) & chr(9) & '</Placemark>';
				variables.joFileWriter.writeLine(kml);
			
			
		</cfscript>
	</cfloop>
	
	
	<cfscript>
	
kml=chr(9) & chr(9) & '</Folder>';
			variables.joFileWriter.writeLine(kml);


		kml=chr(9) & '</Document>' & chr(10) &
			'</kml>';
		variables.joFileWriter.writeLine(kml);
		variables.joFileWriter.close();
	</cfscript>

<a href="#externalPath#/#dlFile#"#externalPath#/#dlFile#</a>

	</cfoutput>