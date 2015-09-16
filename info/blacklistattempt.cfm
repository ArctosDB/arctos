
<cfset inet_address = CreateObject("java", "java.net.InetAddress")>
<cfoutput>
	<cfparam name="rptprd" default=7>
	<cfparam name="mincount" default=20>
	<form name="f" method="post" action="blacklistattempt.cfm">
		<label for"rptprd">Number of Days</label>
		<input type="number" name="rptprd" id="rptprd" value="#rptprd#">
		<label for"rptprd">Minimum Attempts</label>
		<input type="number" name="mincount" id="mincount" value="#mincount#">
		<br><input type="submit" value="filter">
	</form>
	blacklisted_entry_attempt for the last #rptprd# days, containining only those subnets originating > #mincount# attempts
	<br>*ATCA=all-time connection attempts
	<br>*Last=subnet attempts last #rptprd# days
	<cfquery name="d" datasource="uam_god">
			SELECT
			regexp_replace(ip,'^([0-9]{1,3}\.[0-9]{1,3})\..*$','\1') subnet,
			count(*) attempts
		from
			blacklisted_entry_attempt
			where
			to_char(timestamp,'yyyy-mm-dd') >= sysdate-#rptprd#
		having
			count(*) > #mincount#
		group by
			regexp_replace(ip,'^([0-9]{1,3}\.[0-9]{1,3})\..*$','\1')
		 order by
		 	count(*) DESC
	</cfquery>

	<table border>
		<tr>
			<th>Subnet</th>
			<th>Last#rptprd#</th>
			<th>alltime</th>
			<th>IP</th>
			<th>ATCA</th>
			<th>Host</th>
			<th>Click</th>
		</tr>
		<cfloop query="d">
			<cfquery name="ips" datasource="uam_god">
				select
					ip,
					count(*) c
				from
					blacklisted_entry_attempt
				where
					ip like '#d.subnet#.%'
				group by
					ip
				order by
					count(*) DESC
			</cfquery>
			<cfloop query="#ips#">
				<cftry>
					<cfset host_name = inet_address.getByName("#ip#").getHostName()>
				<cfcatch>
					<cfset host_name='idk'>
				</cfcatch></cftry>
				<tr>
					<td>#d.subnet#</td>
					<td>#d.attempts#</td>
					<td>#ip#</td>
					<td>#c#</td>
					<td>#host_name#</td>
					<td><a href="http://whatismyipaddress.com/ip/#ip#">lookup</a></td>
				</tr>
			</cfloop>
		</cfloop>
	</table>
</cfoutput>