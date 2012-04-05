<cfinclude template="/includes/_header.cfm">
<cfset title="Magic Taxonomy Thingee II">
<a href="sqlTaxonomy.cfm">[new search]</a><br>
<cfif action is "nothing">
	<script src="/includes/jquery/jquery-autocomplete/jquery.autocomplete.pack.js" language="javascript" type="text/javascript"></script>
<script type="text/javascript" language="javascript">
	jQuery(document).ready(function() {
		jQuery("#phylclass").autocomplete("/ajax/phylclass.cfm", {
			width: 320,
			max: 50,
			autofill: false,
			multiple: false,
			scroll: true,
			scrollHeight: 300,
			matchContains: true,
			minChars: 1,
			selectFirst:false
		});
		jQuery("#kingdom").autocomplete("/ajax/kingdom.cfm", {
			width: 320,
			max: 50,
			autofill: false,
			multiple: false,
			scroll: true,
			scrollHeight: 300,
			matchContains: true,
			minChars: 1,
			selectFirst:false
		});
		jQuery("#phylum").autocomplete("/ajax/phylum.cfm", {
			width: 320,
			max: 50,
			autofill: false,
			multiple: false,
			scroll: true,
			scrollHeight: 300,
			matchContains: true,
			minChars: 1,
			selectFirst:false
		});
		jQuery("#phylorder").autocomplete("/ajax/phylorder.cfm", {
			width: 320,
			max: 50,
			autofill: false,
			multiple: false,
			scroll: true,
			scrollHeight: 300,
			matchContains: true,
			minChars: 1,
			selectFirst:false
		});
		jQuery("#family").autocomplete("/ajax/family.cfm", {
			width: 320,
			max: 50,
			autofill: false,
			multiple: false,
			scroll: true,
			scrollHeight: 300,
			matchContains: true,
			minChars: 1,
			selectFirst:false
		});
	});
</script>
<cfquery name="CTTAXONOMIC_AUTHORITY" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select source_authority from CTTAXONOMIC_AUTHORITY order by source_authority
</cfquery>
<cfquery name="ctnomenclatural_code" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select nomenclatural_code from ctnomenclatural_code order by nomenclatural_code
</cfquery>

<cfquery name="cttaxon_status" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select taxon_status from cttaxon_status order by taxon_status
</cfquery>
<cfquery name="ctinfraspecific_rank" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select infraspecific_rank from ctinfraspecific_rank order by infraspecific_rank
</cfquery>
	Find taxa
	<br>Default is case-insensitive substring match.
	<br>Leave blank to ignore
	<br>Use prefix = to find exact case-insensitive match. 
	<strong>=Somename</strong> finds 
	<strong>Somename</strong>
	and <strong>somename</strong> but not 
	<strong>partofSomeName</strong> and not 
	<strong>SomeNamepart</strong>.
	<br><strong>NULL</strong> finds IS NULL values.
	<p>&nbsp;</p>
	<cfoutput>
	<form name="srch" method="post" action="sqlTaxonomy.cfm">
		<input type="hidden" name="action" value="findem">
		<label for="TAXON_NAME_ID">TAXON_NAME_ID (comma-list OK)</label>
		<input name="TAXON_NAME_ID" id="TAXON_NAME_ID" type="text">
		<label for="kingdom">kingdom</label>
		<input name="kingdom" id="kingdom" type="text">
		<label for="phylum">phylum</label>
		<input name="phylum" id="phylum" type="text">
		<label for="phylclass">phylclass</label>
		<input name="phylclass" id="phylclass" type="text">
		<label for="subclass">subclass</label>
		<input name="subclass" id="subclass" type="text">
		<label for="phylorder">phylorder</label>
		<input name="phylorder" id="phylorder" type="text">
		<label for="SUBORDER">SUBORDER</label>
		<input name="SUBORDER" id="SUBORDER" type="text">
		<label for="superfamily">superfamily</label>
		<input name="superfamily" id="superfamily" type="text">
		<label for="family">family</label>
		<input name="family" id="family" type="text">
		<label for="subfamily">subfamily</label>
		<input name="subfamily" id="subfamily" type="text">
		<label for="TRIBE">TRIBE</label>
		<input name="TRIBE" id="TRIBE" type="text">
		<label for="GENUS">GENUS</label>
		<input name="GENUS" id="GENUS" type="text">
		<label for="SUBGENUS">SUBGENUS</label>
		<input name="SUBGENUS" id="SUBGENUS" type="text">
		<label for="SPECIES">SPECIES</label>
		<input name="SPECIES" id="SPECIES" type="text">
		<label for="INFRASPECIFIC_RANK">INFRASPECIFIC_RANK</label>
		<select name="infraspecific_rank" id="infraspecific_rank" size="1">
			<option></option>
			<option value="NULL">NULL</option>
			<cfloop query="ctinfraspecific_rank">
				<option value="#infraspecific_rank#">#infraspecific_rank#</option>
			</cfloop>
		</select>
		<label for="SUBSPECIES">SUBSPECIES</label>
		<input name="SUBSPECIES" id="SUBSPECIES" type="text">
		<label for="VALID_CATALOG_TERM_FG">VALID_CATALOG_TERM_FG</label>
		<select name="VALID_CATALOG_TERM_FG" id="VALID_CATALOG_TERM_FG" size="1">
			<option></option>
			<option value="1">1</option>
			<option value="0">0</option>
		</select>
		<label for="AUTHOR_TEXT">AUTHOR_TEXT</label>
		<input name="AUTHOR_TEXT" id="AUTHOR_TEXT" type="text">
		<label for="SOURCE_AUTHORITY">SOURCE_AUTHORITY</label>
		<select name="source_authority" id="source_authority" size="1">
			<option></option>
			<cfloop query="CTTAXONOMIC_AUTHORITY">
				<option value="#source_authority#">#source_authority#</option>
			</cfloop>
		</select>
		<label for="nomenclatural_code">nomenclatural_code</label>
		<select name="nomenclatural_code" id="nomenclatural_code" size="1">
			<option></option>
			<cfloop query="ctnomenclatural_code">
				<option value="#nomenclatural_code#">#nomenclatural_code#</option>
			</cfloop>
		</select>
		<label for="taxon_status">taxon_status</label>
		<select name="taxon_status" id="taxon_status" size="1">
			<option></option>
			<option value="NULL">NULL</option>
			<cfloop query="cttaxon_status">
				<option value="#taxon_status#">#taxon_status#</option>
			</cfloop>
		</select>	
		<br><input type="submit" value="find names">
		<input type="reset" value="clear form">
	</form>
	</cfoutput>
	</cfif>		
