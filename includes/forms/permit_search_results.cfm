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
	<cfset whrtbls=whrtbls & ", agent_name IssuedByAgentName, permit_agent permit_agent_ITA ">
	<cfset whrcls=whrcls & " and permit.permit_id= permit_agent_ITA.permit_id and
			permit_agent_ITA.agent_role='issued by' and
			permit_agent_ITA.agent_id=IssuedByAgentName.agent_id and
			upper(IssuedByAgentName.agent_name) like '%#ucase(IssuedByAgent)#%') ">
</cfif>



<cfset sqlstring=bsql & whrtbls & whrcls>

<!----

</cfif>
	<cfif len(IssuedByAgent) gt 0>
		<cfset whrtbls=whrtbls & ", agent_name IssuedToAgentName ">
		<cfset whrcls=whrcls & " and permit_agent.agent_id=IssuedByAgentName.agent_id and
			upper(IssuedByAgentName.agent_name) like '%#ucase(IssuedByAgent)#%') ">
	</cfif>


<cfif len(IssuedToAgent) gt 0>

<cfset sql = "#sql# AND permit.permit_id in (
		select permit_agent.permit_id from
		permit_agent,agent_name
		where
		permit_agent.agent_id=agent_name.agent_id and
		permit_agent.agent_role='issued to' and
		upper(agent_name.agent_name) like '%#ucase(IssuedToAgent)#%')">

<cfif len(ContactAgent) gt 0>
	<cfset sql = "#sql# AND permit.permit_id in (
		select permit_agent.permit_id from
		permit_agent,agent_name
		where
		permit_agent.agent_id=agent_name.agent_id and
		permit_agent.agent_role='contact' and
		upper(agent_name.agent_name) like '%#ucase(ContactAgent)#%')">
</cfif>

<cfif len(IssuedAfter) gt 0>
	<cfset sql = "#sql# AND issued_date >= '#issued_date#'">
</cfif>

<cfif len(IssuedBefore) gt 0>
	<cfset sql = "#sql# AND issued_date <= '#IssuedBefore#'">
</cfif>


<cfif len(ExpiresAfter) gt 0>
	<cfset sql = "#sql# AND exp_date >= '#ExpiresAfter#'">
</cfif>


<cfif len(ExpiresBefore) gt 0>
	<cfset sql = "#sql# AND exp_date <= '#ExpiresBefore#'">
</cfif>


<cfif len(permit_num) gt 0>
	<cfset sql = "#sql# AND upper(permit_Num) like '%#ucase(permit_Num)#%'">
</cfif>


<cfif len(permit_type) gt 0>
	<cfset sql = "#sql# AND permit.permit_id in (select permit_id from permit_type where permit_type = '#permit_type#')">
</cfif>
<cfif len(permit_regulation) gt 0>
	<cfset sql = "#sql# AND permit.permit_id in (select permit_id from permit_type where permit_regulation = '#permit_regulation#')">
</cfif>


<cfif len(permit_remarks) gt 0>
	<cfset sql = "#sql# AND upper(permit_remarks) like '%#ucase(permit_remarks)#%'">
</cfif>

<cfif isdefined("permit_id") and len(permit_id) gt 0>
	<cfset sql = "#sql# AND permit.permit_id = #permit_id#">
</cfif>

--->
