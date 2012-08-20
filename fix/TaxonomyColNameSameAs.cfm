<cfoutput>
<cfscript>
		serverName = CreateObject("java", "java.net.InetAddress").getLocalHost().getHostName();
	</cfscript>
	
	<cfdump var=#serverName#>
</cfoutput>