<cfoutput>
	<cfif not isdefined("term")>
		no term<cfabort>
	</cfif>
	<cfif term is "georeference_source">
		<cfquery name="pn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select georeference_source from locality where upper(georeference_source) like '%#ucase(q)#%'
			group by georeference_source
			order by georeference_source
		</cfquery>
		<cfloop query="pn">
			#georeference_source# #chr(10)#
		</cfloop>
	</cfif>
</cfoutput>