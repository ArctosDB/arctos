<cfinclude template="/ajax/core/cfajax.cfm">
<cffunction name="yahooGroupRssFeedReader" hint="type='query' delimiter='^' fieldnames='title,pubdate,pubtime,author,link,description'" >
	<cfargument name="url" type="string" required="no" default="http://rss.groups.yahoo.com/group/cfajax/rss">
	<cfargument name="noOfPosts" type="numeric" required="no" default="5">

	<cfset _delimiter = "^">

	<cfhttp url = "#arguments.url#" method = "get" timeout="5">
	<cfset xmlDoc = XMLParse( cfhttp.fileContent )>

	<cfset returnData = ArrayNew(1)>
	<cfset arrItems = XmlSearch(xmlDoc, "rss/channel/item")>
	<cfloop from="1" to=#ArrayLen(arrItems)# index="ctrItems">
		<cfset item = arrItems[ctrItems].XmlChildren>

		<cfset title = "">
		<cfset pubDate = "">
		<cfset pubTime = "">
		<cfset author = "">
		<cfset link = "">
		<cfset description = "">
		<cfset list = "">
		
		<cfloop from="1" to="#Arraylen(item)#" index="elem">
			<cfif (item[elem].xmlName EQ "title")>
				<cfset title = item[elem].XmlText>
			<cfelseif (item[elem].xmlName EQ "pubDate")>
				<cfset pubTime = Trim(Right(item[elem].XmlText, 12))>
				<cfset pubDate = Left(item[elem].XmlText, len(item[elem].XmlText) - 12)>
			<cfelseif (item[elem].xmlName EQ "author")>
				<cfset author = item[elem].XmlText>
			<cfelseif (item[elem].xmlName EQ "link")>
				<cfset link = item[elem].XmlText>
			<cfelseif (item[elem].xmlName EQ "description")>
				<cfset description = replace(item[elem].XmlText,"______", "","ALL")>
			</cfif>
		</cfloop>
		<cfset list = ListAppend(list," #title# ", _delimiter)>
		<cfset list = ListAppend(list," #pubDate# ", _delimiter)>
		<cfset list = ListAppend(list," #pubTime# ", _delimiter)>
		<cfset list = ListAppend(list," #author# ", _delimiter)>
		<cfset list = ListAppend(list," #link# ", _delimiter)>
		<cfset list = ListAppend(list," #description# ", _delimiter)>
		
		<cfif ctrItems LTE noOfPosts>
			<cfset ArrayAppend(returnData, list)>
		</cfif>
	</cfloop>
	<cfreturn returnData>
</cffunction>