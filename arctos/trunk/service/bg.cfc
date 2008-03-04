<cfcomponent>
	<cfoutput>
		<cffunction name="bg" access="remote" returntype="Any" output="no">
			<cfhttp url="http://bg.berkeley.edu/latest" charset="utf-8" method="get">
			</cfhttp>
			<cfreturn cfhttp.fileContent>             
	  	</cffunction>
	</cfoutput>
</cfcomponent>