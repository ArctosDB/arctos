<cfinclude template="/includes/_header.cfm">

<cfhttp 
	url="http://www.ncbi.nlm.nih.gov/sites/entrez?db=nuccore&cmd=search&term=collection%20uam[prop]%20NOT%20loprovarctos[filter]" 
	method="get" />


<cfdump var=#cfhttp#>

<cfset xmlDoc = XmlParse(cfhttp.fileContent)>
<!---
<cfdump var=#xmldoc#>
--->

<cfset cnt=xmldoc.html.head.XmlChildren>
<cfdump var=#cnt#>

<!----
<cfset r=<meta name="ncbi_resultcount" content="4092" />

---->