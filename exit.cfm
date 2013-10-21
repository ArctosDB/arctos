<cfinclude template="includes/_header.cfm">
<cfset title="You are now leaving Arctos.">

<div id="splash">

</div>
<script>
jQuery(document).ready(function() {
	$("#splash").html('i am javasript bla bla lba......');	
});
</script>
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
	<cfhttp url="#http_target#" method="head"></cfhttp>
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
		<div style="border:4px solid red; padding:1em;margin:1em;">
			There may be a problem with the external resource.
			<p>
				Status: #status#
			</p>
			<p>
				You can try the exit link specified: <a href="#target#" target="_blank">#target#</a>
				<cfif http_target is not target>
					<br>Or our guess at the intended target: <a href="#http_target#" target="_blank">#http_target#</a>
				</cfif>
			</p>
		</div>
		<script>
		$("#splash").html('all finished showing page bla bla....');
		</script>		
				

	</cfif>
</cfoutput>
<cfinclude template="includes/_footer.cfm">