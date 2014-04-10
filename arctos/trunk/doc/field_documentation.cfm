<cfinclude template="/includes/_header.cfm">

	<cfoutput>
	
	<table border>
		<tr>
			<th>Column Name</th>
			<th>What's it do?</th>
		</tr>
		<tr>
			<td>CF_VARIABLE</td>
			<td>cfvar here</td>
		</tr>
			<th>CATEGORY</th>
			<th>CODE_TABLE</th>
			<th>DATA_TYPE</th>
			<th>DEFINITION</th>
			<th>DISPLAY_TEXT</th>
			<th>DISP_ORDER</th>
			<th>DOCUMENTATION_LINK</th>
			<th>PLACEHOLDER_TEXT</th>
			<th>SEARCH_HINT</th>
			<th>SPECIMEN_RESULTS_COL</th>
			<th>SQL_ELEMENT</th>
			<th>DEFINITION</th>
			<th>DEFINITION</th>
		</tr>
		<tr>
			<td></td>
		</tr>
	</table>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from ssrch_field_doc order by colname
		</cfquery>
		<table border>
			<tr>
				<th>CF_VARIABLE</th>
				<th>CATEGORY</th>
				<th>CODE_TABLE</th>
				<th>DATA_TYPE</th>
				<th>DEFINITION</th>
				<th>DISPLAY_TEXT</th>
				<th>DISP_ORDER</th>
				<th>DOCUMENTATION_LINK</th>
				<th>PLACEHOLDER_TEXT</th>
				<th>SEARCH_HINT</th>
				<th>SPECIMEN_RESULTS_COL</th>
				<th>SQL_ELEMENT</th>
				<th>DEFINITION</th>
				<th>DEFINITION</th>
			</tr>
			<cfloop query="d">
				<tr>
					<td>
						<a href="short_doc.cfm?action=edit&short_doc_id=#short_doc_id#">#ColName#</a>
					</td>
					<td>#display_name#</td>
					<td>#definition#</td>
					<td>#search_hint#</td>
					<td>#more_info#</td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
	



								    VARCHAR2(4000)
 							   NOT NULL VARCHAR2(4000)
 								    VARCHAR2(4000)
 								    VARCHAR2(4000)
 								    VARCHAR2(4000)
 								    VARCHAR2(4000)
 								    VARCHAR2(4000)
 							    VARCHAR2(4000)
 							    VARCHAR2(4000)
 								    VARCHAR2(4000)
 							    VARCHAR2(4000)
 								    VARCHAR2(4000)
 SSRCH_FIELD_DOC_ID						   NOT NULL VARCHAR2(4000)



<cfif action is "new">
	<form name="d" method="post" action="short_doc.cfm">
		<input type="hidden" name="action" value="insert">
		<label for="colname">ColName</label>
		<input type="text" name="colname" id="colname" size="60">
		
		<label for="display_name">display_name</label>
		<input type="text" name="display_name" id="display_name" size="60">
		
		<label for="definition">definition</label>
		<textarea rows="4" cols="50" name="definition" id="definition"></textarea>

		<label for="search_hint">search_hint</label>
		<input type="text" name="search_hint" id="search_hint" size="60">
		<label for="more_info">MoreInfo</label>
		<input type="text" name="more_info" id="more_info" size="60">
		<br><input type="submit" value="create record">
	</form>
</cfif>

<cfif action is "insert">
	<cfoutput>
		<cfquery name="id" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select sq_short_doc_id.nextval id from dual
		</cfquery>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into short_doc
				(
					short_doc_id,
					colname,
					display_name,
					definition,
					search_hint,
					more_info
				) values (
					#id.id#,
					'#colname#',
					'#display_name#',
					'#escapeQuotes(definition)#',
					'#escapeQuotes(search_hint)#',
					'#more_info#'
				)
		</cfquery>
		<cflocation addtoken="false" url="short_doc.cfm?action=edit&short_doc_id=#id.id#">
	</cfoutput>
</cfif>
<cfif action is "edit">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from short_doc where short_doc_id=#short_doc_id#
	</cfquery>
	<cfoutput>
	<form name="d" method="post" action="short_doc.cfm">
		<input type="hidden" name="action" value="saveEdit">
		<input type="hidden" name="short_doc_id" value="#d.short_doc_id#">
		<label for="colname">ColName</label>
		<input type="text" name="colname" id="colname" value="#d.colname#" size="60">
		
		<label for="display_name">display_name</label>
		<input type="text" name="display_name" id="display_name" value="#d.display_name#" size="60">
		
		<label for="definition">definition</label>
		<textarea rows="4" cols="50" name="definition" id="definition">#d.definition#</textarea>

		<label for="search_hint">search_hint</label>
		<input type="text" name="search_hint" id="search_hint" value="#d.search_hint#"  size="60">
		<label for="more_info">MoreInfo</label>
		<input type="text" name="more_info" id="more_info" value="#d.more_info#"   size="60">
		<br><input type="submit" value="save edits">
		<a href="short_doc.cfm?action=delete&short_doc_id=#short_doc_id#">[ delete this record ]</a>
	</form>
	</cfoutput>
</cfif>

<cfif action is "delete">
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from short_doc where short_doc_id=#short_doc_id#
		</cfquery>
		deleted
	</cfoutput>
</cfif>
<cfif action is "saveEdit">
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update short_doc set
			ColName='#ColName#',
			display_name='#display_name#',
			definition='#escapeQuotes(definition)#',
			search_hint='#escapeQuotes(search_hint)#',
			more_info='#more_info#'
			where short_doc_id=#short_doc_id#
		</cfquery>
		<cflocation addtoken="false" url="short_doc.cfm?action=edit&short_doc_id=#short_doc_id#">
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">