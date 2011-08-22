<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
		short_doc_id,
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
		<cfif cfhttp.Statuscode is '200 OK '>
			<br>spiffy
		<cfelse>
			<br><a href="/doc/short_doc.cfm?action=edit&short_doc_id=#short_doc_id#">
				======================================= fixit ========================
			</a>
		</cfif>
		<cfdump var=#cfhttp#>
	</cfloop>
</cfoutput>
