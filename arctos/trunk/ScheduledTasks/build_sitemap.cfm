<!--- 
	create table cf_sitemaps (
		collection_id number,
		filename varchar2(20),
		lastdate date
	);
--->
<cfinclude template="/includes/_header.cfm">
<cfset btime=now()>
<cfif action is "nothing">
<br><a href="build_sitemap.cfm?action=build_map">build_map</a>
<br><a href="build_sitemap.cfm?action=build_index">build_index</a>
<br><a href="build_sitemap.cfm?action=build_sitemaps_spec">build_sitemaps_spec</a>
<br><a href="build_sitemap.cfm?action=build_sitemaps_tax">build_sitemaps_tax</a>

</cfif>
<cfset chunkSize=50000>
<cfif action is "build_map">
<cfoutput>
	<cfquery name="kcf_sitemaps" datasource="uam_god">
		delete from cf_sitemaps
	</cfquery>
	<cfquery name="t" datasource="uam_god">
		select count(*) c from filtered_flat
	</cfquery>
	<cfset numSiteMaps=Ceiling(t.c/chunkSize)>
	<cfloop from="1" to="#numSiteMaps#" index="l">
		<cfset thisFileName="specimen#l#.xml">
		<cfquery name="i" datasource="uam_god">
			insert into cf_sitemaps (filename) values ('#thisFileName#')
		</cfquery>
	</cfloop>
	<cfquery name="t" datasource="uam_god">
		select count(*) c from taxonomy
	</cfquery>
	<cfset numSiteMaps=Ceiling(t.c/chunkSize)>
	<cfloop from="1" to="#numSiteMaps#" index="l">
		<cfset thisFileName="taxonomy#l#.xml">
		<cfquery name="i" datasource="uam_god">
			insert into cf_sitemaps (filename) values ('#thisFileName#')
		</cfquery>
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
	<cffile action="write" file="#Application.webDirectory#/sitemapindex.xml" addnewline="no" output="#smi#"> 
</cfif>
<!--------------------------------->
<cfif action is "build_sitemaps_tax">
<cfoutput>
	<cfquery name="colls" datasource="uam_god">
		select filename
		from cf_sitemaps
		 where
		 filename like 'taxonomy%' and
		 rownum=1 and (lastdate is null or sysdate-LASTDATE > 1)
	</cfquery>
	<cfset chunkNum=replace(colls.filename,".xml","","all")>
	<cfset chunkNum=replace(chunkNum,"taxonomy","","all")>
	<cfset maxRN=chunkNum*chunkSize>
	<cfset minRN=maxRN-chunkSize>
	<cfquery name="d" datasource="uam_god">
		 select * from (
         	select a.*, rownum rnum from (
            	select                
                	scientific_name
				from 
					taxonomy 
				order by scientific_name
			) a
		where rownum <= #maxRN#)
		where rnum >=#minRN#
	</cfquery>
	<cfset variables.fileName="#Application.webDirectory#/#colls.filename#">
	<cfset variables.encoding="UTF-8">
	<cfscript>
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
	</cfscript>
	<cfscript>
		a='<?xml version="1.0" encoding="UTF-8"?>';
		variables.joFileWriter.writeLine(a);
		a='<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">';
		variables.joFileWriter.writeLine(a);
	</cfscript>			
	<cfloop query="d">
		<cfscript>
			a=chr(9) & "<url>" & chr(10) & 
			chr(9) & chr(9) & "<loc>#application.serverRootUrl#/name/#scientific_name#</loc>" & chr(10) &
			chr(9) & chr(9) & "<priority>.6</priority>" & chr(10) &
			chr(9) & chr(9) & "<changefreq>monthly</changefreq>" & chr(10) & 
			chr(9) & "</url>";
			variables.joFileWriter.writeLine(a);
		</cfscript>
	</cfloop>	
	<cfscript>
		a="</urlset>";
		variables.joFileWriter.writeLine(a);
		variables.joFileWriter.close();
	</cfscript>	
	<cfquery name="u" datasource="uam_god">
		update cf_sitemaps set lastdate=sysdate where filename='#colls.filename#'
	</cfquery>
</cfoutput>
</cfif>
<!--------------------------------->
<cfif action is "build_sitemaps_spec">
<cfoutput>
	<cfquery name="colls" datasource="uam_god">
		select filename
		from cf_sitemaps
		 where
		 filename like 'specimen%' and
		 rownum=1 and (lastdate is null or sysdate-LASTDATE > 1)
	</cfquery>
	<cfset chunkNum=replace(colls.filename,".xml","","all")>
	<cfset chunkNum=replace(chunkNum,"specimen","","all")>
	<cfset maxRN=chunkNum*chunkSize>
	<cfset minRN=maxRN-chunkSize>
	<cfquery name="d" datasource="uam_god">
		 select * from (
         	select a.*, rownum rnum from (
            	select                
                	guid,
                	to_char(LAST_EDIT_DATE,'yyyy-mm-dd') lastMod
				from 
					filtered_flat 
				order by guid
			) a
		where rownum <= #maxRN#)
		where rnum >=#minRN#
	</cfquery>
	<cfset variables.fileName="#Application.webDirectory#/#colls.filename#">
	<cfset variables.encoding="UTF-8">
	<cfscript>
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
	</cfscript>
	<cfscript>
		a='<?xml version="1.0" encoding="UTF-8"?>';
		variables.joFileWriter.writeLine(a);
		a='<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">';
		variables.joFileWriter.writeLine(a);
	</cfscript>			
	<cfloop query="d">
		<cfscript>
			a=chr(9) & "<url>" & chr(10) & 
			chr(9) & chr(9) & "<loc>#application.serverRootUrl#/guid/#guid#</loc>" & chr(10) &
			chr(9) & chr(9) & "<lastmod>#lastMod#</lastmod>" & chr(10) &
			chr(9) & chr(9) & "<priority>.8</priority>" & chr(10) &
			chr(9) & chr(9) & "<changefreq>weekly</changefreq>" & chr(10) & 
			chr(9) & "</url>";
			variables.joFileWriter.writeLine(a);
		</cfscript>
	</cfloop>	
	<cfscript>
		a="</urlset>";
		variables.joFileWriter.writeLine(a);
		variables.joFileWriter.close();
	</cfscript>	
	<cfquery name="u" datasource="uam_god">
		update cf_sitemaps set lastdate=sysdate where filename='#colls.filename#'
	</cfquery>
</cfoutput>
</cfif>