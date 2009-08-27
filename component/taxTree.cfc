<cfcomponent>
<cffunction name="getNodes" access="remote" returntype="Array">
    <cfargument name="path" type="String" required="false" default=""/>
    <cfargument name="value" type="String" required="true" default=""/>
    <!--- set up return array --->
        <cfset var result= arrayNew(1)/>
        <cfset var s =""/>
		<!--- need to break PATH apart ---->
		<cfoutput>
		-----------#arguments.path#---------------
		<cfif isjson(arguments.path)>
			path is json
			<cfelse>
			no it isn't
		</cfif>
		</cfoutput>
        <!--- if arguments.value is empty the tree is being built for the first time --->
        <cfif arguments.value is "">
			<cfquery name="qry" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select nvl(kingdom,'not recorded') data from taxonomy group by kingdom order by kingdom
			</cfquery>
			<cfset x = 0/>
			<cfloop query="qry">
				<cfset x = x+1/>
				<cfset s = structNew()/>
				<cfset s.value="#data#[kingdom]">
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

        <cfelse>
        <!--- arguments.value is not empty --->
        <!--- to keep it simple we will only make children nodes --->
        <cfset y = 0/>
            <cfloop from="1" to="#arguments.value#" index="q">
                <cfset y = y + 1/>
                <cfset s = structNew()/>
                <cfset s.value=#q#>
                <cfset s.display="Leaf #q#">
                <cfset s.leafnode=true/>
                <cfset arrayAppend(result,s)/>
            </cfloop>
        </cfif>
    <cfreturn result/>
</cffunction>
</cfcomponent>