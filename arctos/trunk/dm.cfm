<!--- mobile vs. desktop redirector
set a cookie and redirect ---->

yea yea, working on it.....
<cfif isdefined("r")>
	<cfif request.rdurl contains "/m/">
	   coming from mobile - redirect to desktop
	   <cfcookie
		    name="dorm"
		    value="desktop"
		    expires="never"
		    />

	<cfelse>
	 <cfcookie
            name="dorm"
            value="mobile"
            expires="never"
            />

	</cfif>





    set cookie and redirect

	got....<cfdump var=#r#>





<cfelse>
    set cookie & redirect /
</cfif>