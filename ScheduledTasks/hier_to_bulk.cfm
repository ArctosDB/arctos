<!---- data ---->
<cfquery name="d" datasource="uam_god">
	select * from hierarchical_taxonomy where status='ready_to_push_bl' and rownum < 5
</cfquery>
<!---- column names in order ---->
<cfquery name="oClassTerms" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			*
		from
			CTTAXON_TERM
	</cfquery>

<cfoutput>
	<cfloop query="d">
		#term# - #rank#
	</cfloop>
</cfoutput>
