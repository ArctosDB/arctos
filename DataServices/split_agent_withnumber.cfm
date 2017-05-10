<!---
	split_agent_withnumber.cfm


deal with UWBM mammal data from vertnet
maybe make this something else if if works




reset button:



update temp_uwbm_allagent2 set
	rawagnt1=null,
	rawagnt2=null,
	rawagnt3=null,
	rawagnt4=null,
	rawagnt5=null,
	agent1=null,
	agent2=null,
	agent3=null,
	agent4=null,
	agent5=null,
	number1=null,
	number2=null,
	number3=null,
	number4=null,
	number5=null
 ;
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
<cfoutput>
<cfif action is "nothing">

	<br><a href="split_agent_withnumber.cfm?action=splitOrig">splitOrig</a>

	<br><a href="split_agent_withnumber.cfm?action=splitRaw&num=1">splitRaw&num=1</a>
	<br><a href="split_agent_withnumber.cfm?action=splitRaw&num=2">splitRaw&num=2</a>
	<br><a href="split_agent_withnumber.cfm?action=splitRaw&num=3">splitRaw&num=3</a>
	<br><a href="split_agent_withnumber.cfm?action=splitRaw&num=4">splitRaw&num=4</a>
	<br><a href="split_agent_withnumber.cfm?action=splitRaw&num=5">splitRaw&num=5</a>



</cfif>
	<cfif action is "splitRaw">

		<cfset f="rawagnt#num#">
		<cfset an="agent#num#">
		<cfset nn="number#num#">


		<cfquery name="d" datasource="uam_god">
			select distinct #f# rawstring from temp_uwbm_allagent2 where #f# is not null and
			#an# is null
		</cfquery>
		<cfloop query="d">
			<cfset x=sagent(rawstring)>
			<br>rawstring=#rawstring#



			<br>x.n=#x.n#
			<br>x.a=#x.a#

			<cfquery name="u" datasource="uam_god">
				update temp_uwbm_allagent2 set #an#='#x.a#',#nn#='#x.n#' where #f#='#rawstring#'
			</cfquery>

		</cfloop>

</cfif>

<cfif action is "splitOrig">



	<cfquery name="d" datasource="uam_god">
		select * from temp_uwbm_allagent2 where rawagnt1 is null
	</cfquery>
	<cfoutput>
		<cfloop query="d">
			<cfset i=1>
			<br>#agent#
				<cfloop list="#agent#" index="a" delimiters=",;">
					<cfquery name="u" datasource="prod">
						update temp_uwbm_allagent2 set rawagnt#i#='#a#' where agent='#d.agent#'
					</cfquery>

					<br>-----#a#
					<cfset i=i+1>
				</cfloop>

		</cfloop>
	</cfoutput>



</cfif>

</cfoutput>
<cfinclude template="/includes/_footer.cfm">