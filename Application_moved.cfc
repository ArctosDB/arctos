<cfcomponent>
	<cfset This.name = "Arctos">
	<cfset This.SessionManagement="True">
	<cfset This.ClientManagement="true">
	<cfset This.ClientStorage="Cookie">
	<cffunction name="OnRequestStart" access="public" returntype="boolean" output="true">
		<cfheader statuscode="503" statustext="Service Temporarily Unavailable">
		<cfhtmlhead text="<title>Arctos has moved to Texas, ya'll!</title>">
		<cfset cTemp="">
		<cfif len(cgi.redirect_url) gt 0>
			<cfset cTemp=cgi.redirect_url>
		<cfelseif len(cgi.script_name) gt 0>
			<cfset cTemp=cgi.script_name>
		</cfif>
		<cfoutput>
			<div style="border:3px solid red; margin:3em;padding:3em;font-weight:bold;font-size:x-large;text-align:center;">
				We've moved, but the DNS servers haven't caught up yet.
				<p>
					You can find us at our top-secret headquarters, <a href="http://129.114.52.171">http://129.114.52.171</a>. 
				</p>
				<p>
					http://arctos.database.museum should be back to normal within 72h.
				</p>
				<p>
					Continue to <a href="http://129.114.52.171#cTemp#">http://129.114.52.171#cTemp#</a>
				</p>
			</div>
		</cfoutput>
		<cfreturn false>
	</cffunction>
</cfcomponent>