<cfcomponent>
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

<cfinclude template="includes/_header.cfm">


<cfoutput>
   <cfform name="myform">
      <cftree name="treeTest" height="400" width="200" format="html">
         <cftreeitem bind="cfc:getNodes({cftreeitempath},{cftreeitemvalue})">
      </cftree>
   </cfform>
</cfoutput>

 <cfinclude template="includes/_footer.cfm">