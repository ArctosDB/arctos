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
    task = "GenBank_transfer" 
    operation = "HTTPRequest"
    url = "http://arctos.database.museum/ScheduledTasks/GenBank_transfer.cfm"
    startDate = "1-jan-2008"
    startTime = "10:30 PM"
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