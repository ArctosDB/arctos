<!---
	split_agent_withnumber.cfm


deal with UWBM mammal data from vertnet
maybe make this something else if if works

---->
<cfinclude template="/includes/_header.cfm">
<cfset title='vertnet hates me'>
<cfsetting requestTimeOut = "600">

<cfif action is "nothing">
	<cfoutput>
		<cfquery name="d" datasource="prod">
			select distinct rawagnt1 from temp_uwbm_agentmess where rawagnt1 is not null and
			agent1 is null and rownum<50
		</cfquery>
		<cfloop query="d">
			<br>#rawagnt1#
		</cfloop>
	</cfoutput>


alter table temp_uwbm_agentmess add agent1 VARCHAR2(4000);
alter table temp_uwbm_agentmess add number1 VARCHAR2(4000);


	<!---- split into individuals (sometimes, maybe!!)
	<cfquery name="d" datasource="prod">
		select * from temp_uwbm_agentmess where rownum<5000 and rawagnt1 is null
	</cfquery>
	<cfoutput>
		<cfloop query="d">
			<cfset i=1>
			<br>#agent#
			<cfif agent contains ",">
				<cfloop list="#agent#" index="a">
					<cfquery name="u" datasource="prod">
						update temp_uwbm_agentmess set rawagnt#i#='#a#' where agent='#d.agent#'
					</cfquery>

					<br>-----#a#
					<cfset i=i+1>
				</cfloop>
			<cfelse>
				<!--- nothing to split, stuff everything to one ---->
				<cfquery name="u" datasource="prod">
					update temp_uwbm_agentmess set rawagnt1='#d.agent#' where agent='#d.agent#'
				</cfquery>
			</cfif>
		</cfloop>
	</cfoutput>
	END split into individuals (sometimes, maybe!!) ---->



</cfif>
<cfinclude template="/includes/_footer.cfm">