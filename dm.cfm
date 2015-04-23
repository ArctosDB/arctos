<!---
    mobile vs. desktop redirector
	this page should always be called with variable "r" set to wherever we're going.

	If it isn't, make them pick.

	If it is, set a cookie based on the value of r and redirect them


set a cookie and redirect ---->






<cfif isdefined("r")>

	<cfif r contains "/m/">
	      redirecting to mobile site....
	        <cfcookie
                name="dorm"
                value="mobile"
                expires="never"
                />


	    <cfelse>
	    redirecting to desktop site....


	 <cfcookie
                name="dorm"
                value="desktop"
                expires="never"
                />

	    </cfif>


    <cfdump var=#r#>
	<cfoutput>
		<cflocation url="#r#" addtoken="false">
	Click if you are not redirected: <a href="#r#">#r#</a>

	</cfoutput>
<cfelse>
    i'm not sure how you got here....
</cfif>