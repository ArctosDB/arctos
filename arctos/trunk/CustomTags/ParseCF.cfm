<cfif ThisTag.ExecutionMode IS "END">
     <cfset dummy = SetVariable("Caller." & Attributes.Var, ThisTag.GeneratedContent)>
     <cfset ThisTag.GeneratedContent = "">
</cfif>