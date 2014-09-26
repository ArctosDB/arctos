<cfcomponent>
<cffunction name="remNKFromPosn" returntype="string">
	<cfargument name="freezer" type="numeric" required="yes">
	<cfargument name="rack" type="numeric" required="yes">
	<cfargument name="box" type="numeric" required="yes">
	<cfargument name="place" type="numeric" required="yes">
	<cfargument name="tissue_type" type="string" required="yes">
	<cfargument name="nk" type="numeric" required="yes">
	<cfset result=#place#>
	<cftry>
	<cftransaction>
	<cfquery name="newLoc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from dgr_locator
		where  
			freezer=#freezer# AND
			rack= #rack# and
			box = #box# AND
			place = #place# AND
			nk = #nk# AND
			tissue_type = '#tissue_type#'
	</cfquery>
	
	</cftransaction>
	<cfcatch>
		<cfset result=999999>
	</cfcatch>
	</cftry>
		<cfreturn result>
</cffunction>
</cfcomponent>