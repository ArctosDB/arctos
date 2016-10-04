<cfset title="Manage IP and subnet blocking">
<cfinclude template="/includes/_header.cfm">

<cfif action is "nothing">
	<script src="/includes/sorttable.js"></script>
	<p>
		This form shows only activity in the last 180 days.
	</p>
	<cfoutput>
	<cfquery name="rip" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			*
		from
			uam.blacklist
		where
			sysdate-LISTDATE<180
	</cfquery>
	<cfquery name="sn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			subnet
		from
			uam.blacklist_subnet
		where
			sysdate-INSERT_DATE<180
	</cfquery>

	<cfset utilities = CreateObject("component","component.utilities")>
	<cfset utilities.setAppBL()>


	<cfquery name="d" dbtype="query">
		select ip from rip group by ip
	</cfquery>

	<form name="i" method="post" action="blacklist.cfm">
		<input type="hidden" name="action" value="ins">
		<label for="ip">Add IP</label>
		<input type="text" name="ip" id="ip">
		<br><input type="submit" value="blacklist">
	</form>

	<table border id="t" class="sortable">
		<tr>
			<th>IP</th>
			<th>TimesListed</th>
			<!----
			<th>listdate</th>
			<th>tools</th>
			---->
		</tr>
		<cfloop query="d">
			<tr>
				<td>#d.ip#</td>
				<cfquery name="tl" dbtype="query">
					select * from rip where ip='#d.ip#'
				</cfquery>
				<td>
					<cfdump var=#tl#>
				</td>
				<!----
				<td>#listdate#</td>
				<td>
					<a href="blacklist.cfm?action=del&ip=#ip#">Remove</a>
					<a href="http://whois.domaintools.com/#ip#" target="_blank">whois</a>
				</td>
				---->
			</tr>
		</cfloop>
	</table>
	</cfoutput>
</cfif>









<!----
	Release blocks after a period of time.
	Just ignore everything that's timed out

	THIS IS ALSO HARD_CODED IN Application.cfc



	July 2016 edits:

	see DDL/migration/xxxblacklist.sql
---->
<cfset expiresIn="180">

<cfoutput>
<cfif action is "subnet">
	<script>
		function getHostInfo(ip){
			jQuery.getJSON("/component/DSFunctions.cfc",
				{
					method : "getHostInfo",
					ip : ip,
					returnformat : "json",
					queryformat : 'column'
				},
				function (result) {
					var idstr="c_" + ip;
					$("td[id='" + idstr + "']").html(result);
				}
			);
		}
	</script>
	<script src="/includes/sorttable.js"></script>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			subnet
		from
			uam.blacklist_subnet
		where
			sysdate-INSERT_DATE<#expiresIn#
	</cfquery>
	<a href="blacklist.cfm">blacklist home</a>
	<h2>Currently Blocked Subnets</h2>
	<table border id="t2" class="sortable">
		<tr>
			<th>Subnet</th>
			<th>Whois</th>
			<th>Remove from Blacklist</th>
		</tr>
	<cfloop query="d">
		<tr>
			<td>#subnet#</td>
			<td><a href="http://whois.domaintools.com/#subnet#.1.1" target="_blank">whois</a></td>
			<td><a href="blacklist.cfm?action=UNblockSubnet&subnet=#subnet#">[ allow this subnet ]</a></td>
		</tr>
	</cfloop>

	</table>
	<h2>
		Unblocked subnets with >2 blocked IPs
	</h2>
	<p>
		Use this with great care. Blocked subnets here should be mirrored in firewall rules, which will require an email to the network folks.
		Blocking subnets at the CF level still imposes load on the server.
	</p>
	<p>
		General Guidelines
		<ul>
			<li>
				"Your IP/subnet has been blocked" messages require CF processing. Some subnets regularly fire thousands of these queries
				simultaneously, causing uptime and performance issues for legitimate users. "Flood probes" should be blocked at the firewall.
			 </li>
			 <li>
			 	Some foreign subnets (particularly originating from Eastern Europe) are the origin of continuous probes and no
			 	obvious legitimate traffic. These can mask dangerous activity and make keeping up with logfiles burdensome. Consider
			 	blocking these subnets when all other approaches have failed.
			 </li>
			 <li>
			 	US-based subnets should rarely be blocked, except in the case of fatally-aggressive bot traffic or spam injection attempts from
			 	multiple IPs. Use with great caution.
			 </li>
		</ul>
	</p>
	<p>
		Everything redirects to the IP list page so that application variables can be properly set. Sorry about the extra click.
	</p>

	<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			ip,
			substr(ip,1,instr(ip,'.',1,2)-1) subnet,
			to_char(listdate,'YYYY-MM-DD') listdate
		from
			uam.blacklist
		where
			sysdate-LISTDATE<#expiresIn# and
			substr(ip,1,instr(ip,'.',1,2)-1) not in (
				select subnet from blacklist_subnet where sysdate-INSERT_DATE<#expiresIn#
			)
	</cfquery>
	<cfquery name="sn" dbtype="query">
		select subnet from q group by subnet order by subnet
	</cfquery>
	<table border id="t" class="sortable">
		<tr>
			<th>Subnet</th>
			<th>NumberDistIPs</th>
			<th>firstblock</th>
			<th>lastblock</th>
			<th>whois</th>
			<th>hostname</th>
			<th>block subnet</th>
		</tr>
		<cfloop query="sn">
			<cfquery name="sndata" dbtype="query">
				select
					count(*) c,
					min(listdate) firstblock,
					max(listdate) lastblock
				from
					q
				where
					subnet='#subnet#'
			</cfquery>
			<cfif sndata.c gt 2>
				<tr>
					<td>#subnet#</td>
					<td>#sndata.c#</td>
					<td>#sndata.firstblock#</td>
					<td>#sndata.lastblock#</td>
					<td><a href="http://whois.domaintools.com/#subnet#.1.1" target="_blank">[ whois ]</a></td>
					<td id="c_#subnet#.1.1"><span class="likeLink" onclick="getHostInfo('#subnet#.1.1');">getHostInfo</span></td>
					<td><a href="blacklist.cfm?action=blockSubnet&subnet=#subnet#">[ block this subnet ]</a></td>
				</tr>
			</cfif>
		</cfloop>
	</table>
