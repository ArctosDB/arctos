<cfinclude template="../includes/_pickHeader.cfm">
<cfset title="Publication Pick">
<body bgcolor="#FFFBF0" text="midnightblue" link="blue" vlink="midnightblue">
 <!--- no security --->
 <cfif not isdefined("Action")>
	<cfset Action = "nothing">
</cfif>

<cfif #Action# is "nothing">
<form action="PubPick.cfm" method="post">
<cfoutput>
<input type="hidden" name="pubIdFld" value="#pubIdFld#">
      <input type="hidden" name="PubTxtFld" value="#PubTxtFld#">
      <input type="hidden" name="formName" value="#formName#">
</cfoutput>
<input type="hidden" name="Action" value="srch">
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
    <td align="right">Cited Scientific Name:</td>
    <td><input name="cited_Sci_Name" type="text"></td>
  </tr>
  <tr>
    <td align="right">Accepted Scientific Name:</td>
    <td><input name="current_Sci_Name" type="text"></td>
  </tr> <tr>
    <td align="right">Journal:
		<select name="jnOper" size="1">
			<option value="LIKE">contains</option>
			<option value="=">is</option>
		</select>
	
	</td>
    <td><input name="journal_name" type="text"></td>
  </tr>
</table>
<cfoutput>
<input name="Search" type="submit" value="Search" #srchClr#>
<input value="Clear Form" type="reset" #quitClr#>	
</cfoutput>
</form>

</cfif>
------------------
<cfif #Action# is "srch">
<cfset basSQL = "SELECT DISTINCT 
			publication.publication_id,
			publication.publication_type,
			formatted_publication ">
		<cfset basFrom = "
		FROM 
			publication,
			publication_author_name,
			project_publication,
			agent_name,
			formatted_publication">
		<cfset basWhere = "
		WHERE 
		publication.publication_id = project_publication.publication_id (+) 
		AND publication.publication_id = publication_author_name.publication_id 
		AND publication_author_name.agent_name_id = agent_name.agent_name_id 
		AND formatted_publication.publication_id = publication.publication_id 
		AND formatted_publication.format_style = 'full citation'">
		
	<cfif isdefined("pubTitle") AND len(#pubTitle#) gt 0>
		<cfset basWhere = "#basWhere# AND UPPER(publication_title) LIKE '%#ucase(pubTitle)#%'">
	</cfif>
	<cfif isdefined("pubAuthor") AND len(#pubAuthor#) gt 0>
		<cfset basWhere = "#basWhere# AND UPPER(agent_name) LIKE '%#ucase(pubAuthor)#%'">
	</cfif>
	<cfif isdefined("pubYear") AND len(#pubYear#) gt 0>
		<cfset basWhere = "#basWhere# AND UPPER(PUBLISHED_YEAR) LIKE '%#ucase(pubYear)#%'">
	</cfif>
	<cfif isdefined("publication_id") AND len(#publication_id#) gt 0>
		<cfset basWhere = "#basWhere# AND publication.publication_id = #publication_id#">
	</cfif>
	<cfif isdefined("current_Sci_Name") AND len(#current_Sci_Name#) gt 0>
		<cfset basFrom = "#basFrom# ,
			citation, 
			cataloged_item,
			identification,
			taxonomy catItemTaxa">
		<cfset basWhere = "#basWhere# AND publication.publication_id = citation.publication_id (+)
		AND citation.collection_object_id = cataloged_item.collection_object_id (+)
		AND cataloged_item.collection_object_id = identification.collection_object_id
		AND identification.accepted_id_fg = 1
		AND identification.taxon_name_id = catItemTaxa.taxon_name_id
		AND upper(catItemTaxa.scientific_name) LIKE '%#ucase(current_Sci_Name)#%'">
	</cfif>
	<cfif isdefined("cited_Sci_Name") AND len(#cited_Sci_Name#) gt 0>
		<cfset basFrom = "#basFrom# ,
			citation, taxonomy CitTaxa">
			<cfset basWhere = "#basWhere# AND publication.publication_id = citation.publication_id (+)
				AND citation.cited_taxon_name_id = CitTaxa.taxon_name_id (+)
				AND upper(CitTaxa.scientific_name) LIKE '%#ucase(cited_Sci_Name)#%'">
	</cfif>
	<cfif isdefined("journal_name") AND len(#journal_name#) gt 0>
		<cfif #jnOper# is "LIKE">
			<cfset jname="'%#ucase(journal_name)#%'">
		<cfelse>
			<cfset jname = "'#ucase(journal_name)#'">
		</cfif>
		<cfset basFrom = "#basFrom# ,
			journal, journal_article">
		<cfset basWhere = "#basWhere# AND publication.publication_id = journal_article.publication_id 
			AND journal_article.journal_id = journal.journal_id AND
			upper(journal_name) #jnOper# #jname#">
	</cfif>
	
	
	<cfset basSql = "#basSQL# #basFrom# #basWhere# ORDER BY publication.publication_id">
	
	<cfquery name="getPubsDB" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(basSQL)#
	</cfquery>
	
	<input type="hidden" name="pubIdFld" value="##">
      <input type="hidden" name="PubTxtFld" value="##">
      <input type="hidden" name="formName" value="#formName#">
	  
	  
<cfoutput query="getPubsDB">
<p><a href="##" onClick="javascript: opener.document.#formName#.#pubIdFld#.value='#publication_id#';opener.document.#formName#.#PubTxtFld#.value='#formatted_publication#';self.close();">#formatted_publication#</a>

</cfoutput>

</cfif>
<cfinclude template="../includes/_pickFooter.cfm">