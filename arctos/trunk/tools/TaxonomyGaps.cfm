<cfinclude template="/includes/_header.cfm">
<cfif not isdefined("limit")>
	<cfset limit=2000>
</cfif>

<cfif action is "nothing">
	<cfoutput>
		
		<form name="cf" method="get" action="TaxonomyGaps.cfm">
			<label for="action">Action</label>
			<select name="action" id="action">
				<option <cfif action is "gap"> selected="selected" </cfif> 
					value="gap">NULL class, order, or family</option>
				<option <cfif action is "funkyChar"> selected="selected" </cfif> 
					value="funkyChar">scientific name contains funky characters</option>
			</select>
			<label for="limit">Row Limit</label>
			<select name="limit" id="limit">
				<option <cfif limit is 1000> selected="selected" </cfif> 
					value="1000">1000</option>
				<option <cfif limit is 2000> selected="selected" </cfif> 
					value="2000">2000</option>
				<option <cfif limit is 5000> selected="selected" </cfif> 
					value="5000">5000</option>					
				<option <cfif limit is 10000> selected="selected" </cfif> 
					value="10000">10000</option>
			</select>
			<br><input type="submit" value="Go">
		</form>
		
		Note: This form will return a maximum of #limit# records.
		<br><a href="TaxonomyGaps.cfm?action=gap">NULL class, order, or family</a>
		<br><a href="TaxonomyGaps.cfm?action=funkyChar">scientific name contains funky characters</a>
	</cfoutput>
</cfif>

<!------------------------------------------------------------------->
<cfif action is "funkyChar">
	<cfoutput>

		<cfquery name="ctINFRASPECIFIC_RANK" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select INFRASPECIFIC_RANK from ctINFRASPECIFIC_RANK
		</cfquery>
		<hr> Showing the top #limit# records which have characters other than:
		<ul>
			<li>A-Za-z (upper or lower case Roman characters)</li>
			<li>[a-z]-[a-z] (lower-case character followed by a dash followed by another lower-case character)</li>
			<li>&##215; (hybrid or multiplication character)</li>
			<li>
				Values in ctinfraspecific_rank
				<ul>
					<cfloop query="ctINFRASPECIFIC_RANK">
						<li>#INFRASPECIFIC_RANK#</li>
					</cfloop>
				</ul>
			</li>
		</ul>
		Note: Combinations are goofy. Some records which have >1 excluded characters show up here anyway. 
		"Orchis &##215; semisaccata nothosubsp. murgiana" was valid as of this writing, but still makes the list. Ignore it.
		<cfquery name="md" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
				taxonomy.taxon_name_id,
				regexp_replace(scientific_name, '([^a-zA-Z ])','<b>\1</b>') craps,
				count(identification_taxonomy.identification_id) used
			from 
				taxonomy,
				identification_taxonomy
			where 
				taxonomy.taxon_name_id=identification_taxonomy.taxon_name_id (+) and
				<cfloop query="ctINFRASPECIFIC_RANK">
					regexp_like(regexp_replace(regexp_replace(scientific_name, ' #INFRASPECIFIC_RANK# ', ''),'[a-z]-[a-z]',''), '[^A-Za-z ]') and 
				</cfloop>
				regexp_like(regexp_replace(regexp_replace(scientific_name, chr(50071), ''),'[a-z]-[a-z]',''), '[^A-Za-z ]') and 
				rownum < #limit#
			group by
				taxonomy.taxon_name_id,
				scientific_name
			order by scientific_name
		</cfquery>
		<table border>
			<tr>
				<td>Scientific Name</td>
				<td>NumIds</td>
			</tr>
			<cfloop query="md">
				<tr>
					<td>
					<a href="#Application.ServerRootUrl#/Taxonomy.cfm?Action=edit&taxon_name_id=#taxon_name_id#">#craps#</a>
					</td>
					<td>#used#</td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------->
<cfif action is "gap">
	<cfoutput>
		<cfquery name="md" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			 select taxon_name_id, scientific_name, phylclass, phylorder, family from taxonomy where
			 (phylclass is null or phylorder is null or family is null)
			and rownum < #limit#
			order by scientific_name
		</cfquery>
		<table border>
			<tr>
				<td>Scientific Name</td>
				<td>Class</td>
				<td>Order</td>
				<td>Family</td>
			</tr>
			<cfloop query="md">
				<tr>
					<td>
					<a href="#Application.ServerRootUrl#/Taxonomy.cfm?Action=edit&taxon_name_id=#taxon_name_id#">#scientific_name#</a>
					</td>
					<td>#phylclass#</td>
					<td>#phylorder#</td>
					<td>#family#</td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">