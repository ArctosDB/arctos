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
  Arctos will be offline Wednesday, May 27th at 5pm through Friday, May 29th at 5pm, Arctos for our move to the new Arctos PostgreSQL.
     </p>
<p>
You will need to create a new password the first time you log in after May 29. Use the Lost Password function to create a new password the first time you log in after the move.
</p>

<p>
	We appreciate your feedback. Please use the Arctos GitHub Repository (https://github.com/ArctosDB/arctos/issues) for error reporting and troubleshooting during this time.
     </p>


     <!---
     By returning false, the rest of the page
     rendering will hault.
     --->
     <cfreturn false />
     </cffunction>
</cfcomponent>