<cfinclude template = "/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfset title="Specimen Results Summary">
<cfif not isdefined("groupBy") or len(groupBy) is 0>
	<cfset groupBy='scientific_name'>
</cfif>
<cfoutput>
	<cfset groupBy=listprepend(groupby,"collection_object_id")>
	<cfset prefixed_cols="">
	<cfloop list="#groupBy#" index="x">
		<cfset prefixed_cols = listappend(prefixed_cols,"#session.flatTableName#.#x#")>
	</cfloop>
	<cfset basSelect = " SELECT #prefixed_cols# ">
	<cfset basFrom = " FROM #session.flatTableName#">
	<cfset basJoin = "">
	<cfset basWhere = " WHERE #session.flatTableName#.collection_object_id IS NOT NULL ">
	<cfset basQual = "">
	<cfset mapurl="">
	<cfinclude template="includes/SearchSql.cfm">
	<cfset SqlString = "#basSelect# #basFrom# #basJoin# #basWhere# #basQual# group by #prefixed_cols#">
	<cfset group_cols = groupBy>
	<cfset group_cols=listdeleteat(group_cols,listfindnocase(group_cols,'collection_object_id'))>	
	<cfif listfindnocase(group_cols,'individualcount')>
		<cfset group_cols=listdeleteat(group_cols,listfindnocase(group_cols,'individualcount'))>
	</cfif>
	<cfset InnerSqlString = 'select COUNT(collection_object_id) CountOfCatalogedItem, '>
	<cfif listfindnocase(groupBy,'individualcount')>
		<cfset InnerSqlString = InnerSqlString & 'sum(individualcount) individualcount, '>
	</cfif>
	<cfset InnerSqlString = InnerSqlString & '#group_cols# from (#SqlString#) group by #group_cols# order by #group_cols#'>
	<!--- require some actual searching --->
	<cfset srchTerms="">
	<cfloop list="#mapurl#" delimiters="&" index="t">
		<cfset tt=listgetat(t,1,"=")>
		<cfset srchTerms=listappend(srchTerms,tt)>
	</cfloop>
	<!--- remove standard criteria that kill Oracle... --->
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
		#preserveSingleQuotes(InnerSqlString)#
	</cfif>
	<cfquery name="getData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		#preserveSingleQuotes(InnerSqlString)#
	</cfquery>
	<cfset dlPath = "#Application.DownloadPath#">
	<cfset variables.encoding="UTF-8">
	<cfset variables.fileName="#Application.webDirectory#/download/ArctosSpecimenSummary.csv">
	<cfset header ="Count,">
	<cfif basSelect contains "individualcount">
		<cfset header=header & ',IndividualCount'>
	</cfif>
	<cfset header=header & "#groupBy#,Link">
	<cfscript>
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
		variables.joFileWriter.writeLine(ListQualify(header,'"'));
	</cfscript>
	<span class="controlButton"	onclick="saveSearch('#Application.ServerRootUrl#/SpecimenResultsSummary.cfm?#mapURL#&groupBy=#groupBy#');">Save&nbsp;Search</span>
	<a href="/saveSearch.cfm?action=manage">[ view/manage your saved searches ]</a>
	<table border id="t" class="sortable">
		<tr>
			<th>Count</th>
			<cfif basSelect contains "individualcount">
				<th>IndividualCount</th>
			</cfif>
			<cfloop list="#group_cols#" index="x">
				<cfif x is "phylclass">
					<cfset x="Class">
				<cfelseif x is "phylorder">
					<cfset x="Order">
				</cfif>
				<th>#x#</th>
			</cfloop>
			<th>Specimens</th>
		</tr>
		<cfloop query="getData">
			<cfset thisLink=mapurl>
			<cfset oneLine='"#COUNTOFCATALOGEDITEM#"'>
			<cfif basSelect contains "individualcount">
				<cfset oneLine=oneLine & ',"#individualcount#"'>
			</cfif>
			<!---
				mapURL probably contains taxon_scope
				We have to over-ride that here to get the
				correct links - eg, the no-subspecies name
				should not contain all the subspecies
			---->
			<cfif thisLink contains "scientific_name_match_type">
				<cfset delPos=listcontains(thisLink,"scientific_name_match_type=","?&")>
				<cfset thisLink=listdeleteat(thisLink,delPos,"?&")>
			</cfif>
			<cfset thisLink="#thisLink#&scientific_name_match_type=exact">			
			<tr>
				<td>#COUNTOFCATALOGEDITEM#</td>
				<cfif basSelect contains "individualcount">
					<td>#individualcount#</td>
				</cfif>
				<cfloop list="#group_cols#" index="x">
					<cfif len(evaluate("getData." & x)) is 0>
						<cfset thisVal='NULL'>
					<cfelse>
						<cfset thisVal=evaluate("getData." & x )>
					</cfif>
					
					<cfif thisLink contains x>
						<!--- 
							they searched for something that they also grouped by
							REMOVE the thing they searched (eg, more general)
							ADD the thing grouped (eg, more specific)
						---->

						<!--- replace search terms with stuff here ---->
						<cfset delPos=listcontainsnocase(thisLink,x,"?&")>
						<cfset thisLink=listdeleteat(thisLink,delPos,"?&")>
						<cfset thisLink=listappend(thisLink,"#x#=#thisVal#","&")>
					</cfif>
					<!----
					
					why was this commented out?? Hopefully adding it doesn't break something evil! without it, 
					/SpecimenResultsSummary.cfm?state_prov=Alaska&collection_id=1&groupBy=species&debug=1
					
					just returns everything, NOT species-only
					
					---->
					<cfif thisLink does not contain x>
						<cfset thisLink=listappend(thisLink,"#x#=#thisVal#","&")>
					</cfif>
					<!---- end mysterious comment ----->
					<cfset oneLine=oneline & ',"#thisVal#"'>
					<td>#thisVal#</td>
				</cfloop>
				<cfset thisLink=replace(thisLink,"##","%23","all")>
				<cfset thisLink=replace(thisLink,"?&","?","all")>
				<cfset thisLink=replace(thisLink,"&&","&","all")>
				<cfset oneLine=oneline & ',"#Application.serverRootUrl#/SpecimenResults.cfm?#thisLink#"'>
				
				<cfscript>
					variables.joFileWriter.writeLine(oneLine);
				</cfscript>
				<td><a href="/SpecimenResults.cfm?#thisLink#">specimens</a></td>
			</tr>
		</cfloop>
	</table>
	<cfscript>
		variables.joFileWriter.close();
	</cfscript>
	<a href="/download.cfm?file=ArctosSpecimenSummary.csv">get CSV</a>
</cfoutput>
<cfinclude template = "includes/_footer.cfm">