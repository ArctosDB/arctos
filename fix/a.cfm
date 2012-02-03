<cfoutput>
	<form>
		<input name="vd">
		<input type="submit">
	</form>
	
	<cfif isdefined("vd")>
		<hr>vd: #vd#
		<cfif isdate(vd)>
			<br>vd is a date
		</cfif>
	</cfif>
</cfoutput>