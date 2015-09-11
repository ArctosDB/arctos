<cfset rptprd=7>
<cfset mincount=20>
<cfset inet_address = CreateObject("java", "java.net.InetAddress")>
<cfoutput>
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
		 	count(*)
	</cfquery>
	blacklisted_entry_attempt for the last #rptprd# days, containining only those subnets originating > #mincount# attempts
	<cfloop query="d">
		<p>
			<br>Subnet: #subnet# (attempts: #attempts#)
			<cfquery name="ips" datasource="uam_god">
				select ip, count(*) c from blacklisted_entry_attempt where ip like '#subnet#.%' group by ip order by count(*)
			</cfquery>
			<br>IPs
			<blockquote>
				<cfloop query="#ips#">
					<cfset host_name = inet_address.getByName("#ip#").getHostName()>
					<br><span>#ip#</span> @#c# (#host_name#) <a href="http://whatismyipaddress.com/ip/#ip#">lookup</a>
				</cfloop>
			</blockquote>
		</p>
	</cfloop>
</cfoutput>