<cfoutput>
	<cfparam name="vd">
	<cfparam name="bd">
	<cfparam name="ed">
	<form>
		<input name="vd" value="#vd#">
		<input type="submit">
	</form>
	
	<cfif isdefined("vd") and len(vd) gt 0>
		
		<!--- 4-digit year --->
		<cfif len(vd) is 4 and isnumeric(vd)>
			<cfset bd="#vd#-01-01">
			<cfset ed="#vd#-12-31">
		</cfif>
		<cfif isdate(vd)>
			<br>vd is a date --#dateformat(vd,"yyyy-mm-dd")#--
		</cfif>
		
		<hr>
		vd: #vd#
		<br>bd: #bd#
		<br>ed: #ed#
	</cfif>
</cfoutput>