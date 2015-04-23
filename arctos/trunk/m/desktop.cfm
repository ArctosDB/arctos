<!--- set a cookie and redirect ---->

yea yea, working on it.....
<cfif isdefined("r")>
    set cookie and redirect to <cfdump var=#r#>
<cfelse>
    set cookie & redirect /
</cfif>