<cfset web_user = "MCAT_WU">
<cfset collections = #Attributes.coll#>
<cfset numrecords = #Attributes.cnt#>
<cfif isdefined("Attributes.page")>
	<cfset script_name = #Attributes.page#>
<cfelse>
	<cfset script_name = #cgi.SCRIPT_NAME#>
</cfif>
<cfset tmstmp = "#dateformat(now(),'dd-mmm-yyyy')#">
<cfquery name="updateLog" datasource="cf_dbuser">
	INSERT INTO cf_user_log (
		IP,
		HOST,
		FORM,
		DATESTAMP,
		USERNAME,
		collections,
		numrecords
		 )
	VALUES (
		'#cgi.remote_addr#',
		'#remote_host#',
		'#script_name#',
		'#tmstmp#',
		<cfif isdefined("session.username")>
			'#session.username#',
		<cfelse>
			'guest user',
		</cfif>
		'#collections#',
		#numrecords#
		)
</cfquery>