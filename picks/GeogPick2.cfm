<cfinclude template="/includes/_pickHeader.cfm">
<!----
	edit: griddy: https://github.com/ArctosDB/arctos/issues/1786
--->
<cfset title = "Pick Higher Geog">
<cfif not isdefined("srchstring") or srchstring is "undefined">
	<cfset srchstring="">
</cfif>
<cfset any_geog=srchstring>
<cfoutput>
	<script>
		function useGeo(geog_auth_rec_id,higher_geog){
			opener.document.#formName#.#geogIdFld#.value=geog_auth_rec_id;
			opener.document.#formName#.#highGeogFld#.value=higher_geog;
			self.close();
		}

	</script>
<b>Find Geography:</b>
  <table border="1">
    <form id="gsfrm" name="getHG" method="post" action="GeogPick2.cfm">
      <input type="hidden" name="Action" value="findGeog">
      <input type="hidden" name="geogIdFld" value="#geogIdFld#">
      <input type="hidden" name="highGeogFld" value="#highGeogFld#">
      <input type="hidden" name="formName" value="#formName#">
      <cfinclude template="/includes/frmFindLocation_guts.cfm">
    </form>
</cfoutput>
<!-------------------------------------------------------------------->
<style>
	.haspoly{font-size:larger;font-weight:bolder}

</style>
<cf_findLocality type="geog">

<cfquery name="localityResults" dbtype="query">
	select
	 	CONTINENT_OCEAN,
	 	COUNTRY,
	 	COUNTY,
	 	DRAINAGE,
	 	FEATURE,
	 	GEOG_AUTH_REC_ID,
	 	GEOG_REMARK,
	 	HAS_GEO_POLY,
	 	HIGHER_GEOG,
	 	ISLAND,
	 	ISLAND_GROUP,
	 	QUAD,
	 	SEA,
	 	SOURCE_AUTHORITY,
	 	STATE_PROV
	from localityResults
	group by
		CONTINENT_OCEAN,
	 	COUNTRY,
	 	COUNTY,
	 	DRAINAGE,
	 	FEATURE,
	 	GEOG_AUTH_REC_ID,
	 	GEOG_REMARK,
	 	HAS_GEO_POLY,
	 	HIGHER_GEOG,
	 	ISLAND,
	 	ISLAND_GROUP,
	 	QUAD,
	 	SEA,
	 	SOURCE_AUTHORITY,
	 	STATE_PROV
	order by higher_geog
</cfquery>
<table border>
	<tr>
		<th>Select</th>
		<th>Higher Geog</th>
		<th>Has WKT?</th>
		<th>Continent/Ocean</th>
		<th>Sea</th>
		<th>Country</th>
		<th>State/Province</th>
		<th>County</th>
		<th>Quad</th>
		<th>Feature</th>
		<th>Drainage</th>
		<th>Island</th>
		<th>IslandGroup</th>
		<th>Remark</th>
		<th>Source</th>
		<th>SearchTerms</th>
	</tr>
<cfoutput query="localityResults">
	<tr <cfif has_geo_poly is "YES">class="haspoly"</cfif> >
		<td>
			<a href="##" onClick="useGeo('#geog_auth_rec_id#','#replace(higher_geog,"'","\'","all")#');">use</a>
		</td>
		<td>
		 	#higher_geog#
		</td>
		<td>
			#has_geo_poly#
		</td>
		<td>#CONTINENT_OCEAN#</td>
		<td>#SEA#</td>
		<td>#COUNTRY#</td>
		<td>#STATE_PROV#</td>
		<td>#COUNTY#</td>
		<td>#QUAD#</td>
		<td>#FEATURE#</td>
		<td>#DRAINAGE#</td>
		<td>#ISLAND#</td>
		<td>#ISLAND_GROUP#</td>
		<td>#GEOG_REMARK#</td>
		<td>
			<cfif left(SOURCE_AUTHORITY,4) is 'http'>
				<a href="#SOURCE_AUTHORITY#" target="_blank" class="external">#SOURCE_AUTHORITY#</a>
			<cfelse>
				#SOURCE_AUTHORITY#
			</cfif>
		</td>
		<td>
			<cfquery name="searchterm" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
				select SEARCH_TERM from geog_search_term where geog_auth_rec_id=#geog_auth_rec_id# order by SEARCH_TERM
			</cfquery>
			<cfloop query="searchterm">
				<div style="font-size:small;margin-left:1em;">
					#SEARCH_TERM#
				</div>
			</cfloop>
		</td>
	</tr>
</cfoutput>
</table>
<cfinclude template="/includes/_pickFooter.cfm">