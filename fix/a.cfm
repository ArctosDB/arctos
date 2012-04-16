<cfoutput>
			
			<cfloop collection="#session#" item="key">
				<cfif len(session[key]) gt 0>
				#key#: #session[key]#<br />

				</cfif>
</cfloop>


</cfoutput>