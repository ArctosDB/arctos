<table id="t_identifiers">
				<cfif isdefined("Client.CustomOtherIdentifier") and len(#Client.CustomOtherIdentifier#) gt 0>
					<tr>
						<td align="right" width="250">
							<a href="javascript:void(0);" 
								onClick="pageHelp('SpecimenSearchFldDef','custom_identifier');">
								<cfoutput>#Client.CustomOtherIdentifier#:</cfoutput>
							</a>&nbsp;
							</td>
							<td align="left">
								<label for="CustomOidOper">Display Value</label>
								<select name="CustomOidOper" size="1">
							<option value="IS">is</option>
							<option value="" selected="selected">contains</option>
							<option value="LIST">in list</option>
							<option value="BETWEEN">in range</option>								
						  </select><input type="text" name="CustomIdentifierValue" size="50">
							</td>
						</tr>
						<tr>
							<td align="right" width="250">
								&nbsp;
							</td>
							<td align="left">
								<table cellpadding="0" cellspacing="0">
									<tr>
										<td>
											<label for="custom_id_prefix">OR: Prefix</label>
											<input type="text" name="custom_id_prefix" id="custom_id_prefix" size="12">
										</td>
										<td>
											<label for="custom_id_number">Number</label>
											<input type="text" name="custom_id_number" id="custom_id_number" size="24">
										</td>
										<td>
											<label for="custom_id_suffix">Suffix</label>
											<input type="text" name="custom_id_suffix" id="custom_id_suffix" size="12">
										</td>
									</tr>
								</table>
							</td>
						</tr>
				</cfif>
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
						<td align="right" width="250">
							<a href="javascript:void(0);" 
						<!--- onClick="getHelp('other_id_type'); return false;" --->
						onClick="pageHelp('other_id_type',''); return false;"
						onMouseOver="self.status='Click for Other ID help.';return true;" 
						onmouseout="self.status='';return true;">Other&nbsp;Identifier&nbsp;Type:</a>&nbsp;
						</td>
						<td align="left" nowrap="nowrap">
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
						<td align="right" width="250">
							<a href="javascript:void(0);"
								onClick="pageHelp('other_id_number'); return false;"
								onMouseOver="self.status='Click for Other ID help.';return true;"
								onmouseout="self.status='';return true;">Other&nbsp;Identifying&nbsp;Number:</a>&nbsp;
						</td>
						<td align="left" valign="middle">
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
					<cfif #ListContains(client.searchBy, 'accn_num')# gt 0>	
						<tr>
							<td align="right" width="250">
								<a href="javascript:void(0);" 
									onClick="pageHelp('SpecimenSearchFldDef','accession');">
										Accession:
								</a>&nbsp;
							</td>
							<td align="left">
									<input type="text" name="accn_number" >
									<span class="smaller">&nbsp;Exact Match?</span> <input type="checkbox" name="exactAccnNumMatch" value="1">
							</td>
						</tr>
						<tr>
							<td align="right" width="250">
								Accn. Agency:&nbsp;
							</td>
							<td>
								<input type="text" name="accn_agency" size="50" />
							</td>
						</tr>
					</cfif>
				</table>
			</td>
		</tr>
	</table>