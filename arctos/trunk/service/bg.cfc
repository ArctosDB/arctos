<cfcomponent>
	<cfoutput>
		<cffunction name="bg" access="remote" returntype=" output="true">
			<cfhttp url="http://bg.berkeley.edu/latest" charset="utf-8" method="get" name="bgguts">
			</cfhttp>
			<cfreturn bgguts>
	  	</cffunction>
	</cfoutput>
</cfcomponent>