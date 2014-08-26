<cfinclude template="/includes/_header.cfm">
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
		<cfset  util = CreateObject("component","component.utilities")>
		<cfset csv = util.QueryToCSV2(Query=getData,Fields=getData.columnlist)>
		<cffile action = "write"
		    file = "#Application.webDirectory#/download/#tableName#.csv"
	    	output = "#csv#"
	    	addNewLine = "no">
		<cflocation url="/download.cfm?file=#tableName#.csv" addtoken="false">
	</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">