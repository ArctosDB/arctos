<cfinclude template="includes/_header.cfm">
<script>
	function validateThis(v,msg) {
		alert('v:' + v + ';msg:' + msg)
	}
	function deleteAuth (form,n,a) {
		if (form=='pub') {
			var s1='authorName_' + n;
			var s2='agent_name_id_' + n;
		} else if (form=='sec'){
			var s1='section_' + n + '_author_' + a;
			var s2='section_' + n + '_agent_name_id_' + a;
		} else {
			alert('I have no idea what you are trying to do.');
		}
		var agntFld=document.getElementById(s1);
		agntFld.value='DELETED';
		var agntIdFld=document.getElementById(s2);
		agntIdFld.value='-1';	
	}
	
	function promoteAuth (form,n,a) {
		if (form=='pub') {
			try {
				var m=parseInt(n)-parseInt(1);
				var s1='author_' + n;
				var s2='agent_name_id_' + n;
				var n1='author_' + m;
				var n2='agent_name_id_' + m;
			}
			catch(e) {
				alert('What??' + e)
			}
		} else if (form=='sec'){
			var m=parseInt(a)-parseInt(1);
			var s1='section_' + n + '_author_' + m;
			var s2='section_' + n + '_agent_name_id_' + m;
			var n1='section_' + n + '_author_' + a;
			var n2='section_' + n + '_agent_name_id_' + a;			
		} else {
			alert('I have no idea what you are trying to do.');
		}
		var s1e=document.getElementById(s1);
		var s2e=document.getElementById(s2);
		var n1e=document.getElementById(n1);
		var n2e=document.getElementById(n2);
		var s1v=s1e.value;
		var s2v=s2e.value;
		var n1v=n1e.value;
		var n2v=n2e.value;
		s1e.value=n1v;
		s2e.value=n2v;
		n1e.value=s1v;
		n2e.value=s2v;
	}
	
	function demoteAuth (form,n,a) {
		if (form=='pub') {
			try {
				var m=parseInt(n)+parseInt(1);
				var s1='author_' + n;
				var s2='agent_name_id_' + n;
				var n1='author_' + m;
				var n2='agent_name_id_' + m;
						
			}
			catch(e) {
				alert('What??' + e)
			}
		} else if (form=='sec'){
			var m=parseInt(a)+parseInt(1);
			var s1='section_' + n + '_author_' + m;
			var s2='section_' + n + '_agent_name_id_' + m;
			var n1='section_' + n + '_author_' + a;
			var n2='section_' + n + '_agent_name_id_' + a;
		} else {
			alert('I have no idea what you are trying to do.');
		}
		var s1e=document.getElementById(s1);
		var s2e=document.getElementById(s2);
		var n1e=document.getElementById(n1);
		var n2e=document.getElementById(n2);
		var s1v=s1e.value;
		var s2v=s2e.value;
		var n1v=n1e.value;
		var n2v=n2e.value;
		s1e.value=n1v;
		s2e.value=n2v;
		n1e.value=s1v;
		n2e.value=s2v;
	}
