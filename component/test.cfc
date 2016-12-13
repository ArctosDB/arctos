<cfcomponent>
<cffunction name="getInitTaxTree" access="remote">

	<cfoutput>
	<cfquery name="d" datasource="uam_god">
		select nvl(parent_tid,0) parent_tid, term,tid,rank from hierarchical_taxonomy where parent_tid is null
	</cfquery>

	<cf
	<cfset x="[">
	<cfset i=1>
	<cfloop query="d">

		<!----
		<cfset x=x & '{"id":"id_#tid#","text":"#term# (#rank#)","children":true}'>
		---->
		<cfset x=x & '["#tid#","#parent_tid#","#term#"]'>
		<cfif i lt d.recordcount>
			<cfset x=x & ",">
		</cfif>
		<cfset i=i+1>
	</cfloop>
	<cfset x=x & "]">

		<cfreturn x>
	</cfoutput>

</cffunction>

<cffunction name="test" access="remote">
   <cfargument name="q" type="String" required="false" default=""/>
<cfargument name="t" type="String" required="false" default=""/>

	<cftry>
	<cfquery name="t" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from agent_name where upper(agent_name) like '#ucase(q)#%'
		<cfif len(t) gt 0>and age_name_type='#t#'</cfif>
	</cfquery>
	<cfreturn t>
	<cfcatch>
		<cfreturn cfcatch.detail>
	</cfcatch>
	</cftry>
</cffunction>

<cffunction name="getNodes" access="remote" returntype="array">
   <cfargument name="path" type="String" required="false" default=""/>
   <cfargument name="value" type="String" required="true" default=""/>
   <!--- set up return array --->
      <cfset var result= arrayNew(1)/>
      <cfset var s =""/>

      <!--- if arguments.value is empty the tree is being built for the first time --->
      <cfif arguments.value is "">
         <cfset x = 0/>
         <cfloop from="1" to="10" index="i">
            <cfset x = x+1/>
            <cfset s = structNew()/>
            <cfset s.value=#x#>
            <cfset s.display="Node #i#">
            <cfset arrayAppend(result,s)/>
         </cfloop>
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
