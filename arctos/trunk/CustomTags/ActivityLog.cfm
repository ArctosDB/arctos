<cfset web_user = "MCAT_WU">
<cfquery name="userid" datasource="#Application.web_user#">
	select user_id from cf_users where username = '#client.username#'
</cfquery>
<cfquery name="activID" datasource="#Application.web_user#">
	select max(activity_id) + 1 as nextID from cf_database_activity
</cfquery>
	<cfset user_id = #userid.user_id#>
	<cfset activity_id = #activID.nextID#>
	<cfset tmstmp = "#dateformat(now(),'dd-mmm-yyyy')#">
	<cfset SqlStmnt = #Attributes.sql#>

<cfquery name="updateLog" datasource="#Application.web_user#">
	INSERT INTO cf_database_activity (
		activity_id,
		user_id,
		date_stamp,
		sql_statement
		 )
	VALUES (
		#activity_id#,
		#user_id#,
		'#tmstmp#',
		'#SqlStmnt#'
		)
</cfquery>