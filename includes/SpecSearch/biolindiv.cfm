<cfoutput>
<cfif isdefined("session.portal_id") and session.portal_id gt 0>
	<cftry>
		<cfquery name="ctAttributeType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select distinct(attribute_type) from cctattribute_type#session.portal_id# order by attribute_type
		</cfquery>
		<cfcatch>
			<cfquery name="ctAttributeType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
				select distinct(attribute_type) from ctattribute_type order by attribute_type
			</cfquery>
		</cfcatch>
	</cftry>
<cfelse>
	<cfquery name="ctAttributeType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select distinct(attribute_type) from ctattribute_type order by attribute_type
	</cfquery>
</cfif>
<table id="t_identifiers" class="ssrch">
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_part_remark">Part Remark:</span>
		</td>
		<td class="srch">
			<input type="text" name="part_remark" id="part_remark">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink infoLink" id="attribute_type">Help</span>
			<select name="attribute_type_1" id="attribute_type_1" size="1">
				<option selected value="">[ pick an attribute ]</option>
					<cfloop query="ctAttributeType">
						<option value="#ctAttributeType.attribute_type#">#ctAttributeType.attribute_type#</option>
					</cfloop>
			  </select>
		</td>
		<td class="srch">
			<select name="attOper_1" id="attOper_1" size="1">
				<option selected value="">equals</option>
				<option value="like">contains</option>
				<option value="greater">greater than</option>
				<option value="less">less than</option>
			</select>
			<input type="text" name="attribute_value_1" size="20">
			<span class="infoLink"
				onclick="windowOpener('/info/attributeHelpPick.cfm?attNum=1&attribute='+SpecData.attribute_type_1.value,'attPick','width=600,height=600, resizable,scrollbars');">
				Pick
			</span>
			<input type="text" name="attribute_units_1" size="6">(units)
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="ocr_text">OCR Text:</span>
		</td>
		<td class="srch">
			<input name="ocr_text" id="ocr_text" size="80">
		</td>
	</tr>
</table>
</cfoutput>