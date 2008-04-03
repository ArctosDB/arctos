<script type='text/javascript' src='/includes/SpecSearch/jqLoad.js'></script>	
<table id="t_identifiers" class="ssrch">	
	<cfif len(#exclusive_collection_id#) gt 0>
		<cfset oidTable = "cCTCOLL_OTHER_ID_TYPE#exclusive_collection_id#">
	<cfelse>
		<cfset oidTable = "CTCOLL_OTHER_ID_TYPE">
	</cfif>
	<cfoutput>
		<cfquery name="OtherIdType" datasource="#Application.web_user#">
			select distinct(other_id_type) FROM #oidTable# ORDER BY other_Id_Type
		</cfquery>
	</cfoutput>
	<tr>					
		<td class="lbl">
			<span class="helpLink" id="other_id_type">Other&nbsp;Identifier&nbsp;Type:</span>
		</td>
		<td class="srch">
			<select name="OIDType" size="1"
				<cfif isdefined("OIDType") and len(#OIDType#) gt 0>
					class="reqdClr" </cfif>>
				<option value=""></option>
				<cfoutput query="OtherIdType">
					<option 
						<cfif isdefined("OIDType") and len(#OIDType#) gt 0>
							<cfif #OIDType# is #OtherIdType.other_id_type#>
								selected
							</cfif>
						</cfif>
						value="#OtherIdType.other_id_type#">#OtherIdType.other_id_type#</option>
				</cfoutput> 
			</select><span class="infoLink" 
				  				onclick="getCtDoc('ctcoll_other_id_type',SpecData.OIDType.value);">Define</span>
		</td>
	</tr>
	<cfquery name="OtherIdType" datasource="#Application.web_user#">
		select distinct(other_id_type) FROM ctColl_Other_Id_Type ORDER BY other_Id_Type
	</cfquery>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="other_id_num">Other&nbsp;Identifying&nbsp;Number:</span>
		</td>
		<td class="srch">
			<select name="oidOper" size="1">
				<option value="" selected="selected">contains</option>
				<option value="IS">is</option>
			</select>
			<cfif #ListContains(client.searchBy, 'bigsearchbox')# gt 0>
				<textarea name="OIDNum" rows="6" cols="30" wrap="soft"></textarea>
			<cfelse>
				<input type="text" name="OIDNum" size="34">
			</cfif>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="accn_number">Accession:</span>
		</td>
		<td class="srch">
			<input type="text" name="accn_number" >
			<span class="smaller">&nbsp;Exact Match?</span> <input type="checkbox" name="exactAccnNumMatch" value="1">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="accession_agency">Accession Agency:</span>
		</td>
		<td>
			<input type="text" name="accn_agency" size="50">
		</td>
	</tr>
</table>