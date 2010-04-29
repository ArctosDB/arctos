<cfoutput>
		<cfquery name="t" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select * from taxonomy where taxon_name_id=#taxon_name_id#
		</cfquery>
		<cfif len(t.species) gt 0 and len(t.genus) gt 0>
			<cfif len(t.subspecies) gt 0>
				<cfquery name="ssp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
					select scientific_name,display_name from taxonomy where genus='#t.genus#' and species='#t.species#' and subspecies is null
				</cfquery>
				<cfif len(ssp.scientific_name) gt 0>
					<p>Parent Species: <a href="/name/#ssp.scientific_name#">#ssp.display_name#</a></p>
				</cfif>
			</cfif>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
				select 
					scientific_name,
					display_name 
				from 
					taxonomy 
				where
					 genus = '#t.genus#' and 
					 species = '#t.species#' and 
					 subspecies is not null and
					 scientific_name != '#t.scientific_name#'
				order by
					scientific_name
			</cfquery>
			<cfif d.recordcount gt 0>
				<br><cfif len(t.subspecies) gt 0>Related </cfif>Subspecies:
			</cfif>
			<ul>
				<cfloop query="d">
					<li><a href="/name/#scientific_name#">#display_name#</a></li>
				</cfloop>
			</ul>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
				select 
					scientific_name,
					display_name 
				from 
					taxonomy 
				where
					 genus = '#t.genus#' and 
					 species != '#t.species#' and
					 subspecies is null
				order by
					scientific_name
			</cfquery>
			<cfif d.recordcount gt 0>
				<br>Related Species:
			</cfif>
			<ul>
				<cfloop query="d">
					<li><a href="/name/#scientific_name#">#display_name#</a></li>
				</cfloop>
			</ul>
		<cfelseif len(t.genus) gt 0 and len(t.species) is 0>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
				select 
					scientific_name,
					display_name 
				from 
					taxonomy 
				where
					 genus = '#t.genus#' and
					 species is not null and
					 subspecies is null
				order by
					scientific_name
			</cfquery>
			<cfif d.recordcount gt 0>
				<br>Species:
			</cfif>
			<ul>
				<cfloop query="d">
					<li><a href="/name/#scientific_name#">#display_name#</a></li>
				</cfloop>
			</ul>
		</cfif>
</cfoutput>