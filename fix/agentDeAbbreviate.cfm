<cfinclude template="/includes/_header.cfm">
<cfoutput>
agentDeAbbreviate.cfm
		<cfquery name="d" datasource="uam_god">
			select
				agent_id,
				preferred_agent_name from agent where
			agent_type='person' and preferred_agent_name like '%Mr.%' and
			  agent_id not in (select agent_id from agent_relations union select related_agent_id from agent_relations )
			order by preferred_agent_name
		</cfquery>
		<cfloop query="d">
			<hr>
			#preferred_agent_name#
			<cfset shouldFindName=replace(d.preferred_agent_name,'Mr. ','','all')>
			<br>#shouldFindName#
			<cfquery name="hgv" datasource="uam_god">
				select * from agent_name where agent_name='#shouldFindName#' and agent_id=#agent_id#
			</cfquery>
			<cfif hgv.recordcount gte 1>
				<br>has good variant do nothing
			<cfelse>
				<cfquery name="hg"  datasource="uam_god">
					select * from agent where preferred_agent_name='#shouldFindName#'  and agent_id!=#agent_id#
				</cfquery>
				<cfif hg.recordcount is 1>
					<br>DUPLICATE!!
					<cfdump var=#hg#>

					<cfquery name="insreln" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						insert into agent_relations (
							AGENT_ID,
							RELATED_AGENT_ID,
							AGENT_RELATIONSHIP,
							AGENT_RELATIONS_ID,
							CREATED_BY_AGENT_ID,
							CREATED_ON_DATE
						) values (
							#agent_id#,
							#hg.agent_id#,
							'bad duplicate of',
							sq_agent_relations_id.nextval,
							2072,
							sysdate
						)
					</cfquery>
				<cfelse>
					<cfquery name="autoinsert" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						insert into agent_name (
							AGENT_NAME_ID,
							AGENT_ID,
							AGENT_NAME_TYPE,
							AGENT_NAME
						) values (
							sq_agent_name_id.nextval,
							#agent_id#,
							'aka',
							'#shouldFindName#'
						)
					</cfquery>
					<br>can probably auto-insert a name

				</cfif>
			</cfif>


		</cfloop>

</cfoutput>

