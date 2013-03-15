<!--- first, get rid of everything --->
<cfobject type="JAVA" action="Create" name="factory" class="coldfusion.server.ServiceFactory">
<cfset allTasks = factory.CronService.listAll()>
<cfset numberOtasks = arraylen(allTasks)>
<cfloop index="i" from="1" to="#numberOtasks#">
	<cfschedule action="delete" task="#allTasks[i].task#">
</cfloop>
<!-----------------------------------   related specimens cache    ------------------------------------------>
<cfschedule action = "update"
    task = "fetchRelatedInfo"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/fetchRelatedInfo.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "05:51 AM"
    interval = "daily"
    requestTimeOut = "600">
<!-----------------------------------   Agent merge/delete    ------------------------------------------>
<cfschedule action = "update"
    task = "duplicate_agents_findDups"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/duplicate_agents.cfm?action=findDups"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "04:51 AM"
    interval = "daily"
    requestTimeOut = "600">
<cfschedule action = "update"
    task = "duplicate_agents_merge"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/duplicate_agents.cfm?action=merge"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "05:01 AM"
    interval = "daily"
    requestTimeOut = "600">
<cfschedule action = "update"
    task = "duplicate_agents_notify"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/duplicate_agents.cfm?action=notify"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "05:21 AM"
    interval = "daily"
    requestTimeOut = "600">


<!-----------------------------------   UAM Earth Science Imaging    ------------------------------------------>
<!--- insert to bulkloader ---->
<cfschedule action = "update"
    task = "es_spec_insBulk"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/es_spec.cfm?action=insBulk"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:21 AM"
    interval = "daily"
    requestTimeOut = "600">
<!--- give the newly bulkloaded specimens an hour to run, then find them--->
<cfschedule action = "update"
    task = "es_spec_findSpec"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/es_spec.cfm?action=findSpec"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "01:31 AM"
    interval = "daily"
    requestTimeOut = "600">

<!--- find everything at TACC ---->
<cfschedule action = "update"
    task = "es_tacc_getDir"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/es_tacc.cfm?action=getDir"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "02:31 AM"
    interval = "daily"
    requestTimeOut = "600">
<!--- TACC media to accn cards ---->
<cfschedule action = "update"
    task = "es_tacc_accn_card_media"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/es_tacc.cfm?action=accn_card_media"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "02:51 AM"
    interval = "daily"
    requestTimeOut = "600">
<!--- TACC media to locality cards ---->
<cfschedule action = "update"
    task = "es_tacc_loc_card_media"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/es_tacc.cfm?action=loc_card_media"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "03:01 AM"
    interval = "daily"
    requestTimeOut = "600">
<!--- TACC media to paleoimager-created specimens ---->
<cfschedule action = "update"
    task = "es_tacc_spec_media"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/es_tacc.cfm?action=spec_media"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "03:11 AM"
    interval = "daily"
    requestTimeOut = "600">

<!--- TACC media to already-existing specimens ---->
<cfschedule action = "update"
    task = "es_tacc_spec_media_alreadyentered"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/es_tacc.cfm?action=spec_media_alreadyentered"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "03:21 AM"
    interval = "daily"
    requestTimeOut = "600">

<!-----------------------------------   OCR    ------------------------------------------>

<cfschedule action = "update"
    task = "ocr_specimens"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/tacc_ocr.cfm?action=getSpecs"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:31 AM"
    interval = "daily"
    requestTimeOut = "600">
<cfschedule action = "update"
    task = "ocr_crawl"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/tacc_ocr.cfm?action=crawl"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:01 AM"
    interval = "600"
    requestTimeOut = "300">
<!-----------------------------------   media bulkloader    ------------------------------------------>
<cfschedule action = "update"
    task = "MBL_cleanup"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/BulkloadMedia.cfm?action=cleanup"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:31 AM"
    interval = "daily"
    requestTimeOut = "600">
<cfschedule action = "update"
    task = "MBL_report"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/BulkloadMedia.cfm?action=report"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "04:31 AM"
    interval = "daily"
    requestTimeOut = "600">
