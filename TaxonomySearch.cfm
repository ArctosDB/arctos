<cfinclude template = "includes/_header.cfm">
<cfset title = "Search for Taxa">
<!--- no security required to access this page --->
<cfquery name="class" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select phylclass from ctclass order by phylclass
</cfquery>
<cfquery name="getCount" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select count(*) as cnt from taxonomy
</cfquery>

<form ACTION="TaxonomyResults.cfm" METHOD="post" name="taxa">
<table width="90%" border="0" cellspacing="0" cellpadding="0">
	<tr> 
		<td rowspan="18" valign="top" align="left">
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
						These <cfoutput>#getCount.cnt#</cfoutput> records represent current and past taxonomic treatments in Arctos. 
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
					<input type="radio" name="VALID_CATALOG_TERM_FG" checked value="">
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
	</tr>
	<tr>
		<cfoutput>
		<td>&nbsp;</td>
		<td align="center" nowrap>
			<input type="submit" 
				value="Search" 
				class="schBtn"
				onmouseover="this.className='schBtn btnhov'" 
				onmouseout="this.className='schBtn'">
			&nbsp;&nbsp;
			<input type="reset" 
				value="Clear Form" 
				class="clrBtn"
				onmouseover="this.className='clrBtn btnhov'" 
				onmouseout="this.className='clrBtn'">
			<input type="hidden" name="action" value="search">
			<br><font size=-1>All fields accept partial matches.</font>
		</td>
	</tr>
	<tr>
		<td align="right" nowrap>
			<a href="javascript:void(0);" 
				onClick="getHelp('common_name'); return false;"
				onMouseOver="self.status='Click for Common Name help.';return true;" 
				onmouseout="self.status='';return true;"><b>Common&nbsp;Name:</b></a>
		</td>
		<td><input size="25" name="common_name" maxlength="50"></td>
	</tr>
	<tr>
		<td align="right">
		<a href="javascript:void(0);" 
				onClick="getHelp('taxonomy_scientific_name'); return false;"
				onMouseOver="self.status='Click for Scientific Name help.';return true;" 
				onmouseout="self.status='';return true;"><b><nobr>Scientific Name:</nobr></b></a>		
</td><td><input size="25" name="scientific_name" maxlength="40"></td></tr>
<tr><td align="right">
<a href="javascript:void(0);" 
				onClick="getHelp('taxonomy_anything'); return false;"
				onMouseOver="self.status='Click for Higher Taxa help.';return true;" 
				onmouseout="self.status='';return true;"><b>Any&nbsp;Category:</b></a>
				</td>
<td><input size="25" name="full_taxon_name" maxlength="50"></td></tr>
<tr>
	<td align="right"><b><nobr>Author Text:</nobr></b></td>
	<td><input size="25" name="author_text" maxlength="40"></td>
</tr>
<tr><td align="right"><b><nobr>Genus:</nobr></b>
</td><td><input size="25" name="genus" maxlength="40"></td></tr>
<tr><td align="right"><b><nobr>Species:</nobr></b>
</td><td><input size="25" name="species" maxlength="40"></td></tr>
<tr><td align="right"><b><nobr>Subspecies:</nobr></b>
</td><td><input size="25" name="subspecies" maxlength="40"></td></tr>
<tr><td align="right"><b><nobr>Phylum:</nobr></b>
</td><td><input size="25" name="phylum" maxlength="40"></td></tr>
<tr><td align="right"><b><nobr>Class:</nobr></b></td>
<td>
<cfquery name="ctClass" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select distinct(phylclass) from taxonomy order by phylclass
</cfquery>
<select name="phylclass" size="1">
<option></option>
<cfloop query="ctClass">
	<option value="#phylclass#">#phylclass#</option>
</cfloop>
</select>
<!---
<img 
	class="likeLink" 
	src="/images/ctinfo.gif" 
	border="0"
	onMouseOver="self.status='Code Table Value Definition';return true;"
	onmouseout="self.status='';return true;"
	onClick="getCtDoc('ctclass',taxa.phylclass.value)">
--->
<span class="infoLink" onclick="getCtDoc('ctclass',taxa.phylclass.value);">Define</span>								

</td></tr>
<tr><td align="right"><b><nobr>Order:</nobr></b> </td><td><input size="25" name="phylorder" maxlength="40"></td></tr>
<tr><td align="right"><b><nobr>Suborder:</nobr></b>
</td><td><input size="25" name="suborder" maxlength="40"></td></tr>
<tr> <td  align="right"><b><nobr>Family:</nobr></b>
</td><td><input size="25" name="family" maxlength="40"></td></tr>
<tr><td  align="right"><b><nobr>Subfamily:</nobr></b>
</td><td><input size="25" name="subfamily" maxlength="40"></td></tr>
<tr><td align="right"><b><nobr>Tribe:</nobr></b>
</td><td><input size="25" name="tribe" maxlength="40"></td></tr>
<tr><td align="right"><b><nobr>Subgenus:</nobr></b>
</td><td><input size="25" name="subgenus" maxlength="40"></td></tr>
<tr><td><font size="-1">&nbsp;</font></td>
<td align="center"><input type="submit" 
	value="Search" 
	class="schBtn"
    onmouseover="this.className='schBtn btnhov'" 
    onmouseout="this.className='schBtn'">	

&nbsp;&nbsp;

<input type="reset" 
	value="Clear Form" 
	class="clrBtn"
	onmouseover="this.className='clrBtn btnhov'" 
	onmouseout="this.className='clrBtn'">

<input type="hidden" name="action" value="search"><br><font size=-1>All fields accept partial matches.</font>
</cfoutput>
</form></table>
<br>
Note: This form will not return >1000 records; you may need to narrow your search to return all matches.



 
 
  <!------------------------------------------------>
  
  
 
 
 
<cfinclude template = "includes/_footer.cfm">
