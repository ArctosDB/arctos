<!---
	split_agent_withnumber.cfm


deal with UWBM mammal data from vertnet
maybe make this something else if if works

---->
<cfinclude template="/includes/_header.cfm">
<cfset title='vertnet hates me'>
<cfsetting requestTimeOut = "600">

<cfif action is "nothing">
	<cfquery name="d" datasource="prod">
		select * from temp_uwbm_agentmess where rownum<100
	</cfquery>
	<cfoutput>
		<cfloop query="d">
			<br>#agent#
		</cfloop>
	</cfoutput>


</cfif>
<cfinclude template="/includes/_footer.cfm">