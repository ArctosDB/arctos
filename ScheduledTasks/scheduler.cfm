<!--- first, get rid of everything --->
<cfobject type="JAVA" action="Create" name="factory" class="coldfusion.server.ServiceFactory">
<cfset allTasks = factory.CronService.listAll()>
<cfset numberOtasks = arraylen(allTasks)>
<cfloop index="i" from="1" to="#numberOtasks#">
	<cfschedule action="delete" task="#allTasks[i].task#">
</cfloop>
<!-----------------------------------   related specimens cache    ------------------------------------------>
<!--- 
	fetchRelatedInfo
	Purpose: Cache related-specimen information
	Cost: Extremely variable, depends on specimens created and/or in need of refresh
	Growth potential: unlimited
--->
<cfschedule action = "update"
    task = "fetchRelatedInfo"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/fetchRelatedInfo.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "05:51 AM"
    interval = "daily"
    requestTimeOut = "600">
<!-----------------------------------   Agent merge/delete    ------------------------------------------>
<!--- 
	duplicate_agents_findDups
	Purpose: Find agents marked as duplicates
	Cost: low
	Growth potential: low
--->
<cfschedule action = "update"
    task = "duplicate_agents_findDups"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/duplicate_agents.cfm?action=findDups"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "04:51 AM"
    interval = "daily"
    requestTimeOut = "600">
	
<!--- 
	duplicate_agents_merge
	Purpose: Merge duplicate agents
	Cost: extremely variable - can involve updating many (10s of K) rows in ~50 tables
	Growth potential: low
--->
<cfschedule action = "update"
    task = "duplicate_agents_merge"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/duplicate_agents.cfm?action=merge"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "05:01 AM"
    interval = "daily"
    requestTimeOut = "600">
<!--- 
	duplicate_agents_notify
	Purpose: Merge duplicate agents notification
	Cost: low/moderate
	Growth potential: low
--->
<cfschedule action = "update"
    task = "duplicate_agents_notify"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/duplicate_agents.cfm?action=notify"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "05:21 AM"
    interval = "daily"
    requestTimeOut = "600">


<!-----------------------------------   UAM Earth Science Imaging    ------------------------------------------>
<!--- 
	es_spec_insBulk
	Purpose: insert to bulkloader from uam:es imaging app
	Cost: moderate to low depending on recent activity
	Growth potential: low
--->

<cfschedule action = "update"
    task = "es_spec_insBulk"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/es_spec.cfm?action=insBulk"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:21 AM"
    interval = "daily"
    requestTimeOut = "600">
<!--- 
	es_spec_findSpec
	Purpose: Find imaged specimens by barcode
	Cost: moderate (?)
	Growth potential: low
--->

<cfschedule action = "update"
    task = "es_spec_findSpec"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/es_spec.cfm?action=findSpec"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "01:31 AM"
    interval = "daily"
    requestTimeOut = "600">
<!--- 
	es_tacc_getDir
	Purpose: Find images at TACC
	Cost: High
	Growth potential: high
--->
<cfschedule action = "update"
    task = "es_tacc_getDir"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/es_tacc.cfm?action=getDir"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "02:31 AM"
    interval = "daily"
    requestTimeOut = "600">
<!--- 
	es_tacc_accn_card_media
	Purpose: Find images of accn cards at TACC
	Cost: moderate/low
	Growth potential: low
--->
<cfschedule action = "update"
    task = "es_tacc_accn_card_media"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/es_tacc.cfm?action=accn_card_media"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "02:51 AM"
    interval = "daily"
    requestTimeOut = "600">
<!--- 
	es_tacc_loc_card_media
	Purpose: Find images of locality cards at TACC
	Cost: moderate/low
	Growth potential: low
--->
<cfschedule action = "update"
    task = "es_tacc_loc_card_media"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/es_tacc.cfm?action=loc_card_media"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "03:01 AM"
    interval = "daily"
    requestTimeOut = "600">
<!--- 
	es_tacc_spec_media
	Purpose: Find images of specimens at TACC
	Cost: moderate/low
	Growth potential: low
--->
<cfschedule action = "update"
    task = "es_tacc_spec_media"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/es_tacc.cfm?action=spec_media"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "03:11 AM"
    interval = "daily"
    requestTimeOut = "600">
<!--- 
	es_tacc_spec_media_alreadyentered
	Purpose: Find images of specimens at TACC
	Cost: moderate/low
	Growth potential: low
--->
<cfschedule action = "update"
    task = "es_tacc_spec_media_alreadyentered"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/es_tacc.cfm?action=spec_media_alreadyentered"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "03:21 AM"
    interval = "daily"
    requestTimeOut = "600">

