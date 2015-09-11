-- since the last time we blocked the most idiotic of the idiots, which IP subnets have been most troublesome?
<cfset rptprd=7>
<cfset mincount=20>


<cfset inet_address = CreateObject("java", "java.net.InetAddress")>
<cfset host_name = inet_address.getByName("66.249.66.99").getHostName()>
<cfoutput>#host_name#</cfoutput>




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
	<cfdump var=#d#>

	<cfloop query="d">
		blacklisted_entry_attempt for the last #rptprd# days, containining only those subnets originating
		> #mincount# attempts
		<p>
			<br>Subnet: #subnet# (attempts: #attempts#)
			<cfquery name="ips" datasource="uam_god">
				select distinct ip from blacklisted_entry_attempt where ip like '#subnet#.%' order by ip
			</cfquery>

	<cfdump var=#ips#>
			<br>IPs
			<blockquote>
				<cfloop query="#ips#">
					<br>#ip#
				</cfloop>
			</blockquote>
		</p>



	</cfloop>
</cfoutput>