</script>
<cfif #action# is "nothing">
<cfset title="Edit Book">
	<cfoutput>
		<cfquery name="getBook" datasource="#Application.web_user#">
			 SELECT * from 
			 book, 
			 publication, 
			 publication_author_name, 
			 agent_name
			 where book.publication_id=publication.publication_id and
			 publication.publication_id = publication_author_name.publication_id (+) and
			 publication_author_name.agent_name_id = agent_name.agent_name_id (+) and
			 book.publication_id=#publication_id#
		</cfquery>
		<cfquery name="getBookSec" datasource="#Application.web_user#">
			select 
				book_section.publication_id, 
				publication_title,
				book_id,
				book_section_type,
				begins_page_number,
				ends_page_number,
				book_section_order,
				publication_remarks,
				agent_name,
				agent_name.agent_name_id,
				author_position,
				published_year
			 from book_section, publication, publication_author_name, agent_name
			 where book_section.publication_id=publication.publication_id and
			 publication.publication_id = publication_author_name.publication_id (+) and
			 publication_author_name.agent_name_id = agent_name.agent_name_id (+) and
			 book_id=#publication_id#
			 order by publication_id			 
		</cfquery>		
		<cfquery name="distSecs" dbtype="query">
			select 
				publication_id, 
				book_id,
				book_section_type,
				begins_page_number,
				ends_page_number,
				book_section_order,
				publication_remarks,
				publication_title,
				published_year
			FROM 
				getBookSec
			GROUP BY
				publication_id, 
				book_id,
				book_section_type,
				begins_page_number,
				ends_page_number,
				book_section_order,
				publication_remarks,
				publication_title,
				published_year
			order by
				book_section_order
		</cfquery>
		<cfquery name="getAuths" dbtype="query">
			select agent_name, agent_name_id, author_position from getBook
			order by author_position
		</cfquery>
	<table>
	<cfform name="book" method="post" action="editBook.cfm">
		<input type="hidden" name="Action" value="SaveBookChanges">
		<input type="hidden" name="publication_id" value="#getBook.publication_id#">
		<tr class='oddRow'>
			<td>
				<label for="publication_title">Book Title</label>
				<cftextarea name="publication_title" id="publication_title" 
					cols="45" rows="3" class="reqdClr"
					required="true" message="Publication title is required">#getBook.publication_title#</cftextarea>
				<label for="publisher">Book Publisher</label>
				<input type="text" name="publisher" id="publisher" value="#getBook.publisher_name#" size="60">
				<label for="remarks">Book Remark</label>
				<input type="text" name="remarks" id="remarks" value="#getBook.publication_remarks#" size="60">
				<table width="100%">
					<tr>
						<td>
							<label for="edited">Edited?</label>
							<select name="edited" id="edited" size="1" class="reqdClr">
								<option value="1">yes</option>
								<option <cfif #getBook.edited_work_fg# is "0"> selected </cfif>value="0">no</option>
							</select>
						</td>
						<td>
							<label for="edited">Volume</label>
							<cfinput type="text" name="volume" id="volume" value="#getBook.volume_number#" size="5" 
								validate="integer" message="Volume is an integer.">
						</td>
						<td>
							<label for="pages">Number of Pages</label>
							<cfinput type="text" name="pages" id="pages" value="#getBook.page_total#" size="4"
								message="Number of Pages is an integer." validate="integer">
						</td>
						<td>
							<label for="published_year">Published Year</label>
							<cfinput type="text" name="published_year" id="published_year" 
								value="#getBook.published_year#" size="4"
								message="Published Year is a positive 4-digit integer." validate="integer" mask="9999">
						</td>
					</tr>
				</table>				
			</td>
			<td valign="top">
				<table>
				<cfset i=1>
				<cfloop query="getAuths">
					<tr>
						<td>
							<label for="author_#i#">Author #i#</label>
							<input type="text" 
								name="author_#i#" 
								id="author_#i#"
								value="#getAuths.agent_name#"
								class="reqdClr" 
								onchange="findAgentName('agent_name_id_#i#','author_#i#','book',this.value); return false;"
				 				onKeyPress="return noenter(event);">
							<cfinput type="hidden" name="agent_name_id_#i#"
								id="agent_name_id_#i#" value="#getAuths.agent_name_id#" 
								required="true" validate="integer"
								message="Author #i# pick seems to be bad.">
						</td>
						<td>
							<span class="infoLink" onclick="deleteAuth('pub','#i#')">Delete</span>
							<cfif i gt 1>
								<span class="infoLink" onclick="promoteAuth('pub','#i#')">Move Up</span>
							</cfif>
							<cfif i lt getAuths.recordcount>
								<span class="infoLink" onclick="demoteAuth('pub','#i#')">Move Down</span>
							</cfif>
						</td>
					</tr>
					<cfset i=i+1>
				</cfloop>
				<cfset numberBookAuthors=i-1>
				<input type="hidden" name="numberBookAuthors" id="numberBookAuthors" value="#numberBookAuthors#">
				<tr class="newRec">
					<td>
						<label for="author_n">New Author</label>
						<input type="text" 
							name="author_n" 
							id="author_n"
							class="reqdClr" 
							onchange="findAgentName('agent_name_id_n','author_n','book',this.value); return false;"
			 				onKeyPress="return noenter(event);">
						<input type="hidden" name="agent_name_id_n"
							id="agent_name_id_n">
					</td>
					<td>
						
					</td>
				</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td colspan="2" style="padding-left:50px;">Book Sections</td>
		</tr>
		<cfset s=1>
		<cfloop query="distSecs">
			<tr #iif(s MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
				<td  style="padding-left:50px;">
					<input type="hidden" name="publication_id_#s#" id="publication_id_#s#" value="#publication_id#">
					<label for="book_section_order_#s#">Section Order</label>
					<cfinput type="text" 
						name="book_section_order_#s#" 
						id="book_section_order_#s#" 
						value="#book_section_order#"
						validate="integer" message="Section Order is an integer.">
					<span class="infoLink" onclick="document.getElementById('book_section_order_#s#').value='DELETE'">Delete Section</span>
					<label for="book_section_order_#s#">Section Title</label>
					<cftextarea name="publication_title_#s#" 
						id="publication_title_#s#" rows="4" cols="50" 
						required="true" message="Section Title is required." 
						class="reqdClr">#publication_title#</cftextarea>
					<label for="remarks_#s#">Section Remarks</label>
					<input type="text" name="remarks_#s#"
						id="remarks_#s#" value="#publication_remarks#" size="60">	
					<table width="100%">
						<tr>
							<td>
								<label for="published_year_#s#">Published Year</label>
								<cfinput type="text" name="published_year_#s#" size="4"
									id="published_year_#s#" value="#published_year#" validate="integer" 
									message="Published Year is an integer." mask="9999">
							</td>
							<td>
								<label for="begins_page_number_#s#">Begin Page</label>
								<cfinput type="text" name="begins_page_number_#s#" size="4"
									id="begins_page_number_#s#" value="#begins_page_number#"
									validate="integer" message="Begin Page is an integer.">		
							</td>
							<td>
								<label for="ends_page_number_#s#">End Page</label>
								<cfinput type="text" name="ends_page_number_#s#" size="4"
									id="ends_page_number_#s#" value="#ends_page_number#"
									validate="integer" message="End Page is an integer.">
							</td>
						</tr>
					</table>
				</td>
				<cfquery name="getSecAuths" dbtype="query">
					select agent_name, author_position, agent_name_id from getBookSec
					where publication_id=#publication_id#
					order by author_position
				</cfquery>
				<td valign="top">
					<cfset a=1>
					<table>						
						<cfloop query="getSecAuths">
							<tr>
								<td>
									<label for="section_#s#_author_#a#">Author #a#</label>
									<input type="text" 
										name="section_#s#_author_#a#" 
										id="section_#s#_author_#a#"
										value="#agent_name#"
										class="reqdClr" 
										onchange="findAgentName('section_#s#_agent_name_id_#a#','section_#s#_author_#a#','book',this.value); return false;"
				 						onKeyPress="return noenter(event);">
									<input type="hidden" name="section_#s#_agent_name_id_#a#"
										id="section_#s#_agent_name_id_#a#" value="#agent_name_id#">
								</td>
								<td>
									<span class="infoLink" onclick="deleteAuth('sec','#s#','#a#')">Delete</span>
									<cfif a gt 1>
										<span class="infoLink" onclick="promoteAuth('sec','#s#','#a#')">Move Up</span>
									</cfif>
									<cfif a lt getSecAuths.recordcount>
										<span class="infoLink" onclick="demoteAuth('sec','#s#','#a#')">Move Down</span>
									</cfif>
								</td>
							</tr>
							<cfset a=a+1>
						</cfloop>
						<cfset numberSectionAuthors=a-1>
						<input type="hidden" name="numberSectionAuthors_#s#" id="numberSectionAuthors_#s#" value="#numberSectionAuthors#">
						<tr class="newRec">
							<td>
								<label for="section_#s#_author_n">New Author</label>
								<input type="text" 
									name="section_#s#_author_n" 
									id="section_#s#_author_n"
									class="reqdClr" 
									onchange="findAgentName('section_#s#_agent_name_id_n','section_#s#_author_n','book',this.value); return false;"
					 				onKeyPress="return noenter(event);">
								<input type="hidden" name="section_#s#_agent_name_id_n"
									id="section_#s#_agent_name_id_n">
							</td>
							<td>								
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<cfset s=s+1>
		</cfloop>
		<cfset numberSections=s-1>
		<input type="hidden" name="numberSections" id="numberSections" value="#numberSections#">
		<tr>
			<td colspan="2" style="padding-left:100px;">Add a Section</td>
		</tr>		
		<tr class="newRec">
				<td style="padding-left:100px;">
					<label for="book_section_order_n">Section Order</label>
					<input type="text" 
						name="book_section_order_n" 
						id="book_section_order_n" 
						value="#i#">
					<label for="publication_title_n">Section Title</label>
					<textarea name="publication_title_n" 
						id="publication_title_n" rows="4" cols="50" 
						class="reqdClr"></textarea>
					<label for="remarks_n">Section Remarks</label>
					<input type="text" name="remarks_n"
						id="remarks_n" size="60">
					<table width="100%">
						<tr>
							<td>
								<label for="published_year_n">Published Year</label>
								<cfinput type="text" name="published_year_n" validate="integer" mask="9999"  size="4"
									id="published_year_n" message="Published Year is a 4-digit year.">
							</td>
							<td>
								<label for="begins_page_number_n">Begin Page</label>
								<cfinput type="text" name="begins_page_number_n"  size="4"
									id="begins_page_number_n" validate="integer" message="Begin Page is an integer.">
							</td>
							<td>
								<label for="ends_page_number_n">End Page</label>
								<cfinput type="text" name="ends_page_number_n"  size="4"
									id="ends_page_number_n" validate="integer" message="End Page is an integer.">
							</td>
						</tr>
					</table>					
				</td>
				<td valign="top">
					<table>
						<tr class="newRec">
							<td>
								<label for="section_n_author_n">New Author</label>
								<input type="text" 
									name="section_n_author_n" 
									id="section_n_author_n"
									class="reqdClr" 
									onchange="findAgentName('section_n_agent_name_id_n','section_n_author_n','book',this.value); return false;"
					 				onKeyPress="return noenter(event);">
								<input type="hidden" name="section_n_agent_name_id_n"
									id="section_n_agent_name_id_n">
							</td>
							<td>
								
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td colspan="2" align="center">
					<input type="submit" class="savBtn" value="Save all changes">
				</td>
			</tr>
			
		</cfform>
		
	</table>
		
		
		
	</cfoutput>
