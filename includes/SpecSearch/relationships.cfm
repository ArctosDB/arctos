<cfoutput>
	<cfquery name="ctid_references" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select id_references from ctid_references where id_references != 'self' order by id_references
		</cfquery>
		<cfif isdefined("session.portal_id") and session.portal_id gt 0>
			<cftry>
				<cfquery name="OtherIdType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
					select distinct(other_id_type) FROM CCTCOLL_OTHER_ID_TYPE#session.portal_id# ORDER BY other_Id_Type
				</cfquery>
				<cfcatch>
					<cfquery name="OtherIdType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
						select distinct(other_id_type) FROM CTCOLL_OTHER_ID_TYPE ORDER BY other_Id_Type
					</cfquery>
				</cfcatch>
			</cftry>
		<cfelse>
			<cfquery name="OtherIdType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
				select distinct(other_id_type) FROM CTCOLL_OTHER_ID_TYPE ORDER BY other_Id_Type
			</cfquery>
		</cfif>
		boogity
</cfoutput>