<cfoutput>
	<cfquery name="ctterm" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select distinct(TERM) term FROM cf_relations_cache ORDER BY TERM
	</cfquery>
	<table id="t_relationships" class="ssrch">
		<tr>
			<td class="lbl">
				<span class="helpLink" id="_related_term_1">Term:</span>
			</td>
			<td class="srch">
				<select name="related_term_1" id="related_term_1" size="1">
					<option value=""></option>
						<cfloop query="ctterm">
							<option value="#ctterm.term#">#ctterm.term#</option>
						</cfloop>
				  </select>
			</td>
		</tr>
		<tr>
			<td class="lbl">
				<span class="helpLink" id="_related_term_val_1">Value:</span>
			</td>
			<td class="srch">
				<input type="text" name="related_term_val_1" size="60">
			</td>
		</tr>
	</table>
</cfoutput>