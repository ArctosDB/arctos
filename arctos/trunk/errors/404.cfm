<cfif not isdefined("toProperCase")>
	<cfinclude template="/includes/_header.cfm">
</cfif>
<cfoutput>
	<CFIF isdefined("CGI.HTTP_X_Forwarded_For") and len(CGI.HTTP_X_Forwarded_For) gt 0>
		<CFSET ipaddress=CGI.HTTP_X_Forwarded_For>
	<CFELSEif  isdefined("CGI.Remote_Addr") and len(CGI.Remote_Addr) gt 0>
		<CFSET ipaddress=CGI.Remote_Addr>
	<cfelse>
		<cfset ipaddress='unknown'>
	</CFIF>
	<cfset cTemp="">
	<cfset rdurl=replacenocase(cgi.query_string,"path=","","all")>
	<cfif len(rdurl) gt 0>
		<cfset cTemp=rdurl>
	<cfelseif len(cgi.script_name) gt 0>
		<cfset cTemp=cgi.script_name>
	</cfif>
	<cfquery name="redir" datasource="cf_dbuser">
		select new_path from redirect where upper(old_path)='/#ucase(cTemp)#'
	</cfquery>
	<cfif redir.recordcount is 1>
		<cfheader statuscode="301" statustext="Moved permanently">
		<cfif left(redir.new_path,4) is "http">
			<cfheader name="Location" value="#redir.new_path#">
		<cfelse>
			<cfheader name="Location" value="#application.serverRootURL##redir.new_path#">
		</cfif>
		<cfabort>
	</cfif>
	<cfset nono="wp-admin,wp,verify-tldnotify,jmx-console,admin-console,cgi-bin,webcalendar,webcal,calendar,plugins,passwd,mysql,htdocs,PHPADMIN,mysql2,mydbs,dbg,pma2,pma4,scripts,sqladm,mysql2,phpMyAdminLive,_phpMyAdminLive,dbadmin,sqladm,lib,webdav,manager,ehcp,MyAdmin,pma,phppgadmin,dbadmin,myadmin,awstats,version,phpldapadmin,horde,appConf,soapCaller,muieblackcat,@@version,w00tw00t,announce,php,cgi,ini,config,client,webmail,roundcubemail,roundcube,HovercardLauncher,README,cube,mail,board,zboard,phpMyAdmin">
	<cfset fourohthree="dll,asp,png,crossdomain">
	<cfloop list="#rdurl#" delimiters="./&" index="i">
		<cfif listfindnocase(nono,i)>
			<cfinclude template="/errors/autoblacklist.cfm">
			<cfabort>
		</cfif>
		<cfif listfindnocase(fourohthree,i)>
			<!--- allow this stuff, but not when it's a blatant probe! --->
			<cfif cgi.HTTP_REFERER contains '/App/DddWrapper.swf'>
				<cfinclude template="/errors/autoblacklist.cfm">
				<cfabort>
			</cfif>
			<cfthrow detail="You've requested a form which isn't available. This may be an indication of unwanted or malicious software on your computer." message="403: Forbidden" errorcode="403">
		</cfif>
	</cfloop>
	<!--- we don't have a redirect, and it's not on our hitlist, so 404 --->
	<cfheader statuscode="404" statustext="Not found">
	<cfset title="404: not found">
	<h2>
		404! The page you tried to access does not exist.
	</h2>
	<script type="text/javascript">
		var GOOG_FIXURL_LANG = 'en';
		var GOOG_FIXURL_SITE = 'http://arctos.database.museum/';
	</script>
	<script type="text/javascript" src="http://linkhelp.clients.google.com/tbproxy/lh/wm/fixurl.js"></script>
	<script type="text/javascript" language="javascript">
		function changeCollection () {
			jQuery.getJSON("/component/functions.cfc",
				{
					method : "changeexclusive_collection_id",
					tgt : '',
					returnformat : "json",
					queryformat : 'column'
				},
				function (d) {
		  			document.location='#rdurl#';
				}
			);
		}
	</script>
	<cfset isGuid=false>
	<cfif len(rdurl) gt 0 and rdurl contains "guid">
		<cfset isGuid=true>
		<cfif session.dbuser is not "pub_usr_all_all">
			<cfquery name="yourcollid" datasource="cf_dbuser">
				select collection from cf_collection where DBUSERNAME='#session.dbuser#'
			</cfquery>
			<p>
				<cfif len(session.roles) gt 0 and session.roles is not "public">
					If you are an operator, you may have to log out or ask your supervisor for more access.
				</cfif>
				You are accessing Arctos through the #yourcollid.collection# portal, and cannot access specimen data in
				other collections. You may
				<span class="likeLink" onclick="changeCollection()">try again in the public portal</span>.
			</p>
		</cfif>
	</cfif>

	<p>
		If you followed a link from within Arctos, please <a href="/info/bugs.cfm">submit a bug report</a>
	 	containing any information that might help us resolve this issue.
	</p>
	<p>
		If you followed an external link, please use your back button and tell the webmaster that
		something is broken, or <a href="/info/bugs.cfm">submit a bug report</a> telling us how you got this error.
	</p>

	<p><a href="/TaxonomySearch">Search for Taxon Names here</a></p>
	<p><a href="/SpecimenUsage">Search for Projects and Publications here</a></p>
	<p>
		If you're trying to find specimens, you may:
		<ul>
			<li><a href="/SpecimenSearch">Search for them</a></li>
			<li>Access them by URLs of the format:
				<ul>
					<li>
						#Application.serverRootUrl#/guid/{institution}:{collection}:{catnum}
						<br>Example: #Application.serverRootUrl#/guid/UAM:Mamm:1
						<br>&nbsp;
					</li>
				</ul>
			</li>
		</ul>
		Some specimens are restricted. You may <a href="/contact.cfm">contact us</a> for more information.
		<p>
			Occasionally, a specimen is recataloged. You may be able to find them by using Other Identifiers in Specimen Search.
		</p>
	</p>
	<cfif isGuid is false>
		<cfset sub="Dead Link">
		<cfset frm="dead.link">
	<cfelse>
		<cfset sub="Missing GUID">
		<cfset frm="dead.guid">
	</cfif>
	<cfif rdurl contains 'coldfusion.applets.CFGridApplet.class'>
		<cfset sub="stoopid safari">
		<cfset frm="stoopid.safari">
	</cfif>
	<cfmail subject="#sub#" to="#Application.PageProblemEmail#" from="#frm#@#application.fromEmail#" type="html">
		A user found a dead link! The referring site was #cgi.HTTP_REFERER#.
		<cfif isdefined("CGI.script_name")>
			<br>The missing page is #Replace(CGI.script_name, "/", "")#
		</cfif>
		<cfif isdefined("rdurl")>
			<br>rdurl: #rdurl#
		</cfif>
		<cfif isdefined("session.username")>
			<br>The username is #session.username#
		</cfif>
		<br>The IP requesting the dead link was <a href="http://network-tools.com/default.asp?prog=network&host=#ipaddress#">#ipaddress#</a>
		 - <a href="http://arctos.database.museum/Admin/blacklist.cfm?action=ins&ip=#ipaddress#">blacklist</a>
		<br>This message was generated by #cgi.CF_TEMPLATE_PATH#.
		<hr><cfdump var="#cgi#">
	</cfmail>
	 <p>A message has been sent to the site administrator.</p>
	 <p>
	 	Use the tabs in the header to continue navigating Arctos.
	 </p>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">