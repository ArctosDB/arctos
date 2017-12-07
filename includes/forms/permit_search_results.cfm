<cfoutput>
	<cfset bsql = "select
		permit.permit_id,
		getPreferredAgentName(permit_agent.agent_id) permit_agent,
		permit_agent.agent_role,
		permit.issued_Date,
		permit.exp_Date,
		permit.permit_Num,
		permit.permit_remarks,
		permit_type.permit_type,
		permit_type.permit_regulation
	from">
	<cfset whrtbls="
		permit,
		permit_agent,
		permit_type
		">
	<cfset whrcls="
	where
		permit.permit_id = permit_agent.permit_id (+) and
		permit.permit_id = permit_type.permit_id (+) ">

<cfif len(IssuedByAgent) gt 0>
	<cfset whrtbls=whrtbls & ", agent_name IssuedByAgentName, permit_agent permit_agent_IBA ">
	<cfset whrcls=whrcls & " and permit.permit_id= permit_agent_IBA.permit_id and
			permit_agent_IBA.agent_role='issued by' and
			permit_agent_IBA.agent_id=IssuedByAgentName.agent_id and
			upper(IssuedByAgentName.agent_name) like '%#ucase(IssuedByAgent)#%' ">
</cfif>

<cfif len(IssuedToAgent) gt 0>
	<cfset whrtbls=whrtbls & ", agent_name IssuedToAgentName, permit_agent permit_agent_ITA ">
	<cfset whrcls=whrcls & " and permit.permit_id= permit_agent_ITA.permit_id and
			permit_agent_ITA.agent_role='issued to' and
			permit_agent_ITA.agent_id=IssuedToAgentName.agent_id and
			upper(IssuedToAgentName.agent_name) like '%#ucase(IssuedToAgent)#%' ">
</cfif>
<cfif len(ContactAgent) gt 0>
	<cfset whrtbls=whrtbls & ", agent_name ContactAgentName, permit_agent permit_agent_CA ">
	<cfset whrcls=whrcls & " and permit.permit_id= permit_agent_CA.permit_id and
			permit_agent_CA.agent_role='issued to' and
			permit_agent_CA.agent_id=ContactAgentName.agent_id and
			upper(ContactAgentName.agent_name) like '%#ucase(ContactAgent)#%' ">
</cfif>

<cfif isdefined("anyAgent") and len(anyAgent) gt 0>
	<cfif whrtbls does not contain "permit_agent_AA">
		<cfset whrtbls=whrtbls & ", agent_name AnyAgentName, permit_agent permit_agent_AA ">
		<cfset whrcls=whrcls & " and permit.permit_id= permit_agent_AA.permit_id and
			permit_agent_AA.agent_id=AnyAgentName.agent_id">
	</cfif>
	<cfset whrcls=whrcls & " and upper(AnyAgentName.agent_name) like '%#ucase(anyAgent)#%' ">
</cfif>

<cfif isdefined("anyAgentRole") and len(anyAgentRole) gt 0>
	<cfif whrtbls does not contain "permit_agent_AA">
		<cfset whrtbls=whrtbls & ", agent_name AnyAgentName, permit_agent permit_agent_AA ">
		<cfset whrcls=whrcls & " and permit.permit_id= permit_agent_AA.permit_id and
			permit_agent_AA.agent_id=AnyAgentName.agent_id">
	</cfif>
	<cfset whrcls=whrcls & " and permit_agent_AA = 'anyAgentRole' ">
</cfif>


<cfif len(IssuedAfter) gt 0>
	<cfset whrcls=whrcls & " AND issued_date >= '#IssuedAfter#'">
</cfif>

<cfif len(IssuedBefore) gt 0>
	<cfset whrcls=whrcls & " AND issued_date <= '#IssuedBefore#'">
</cfif>


<cfif len(ExpiresAfter) gt 0>
	<cfset whrcls=whrcls & " AND exp_date >= '#ExpiresAfter#'">
</cfif>


<cfif len(ExpiresBefore) gt 0>
	<cfset whrcls=whrcls & " AND exp_date <= '#ExpiresBefore#'">
</cfif>


<cfif len(permit_num) gt 0>
	<cfif left(permit_num,1) is "=">
		<cfset whrcls=whrcls & " AND permit_num = '#ucase(mid(permit_num,2,len(permit_num)-1))#'">
	<cfelse>
		<cfset whrcls=whrcls & " AND upper(permit_Num) like '%#ucase(permit_Num)#%'">
	</cfif>
</cfif>


<cfif len(permit_type) gt 0>
	<cfset whrcls=whrcls & " AND permit.permit_id in (select permit_id from permit_type where permit_type = '#permit_type#')">
</cfif>
<cfif len(permit_regulation) gt 0>
	<cfset whrcls=whrcls & " AND permit.permit_id in (select permit_id from permit_type where permit_regulation = '#permit_regulation#')">
</cfif>


<cfif len(permit_remarks) gt 0>
	<cfset whrcls=whrcls & " AND upper(permit_remarks) like '%#ucase(permit_remarks)#%'">
</cfif>

<cfif isdefined("permit_id") and len(permit_id) gt 0>
	<cfset whrcls=whrcls & " AND permit.permit_id = #permit_id#">
</cfif>

<cfset sqlstring=bsql & whrtbls & whrcls>

</cfoutput>
