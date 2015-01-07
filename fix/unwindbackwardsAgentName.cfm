<cfoutput>


select preferred_agent_name,replace(preferred_agent_name,'Jr','Jr.') from agent where preferred_agent_name like '% Jr';

select preferred_agent_name from agent where preferred_agent_name!=trim(preferred_agent_name);

select agent_name from agent_name where agent_name!=trim(agent_name);




update agent set preferred_agent_name=trim(preferred_agent_name) where preferred_agent_name!=trim(preferred_agent_name);

select preferred_agent_name from agent where preferred_agent_name!=trim(preferred_agent_name) and trim(preferred_agent_name) in (select preferred_agent_name from agent);


<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select 
		agent_id,
		preferred_agent_name 
	from 
		agent 
	where 
		agent_type='person' and 
		preferred_agent_name like '%,%' and
		preferred_agent_name not like '% III' and
		preferred_agent_name not like '% Sr.' and
		preferred_agent_name not like '% II' and
		preferred_agent_name not like '% Jr.' and
		preferred_agent_name not like '% PhD' and
		preferred_agent_name not like '% IV' and
		preferred_agent_name not like '% MD'
	and agent_id not in (select agent_id from agent_relations where agent_relationship='bad duplicate of')
</cfquery>
<cfloop query="d">
	<p>
		#preferred_agent_name#
		<cfset lname=listgetat(preferred_agent_name,1,',')>
		<cfset fname=listgetat(preferred_agent_name,2,',')>
		<cfset shn=trim(fname  & ' ' & lname)>
		<br>:#shn#:
		<cfquery name="dup" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select 
			distinct agent.agent_id, preferred_agent_name from 
			agent,agent_name where 
			agent.agent_id=agent_name.agent_id and 
			agent.agent_id != #agent_id# and 
			(agent_name ='#shn#' or preferred_agent_name='#shn#')
		</cfquery>
		<cfif dup.recordcount is 1>
			<cfquery name="mkdup" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into agent_relations (
					AGENT_ID,
					RELATED_AGENT_ID,
					AGENT_RELATIONSHIP,
					AGENT_RELATIONS_ID
				) values (
					#agent_id#,
					#dup.agent_id#,
					'bad duplicate of',
					sq_AGENT_RELATIONS_ID.nextval
				)
			</cfquery>

			<cfdump var=#dup#>
		<cfelseif dup.recordcount gt 1>
			MULTIPLES!!!!!!!!
		<cfelse>
			
			<cfquery name="nndup" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update agent set preferred_agent_name='#shn#' where agent_id=#agent_id#
			</cfquery>
			<cfquery name="oldndup" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into agent_name (AGENT_NAME_ID,AGENT_ID,AGENT_NAME_TYPE,AGENT_NAME) values 
				(sq_AGENT_NAME_ID.nextval,#agent_id#,'aka','#preferred_agent_name#')
			</cfquery>
			
			switcharoo
		
		</cfif>



	</p>
</cfloop>
</cfoutput>