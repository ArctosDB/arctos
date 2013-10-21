<cfscript>
		serverName = CreateObject("java", "java.net.InetAddress").getLocalHost().getHostName();
	</cfscript>
	<cfdump var=#servername#>
<!--- no security --->
<cfdump var="#variables#" label="variables">
<cfdump var=#session# label="session">
<cfdump var=#application# label="application">
<cfdump var=#cgi# label="cgi">

<cfdump var=#request# label="request">
