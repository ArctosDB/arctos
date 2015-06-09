<cfoutput>
<cfif isdefined("attributes.cause.message")>
	<cfset exception.message=replace(attributes.cause.message,'[Macromedia][Oracle JDBC Driver][Oracle]','','all')>
</cfif>
<cfif isdefined("attributes.message")>
	<cfset exception.message=attributes.message>
</cfif>
<cfif isdefined("attributes.sql")>
	<cfset exception.sql=attributes.sql>
</cfif>
<cfif isdefined("attributes.cause") and structKeyExists(attributes.cause,"tagcontext")>
<cftry>
	<cfset exception.line=attributes.cause.tagContext[1].line>
<cfcatch></cfcatch>
</cftry>
</cfif>
<!---- see if we can figure out why there's an error ---->
<!--- first, just see if it's being explicitly handed in ---->
<cfif isdefined("attributes.subject") and len(attributes.subject) gt 0>
	<cfset exception.subject=attributes.subject>
<cfelse>
	<cfset exception.subject='unknown error'>
</cfif>
<!---
	now see if we can figure out an appropriate logfile
	make sure all these are initiated in application start
----->
<cfset theLogFile="log.txt">
<cfif exception.subject is "404">
	<cfset theLogFile="404log.txt">
<cfelseif exception.subject is "missing GUID">
	<cfset theLogFile="missingGUIDlog.txt">
<cfelseif exception.subject is "autoblacklist">
	<cfset theLogFile="blacklistlog.txt">
</cfif>
<cfset exception.logfile=theLogFile>
<cfset exception.date='#dateformat(now(),"yyyy-mm-dd")#T#TimeFormat(now(), "HH:mm:ss")#'>
<cfif isdefined("form")>
	<cfloop item="key" collection="#form#">
		<cfif len(form[key]) gt 0>
			<cfset "exception.#key#"="#form[key]#">
		</cfif>
	</cfloop>
</cfif>
<cfif isdefined("request")>
	<cfloop item="key" collection="#request#">
		<cfif len(request[key]) gt 0>
			<cfset "exception.#key#"="#request[key]#">
		</cfif>
	</cfloop>
</cfif>
<cfif isdefined("cgi")>
	<cfloop item="key" collection="#cgi#">
		<cfif len(cgi[key]) gt 0>
			<cfset "exception.#key#"="#cgi[key]#">
		</cfif>
	</cfloop>
</cfif>
<CFTRY>
<cfif isdefined("URL")>
	<cfloop item="key" collection="#URL#">
		<cfif len(URL[key]) gt 0>
			<cfset "exception.#key#"="#URL[key]#">
		</cfif>
	</cfloop>
</cfif>
<CFCATCH></CFCATCH>
</CFTRY>
<cfif isdefined("session")>
	<cfloop item="key" collection="#session#">
		<cfif len(session[key]) gt 0>
			<cfset "exception.#key#"="#session[key]#">
		</cfif>
	</cfloop>
</cfif>
<cfsavecontent variable="rawexc">
	<cf_dumptoxml v=attributes>
</cfsavecontent>
<cfset exception.rawExceptionDump=rawexc>
<!--- clean up the stuff we don't really care about --->
<cfif structkeyexists(exception,"HTTPS")>
	<cfset StructDelete(exception, "HTTPS")>
</cfif>
<cfif structkeyexists(exception,"header_color")>
	<cfset StructDelete(exception, "header_color")>
</cfif>
<cfif structkeyexists(exception,"header_image")>
	<cfset StructDelete(exception, "header_image")>
</cfif>
<cfif structkeyexists(exception,"institution_url")>
	<cfset StructDelete(exception, "institution_url")>
</cfif>
<cfif structkeyexists(exception,"mediasrchtab")>
	<cfset StructDelete(exception, "mediasrchtab")>
</cfif>
<cfif structkeyexists(exception,"meta_description")>
	<cfset StructDelete(exception, "meta_description")>
</cfif>
<cfif structkeyexists(exception,"meta_keywords")>
	<cfset StructDelete(exception, "meta_keywords")>
</cfif>
<cfif structkeyexists(exception,"sessionid")>
	<cfset StructDelete(exception, "sessionid")>
</cfif>
<cfif structkeyexists(exception,"sessionkey")>
	<cfset StructDelete(exception, "sessionkey")>
</cfif>
<cfif structkeyexists(exception,"specsrchtab")>
	<cfset StructDelete(exception, "sesspecsrchtabsionkey")>
</cfif>
<cfif structkeyexists(exception,"taxsrchtab")>
	<cfset StructDelete(exception, "taxsrchtab")>
</cfif>
<cfif structkeyexists(exception,"SERVER_NAME")>
	<cfset StructDelete(exception, "SERVER_NAME")>
