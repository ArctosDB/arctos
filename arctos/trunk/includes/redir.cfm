<cfoutput>
Please wait while we build your request...<cfflush>
<cfif not isdefined("startApp")>
	<cfset startApp = "/home.cfm">
</cfif>
	<!---- 
		replace cflocation with JavaScript below so I'll always break
		out of frames (ie, agents) when using the nav button 
	--->
	<script language="JavaScript">
		parent.location.href="#startApp#"
	</script>
	</cfoutput>