<cfif action is "findem">
<script src="/includes/sorttable.js"></script>
	<cfoutput>
		<cfset sql="select * from taxonomy where 1=1">
		<cfif len(TAXON_NAME_ID) gt 0>
			<cfset sql=sql & " and TAXON_NAME_ID IN ( #TAXON_NAME_ID# )">
		</cfif>
		
		
		<cfif isdefined("kingdom") AND len(kingdom) gt 0>
			<cfif left(kingdom,1) is "=">
				<CFSET SQL = "#SQL# AND upper(kingdom) = '#ucase(right(kingdom,len(kingdom)-1))#'">
			<cfelseif kingdom is "NULL">
				<CFSET SQL = "#SQL# AND kingdom is null">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(kingdom) LIKE '%#ucase(kingdom)#%'">
			</cfif>
		</cfif>
		<cfif isdefined("phylum") AND len(phylum) gt 0>
			<cfif left(phylum,1) is "=">
				<CFSET SQL = "#SQL# AND upper(phylum) = '#ucase(right(phylum,len(phylum)-1))#'">
			<cfelseif phylum is "NULL">
				<CFSET SQL = "#SQL# AND phylum is null">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(phylum) LIKE '%#ucase(phylum)#%'">
			</cfif>
		</cfif>
		<cfif isdefined("phylclass") AND len(phylclass) gt 0>
			<cfif left(phylclass,1) is "=">
				<CFSET SQL = "#SQL# AND upper(phylclass) = '#ucase(right(phylclass,len(phylclass)-1))#'">
			<cfelseif phylclass is "NULL">
				<CFSET SQL = "#SQL# AND phylclass is null">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(phylclass) LIKE '%#ucase(phylclass)#%'">
			</cfif>
		</cfif>
		<cfif isdefined("subclass") AND len(subclass) gt 0>
			<cfif left(subclass,1) is "=">
				<CFSET SQL = "#SQL# AND upper(subclass) = '#ucase(right(subclass,len(subclass)-1))#'">
			<cfelseif subclass is "NULL">
				<CFSET SQL = "#SQL# AND subclass is null">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(subclass) LIKE '%#ucase(subclass)#%'">
			</cfif>
		</cfif>
		<cfif isdefined("phylorder") AND len(phylorder) gt 0>
			<cfif left(phylorder,1) is "=">
				<CFSET SQL = "#SQL# AND upper(phylorder) = '#ucase(right(phylorder,len(phylorder)-1))#'">
			<cfelseif phylorder is "NULL">
				<CFSET SQL = "#SQL# AND phylorder is null">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(phylorder) LIKE '%#ucase(phylorder)#%'">
			</cfif>
		</cfif>
		<cfif isdefined("SUBORDER") AND len(SUBORDER) gt 0>
			<cfif left(SUBORDER,1) is "=">
				<CFSET SQL = "#SQL# AND upper(SUBORDER) = '#ucase(right(SUBORDER,len(SUBORDER)-1))#'">
			<cfelseif SUBORDER is "NULL">
				<CFSET SQL = "#SQL# AND SUBORDER is null">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(SUBORDER) LIKE '%#ucase(SUBORDER)#%'">
			</cfif>
		</cfif>
		<cfif isdefined("superfamily") AND len(superfamily) gt 0>
			<cfif left(superfamily,1) is "=">
				<CFSET SQL = "#SQL# AND upper(superfamily) = '#ucase(right(superfamily,len(superfamily)-1))#'">
			<cfelseif superfamily is "NULL">
				<CFSET SQL = "#SQL# AND superfamily is null">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(superfamily) LIKE '%#ucase(superfamily)#%'">
			</cfif>
		</cfif>
		<cfif isdefined("FAMILY") AND len(FAMILY) gt 0>
			<cfif left(FAMILY,1) is "=">
				<CFSET SQL = "#SQL# AND upper(FAMILY) = '#ucase(right(FAMILY,len(FAMILY)-1))#'">
			<cfelseif FAMILY is "NULL">
				<CFSET SQL = "#SQL# AND FAMILY is null">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(FAMILY) LIKE '%#ucase(FAMILY)#%'">
			</cfif>
		</cfif>
		<cfif isdefined("SUBFAMILY") AND len(SUBFAMILY) gt 0>
			<cfif left(SUBFAMILY,1) is "=">
				<CFSET SQL = "#SQL# AND upper(SUBFAMILY) = '#ucase(right(SUBFAMILY,len(SUBFAMILY)-1))#'">
			<cfelseif SUBFAMILY is "NULL">
				<CFSET SQL = "#SQL# AND SUBFAMILY is null">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(SUBFAMILY) LIKE '%#ucase(SUBFAMILY)#%'">
			</cfif>
		</cfif>
		<cfif isdefined("TRIBE") AND len(TRIBE) gt 0>
			<cfif left(TRIBE,1) is "=">
				<CFSET SQL = "#SQL# AND upper(TRIBE) = '#ucase(right(TRIBE,len(TRIBE)-1))#'">
			<cfelseif TRIBE is "NULL">
				<CFSET SQL = "#SQL# AND TRIBE is null">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(TRIBE) LIKE '%#ucase(TRIBE)#%'">
			</cfif>
		</cfif>
		<cfif isdefined("GENUS") AND len(GENUS) gt 0>
			<cfif left(GENUS,1) is "=">
				<CFSET SQL = "#SQL# AND upper(GENUS) = '#ucase(right(GENUS,len(GENUS)-1))#'">
			<cfelseif GENUS is "NULL">
				<CFSET SQL = "#SQL# AND GENUS is null">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(GENUS) LIKE '%#ucase(GENUS)#%'">
			</cfif>
		</cfif>
		<cfif isdefined("SUBGENUS") AND len(SUBGENUS) gt 0>
			<cfif left(SUBGENUS,1) is "=">
				<CFSET SQL = "#SQL# AND upper(SUBGENUS) = '#ucase(right(SUBGENUS,len(SUBGENUS)-1))#'">
			<cfelseif SUBGENUS is "NULL">
				<CFSET SQL = "#SQL# AND SUBGENUS is null">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(SUBGENUS) LIKE '%#ucase(SUBGENUS)#%'">
			</cfif>
		</cfif>
		<cfif isdefined("SPECIES") AND len(SPECIES) gt 0>
			<cfif left(SPECIES,1) is "=">
				<CFSET SQL = "#SQL# AND upper(SPECIES) = '#ucase(right(SPECIES,len(SPECIES)-1))#'">
			<cfelseif GENUS is "NULL">
				<CFSET SQL = "#SQL# AND SPECIES is null">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(SPECIES) LIKE '%#ucase(SPECIES)#%'">
			</cfif>
		</cfif>
		<cfif isdefined("INFRASPECIFIC_RANK") AND len(INFRASPECIFIC_RANK) gt 0>
			<cfif left(INFRASPECIFIC_RANK,1) is "=">
				<CFSET SQL = "#SQL# AND upper(INFRASPECIFIC_RANK) = '#ucase(right(INFRASPECIFIC_RANK,len(INFRASPECIFIC_RANK)-1))#'">
			<cfelseif INFRASPECIFIC_RANK is "NULL">
				<CFSET SQL = "#SQL# AND INFRASPECIFIC_RANK is null">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(INFRASPECIFIC_RANK) LIKE '%#ucase(INFRASPECIFIC_RANK)#%'">
			</cfif>
		</cfif>
		<cfif isdefined("SUBSPECIES") AND len(SUBSPECIES) gt 0>
			<cfif left(SUBSPECIES,1) is "=">
				<CFSET SQL = "#SQL# AND upper(SUBSPECIES) = '#ucase(right(SUBSPECIES,len(SUBSPECIES)-1))#'">
			<cfelseif SUBSPECIES is "NULL">
				<CFSET SQL = "#SQL# AND SUBSPECIES is null">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(SUBSPECIES) LIKE '%#ucase(SUBSPECIES)#%'">
			</cfif>
		</cfif>		
		<cfif isdefined("SOURCE_AUTHORITY") AND len(SOURCE_AUTHORITY) gt 0>
			<CFSET SQL = "#SQL# AND SOURCE_AUTHORITY = '#SOURCE_AUTHORITY#'">
		</cfif>		
		<cfif isdefined("taxon_status") AND len(taxon_status) gt 0>
			<cfif taxon_status is "NULL">
				<CFSET SQL = "#SQL# AND taxon_status is null">
			<cfelse>
				<CFSET SQL = "#SQL# AND taxon_status = '#taxon_status#'">
			</cfif>
		</cfif>
		<cfif isdefined("AUTHOR_TEXT") AND len(AUTHOR_TEXT) gt 0>
			<cfif left(AUTHOR_TEXT,1) is "=">
				<CFSET SQL = "#SQL# AND upper(AUTHOR_TEXT) = '#ucase(right(AUTHOR_TEXT,len(AUTHOR_TEXT)-1))#'">
			<cfelseif AUTHOR_TEXT is "NULL">
				<CFSET SQL = "#SQL# AND AUTHOR_TEXT is null">
			<cfelse>
				<CFSET SQL = "#SQL# AND upper(AUTHOR_TEXT) LIKE '%#ucase(AUTHOR_TEXT)#%'">
			</cfif>
		</cfif>
		<cfif isdefined("VALID_CATALOG_TERM_FG") AND len(VALID_CATALOG_TERM_FG) gt 0>
			<CFSET SQL = "#SQL# AND VALID_CATALOG_TERM_FG = #VALID_CATALOG_TERM_FG#">
		</cfif>
		<cfif isdefined("nomenclatural_code") AND len(nomenclatural_code) gt 0>
			<CFSET SQL = "#SQL# AND nomenclatural_code = '#nomenclatural_code#'">
		</cfif>
		<CFSET SQL = "#SQL# and rownum < 1000">
		<p><strong>CHECK THIS SQL BEFORE YOU DO ANYTHING ELSE!!!!!!!!!!!!!</strong></p>
		<hr>#sql#<hr>
		<cfquery name="getData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			#preservesinglequotes(sql)#			
		</cfquery>
		<strong>Found #getData.recordcount# records.</strong>
		<br>
		Click headers to sort.
		<cfif getData.recordcount is 999>
			That usually means you're not seeing everything, so you can't use this form. Try finding a smaller dataset.
			<cfabort>
		</cfif>
		<table id="t" class="sortable" border="1">
			<tr>
				<th>kingdom</th>
				<th>phylum</th>
				<th>phylclass</th>
				<th>SUBCLASS</th>
				<th>phylorder</th>
				<th>SUBORDER</th>
				<th>SUPERFAMILY</th>
				<th>FAMILY</th>
				<th>SUBFAMILY</th>
				<th>TRIBE</th>
				<th>GENUS</th>
				<th>SUBGENUS</th>
				<th>SPECIES</th>
				<th>INFRASPECIFIC_RANK</th>
				<th>SUBSPECIES</th>
				<th>VALID_CATALOG_TERM_FG</th>
				<th>AUTHOR_TEXT</th>
				<th>SOURCE_AUTHORITY</th>
				<th>TAXON_REMARKS</th>
				<th>SCIENTIFIC_NAME</th>				
				<th>nomenclatural_code</th>			
				<th>taxon_status</th>
			</tr>
		<cfloop query="getData">
			<tr>
				<td>#kingdom#</td>
				<td>#phylum#</td>
				<td>#phylclass#</td>
				<td>#SUBCLASS#</td>
				<td>#phylorder#</td>
				<td>#SUBORDER#</td>
				<td>#SUPERFAMILY#</td>
				<td>#FAMILY#</td>
				<td>#SUBFAMILY#</td>
				<td>#TRIBE#</td>
				<td>#GENUS#</td>
				<td>#SUBGENUS#</td>
				<td>#SPECIES#</td>
				<td>#INFRASPECIFIC_RANK#</td>
				<td>#SUBSPECIES#</td>
				<td>#VALID_CATALOG_TERM_FG#</td>
				<td>#AUTHOR_TEXT#</td>
				<td>#SOURCE_AUTHORITY#</td>
				<td>#TAXON_REMARKS#</td>
				<td><a href="/name/#SCIENTIFIC_NAME#">#SCIENTIFIC_NAME#</a></td>
				<td>#nomenclatural_code#</td>
				<td>#taxon_status#</td>
			</tr>
		</cfloop>
		</table>
		<cfif getData.recordcount gt 0>
			<cfset upList = "kingdom,phylum,phylclass,SUBCLASS,phylorder,SUBORDER,SUPERFAMILY,FAMILY,subfamily,TRIBE,GENUS,SUBGENUS,SPECIES,INFRASPECIFIC_RANK,SUBSPECIES,VALID_CATALOG_TERM_FG,SOURCE_AUTHORITY,AUTHOR_TEXT,TAXON_REMARKS,nomenclatural_code,taxon_status">
			<hr>
			Use this form to update all records in the table above.
			<br>Update is exact match including nonprinting characters.
			<br>Update will TRY for each record. It is possible to update only SOME of the records in the table above,
			and for the update to fail for others.
			<br>Be paranoid. Srsly.
			<form name="buildIt" method="post" action="sqlTaxonomy.cfm">
				<input type="hidden" name="action" value="update">
				<input type="hidden" name="taxonnameidlist" value="#valuelist(getData.taxon_name_id)#">
				<br>For everything in the table above:<br><strong>UPDATE taxonomy SET</strong>
				<select name="upFld" id="upFld" size="1">
				<cfloop list="#upList#" index="f">
					<option value="#f#">#f#</option>
				</cfloop>
				</select>
				<strong>=</strong>
				<input type="text" name="upTo" id="upTo">
			<br><input type="submit" value="Make Changes">
			</form>
		</cfif>
	</cfoutput>
