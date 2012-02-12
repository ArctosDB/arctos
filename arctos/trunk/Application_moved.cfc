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
      
    We've moved, but the DNS servers haven't caught up yet.
	
	<p>
		You can find us at http://129.114.52.171, and things should be back to normal within 24h.
	</p>
     <cfreturn false />
     </cffunction>
</cfcomponent>