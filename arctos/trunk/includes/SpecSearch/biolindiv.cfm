<cfoutput>
<cfquery name="ctbiol_relations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select biol_indiv_relationship  from ctbiol_relations
</cfquery>
<cfif isdefined("session.portal_id") and session.portal_id gt 0>
	<cftry>
		<cfquery name="ctAttributeType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select distinct(attribute_type) from cctattribute_type#session.portal_id# order by attribute_type
		</cfquery>
		<cfcatch>
			<cfquery name="ctAttributeType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
				select distinct(attribute_type) from ctattribute_type order by attribute_type
			</cfquery>
		</cfcatch>
	</cftry>
<cfelse>
	<cfquery name="ctAttributeType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select distinct(attribute_type) from ctattribute_type order by attribute_type
	</cfquery>
</cfif>		
<table id="t_identifiers" class="ssrch">
	<tr>
		<td class="lbl">
			<span class="helpLink" id="biol_indiv_relationship">Relationship:</span>
		</td>
		<td class="srch">
			<select name="relationship" id="relationship" size="1">
				<option value=""></option>
				<cfloop query="ctbiol_relations">
					<option value="#ctbiol_relations.biol_indiv_relationship#">
						#ctbiol_relations.biol_indiv_relationship#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_derived_relationship">Derived Relationship:</span>
		</td>
		<td class="srch">
			<select name="derived_relationship" id="derived_relationship" size="1">
				<option value=""></option>
					<option value="offspring of">offspring of</option>
			</select>	
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink infoLink" id="attribute_type">Help</span>
			<select name="attribute_type_1" id="attribute_type_1" size="1">
				<option selected value=""></option>
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
			<input name="ocr_text" id="ocr_text" size="1">
		</td>
	</tr>
</table>
</cfoutput>