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
<br><a href="build_sitemap.cfm?action=build_sitemap">build_sitemap</a>
</cfif>
<cfset chunkSize=50000>
<cfif action is "build_map">
<cfoutput>
	<cfquery name="colls" datasource="uam_god">
		select * from collection
	</cfquery>
	<cfloop query="colls">
		<cfquery name="t" datasource="uam_god">
			select max(cat_num) c from cataloged_item where collection_id=#collection_id#
		</cfquery>
		<cfif t.c gt 1>
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
		</cfif>
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
	<cfset etime=now()>
	<cfset tt=DateDiff("s", btime, etime)>
	<br>start: #tt#
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
	<cfset maxCN=chunkNum*chunkSize>
	<cfset minCN=maxCN-chunkSize>
	<cfquery name="d" datasource="uam_god">
		select guid,to_char(LAST_EDIT_DATE,'yyyy-mm-dd') lastMod
		from filtered_flat where collection_id=#colls.collection_id# and cat_num between #minCN# and #maxCN#
	</cfquery>
	<cfset variables.fileName="#Application.webDirectory#/#colls.filename#">
	<cfset variables.encoding="UTF-8">
	<cfscript>
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
	</cfscript>
	<cfscript>
		f='<?xml version="1.0" encoding="UTF-8"?>';
		variables.joFileWriter.writeLine(f);
		f='<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">';
		variables.joFileWriter.writeLine(f);
		a="<urlset>";
		variables.joFileWriter.writeLine(a);
	</cfscript>			
	<cfloop query="d">
		<cfscript>
			a=chr(9) & "<url>";
			variables.joFileWriter.writeLine(a);
			a=chr(9) & chr(9) & "<loc>#application.serverRootUrl#/guid/#guid#</loc>";
			variables.joFileWriter.writeLine(a);
			if (len(lastMod) gt 0) {
				a=chr(9) & chr(9) & "<lastmod>#lastMod#</lastmod>";
				variables.joFileWriter.writeLine(a);
			}
			a=chr(9) & chr(9) & "<priority>.8</priority>";
			variables.joFileWriter.writeLine(a);
			a=chr(9) & chr(9) & "<changefreq>weekly</changefreq>";
			variables.joFileWriter.writeLine(a);
			a=chr(9) & "</url>";
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