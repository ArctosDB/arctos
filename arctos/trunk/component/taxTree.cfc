<cfcomponent>
<cffunction name="getNodes" access="remote" returntype="Array">
    <cfargument name="path" type="String" required="false" default=""/>
    <cfargument name="value" type="String" required="true" default=""/>
    <!--- set up return array --->
        <cfset var result= arrayNew(1)/>
        <cfset var s =""/>
		<!--- need to break PATH apart ---->
		<cfoutput>
			
			<!----
			<cfdump var="#url#">
			<cfdump var="#arguments#">
		-----------#arguments.path#---------------
		<cfif isjson(arguments.path)>
			path is json
			<cfelse>
			no it isn't
		</cfif>
		---->
		<cfif len(arguments.value) is 0>
			<cfset sql="select nvl(kingdom,'not recorded') data from taxonomy group by kingdom order by kingdom">
		<cfelse>
			<cfset sql="select '#arguments.value#' data from dual">
		</cfif>
		
        <!--- if arguments.value is empty the tree is being built for the first time --->
			<cfquery name="qry" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				#sql#
			</cfquery>
			<cfset x = 0/>
			<cfloop query="qry">
				<cfset x = x+1/>
				<cfset s = structNew()/>
				<cfset s.value="kingdom=#data#">
				<cfset s.display="#data# (kingdom)">
				<cfset arrayAppend(result,s)/>
			</cfloop>
			            <!---

			 <cfset x = 0/>
            <cfloop from="1" to="10" index="i">
                <cfset x = x+1/>
                <cfset s = structNew()/>
                <cfset s.value=#x#>
                <cfset s.display="Node #i#">
                <cfset arrayAppend(result,s)/>
            </cfloop>
						---->

      
		</cfoutput>
    <cfreturn result/>
</cffunction>
</cfcomponent>