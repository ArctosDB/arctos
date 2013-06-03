<cfinclude template="/includes/_header.cfm">
<cfquery name="getData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select
		flat.CAT_NUM,
		flat.COLLECTING_METHOD,
		flat.COLLECTORS,
		flat.COUNTRY,
		flat.STATE_PROV,
		flat.HABITAT,
		flat.MIN_ELEV_IN_M,
		flat.MAX_ELEV_IN_M,
		flat.SPEC_LOCALITY,
		flat.BEGAN_DATE,
		flat.ENDED_DATE,
		flat.DEC_LAT,
		flat.DEC_LONG,
		flat.COORDINATEUNCERTAINTYINMETERS,
		flat.PHYLORDER,
		flat.PHYLCLASS,
		flat.MADE_DATE ID_DATE,
		flat.IDENTIFIEDBY IDENTIFIED_BY,
		get_taxonomy(flat.collection_object_id,'display_name') SCI_NAME_WITH_AUTH,
		get_taxonomy(flat.collection_object_id,'SUBFAMILY') SUBFAMILY,
		get_taxonomy(flat.collection_object_id,'tribe') TRIBE,
		flat.SCIENTIFIC_NAME,
		flat.FAMILY,
		concatpartbarcode(flat.collection_object_id) barcodes,
		flat.COLL_EVENT_REMARKS
	from
		flat,
		#session.specsrchtab#
	where
		flat.collection_object_id=#session.specsrchtab#.collection_object_id
</cfquery>
<cfoutput>
<cfset fname = "uamento.csv">
<cfset variables.fileName="#Application.webDirectory#/download/#fname#">
<cfset variables.encoding="UTF-8">
<cfset header='CAT_NUM,barcodes,COLLECTING_METHOD,COLLECTORS,COUNTRY,STATE_PROV,HABITAT,MIN_ELEV_IN_M,MAX_ELEV_IN_M,SPEC_LOCALITY,BEGAN_DATE,ENDED_DATE,DEC_LAT,DEC_LONG,COORDINATEUNCERTAINTYINMETERS,PHYLORDER,PHYLCLASS,ID_DATE,IDENTIFIED_BY,SCI_NAME_WITH_AUTH,SUBFAMILY,TRIBE,SCIENTIFIC_NAME,FAMILY,COLL_EVENT_REMARKS'>
<cfscript>
	variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
	variables.joFileWriter.writeLine(header);
</cfscript>
<cfloop query="getData">
	<cfset oneLine = "">
	<cfloop list="#header#" index="c" delimiters=",">
		<cfset thisData = evaluate("getData." & c)>
		<cfset thisData=replace(thisData,'"','""','all')>
		<cfif len(oneLine) is 0>
			<cfset oneLine = '"#thisData#"'>
		<cfelse>
			<cfset oneLine = '#oneLine#,"#thisData#"'>
		</cfif>
		<cfset oneLine = trim(oneLine)>
	</cfloop>
	<cfscript>
		variables.joFileWriter.writeLine(oneLine);
	</cfscript>
</cfloop>
<cfscript>
	variables.joFileWriter.close();
</cfscript>
<cflocation url="/download.cfm?file=#fname#" addtoken="false">
</cfoutput>