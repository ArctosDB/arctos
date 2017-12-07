<cfoutput>
	<!----
		standard permit search SQL assembly

	---->
	<cfset bsql = "select
		permit.permit_id,
		permit.issued_Date,
		permit.exp_Date,
		permit.permit_Num,
		permit.permit_remarks,
		getPermitAgents(permit.permit_id, 'issued to') IssuedToAgent,
		getPermitAgents(permit.permit_id, 'issued by') IssuedByAgent,
		getPermitAgents(permit.permit_id, 'contact') ContactAgent,
		getPermitTypeReg(permit.permit_id) permit_Type
	from ">
	<cfset whrtbls=" permit	">
	<cfset whrcls=" where 1=1">

<cfif isdefined("IssuedByAgent") and len(IssuedByAgent) gt 0>
	<cfset whrtbls=whrtbls & ", agent_name IssuedByAgentName, permit_agent permit_agent_IBA ">
	<cfset whrcls=whrcls & " and permit.permit_id= permit_agent_IBA.permit_id and
			permit_agent_IBA.agent_role='issued by' and
			permit_agent_IBA.agent_id=IssuedByAgentName.agent_id and
			upper(IssuedByAgentName.agent_name) like '%#ucase(IssuedByAgent)#%' ">
</cfif>

<cfif isdefined("IssuedToAgent") and len(IssuedToAgent) gt 0>
	<cfset whrtbls=whrtbls & ", agent_name IssuedToAgentName, permit_agent permit_agent_ITA ">
	<cfset whrcls=whrcls & " and permit.permit_id= permit_agent_ITA.permit_id and
			permit_agent_ITA.agent_role='issued to' and
			permit_agent_ITA.agent_id=IssuedToAgentName.agent_id and
			upper(IssuedToAgentName.agent_name) like '%#ucase(IssuedToAgent)#%' ">
</cfif>
<cfif isdefined("ContactAgent") and len(ContactAgent) gt 0>
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
	<cfset whrcls=whrcls & " and permit_agent_AA.agent_role = '#anyAgentRole#' ">
</cfif>


<cfif isdefined("IssuedAfter") and len(IssuedAfter) gt 0>
	<cfset whrcls=whrcls & " AND issued_date >= '#IssuedAfter#'">
</cfif>

<cfif isdefined("IssuedBefore") and len(IssuedBefore) gt 0>
	<cfset whrcls=whrcls & " AND issued_date <= '#IssuedBefore#'">
</cfif>


<cfif isdefined("ExpiresAfter") and len(ExpiresAfter) gt 0>
	<cfset whrcls=whrcls & " AND exp_date >= '#ExpiresAfter#'">
</cfif>


<cfif isdefined("ExpiresBefore") and len(ExpiresBefore) gt 0>
	<cfset whrcls=whrcls & " AND exp_date <= '#ExpiresBefore#'">
</cfif>


<cfif isdefined("permit_num") and len(permit_num) gt 0>
	<cfif left(permit_num,1) is "=">
		<cfset whrcls=whrcls & " AND permit_num = '#ucase(mid(permit_num,2,len(permit_num)-1))#'">
	<cfelse>
		<cfset whrcls=whrcls & " AND upper(permit_Num) like '%#ucase(permit_Num)#%'">
	</cfif>
</cfif>


<cfif isdefined("permit_type") and len(permit_type) gt 0>
	<cfset whrcls=whrcls & " AND permit.permit_id in (select permit_id from permit_type where permit_type = '#permit_type#')">
</cfif>
<cfif isdefined("permit_regulation") and len(permit_regulation) gt 0>
	<cfset whrcls=whrcls & " AND permit.permit_id in (select permit_id from permit_type where permit_regulation = '#permit_regulation#')">
</cfif>


<cfif isdefined("permit_remarks") and len(permit_remarks) gt 0>
	<cfset whrcls=whrcls & " AND upper(permit_remarks) like '%#ucase(permit_remarks)#%'">
</cfif>

<cfif isdefined("permit_id") and len(permit_id) gt 0>
	<cfset whrcls=whrcls & " AND permit.permit_id = #permit_id#">
</cfif>

<cfset sqlstring=bsql & whrtbls & whrcls & " group by
	permit.permit_id,
	permit.issued_Date,
	permit.exp_Date,
	permit.permit_Num,
	permit.permit_remarks,
	getPermitAgents(permit.permit_id, 'issued to'),
	getPermitAgents(permit.permit_id, 'issued by'),
	getPermitAgents(permit.permit_id, 'contact'),
	getPermitTypeReg(permit.permit_id) ">

</cfoutput>
