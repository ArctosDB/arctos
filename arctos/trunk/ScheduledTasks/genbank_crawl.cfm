<cfinclude template="/includes/_header.cfm">

<cfhttp 
	url="http://www.ncbi.nlm.nih.gov/sites/entrez?db=nuccore&cmd=search&term=collection%20uam[prop]%20NOT%20loprovarctos[filter]" 
	method="get" />

<cfset xmlDoc=xmlParse(cfhttp.filecontent)>
<cfoutput>
<cfloop from="1" to="#ArrayLen(xmldoc.html.head.meta)#" index="i">
	<cfset a=xmldoc.html.head.meta[i].xmlattributes>
	<cfif isdefined("a.name") and a.name is 'ncbi_resultcount'>
		<cfset ncbi_resultcount=a.content>
		ncbi_resultcount: #ncbi_resultcount#
	</cfif>
</cfloop>
</cfoutput>


<!----
<cfset r=<meta name="ncbi_resultcount" content="4092" />

---->