<!-----------------------------------   OCR    ------------------------------------------>
<!--- 
	ocr_specimens
	Purpose: Find OCR results at TACC
	Cost: moderate/low
	Growth potential: ??
--->
<!---
<cfschedule action = "update"
    task = "ocr_specimens"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/tacc_ocr.cfm?action=getSpecs"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:31 AM"
    interval = "daily"
    requestTimeOut = "600">
	---->
<!--- 
	ocr_crawl
	Purpose: Find OCR results at TACC
	Cost: moderate/low
	Growth potential: ??
--->
<!----
<cfschedule action = "update"
    task = "ocr_crawl"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/tacc_ocr.cfm?action=crawl"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:01 AM"
    interval = "daily"
    requestTimeOut = "300">
	---->
<!-----------------------------------   media bulkloader    ------------------------------------------>
<!--- 
	MBL_cleanup
	Purpose: Cleanup bulkloaded media
	Cost: low
	Growth potential: low
--->
<cfschedule action = "update"
    task = "MBL_cleanup"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/BulkloadMedia.cfm?action=cleanup"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:31 AM"
    interval = "daily"
    requestTimeOut = "600">
<!--- 
	MBL_report
	Purpose: Send email relating to bulkloaded media
	Cost: low
	Growth potential: low
--->
<cfschedule action = "update"
    task = "MBL_report"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/BulkloadMedia.cfm?action=report"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "04:31 AM"
    interval = "daily"
    requestTimeOut = "600">
<!--- 
	MBL_report
	Purpose: Send email relating to bulkloaded media
	Cost: low
	Growth potential: low
--->
<cfschedule action = "update"
    task = "MBL_validate"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/BulkloadMedia.cfm?action=validate"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:01 AM"
    interval = "300"
    requestTimeOut = "600">
<!--- 
	MBL_load
	Purpose: load bulkloaded media
	Cost: variable - potentially high
	Growth potential: high
--->
<cfschedule action = "update"
    task = "MBL_load"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/BulkloadMedia.cfm?action=load"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:01 AM"
    interval = "600"
    requestTimeOut = "300">


<!-----------------------------------   sitemaps    ------------------------------------------>

<!--- 
	CTupdates
	Purpose: build sitemaps
	Cost: moderate/high
	Growth potential: high
--->
<cfschedule action = "update"
    task = "CTupdates"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/CTupdates.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:01 AM"
    interval = "daily"
    requestTimeOut = "600">
<!--- 
	build_sitemap_map
	Purpose: build sitemaps
	Cost: moderate/high
	Growth potential: high
--->
<cfschedule action = "update"
    task = "build_sitemap_map"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/build_sitemap.cfm?action=build_map"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "05:00 PM"
    interval = "weekly"
    requestTimeOut = "600">
<!--- 
	build_sitemap_index
	Purpose: build sitemaps
	Cost: moderate/high
	Growth potential: high
--->
<cfschedule action = "update"
    task = "build_sitemap_index"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/build_sitemap.cfm?action=build_index"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "05:10 PM"
    interval = "weekly"
    requestTimeOut = "600">
<!--- 
	build_sitemaps_spec
	Purpose: build sitemaps
	Cost: moderate/high
	Growth potential: high
--->
<cfschedule action = "update"
    task = "build_sitemaps_spec"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/build_sitemap.cfm?action=build_sitemaps_spec"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:20 AM"
    interval = "1800"
    requestTimeOut = "600">
<!--- 
	build_sitemaps_tax
	Purpose: build sitemaps
	Cost: moderate/high
	Growth potential: high
--->
<cfschedule action = "update"
    task = "build_sitemaps_tax"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/build_sitemap.cfm?action=build_sitemaps_tax"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:23 AM"
    interval = "3600"
    requestTimeOut = "600">
<!--- 
	build_sitemaps_pub
	Purpose: build sitemaps
	Cost: moderate/high
	Growth potential: high
--->
<cfschedule action = "update"
    task = "build_sitemaps_pub"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/build_sitemap.cfm?action=build_sitemaps_pub"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:26 AM"
    interval = "3600"
    requestTimeOut = "600">
<!--- 
	build_sitemaps_proj
	Purpose: build sitemaps
	Cost: moderate/high
	Growth potential: high
--->
<cfschedule action = "update"
    task = "build_sitemaps_proj"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/build_sitemap.cfm?action=build_sitemaps_proj"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:30 AM"
    interval = "3600"
    requestTimeOut = "600">
<!--- 
	build_sitemaps_stat
	Purpose: build sitemaps
	Cost: moderate/high
	Growth potential: high
