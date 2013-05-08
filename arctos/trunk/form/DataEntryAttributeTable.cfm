<script>
jQuery(document).ready(function() {
	for (i=1;i<=11;i++){
		$("#attribute_date_" + i).datepicker();
	}
});
</script>
<cfoutput>
<cfif isdefined("data.collection_cde")>
	<cfset collection_cde=data.collection_cde>
	</cfif>
	<cftry>
		<cfif not isdefined("useCustom")>
			<cfset useCustom="true">
		</cfif>
		<cfquery name="ctAttributeType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			SELECT attribute_type FROM ctattribute_type
			<cfif len(collection_cde) gt 0>
				WHERE collection_cde='#collection_cde#'
			</cfif>
			order by attribute_type
		</cfquery>
		<cfquery name="ctSex_Cde" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			SELECT distinct(sex_cde) as sex_cde FROM ctSex_Cde
			<cfif len(collection_cde) gt 0>
				WHERE collection_cde='#collection_cde#'
			</cfif>
			order by sex_cde
		</cfquery>
		<cfquery name="ctLength_Units" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select length_units from ctLength_Units order by length_units
		</cfquery>
		<cfquery name="ctWeight_Units" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select Weight_Units from ctWeight_Units order by weight_units
		</cfquery>
		<cfif collection_cde is "Mamm" and useCustom is true>
			<!--- this sets off the attribute default updater - make sure it's not removed --->
			<input type="hidden" id="mammalCustomAttributes">
			<div style="border:1px solid green">
			<table cellpadding="1" cellspacing="0">
				<tr>
					<td>
						<label for="attribute_1">sex</label>
						<input type="hidden" name="attribute_1" id="attribute_1" value="sex">
						<select name="attribute_value_1" size="1" onChange="changeSex(this.value)"
							id="attribute_value_1"
							class="reqdClr"
							style="width: 80px">
							<option value=""></option>
							<cfloop query="ctSex_Cde">
								<option value="#Sex_Cde#">#Sex_Cde#</option>
							</cfloop>
						</select>
						<!--- attribute_date_1 is at the other end of the table ---->
						<input type="hidden" name="attribute_date_2"  id="attribute_date_2" value="">
						<!--- attribute_determiner_1 is at the other end of the table ---->
						<input type="hidden" name="attribute_determiner_2" id="attribute_determiner_2" value="">
						<input type="hidden" name="attribute_det_meth_1" id="attribute_det_meth_1" value="">
					</td>
					<td>
						<label for="attribute_2">TLen</label>
						<input type="hidden" name="attribute_2" id="attribute_2" value="total length" onchange="checkCustomAtts()">
						<input type="text" name="attribute_value_2" size="3" id="attribute_value_2">
					</td>
					<td>
						<label for="attribute_3">Tail</label>
						<input type="hidden" name="attribute_units_3" id="attribute_units_3" />
						<input type="hidden" name="attribute_date_3" id="attribute_date_3" />
						<input type="hidden" name="attribute_determiner_3" id="attribute_determiner_3" />
						<input type="hidden" name="attribute_3" value="tail length" />
						<input type="text" name="attribute_value_3" size="3" id="attribute_value_3" onchange="checkCustomAtts()">
					</td>
					<td>
						<label for="attribute_4">HFoot</label>
						<input type="hidden" name="attribute_units_4" id="attribute_units_4" />
						<input type="hidden" name="attribute_date_4" id="attribute_date_4" />
						<input type="hidden" name="attribute_determiner_4" id="attribute_determiner_4" />
						<input type="hidden" name="attribute_4" value="hind foot with claw" />
						<input type="text" name="attribute_value_4" size="3" id="attribute_value_4" onchange="checkCustomAtts()">
					</td>
					<td>
						<label for="attribute_5">Ear</label>
						<input type="hidden" name="attribute_units_5" id="attribute_units_5" />
						<input type="hidden" name="attribute_date_5" id="attribute_date_5" />
						<input type="hidden" name="attribute_determiner_5" id="attribute_determiner_5" />
						<input type="hidden" name="attribute_5" value="ear from notch" />
						<input type="text" name="attribute_value_5" size="3" id="attribute_value_5" onchange="checkCustomAtts()">
					</td>
					<td>
						<label for="attribute_units_2">Units</label>
						<select name="attribute_units_2" size="1" id="attribute_units_2">
							<option value=""></option>
							<cfloop query="ctLength_Units">
								<option value="#Length_Units#">#Length_Units#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<label for="attribute_value_6">Weight</label>
						<input type="hidden" name="attribute_date_6" id="attribute_date_6" />
						<input type="hidden" name="attribute_determiner_6" id="attribute_determiner_6" />
						<input type="hidden" name="attribute_6" value="weight" />
						<input type="text" name="attribute_value_6" size="3" id="attribute_value_6" onchange="checkCustomAtts()">
					</td>
					<td>
						<label for="attribute_units_6">Wt.Unit</label>
						<select name="attribute_units_6" size="1" id="attribute_units_6">
							<option value=""></option>
							<cfloop query="ctWeight_Units">
								<option value="#Weight_Units#">#Weight_Units#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<label for="attribute_date_1">
							Det.Date
							<span class="infoLink" onclick="copyAttributeDates('attribute_date_1');">Sync</span>
						</label>
						<!--- attribute_date_2 is at the other end of the table ---->
						<input type="text" name="attribute_date_1" id="attribute_date_1" size="10" class="reqdClr">
					</td>
					<td>
						<label for="attribute_date_1">
							Determiner
							<span class="infoLink" onclick="copyAttributeDetr('attribute_determiner_1');">Sync</span>
						</label>
						<!--- attribute_determiner_2 is at the other end of the table ---->
						<input type="text" name="attribute_determiner_1" id="attribute_determiner_1"
							onchange="getAgent('nothing',this.id,'dataEntry',this.value);"
							onkeypress="return noenter(event);"
							class="reqdClr"
							onchange="autocopyAttDetr();">
					</td>
				</tr>
			</table>
			</div>
			<!---- attributes 7-10 are freeform --->
			<table cellspacing="0" cellpadding="0">
				<tr>
					<th><span class="f11a">Attribute</span></th>
					<th><span class="f11a">Value</span></th>
					<th><span class="f11a">Units</span></th>
					<th><span class="f11a">Date</span></th>
					<th><span class="f11a">Determiner</span></th>
					<th><span class="f11a">Method</span></th>
					<th><span class="f11a">Remarks</span></th>
				</tr>
				<cfloop from="7" to="10" index="i">
					<tr id="de_attribute_#i#">
						<td>
							<select name="attribute_#i#" onChange="getAttributeStuff(this.value,this.id);"
								style="width:100px;" id="attribute_#i#">
								<option value="">&nbsp;&nbsp;&nbsp;&nbsp;</option>
								<cfloop query="ctAttributeType">
									<option value="#attribute_type#">#attribute_type#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<div id="attribute_value_cell_#i#">
								<input type="text" name="attribute_value_#i#" id="attribute_value_#i#"size="15">
							</div>
						</td>
						<td>
							<div id="attribute_units_cell_#i#">
							<input type="text" name="attribute_units_#i#" id="attribute_units_#i#" size="6">
							</div>
						</td>
						<td>
							<input type="text" name="attribute_date_#i#" id="attribute_date_#i#" size="10">
						</td>
						<td>
							 <input type="text" name="attribute_determiner_#i#" id="attribute_determiner_#i#" size="15"
								onchange="getAgent('nothing',this.id,'dataEntry',this.value);"
								onkeypress="return noenter(event);">
						</td>
						<td>
							<input type="text" name="attribute_det_meth_#i#" id="attribute_det_meth_#i#" size="15">
						</td>
						<td>
							<input type="text" name="attribute_remarks_#i#" id="attribute_remarks_#i#">
						</td>
					</tr>
				</cfloop>
			</table>
		<cfelseif collection_cde is "Bird" and useCustom is true>
			<!--- this sets off the attribute default updater - make sure it's not removed --->
			<input type="hidden" id="birdCustomAttributes">
			<div style="border:1px solid green">
			<table cellpadding="1" cellspacing="0">
				<tr>
					<td>
						<label for="attribute_value_1">Sex</label>
						<select name="attribute_value_1" size="1" onChange="changeSex(this.value)"
							id="attribute_value_1"
							class="reqdClr"
							style="width: 80px">
							<option value=""></option>
							<cfloop query="ctSex_Cde">
								<option value="#Sex_Cde#">#Sex_Cde#</option>
							</cfloop>
						</select>
						<input type="hidden" name="attribute_1" id="attribute_1" value="sex">
						<input type="hidden" name="attribute_date_2" id="attribute_date_2">
						<input type="hidden" name="attribute_determiner_2" id="attribute_determiner_2">
						<input type="hidden" name="attribute_det_meth_1" id="attribute_det_meth_1">
					</td>
					<td>
						<label for="attribute_value_2">Age</label>
						<input type="text" name="attribute_value_2" size="3" id="attribute_value_2">
						<input type="hidden" name="attribute_2" id="attribute_2" value="age" />
					</td>
					<td>
						<label for="attribute_value_3">Fat</label>
						<input type="text" name="attribute_value_3" size="15" id="attribute_value_3">
						<input type="hidden" name="attribute_date_3" id="attribute_date_3" />
						<input type="hidden" name="attribute_determiner_3" id="attribute_determiner_3" />
						<input type="hidden" name="attribute_3" id="attribute_3" value="fat deposition" />
					</td>
					<td>
						<label for="attribute_value_4">Molt</label>
						<input type="text" name="attribute_value_4" size="15" id="attribute_value_4">
						<input type="hidden" name="attribute_date_4" id="attribute_date_4" />
						<input type="hidden" name="attribute_determiner_4" id="attribute_determiner_4" />
						<input type="hidden" name="attribute_4" id="attribute_4" value="molt condition" />
					</td>
					<td>
						<label for="attribute_value_5">Ossification</label>
						<input type="text" name="attribute_value_5"  size="15" id="attribute_value_5">
						<input type="hidden" name="attribute_date_5" id="attribute_date_5" />
						<input type="hidden" name="attribute_determiner_5" id="attribute_determiner_5" />
						<input type="hidden" name="attribute_5" id="attribute_5" value="skull ossification" />
					</td>
					<td>
						<label for="attribute_value_6">Weight</label>
						<input type="text" name="attribute_value_6" size="2" id="attribute_value_6">
						<input type="hidden" name="attribute_date_6" id="attribute_date_6" />
						<input type="hidden" name="attribute_determiner_6" id="attribute_determiner_6" />
						<input type="hidden" name="attribute_6" id="attribute_6" value="weight" />
					</td>
					<td>
						<label for="attribute_units_6">Wt.Unit</label>
						<select name="attribute_units_6" size="1" id="attribute_units_6" class="reqdClr">
							<cfloop query="ctWeight_Units">
								<option value="#Weight_Units#">#Weight_Units#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<label for="attribute_date_1">
							Attr.Date
							<span class="infoLink" onclick="copyAttributeDates('attribute_date_1');">Sync</span>
						</label>
						<input type="text" name="attribute_date_1" id="attribute_date_1" class="reqdClr" size="10">
					</td>
					<td>
						<label for="attribute_determiner_1">
							Determiner
							<span class="infoLink" onclick="copyAttributeDetr('attribute_determiner_1');">Sync</span>
						</label>
						<input type="text" class="reqdClr"
							name="attribute_determiner_1"
							id="attribute_determiner_1"
							onchange="getAgent('nothing',this.id,'dataEntry',this.value);"
							onkeypress="return noenter(event);">
					</td>
				</tr>
			</table>
			</div>
			<!---- attributes 7-10 are freeform --->
			<table cellspacing="0" cellpadding="0">
				<tr>
					<th><span class="f11a">Attribute</span></th>
					<th><span class="f11a">Value</span></th>
					<th><span class="f11a">Units</span></th>
					<th><span class="f11a">Date</span></th>
					<th><span class="f11a">Determiner</span></th>
					<th><span class="f11a">Method</span></th>
					<th><span class="f11a">Remarks</span></th>
				</tr>
				<cfloop from="7" to="10" index="i">
					<tr id="de_attribute_#i#">
						<td>
							<select name="attribute_#i#" onChange="getAttributeStuff(this.value,this.id);"
								style="width:100px;" id="attribute_#i#">
								<option value="">&nbsp;&nbsp;&nbsp;&nbsp;</option>
								<cfloop query="ctAttributeType">
									<option value="#attribute_type#">#attribute_type#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<div id="attribute_value_cell_#i#">
								<input type="text" name="attribute_value_#i#" id="attribute_value_#i#" size="15">
							</div>
						</td>
						<td>
							<div id="attribute_units_cell_#i#">
							<input type="text" name="attribute_units_#i#" id="attribute_units_#i#" size="6">
							</div>
						</td>
						<td>
							<input type="text" name="attribute_date_#i#" id="attribute_date_#i#" size="10">
						</td>
						<td>
							 <input type="text" name="attribute_determiner_#i#" id="attribute_determiner_#i#" size="15"
								onchange="getAgent('nothing',this.id,'dataEntry',this.value);"
								onkeypress="return noenter(event);">
						</td>
						<td>
							<input type="text" name="attribute_det_meth_#i#" id="attribute_det_meth_#i#" size="15">
						</td>
						<td>
							<input type="text" name="attribute_remarks_#i#" id="attribute_remarks_#i#">
						</td>
					</tr>
				</cfloop>
			</table>
		<cfelse><!---- fall back to all attributes in table --->
			<table cellspacing="0" cellpadding="0">
				<tr>
					<th><span class="f11a">Attribute</span></th>
					<th><span class="f11a">Value</span></th>
					<th><span class="f11a">Units</span></th>
					<th><span class="f11a">Date</span></th>
					<th><span class="f11a">Determiner</span></th>
					<th><span class="f11a">Method</span></th>
					<th><span class="f11a">Remarks</span></th>
				</tr>
				<cfloop from="1" to="10" index="i">
					<tr id="de_attribute_#i#">
						<td>
							<select name="attribute_#i#" onChange="getAttributeStuff(this.value,this.id);"
								style="width:100px;" id="attribute_#i#">
								<option value="">&nbsp;&nbsp;&nbsp;&nbsp;</option>
								<cfloop query="ctAttributeType">
									<option value="#attribute_type#">#attribute_type#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<div id="attribute_value_cell_#i#">
								<input type="text" name="attribute_value_#i#"
									id="attribute_value_#i#"size="15">
							</div>
						</td>
						<td>
							<div id="attribute_units_cell_#i#">
							<input type="text" name="attribute_units_#i#"
								id="attribute_units_#i#" size="6">
							</div>
						</td>
						<td>
							<input type="text" name="attribute_date_#i#"
								id="attribute_date_#i#" size="10">
						</td>
						<td>
							 <input type="text" name="attribute_determiner_#i#"
								id="attribute_determiner_#i#" size="15"
								onchange="getAgent('nothing',this.id,'dataEntry',this.value);"
								onkeypress="return noenter(event);">
						</td>
						<td>
							<input type="text" name="attribute_det_meth_#i#"
								id="attribute_det_meth_#i#" size="15">
						</td>
						<td>
							<input type="text" name="attribute_remarks_#i#"
								id="attribute_remarks_#i#">
						</td>
					</tr>
				</cfloop>
			</table>
		</cfif>
	<cfcatch>
		<cfdump var=#cfcatch#>
	</cfcatch>
</cftry>
</cfoutput>