</cfif>
<!------------------------------------------>
<cfif action is "UNblockSubnet">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from blacklist_subnet where subnet='#subnet#'
	</cfquery>

	Subnet #subnet# has been removed from the blacklist. You must send email to the network folks to remove and firewall blacklists.

	<p>
		You must now <a href="/Admin/blacklist.cfm">continue to the main blacklist page</a> to push the changes to the application.
	</p>
</cfif>
<!------------------------------------------>
<cfif action is "blockSubnet">
	<cfif trim(subnet) is "127.0">
		<cfthrow message = "Local subnet cannot be blacklisted" errorCode = "127001">
		<cfabort>
	</cfif>
	<cftry>
		<!--- see if it's expired; if it is, just re-up ---->
		<cfquery name="exists" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from blacklist_subnet where subnet in ('#subnet#')
		</cfquery>
		<cfif len(exists.SUBNET) gt 0>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update blacklist_subnet set INSERT_DATE=sysdate where subnet in ('#subnet#')
			</cfquery>
			Subnet #subnet# has been <strong>RE</strong>added to the blacklist. You should definitely send email to the network folks and also
		blacklist it at the firewall.
		<cfelse>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into blacklist_subnet (subnet) values ('#subnet#')
			</cfquery>
			Subnet #subnet# has been added to the blacklist. You should probably send email to the network folks and also
			blacklist it at the firewall.
		</cfif>
	<p>
		You must <a href="/Admin/blacklist.cfm">continue to the main blacklist page</a> to push the changes to the application.
	</p>
	<cfcatch>
		<cfdump var=#cfcatch#>
	</cfcatch>
	</cftry>
</cfif>
<!------------------------------------------>
<cfif action is "old_nothing">
	<script src="/includes/sorttable.js"></script>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			ip,LISTDATE
		from
			uam.blacklist
		where
			sysdate-LISTDATE<#expiresIn# and
			substr(ip,1,instr(ip,'.',1,2)-1) not in (
			-- ignore IPs in currently-blocked subnets
				select subnet from blacklist_subnet where sysdate-INSERT_DATE<#expiresIn#
			)
	</cfquery>
	<cfquery name="sn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			subnet
		from
			uam.blacklist_subnet
		where
			sysdate-INSERT_DATE<#expiresIn#
	</cfquery>
	<p>
		IMPORTANT NOTE: IPs for blocked subnets are NOT included here. <a href="blacklist.cfm?action=subnet">manage blocked subnets</a>
	</p>
	<p>
		Found #d.recordcount# blocked IPs
	</p>

	<cfset application.blacklist=valuelist(d.ip)>
	<cfset application.subnet_blacklist=valuelist(sn.subnet)>

	<form name="i" method="post" action="blacklist.cfm">
		<input type="hidden" name="action" value="ins">
		<label for="ip">Add IP</label>
		<input type="text" name="ip" id="ip">
		<br><input type="submit" value="blacklist">
	</form>

	<table border id="t" class="sortable">
		<tr>
			<th>IP</th>
			<th>listdate</th>
			<th>tools</th>
		</tr>
		<cfloop query="d">
			<tr>
				<td>#ip#</td>
				<td>#listdate#</td>
				<td>
					<a href="blacklist.cfm?action=del&ip=#ip#">Remove</a>
					<a href="http://whois.domaintools.com/#ip#" target="_blank">whois</a>
				</td>
			</tr>
		</cfloop>
	</table>
</cfif>
<!------------------------------------------>
<cfif action is "ins">
	<cfquery name="protected_ip_list" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select protected_ip_list from cf_global_settings
	</cfquery>
	<cfif listfind(protected_ip_list.protected_ip_list,trim(request.ipaddress))>
		<cfset ee="
			cgi.HTTP_X_Forwarded_For: #cgi.HTTP_X_Forwarded_For#
			<br>cgi.Remote_Addr: #cgi.Remote_Addr#
			<br>request.ipaddress: #request.ipaddress#
			<br>request.requestingSubnet: #request.requestingSubnet#
		">
		<cfthrow message = "protected IP cannot be blacklisted" errorCode = "127001" extendedInfo="#ee#">
		<cfabort>
	</cfif>
	<cftry>

		<!--- see if it's expired; if it is, just re-up ---->
		<cfquery name="exists" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from uam.blacklist where ip in  ('#trim(ip)#')
		</cfquery>
		<cfif len(exists.IP) gt 0>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update uam.blacklist set LISTDATE=sysdate where IP in ('#trim(ip)#')
			</cfquery>
			Reupped the blacklist for #ip#; <strong>repeat offender alert</strong>
		<cfelse>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into uam.blacklist (ip) values ('#trim(ip)#')
			</cfquery>
			Added #ip#
		</cfif>
		<cflocation url="/Admin/blacklist.cfm" addtoken="false">
		<cfcatch>
			<cfdump var=#cfcatch#>
		</cfcatch>
	</cftry>
</cfif>
<!------------------------------------------>
<cfif action is "del">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from uam.blacklist where ip = '#ip#'
	</cfquery>
	<cflocation url="/Admin/blacklist.cfm" addtoken="false">
</cfif>
</cfoutput>


<cfinclude template="/includes/_footer.cfm">