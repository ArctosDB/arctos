<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
		more_info,
				replace(replace(more_info,'http://g-arctos.appspot.com/arctosdoc/','http://arctosdb.wordpress.com/documentation/'),'.html','/')
 newurl
 from short_doc where more_info is not null		
</cfquery>
<cfoutput>
	<cfloop query="d">
		<hr>
		old URL: #more_info#
		<br>
		new URL: #newurl#
		<cfhttp url="#newurl#" method="head"></cfhttp>
		<cfdump var=#cfhttp#>
	</cfloop>
</cfoutput>
