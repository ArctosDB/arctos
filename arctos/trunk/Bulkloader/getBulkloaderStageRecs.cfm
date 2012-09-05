<cfquery name="getCols" datasource="uam_god">
	select column_name from sys.user_tab_cols
	where table_name='BULKLOADER_STAGE' and
		column_name not in (
			'COLLECTION_ID','ENTERED_AGENT_ID','ENTEREDTOBULKDATE','C$LAT','C$LONG'
		)
	order by internal_column_id
</cfquery>
<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select * from BULKLOADER_STAGE		
</cfquery>
<cfoutput>
	<cfset colList = valuelist(getCols.column_name)>
	<cfset variables.fileName="#Application.webDirectory#/download/bulkloader_stage.csv">
	<cfset variables.encoding="UTF-8">
	<cfscript>
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
		variables.joFileWriter.writeLine(colList);
	</cfscript>
	<cfloop query="data">
		<cfset oneLine = "">
		<cfloop list="#colList#" index="c">
			<cfset thisData = evaluate(c)>
			<cfif len(oneLine) is 0>
				<cfset oneLine = '"#thisData#"'>
			<cfelse>
				<cfset thisData=replace(thisData,'"','""','all')>
				<cfset oneLine = '#oneLine#,"#thisData#"'>
			</cfif>
		</cfloop>
		<cfset oneLine = trim(oneLine)>
		<cfscript>
			variables.joFileWriter.writeLine(oneLine);
		</cfscript>
	</cfloop>
	<cfscript>	
		variables.joFileWriter.close();
	</cfscript>
</cfoutput>