</cfif>
<cfif action is "SaveBookChanges">
<cfoutput>
<cftransaction>
	<cfquery name="upBook" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update 
			book
		set
			EDITED_WORK_FG=#EDITED#,
			VOLUME_NUMBER=#VOLUME#,
			PAGE_TOTAL='#PAGES#',
			PUBLISHER_NAME='#PUBLISHER#'
		where
			PUBLICATION_ID=#PUBLICATION_ID#
	</cfquery>
	<cfquery name="upBookPub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update 
			publication 
		set
			<cfif len(#published_year#) gt 0>
				PUBLISHED_YEAR=#published_year#,
			<cfelse>
				PUBLISHED_YEAR=NULL,
			</cfif>
			PUBLICATION_TYPE='Book',
			PUBLICATION_TITLE='#trim(stripQuotes(PUBLICATION_TITLE))#',
			PUBLICATION_REMARKS='#REMARKS#'
		where
			PUBLICATION_ID=#PUBLICATION_ID#
	</cfquery>
	<cfquery name="killAuth" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		delete from 
			publication_author_name
		where
			PUBLICATION_ID=#PUBLICATION_ID#
	</cfquery>
	<cfset agentPosition=1>
	<cfloop from="1" to="#NUMBERBOOKAUTHORS#" index="i">
		<cfset thisAgentId=evaluate("AGENT_NAME_ID_" & i)>
		<cfif len(thisAgentId) gt 0 and thisAgentId gt 0>
			<cfquery name="insPubAuth" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into publication_author_name (
					PUBLICATION_ID,
					AGENT_NAME_ID,
					AUTHOR_POSITION)
				values (
					#PUBLICATION_ID#,
					#thisAgentId#,
					#agentPosition#)
			</cfquery>
			<cfset agentPosition=agentPosition+1>
		</cfif>
	</cfloop>
	<cfif len(AGENT_NAME_ID_N) gt 0>
		<cfquery name="insPubAuth" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			insert into publication_author_name (
				PUBLICATION_ID,
				AGENT_NAME_ID,
				AUTHOR_POSITION)
			values (
				#PUBLICATION_ID#,
				#AGENT_NAME_ID_N#,
				#agentPosition#)
		</cfquery>
	</cfif>
	<cfloop from="1" to="#NUMBERSECTIONS#" index="s">
		<cfset thisPublicationId=evaluate("publication_id_" & s)>
		<cfset thisBeginPage=evaluate("BEGINS_PAGE_NUMBER_" & s)>
		<cfset thisEndPage=evaluate("ENDS_PAGE_NUMBER_" & s)>
		<cfset thisSectionOrder=evaluate("BOOK_SECTION_ORDER_" & s)>
		<cfset thisPubTitle=evaluate("PUBLICATION_TITLE_" & s)>
		<cfset thisRemark=evaluate("REMARKS_" & s)>
		<cfset thisPubYear=evaluate("PUBLISHED_YEAR_" & s)>
		<cfset thisNumAuths=evaluate("NUMBERSECTIONAUTHORS_" & s)>
		<cfif thisSectionOrder is "DELETE">
			<cfquery name="killSectionAuth" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				delete from publication_author_name where PUBLICATION_ID=#thisPublicationId#
			</cfquery>
			<cfquery name="killSection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				delete from book_section where PUBLICATION_ID=#thisPublicationId#
			</cfquery>
			<cfquery name="killPub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				delete from publication where PUBLICATION_ID=#thisPublicationId#
			</cfquery>
		<cfelse>
			<cfquery name="upSec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				update book_section set
					BOOK_SECTION_TYPE='Book Section'
					<cfif len(thisBeginPage) gt 0>
						,BEGINS_PAGE_NUMBER=#thisBeginPage#
					<cfelse>
						,BEGINS_PAGE_NUMBER=NULL
					</cfif>
					<cfif len(thisEndPage) gt 0>
						,ENDS_PAGE_NUMBER=#thisEndPage#
					<cfelse>
						,ENDS_PAGE_NUMBER=NULL
					</cfif>
					<cfif len(thisSectionOrder) gt 0>
						,BOOK_SECTION_ORDER=#thisSectionOrder#
					<cfelse>
						,BOOK_SECTION_ORDER=NULL
					</cfif>
				where
					PUBLICATION_ID=#thisPublicationId#
			</cfquery>
			<cfquery name="upSecPub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				update publication set
					<cfif len(#thisPubYear#) gt 0>
						PUBLISHED_YEAR=#thisPubYear#,
					<cfelse>
						PUBLISHED_YEAR=NULL,
					</cfif>
					PUBLICATION_TYPE='Book Section',
					PUBLICATION_TITLE='#thisPubTitle#',
					PUBLICATION_REMARKS='#thisRemark#'
				where
					PUBLICATION_ID=#thisPublicationId#
			</cfquery>
			<cfquery name="killSecAuth" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				delete from 
					publication_author_name
				where
					PUBLICATION_ID=#thisPublicationId#
			</cfquery>
			<cfset agentPosition=1>
			<cfloop from="1" to="#thisNumAuths#" index="i">
				<cfset thisAgentId=evaluate("SECTION_" & s & "_AGENT_NAME_ID_" & i)>
				<cfif len(thisAgentId) gt 0 and thisAgentId gt 0>
					<cfquery name="killSecAuth" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						insert into publication_author_name (
							PUBLICATION_ID,
							AGENT_NAME_ID,
							AUTHOR_POSITION)
						values (
							#thisPublicationId#,
							#thisAgentId#,
							#agentPosition#)
					</cfquery>					
					<cfset agentPosition=agentPosition+1>
				</cfif>
			</cfloop>
		</cfif>
		<cfset thisNewSecAuth=evaluate("SECTION_" & s & "_AGENT_NAME_ID_N")>
		<cfif len(thisNewSecAuth) gt 0>
			<cfquery name="killSecAuth" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into publication_author_name (
					PUBLICATION_ID,
					AGENT_NAME_ID,
					AUTHOR_POSITION)
				values (
					#thisPublicationId#,
					#thisNewSecAuth#,
					#agentPosition#)
			</cfquery>
		</cfif>
	</cfloop>
	<cfif len(#PUBLICATION_TITLE_N#) gt 0>
		<cfquery name="nPub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select sq_publication_id.nextval n from dual
		</cfquery>
		<cfset nextPubId=nPub.n>
		<cfquery name="nSectionPub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			insert into publication (
				PUBLICATION_ID,
				PUBLICATION_TYPE,
				PUBLICATION_TITLE
				<cfif len(PUBLISHED_YEAR_N) gt 0>
					,PUBLISHED_YEAR
				</cfif>
				<cfif len(REMARKS_N) gt 0>
					,PUBLICATION_REMARKS
				</cfif>
			) values (
				#nextPubId#,
				'Book Section',
				'#PUBLICATION_TITLE_N#'
				<cfif len(PUBLISHED_YEAR_N) gt 0>
					,#PUBLISHED_YEAR_N#
				</cfif>
				<cfif len(REMARKS_N) gt 0>
					,'#REMARKS_N#'
				</cfif>
			)
		</cfquery>
		<cfquery name="nSection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			insert into book_section (
				book_id,
				PUBLICATION_ID,
				BOOK_SECTION_TYPE
				<cfif len(BEGINS_PAGE_NUMBER_N) gt 0>
					,BEGINS_PAGE_NUMBER
				</cfif>
				<cfif len(ENDS_PAGE_NUMBER_N) gt 0>
					,ENDS_PAGE_NUMBER
				</cfif>
				<cfif len(BOOK_SECTION_ORDER_N) gt 0>
					,BOOK_SECTION_ORDER
				</cfif>
			) values (
				#publication_id#,
				#nextPubId#,
				'Book Section'
				<cfif len(BEGINS_PAGE_NUMBER_N) gt 0>
					,#BEGINS_PAGE_NUMBER_N#
				</cfif>
				<cfif len(ENDS_PAGE_NUMBER_N) gt 0>
					,#ENDS_PAGE_NUMBER_N#
				</cfif>
				<cfif len(BOOK_SECTION_ORDER_N) gt 0>
					,#BOOK_SECTION_ORDER_N#
				</cfif>
			)
		</cfquery>
		<cfif len(#SECTION_N_AGENT_NAME_ID_N#) gt 0>
			<cfquery name="nSectionPAuth" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into publication_author_name (
					PUBLICATION_ID,
					AGENT_NAME_ID,
					AUTHOR_POSITION)
				values (
					#nextPubId#,
					#SECTION_N_AGENT_NAME_ID_N#,
					1)
			</cfquery>
		</cfif>
	</cfif> 
</cftransaction>
<cflocation url="editBook.cfm?publication_id=#publication_id#" addtoken="false">	
</cfoutput>
</cfif>