<cfschedule action = "update"
    task = "sitemap_map" 
    operation = "HTTPRequest"
    url = "http://arctos.database.museum/ScheduledTasks/build_sitemap.cfm?action=build_map"
    startDate = "dateformat(now(),'dd-mmm-yyyy')"
    startTime = "05:00 PM"
    interval = "weekly"
    requestTimeOut = "600">
	
<cfschedule action = "update"
    task = "sitemap_index" 
    operation = "HTTPRequest"
    url = "http://arctos.database.museum/ScheduledTasks/build_sitemap.cfm?action=build_index"
    startDate = "dateformat(now(),'dd-mmm-yyyy')"
    startTime = "05:10 PM"
    interval = "weekly"
    requestTimeOut = "600">
	
<cfschedule action = "update"
    task = "sitemap_spec" 
    operation = "HTTPRequest"
    url = "http://arctos.database.museum/ScheduledTasks/build_sitemap.cfm?action=build_sitemaps_spec"
    startDate = "dateformat(now(),'dd-mmm-yyyy')"
    startTime = "05:20 PM"
    interval = "3600"
    requestTimeOut = "600">
	
<cfschedule action = "update"
    task = "ALA_ProblemReport" 
    operation = "HTTPRequest"
    url = "http://arctos.database.museum/ScheduledTasks/alaImaging/ala_has_probs.cfm"
    startDate = "1-jan-2008"
    startTime = "06:00 AM"
    interval = "daily"
    requestTimeOut = "600">

<cfschedule action = "update"
    task = "attention_needed" 
    operation = "HTTPRequest"
    url = "http://arctos.database.museum/ScheduledTasks/alaImaging/attention_needed.cfm"
    startDate = "1-jan-2008"
    startTime = "01:00 AM"
    interval = "daily"
    requestTimeOut = "600">
	
<cfschedule action = "update"
    task = "GenBank_build" 
    operation = "HTTPRequest"
    url = "http://arctos.database.museum/ScheduledTasks/GenBank_build.cfm"
    startDate = "1-jan-2008"
    startTime = "10:00 PM"
    interval = "daily"
    requestTimeOut = "600">
	
<cfschedule action = "update"
    task = "GenBank_transfer_name" 
    operation = "HTTPRequest"
    url = "http://arctos.database.museum/ScheduledTasks/GenBank_transfer_name.cfm"
    startDate = "1-jan-2008"
    startTime = "10:30 PM"
    interval = "daily"
    requestTimeOut = "600">

<cfschedule action = "update"
    task = "GenBank_transfer_nuc" 
    operation = "HTTPRequest"
    url = "http://arctos.database.museum/ScheduledTasks/GenBank_transfer_nuc.cfm"
    startDate = "1-jan-2008"
    startTime = "10:35 PM"
    interval = "daily"
    requestTimeOut = "600">

<cfschedule action = "update"
    task = "GenBank_transfer_tax" 
    operation = "HTTPRequest"
    url = "http://arctos.database.museum/ScheduledTasks/GenBank_transfer_tax.cfm"
    startDate = "1-jan-2008"
    startTime = "10:40 PM"
    interval = "daily"
    requestTimeOut = "600">


<cfschedule action = "update"
    task = "CleanTempFiles" 
    operation = "HTTPRequest"
    url = "http://arctos.database.museum/ScheduledTasks/CleanTempFiles.cfm"
    startDate = "1-jan-2008"
    startTime = "12:00 AM"
    interval = "daily"
    requestTimeOut = "600">
	
<cfschedule action = "update"
    task = "build_home" 
    operation = "HTTPRequest"
    url = "http://arctos.database.museum/ScheduledTasks/build_home.cfm"
    startDate = "1-jan-2008"
    startTime = "12:56 AM"
    interval = "daily"
    requestTimeOut = "600">

<cfschedule action = "update"
    task = "reminder" 
    operation = "HTTPRequest"
    url = "http://arctos.database.museum/ScheduledTasks/reminder.cfm"
    startDate = "1-jan-2008"
    startTime = "12:56 AM"
    interval = "daily"
    requestTimeOut = "600">