hello I am hierarchicalTaxonomyEdit.cfm
<cfquery name="cttaxon_term" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select * from cttaxon_term
</cfquery>

UAM@ARCTEST> desc cttaxon_term
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 TAXON_TERM							   NOT NULL VARCHAR2(255)
 DESCRIPTION								    VARCHAR2(4000)
 IS_CLASSIFICATION						   NOT NULL NUMBER
 RELATIVE_POSITION							    NUMBER
 CTTAXON_TERM_ID						   NOT NULL NUMBER

UAM@ARCTEST>


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
	Editing <strong>#d.term#</strong>
	<label for="rank">Rank</label>
	<select name="rank" id="rank">
		<cfloop query="c">
			<option value="#TAXON_TERM#" <cfif c.taxon_term is d.rank> selected="taxon_term" </cfif> >#TAXON_TERM#</option>
		</cfloop>
	</select>
	<cfloop query="t">
		<select name="nctermtype_#nc_tid#" id="nctermtype_#nc_tid#">
			<cfloop query="nc">
				<option value="#term_type#" <cfif t.term_type is nc.taxon_term> selected="selected" </cfif> >#term_type#</option>
			</cfloop>
		</select>
			<input name="nctermvalue_#nc_tid#" id="nctermvalue_#nc_tid#" type="text" value="#t.term_value#">
	</cfloop>
</form>
</cfoutput>

<cfdump var=#d#>

<cfdump var=#t#>