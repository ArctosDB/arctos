<cfinclude template="/includes/_header.cfm">
<cfoutput>
	<cfquery name="p" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select publication_id from publication where publication_id not in (select publication_id from formatted_publication)
	</cfquery>
	<cfloop query="p">
		<cftransaction>
			<cfset publication_id=p.publication_id>
			<cfinvoke component="/component/publication" method="shortCitation" returnVariable="shortCitation">
				<cfinvokeargument name="publication_id" value="#publication_id#">
				<cfinvokeargument name="returnFormat" value="plain">
			</cfinvoke>
			<cfinvoke component="/component/publication" method="longCitation" returnVariable="longCitation">
				<cfinvokeargument name="publication_id" value="#publication_id#">
				<cfinvokeargument name="returnFormat" value="plain">
			</cfinvoke>				
			<cfquery name="sfp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into formatted_publication (
					publication_id,
					format_style,
					formatted_publication
				) values (
					#publication_id#,
					'short',
					'#shortCitation#'
				)
			</cfquery>
			<cfquery name="lfp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into formatted_publication (
					publication_id,
					format_style,
					formatted_publication
				) values (
					#publication_id#,
					'long',
					'#longCitation#'
				)
			</cfquery>
		</cftransaction>
	</cfloop>
</cfoutput>