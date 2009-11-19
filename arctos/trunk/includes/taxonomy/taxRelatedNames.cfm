<cfinclude template = "/includes/_frameHeader.cfm">
<cfoutput>
		<cfquery name="t" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from taxonomy where taxon_name_id=#taxon_name_id#
		</cfquery>
		<cfif len(t.subspecies) is 0 and len(t.species) gt 0 and len(t.genus) gt 0>
			<cfset desc="Related subspecies">
			<cfset q=" genus = '#t.genus#' and species = '#t.species#'
				and scientific_name != '#t.scientific_name#'">		
		</cfif>
		<cfif isdefined("q")>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
					scientific_name,
					display_name 
				from 
					taxonomy 
				where
					#preservesinglequotes(q)#
			</cfquery>
			<cfif d.recordcount gt 0>
				#desc#:
				<ul>
					<cfloop query="d">
						<li><a href="/name/#scientific_name#">#display_name#</a></li>
					</cfloop>
				</ul>
			</cfif>
		</cfif>
</cfoutput>