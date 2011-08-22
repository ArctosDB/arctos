<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
		short_doc_id,
		more_info
 from short_doc where more_info is not null		
</cfquery>
<cfoutput>
	<cfloop query="d">
		<hr>
		#more_info#
		<br>
		<cfhttp url="#more_info#" method="head"></cfhttp>
		<cfif cfhttp.Statuscode is '200 OK'>
			<br>spiffy
		<cfelse>
			<br><a href="/doc/short_doc.cfm?action=edit&short_doc_id=#short_doc_id#">
				======================================= fixit ========================
			</a>
		</cfif>
	</cfloop>
</cfoutput>
