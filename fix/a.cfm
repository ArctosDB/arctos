<cfoutput>

hello there

select preferred_agent_name,replace(preferred_agent_name,'Jr','Jr.') from agent where preferred_agent_name like '% Jr';

<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select
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
</cfquery>
<cfloop query="d">
	<p>
		#preferred_agent_name#
		<cfset lname=listgetat(preferred_agent_name,1,',')>
		<cfset fname=listgetat(preferred_agent_name,2,',')>
		<cfset shn=fname  & ' ' & lname>
		<br>#shn#
	</p>
</cfloop>
</cfoutput>