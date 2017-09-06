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
		$(document).ready(function() {
			$( "#resetfilter" ).click(function() {
			  document.location='blacklist.cfm';
			});
		});
	</script>
	<script src="/includes/sorttable.js"></script>
	<cfoutput>
		<hr>Filter
		<cfparam name="sincedays" default="180">
		<cfparam name="ipstartswith" default="">
		<cfset ipstartswith=trim(ipstartswith)>
		<cfif listlen(ipstartswith,".") gt 2>
			<cfset snstartswith=listgetat(ipstartswith,1,".") & "." & listgetat(ipstartswith,2,".")>
		<cfelse>
			<cfset snstartswith=ipstartswith>
		</cfif>
		<cfparam name="pg" default="1">
		<cfparam name="pgsize" default="100">
		<cfset startrow=(pg*pgsize)-pgsize>
		<cfset stoprow=startrow+pgsize>
		<form method="post" id="ff" action="blacklist.cfm">
			<label for="ipstartswith">IP (starts with)</label>
			<input type="text" name="ipstartswith" id="ipstartswith" value="#ipstartswith#">
			<label for="sincedays">Days to include*</label>
			<input type="number" name="sincedays" id="sincedays" value="#sincedays#">
			<label for="pg">page</label>
			<input type="number" name="pg" id="pg" value="#pg#" required>
			<label for="pagesize">page size</label>
			<input type="number" name="pgsize" id="pgsize" value="#pgsize#" required>
			<br><input type="submit" value="apply filter">
			<input type="button" id="resetfilter" value="reset">
		</form>
		<p>
			* All IP-based access restrictions expire after 180 days, and data older than 180 days is by default excluded from this form.
		</p>
		<cfquery name="rip" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			Select * from (
				Select a.*, rownum rnum From (
					select
						IP,
						to_char(LISTDATE,'yyyy-mm-dd') LISTDATE,
						STATUS,
						to_char(LASTDATE,'yyyy-mm-dd') LASTDATE,
						calc_subnet
					from
						uam.blacklist
					where
						sysdate-LISTDATE<#sincedays#
						<cfif len(ipstartswith) gt 0>
							and ip like '#snstartswith#%'
						</cfif>
						order by LISTDATE desc
					) a
					where rownum <= #stoprow#
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
				calc_subnet
			from rip
				group by
				calc_subnet
				order by LISTDATE desc
		</cfquery>
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
			malicious activity from a single IP. IPs containing "ip starts with" search string are <span class="highlight">highlighted</span>.
		</p>
		<p>
			IPs are generally auto-blacklisted. Users may remove IP restrictions from Arctos.
			Immediately contact Arctos personnel if unnecessary restrictions are being automatically added.
		</p>
		<p>
			Subnets are automatically blocked with 10 active IP blocks from the subnet. This controls
			the size of application variables, prevents "learning" attacks,
			and sends email alerting Arctos personnel to increased suspicious activity.
			Users may remove this restriction from Arctos.
		</p>
		<p>
			"Probably malicious" subnets should be hard-blocked using the tools below. These blocks cannot be
			removed by users, but users may fill in a form asking for removal; this must be evaluated by Arctos personnel. Create and release
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
			One non-released subnet block blocks the entire subnet; "released" are kept as a history but do nothing.
		</p>
		<p>
			All IPs from a blocked subnet are effectively blocked; releasing individual IPs from a blocked subnet does nothing.
		</p>
		<p>
			Individual IPs (from un-blocked subnets) behave as subnets; one non-released record prevents acceess, while all
			released records are maintained only as a history.
		</p>
		<p>
			IPs and subnets with a great deal of activity should receive extra scrutiny.
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
						#calc_subnet#
						<br>
						<a href="blacklist.cfm?ipstartswith=#calc_subnet#">Show only this subnet</a>
						<ul>
							<li><a href="blacklist.cfm?action=UNblockSubnet&subnet=#calc_subnet#">remove all subnet blocks</a></li>
							<li><a href="blacklist.cfm?action=blockSubnet&subnet=#calc_subnet#">hard-block the subnet</a></li>
						</ul>
					</td>
					<cfquery name="tsnd" dbtype="query">
						select * from sn where subnet='#calc_subnet#' order by status
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
							select ip from rip where calc_subnet='#calc_subnet#' group by ip order by ip
						</cfquery>
						<cfloop query="dip">
							<table border>
								<tr>
									<td valign="top">
										IP:
										<cfif len(ipstartswith) gt 0 and find(ipstartswith, ip)>
											<span class="highlight">#ip#</span>
										<cfelse>
											#ip#
										</cfif>
										<ul>
											<li><a href="blacklist.cfm?action=del&ip=#ip#">release IP</a></li>
											<li><a class="external" target="_blank" href="http://whatismyipaddress.com/ip/#ip#">[ @whatismyipaddress ]</a></li>
											<li><a class="external" target="_blank" href="https://www.ipalyzer.com/#ip#">[ @ipalyzer ]</a></li>
											<li><a class="external" target="_blank" href="https://gwhois.org/#ip#">[ @gwhois ]</a></li>
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
	<cflocation url="/Admin/blacklist.cfm?ipstartswith=#ip#" addtoken="false">
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
	<cfoutput>
		<cflocation url="/Admin/blacklist.cfm??ipstartswith=#subnet#" addtoken="false">
	</cfoutput>
</cfif>
<!------------------------------------------>
<cfif action is "del">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update uam.blacklist set status='released' where ip = '#ip#'
	</cfquery>
	<cflocation url="/Admin/blacklist.cfm" addtoken="false">
</cfif>

<cfinclude template="/includes/_footer.cfm">