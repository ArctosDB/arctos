<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>

	<cfoutput>
	
	<table border>
		<tr>
			<th>Column Name</th>
			<th>What's it do?</th>
		</tr>
		<tr>
			<td>CF_VARIABLE</td>
			<td>Variable as used by Arctos applications, eg, in specimenresults mapurl</td>
		</tr>
		<tr>
			<td>DATA_TYPE</td>
			<td>"Human-readable" approximation of the datatype accepted by the variable, e.g., "comma-separated list of integers."</td>
		</tr>
		<tr>
			<td>DISPLAY_TEXT</td>
			<td>"Field label" - "Catalog Number" - keep it short.</td>
		</tr>
		<tr>
			<td>CODE_TABLE</td>
			<td>Controlling code table. Must be table name only - "ctage_class" - do not guess at this.</td>
		</tr>
		<tr>
			<td>PLACEHOLDER_TEXT</td>
			<td>Very short snippet to display in the HTML5 "placeholder" element.</td>
		</tr>
		<tr>
			<td>SEARCH_HINT</td>
			<td>Short "how it works" useful for guiding search.</td>
		</tr>
		<tr>
			<td>SPECIMEN_RESULTS_COL</td>
			<td>Is the element available as a column in specimenresults? Don't guess at this.</td>
		</tr>
		<tr>
			<td>DISP_ORDER</td>
			<td>Order (left to right) in which to display columns on specimenresults.</td>
		</tr>
		<tr>
			<td>CATEGORY</td>
			<td>Category on specimen results. Don't guess at this.</td>
		</tr>
		<tr>
			<td>SQL_ELEMENT</td>
			<td>SQL to use in building dynamic queries. Don't guess at this.</td>
		</tr>
		<tr>
			<td>DEFINITION</td>
			<td>Short-ish definition suitable for popup/tooltip documentation</td>
		</tr>
		<tr>
			<td>DOCUMENTATION_LINK</td>
			<td>Link to further documentation, probably on http://arctosdb.org/.</td>
		</tr>
	</table>
	

		
		<table border id="t" class="sortable">
			<tr>
				<th>CF_VARIABLE</th>
				<th>DATA_TYPE</th>
				<th>DISPLAY_TEXT</th>
				<th>CODE_TABLE</th>
				<th>DEFINITION</th>
				<th>PLACEHOLDER_TEXT</th>
				<th>SEARCH_HINT</th>
				<th>SPECIMEN_RESULTS_COL</th>
				<th>DISP_ORDER</th>
				<th>CATEGORY</th>
				<th>SQL_ELEMENT</th>
				<th>DEFINITION</th>
				<th>DOCUMENTATION_LINK</th>
			</tr>
			
			
			
		<cfquery name="cNames" datasource="uam_god">
			select column_name from user_tab_cols where lower(table_name)='ssrch_field_doc' order by internal_column_id
		</cfquery>
		<cfset ColNameList = valuelist(cNames.column_name)>
		<cfset ColNameList = replace(ColNameList,"SSRCH_FIELD_DOC_ID","","all")>
		<cfset args.width="1200">
		<cfset args.height="600">
		<cfset args.stripeRows = true>
		<cfset args.selectColor = "##D9E8FB">
		<cfset args.selectmode = "edit">
		<cfset args.format="html">
		<cfset args.name="blGrid">
		<cfset args.pageSize="20">
		<cfset args.onchange = "cfc:component.docs.editRecord({cfgridaction},{cfgridrow},{cfgridchanged})">
		<cfset args.bind="cfc:component.docs.getPage({cfgridpage},{cfgridpagesize},{cfgridsortcolumn},{cfgridsortdirection})">
		<cfset args.name="blGrid">
		<cfset args.pageSize="20">		
		<cfform method="post" action="field_documentation.cfm">
			<cfinput type="hidden" name="returnAction" value="ajaxGrid">
			<cfinput type="hidden" name="action" value="saveGridUpdate">
			<cfgrid attributeCollection="#args#">
				<cfloop list="#ColNameList#" index="thisName">
					<cfgridcolumn name="#thisName#">
				</cfloop>
			</cfgrid>
		</cfform>
		
		
		<!----
		
			<cfloop query="d">
				<tr>
					<td>
						<a href="field_documentation.cfm?action=edit&SSRCH_FIELD_DOC_ID=#SSRCH_FIELD_DOC_ID#">#CF_VARIABLE#</a>
					</td>
					<td>#display_name#</td>
					<td>#definition#</td>
					<td>#search_hint#</td>
					<td>#more_info#</td>
				</tr>
			</cfloop>
		</table>
		
		
		---->
	</cfoutput>
	


<cfabort>


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
 						   NOT NULL VARCHAR2(4000)



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