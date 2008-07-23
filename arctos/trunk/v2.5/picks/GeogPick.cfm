<cfinclude template="/includes/_pickHeader.cfm">
<cfset title = "Pick Higher Geog">
<cfoutput>	
<b>Find Geography:</b>	
  <table border="1">
    <form name="getHG" method="post" action="GeogPick.cfm">
      <input type="hidden" name="Action" value="findGeog">
      <input type="hidden" name="geogIdFld" value="#geogIdFld#">
      <input type="hidden" name="highGeogFld" value="#highGeogFld#">
      <input type="hidden" name="formName" value="#formName#">
      <cfinclude template="/includes/frmFindLocation_guts.cfm">
    </form>
</cfoutput>
<!-------------------------------------------------------------------->
<cfif #Action# is "findGeog">
<cf_findLocality>
<cfquery name="localityResults" dbtype="query">
	select geog_auth_rec_id,higher_geog
	from localityResults
	group by geog_auth_rec_id,higher_geog
</cfquery>
<cfoutput query="localityResults">

<p><a href="##" onClick="javascript: opener.document.#formName#.#geogIdFld#.value='#geog_auth_rec_id#';opener.document.#formName#.#highGeogFld#.value='#replace(higher_geog,"'","\'","all")#';self.close();">#higher_geog#</a>

</cfoutput>
</cfif>
<cfinclude template="/includes/_pickFooter.cfm">