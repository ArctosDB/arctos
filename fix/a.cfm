<cfoutput>
	--#session.displayrows#--
	<br>
	<cfif not isdefined("session.displayrows")>
		not defined
	</cfif>
	<cfif len(session.displayrows) is 0>
		len is 0
	</cfif>
	<cfif not isnumeric(session.displayrows)>
		not numeric
	</cfif>
	<cfif session.displayrows lt 10>
			lt 10
		</cfif>

</cfoutput>