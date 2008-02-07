<cfoutput>
<cfquery name="uam1" datasource="#Application.web_user#">
	select
		other_id_num,
		a.collection_object_id,
		cat_num
	FROM
		cataloged_item a,
		coll_obj_other_id_num b
	where
		a.collection_object_id = b.collection_object_id AND
		b.other_id_type='GenBank sequence accession'
</cfquery>

<cfset header="------------------------------------------------#chr(10)#prid: 3849#chr(10)#dbase: Nucleotide#chr(10)#!base.url: http://arctos.database.museum/SpecimenDetail.cfm?">
<cffile action="write" file="/var/www/html/temp/uam1.ft" addnewline="no" output="#header#">
<cfset i=1>
<cfloop query="uam1">
	<cfset oneLine="#chr(10)#------------------------------------------------#chr(10)#linkid: #i##chr(10)#query: #other_id_num##chr(10)#base: &base.url;#chr(10)#rule: collection_object_id=#collection_object_id##chr(10)#name: UAM #cat_num#">
		<cfset i=#i#+1>
		<cffile action="append" file="/var/www/html/temp/uam1.ft" addnewline="no" output="#oneLine#">
</cfloop>

<cfquery name="uam2" datasource="#Application.web_user#">
	select 
		distinct(scientific_name)
	FROM 
		cataloged_item a, 
		identification c, 
		coll_obj_other_id_num d 
	WHERE 
		a.collection_object_id = c.collection_object_id AND 
		c.accepted_id_fg=1 AND 
		a.collection_object_id = d.collection_object_id AND 
		d.other_id_type='GenBank sequence accession'
</cfquery>
<cfset header="------------------------------------------------#chr(10)#prid: 3849#chr(10)#dbase: Taxonomy#chr(10)#!base.url: http://arctos.database.museum/SpecimenResults.cfm?">
<cffile action="write" file="/var/www/html/temp/uam2.ft" addnewline="no" output="#header#">
<cfset i=1>
<cfloop query="uam2">
	<cfset oneLine="#chr(10)#------------------------------------------------#chr(10)#linkid: #i##chr(10)#query: #scientific_name# [name]#chr(10)#base: &base.url;#chr(10)#rule: scientific_name=#scientific_name##chr(10)#name: #scientific_name# with GenBank sequence accessions">		<cfset i=#i#+1>
		<cffile action="append" file="/var/www/html/temp/uam2.ft" addnewline="no" output="#oneLine#">
</cfloop>

<cfquery name="uamAllSciNames" datasource="#Application.web_user#">
	select 
		distinct(scientific_name) from taxonomy
</cfquery>
<cfset header="------------------------------------------------#chr(10)#prid: 3849#chr(10)#dbase: Taxonomy#chr(10)#!base.url: http://arctos.database.museum/TaxonomyResults.cfm?">
<cffile action="write" file="/var/www/html/temp/uamAllSciNames.ft" addnewline="no" output="#header#">
<cfset i=1>
<cfloop query="uamAllSciNames">
	<cfset oneLine="#chr(10)#------------------------------------------------#chr(10)#linkid: #i##chr(10)#query: #scientific_name# [name]#chr(10)#base: &base.url;#chr(10)#rule: full_taxon_name=#scientific_name##chr(10)#name: #scientific_name# taxonomy">
		<cfset i=#i#+1>
		<cffile action="append" file="/var/www/html/temp/uamAllSciNames.ft" addnewline="no" output="#oneLine#">
</cfloop>

<cfquery name="uamAllUsedSciNames" datasource="#Application.web_user#">
	select 
		distinct(scientific_name) from identification
</cfquery>
<cfset header="------------------------------------------------#chr(10)#prid: 3849#chr(10)#dbase: Taxonomy#chr(10)#!base.url: http://arctos.database.museum/TaxonomyResults.cfm?">
<cffile action="write" file="/var/www/html/temp/uamAllUsedSciNames.ft" addnewline="no" output="#header#">
<cfset i=1>
<cfloop query="uamAllUsedSciNames">
	<cfset oneLine="#chr(10)#------------------------------------------------#chr(10)#linkid: #i##chr(10)#query: #scientific_name# [name]#chr(10)#base: &base.url;#chr(10)#rule: full_taxon_name=#scientific_name##chr(10)#name: #scientific_name# taxonomy">
		<cfset i=#i#+1>
		<cffile action="append" file="/var/www/html/temp/uamAllUsedSciNames.ft" addnewline="no" output="#oneLine#">
