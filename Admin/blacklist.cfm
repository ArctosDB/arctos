<cfset title="Manage IP and subnet blocking">
<cfinclude template="/includes/_header.cfm">

<cfif action is "nothing">
	<script>
		function nextPage(){
			$("#pg").val(parseInt($("#pg").val())+1);
			$("#ff").submit();
			}
			function prevPage(){
			$("#pg").val(parseInt($("#pg").val())-1);
			$("#ff").submit();
			}
	</script>


	<script src="/includes/sorttable.js"></script>
	<cfoutput>
	<hr>Filter
	<cfparam name="sincedays" default="180">
	<cfparam name="ipstartswith" default="">
	<cfparam name="pg" default="1">
	<cfparam name="pgsize" default="100">

	<cfset startrow=(pg*pgsize)-pgsize>

	<p>
		startrow: #startrow#
	</p>


	<cfset stoprow=startrow+pgsize>

	<p>
		stoprow: #stoprow#
	</p>
	<form method="post" id="ff" action="blacklist.cfm">
		<label for="sincedays">Days to include</label>
		<input type="number" name="sincedays" id="sincedays" value="#sincedays#">

		<label for="ipstartswith">IP (starts with)</label>
		<input type="text" name="ipstartswith" id="ipstartswith" value="#ipstartswith#">


		<label for="pg">page</label>
		<input type="number" name="pg" id="pg" value="#pg#" required>
		<label for="pagesize">page size</label>
		<input type="number" name="pgsize" id="pgsize" value="#pgsize#" required>
		<br><input type="submit" value="apply filter">
	</form>

	<p>
		All IP-based access restrictions expire after 180 days, and data older than 180 days is by default excluded from this form.
	</p>

	<!----
	<cfquery name="rip" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			IP,
			to_char(LISTDATE,'yyyy-mm-dd') LISTDATE,
			STATUS,
			to_char(LASTDATE,'yyyy-mm-dd') LASTDATE,
			substr(ip,1,instr(ip,'.',1,2)-1) subnet
		from
			uam.blacklist
		where
			sysdate-LISTDATE<#sincedays#
	</cfquery>
	---------->
	<cfquery name="rip" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		Select * from (
						Select a.*, rownum rnum From (
						select
			IP,
			to_char(LISTDATE,'yyyy-mm-dd') LISTDATE,
			STATUS,
			to_char(LASTDATE,'yyyy-mm-dd') LASTDATE,
			substr(ip,1,instr(ip,'.',1,2)-1) subnet
		from
			uam.blacklist
		where
			sysdate-LISTDATE<#sincedays#
			order by LISTDATE desc) a where rownum <= #stoprow#
					) where rnum >= #startrow#
	</cfquery>

	<!--- get subnet blocks relevant to whatever was returned by the IP query ---->
	<cfquery name="sn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			SUBNET,
			STATUS,
			to_char(INSERT_DATE,'yyyy-mm-dd') INSERT_DATE,
			to_char(LASTDATE,'yyyy-mm-dd') LASTDATE
		from
			uam.blacklist_subnet
		where
			sysdate-INSERT_DATE<#sincedays#
	</cfquery>
	<cfset utilities = CreateObject("component","component.utilities")>
	<cfset utilities.setAppBL()>
	<cfquery name="subnetfromip" dbtype="query">
		select
			subnet,LISTDATE
		from rip
			group by
			subnet
			order by LISTDATE desc
	</cfquery>

	<cfdump var=#subnetfromip#>
	<hr>
	<form name="i" method="post" action="blacklist.cfm">
		<input type="hidden" name="action" value="ins">
		<label for="ip">Manually block IP</label>
		<input type="text" name="ip" id="ip">
		<br><input type="submit" value="blacklist">
	</form>
	<hr>
	<p>
		Use the form above (and update the filters or contact someone who can) to stop
		malicious activity from a single IP.
	</p>
	<p>
		IPs are generally auto-blacklisted. Users may remove IP restrictions from Arctos.
	</p>
	<p>
		Subnets are automatically blocked with 10 active IP blocks from the subnet. This controls
		the size of application variables, prevents "learning" attacks,
		and sends email alerting Arctos personnel to increased suspicious activity.
		Users may remove this restriction from Arctos.
	</p>
	<p>
		"Fairly malicious" subnets should be hard-blocked using the tools below. These blocks cannot be
		removed by users. Users may fill in a form asking for removal; this must be evaluated by Arctos personnel. Create and release
		these restrictions with caution.
	</p>
	<p>
		More-malicious subnets should be blocked at the firewall. Send email to TACC. Users from
		firewall-blocked subnets cannot see Arctos at all. Use with extreme caution.
	</p>
	<p>
		Please carefully examine the relevant logs and consult with Arctos personnel before doing anything with this form.
	</p>
	<p>
		Immediately contact Arctos personnel if unnecessary restrictions are being automatically added.
	</p>

	<span class="likeLink" onclick="prevPage()">Previous Page</span>
	<span class="likeLink" onclick="nextPage()">Next Page</span>
	<table border id="t" class="sortable">
		<tr>
			<th>Subnet/Tools</th>
			<th>SubnetBlocks</th>
			<th>IPInfo</th>
		</tr>
		<cfloop query="subnetfromip">
			<tr>
				<td valign="top">
					#subnet#
					<ul>
						<li><a href="blacklist.cfm?action=UNblockSubnet&subnet=#subnet#">remove all subnet blocks</a></li>
						<li><a href="blacklist.cfm?action=blockSubnet&subnet=#subnet#">hard-block the subnet</a></li>
					</ul>
				</td>
				<cfquery name="tsnd" dbtype="query">
					select * from sn where subnet='#subnet#'
				</cfquery>
				<td valign="top">
					<cfif tsnd.recordcount is 0>
						no subnet blocks
					<cfelse>
						<table border>
							<tr>
								<th>subnet-listdate</th>
								<th>lastdate</th>
								<th>status</th>
							</tr>
							<cfloop query="#tsnd#">
								<tr>
									<td>#INSERT_DATE#</td>
									<td>#LASTDATE#</td>
									<td>#STATUS#</td>
								</tr>
							</cfloop>
						</table>
					</cfif>
				</td>
				<td valign="top">
					<cfquery name="dip" dbtype="query">
						select ip from rip where subnet='#subnet#' group by ip order by ip
					</cfquery>
					<cfloop query="dip">
						<table border>
							<tr>
								<td valign="top">
									IP: #ip#
										<ul>
											<li><a href="blacklist.cfm?action=del&ip=#ip#">release IP</a></li>
											<li><a class="external" target="_blank" href="http://whatismyipaddress.com/ip/#ip#">[ lookup @whatismyipaddress ]</a></li>
											<li><a class="external" target="_blank" href="https://www.ipalyzer.com/#ip#">[ lookup @ipalyzer ]</a></li>
											<li><a class="external" target="_blank" href="https://gwhois.org/#ip#">[ lookup @gwhois ]</a></li>
										</ul>
								</td>
								<td>
									<cfquery name="tl" dbtype="query">
										select * from rip where ip='#ip#' order by listdate
									</cfquery>
									<table border>
										<tr>
											<th>listdate</th>
											<th>lastdate</th>
											<th>status</th>
										</tr>
										<cfloop query="#tl#">
											<tr>
												<td>#LISTDATE#</td>
												<td>#LASTDATE#</td>
												<td>#STATUS#</td>
											</tr>
										</cfloop>
									</table>
								</td>
							</tr>
						</table>
					</cfloop>
				</td>
			</tr>
		</cfloop>
	</table>



	</cfoutput>
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
	<cfquery name="d" datasource="uam_god">
		insert into uam.blacklist (
			ip,
			LISTDATE,
			STATUS,
			LASTDATE
		) values (
			'#ip#',
			sysdate,
			'active',
			sysdate
			)
	</cfquery>
	<cflocation url="/Admin/blacklist.cfm" addtoken="false">
</cfif>
<!------------------------------------------>
<cfif action is "UNblockSubnet">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update blacklist_subnet set status='released' where subnet='#subnet#'
	</cfquery>
	<cflocation url="/Admin/blacklist.cfm" addtoken="false">
</cfif>
<!------------------------------------------>
<cfif action is "blockSubnet">
	<cfif trim(subnet) is "127.0">
		<cfthrow message = "Local subnet cannot be blacklisted" errorCode = "127001">
		<cfabort>
	</cfif>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		insert into blacklist_subnet (subnet,INSERT_DATE,STATUS,LASTDATE) values ('#subnet#',sysdate,'hardblock',sysdate)
	</cfquery>
	<cflocation url="/Admin/blacklist.cfm" addtoken="false">
</cfif>
<!------------------------------------------>
<cfif action is "del">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update uam.blacklist set status='released' where ip = '#ip#'
	</cfquery>
	<cflocation url="/Admin/blacklist.cfm" addtoken="false">
</cfif>
<!------------------


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
------------->
<cfinclude template="/includes/_footer.cfm">