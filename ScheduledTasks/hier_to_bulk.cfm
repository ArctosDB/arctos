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

		<cfset variables.TID=TID>
		<cfset variables.PARENT_TID=PARENT_TID>
		<cfset "variables.#RANK#"=term>


	<cfdump var=#variables#>

		<!---- loop a bunch...---->
		<cfloop from="1" to="500" index="l">

		</cfloop>
	</p>
	</cfloop>
</cfoutput>
