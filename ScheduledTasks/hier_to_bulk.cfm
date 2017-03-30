<!---- data ---->
<cfquery name="d" datasource="uam_god">
	select * from hierarchical_taxonomy where status='ready_to_push_bl' and rownum < 5
</cfquery>
<!---- column names in order ---->
<cfquery name="CTTAXON_TERM" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			*
		from
			CTTAXON_TERM
	</cfquery>

<cfoutput>
	<cfloop query="d">
		<!--- reset variables ---->
		<cfloop query="CTTAXON_TERM">
			<cfset "variables.#TAXON_TERM#"="">
		</cfloop>
	<p>

		#term# - #rank#

		<cfset variables.TID=d.TID>
		<cfset variables.PARENT_TID=d.PARENT_TID>
		<cfset "variables.#RANK#"=d.term>


	<cfdump var=#variables#>

		<!---- loop a bunch...---->
		<cfloop from="1" to="500" index="l">
			<cfif len(variables.PARENT_TID) gt 0>
				<br>got a parent, get it
				<cfquery name="next" datasource="uam_god">
					select * from hierarchical_taxonomy where tid=#variables.PARENT_TID#
				</cfquery>
				<cfdump var="#next#">
				<cfset variables.TID=next.TID>
				<cfset variables.PARENT_TID=next.PARENT_TID>
				<cfset "variables.#next.RANK#"=next.term>
				<br>#next.RANK#=#evaluate('variables.' & next.RANK)#
			<cfelse>
				<cfbreak>
			</cfif>

		</cfloop>
	</p>
	</cfloop>
</cfoutput>
