<cfinclude template = "/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfset title="Specimen Results Summary">
<cfif not isdefined("groupBy") or len(groupBy) is 0>
	<cfset groupBy='scientific_name'>
</cfif>
<cfoutput>
	<cfif not listfindnocase(groupby,'collection_object_id')>
		<cfset groupBy=listprepend(groupby,"collection_object_id")>
	</cfif>
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

	<a href="/SpecimenResultsSummaryPagesFS.cfm?groupby=#groupby#&querystring=#URLEncodedFormat(mapurl)#">new form</a>
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
	<span class="controlButton"	onclick="saveSearch('#Application.ServerRootUrl#/SpecimenResultsSummary.cfm?#mapURL#&groupBy=#groupBy#');">[ Save&nbsp;Search ]</span>
	<a href="/saveSearch.cfm?action=manage">[ view/manage your saved searches ]</a>
	<a href="/download.cfm?file=ArctosSpecimenSummary.csv">[ CSV ]</a>

	<cfset dlqcols="CountOfCatalogedItem">
	<table border id="t" class="sortable">
		<tr>
			<th>Count</th>
			<cfif basSelect contains "individualcount">
				<th>IndividualCount</th>
				<cfset dlqcols=listAppend(dlqcols,"IndividualCount")>
			</cfif>
			<cfloop list="#group_cols#" index="x">
				<cfif x is "phylclass">
					<cfset x="Class">
				<cfelseif x is "phylorder">
					<cfset x="Order">
				<cfelseif x is "scientific_name">
					<cfset x="ScientificName">
				<cfelseif x is "formatted_scientific_name">
					<cfset x="FormattedScientificName">
				<cfelseif x is "state_prov">
					<cfset x="StateOrProvince">
				<cfelseif x is "island_group">
					<cfset x="IslandGroup">
				<cfelseif x is "spec_locality">
					<cfset x="SpecificLocality">
				<cfelseif x is "continent_ocean">
					<cfset x="ContinentOrOcean">
				<cfelse>
					<cfset x=toProperCase(x)>
				</cfif>
				<cfset dlqcols=listAppend(dlqcols,x)>
				<th>#x#</th>
			</cfloop>
			<th>Specimens</th>
		</tr>
		<cfset dlqcols=listAppend(dlqcols,"linkToSpecimens")>
		<cfset dlq = querynew(dlqcols)>
		<cfset r=1>
		<cfloop query="getData">
			<cfset temp=queryaddrow(dlq,1)>
			<cfset thisLink=mapurl>
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
				<td>
					#COUNTOFCATALOGEDITEM#
					<cfset temp = QuerySetCell(dlq, "COUNTOFCATALOGEDITEM", COUNTOFCATALOGEDITEM, r)>
				</td>
				<cfif basSelect contains "individualcount">
					<td>
						#individualcount#
						<cfset temp = QuerySetCell(dlq, "individualcount", individualcount, r)>
					</td>
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
						<cfset thisLink=listappend(thisLink,"#x#=#URLEncodedFormat(thisVal)#","&")>
					</cfif>
					<!----

					why was this commented out?? Hopefully adding it doesn't break something evil! without it,
					/SpecimenResultsSummary.cfm?state_prov=Alaska&collection_id=1&groupBy=species&debug=1

					just returns everything, NOT species-only

					---->
					<cfif thisLink does not contain x>
						<cfset thisLink=listappend(thisLink,"#x#=#URLEncodedFormat(thisVal)#","&")>
					</cfif>
					<!---- end mysterious comment ----->
					<td>
						#thisVal#
						<cfif x is "phylclass">
							<cfset x="Class">
						<cfelseif x is "phylorder">
							<cfset x="Order">
						<cfelseif x is "scientific_name">
							<cfset x="ScientificName">
						<cfelseif x is "formatted_scientific_name">
							<cfset x="FormattedScientificName">
						<cfelseif x is "state_prov">
							<cfset x="StateOrProvince">
						<cfelseif x is "island_group">
							<cfset x="IslandGroup">
						<cfelseif x is "spec_locality">
							<cfset x="SpecificLocality">
						<cfelseif x is "continent_ocean">
							<cfset x="ContinentOrOcean">
						<cfelse>
							<cfset x=toProperCase(x)>
						</cfif>
						<cfset temp = QuerySetCell(dlq, "#x#", thisVal, r)>
					</td>
				</cfloop>
				<cfset thisLink=replace(thisLink,"##","%23","all")>
				<cfset thisLink=replace(thisLink,"?&","?","all")>
				<cfset thisLink=replace(thisLink,"&&","&","all")>
				<td><a href="/SpecimenResults.cfm?#thisLink#">specimens</a></td>
				<cfset temp = QuerySetCell(dlq, "linktospecimens", "#Application.ServerRootUrl#/SpecimenResults.cfm?#thisLink#", r)>
			</tr>
			<cfset r=r+1>
		</cfloop>
	</table>
	<cfthread action="run" dlq="#dlq#" dlqcold="#dlqcols#" name="sqsdl">
		<cfset  util = CreateObject("component","component.utilities")>
		<cfset csv = util.QueryToCSV2(Query=dlq,Fields=dlqcols)>
		<cffile action = "write"
		    file = "#Application.webDirectory#/download/ArctosSpecimenSummary.csv"
	    	output = "#csv#"
	    	addNewLine = "no">
	</cfthread>
</cfoutput>
<cfinclude template = "includes/_footer.cfm">