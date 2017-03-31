<cfquery name="cttaxon_term" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select * from cttaxon_term
</cfquery>
<cfquery name="c" dbtype="query">
	select TAXON_TERM from cttaxon_term where IS_CLASSIFICATION=1 order by RELATIVE_POSITION
</cfquery>
<cfquery name="nc" dbtype="query">
	select TAXON_TERM from cttaxon_term where IS_CLASSIFICATION=0 order by TAXON_TERM
</cfquery>
<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select term,rank from hierarchical_taxonomy where tid=#tid#
</cfquery>
<cfquery name="t" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select nc_tid,term_type,term_value from htax_noclassterm where tid=#tid#
</cfquery>
<cfoutput>
<form>
	[i will be a save button someday]
	<br>
	[ maybe a delete button too.
	<br>but not sure what that could do.
	<br>update {children_of_this} set parent_id={parent_of_this} and then flush the term maybe??
	<br>does that break anything??

	<table border>
		<tr>
			<td>
				Editing <strong>#d.term#</strong>
			</td>
			<td>
				<label for="rank">Rank</label>
				<select name="rank" id="rank">
					<cfloop query="c">
						<option value="#TAXON_TERM#" <cfif c.taxon_term is d.rank> selected="taxon_term" </cfif> >#TAXON_TERM#</option>
					</cfloop>
				</select>
			</td>
		</tr>
	</table>


	<table border>
		<tr>
			<th>Term</th>
			<th>Value</th>
		</tr>
	<cfloop query="t">
		<tr>
			<td>
				<select name="nctermtype_#nc_tid#" id="nctermtype_#nc_tid#">
					<cfloop query="nc">
						<option value="#t.term_type#" <cfif t.term_type is nc.taxon_term> selected="selected" </cfif> >#t.term_type#</option>
					</cfloop>
				</select>
			</td>
			<td><input name="nctermvalue_#nc_tid#" id="nctermvalue_#nc_tid#" type="text" value="#t.term_value#" size="60"></td>
		</tr>
	</cfloop>
	<br>
	<cfloop from="1" to="10" index="i">
		<tr>
			<td>
				<select name="nctermtype_new_#i#" id="nctermtype_new_#i#">
					<option value="">pick to add term-value pair</option>
					<cfloop query="nc">
						<option value="#nc.term_type#">#nc.term_type#</option>
					</cfloop>
				</select>
			</td>
			<td><input name="nctermvalue_new_#i#" id="nctermvalue_new_#i#" type="text" size="60"></td>
		</tr>

	</cfloop>

	</table>

	[wow so many save buttons might be here eventually!]

</form>
</cfoutput>