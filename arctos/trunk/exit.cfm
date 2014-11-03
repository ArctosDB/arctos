<cfinclude template="includes/_header.cfm">
<cfset title="You are now leaving Arctos.">
<cfoutput>
	<cfif not isdefined("target") or len(target) is 0>
		Improper call of this form.	
		<cfthrow detail="exit called without target" errorcode="9944" message="A call to the exit form was made without specifying a target.">
		<cfabort>
	</cfif>
	<cfif left(target,4) is not "http">
		<!--- hopefully a local resource and not some garbage ---->
		<cfif left(target,1) is "/">
			<cfset http_target=application.serverRootURL & target>
		<cfelse>
			<cfset http_target=application.serverRootURL & '/' & target>
		</cfif>
	<cfelse>
		<cfset http_target=target>
	</cfif>
	<cfif target contains "inurl:/content/">
		<cflocation url="/errors/autoblacklist.cfm">
	</cfif>
	<cfhttp url="#http_target#" method="head" timeout="3"></cfhttp>
	<cfif isdefined("cfhttp.statuscode") and cfhttp.statuscode is "200 OK">
		<cfset status="200">
	<cfelse>
		<cfset isGoodLink=false>
		<cfif isdefined("cfhttp.statuscode")>
			<cfset status=cfhttp.statuscode>
		<cfelse>
			<cfset status='n/a'>
		</cfif>
	</cfif>
	<cfquery name="exit"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		insert into exit_link (
			username,
			ipaddress,
			from_page,
			target,
			http_target,
			when_date,
			status
		) values (
			'#session.username#',
			'#request.ipaddress#',
			'#cgi.HTTP_REFERER#',
			'#target#',
			'#http_target#',
			sysdate,
			'#status#'
		)
	</cfquery>
 	<cfif status is "200">
		<cfheader statuscode="303" statustext="Redirecting to external resource">
		<cfheader name="Location" value="#http_target#">	
	<cfelse>
		<cftry><cfhtmlhead text='<title>An external resource is not responding properly</title>'>
			<cfcatch type="template">
			</cfcatch>
		</cftry>
		<div style="border:4px solid red; padding:1em;margin:1em;">
			There may be a problem with the linked resource. 
			<p>
				Status: #status#
			</p>
			<cfif left(status,3) is "408">
				<p>The server hosting the link may be slow or nonresponsive.</p>
			<cfelseif  left(status,3) is "404">
				<p>The external resource does not appear to exist.</p>
			<cfelseif left(status,3) is "500">
				<p>The server may be down or misconfigured.</p>			
			</cfif>
			<p>
				Click the following link(s) to attempt to load the resource manually. 
			</p>
			<p>
				Please <a href="/contact.cfm?ref=#target#">contact us</a> if you experience additional problems with the link.
			</p>
			<p>Link as provided: <a href="#target#">#target#</a></p>
				<cfif http_target is not target>
					<br>Or our guess at the intended link: <a href="#http_target#">#http_target#</a>
				</cfif>
		</div>
	</cfif>
</cfoutput>
<cfinclude template="includes/_footer.cfm">