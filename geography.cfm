<cfinclude template="includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
	<cfoutput>
		<cfset title="Find Geography">
		<strong>Find Higher Geography:</strong>
		<form name="getCol" method="post" action="geography.cfm">
		    <input type="hidden" name="Action" value="findGeog">
			<cfinclude template="/includes/frmFindLocation_guts.cfm">
		</form>
	</cfoutput>


<!---------------------------------------------------------------------------------------------------->
<cfset title="Geography Search Results">
<cfoutput>
<cf_findLocality type="geog">
<cfif localityResults.recordcount is 0>
	<cfinclude template="includes/_footer.cfm">
	<cfabort>
</cfif>
<script src="/includes/sorttable.js"></script>
<cfset hasDataFlds="CONTINENT_OCEAN,ISLAND">
<cfloop list="#hasDataFlds#" index="f">
	<br>#f#
	<cfquery name="d" dbtype="query">
		select count(*) c from localityResults where #f# is not null
	</cfquery>
	<cfdump var=#d#>
	<cfif d.c is 0>
		buhbye
		<cfset hasDataFlds=listdeleteat(hasDataFlds,listfind(hasDataFlds,'##'))>
	</cfif>
</cfloop>

<table border id="t" class="sortable">
	<tr>
		<th>Links</th>
		<th>Higher Geog</th>
		<cfif listfind(hasDataFlds,'CONTINENT_OCEAN')>
			<th>Continent</th>
		</cfif>
		<th>Country</th>
		<th>State</th>
		<th>County</th>
		<th>Quad</th>
		<th>Feature</th>
		<th>IslandGroup</th>
		<cfif listfindnocase(hasDataFlds,'Island')>
			<th>Island</th>
		</cfif>

		<th>Sea</th>
		<th>Remark</th>
		<th>SrchTerm</th>
	</tr>
	<cfset i=0>
<cfloop query="localityResults">
<cfset i=i+1>
<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
	<td>
		<div style="border:1px dashed gray; font-size:x-small;">
			<cfif session.roles contains "manage_geography">
				<div>
					<a href="Locality.cfm?Action=editGeog&geog_auth_rec_id=#geog_auth_rec_id#">Edit #geog_auth_rec_id#</a>
				</div>
			</cfif>
			<div>
				<cfif left(SOURCE_AUTHORITY,4) is 'http'>
					<a href="#SOURCE_AUTHORITY#" class="external" target="_blank">#SOURCE_AUTHORITY#</a>
				<cfelse>
					#SOURCE_AUTHORITY#
				</cfif>
			</div>
			<div>
				<a href="/SpecimenResults.cfm?geog_auth_rec_id=#geog_auth_rec_id#">Specimens</a>
			</div>
		</div>
	</td>
	<td>
		<div>#higher_geog#</div>
	</td>
	<cfif listfind(hasDataFlds,'CONTINENT_OCEAN')>
		<a href="geography.cfm?CONTINENT_OCEAN=#CONTINENT_OCEAN#">#CONTINENT_OCEAN#</a>
	</cfif>
	<!----
	<td>
		<cfif len(CONTINENT_OCEAN) gt 0>
		</cfif>
	</td>
	---->
	<td>
		<cfif len(COUNTRY) gt 0>
			<a href="geography.cfm?COUNTRY=#COUNTRY#">#COUNTRY#</a>
		</cfif>
	</td>
	<td>
		<cfif len(STATE_PROV) gt 0>
			<a href="geography.cfm?STATE_PROV=#STATE_PROV#">#STATE_PROV#</a>
		</cfif>
	</td>
	<td>
		<cfif len(COUNTY) gt 0>
			<a href="geography.cfm?COUNTY=#COUNTY#">#COUNTY#</a>
		</cfif>
	</td>
	<td>
		<cfif len(QUAD) gt 0>
			<a href="geography.cfm?QUAD=#QUAD#">#QUAD#</a>
		</cfif>
	</td>
	<td>
		<cfif len(FEATURE) gt 0>
			<a href="geography.cfm?FEATURE=#FEATURE#">#FEATURE#</a>
		</cfif>
	</td>
	<td>
		<cfif len(ISLAND_GROUP) gt 0>
			<a href="geography.cfm?ISLAND_GROUP=#ISLAND_GROUP#">#ISLAND_GROUP#</a>
		</cfif>
	</td>
	<cfif listfind(hasDataFlds,'ISLAND')>
		<td><a href="geography.cfm?ISLAND=#ISLAND#">#ISLAND#</a></td>
	</cfif>
	<!----
	<td>
		<cfif len(ISLAND) gt 0>
			<a href="geography.cfm?ISLAND=#ISLAND#">#ISLAND#</a>
		</cfif>
	</td>
	---->
	<td>
		<cfif len(SEA) gt 0>
			<a href="geography.cfm?SEA=#SEA#">#SEA#</a>
		</cfif>
	</td>
	<td>
		<div style="font-size:x-small;">
			#geog_remark#
		</div>
	</td>
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


<cfinclude template="includes/_footer.cfm">