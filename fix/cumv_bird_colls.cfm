<cfinclude template="/includes/_header.cfm">
<cfoutput>
	<cfsetting requestTimeOut = "1200">
	<cfsavecontent variable="dsql">
		<cfloop from="1" to="8" index="x">
			,collector_#x#
			,preparator_#x#
		</cfloop>
	</cfsavecontent>
	<cfset sql="select collectors,preparator #dsql# from birdprepcoll where gotit is null group by collectors,preparator #dsql#">
	<cfquery name="d" datasource="uam_god">
		select * from (#sql#) where rownum<10001
	</cfquery>
	<cfif d.recordcount is 0>alldone</cfif>
	<cfloop query="d">
		<cfloop from="1" to="8" index="x">
			<cfset "n#x#"=''>
			<cfset "r#x#"=''>
		</cfloop>
		<cfset thisorder=1>
		<cfloop from="1" to="8" index="x">
			<cfset thisC=evaluate("d.collector_" & x)>
			<cfif len(thisC) gt 0>
				<cfset "n#thisorder#"=thisC>
				<cfset "r#thisorder#"='c'>
				<cfset thisorder=thisorder+1>
			</cfif>
		</cfloop>
		<cfloop from="1" to="8" index="x">
			<cfset thisC=evaluate("d.preparator_" & x)>
			<cfif len(thisC) gt 0>
				<cfset "n#thisorder#"=thisC>
				<cfset "r#thisorder#"='p'>
				<cfset thisorder=thisorder+1>
			</cfif>
		</cfloop>
		<cfquery name="up" datasource="uam_god">
			update birdprepcoll set gotit=1 where collectors
			<cfif len(collectors) gt 0>
				='#escapeQuotes(collectors)#' 
			<cfelse>
				is null
			</cfif>
			and preparator
			<cfif len(preparator) gt 0>
				='#escapeQuotes(preparator)#'
			<cfelse>
				is null
			</cfif>
		</cfquery>
		<cfquery name="up" datasource="uam_god">
		update cumv_bird_bulk set 
		collector_agent_1='#n1#',
		collector_role_1='#r1#',
		collector_agent_2='#n2#',
		collector_role_2='#r2#',
		collector_agent_3='#n3#',
		collector_role_3='#r3#',
		collector_agent_4='#n4#',
		collector_role_4='#r4#',
		collector_agent_5='#n5#',
		collector_role_5='#r5#',
		collector_agent_6='#n6#',
		collector_role_6='#r6#',
		collector_agent_7='#n7#',
		collector_role_7='#r7#',
		collector_agent_8='#n8#',
		collector_role_8='#r8#'				
		where collectors='#escapeQuotes(collectors)#' and preparator
			<cfif len(preparator) gt 0>
				='#escapeQuotes(preparator)#'
			<cfelse>
				is null
			</cfif>
		</cfquery>
	</cfloop>
</cfoutput>