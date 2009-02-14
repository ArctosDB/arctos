<!--- updates missing taxonomy based on existing entries -------->
<cfset theList = "Accipitridae,Alcidae,Sylviidae,Caprimulgidae,Charadriidae,Cisticolidae,Coliidae,Columbidae,Corvidae,Cotingidae,Cuculidae,Dendrocolaptidae,Emberizidae,Estrildidae,Furnariidae,Phasianidae,Picidae,Pipridae,Psittacidae,Strigidae,Troglodytidae,Turdidae,Timaliidae,Tyrannidae,Tytonidae,Laniidae,Meliphagidae,Parulidae,Cathartidae,Upupidae,Vangidae,Viduidae,Vireonidae,Zosteropidae">
<cfoutput>
<cfloop list="#theList#" index="i">
	<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select phylclass from taxonomy where family='#i#'
		and phylclass is not null
		group by phylclass
	</cfquery>
	<cfquery name="o" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select phylorder from taxonomy where family='#i#'
		and phylorder is not null
		group by phylorder
	</cfquery>
	<cfquery name="s" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select suborder from taxonomy where family='#i#'
		and suborder is not null
		group by suborder
	</cfquery>
	
	<cfif #c.recordcount# is 0>
		<br />No class for #i#
	<cfelseif #c.recordcount# is 1>
		<cfquery name="uc" datasource="#Application.uam_dbo#">
			update taxonomy set phylclass='#c.phylclass#'
			where family = '#i#'
		</cfquery>
		<br />#i# class = #c.phylclass#
	<cfelse>
		<br />Multiple class for #i#:
			<blockquote>
			<cfloop query="c">
				<br />#phylclass#
			</cfloop>
			</blockquote>
	</cfif>
	
	<cfif #o.recordcount# is 0>
		<br />No phylorder for #i#
	<cfelseif #o.recordcount# is 1>
		<cfquery name="uo" datasource="#Application.uam_dbo#">
			update taxonomy set phylorder='#o.phylorder#'
			where family = '#i#'
		</cfquery>
		<br />#i# phylorder = #o.phylorder#
	<cfelse>
		<br />Multiple phylorder for #i#:
			<blockquote>
			<cfloop query="o">
				<br />#phylorder#
			</cfloop>
			</blockquote>
	</cfif>
	
	<cfif #s.recordcount# is 0>
		<br />No suborder for #i#
	<cfelseif #s.recordcount# is 1>
		<cfquery name="uo" datasource="#Application.uam_dbo#">
			update taxonomy set suborder='#s.suborder#'
			where family = '#i#'
		</cfquery>
		<br />#i# suborder = #s.suborder#
	<cfelse>
		<br />Multiple suborder for #i#:
			<blockquote>
			<cfloop query="s">
				<br />#suborder#
			</cfloop>
			</blockquote>
	</cfif>
</cfloop>
</cfoutput>