</cfif>
<cfif structkeyexists(exception,"SERVER_PORT")>
	<cfset StructDelete(exception, "SERVER_PORT")>
</cfif>
<cfif structkeyexists(exception,"SERVER_PORT_SECURE")>
	<cfset StructDelete(exception, "SERVER_PORT_SECURE")>
</cfif>
<cfif structkeyexists(exception,"SERVER_PROTOCOL")>
	<cfset StructDelete(exception, "SERVER_PROTOCOL")>
</cfif>
<cfif structkeyexists(exception,"downloadfilename")>
	<cfset StructDelete(exception, "downloadfilename")>
</cfif>
<cfif structkeyexists(exception,"epw")>
	<cfset StructDelete(exception, "epw")>
</cfif>
<cfif structkeyexists(exception,"flattablename")>
	<cfset StructDelete(exception, "flattablename")>
</cfif>
<cfif structkeyexists(exception,"getjulianday")>
	<cfset StructDelete(exception, "getjulianday")>
</cfif>
<cfif structkeyexists(exception,"urltoken")>
	<cfset StructDelete(exception, "urltoken")>
</cfif>
<cfif structkeyexists(exception,"institution_link_text")>
	<cfset StructDelete(exception, "institution_link_text")>
</cfif>
<cfif structkeyexists(exception,"collection_link_text")>
	<cfset StructDelete(exception, "collection_link_text")>
</cfif>
<cfif structkeyexists(exception,"collection_url")>
	<cfset StructDelete(exception, "collection_url")>
</cfif>
<cfif structkeyexists(exception,"specsrchtab")>
	<cfset StructDelete(exception, "specsrchtab")>
</cfif>

<cfset logdata="<logEntry>">
<cfloop item="key" collection="#exception#">
	<cfset logdata=logdata & "<#key#>#replace(replace(exception[key],'=','[EQUALS]','all'),'&','[AND]','all')#</#key#>">
</cfloop>
<cfset logdata=logdata & "</logEntry>">
<cftry>
	<cfhttp url="http://api.hostip.info/get_html.php?ip=#exception.ipaddress#" timeout="5"></cfhttp>
	<cfset ipinfo=cfhttp.fileContent>
<cfcatch><cfset ipinfo='ip info lookup failed'></cfcatch>
</cftry>



<cffile action="append" file="#Application.webDirectory#/log/#theLogFile#" output="#logdata#">
<cfmail subject="#exception.subject#" to="#Application.LogEmail#" from="logs@#application.fromEmail#" type="html">
	<br>
	ipinfo:#ipinfo#
	<br>
	<a href="http://whatismyipaddress.com/ip/#exception.ipaddress#">[ lookup #exception.ipaddress# ]</a>
	<br><a href="http://arctos.database.museum/Admin/blacklist.cfm?action=ins&ip=#exception.ipaddress#">[ blacklist #exception.ipaddress# ]</a>

	<cfif isdefined("exception.requestingsubnet") and len(exception.requestingsubnet) gt 0>
		<p>
			Nuke it from orbit option: Click this to blacklist an entire subnet. Use with caution.
			<a href="http://arctos.database.museum/Admin/blacklist.cfm?action=blockSubnet&subnet=#exception.requestingsubnet#">[ blacklist SUBNET #exception.requestingsubnet# ]</a>
		</p>
	<cfelse>
		nope requestingsubnet
	</cfif>



	<cfif structKeyExists(exception,"username")>
		<br>username: #exception.username#
	</cfif>
	<cfif structKeyExists(exception,"rdurl")>
		<br>rdurl: #exception.rdurl#
	</cfif>
	<cfif structKeyExists(exception,"ACTION")>
		<br>ACTION: #exception.ACTION#
	</cfif>
	<cfif structKeyExists(exception,"SQL")>
		<br>SQL: #exception.SQL#
	</cfif>
	<cfif structKeyExists(exception,"LINE")>
		<br>LINE: #exception.LINE#
	</cfif>
	<cfif structKeyExists(exception,"HTTP_REFERER")>
		<br>HTTP_REFERER: #exception.HTTP_REFERER#
	</cfif>
	<cfif structKeyExists(exception,"SUBJECT")>
		<br>SUBJECT: #exception.SUBJECT#
	</cfif>
	<cfif structKeyExists(exception,"MESSAGE")>
		<br>MESSAGE: #exception.MESSAGE#
	</cfif>
	<p>
		This message has been logged in #exception.logfile# as #exception.uuid#
	</p>
	<p>Raw exception dump:</p>
	<cfdump var=#exception# format="html">
	<cfdump var=#attributes# format="html">
</cfmail>
</cfoutput>