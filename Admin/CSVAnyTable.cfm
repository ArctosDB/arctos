<cfsetting requestTimeOut = "600">
<cfoutput>
	<cfif not isdefined("tableName") or len(tableName) is 0>
		<form method="get" action="CSVAnyTable.cfm">
			<label for="tableName">Table</label>
			<input type="text" name="tableName" id="tableName">
			<br><input type="submit" value="get csv">
		</form>
	</cfif>
	<cfif isdefined("tableName") and len(tableName) gt 0>
		<cfquery name="getData" datasource="uam_god">
			select * from #tableName#
		</cfquery>
		<cfset ac = getData.columnList>
		<cfset fileDir = "#Application.webDirectory#">
		<cfset variables.encoding="UTF-8">
		<cfset fname = "#tableName#.csv">
		<cfset variables.fileName="#Application.webDirectory#/download/#fname#">
		<cfset header=trim(ac)>
		<cfscript>
			variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
			variables.joFileWriter.writeLine(header);
		</cfscript>
		<cfloop query="getData">
			<cfset oneLine = "">
			<cfloop list="#ac#" index="c">
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
		<cflocation url="/download.cfm?file=#fname#" addtoken="false">
		<a href="/download/#fname#">Click here if your file does not automatically download.</a>
	</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">