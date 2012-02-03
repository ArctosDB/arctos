<cfoutput>
	<cfparam name="vd">
	<form>
		<input name="vd" value="#vd#">
		<input type="submit">
	</form>
	
	<cfif isdefined("vd")>
		<hr>vd: #vd#
		<cfif isdate(vd)>
			<br>vd is a date --#dateformat(vd,"yyyy-mm-dd")#--
		</cfif>
	</cfif>
</cfoutput>