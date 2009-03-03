<cfinclude template="includes/_header.cfm">
<cfset title = "Edit Publication">

<!----------------------------------------------------------------------------->
<cfif #Action# is "editBookSection">
	<!--- get the book data and relocate to editBook --->
	
	<cfquery name="getBook" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select book_id from book_section where publication_id=#publication_id#
	</cfquery>
	<cfoutput>
		<cflocation url="editBook.cfm?publication_id=#getBook.book_id#">
	</cfoutput>
</cfif>
<!----------------------------------------------------------------------------->


<cfif #Action# is "nothing">
<cfset title="Find Journals">
<h2>Find Journal</h2>
<form name="findJournal" method="post" action="Publication.cfm">
	<input type="hidden" name="Action" value="findJournal">
		<label for="journal_name">Journal Name</label>
		<input type="text" name="journal_name" id="journal_name">
		<label for="journal_abbreviation">Journal Abbreviation</label>
		<input type="text" name="journal_abbreviation" id="journal_abbreviation">
		<label for="journal_abbreviation">Publisher</label>
		<input type="text" name="publisher_name" id="publisher_name">
		<br>
		<input type="submit" 
			value="Find Journal" 
			class="schBtn">	
		<input type="reset" 
			value="Clear Form" 
			class="clrBtn">
	</form>
	</cfif>
<!---------------------------------------------------------------------------->
<cfif #Action# is "newJournalArt">
<cfoutput>
<cfset title="Create Journal Article">
	Create Journal Article:
	<table>
		<cfform name="newJournalArt" method="post" action="Publication.cfm">
		<input type="hidden" name="Action" value="makeJournalArticle">
		<tr>
			<td align="right">
			<a href="javascript:void(0);" onClick="getDocs('publication','title')">Title:</a>
			</td>
			<td><input type="text" name="publication_title" size="70"></td>
		</tr>
		<tr>
			<td align="right">Journal:</td>
			<td><input type="text" name="journal_name" readonly="yes" size="60">
				<input type="hidden" name="journal_id">
				<input type="button" 
				value="Pick" 
				class="picBtn"
				onmouseover="this.className='picBtn btnhov'"
				onmouseout="this.className='picBtn'"
				onClick="JournalPick('journal_id','journal_name','newJournalArt'); return false;">
				
				</td>
		</tr>
		<tr>
		<td align="right">Page:</td>
		<td><input type="text" name="begins_page_number" size="4"> to <input type="text" name="ends_page_number" size="4">
		Volume: <input type="text" name="volume_number" size="4"> Issue: <input type="text" name="issue_number" size="4">
		<a href="javascript:void(0);" onClick="getDocs('publication','year')">Year:</a> <input type="text" name="published_year" size="4"></td>
		</tr>
		
		<tr>
		<td align="right">Remarks:</td>
		<td><input type="text" name="publication_remarks"></td>
		</tr>
		<tr>
		<td colspan="2">
			<input type="submit" 
				value="Create Journal Article" 
				class="insBtn"
				onmouseover="this.className='insBtn btnhov'" 
				onmouseout="this.className='insBtn'">
			<input type="button"
				value="Quit"
				class="qutBtn"
				onmouseover="this.className='qutBtn btnhov'"
				onmouseout="this.className='qutBtn'"
				onClick="document.location='Publication.cfm';">
	
				</td>
		</tr>
		</cfform>
		</table>
</cfoutput>

</cfif>
<!---------------------------------------------------------------------------->
<!---------------------------------------------------------------------------->
<cfif #Action# is "newJournal">
<CFSET title="Create Journal">
<cfoutput>
	<table class="newRec">
		<form name="newJournal" method="post" action="Publication.cfm">
		<input type="hidden" name="Action" value="makeJournal">
		<input type="hidden" name="publication_id" >
		<tr>
			<td colspan="2">
				<strong>Create Journal:</strong>
			</td>
		</tr>
		<tr>
			<td align="right">
				Name:
			</td>
			<td>
				<input type="text" name="journal_name" size="70" class="reqdClr">
			</td>
		</tr>
		<tr>
			<td align="right">
				Abbreviation:
			</td>
			<td>
				<input type="text" name="journal_abbreviation" size="70" class="reqdClr">
			</td>
		</tr>
		<tr>
			<td align="right">
				Publisher:
			</td>
			<td>
				<input type="text" name="publisher_name" size="70">
			</td>
		</tr>
		<tr>
			<td colspan="2" align="center">
				<input type="submit" 
						value="Create Journal" 
						class="insBtn"
						onmouseover="this.className='insBtn btnhov'" 
						onmouseout="this.className='insBtn'">	
				<input type="button"
						value="Quit"
						class="qutBtn"
						onmouseover="this.className='qutBtn btnhov'"
						onmouseout="this.className='qutBtn'"
						onClick="document.location='Publication.cfm';">
			</td>
		</tr>
	</form>
	</table>