--->
<cfschedule action = "update"
    task = "build_sitemaps_stat"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/build_sitemap.cfm?action=build_sitemaps_stat"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:35 AM"
    interval = "3600"
    requestTimeOut = "600">
<!--- 
	build_sitemaps_media
	Purpose: build sitemaps
	Cost: moderate/high
	Growth potential: high
--->

<cfschedule action = "update"
    task = "build_sitemaps_media"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/build_sitemap.cfm?action=build_sitemaps_media"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:45 AM"
    interval = "1800"
    requestTimeOut = "600">
<!-----------------------------------   imaging    ------------------------------------------>
<!--- 
	ALA_ProblemReport
	Purpose: send email about ALA imaging problems
	Cost: low
	Growth potential: low
--->
<cfschedule action = "update"
    task = "ALA_ProblemReport"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/alaImaging/ala_has_probs.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "06:00 AM"
    interval = "daily"
    requestTimeOut = "600">
<!--- 
	tacc1_findAllDirectories
	Purpose: Find stuff at TACC
	Cost: high
	Growth potential: high
	NOTE: Might be able to merge this and UAM:ES find images
--->
<cfschedule action = "update"
    task = "tacc1_findAllDirectories"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/tacc.cfm?action=findAllDirectories"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "04:30 AM"
    interval = "daily">
<!--- 
	TACC2_findFilesOnePath
	Purpose: Find one folder of stuff at TACC
	Cost: moderate
	Growth potential: moderate/low
	NOTE: Might be able to merge this and UAM:ES imaging
--->
<cfschedule action = "update"
    task = "TACC2_findFilesOnePath"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/tacc.cfm?action=findFilesOnePath"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:17 AM"
    interval = "7200">
<!--- 
	TACC3_linkToSpecimens
	Purpose: Hook specimens to TACC media
	Cost: moderate/high
	Growth potential: moderate/low
	NOTE: Might be able to merge this and UAM:ES imaging
--->
<cfschedule action = "update"
    task = "TACC3_linkToSpecimens"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/tacc.cfm?action=linkToSpecimens"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:27 AM"
    interval = "1200">
<!--- 
	TACC4_makeDNGMedia
	Purpose: Hook specimens to TACC media
	Cost: moderate/high
	Growth potential: moderate/low
	NOTE: Might be able to merge this and UAM:ES imaging
--->
<cfschedule action = "update"
    task = "TACC4_makeDNGMedia"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/tacc.cfm?action=makeDNGMedia"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:37 AM"
    interval = "3600">

<!--- 
	TACC5_makeJPGMedia
	Purpose: Hook specimens to TACC media
	Cost: moderate/high
	Growth potential: moderate/low
	NOTE: Might be able to merge this and UAM:ES imaging
--->
<cfschedule action = "update"
    task = "TACC5_makeJPGMedia"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/tacc.cfm?action=makeJPGMedia"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:47 AM"
    interval = "3600">

<!-----------------------------------   curatorial alerts    ------------------------------------------>
<!--- 
	reminder
	Purpose: loans due, permits expiring, etc. notifications
	Cost: low/moderate
	Growth potential: moderate/high
--->
<cfschedule action = "update"
    task = "reminder"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/reminder.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:56 AM"
    interval = "daily"
    requestTimeOut = "600">
<!--- 
	globalnames_refresh
	Purpose: Refresh data from globalnames
	Cost: moderate
	Growth potential: moderate/high
	Usage: refreshes data in table taxon_refresh_log. Manually add needs-refreshed data to this table. When
		the table is empty or all rows have NOT NULL lastfetch, the job will immediately exit.
--->
<cfschedule action = "update"
    task = "globalnames_refresh"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/globalnames_refresh.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:00 AM"
    interval = "600"
    requestTimeOut = "600">
<!--- 
	authority_change
	Purpose: code tables or geography change notifications
	Cost: moderate
	Growth potential: low/moderate
--->
<cfschedule action = "update"
    task = "authority_change"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/authority_change.cfm?action=sendEmail"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:59 AM"
    interval = "daily"
    requestTimeOut = "600">
<!--- 
	genbank_crawl_institution_wild2
	Purpose: Find uncited specimens at GenBank
	Cost: low/moderate
	Growth potential: high
--->
<cfschedule action = "update"
    task = "genbank_crawl_institution_wild2"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/genbank_crawl.cfm?action=institution_wild2"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "07:25 AM"
    interval = "daily"
    requestTimeOut = "600">
<!--- 
	genbank_crawl_institution_wild1
	Purpose: Find uncited specimens at GenBank
	Cost: low/moderate
	Growth potential: high
