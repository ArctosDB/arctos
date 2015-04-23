<!--- set a cookie and redirect ---->

yea yea, working on it.....
<cfif isdefined("r")>
    set cookie and redirect

	got....<cfdump var=#r#>




    <cfif r contains "SpecimenResults.cfm" and (isdefined("mapurl") and len(mapurl) gt 0)>
          <cfset murl="/SpecimenResults.cfm?mapurl=" & mapurl>
    <cfelse>
           <cfset murl=r>
     </cfif>

    going....<cfdump var=#murl#>



<cfelse>
    set cookie & redirect /
</cfif>