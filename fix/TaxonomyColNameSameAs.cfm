<cfoutput>
<cfscript>
		serverName = CreateObject("java", "java.net.InetAddress").getLocalHost().getHostName();
	</cfscript>
	<hr>
	<cfdump var=#serverName#>
	<hr>
</cfoutput>