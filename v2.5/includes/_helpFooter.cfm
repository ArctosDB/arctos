<cfif not isdefined("title")>
	<cfset title = "Arctos Help">
</cfif>
<cftry>
	<cfhtmlhead text="<title>Arctos Help: #title#</title>
	">
	<cfcatch type="template">
		<!--- 
			do nothing, couldn't process the header
			This is almost certainly because a CFFLUSH was called - we 
			just don't get a title on the pages
		 --->
	</cfcatch>
</cftry>
</body>
</html>

