<cfinclude template = "/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfset title="Specimen Results Summary">
<cfset basSelect = " SELECT COUNT(distinct(#session.flatTableName#.collection_object_id)) CountOfCatalogedItem,#groupby#">
<cfset basFrom = " FROM #session.flatTableName#">
<cfset basJoin = "">
<cfset basWhere = " WHERE #session.flatTableName#.collection_object_id IS NOT NULL ">	
<cfset basQual = "">
<cfset mapurl="">
<cfinclude template="includes/SearchSql.cfm">
<!--- wrap everything up in a string --->
<cfset SqlString = "#basSelect# #basFrom# #basJoin# #basWhere# #basQual# group by #groupby#">
<cfset sqlstring = replace(sqlstring,"flatTableName","#session.flatTableName#","all")>
<!--- require some actual searching --->
<cfset srchTerms="">
<cfloop list="#mapurl#" delimiters="&" index="t">
	<cfset tt=listgetat(t,1,"=")>
	<cfset srchTerms=listappend(srchTerms,tt)>
</cfloop>
<!--- remove standard criteria that kill Oracle... --->
<cfif listcontains(srchTerms,"ShowObservations")>
	<cfset srchTerms=listdeleteat(srchTerms,listfindnocase(srchTerms,'ShowObservations'))>
</cfif>
<cfif listcontains(srchTerms,"collection_id")>
	<cfset srchTerms=listdeleteat(srchTerms,listfindnocase(srchTerms,'collection_id'))>
</cfif>
<!--- ... and abort if there's nothing left --->
<cfif len(srchTerms) is 0>
	<CFSETTING ENABLECFOUTPUTONLY=0>			
	<font color="##FF0000" size="+2">You must enter some search criteria!</font>	  
	<cfabort>
</cfif>

<cfset checkSql(SqlString)>
<cfif isdefined("debug") and debug is true>
	#preserveSingleQuotes(SqlString)#
</cfif>
<cfquery name="getData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	#preserveSingleQuotes(SqlString)#
</cfquery>
<cfoutput>
	

<cfset dlPath = "#Application.DownloadPath#">
<cfset variables.encoding="UTF-8">
<cfset variables.fileName="#Application.webDirectory#/download/ArctosSpecimenSummary.csv">
<cfset header ="Count,#groupBy#,Link">
<cfscript>
	variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
	variables.joFileWriter.writeLine(ListQualify(header,'"')); 
</cfscript>
<table border id="t" class="sortable">
	<tr>
		<th>Count</th>
		<cfloop list="#groupby#" index="x">
			<th>#x#</th>
		</cfloop>
		<th>Specimens</th>
	</tr>
	<cfloop query="getData">
		<cfset thisLink=mapurl>
		<cfset oneLine='"#COUNTOFCATALOGEDITEM#","/SpecimenResults.cfm?#thisLink#"'>
		<tr>
			<td>#COUNTOFCATALOGEDITEM#</td>
			<cfloop list="#groupby#" index="x">
				<cfif len(evaluate("getData." & x)) is 0>
					<cfset thisVal='NULL'>
				<cfelse>
					<cfset thisVal=evaluate("getData." & x)>
				</cfif>
				<cfset thisLink=listappend(thisLink,thisVal,"&")>
				<cfset oneLine=oneline & ',"#thisVal#"'>
				<td>#thisVal#</td>
			</cfloop>
			<cfset oneLine=oneline & ',"#thisLink#"'>
			<cfscript>
				variables.joFileWriter.writeLine(oneLine); 
			</cfscript>
			<td><a href="/SpecimenResults.cfm?#thisLink#">specimens</a>
		</tr>
	</cfloop>
</table>
	


	<cfscript>	
		variables.joFileWriter.close();
	</cfscript>
	
	<a href="/download.cfm?file=ArctosSpecimenSummary.csv">get CSV</a>
	
	
	
</cfoutput>



<cfinclude template = "includes/_footer.cfm">