--->
<cfschedule action = "update"
    task = "genbank_crawl_institution_wild1"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/genbank_crawl.cfm?action=institution_wild1"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "07:20 AM"
    interval = "daily"
    requestTimeOut = "600">
<!--- 
	genbank_crawl_collection_wild2
	Purpose: Find uncited specimens at GenBank
	Cost: low/moderate
	Growth potential: high
--->
<cfschedule action = "update"
    task = "genbank_crawl_collection_wild2"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/genbank_crawl.cfm?action=collection_wild2"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "07:15 AM"
    interval = "daily"
    requestTimeOut = "600">
<!--- 
	genbank_crawl_collection_wild1
	Purpose: Find uncited specimens at GenBank
	Cost: low/moderate
	Growth potential: high
--->
<cfschedule action = "update"
    task = "genbank_crawl_collection_wild1"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/genbank_crawl.cfm?action=collection_wild1"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "07:10 AM"
    interval = "daily"
    requestTimeOut = "600">
<!--- 
	genbank_crawl_collection_voucher
	Purpose: Find uncited specimens at GenBank
	Cost: low/moderate
	Growth potential: high
--->
<cfschedule action = "update"
    task = "genbank_crawl_collection_voucher"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/genbank_crawl.cfm?action=collection_voucher"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "07:05 AM"
    interval = "daily"
    requestTimeOut = "600">
<!--- 
	genbank_crawl_institution_voucher
	Purpose: Find uncited specimens at GenBank
	Cost: low/moderate
	Growth potential: high
--->
<cfschedule action = "update"
    task = "genbank_crawl_institution_voucher"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/genbank_crawl.cfm?action=institution_voucher"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "07:00 AM"
    interval = "daily"
    requestTimeOut = "600">
<!-----------------------------------   sharing data    ------------------------------------------>
<!--- 
	GenBank_build
	Purpose: Build linkouts from GenBank
	Cost: low/moderate
	Growth potential: high
--->
<cfschedule action = "update"
    task = "GenBank_build"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/GenBank_build.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "10:00 PM"
    interval = "daily"
    requestTimeOut = "600">
<!--- 
	GenBank_transfer_name
	Purpose: Build linkouts from GenBank
	Cost: low/moderate
	Growth potential: high
--->
<cfschedule action = "update"
    task = "GenBank_transfer_name"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/GenBank_transfer_name.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "10:30 PM"
    interval = "daily"
    requestTimeOut = "600">
<!--- 
	GenBank_transfer_nuc
	Purpose: Build linkouts from GenBank
	Cost: low/moderate
	Growth potential: high
--->
<cfschedule action = "update"
    task = "GenBank_transfer_nuc"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/GenBank_transfer_nuc.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "10:35 PM"
    interval = "daily"
    requestTimeOut = "600">
<!--- 
	GenBank_transfer_tax
	Purpose: Build linkouts from GenBank
	Cost: low/moderate
	Growth potential: high
--->
<cfschedule action = "update"
    task = "GenBank_transfer_tax"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/GenBank_transfer_tax.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "10:40 PM"
    interval = "daily"
    requestTimeOut = "600">
<!-----------------------------------   maintenance    ------------------------------------------>
<!--- 
	cf_spec_res_cols
	Purpose: Sync specresults with code table additions
	Cost: low
	Growth potential: low
--->
<cfschedule action = "update"
    task = "cf_spec_res_cols"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/cf_spec_res_cols.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "01:38 AM"
    interval = "weekly"
    requestTimeOut = "600">
<!--- 
	CleanTempFiles
	Purpose: Clean up temporary fileserver gunk
	Cost: low
	Growth potential: low/moderate
	NOTE: perhaps more efficient as CRON, but easier to maintain from here
--->	
<cfschedule action = "update"
    task = "CleanTempFiles"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/CleanTempFiles.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:00 AM"
    interval = "daily"
    requestTimeOut = "600">
<!--- 
	build_home
	Purpose: maintain home.cfm
	Cost: low
	Growth potential: low/moderate
--->
<cfschedule action = "update"
    task = "build_home"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/build_home.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:56 AM"
    interval = "daily"
    requestTimeOut = "600">
<!--- 
	build_robots
	Purpose: maintain robots.txt
	Cost: low
	Growth potential: low/moderate
--->
<cfschedule action = "update"
    task = "build_robots"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/createRobots.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "1:36 AM"
    interval = "weekly"
    requestTimeOut = "600">
<!--- 
	stale_users
	Purpose: lock old and unused user accounts
	Cost: low
	Growth potential: low/moderate
--->
<cfschedule action = "update"
    task = "stale_users"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/stale_users.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "1:56 AM"
    interval = "weekly"
    requestTimeOut = "600">