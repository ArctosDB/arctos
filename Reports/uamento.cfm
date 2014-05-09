<cfinclude template="/includes/_header.cfm">
<cfquery name="raw" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select
		flat.guid,
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
		flat.FORMATTED_SCIENTIFIC_NAME SCI_NAME_WITH_AUTH,
		flat.SUBFAMILY,
		flat.TRIBE,
		flat.SCIENTIFIC_NAME,
		flat.FAMILY,
		concatpartbarcode(flat.collection_object_id) barcodes,
		flat.COLL_EVENT_REMARKS,
		identification.identification_id,
		identification.identification_remarks
	from
		flat,
		identification,
		#session.specsrchtab#
	where
		flat.collection_object_id=identification.collection_object_id and
		flat.collection_object_id=#session.specsrchtab#.collection_object_id
</cfquery>
<cfquery name="getData" dbtype="query">
	select CAT_NUM,barcodes,COLLECTING_METHOD,COLLECTORS,COUNTRY,STATE_PROV,HABITAT,MIN_ELEV_IN_M,MAX_ELEV_IN_M,SPEC_LOCALITY,BEGAN_DATE,ENDED_DATE,DEC_LAT,DEC_LONG,COORDINATEUNCERTAINTYINMETERS,PHYLORDER,PHYLCLASS,ID_DATE,IDENTIFIED_BY,SCI_NAME_WITH_AUTH,SUBFAMILY,TRIBE,SCIENTIFIC_NAME,FAMILY,COLL_EVENT_REMARKS
	from raw group by
	CAT_NUM,barcodes,COLLECTING_METHOD,COLLECTORS,COUNTRY,STATE_PROV,HABITAT,MIN_ELEV_IN_M,MAX_ELEV_IN_M,SPEC_LOCALITY,BEGAN_DATE,ENDED_DATE,DEC_LAT,DEC_LONG,COORDINATEUNCERTAINTYINMETERS,PHYLORDER,PHYLCLASS,ID_DATE,IDENTIFIED_BY,SCI_NAME_WITH_AUTH,SUBFAMILY,TRIBE,SCIENTIFIC_NAME,FAMILY,COLL_EVENT_REMARKS
</cfquery>
<cfquery name="idrem" dbtype="query">
	select guid,identification_remarks, count(*) as numIDs from raw  group by guid,identification_remarks
</cfquery>
<cfset basheader='CAT_NUM,barcodes,COLLECTING_METHOD,COLLECTORS,COUNTRY,STATE_PROV,HABITAT,MIN_ELEV_IN_M,MAX_ELEV_IN_M,SPEC_LOCALITY,BEGAN_DATE,ENDED_DATE,DEC_LAT,DEC_LONG,COORDINATEUNCERTAINTYINMETERS,PHYLORDER,PHYLCLASS,ID_DATE,IDENTIFIED_BY,SCI_NAME_WITH_AUTH,SUBFAMILY,TRIBE,SCIENTIFIC_NAME,FAMILY,COLL_EVENT_REMARKS'>
<cfquery name="mid" dbtype="query">
	select max(numIDs) mnid from idrem
</cfquery>

<cfoutput>

		<cfset header=basheader>



<cfdump var=#mid#>
<cfset maxNumIDRemark=mid.mnid>
<cfif maxNumIDRemark gt 0>
maxNumIDRemark: #maxNumIDRemark#
	<cfloop from="1" to="#maxNumIDRemark#" index="i">
		<cfset header='#header#,id_remark_#i#'>
	</cfloop>
</cfif>




<cfdump var=#idrem#>

<cfset fname = "uamento.csv">
<cfset variables.fileName="#Application.webDirectory#/download/#fname#">
<cfset variables.encoding="UTF-8">
<cfscript>
	variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
	variables.joFileWriter.writeLine(header);
</cfscript>
<cfloop query="getData">
	<cfset oneLine = "">
	<cfloop list="#basheader#" index="c" delimiters=",">
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

<a href="/download.cfm?file=#fname#">/download.cfm?file=#fname#</a>
<!-----
<cflocation url="/download.cfm?file=#fname#" addtoken="false">
---->
</cfoutput>