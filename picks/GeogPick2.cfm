<cfinclude template="/includes/_pickHeader.cfm">
<cfset title = "Pick Higher Geog">
<cfif not isdefined("srchstring") or srchstring is "undefined">
	<cfset srchstring="">
</cfif>
<cfset any_geog=srchstring>
<cfoutput>



	<br>any_geog: #any_geog# -----------
	<script>
		function useGeo(geog_auth_rec_id,higher_geog){
			opener.document.#formName#.#geogIdFld#.value=geog_auth_rec_id;
			opener.document.#formName#.#highGeogFld#.value=higher_geog;
			self.close();
		}






		$(document).ready(function() {
			$("##any_geog").val('#srchstring#');
		});

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

hi here we are


<cf_findLocality type="geog">

now here


<cfquery name="localityResults" dbtype="query">
	select geog_auth_rec_id,higher_geog
	from localityResults
	group by geog_auth_rec_id,higher_geog
</cfquery>
<cfoutput query="localityResults">
	<div>
		<div>
			<a href="##" onClick="useGeo('#geog_auth_rec_id#','#replace(higher_geog,"'","\'","all")#');">#higher_geog#</a>
		</div>
		<cfquery name="searchterm" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select SEARCH_TERM from geog_search_term where geog_auth_rec_id=#geog_auth_rec_id# order by SEARCH_TERM
		</cfquery>
		<cfloop query="searchterm">
			<div style="font-size:small;margin-left:1em;">
				#SEARCH_TERM#
			</div>
		</cfloop>
	</div>
</cfoutput>
<cfinclude template="/includes/_pickFooter.cfm">