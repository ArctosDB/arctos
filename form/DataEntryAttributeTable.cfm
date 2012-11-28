<cfoutput>
	<cfloop from="1" to="6" index="i">
										<input type="hidden" name="attribute_#i#" id="attribute_#i#" value="">
										<input type="hidden" name="attribute_value_#i#"  id="attribute_value_#i#" value="">
										<input type="hidden" name="attribute_date_#i#"  id="attribute_date_#i#" value="">
										<input type="hidden" name="attribute_determiner_#i#"  id="attribute_determiner_#i#" value="">
										<input type="hidden" name="attribute_det_meth_#i#"  id="attribute_det_meth_#i#" value="">
									</cfloop>
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
												<!----
												<cfloop query="ctAttributeType">
													<option <cfif evaluate("data.attribute_" & i) is ctAttributeType.attribute_type> selected="selected" </cfif>
														value="#attribute_type#">#attribute_type#</option>
												</cfloop>
												---->
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
									</cfoutput>