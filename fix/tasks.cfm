 <!--- Set Defaults and Constants --->
<cfscript>
	sitename = "mvzarctos-dev.berkeley.edu";
	
	defaultTaskName = "#Replace(sitename,'.','','all')#-";
	defaultTaskURL = "http://#sitename#/";
	defaultStartDate = DateFormat(now());
	defaultStartTime = TimeFormat(now());
	defaultPath = GetDirectoryFromPath(GetCurrentTemplatePath());
	defaultFileName = "output.htm";
	defaultInterval = "daily";
	
	message = "";
</cfscript>

<!--- UPDATE Schedule --->
<cfif isdefined("FORM.taskName")>
	
	<!--- Make sure we are only editing our own tasks --->
	<!--- Prefix the task name with the site name --->
	<cfif FindNoCase(defaultTaskName,FORM.taskName) EQ 0>
		<cfset FORM.taskName = sitename & "-" & FORM.taskName>
	</cfif>
	
	<cfschedule 
		action="update" 
		task="#FORM.taskName#"
		url="#FORM.taskURL#"
		operation="httprequest"
		interval="#FORM.taskInterval#"
		startdate="#FORM.taskStartDate#"
		starttime="#FORM.taskStartTime#"
		publish="yes"
		path="#FORM.taskPublishPath#"
		file="#FORM.taskPublishFile#">
	
	<cfset message = "Schedule Updated">
</cfif>

<!--- DELETE Schedule --->
<cfif isdefined("FORM.taskDeleteName")>
	<cfschedule 
		action="delete" 
		task="#FORM.taskDeleteName#">

	<cfset message = "Schedule Deleted">
</cfif>


<!--- RUN Schedule --->
<cfif isdefined("FORM.taskRunName")>
	<cfschedule 
		action="run" 
		task="#FORM.taskRunName#">

	<cfset message = "Schedule Ran">
</cfif>

<!--- Grab all the Scheduled Tasks --->
<cflock name="#sitename#" type="exclusive" timeout="10">

	<!--- http://www.anticlue.net/archives/000303.htm --->
	<cfscript>
		factory = CreateObject("java","coldfusion.server.ServiceFactory");
		cron_service = factory.CronService;
		services = cron_service.listALL();
	</cfscript>

</cflock>

<!--- Set Form values if Form is in edit mode. --->
<cfif isdefined("FORM.taskUpdateName")>

	<!--- Find the task to edit. --->
	<cfloop index="i" from="1" to="#ArrayLen(services)#">
		<cfif services[i].task EQ FORM.taskUpdateName>
			<cfscript>
				defaultTaskName = services[i].task;
				defaultTaskURL = services[i].url;
				defaultStartDate = services[i].start_date;
				defaultStartTime = services[i].start_time;
				defaultPath = services[i].path;
				defaultFileName = services[i].file;
				defaultInterval = services[i].interval;
			</cfscript>
		</cfif>
	</cfloop>

</cfif>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<cfoutput><title>#sitename# Scheduler</title</cfoutput>>

<style type="text/css">
	table {border:3px double #003366;}
	table th {background-color:#003366; color:#FFFFFF;}
	table td {border-bottom:1px solid #F0F0F0;}
</style>

</head>

<body>
<cfoutput><h3 style="color:green;">#message#</h3></cfoutput>

<cfform name="mySchedule" method="post" action="#CGI.SCRIPT_NAME#">
<table cellpadding="4" cellspacing="0">
	<tr><th colspan="2">Tasks</th></tr>
	
	<tr><td>Task Name:</td><td>
	<cfinput  
		name="taskName" 
		type="text" 
		required="yes" 
		message="Task Name Required" 
		value="#defaultTaskName#"
		size="40" >
	</td></tr>
	
	<tr><td>URL:</td><td>
	<cfinput 
		name="taskURL" 
		type="text" 
		required="yes" 
		message="Full URL is required." 
		value="#defaultTaskURL#" 
		size="60">
	</td></tr>
	
	<tr><td>Start Date:</td><td>
	<cfinput 
		name="taskStartDate" 
		type="text" 
		required="yes" 
		validate="date" 
		value="#defaultStartDate#" 
		message="Enter a valid start date." 
		size="10"> 
	Time: 
	<cfinput 
		name="taskStartTime" 
		type="text" 
		required="yes" 
		validate="time" 
		value="#defaultStartTime#" 
		message="Enter a valid start time." 
		size="10">
	</td></tr>
	
	<tr><td>Publish Path:</td><td>
	<cfinput 
		name="taskPublishPath" 
		type="text" 
		required="yes" 
		value="#defaultPath#" 
		message="Enter path for published file." 
		size="50">
	File Name: 
	<cfinput 
		name="taskPublishFile" 
		type="text" 
		required="yes" 
		value="#defaultFileName#" 
		message="Enter file name for published file." 
		size="10">
	</td></tr>

	<tr><td>Interval:</td><td>
	<cfinput 
		name="taskInterval" 
		type="text" 
		required="yes" 
		value="#defaultInterval#" 
		message="Enter number of seconds, 'once', 'daily', 'weekly', 'monthly'.">
	</td></tr>

	<tr><td>&nbsp;</td><td>
	<cfinput 
		name="taskSubmit" 
		type="submit" 
		value="Submit">
	</td></tr>

</table>
</cfform>
<br>

<cftry>
	<cfoutput>
	<table cellpadding="4" cellspacing="0">
		<tr>
			<th>Run Now</th>
			<th>Update</th>
			<th>Task Name</th>
			<th>Start Date</th>
			<th>Start Time</th>
			<th>End Date</th>
			<th>Interval</th>
			<th>Delete</th>
		</tr>
		<!--- Loop all the scheduled task's --->
		<cfloop index="i" from="1" to="#ArrayLen(services)#">
		
		<!--- Only display our tasks, the list will return all tasks on the server. --->
		<cfif FindNoCase(sitename,services[i].url)>
		<tr>
			<td>
				<form 
					name="runNow#services[i].task#" 
					method="post" 
					action="#CGI.SCRIPT_NAME#" 
					style="display:inline; margin:0;">
					
					<input 
						type="submit" 
						name="runNow" 
						value="Run Now">
						
					<input 
						type="hidden" 
						name="taskRunName" 
						value="#services[i].task#">
				</form>
			</td>
			<td>
				<form 
					name="updateTask#services[i].task#" 
					method="post" 
					action="#CGI.SCRIPT_NAME#" 
					style="display:inline; margin:0;">
					
					<input 
						type="submit" 
						name="update" 
						value="Update">
						
					<input 
						type="hidden" 
						name="taskUpdateName" 
						value="#services[i].task#">
				</form>
			</td>
			<td>#services[i].task#</td>
			<td nowrap>#services[i].start_date#</td>
			<td nowrap>#services[i].start_time#</td>
			<td nowrap>#services[i].end_date#</td>
			<td>#services[i].interval#</td>
			<td>
				<form 
					name="deleteTask#services[i].task#" 
					method="post" 
					action="#CGI.SCRIPT_NAME#" 
					style="display:inline; margin:0;">
					
					<input 
						type="submit" 
						name="deleteTask" 
						value="Delete">
						
					<input 
						type="hidden" 
						name="taskDeleteName" 
						value="#services[i].task#">
				</form>
			</td>
		</tr>
		</cfif>
		</cfloop>
	</table>
	</cfoutput>

	<cfcatch type="any">
		<cfdump var="#cfcatch#">
	</cfcatch>
</cftry>

</body>
</html>
