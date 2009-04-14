<cfoutput>
<cfquery name="colls" datasource="uam_god">
	select * from collection where collection_id=1
</cfquery>
	<cfloop query="colls">
		<cfquery name="t" datasource="uam_god">
			select count(*) c from cataloged_item where collection_id=#collection_id#
		</cfquery>
		<cfset numSiteMaps=Ceiling(t.c/50000)>
		<cfset smi='<?xml version="1.0" encoding="UTF-8"?>'>
		<cfset smi=smi & chr(10) & chr(9) & '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'>
		<cfset smi=smi & chr(10) & chr(9) & '<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'>
		<br>need #numSiteMaps# numSiteMaps for #collection#
		<cfloop from="1" to="#numSiteMaps#" index="l">
			<cfset thisFileName="#colls.institution_acronym#_#colls.collection_cde##l#.xml">
			<cfset smi=smi & chr(10) & chr(9) & chr(9) & '<sitemap>'>
				<cfset smi=smi & chr(10) & chr(9) & chr(9) & chr(9) & "<loc>#application.serverRootUrl#/#thisFileName#</loc>">
				<cfset smi=smi & chr(10) & chr(9) & chr(9) & chr(9) & "<lastmod>#dateformat(now(),'yyyy-mm-dd')#</lastmod>">
			<cfset smi=smi & chr(10) & chr(9) & chr(9) & '</sitemap>'>			
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
	<cfset smi=smi & chr(10) & chr(9) & '</sitemapindex>'>
	<cffile action="write" file="#Application.webDirectory#/sitemapindex.xml.gz" addnewline="no" output="#f#"> 
</cfoutput>