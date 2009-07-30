<cfschedule action = "update"
    task = "image_transfer" 
    operation = "HTTPRequest"
    url = "127.0.0.1/ScheduledTasks/checkNew.cfm"
    startDate = "#dateformat(now(),'dd-mmm-yyyy')#"
    startTime = "#timeformat(now() + 10)#"
    interval = "180"
    requestTimeOut = "600">