</cfoutput>

</cfif>
<!---------------------------------------------------------------------------->

<!---------------------------------------------------------------------------->
<cfif #Action# is "makeJournalArticle">
<cfoutput>

<cfquery name="nextPub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select sq_publication_id.nextval nextID from dual
</cfquery>
<cfset thisID = #nextPub.nextID#>
<cftransaction>
	<cfquery name="newJAP" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
INSERT INTO publication (
PUBLICATION_ID,
PUBLICATION_TYPE
<cfif len(#PUBLISHED_YEAR#) gt 0>
	,PUBLISHED_YEAR
</cfif>
,publication_title
<cfif len(#PUBLICATION_REMARKS#) gt 0>
	,PUBLICATION_REMARKS
</cfif>
)
values (
#thisID#,
'Journal Article'
<cfif len(#PUBLISHED_YEAR#) gt 0>
	,#PUBLISHED_YEAR#
</cfif>
,'#publication_title#'
<cfif len(#PUBLICATION_REMARKS#) gt 0>
	,'#PUBLICATION_REMARKS#'
</cfif>
)
</cfquery>
<cfquery name="newJA" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
INSERT INTO journal_article (
PUBLICATION_ID ,
JOURNAL_ID
<cfif len(#BEGINS_PAGE_NUMBER#) gt 0>
	,BEGINS_PAGE_NUMBER
</cfif>
<cfif len(#ENDS_PAGE_NUMBER#) gt 0>
	,ENDS_PAGE_NUMBER
</cfif>
<cfif len(#VOLUME_NUMBER#) gt 0>
	,VOLUME_NUMBER
</cfif>
<cfif len(#ISSUE_NUMBER#) gt 0>
	,ISSUE_NUMBER
</cfif> )
 VALUES (
#thisID# ,
#journal_id#
<cfif len(#BEGINS_PAGE_NUMBER#) gt 0>
	,#BEGINS_PAGE_NUMBER#
</cfif>
<cfif len(#ENDS_PAGE_NUMBER#) gt 0>
	,#ENDS_PAGE_NUMBER#
</cfif>
<cfif len(#VOLUME_NUMBER#) gt 0>
	,#VOLUME_NUMBER#
</cfif>
<cfif len(#ISSUE_NUMBER#) gt 0>
	,#ISSUE_NUMBER#
</cfif>
)
</cfquery>

</cftransaction>

<cflocation url="Publication.cfm?Action=editJournalArt&publication_id=#thisID#">
</cfoutput>

</cfif>
<!---------------------------------------------------------------------------->
<!---------------------------------------------------------------------------->
<cfif #Action# is "makeJournal">
<cfoutput>
	<cfquery name="nextJID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select sq_journal_id.nextval nextid from dual
	</cfquery>
	<cfquery name="newJ" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	INSERT INTO journal (
	 JOURNAL_ID,
	 JOURNAL_ABBREVIATION,
	 JOURNAL_NAME 
	 <cfif len(#PUBLISHER_NAME#) gt 0>
	 	,PUBLISHER_NAME 
	 </cfif>   
	 )	VALUES (
		#nextJID.nextid#,
	 '#JOURNAL_ABBREVIATION#',
	 '#JOURNAL_NAME#'
	 <cfif len(#PUBLISHER_NAME#) gt 0>
	 	,'#PUBLISHER_NAME#'
	 </cfif> )  
	 </cfquery>
	 <cflocation url="Publication.cfm?Action=editJournal&JOURNAL_ID=#nextJID.nextid#">
</cfoutput>

</cfif>
<!---------------------------------------------------------------------------->
<!---------------------------------------------------------------------------->
<cfif #Action# is "newBook">
<cfset title="Create Book">
<cfoutput>
	
	<cfform name="newBook" method="post" action="Publication.cfm">
		<input type="hidden" name="Action" value="makeBook1">
		<input type="hidden" name="publication_id" >
		Create Book:
			
			<br>Title:<input type="text" name="publication_title">
			<br>Volume:<input type="text" name="Volume_number">
			<br>Pages:<input type="text" name="Page_total">
			<br>Publisher:<input type="text" name="Publisher_name">
			<br>Remarks:<input type="text" name="publication_Remarks">
			<br>Year:<input type="text" name="published_year">
			<br>Edited:<select name="Edited_work_fg" size="1">
			<option value="1">yes</option>
			<option value="0">no</option>
		</select>
			<input type="submit" 
				value="Save Book" 
				class="insBtn"
				onmouseover="this.className='insBtn btnhov'" 
				onmouseout="this.className='insBtn'">
			<input type="button"
				value="Quit"
				class="qutBtn"
				onmouseover="this.className='qutBtn btnhov'"
				onmouseout="this.className='qutBtn'"
				onClick="document.location='Publication.cfm';">
		
		</cfform>
</cfoutput>

</cfif>
<!---------------------------------------------------------------------------->
<!---------------------------------------------------------------------------->
<cfif #Action# is "makeBook1">
<cfoutput>

<cfquery name="nextPub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select sq_publication_id.nextval nextID from dual
</cfquery>
<cftransaction>
<cfquery name="nextBP" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
INSERT INTO publication (
PUBLICATION_ID,
PUBLICATION_TYPE
<cfif len(#PUBLISHED_YEAR#) gt 0>
	,PUBLISHED_YEAR
</cfif>
<cfif len(#PUBLICATION_REMARKS#) gt 0>
	,PUBLICATION_REMARKS
</cfif>
,publication_title
)
values (
#nextPub.nextID#,
'Book'
<cfif len(#PUBLISHED_YEAR#) gt 0>
	,#PUBLISHED_YEAR#
</cfif>
<cfif len(#PUBLICATION_REMARKS#) gt 0>
	,'#PUBLICATION_REMARKS#'
</cfif>
,'#publication_title#'
)
</cfquery>

<cfquery name="nextB" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
INSERT INTO book (
PUBLICATION_ID ,
EDITED_WORK_FG
<cfif len(#VOLUME_NUMBER#) gt 0>
	,VOLUME_NUMBER
</cfif>
<cfif len(#PAGE_TOTAL#) gt 0>
	,PAGE_TOTAL
</cfif>
<cfif len(#PUBLISHER_NAME#) gt 0>
	,PUBLISHER_NAME
</cfif>
)
VALUES (
#nextPub.nextID# ,
#EDITED_WORK_FG#
<cfif len(#VOLUME_NUMBER#) gt 0>
	,#VOLUME_NUMBER#
</cfif>
<cfif len(#PAGE_TOTAL#) gt 0>
	,'#PAGE_TOTAL#'
</cfif>
<cfif len(#PUBLISHER_NAME#) gt 0>
	,'#PUBLISHER_NAME#'
</cfif>
)
</cfquery>
</cftransaction>

<cflocation url="Publication.cfm?Action=editBook&publication_id=#nextPub.nextID#">
</cfoutput>

</cfif>
<!---------------------------------------------------------------------------->
<!---------------------------------------------------------------------------->
<cfif #Action# is "editBook">
<cfoutput>
	<cflocation url="editBook.cfm?publication_id=#publication_id#" addtoken="false">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->

<!---------------------------------------------------------------------------->
<cfif #Action# is "findJournal">
	<cfoutput>
		<cfset sql = "SELECT * from journal where journal_id > 0">
		<cfif len(#journal_name#) gt 0>
			<cfset sql = "#sql# AND upper(journal_name) like '%#ucase(journal_name)#%'">
		</cfif>
		<cfif len(#journal_abbreviation#) gt 0>
			<cfset sql = "#sql# AND upper(journal_abbreviation) like '%#ucase(journal_abbreviation)#%'">
		</cfif>
		<cfif len(#publisher_name#) gt 0>
			<cfset sql = "#sql# AND upper(publisher_name) LIKE '%#ucase(publisher_name)#%'">
		</cfif>
		<cfquery name="getJournal" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			#preservesinglequotes(sql)#
		</cfquery>
		</cfoutput>	
		<table border="1">
			<tr>
				<th>Journal Name</th>
				<th>Abbreviation</th>
				<th>Publisher</th>
				<th>&nbsp;</th>
			</tr>
			<cfoutput query="getJournal">
				<tr>
					<td>#journal_name#</td>
					<td><#journal_abbreviation#/td>
					<td>#publisher_name#</td>
					<td><a href="Publication.cfm?Action=editJournal&journal_id=#journal_id#">Edit</a></td>
				</tr>
			</cfoutput>
		</table>	
</cfif>
<!---------------------------------------------------------------------------->


<!---------------------------------------------------------------------------->
<cfif #Action# is "editJournal">
<cfset title="Edit Journal">
	<cfoutput>
		<cfquery name="jdet" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from journal where journal_id=#journal_id#
		</cfquery>
	</cfoutput>
	<cfoutput query="jdet">
		<cfform name="journal" method="post" action="Publication.cfm">
			<input type="hidden" name="Action" value="saveJourEdit">
			<input type="hidden" name="journal_id" value="#journal_id#">
			<label for="journal_name">Journal Name</label>
			<input type="text" name="journal_name" id="journal_name" value="#journal_name#" class="reqdClr" size="50">
			<label for="journal_abbreviation">Journal Abbreviation</label>
			<input type="text" name="journal_abbreviation" id="journal_abbreviation" value="#journal_abbreviation#" class="reqdClr">
			<label for="journal_abbreviation">Publisher</label>
			<input type="text" name="publisher_name" id="publisher_name" value="#publisher_name#" size="50">
			<br>	
			<input type="submit"
				value="Save"
				class="savBtn">			
			<input type="button"
				value="Quit"
				class="qutBtn"
				onClick="document.location='Publication.cfm';">				
		</cfform>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->


<!---------------------------------------------------------------------------->
<cfif #Action# is "editJournalArt">
<cfset title="Edit Journal Article">
	<cfoutput>
		<cfquery name="getJournalArt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			 SELECT * from journal_article, journal, publication, publication_author_name, agent_name,
			 publication_url
			 where 
			 journal_article.publication_id=publication.publication_id and
			 journal_article.journal_id=journal.journal_id and
			 publication.publication_id = publication_url.publication_id (+) and
			 publication.publication_id = publication_author_name.publication_id (+) and
			 publication_author_name.agent_name_id = agent_name.agent_name_id (+)
			 and publication.publication_id=#publication_id#
		</cfquery>
		
		<cfquery name="distJourArt" dbtype="query">
			select published_year, publication_id,publication_title, 
		journal_name,
		journal_abbreviation,
		publisher_name,
		begins_page_number,
		ends_page_number,
		volume_number,
		issue_number,
		publication_remarks
		 from getJournalArt group  by
		published_year, publication_id, publication_title, 
		journal_name,
		journal_abbreviation,
		publisher_name,
		begins_page_number,
		ends_page_number,
		volume_number,
		issue_number,
		publication_remarks
		</cfquery>
		<cfquery name="distUrl" dbtype="query">
			select publication_id, link, description,publication_url_id from getJournalArt 
			GROUP BY publication_id, link, description,publication_url_id
		</cfquery>
		<cfquery name="journArtAuth" dbtype="query">
			select agent_name, author_position, agent_name_id from getJournalArt 
			group by agent_name, author_position, agent_name_id
			order by author_position
		</cfquery>
	
	<table border>
		<cfform name="journArtDet" method="post" action="Publication.cfm">
		<input type="hidden" name="Action" value="SaveJournArtChanges">
		<input type="hidden" name="publication_id" value="#distJourArt.publication_id#">
		<tr>
			<td valign="top" align="right">Journal&nbsp;Article:
			<br><a href="javascript:void(0);" onClick="getDocs('publication')"><img src="/images/info.gif" border="0"></a></td>
		<td>
			<table>
				<tr>
					<td align="right" valign="top">
					<a href="javascript:void(0);" onClick="getDocs('publication','title')">Title:</a>
					</td>
					<td colspan="3">
					<textarea name="publication_title" rows="3" cols="40">#distJourArt.publication_title#</textarea>
					</td>
				</tr>
				<tr>
					<td align="right">Journal Name:</td>
					<td colspan="3">
					<input type="text" 
						name="journal_name" 
						value="#distJourArt.journal_name#" 
						class="reqdClr"
						size="70"
						onchange="findJournal('journal_id','journal_name','journArtDet',this.value); return false;"
		 				onKeyPress="return noenter(event);">
		 
		 
					
							<input type="hidden" name="journal_id">
							
							
							
					</td>
				</tr>
				<tr>

					<td align="right">Page:</td>
					<td><input type="text" name="begins_page_number" value="#distJourArt.begins_page_number#" size="6">&nbsp;
						TO&nbsp;<input type="text" name="ends_page_number" value="#distJourArt.ends_page_number#" size="6">
					</td>
					<td colspan="2">Volume:&nbsp;<input type="text" name="volume_number" value="#distJourArt.volume_number#" size="6">
					&nbsp;Issue:&nbsp;<input type="text" name="issue_number" value="#distJourArt.issue_number#" size="6"></td>
				</tr>
				<tr>
					<td align="right">Remarks:</td>
					<td colspan="3"><input type="text" name="remarks" size="60" value="#distJourArt.publication_remarks#"></td>
				</tr>
			</table>
		</td>		
		</tr> 
		<tr><td colspan="2" nowrap>
		
		<div align="left" style="float:left ">
		<input type="submit" value="Save Edits" class="savBtn"
   					onmouseover="this.className='savBtn btnhov'" onmouseout="this.className='savBtn'">	
		<input type="button" value="Quit" class="qutBtn"
   					onmouseover="this.className='qutBtn btnhov'" onmouseout="this.className='qutBtn'"
					onClick="document.location='Publication.cfm';">	
					</cfform>
	</div>
	<span style="float:right;  ">
					<form name="killJA" action="Publication.cfm" method="post">
			<input type="hidden" name="Action" value="killJournalArticle">
			<input type="hidden" name="publication_id" value="#distJourArt.publication_id#">
			<input type="submit" value="Delete" class="delBtn"
   					onmouseover="this.className='delBtn btnhov'" onmouseout="this.className='delBtn'">	
			
			
		</form>
					</span>
		
		
		</td></tr>
		
		<tr><td><a href="javascript:void(0);" onClick="getDocs('publication','author')">Authors:</a>
					</td>
		<td>
		<table>
		<cfset i=1>
			<cfloop query="journArtAuth">
			<cfif len(#journArtAuth.agent_name_id#) gt 0>
				<form name="author#i#" method="post" action="Publication.cfm">
				<input type="hidden" name="Action" value="changePubAuth">
				<input type="hidden" name="publication_id" value="#distJourArt.publication_id#">
				<input type="hidden" name="caller" value="#Action#">
				<tr><td>Author ##<select name="author_position">
					<cfset num = 1>
					<cfloop condition="#num# lt 26">
						<option <cfif #num# is "#journArtAuth.author_position#"> selected </cfif>value="#num#">#num#</option>
						<cfset num=#num#+1>
					</cfloop>
						</select>
				
				</td><td>
				
				
				
				<input type="text" name="authorName" value="#journArtAuth.agent_name#" class="reqdClr" 
		onchange="findAgentName('newagent_name_id','authorName','author#i#',this.value); return false;"
		 onKeyPress="return noenter(event);">
		 
		 
					<input type="hidden" name="agent_name_id" value="#journArtAuth.agent_name_id#">
					<input type="hidden" name="newagent_name_id">
				
				
				
				
				<input type="button" value="Save" class="savBtn"
   					onmouseover="this.className='savBtn btnhov'" onmouseout="this.className='savBtn'"
					onClick="submit();">	
				<input type="button" value="Delete" class="delBtn"
   					onmouseover="this.className='delBtn btnhov'" onmouseout="this.className='delBtn'"
					onClick="author#i#.Action.value='delPubAuth';submit();">	
					<cfset i = #i#+1>
					
					</td></tr>
			</form>
			</cfif>
			</cfloop>
			</table>
			<table class="newRec"><tr><td>
			<cfform name="newAuthor"  method="post" action="Publication.cfm">
			<input type="hidden" name="Action" value="newPubAuth">
				<input type="hidden" name="publication_id" value="#distJourArt.publication_id#">
				<input type="hidden" name="caller" value="#Action#">
			<cftry>
			<cfquery name="nextAuth" dbtype="query">
				select max(author_position) + 1 as nextPos from getJournalArt
			</cfquery>
			<cfcatch>
				<!--- returned null --->
				<cfset nextPos = 1>
			</cfcatch>
			</cftry>
			<cfif isdefined("nextAuth.recordcount") AND #nextAuth.recordcount# gt 0>
				<cfset nextPos = #nextAuth.nextPos#>
				<cfelse>
					<cfset nextPos = 1>
			</cfif>
			<br>Add Author: ##<select name="author_position">
					<cfset num = 1>
					<cfloop condition="#num# lt 26">
						<option 
							<cfif #num# is "#nextPos#"> selected </cfif>value="#num#">#num#</option>
						<cfset num=#num#+1>
					</cfloop>
						</select>
						
						
				<input type="text" name="newAuth"  class="reqdClr" 
		onchange="findAgentName('newAuthId','newAuth','newAuthor',this.value); return false;"
		 onKeyPress="return noenter(event);">
		 
		 
				<input type="hidden" name="newAuthId">
				
				<input type="submit" value="Save" class="savBtn"
   					onmouseover="this.className='savBtn btnhov'" onmouseout="this.className='savBtn'">	
				
			</cfform>
			</td></tr></table>		
					

	</cfoutput>
	</td></tr>
	<tr>
		<td>
			Links:
		</td>
		<td>
				<table>
				<tr>
					<td>
					<a href="javascript:void(0);" onClick="getDocs('publication','description')">Description</a>
					</td>
					<td><a href="javascript:void(0);" onClick="getDocs('publication','url')">URL</a></td>
					<td>&nbsp;</td>
				</tr>
				
						<cfset i=1>
						<cfif len(#distUrl.link#) gt 0>
						<cfoutput query="distUrl">
						<tr>
					
							<form name="pubLink#i#" method="post" action="Publication.cfm">
								<input type="hidden" name="action" value="">
								<input type="hidden" name="publication_url_id" value="#publication_url_id#">
								<input type="hidden" name="publication_id" value="#publication_id#">
								<td><input type="text" name="description" value="#description#"></td>
								<td><input type="text" name="link" value="#link#" size="60"></td>
								<td nowrap><input type="button" value="Save" class="savBtn"
   					onmouseover="this.className='savBtn btnhov'" onmouseout="this.className='savBtn'"
					onclick="pubLink#i#.action.value='updateLink';submit();">
					
					<input type="button" value="Delete" class="delBtn"
   					onmouseover="this.className='delBtn btnhov'" onmouseout="this.className='delBtn'"
					onclick="pubLink#i#.action.value='deleteLink';submit();">
					
					</td>
								
								
							</form>
							
							<cfset i=#i#+1>
							</tr>
						</cfoutput>
						</cfif>
												
					
				
				<tr class="newRec">
					<cfoutput>
						<form name="newLink" method="post" action="Publication.cfm">
								<input type="hidden" name="action" value="newLink">
								<input type="hidden" name="publication_id" value="#distUrl.publication_id#">
								<td><input type="text" name="description"></td>
								<td><input type="text" name="link" size="60"></td>
								<td><input type="submit" value="Insert" class="insBtn"
   					onmouseover="this.className='insBtn btnhov'" onmouseout="this.className='insBtn'">	</td>
								
								
							</form>
					</cfoutput>
				</tr>
			</table>
		</td>
	</tr>
	</table>
</cfif>

<!---------------------------------------------------------------------------->
<cfif #Action# is "deleteLink">
	
	<cfoutput>
	<cfquery name="newLink" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		DELETE FROM publication_url
		WHERE
		publication_url_id = #publication_url_id#
	</cfquery>
	
	
	<cflocation url="Publication.cfm?Action=editJournalArt&publication_id=#publication_id#">
	
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->
<!---------------------------------------------------------------------------->
<cfif #Action# is "updateLink">
	<cfoutput>
	<cfquery name="newLink" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		UPDATE publication_url SET
		link = '#link#',
		description = '#description#'
		WHERE
		publication_url_id = #publication_url_id#
	</cfquery>
	
	
	<cflocation url="Publication.cfm?Action=editJournalArt&publication_id=#publication_id#">
	
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->
<!---------------------------------------------------------------------------->
<cfif #Action# is "newLink">
	<cfoutput>
	<cfquery name="newLink" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		INSERT INTO publication_url (
		publication_url_id,
		publication_id,
		link,
		description)
		values (
		sq_publication_url_id.nextval,
		#publication_id#,
		'#link#',
		'#description#'
		)
	</cfquery>	
	<cflocation url="Publication.cfm?Action=editJournalArt&publication_id=#publication_id#">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->
<!---------------------------------------------------------------------------->
<cfif #Action# is "SaveJournArtChanges">
	<cfoutput>
	<cftransaction>
	<cfquery name="uJ" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	UPDATE journal_article SET publication_id=#publication_id#
		<cfif len(journal_id) gt 0>
			,journal_id=#journal_id#
		</cfif>
		<cfif len(begins_page_number) gt 0>
			,begins_page_number='#begins_page_number#'
		</cfif>
		<cfif len(ends_page_number) gt 0>
			,ends_page_number='#ends_page_number#'
		</cfif>
		<cfif len(volume_number) gt 0>
			,volume_number='#volume_number#'
			<cfelse>
			,volume_number = null
		</cfif>
		<cfif len(issue_number) gt 0>
			,issue_number='#issue_number#'
		<cfelse>
			,issue_number = null
		</cfif>
		where publication_id=#publication_id#
		</cfquery>
		
		<cfquery name="uJP" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	UPDATE publication SET publication_id=#publication_id#
		<cfif len(#Remarks#) gt 0>
			,publication_remarks='#Remarks#'
		<cfelse>
			,publication_remarks=NULL
		</cfif>
		,publication_title = '#publication_title#'
	where publication_id=#publication_id#
	</cfquery>
	PDATE publication SET publication_id=#publication_id#
		<cfif len(#Remarks#) gt 0>
			,publication_remarks='#Remarks#'
		<cfelse>
			,publication_remarks=NULL
		</cfif>
		,publication_title = '#publication_title#'
	where publication_id=#publication_id#
	
	
	</cftransaction>
	<cflocation url="Publication.cfm?Action=editJournalArt&publication_id=#publication_id#">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->
<!---------------------------------------------------------------------------->
<cfif #Action# is "saveJourEdit">
	<cfoutput>
	<cfquery name="uJ" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	UPDATE journal SET  
	journal_name = '#journal_name#'
	<cfif len(#journal_abbreviation#) gt 0>
		,journal_abbreviation='#journal_abbreviation#'
	</cfif>
	<cfif len(#publisher_name#) gt 0>
		,publisher_name='#publisher_name#'
	</cfif>
	where journal_id=#journal_id#
	</cfquery>
	<cflocation url="Publication.cfm?Action=editJournal&journal_id=#journal_id#">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->
<!---------------------------------------------------------------------------->
<cfif #Action# is "delPubAuth">
	<cfoutput>
	<cfquery name="dp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	delete from publication_author_name where publication_id=#publication_id# and
	agent_name_id = #agent_name_id#
	</cfquery>
	<cflocation url="Publication.cfm?Action=#caller#&publication_id=#publication_id#">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->
<!---------------------------------------------------------------------------->
<cfif #Action# is "SaveBookChanges">
	<cfoutput>
	<cftransaction>
	<cfquery name="ub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	UPDATE book SET publication_id=#publication_id#
		<cfif len(Volume) gt 0>
			,volume_number='#Volume#'
		</cfif>
		<cfif len(Pages) gt 0>
			,page_total='#Pages#'
		</cfif>
		<cfif len(Publisher) gt 0>
			,publisher_name='#Publisher#'
		</cfif>
		<cfif len(Edited) gt 0>
			,edited_work_fg='#Edited#'
		</cfif>
		where publication_id=#publication_id#
		</cfquery>
	<cfquery name="ubp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	UPDATE publication SET publication_id=#publication_id#
		<cfif len(Remarks) gt 0>
			,publication_remarks='#Remarks#'
		</cfif>
		,publication_title = '#publication_title#'
	where publication_id=#publication_id#
		</cfquery>
	</cftransaction>
		<cflocation url="Publication.cfm?Action=editBook&publication_id=#publication_id#">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->
<!---------------------------------------------------------------------------->
<cfif #Action# is "saveSectionEdits">
	<cfoutput>
	<cftransaction>
	<cfquery name="ubs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	UPDATE book_section SET publication_id=#publication_id#
		<cfif len(book_section_type) gt 0>
			,book_section_type='#book_section_type#'
		</cfif>
		<cfif len(begins_page_number) gt 0>
			,begins_page_number='#begins_page_number#'
		</cfif>
		<cfif len(ends_page_number) gt 0>
			,ends_page_number='#ends_page_number#'
		</cfif>
		<cfif len(book_section_order) gt 0>
			,book_section_order='#book_section_order#'
		</cfif>
		where publication_id=#publication_id#
		</cfquery>
		<cfquery name="ubsp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			
	
	UPDATE publication SET publication_id=#publication_id#
		<cfif len(published_year) gt 0>
			,published_year='#published_year#'
		  <cfelse>
		  ,published_year=null
		  </cfif>
		
		<cfif len(Remarks) gt 0>
			,publication_remarks='#Remarks#'
		<cfelse>
			,publication_remarks=null
		</cfif>
		<cfif len(publication_title) gt 0>
			,publication_title='#publication_title#'
		<cfelse>
			,publication_title=null
		</cfif>
	where publication_id=#publication_id#
	</cfquery>
	</cftransaction>
		<cflocation url="Publication.cfm?Action=editBookSection&publication_id=#publication_id#">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->
<!---------------------------------------------------------------------------->
<cfif #Action# is "newbooksec">
	<cfoutput>
	<cftransaction>
		<cfquery name="nextPub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select sq_publication_id.nextval nextID from dual
		</cfquery>
	
	<cfquery name="nbsP" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			INSERT INTO publication (
				publication_id
				,publication_type
				,publication_title
				<cfif len(#published_year#) gt 0>
					,published_year
				</cfif>
				<cfif len(#publication_remarks#) gt 0>
					,publication_remarks
				</cfif>)
			VALUES (
				#nextPub.nextID#
				,'Book Section'
				,'#publication_title#'
				<cfif len(#published_year#) gt 0>
					,#published_year#
				</cfif>
				<cfif len(#publication_remarks#) gt 0>
					,'#publication_remarks#'
				</cfif>)

	</cfquery>
	<cfquery name="nbs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	INSERT INTO book_section (
		PUBLICATION_ID,
		book_id,
		book_section_type
		<cfif len(#begins_page_number#) gt 0>
			,begins_page_number
		</cfif>
		<cfif len(#ends_page_number#) gt 0>
			,ends_page_number
		</cfif>
		<cfif len(#book_section_order#) gt 0>
			,book_section_order
		</cfif>
		)
	VALUES (
		#nextPub.nextID#,
		#book_id#,
		'chapter'
		<cfif len(#begins_page_number#) gt 0>
			,#begins_page_number#
		</cfif>
		<cfif len(#ends_page_number#) gt 0>
			,#ends_page_number#
		</cfif>
		<cfif len(#book_section_order#) gt 0>
			,#book_section_order#
		</cfif>
		)
	</cfquery>
	</cftransaction>
		<cflocation url="Publication.cfm?Action=editBookSection&publication_id=#nextPub.nextID#">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->

<!---------------------------------------------------------------------------->
<cfif #Action# is "changePubAuth">
	<cfoutput>
	<cfquery name="upa" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	UPDATE publication_author_name SET 
	<cfif len(#newagent_name_id#) gt 0>
		agent_name_id=#newagent_name_id#,
	</cfif>author_position=#author_position# where
	publication_id=#publication_id# and agent_name_id=#agent_name_id#
	</cfquery>
	
	<cflocation url="Publication.cfm?Action=#caller#&publication_id=#publication_id#">
	</cfoutput>
	

</cfif>
<!---------------------------------------------------------------------------->

<!---------------------------------------------------------------------------->
<cfif #Action# is "killJournalArticle">
	<cfoutput>
	<cftransaction>
		<cfquery name="killja" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			delete from journal_article where publication_id = #publication_id#
		</cfquery>
		<cfquery name="killpub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			delete from publication where publication_id = #publication_id#
		</cfquery>
		<cfquery name="killpubauth" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			delete from publication_author_name where publication_id = #publication_id#
		</cfquery>
	</cftransaction>
	
	
	<cflocation url="PublicationSearch.cfm">
	</cfoutput>
	

</cfif>
<!---------------------------------------------------------------------------->
<!---------------------------------------------------------------------------->
<cfif #Action# is "newPubAuth">
	<cfoutput>
	<cfquery name="npa" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	INSERT INTO  publication_author_name (publication_id,agent_name_id,author_position)
		VALUES (#publication_id#,#newAuthId#,#author_position#)
	</cfquery>
	<cflocation url="Publication.cfm?Action=#caller#&publication_id=#publication_id#">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->
<cfinclude template="includes/_footer.cfm">
