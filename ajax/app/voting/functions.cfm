<cfinclude template="/ajax/core/cfajax.cfm">
<cffunction name="votingchoice">
	<cfargument name="category" required="yes">
	<cfreturn getCategory(arguments.category)>
</cffunction>


<cffunction name="votingresult">
	<cfargument name="category" required="yes">
	<cfargument name="vote" required="yes">

	<cfset choices = getCategory(arguments.category)>
	<cfset fileName= ExpandPath("./") & "voting#category#.txt">
	<cfif fileExists(fileName)>
		<cffile action="read" file="#fileName#" variable="results">
		<cfset results = trim(results)>
	<cfelse>
		<cfset results = "">
	</cfif>

	<cfset resultStruct = StructNew()>
	<cfloop list="#results#" index="i">
		<cfset StructInsert( resultStruct,  ListGetAt(i,1,"="), ListGetAt(i,2,"=") )>
	</cfloop>

	<cfset choices = getCategory(arguments.category)>
	<cfset myQuery = QueryNew("name, votes")>
	<cfset results = "">
	<cfloop from="1" to="#ArrayLen(choices)#" index="i">
		<cfset newRow = QueryAddRow(MyQuery)>
		<cfset temp = QuerySetCell(myQuery, "name", ListGetAt( choices[i],1))>
		<cfset votes = 0>
		<cfif StructKeyExists(resultStruct, i)>
			<cfset votes = resultStruct[i]>
		</cfif>
		<cfif i EQ arguments.vote>
			<cfset votes = votes + 1>
		</cfif>
		<cfset temp = QuerySetCell(myQuery, "votes", votes)>
		<cfset results = listAppend(results, i & "=" & votes)>
	</cfloop>
	<cffile action="write" file="#fileName#" output="#trim(results)#">
	<cfreturn myQuery>
</cffunction>

<cffunction name="getCategory" access="private">
	<cfargument name="category" type="string" required="yes">
	<cfset choice = ArrayNew(1)>
	<cfif category EQ 1>
		<cfset ArrayAppend(choice, "Joan Allen")>
		<cfset ArrayAppend(choice, "Cameron Diaz")>
		<cfset ArrayAppend(choice, "Charlize Theron")>
		<cfset ArrayAppend(choice, "Claire Danes")>
		<cfset ArrayAppend(choice, "Uma Thurman")>
		<cfset ArrayAppend(choice, "My Girlfriend/Wife")>
	<cfelseif category EQ 2>
		<cfset ArrayAppend(choice, "Russell Crowe")>
		<cfset ArrayAppend(choice, "Joaquin Phoenix")>
		<cfset ArrayAppend(choice, "Colin Farrell")>
		<cfset ArrayAppend(choice, "Viggo Mortensen")>
		<cfset ArrayAppend(choice, "Eric Bana")>
		<cfset ArrayAppend(choice, "My Boyfriend/Husband")>
	<cfelseif category EQ 3>
		<cfset ArrayAppend(choice, "ASP")>
		<cfset ArrayAppend(choice, "ASP.net")>
		<cfset ArrayAppend(choice, "PHP")>
		<cfset ArrayAppend(choice, "Coldfusion")>
		<cfset ArrayAppend(choice, "JSP")>
		<cfset ArrayAppend(choice, "None")>
	</cfif>
	<cfreturn choice>
</cffunction>