<cfinclude template="/ajax/core/cfajax.cfm">
<cffunction name="amazonmusicsearch">
	<cfargument name="keyword" type="string" required="yes">
	<cfargument name="page" type="string" required="yes">

	<cfset request = StructNew()>
	<cfset request.Keywords = "hindi">
	<cfset request.SearchIndex = "Music">

	
<!---
	<cfset AmazonURL = "http://localhost/ajax/examples/xml.xml">
--->	
	<cfset AmazonURL = "http://webservices.amazon.com/onca/xml?Service=AWSECommerceService&SubscriptionId=14VK3APM8AGS9PB348R2&Operation=ItemSearch&SearchIndex=Music&Keywords=#trim(keyword)#&ResponseGroup=Medium&ItemPage=#page#">

	<cfhttp url = "#AmazonURL#" method = "get" timeout="60">
	<cfset content = replace(cfhttp.fileContent," xmlns=""http://webservices.amazon.com/AWSECommerceService/2005-03-23"">",">")>
	<cfset xmlDoc = XMLParse( content )>

	<cfset arrResult = XmlSearch(xmlDoc, "ItemSearchResponse/Items/TotalPages")>
	<cfset totalPages = arrResult[1].XmlText>

	<cfset arrResult = XmlSearch(xmlDoc, "ItemSearchResponse/Items/TotalResults")>
	<cfset totalRecords = arrResult[1].XmlText>
	
	<cfset listingArray = ArrayNew(1)>
	<cfset arrTitles = XmlSearch(xmlDoc, "ItemSearchResponse/Items/Item")>
	<cfloop from="1" to=#ArrayLen(arrTitles)# index="ctrItems">
		<cfset item = arrTitles[ctrItems].XmlChildren>
		<cfset smallImageExists = false>
		<cfset largeImageExists = false>
		<cfset list="">
		<cfloop from="1" to="#Arraylen(item)#" index="elem">
			<cfif (item[elem].xmlName EQ "SmallImage")>
				<cfset smallImageExists = true>
			<cfelseif (item[elem].xmlName EQ "LargeImage")>
				<cfset largeImageExists = true>
			</cfif>
		</cfloop>
		<cfset list = ListAppend(list,arrTitles[ctrItems]["ASIN"].XmlText)>
		<cfset list = ListAppend(list,arrTitles[ctrItems]["DetailPageURL"].XmlText)>
		<cfset list = ListAppend(list,filterJavascriptChar(arrTitles[ctrItems]["ItemAttributes"]["Title"].XmlText))>
		<cfif smallImageExists eq true>
			<cfset list = ListAppend(list,arrTitles[ctrItems]["SmallImage"]["URL"].XmlText)>
		<cfelse>
			<cfset list = ListAppend(list,"http://g-images.amazon.com/images/G/01/x-site/icons/no-img-lg.gif")>
		</cfif>
		<cfif largeImageExists eq true>
			<cfset list = ListAppend(list,arrTitles[ctrItems]["LargeImage"]["URL"].XmlText)>
		<cfelse>
			<cfset list = ListAppend(list,"http://g-images.amazon.com/images/G/01/x-site/icons/no-img-lg.gif")>
		</cfif>
		
		<cfset lowestUsedPriceExist = false>
		<cfset lowestNewPriceExists = false>
		<cfset lowestCollectiblePriceExists = false>
		
		<cfset subItem = arrTitles[ctrItems]["OfferSummary"].XmlChildren>
		<cfloop from="1" to="#Arraylen(subItem)#" index="elem">
			<cfif (subItem[elem].xmlName EQ "LowestUsedPrice")>
				<cfset lowestUsedPriceExist = true>
			<cfelseif (subItem[elem].xmlName EQ "LowestNewPrice")>
				<cfset lowestNewPriceExists = true>
			<cfelseif (subItem[elem].xmlName EQ "LowestCollectiblePrice")>
				<cfset lowestCollectiblePriceExists = true>
			</cfif>
		</cfloop>
		
		<cfif lowestNewPriceExists eq true>
			<cfset list = ListAppend(list,arrTitles[ctrItems]["OfferSummary"]["LowestNewPrice"]["FormattedPrice"].XmlText)>
		<cfelseif lowestCollectiblePriceExists eq true>
			<cfset list = ListAppend(list,arrTitles[ctrItems]["OfferSummary"]["LowestCollectiblePrice"]["FormattedPrice"].XmlText)>
		<cfelse>
			<cfset list = ListAppend(list,"n/a")>
		</cfif>
		
		<cfif lowestUsedPriceExist eq true>
			<cfset list = ListAppend(list,arrTitles[ctrItems]["OfferSummary"]["LowestUsedPrice"]["FormattedPrice"].XmlText)>
		<cfelse>
			<cfset list = ListAppend(list,"0")>
		</cfif>

		<cfset nameList=" ">
		<cfset artist=" ">
		<cfset label = " ">
		<cfset ReleaseDate = " ">
		<cfset subItem = arrTitles[ctrItems]["ItemAttributes"].XmlChildren>
		<cfloop from="1" to="#Arraylen(subItem)#" index="elem">
			<cfif (subItem[elem].xmlName EQ "Creator")>
				<cfset nameList = ListAppend(nameList, subItem[elem].XmlText, " - ")>
			<cfelseif (subItem[elem].xmlName EQ "Artist")>
				<cfset artist = ListAppend(nameList, subItem[elem].XmlText, " - ")>
			<cfelseif (subItem[elem].xmlName EQ "Label")>
				<cfset label = subItem[elem].XmlText>
			<cfelseif (subItem[elem].xmlName EQ "ReleaseDate")>
				<cfset ReleaseDate = subItem[elem].XmlText>
			</cfif>
		</cfloop>
		<cfset list = ListAppend(list,nameList)>
		<cfset list = ListAppend(list, arrTitles[ctrItems]["ItemAttributes"]["Binding"].XmlText)>
		<cfset list = ListAppend(list, filterJavascriptChar(label))>
		<cfset list = ListAppend(list, artist)>
		<cfset list = ListAppend(list, totalPages)>
		<cfset list = ListAppend(list, totalRecords)>
		<cfset list = ListAppend(list, ReleaseDate)>
		<cfset ArrayAppend(listingArray, list)>
	</cfloop>

	<cfset myQuery = QueryNew("asin, detailurl, title, smallimage, price, lowest, creator, binding, label, artist, pages, records, releasedate")>
	<cfloop from="1" to="#ArrayLen(listingArray)#" index="i">
		<cfset newRow = QueryAddRow(MyQuery)>
		<cfset temp = QuerySetCell(myQuery, "asin", ListGetAt( listingArray[i],1))>
		<cfset temp = QuerySetCell(myQuery, "detailurl", ListGetAt( listingArray[i],2))>
		<cfset temp = QuerySetCell(myQuery, "title", ListGetAt( listingArray[i],3))>
		<cfset temp = QuerySetCell(myQuery, "smallimage", ListGetAt( listingArray[i],4))>
		<!---<cfset temp = QuerySetCell(myQuery, "largeimage", ListGetAt( listingArray[i],5))>--->
		<cfset temp = QuerySetCell(myQuery, "price", ListGetAt( listingArray[i],6))>
		<cfset temp = QuerySetCell(myQuery, "lowest", ListGetAt( listingArray[i],7))>
		<cfset temp = QuerySetCell(myQuery, "creator", replace(ListGetAt( listingArray[i],8),"'","","ALL"))>
		<cfset temp = QuerySetCell(myQuery, "binding", replace(ListGetAt( listingArray[i],9),"'","","ALL"))>
		<cfset temp = QuerySetCell(myQuery, "label", replace(ListGetAt( listingArray[i],10),"'",""))>
		<cfset temp = QuerySetCell(myQuery, "artist", replace(ListGetAt( listingArray[i],11),"'",""))>
		<cfset temp = QuerySetCell(myQuery, "pages", ListGetAt( listingArray[i],12))>
		<cfset temp = QuerySetCell(myQuery, "records", ListGetAt( listingArray[i],13))>
		<cfset temp = QuerySetCell(myQuery, "releasedate", ListGetAt( listingArray[i],14))>
	</cfloop>
	<cfreturn myQuery>
</cffunction>
	
	
<cffunction name="filterJavascriptChar" access="private">
	<cfargument name="string">
	<cfset retVar = replace(arguments.string,"'"," ","ALL")>
	<cfset retVar = replace(retVar,","," ","ALL")>
	<cfset retVar = replace(retVar,";"," - ","ALL")>
	<cfreturn retVar>	
</cffunction>