</cfloop>
<!----
<cfquery name="uamsp2" datasource="#Application.web_user#">
	select 
		distinct(scientific_name) from taxonomy
		genus, 
		species, 
		subspecies, 
		a.collection_object_id, 
		cat_num 
	FROM 
		cataloged_item a, 
		identification_taxonomy b, 
		taxonomy e,
		identification c, 
		coll_obj_other_id_num d 
	WHERE 
		a.collection_object_id = c.collection_object_id AND 
		c.accepted_id_fg=1 AND 
		c.identification_id=b.identification_id AND 
		b.taxon_name_id=e.taxon_name_id AND 
		a.collection_object_id = d.collection_object_id AND 
		d.other_id_type='GenBank sequence accession'
</cfquery>
<cfset header="------------------------------------------------#chr(10)#prid: 3849#chr(10)#dbase: Taxonomy#chr(10)#!base.url: http://arctos.database.museum/TaxonomyResults.cfm?">
<cffile action="write" file="/var/www/html/temp/uamsp2.ft" addnewline="no" output="#header#">
<cfset i=1>
<cfloop query="uam2">
	<cfset oneLine="#chr(10)#------------------------------------------------#chr(10)#linkid: #i##chr(10)#query: #scientific_name# [name]#chr(10)#base: &base.url;#chr(10)#rule: full_taxon_name=#scientific_name##chr(10)#name: search UAM: #scientific_name#">
		<cfset i=#i#+1>
		<cffile action="append" file="/var/www/html/temp/uamsp2.ft" addnewline="no" output="#oneLine#">
</cfloop>
<cfquery name="uamsp3" datasource="#Application.web_user#">
	select 
		scientific_name 
	FROM 
		cataloged_item a, 
		identification c, 
		coll_obj_other_id_num d 
	WHERE 
		a.collection_object_id = c.collection_object_id AND 
		a.collection_object_id = d.collection_object_id AND 
		c.accepted_id_fg=1 AND 
		d.other_id_type='GenBank sequence accession'
</cfquery>
<cfset header="------------------------------------------------#chr(10)#prid: 3849#chr(10)#dbase: Taxonomy#chr(10)#!base.url: http://arctos.database.museum/TaxonomyResults.cfm?">
<cffile action="write" file="/var/www/html/temp/uamsp3.ft" addnewline="no" output="#header#">
<cfset i=1>
<cfloop query="uam2">
	<cfset oneLine="#chr(10)#------------------------------------------------#chr(10)#linkid: #i##chr(10)#query: #scientific_name# [sname]#chr(10)#base: &base.url;#chr(10)#rule: full_taxon_name=#scientific_name##chr(10)#name: search UAM: #scientific_name#">
		<cfset i=#i#+1>
		<cffile action="append" file="/var/www/html/temp/uamsp3.ft" addnewline="no" output="#oneLine#">
</cfloop>
---->
<cfftp action="open" username="uam" password="bU7$f%Nu" server="ftp-private.ncbi.nih.gov" connection="genbank" passive="yes">
	<cfftp connection="genbank" action="changedir"  directory="holdings">
	<cfftp connection="genbank" action="putfile" localfile="/var/www/html/temp/uam1.ft" remotefile="uam1.ft" name="Put_uam1">
	<cfftp connection="genbank" action="putfile" localfile="/var/www/html/temp/uam2.ft" remotefile="uam2.ft" name="Put_uam2">
	<cfftp connection="genbank" action="putfile" localfile="/var/www/html/temp/uamAllUsedSciNames.ft" remotefile="uamAllUsedSciNames.ft" name="Put_uam2">
	<cfftp connection="genbank" action="putfile" localfile="/var/www/html/temp/uamAllSciNames.ft" remotefile="uamAllSciNames.ft" name="Put_uam2">
	
	<!----
	<cfftp connection="genbank" action="putfile" localfile="/var/www/html/temp/uamsp2.ft" remotefile="uamsp2.ft" name="Put_uamsp2">
	<cfftp connection="genbank" action="putfile" localfile="/var/www/html/temp/uamsp3.ft" remotefile="uamsp3.ft" name="Put_uamsp3">
	---->
<cfftp connection="genbank" action="close">
</cfoutput>