<cfschedule action = "update"
    task = "MBL_validate"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/BulkloadMedia.cfm?action=validate"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:01 AM"
    interval = "120"
    requestTimeOut = "300">
<cfschedule action = "update"
    task = "MBL_load"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/BulkloadMedia.cfm?action=load"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:01 AM"
    interval = "300"
    requestTimeOut = "300">


<!-----------------------------------   sitemaps    ------------------------------------------>


<cfschedule action = "update"
    task = "CTupdates"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/CTupdates.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:01 AM"
    interval = "daily"
    requestTimeOut = "600">
<cfschedule action = "update"
    task = "cf_spec_res_cols"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/cf_spec_res_cols.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "01:38 AM"
    interval = "weekly"
    requestTimeOut = "600">
<cfschedule action = "update"
    task = "build_sitemap_map"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/build_sitemap.cfm?action=build_map"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "05:00 PM"
    interval = "weekly"
    requestTimeOut = "600">
<cfschedule action = "update"
    task = "build_sitemap_index"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/build_sitemap.cfm?action=build_index"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "05:10 PM"
    interval = "weekly"
    requestTimeOut = "600">
<cfschedule action = "update"
    task = "build_sitemaps_spec"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/build_sitemap.cfm?action=build_sitemaps_spec"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:20 AM"
    interval = "1800"
    requestTimeOut = "600">
<cfschedule action = "update"
    task = "build_sitemaps_tax"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/build_sitemap.cfm?action=build_sitemaps_tax"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:23 AM"
    interval = "3600"
    requestTimeOut = "600">
<cfschedule action = "update"
    task = "build_sitemaps_pub"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/build_sitemap.cfm?action=build_sitemaps_pub"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:26 AM"
    interval = "3600"
    requestTimeOut = "600">
<cfschedule action = "update"
    task = "build_sitemaps_proj"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/build_sitemap.cfm?action=build_sitemaps_proj"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:30 AM"
    interval = "3600"
    requestTimeOut = "600">
<cfschedule action = "update"
    task = "build_sitemaps_stat"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/build_sitemap.cfm?action=build_sitemaps_stat"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:35 AM"
    interval = "3600"
    requestTimeOut = "600">

<cfschedule action = "update"
    task = "build_sitemaps_media"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/build_sitemap.cfm?action=build_sitemaps_media"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:45 AM"
    interval = "1800"
    requestTimeOut = "600">
<!-----------------------------------   imaging    ------------------------------------------>
<cfschedule action = "update"
    task = "ALA_ProblemReport"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/alaImaging/ala_has_probs.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "06:00 AM"
    interval = "daily"
    requestTimeOut = "600">
<cfschedule action = "update"
    task = "tacc1_findAllDirectories"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/tacc.cfm?action=findAllDirectories"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "04:30 AM"
    interval = "daily">
<cfschedule action = "update"
    task = "TACC2_findFilesOnePath"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/tacc.cfm?action=findFilesOnePath"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:17 AM"
    interval = "7200">
<cfschedule action = "update"
    task = "TACC3_linkToSpecimens"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/tacc.cfm?action=linkToSpecimens"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:27 AM"
    interval = "1200">
<cfschedule action = "update"
    task = "TACC4_makeDNGMedia"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/tacc.cfm?action=makeDNGMedia"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:37 AM"
    interval = "3600">
<cfschedule action = "update"
    task = "TACC5_makeJPGMedia"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/tacc.cfm?action=makeJPGMedia"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:47 AM"
    interval = "3600">

<!-----------------------------------   curatorial alerts    ------------------------------------------>
<!--- no longer exists - replace with 'someone made a link to your stuff' eventually

<cfschedule action = "update"
    task = "attention_needed"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/attention_needed.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "01:00 AM"
    interval = "daily"
    requestTimeOut = "600">
---->
<cfschedule action = "update"
    task = "reminder"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/reminder.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:56 AM"
    interval = "daily"
    requestTimeOut = "600">
<!----
<cfschedule action = "update"
    task = "pendingRelations"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/pendingRelations.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "3:38 AM"
    interval = "daily"
    requestTimeOut = "600">
	---->
