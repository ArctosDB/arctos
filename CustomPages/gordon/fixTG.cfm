
Whoa, big fella....
<cfabort>

<cfoutput>
HI
<cfquery name="md" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
 select taxon_name_id, scientific_name, phylclass, phylorder, family, genus from taxonomy where
 (phylclass is null or phylorder is null or family is null and genus is not null) and TAXON_NAME_ID > 0 order by scientific_name
</cfquery>
<table border>
	<tr>
		<td>Scientific Name</td>
		<td>Class</td>
		<td>Order</td>
		<td>Family</td>
		<td>Genus</td>
	</tr>
	<cfloop query="md">
		<tr>
			
			<td>
			<a href="http://arctos.database.museum/Taxonomy.cfm?Action=edit&taxon_name_id=#taxon_name_id#">#scientific_name#</a>
			</td>
			<td>#phylclass#</td>
			<td>#phylorder#</td>
			<td>#family#</td>
			<td>#genus#</td>
			<td>
				<cfif len(#phylclass#) is 0>
					<cfquery name="pc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						select distinct(phylclass) from taxonomy where genus='#genus#'
						and phylclass is not null
					</cfquery>
					<cfif #pc.recordcount# is 1>
						<cfquery name="u" datasource="#uam_dbo#">
							UPDATE taxonomy SET phylclass = '#pc.phylclass#' where taxon_name_id=#taxon_name_id#
						</cfquery>
						<font color="##00FF00">1<br>
						#pc.phylclass#</font>
					<cfelseif #pc.recordcount# is 0>
						<font color="##FFFF00">nada</font>					
						<cfelse>
						many<br><cfloop query="pc">
							<font color="##FF0000">#phylclass#<br>
							</font>						
						</cfloop>
					</cfif>
				<cfelse>
					already got one....
				</cfif>
			</td>
			<td>
				<cfif len(#phylorder#) is 0>
					<cfquery name="po" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						select distinct(phylorder) from taxonomy where genus='#genus#'
						and phylorder is not null
					</cfquery>
					
					<cfif #po.recordcount# is 1>
						<cfquery name="u" datasource="#uam_dbo#">
							UPDATE taxonomy SET phylorder = '#po.phylorder#' where taxon_name_id=#taxon_name_id#
						</cfquery>
						<font color="##00FF00">1<br>
						#po.phylorder#</font>
					<cfelseif #po.recordcount# is 0>
						<font color="##FFFF00">nada</font>					
						<cfelse>
						many<br><cfloop query="po">
							<font color="##FF0000">#phylorder#<br>
							</font>						
						</cfloop>
					</cfif>
				<cfelse>
					already got one....
				</cfif>
			</td>
			<td>
				<cfif len(#family#) is 0>
					<cfquery name="f" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						select distinct(family) from taxonomy where genus='#genus#'
						and family is not null
					</cfquery>
					<cfif #f.recordcount# is 1>
						<cfquery name="u" datasource="#uam_dbo#">
							UPDATE taxonomy SET family = '#f.family#' where taxon_name_id=#taxon_name_id#
						</cfquery>
						1<font color="##00FF00"><br>
						#f.family#</font>
					<cfelseif #f.recordcount# is 0>
						<font color="##FFFF00">nada</font>					
						<cfelse>
						many<br><cfloop query="f">
							<font color="##FF0000">#family#<br>
							</font>						
						</cfloop>
					</cfif>
				<cfelse>
					already got one....
				</cfif>
			</td>
		</tr>
	</cfloop>
</table>
</cfoutput>