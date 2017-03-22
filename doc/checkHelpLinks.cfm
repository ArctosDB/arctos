<cfset res=  DirectoryList(Application.webDirectory,true,"path","*.cf*")>
<cfoutput>
	<cfloop array="#res#" index="f">
		<!--- ignore cfr etc --->
		<cfif listlast(f,".") is "cfm" or listlast(f,".") is "cfc">
			<br>#f#
			<cffile action = "read" file = "#f#" variable = "fc">
			<cfif fc contains "helpLink">
				<br>-------------------------- something to check here ----------------
			</cfif>
		</cfif>

	</cfloop>
</cfoutput>