<cfinclude template="/includes/_header.cfm">
<cfoutput>

<cfquery name="c" datasource="uam_god">
	select collection_cde,institution_acronym from collection order by institution_acronym,collection_cde
</cfquery>
<cfquery name="inst" dbtype="query">
	select institution_acronym from c group by institution_acronym order by institution_acronym
</cfquery>
<cfloop query="inst">
	<cfset u="http://www.ncbi.nlm.nih.gov/sites/entrez?db=nuccore&cmd=search&term=">
	<cfset u=u & "collection%20" & institution_acronym & "[prop]%20NOT%20loprovarctos[filter]">
	<cfhttp url="#u#" method="get" />
	<cfset xmlDoc=xmlParse(cfhttp.filecontent)>
	<cfloop from="1" to="#ArrayLen(xmldoc.html.head.meta)#" index="i">
		<cfset a=xmldoc.html.head.meta[i].xmlattributes>
		<cfif isdefined("a.name") and a.name is 'ncbi_resultcount'>
			<cfset ncbi_resultcount=a.content>
			ncbi_resultcount: 
		</cfif>
	</cfloop>
	<hr>There are #ncbi_resultcount# unlinked records for institution #institution_acronym#.
</cfloop>



</cfoutput>


<!----
<cfset r=<meta name="ncbi_resultcount" content="4092" />

---->