<cfcomponent>
<!----------------------------------------------------------------------------------------->
<cffunction name="getTags" access="remote">
	<cfargument name="media_id" required="yes">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from tag where media_id=#media_id#
	</cfquery>
	<cfreturn data>
</cffunction>
<!--------------------------------------->
</cfcomponent>