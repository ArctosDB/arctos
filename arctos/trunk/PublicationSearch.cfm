<cfinclude template = "includes/_header.cfm">
<cfif not isdefined("toproject_id")>
	<cfset toproject_id = -1>
</cfif>
<cfset title = "Search for Publications">
<table width="75%">
	<tr valign="top">
	<td>
	<b><font size="+1">Publication Search</font></b> 
	<table width="90%" border><tr><td>
	Publications often relate directly to specimens through 
	<a href="javascript: void(0);" 
	onClick="windowOpener('/info/Citations.cfm','CitationStats','width=800,height=800, resizable,scrollbars');return true;">citations</a>.  A specimen is considered to have been cited if the individual specimen can be definitively related to a page in refereed literature.
<p>
A publication might also be linked to the project from which it resulted.  We may know what specimens were used and what publications were produced even if specimens were not cited.
</td></tr></table>
	</td>
	<td>
	<form action="PublicationResults.cfm" method="post">
<cfoutput>

<input type="hidden" name="toproject_id" value="#toproject_id#">
  </cfoutput> 
  <table>
  <tr>
    <td align="right">Title:</td>
    <td><input name="pubTitle" type="text"></td>
  </tr>
  <tr>
    <td align="right">Author:</td>
    <td><input name="pubAuthor" type="text"></td>
  </tr>
  <tr>
    <td align="right">Year:</td>
    <td><input name="pubYear" type="text"></td>
  </tr>
   <tr>
    <td align="right">Journal:
		<select name="jnOper" size="1">
			<option value="LIKE">contains</option>
			<option value="=">is</option>
		</select>
	
	</td>
    <td><input name="journal_name" type="text"></td>
  </tr>
   <tr>
    <td align="right" nowrap><a href="javascript:void(0);" 
		onClick="getHelp('cited_sci_name'); return false;"
		onMouseOver="self.status='Click for Cited Scientific Name help.';return true;" 
		onmouseout="self.status='';return true;">Cited Scientific Name:</a></td>
    <td><input name="cited_Sci_Name" type="text"></td>
  </tr>
  <tr>
    <td align="right" nowrap>
	 <a href="javascript:void(0);" 
		onClick="getHelp('accepted_sci_name'); return false;"
		onMouseOver="self.status='Click for Accepted Scientific Name help.';return true;" 
		onmouseout="self.status='';return true;">Accepted Scientific Name:</a>
		</td>
    <td><input name="current_Sci_Name" type="text"></td>
  </tr> 
  
  <tr>
    <td align="right">
		<a href="javascript:void(0);" 
		onClick="getHelp('onlyCited'); return false;"
		onMouseOver="self.status='Click for Accepted Scientific Name help.';return true;" 
		onmouseout="self.status='';return true;">Cite specimens only?</a>
		
	
	</td>
    <td>
	<input type="checkbox" name="onlyCitePubs" value="1">
	</td>
</tr>
<tr>
	<td align="right">
		Cites&nbsp;Collection:
	</td>
	<cfquery name="ctColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select collection,collection_id from collection order by collection_id
	</cfquery>
	<td>
		<cfoutput>
		<select name="collection_id" id="collection_id" size="1">
			<option value="">All</option>
			<cfloop query="ctColl">
				<option value="#collection_id#">#collection#</option>
			</cfloop>
		</select>
		</cfoutput>
	</td>
  </tr>
  
  
</table>
<cfoutput>
<input type="submit" 
	value="Search" 
	class="schBtn"
    onmouseover="this.className='schBtn btnhov'" 
    onmouseout="this.className='schBtn'">
<input type="reset" 
	value="Clear Form" 
	class="clrBtn"
	onmouseover="this.className='clrBtn btnhov'" 
	onmouseout="this.className='clrBtn'">
	
</cfoutput>
</form>
<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>					
	<br><a href="Publication.cfm?action=newPub">Create Publication</a>
</cfif>
<cfinclude template = "includes/_footer.cfm">