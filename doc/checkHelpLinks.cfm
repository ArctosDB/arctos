<cfset res=  DirectoryList(Application.webDirectory,true,"path","*.cf*")>
<cfdump var="#res#">
<cfoutput>
	<cfloop array="#res#" index="f">
		<br>#f#

	</cfloop>
</cfoutput>