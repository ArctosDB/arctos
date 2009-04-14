<!--- 
	create table cf_sitemaps (
		collection_id number,
		filename varchar2(20),
		lastdate date
	);
--->
<cfinclude template="/includes/_header.cfm">
<cfif action is "nothing">
<br><a href="build_sitemap.cfm?action=build_map">build_map</a>
<br><a href="build_sitemap.cfm?action=build_index">build_index</a>
<br><a href="build_sitemap.cfm?action=build_sitemap">build_sitemap</a>
</cfif>
<cfset chunkSize=20000>
<cfif action is "build_map">
<cfoutput>
	<cfquery name="colls" datasource="uam_god">
		select * from collection
	</cfquery>
	<cfloop query="colls">
		<cfquery name="t" datasource="uam_god">
			select max(cat_num) c from cataloged_item where collection_id=#collection_id#
		</cfquery>
		<cfset numSiteMaps=Ceiling(t.c/chunkSize)>
		<cfloop from="1" to="#numSiteMaps#" index="l">
			<cfset thisFileName="#colls.institution_acronym#_#colls.collection_cde##l#.xml">
			<cfquery name="g" datasource="uam_god">
				select count(*) c from cf_sitemaps where filename='#thisFileName#'
			</cfquery>
			<cfif g.c is 0>
				<cfquery name="i" datasource="uam_god">
					insert into cf_sitemaps (filename,collection_id) values ('#thisFileName#',#collection_id#)
				</cfquery>
			</cfif>
		</cfloop>
	</cfloop>
</cfoutput>	
</cfif>
<!------------------------------->
<cfif action is "build_index">
	<cfquery name="colls" datasource="uam_god">
		select filename from cf_sitemaps
	</cfquery>
	<cfset smi='<?xml version="1.0" encoding="UTF-8"?>'>
	<cfset smi=smi & chr(10) & chr(9) & '<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'>
	<cfloop query="colls">
		<cfset smi=smi & chr(10) & chr(9) & chr(9) & '<sitemap>'>
		<cfset smi=smi & chr(10) & chr(9) & chr(9) & chr(9) & "<loc>#application.serverRootUrl#/#filename#</loc>">
		<cfset smi=smi & chr(10) & chr(9) & chr(9) & chr(9) & "<lastmod>#dateformat(now(),'yyyy-mm-dd')#</lastmod>">
		<cfset smi=smi & chr(10) & chr(9) & chr(9) & '</sitemap>'>					
	</cfloop>
	<cfset smi=smi & chr(10) & chr(9) & '</sitemapindex>'>
	<cffile action="write" file="#Application.webDirectory#/sitemapindex.xml.gz" addnewline="no" output="#smi#"> 
</cfif>
<!--------------------------------->
<cfif action is "build_sitemap">
<cfoutput>
<cfquery name="colls" datasource="uam_god">
	select 
		filename,
		cf_sitemaps.collection_id,
		institution_acronym,
		collection_cde
	from cf_sitemaps,collection
	 where 
	 cf_sitemaps.collection_id=collection.collection_id and
	 rownum=1 and (lastdate is null or sysdate-LASTDATE > 1)
</cfquery>
<cfset chunkNum=replace(colls.filename,".xml","","all")>
<cfset chunkNum=replace(chunkNum,"#colls.institution_acronym#_#colls.collection_cde#","","all")>
getting data for collection #colls.collection_id#, chunk #chunkNum#
<cfset maxCN=chunkNum*chunkSize>
<cfset minCN=maxCN-chunkSize>
maxCN: #maxCN#
minCN: #minCN#

	<!---
	<cfloop query="colls">
		<cfloop from="1" to="#numSiteMaps#" index="l">
		<cfset f='<?xml version="1.0" encoding="UTF-8"?>'>			
			<cfquery name="d" datasource="uam_god">
				select guid,sysdate lastmod from flat where collection_id=#collection_id# and cat_num<20000
			</cfquery>
			<cfloop query="d">
				<cfset f=f & chr(10) & chr(9) & chr(9) & '<url>'>
				<cfset f=f & chr(10) & chr(9) & chr(9) & chr(9) & "<loc>#application.serverRootUrl#/guid/#guid#</loc>">
			    <cfset f=f & chr(10) & chr(9) & chr(9) & chr(9) & "<lastmod>#lastmod#</lastmod>">
			    <cfset f=f & chr(10) & chr(9) & chr(9) & chr(9) & "<priority>.8</priority>">
			    <cfset f=f & chr(10) & chr(9) & chr(9) & chr(9) & "<changefreq>weekly</changefreq>">
			    <cfset f=f & chr(10) & chr(9) & chr(9) & '</url>'>
			</cfloop>
			<cffile action="write" file="#Application.webDirectory#/#thisFileName#" addnewline="no" output="#f#"> 
	
		</cfloop>
	</cfloop>
--->
</cfoutput>
</cfif>