<cfinclude template="/includes/_pickHeader.cfm">
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
	select geog_auth_rec_id,higher_geog,has_geo_poly
	from localityResults
	group by geog_auth_rec_id,higher_geog,has_geo_poly
	order by higher_geog
</cfquery>
<table border>
	<tr>
		<th>Higher Geog</th>
		<th>Has WKT?</th>
		<th>SearchTerms</th>
		<th>Select</th>
	</tr>
<cfoutput query="localityResults">
	<tr <cfif has_geo_poly is "YES">class="haspoly"</cfif> >
		<td>
		 	#higher_geog#
		</td>
		<td>
			#has_geo_poly#
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
		<td>
			<a href="##" onClick="useGeo('#geog_auth_rec_id#','#replace(higher_geog,"'","\'","all")#');">use</a>
		</td>
	</tr>
</cfoutput>
</table>
<cfinclude template="/includes/_pickFooter.cfm">