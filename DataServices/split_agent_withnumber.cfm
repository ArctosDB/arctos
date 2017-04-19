<!---
	split_agent_withnumber.cfm


deal with UWBM mammal data from vertnet
maybe make this something else if if works

---->
<cfinclude template="/includes/_header.cfm">
<cfset title='vertnet hates me'>
<cfsetting requestTimeOut = "600">

<cffunction name="sagent">
	<cfargument name="ra" required="yes">
	<cfif listlen(ra,' ') gt 1>
		<cfset n=trim(listlast(ra,' '))>
		<cfset a=trim(replace(ra,n,'','all'))>
	<cfelse>
		<cfset a=ra>
		<cfset n=''>
	</cfif>
	<cfset r={}>
	<cfset r.n=n>
	<cfset r.a=a>
	<cfreturn r>
</cffunction>

<cfif action is "nothing">
	<cfoutput>
		<cfquery name="d" datasource="prod">
			select distinct rawagnt1 rawstring from temp_uwbm_agentmess where rawagnt1 is not null and
			agent1 is null and rownum<500
		</cfquery>
		<cfloop query="d">
			<br>rawstring=#rawstring#
			<cfset x=sagent(rawstring)>


			<cfdump var=#x#>
			<br>x.n=#x.n#
			<br>x.a=#x.a#
			<!----------
			<cfif listlen(rawagnt1,' ') gt 1>
				<cfset n=trim(listlast(rawagnt1,' '))>
				<cfset a=trim(replace(rawagnt1,n,'','all'))>
				<br>n==#n#
				<br>a==#a#
			<cfelse>
				<br>
				<cfset n=rawagnt1>
				<cfset a=''>
			</cfif>
			<cfquery name="u" datasource="prod">
				update temp_uwbm_agentmess set agent1='#a#',number1='#n#' where rawagnt1='#rawagnt1#'
			</cfquery>

			---------->
		</cfloop>
	</cfoutput>




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