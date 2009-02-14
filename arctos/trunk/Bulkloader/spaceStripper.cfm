<cfoutput>
<cfif #cgi.SERVER_NAME# contains "arctos.database">
	<cfquery name="getBLColNames" datasource="uam_god">
		select column_name from sys.user_tab_cols
		where table_name='BULKLOADER'
		order by internal_column_id
	</cfquery>
<cfelseif #cgi.SERVER_NAME# contains "berkeley">
	<cfquery name="getBLColNames" datasource="uam_god">
		select column_name from information_schema.columns
		where upper(table_name)='BULKLOADER'
	</cfquery>
</cfif>

<cfloop query="getBLColNames">
	<cfquery name="strip" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update bulkloader set #column_name# = trim(#column_name#)
	</cfquery>
</cfloop>
</cfoutput>