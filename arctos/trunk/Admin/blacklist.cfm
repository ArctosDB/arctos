<cfinclude template="/includes/_header.cfm">
<cfoutput>
<cfif action is "nothing">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select ip from uam.blacklist order by to_number(replace(ip,'.'))
	</cfquery>
	<cfset application.blacklist=valuelist(d.ip)>
	<form name="i" method="post" action="blacklist.cfm">
		<input type="hidden" name="action" value="ins">
		<label for="ip">Add IP</label>
		<input type="text" name="ip" id="ip">
		<br><input type="submit" value="blacklist">
	</form>
	<cfloop query="d">
		<br>#ip# <a href="blacklist.cfm?action=del&ip=#ip#">Remove</a>
		<a href="http://whois.domaintools.com/#ip#" target="_blank">whois</a>
	</cfloop>
</cfif>
<cfif action is "ins">
	<cfif trim(ip) is "127.0.0.1">
		<cfthrow message = "Local IP cannot be blacklisted" errorCode = "127001">
		<cfabort>
	</cfif>
	<cftry>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		insert into uam.blacklist (ip) values ('#trim(ip)#')
	</cfquery>
	<cflocation url="/Admin/blacklist.cfm">
	<cfcatch>
		<cfdump var=#cfcatch#>
	</cfcatch>
	</cftry>
</cfif>
<cfif action is "del">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from uam.blacklist where ip = '#ip#'
	</cfquery>
	<cflocation url="/Admin/blacklist.cfm">
</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">