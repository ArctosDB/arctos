<cfinclude template="includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfif action is "nothing">
	<cfoutput>
		<cfset title="Find Geography">
		<strong>Find Higher Geography:</strong>
		<form name="getCol" method="post" action="geography.cfm">
		    <input type="hidden" name="Action" value="findGeog">
			<cfinclude template="/includes/frmFindLocation_guts.cfm">
		</form>
	</cfoutput>
</cfif>


<!---------------------------------------------------------------------------------------------------->
<cfif action is "findGeog">
<cfset title="Geography Search Results">
<cfoutput>
	<a href="geography.cfm">search again</a>
<cf_findLocality type="geog">
<script src="/includes/sorttable.js"></script>

<table border id="t" class="sortable">
	<tr>
		<th>Geog ID</th>
		<th>Higher Geog</th>
		<th>Continent</th>
		<th>Country</th>
		<th>State</th>
		<th>County</th>
		<th>Quad</th>
		<th>Feature</th>
		<th>IslandGroup</th>
		<th>Island</th>
		<th>Sea</th>
		<th>Authority</th>
		<th>Remark</th>
		<th>SrchTerm</th>
	</tr>
<cfloop query="localityResults">
<tr>
	<td><a href="Locality.cfm?Action=editGeog&geog_auth_rec_id=#geog_auth_rec_id#">#geog_auth_rec_id#</a></td>
	<td>
		<!--- make this as input that looks like test to make copying easier --->
		<input style="border:none;" value="#higher_geog#" size="80" readonly="yes"/>
	</td>
	<td>#CONTINENT_OCEAN#</td>
	<td>#COUNTRY#</td>
	<td>#STATE_PROV#</td>
	<td>#COUNTY#</td>
	<td>#QUAD#</td>
	<td>#FEATURE#</td>
	<td>#ISLAND_GROUP#</td>
	<td>#ISLAND#</td>
	<td>#SEA#</td>
	<td>
		<cfif left(SOURCE_AUTHORITY,4) is 'http'>
			<a href="#SOURCE_AUTHORITY#" class="external" target="_blank">#SOURCE_AUTHORITY#</a>
		<cfelse>
			#SOURCE_AUTHORITY#
		</cfif>
	</td>
	<td>#geog_remark#</td>
	<cfquery name="searchterm" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select SEARCH_TERM from geog_search_term where geog_auth_rec_id=#geog_auth_rec_id# order by SEARCH_TERM
	</cfquery>
	<td valign="top">
		<cfloop query="searchterm">
			<div style="border:1px dashed gray; font-size:x-small;">
				#SEARCH_TERM#
			</div>
		</cfloop>
	</td>



  </tr>
</cfloop>
</cfoutput>
</table>
</cfif>


<cfinclude template="includes/_footer.cfm">