<cfschedule action = "update"
    task = "genbank_crawl_institution_wild2"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/genbank_crawl.cfm?action=institution_wild2"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "07:25 AM"
    interval = "daily"
    requestTimeOut = "600">
<cfschedule action = "update"
    task = "genbank_crawl_institution_wild1"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/genbank_crawl.cfm?action=institution_wild1"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "07:20 AM"
    interval = "daily"
    requestTimeOut = "600">
<cfschedule action = "update"
    task = "genbank_crawl_collection_wild2"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/genbank_crawl.cfm?action=collection_wild2"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "07:15 AM"
    interval = "daily"
    requestTimeOut = "600">
<cfschedule action = "update"
    task = "genbank_crawl_collection_wild1"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/genbank_crawl.cfm?action=collection_wild1"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "07:10 AM"
    interval = "daily"
    requestTimeOut = "600">
<cfschedule action = "update"
    task = "genbank_crawl_collection_voucher"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/genbank_crawl.cfm?action=collection_voucher"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "07:05 AM"
    interval = "daily"
    requestTimeOut = "600">
<cfschedule action = "update"
    task = "genbank_crawl_institution_voucher"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/genbank_crawl.cfm?action=institution_voucher"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "07:00 AM"
    interval = "daily"
    requestTimeOut = "600">
<!-----------------------------------   sharing data    ------------------------------------------>
<cfschedule action = "update"
    task = "GenBank_build"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/GenBank_build.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "10:00 PM"
    interval = "daily"
    requestTimeOut = "600">
<cfschedule action = "update"
    task = "GenBank_transfer_name"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/GenBank_transfer_name.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "10:30 PM"
    interval = "daily"
    requestTimeOut = "600">
<cfschedule action = "update"
    task = "GenBank_transfer_nuc"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/GenBank_transfer_nuc.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "10:35 PM"
    interval = "daily"
    requestTimeOut = "600">
<cfschedule action = "update"
    task = "GenBank_transfer_tax"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/GenBank_transfer_tax.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "10:40 PM"
    interval = "daily"
    requestTimeOut = "600">
<!-----------------------------------   maintenance    ------------------------------------------>
<cfschedule action = "update"
    task = "CleanTempFiles"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/CleanTempFiles.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:00 AM"
    interval = "daily"
    requestTimeOut = "600">
<cfschedule action = "update"
    task = "build_home"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/build_home.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:56 AM"
    interval = "daily"
    requestTimeOut = "600">
<cfschedule action = "update"
    task = "build_robots"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/createRobots.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "1:36 AM"
    interval = "weekly"
    requestTimeOut = "600">
<cfschedule action = "update"
    task = "stale_users"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/stale_users.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "1:56 AM"
    interval = "weekly"
    requestTimeOut = "600">

<!----
	We're now on the TACC server so there's no reason to move this stuff off to the TACC server

<!-----------------------------------   images    ------------------------------------------>
<cfschedule action = "update"
    task = "image_CheckNew"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/localToTacc.cfm?action=checkNew"
    startDate = "1-jan-2008"
    startTime = "12:30 AM"
    interval = "weekly"
    requestTimeOut = "600">
<cfschedule action = "update"
    task = "image_transfer"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/localToTacc.cfm?action=transfer"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "#timeformat(now())#"
    interval = "300"
    requestTimeOut = "300">
<cfschedule action = "update"
    task = "image_findIt"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/localToTacc.cfm?action=findIt"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:00 AM"
    interval = "28800"
    requestTimeOut = "600">
<cfschedule action = "update"
    task = "image_fixURI"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/localToTacc.cfm?action=fixURI"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "01:00 AM"
    interval = "28800"
    requestTimeOut = "600">
<cfschedule action = "update"
    task = "image_recoverDisk"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/localToTacc.cfm?action=recoverDisk"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "02:59 AM"
    interval = "daily"
    requestTimeOut = "3600">
<cfschedule action = "update"
    task = "image_report"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/localToTacc.cfm?action=report"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "02:34 AM"
    interval = "weekly"
    requestTimeOut = "600">





<cfschedule action = "update"
    task = "dupsAtTacc"
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/dupsAtTacc.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "12:34 AM"
    interval = "600"
    requestTimeOut = "600">
--------->
