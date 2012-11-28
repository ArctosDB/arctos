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
		<cfif collection_cde is "Mamm" and useCustom is true>

going with mammal customizations


				<table cellpadding="1" cellspacing="0">
					<tr>
						<td><span class="f11a">sex</span></td>
						<td><span class="f11a">len</span></td>
						<td><span class="f11a">tail</span></td>
						<td><span class="f11a">Hind Foot</span></td>
						<td><span class="f11a">Ear From Notch</span></td>
						<td><span class="f11a">Units</span></td>
						<td colspan="2" align="center"><span class="f11a">Weight</span></td>
						<td><span class="f11a">Date</span></td>
						<td><span class="f11a">Determiner</span></td>
					</tr>

					<tr>
						<td>
							<input type="hidden" name="attribute_1" value="sex">
							<select name="attribute_value_1" size="1" onChange="changeSex(this.value)"
								id="attribute_value_1"
								class="reqdClr"
								style="width: 80px">
								<option value=""></option>
								<cfloop query="ctSex_Cde">
									<option value="#Sex_Cde#">#Sex_Cde#</option>
								</cfloop>
							</select>
							<input type="hidden" name="attribute_date_1"  id="attribute_date_1" value="">
							<input type="hidden" name="attribute_determiner_1" id="attribute_determiner_1" value="">
							<input type="hidden" name="attribute_det_meth_1" id="attribute_det_meth_1" value="">

						</td>
						<td>
							<input type="hidden" name="attribute_2" id="attribute_2" value="total length" />
							<input type="text" name="attribute_value_2" size="3" id="attribute_value_2">
						</td>
						<td>
							<input type="hidden" name="attribute_units_3" id="attribute_units_3" />
							<input type="hidden" name="attribute_date_3" id="attribute_date_3" />
							<input type="hidden" name="attribute_determiner_3" id="attribute_determiner_3" />
							<input type="hidden" name="attribute_3" value="tail length" />
							<input type="text" name="attribute_value_3" value="#attribute_value_3#" size="3" id="attribute_value_3">
						</td>
						<td align='center'>
							<input type="hidden" name="attribute_units_4" id="attribute_units_4" />
							<input type="hidden" name="attribute_date_4" id="attribute_date_4" />
							<input type="hidden" name="attribute_determiner_4" id="attribute_determiner_4" />
							<input type="hidden" name="attribute_4" value="hind foot with claw" />
							<input type="text" name="attribute_value_4" size="3" id="attribute_value_4">
						</td>
						<td align='center'>
							<input type="hidden" name="attribute_units_5" id="attribute_units_5" />
							<input type="hidden" name="attribute_date_5" id="attribute_date_5" />
							<input type="hidden" name="attribute_determiner_5" id="attribute_determiner_5" />
							<input type="hidden" name="attribute_5" value="ear from notch" />
							<input type="text" name="attribute_value_5" size="3" id="attribute_value_5">
						</td>
						<td>
							<select name="attribute_units_2" size="1" id="attribute_units_2">
								<option value=""></option>
								<cfloop query="ctLength_Units">
									<option <cfif #data.attribute_units_2# is #Length_Units#> selected </cfif>
									value="#Length_Units#">#Length_Units#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<input type="hidden" name="attribute_date_6" id="attribute_date_6" />
							<input type="hidden" name="attribute_determiner_6" id="attribute_determiner_6" />
							<input type="hidden" name="attribute_6" value="weight" />
							<input type="text" name="attribute_value_6" size="3" id="attribute_value_6">
						</td>
						<td>
							<select name="attribute_units_6" size="1" id="attribute_units_6">
								<option value=""></option>
								<cfloop query="ctWeight_Units">
									<option value="#Weight_Units#">#Weight_Units#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<input type="text" name="attribute_date_2" id="attribute_date_2" value="#attribute_date_2#">
						</td>
						<td>
							<input type="text" name="attribute_determiner_2" id="attribute_determiner_2"
								onchange="getAgent('nothing',this.id,'dataEntry',this.value);"
								onkeypress="return noenter(event);">

						</td>
					</tr>
				</table>
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
		<cfelse><!---- fall back to all attributes in table --->
			default/fallback
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



<!------------------


	<cfloop from="1" to="6" index="i">
										<input type="hidden" name="attribute_#i#" id="attribute_#i#" value="">
										<input type="hidden" name="attribute_value_#i#"  id="attribute_value_#i#" value="">
										<input type="hidden" name="attribute_date_#i#"  id="attribute_date_#i#" value="">
										<input type="hidden" name="attribute_determiner_#i#"  id="attribute_determiner_#i#" value="">
										<input type="hidden" name="attribute_det_meth_#i#"  id="attribute_det_meth_#i#" value="">
									</cfloop>


								-------------->
									</cfoutput>