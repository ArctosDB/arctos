<table id="t_identifiers" class="ssrch">
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
	</cfoutput>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="other_id_type">Other&nbsp;Identifier&nbsp;Type:</span>
		</td>
		<td class="srch">
			<label for="">Apple/click or Ctl/click to select multiple & match any</label>
			<select name="OIDType" id="OIDType" size="5" multiple="multiple"
				<cfif isdefined("OIDType") and len(OIDType) gt 0>
					class="reqdClr"
				</cfif>>
				<option value=""></option>
				<cfoutput query="OtherIdType">
					<option
						<cfif isdefined("OIDType") and len(OIDType) gt 0>
							<cfif OIDType is OtherIdType.other_id_type>
								selected="selected"
							</cfif>
						</cfif>
						value="#replace(OtherIdType.other_id_type,",","#chr(44)#","all")#">#OtherIdType.other_id_type#</option>
				</cfoutput>
			</select><span class="infoLink" onclick="getCtDoc('ctcoll_other_id_type',SpecData.OIDType.value);">Define</span>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="other_id_num">Other&nbsp;Identifier:</span>
		</td>
		<td class="srch">
			<select name="oidOper" id="oidOper" size="1">
				<option value="">contains</option>
				<option selected="selected" value="IS">is</option>
				<option value="list">in list</option>
			</select>
			<cfif ListContains(session.searchBy, 'bigsearchbox') gt 0>
				<textarea name="OIDNum" id="OIDNum" rows="6" cols="30" wrap="soft"></textarea>
			<cfelse>
				<input type="text" name="OIDNum" id="OIDNum" size="34">
			</cfif>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_accn_number">Accession:</span>
		</td>
		<td class="srch">
			<input type="text" name="accn_number" id="accn_number">
			<span class="infoLink" onclick="var e=document.getElementById('accn_number');e.value='='+e.value;">Add = for exact match</span>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="accession_agency">Accession Agency:</span>
		</td>
		<td>
			<input type="text" name="accn_agency" id="accn_agency" size="50">
		</td>
	</tr>
</table>