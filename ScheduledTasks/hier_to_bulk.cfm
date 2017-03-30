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
			<cfset "v_#TAXON_TERM#"="">
		</cfloop>
	<p>

		#term# - #rank#

		<cfset v_TID=TID>
		<cfset v_PARENT_TID=PARENT_TID>
		<cfset "v_#RANK#"=term>



		<!---- loop a bunch...---->
		<cfloop from="1" to="500" index="l">

		</cfloop>
	</p>
	</cfloop>
</cfoutput>