</cfif>
<cfif action is "update">
	<cfoutput>
		<cfset goodIdList="">
		<cfset badIdList="">
		<cfloop list="#taxonnameidlist#" index="i">
			<cftry>
				<cfquery name="upTax" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update taxonomy set #upFld# =  '#upTo#' where taxon_name_id = #i#
				</cfquery>
				<br>update taxonomy set #upFld# =  '#upTo#' where taxon_name_id = #i#: success!
				<cfset goodIdList=listappend(goodIdList,i)>
			<cfcatch>
				<div style="border:3px solid red;">
				<br>update taxonomy set #upFld# =  '#upTo#' where taxon_name_id = #i#:FAIL!
				<br>#cfcatch.message#: #cfcatch.detail#
				<br><a href="/Taxonomy.cfm?Action=edit&taxon_name_id=#i#" target="_blank">[ edit taxonomy ]</a> (new window)
				<cfset badIdList=listappend(badIdList,i)>
				</div>
			</cfcatch>
			</cftry>
			<hr>
		</cfloop>
		
		<form name="all" method="post" action="sqlTaxonomy.cfm">
			<input type="hidden" name="action" value="findem">
			<input type="hidden" name="taxon_name_id" value="#taxonnameidlist#">
		<br><input type="submit" value=" [ return to taxon table ] ">
		</form>
		<form name="good" method="post" action="sqlTaxonomy.cfm">
			<input type="hidden" name="action" value="findem">
			<input type="hidden" name="taxon_name_id" value="#goodIdList#">
		<br><input type="submit" value=" [ SQLTaxonomy all SUCCESSFUL UPDATES ] ">
		</form>
		<form name="bad" method="post" action="sqlTaxonomy.cfm">
			<input type="hidden" name="action" value="findem">
			<input type="hidden" name="taxon_name_id" value="#badIdList#">
		<br><input type="submit" value=" [ SQLTaxonomy all FAILED UPDATES ] ">
		</form>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">