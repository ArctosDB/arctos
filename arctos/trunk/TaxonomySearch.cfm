<cfinclude template = "includes/_header.cfm">
<script src="/includes/jquery/jquery-autocomplete/jquery.autocomplete.pack.js" language="javascript" type="text/javascript"></script>
<cfset title = "Search for Taxonomy">
<cfset metaDesc = "Search Arctos for taxonomy, including accepted, unaccepted, used, and unused names, higher taxonomy, and common names.">
<cfquery name="getCount" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select count(*) as cnt from taxonomy
</cfquery>
<cfquery name="CTTAXONOMIC_AUTHORITY" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select source_authority from CTTAXONOMIC_AUTHORITY order by source_authority
</cfquery>
<cfquery name="ctnomenclatural_code" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select nomenclatural_code from ctnomenclatural_code order by nomenclatural_code
</cfquery>
<cfquery name="cttaxon_status" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select taxon_status from cttaxon_status order by taxon_status
</cfquery>
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
<cfoutput>
<br>
	<form ACTION="TaxonomyResults.cfm" METHOD="post" name="taxa">
		<table width="90%" border="0" cellspacing="0" cellpadding="0">
			<tr> 
				<td valign="top" align="left">
					<table border="0" cellpadding="10" cellspacing="10">
						<tr>
							<td>
								Search the taxonomy used in Arctos for:
								<ul>
									<li>Common names</li>
									<li>Synonymies</li>
									<li>Taxa used for current identifications</li>
									<li>Taxa used as authorities for future identifications</li>
									<li>Taxa used in previous identifications 
										(especially where specimens were cited by a now-unaccepted name).</li>
								</ul>
								<p>
									These #getCount.cnt# records represent current and past taxonomic treatments in Arctos. 
									They are neither complete nor necessarily authoritative. 
								<p>
									Not all taxa in Arctos have associated specimens. 
									<a href="javascript:void(0)" onClick="taxa.we_have_some.checked=false;">Uncheck</a> 
									the "Find only taxa for which specimens exist?" box to see all matches.
							</td>
						</tr>
					</table>
					<table>
						<tr>
							<td>
								<input type="radio" name="VALID_CATALOG_TERM_FG" checked="checked" value="">
							</td>
							<td>
								<a href="javascript:void(0)" onClick="taxa.VALID_CATALOG_TERM_FG[0].checked=true;"><b>Display all matches?</b></a>
							</td>
						</tr>
						<tr>
							<td>
								<input type="radio" name="VALID_CATALOG_TERM_FG" value="1">
							</td>
							<td>
								<a href="javascript:void(0)" onClick="taxa.VALID_CATALOG_TERM_FG[1].checked=true;"><b>Display only taxa currently accepted for identification?</b></a>
							</td>
						</tr>
						<tr>
							<td>
								<input type="checkbox" name="we_have_some" value="1" id="we_have_some">
							</td>
							<td>
								<a href="javascript:void(0)" onClick="taxa.we_have_some.checked=true;"><b>Find only taxa for which specimens exist?</b></a>
								<cfif isdefined("session.username") and #session.username# is "gordon">
									<script type="text/javascript" language="javascript">
										document.getElementById('we_have_some').checked=false;
									</script>
								</cfif>
							</td>
						</tr>
					</table>
				</td>
				<td>
					<table>
						<tr>
							<td colspan="2" align="center" nowrap>
								<input type="submit" value="Search"	class="schBtn">
								&nbsp;&nbsp;
								<input type="reset" value="Clear Form" class="clrBtn">
								<input type="hidden" name="action" value="search">
							</td>
						</tr>
						<tr>
							<td align="right" nowrap>
								<span class="helpLink" id="common_name"><strong>Common&nbsp;Name:</strong></span>
							</td>
							<td nowrap="nowrap"><input size="25" name="common_name" id="common_name" maxlength="50"></td>
						</tr>
						<tr>
							<td align="right">
								<span class="helpLink" id="taxonomy_scientific_name"><strong>Scientific&nbsp;Name:</strong></span>
							</td>
							<td nowrap="nowrap">
								<input size="25" name="scientific_name" id="scientific_name" maxlength="40">
								<span class="infoLink" onclick="var e=document.getElementById('scientific_name');e.value='='+e.value;">
									Add = for exact match
								</span>
							</td>
						</tr>
						<tr>
							<td align="right">
								<span class="helpLink" id="taxonomy_anything"><strong>Any&nbsp;Category:</strong></span>
							</td>
							<td nowrap="nowrap">
								<input size="25" name="full_taxon_name" id="full_taxon_name" maxlength="50">
							</td>
						</tr>
						<tr>
							<td align="right">
								<span class="helpLink" id="author_text"><strong><nobr>Author Text:</nobr></strong></span>
							</td>
							<td nowrap="nowrap"><input size="25" name="author_text" id="author_text" maxlength="40">
								<span class="infoLink" onclick="var e=document.getElementById('author_text');e.value='='+e.value;">
									Add = for exact match
								</span>
							</td>
						</tr>
						<tr>
							<td align="right">
								<span class="helpLink" id="infraspecific_author"><strong><nobr>Infraspecific Author Text:</nobr></strong></span>
							</td>
							<td nowrap="nowrap"><input size="25" name="infraspecific_author" id="infraspecific_author" maxlength="40">
								<span class="infoLink" onclick="var e=document.getElementById('infraspecific_author');e.value='='+e.value;">
									Add = for exact match
								</span>
							</td>
						</tr>
						<tr>
							<td align="right"><b><nobr>Genus:</nobr></b></td>
							<td nowrap="nowrap">
								<input size="25" name="genus" id="genus" maxlength="40">
								<span class="infoLink" onclick="var e=document.getElementById('genus');e.value='='+e.value;">
									Add = for exact match
								</span>
							</td>
						</tr>
						<tr>
							<td align="right"><b><nobr>Species:</nobr></b></td>
							<td nowrap="nowrap">
								<input size="25" name="species" id="species" maxlength="40">
								<span class="infoLink" onclick="var e=document.getElementById('species');e.value='='+e.value;">
									Add = for exact match
								</span>
							</td>
						</tr>
						<tr>
							<td align="right"><b><nobr>Subspecies:</nobr></b></td>
							<td nowrap="nowrap">
								<input size="25" name="subspecies" id="subspecies" maxlength="40">
								<span class="infoLink" onclick="var e=document.getElementById('subspecies');e.value='='+e.value;">
									Add = for exact match
								</span>
							</td>
						</tr>
						<tr>
							<td align="right"><b><nobr>Nomenclatural&nbsp;Code:</nobr></b></td>
							<td nowrap="nowrap">
								<select name="nomenclatural_code" id="nomenclatural_code" size="1">
									<option></option>
									<cfloop query="ctnomenclatural_code">
										<option value="#nomenclatural_code#">#nomenclatural_code#</option>
									</cfloop>
								</select>							
							</td>
						</tr>
						<tr>
							<td align="right"><b><nobr>Kingdom:</nobr></b></td>
							<td nowrap="nowrap">
								<input size="25" name="kingdom" id="kingdom" maxlength="40">
								<span class="infoLink" onclick="var e=document.getElementById('kingdom');e.value='='+e.value;">
									Add = for exact match
								</span>
							</td>
						</tr>
						<tr>
							<td align="right"><b><nobr>Phylum:</nobr></b></td>
							<td nowrap="nowrap">
								<input size="25" name="phylum" id="phylum" maxlength="40">
								<span class="infoLink" onclick="var e=document.getElementById('phylum');e.value='='+e.value;">
									Add = for exact match
								</span>
							</td>
						</tr>
						<!---
						<cfquery name="ctClass" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
							select distinct(phylclass) from taxonomy order by phylclass
						</cfquery>
						---->
						<tr>
							<td align="right"><b><nobr>Class:</nobr></b></td>
							<td nowrap="nowrap">
								<input size="25" name="phylclass" id="phylclass" maxlength="40">
								<span class="infoLink" onclick="var e=document.getElementById('phylclass');e.value='='+e.value;">
									Add = for exact match
								</span>							
							</td>
						</tr>
						<tr>
							<td align="right"><b><nobr>Subclass:</nobr></b></td>
							<td nowrap="nowrap">
								<input size="25" name="subclass" id="subclass" maxlength="40">
								<span class="infoLink" onclick="var e=document.getElementById('subclass');e.value='='+e.value;">
									Add = for exact match
								</span>							
							</td>
						</tr>
						<tr>
							<td align="right"><b><nobr>Order:</nobr></b></td>
							<td nowrap="nowrap">
								<input size="25" name="phylorder" id="phylorder" maxlength="40">
								<span class="infoLink" onclick="var e=document.getElementById('phylorder');e.value='='+e.value;">
									Add = for exact match
								</span>
							</td>
						</tr>
						<tr>
							<td align="right"><b><nobr>Suborder:</nobr></b></td>
							<td nowrap="nowrap">
								<input size="25" name="suborder" id="suborder" maxlength="40">
								<span class="infoLink" onclick="var e=document.getElementById('suborder');e.value='='+e.value;">
									Add = for exact match
								</span>
							</td>
						</tr>
						<tr>
							<td align="right"><b><nobr>Superfamily:</nobr></b></td>
							<td nowrap="nowrap">
								<input size="25" name="superfamily" id="superfamily" maxlength="40">
								<span class="infoLink" onclick="var e=document.getElementById('superfamily');e.value='='+e.value;">
									Add = for exact match
								</span>
							</td>
						</tr>
						<tr>
							<td align="right"><b><nobr>Family:</nobr></b></td>
							<td nowrap="nowrap">
								<input size="25" name="family" id="family" maxlength="40">
								<span class="infoLink" onclick="var e=document.getElementById('family');e.value='='+e.value;">
									Add = for exact match
								</span>
							</td>
						</tr>
						<tr>
							<td  align="right"><b><nobr>Subfamily:</nobr></b></td>
							<td nowrap="nowrap">
								<input size="25" name="subfamily" id="subfamily" maxlength="40">
								<span class="infoLink" onclick="var e=document.getElementById('subfamily');e.value='='+e.value;">
									Add = for exact match
								</span>
							</td>
						</tr>
						<tr>
							<td align="right"><b><nobr>Tribe:</nobr></b></td>
							<td nowrap="nowrap">
								<input size="25" name="tribe" id="tribe" maxlength="40">
								<span class="infoLink" onclick="var e=document.getElementById('tribe');e.value='='+e.value;">
									Add = for exact match
								</span>
							</td>
						</tr>
						<tr>
							<td align="right"><b><nobr>Subgenus:</nobr></b></td>
							<td nowrap="nowrap">
								<input size="25" name="subgenus" id="subgenus" maxlength="40">
								<span class="infoLink" onclick="var e=document.getElementById('subgenus');e.value='='+e.value;">
									Add = for exact match
								</span>
							</td>
						</tr>
						<tr>
							<td align="right">
								<span class="helpLink" id="_source_authority"><strong>Authority:</strong></span>
							</td>
							<td nowrap="nowrap">
								<select name="source_authority" id="source_authority" size="1">
									<option></option>
									<cfloop query="CTTAXONOMIC_AUTHORITY">
										<option value="#source_authority#">#source_authority#</option>
									</cfloop>
								</select>							
							</td>
						</tr>
						<tr>
							<td align="right">
								<span class="helpLink" id="_taxon_status"><strong>Taxon Status:</strong></span>
							</td>
							<td nowrap="nowrap">
								<select name="taxon_status" id="taxon_status" size="1">
									<option></option>
									<cfloop query="cttaxon_status">
										<option value="#taxon_status#">#taxon_status#</option>
									</cfloop>
								</select>							
							</td>
						</tr>
						<tr>
							<td colspan="2" align="center">
								<input type="submit" value="Search" class="schBtn">
								&nbsp;&nbsp;
								<input type="reset" value="Clear Form" class="clrBtn">
								<input type="hidden" name="action" value="search">
								<div style="border:1px dotted green;font-size:small;font-weight:bold;text-align:left;">
								Note: This form will not return >1000 records; 
								you may need to narrow your search to return all relevant matches.
								</div>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</form>
</cfoutput>
<cfinclude template = "includes/_footer.cfm">