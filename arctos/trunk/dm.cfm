<!---
	mobile vs. desktop redirector
	this page should always be called with variable "r" set to wherever we're going.
	If it isn't, make them pick.
	If it is, set a cookie based on the value of r and redirect them
	set a cookie and redirect ---->
<cfset r=replace(r,"//","/","all")>
<cfif isdefined("r")>
	<cfif r contains "/m/">
		redirecting to mobile site....
		<cfcookie
			name="dorm"
			value="mobile"
			expires="never"
			/>
	<cfelse>
		<cfcookie
			name="dorm"
			value="desktop"
			expires="never"
			/>
	</cfif>
	<cfdump var=#r#>
	<cfoutput>
		<!----
			---->
		<cflocation url="#r#" addtoken="false">
		Click if you are not redirected:
		<a href="#r#">
			#r#
		</a>
	</cfoutput>
<cfelse>
	I'm not sure how you got here....you're probably looking for the
	<a href="/">
		desktop site
	</a>
	or the
	<a href="/m/">
		mobile site
	</a>
</cfif>