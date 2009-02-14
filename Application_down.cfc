<cfcomponent>
<cfset This.name = "Arctos">
<cfset This.SessionManagement="True">
<cfset This.ClientManagement="true">
<cfset This.ClientStorage="Cookie">
<cffunction
     name="OnRequestStart"
     access="public"
     returntype="boolean"
     output="true">
     <cfargument
     name="TargetPage"
     type="string"
     required="true"/>
      
     <!--- Define the local scope. --->
     <cfset var LOCAL = StructNew() />
      
      
     <!--- Set header code. --->
     <cfheader
     statuscode="503"
     statustext="Service Temporarily Unavailable"
     />
      
     <!--- Set retry time. --->
     <cfheader
     name="retry-after"
     value="3600"
     />
      
      
     <h1>
     Down For Maintenance
     </h1>
      
     <p>
     Arctos currently down for maintenance and will
     be back up shortly. Sorry for the inconvenience.
     </p>
      
      
     <!---
     By returning false, the rest of the page
     rendering will hault.
     --->
     <cfreturn false />
     </cffunction>
</cfcomponent>