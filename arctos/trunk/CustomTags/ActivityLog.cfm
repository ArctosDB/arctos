<cfset web_user = "MCAT_WU">
<cfquery name="userid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select user_id from cf_users where username = '#session.username#'
</cfquery>
<cfquery name="activID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select max(activity_id) + 1 as nextID from cf_database_activity
</cfquery>
	<cfset user_id = #userid.user_id#>
	<cfset activity_id = #activID.nextID#>
	<cfset tmstmp = "#dateformat(now(),'dd-mmm-yyyy')#">
	<cfset SqlStmnt = #Attributes.sql#>

<cfquery name="updateLog" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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