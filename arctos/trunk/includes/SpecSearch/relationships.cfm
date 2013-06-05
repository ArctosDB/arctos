<cfoutput>
	<cfif isdefined("session.portal_id") and session.portal_id gt 0>
		<cftry>
			<cfquery name="OtherIdType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
				select distinct(other_id_type) FROM CCTCOLL_OTHER_ID_TYPE#session.portal_id# ORDER BY other_Id_Type
			</cfquery>
			<cfcatch>
				<cfquery name="OtherIdType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
					select distinct(other_id_type) FROM CTCOLL_OTHER_ID_TYPE ORDER BY other_Id_Type
				</cfquery>
			</cfcatch>
		</cftry>
	<cfelse>
		<cfquery name="OtherIdType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select distinct(other_id_type) FROM CTCOLL_OTHER_ID_TYPE ORDER BY other_Id_Type
		</cfquery>
	</cfif>
	<cfquery name="ctterm" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select distinct(TERM) term FROM cf_relations_cache ORDER BY TERM
	</cfquery>
	<table id="t_relationships" class="ssrch">
		<td class="lbl">
			<span class="helpLink" id="other_id_type">Related&nbsp;Identifier&nbsp;Type:</span>
		</td>
		<td class="srch">
			<select name="RelatedOIDType" id="RelatedOIDType">
				<option value=""></option>
				<cfoutput query="OtherIdType">
					<option value="#replace(OtherIdType.other_id_type,",","|","all")#">#OtherIdType.other_id_type#</option>
				</cfoutput>
			</select>
		</td>
	</tr>
		<tr>
			<td class="lbl">
				<span class="helpLink" id="_related_term">Term:</span>
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
				<span class="helpLink" id="_related_term_val">Value:</span>
			</td>
			<td class="srch">
				<input type="text" name="related_term_val_1" id="related_term_val_1" size="60">
			</td>
		</tr>
	</table>
</cfoutput>