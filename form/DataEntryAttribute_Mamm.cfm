<cfoutput>
	ello gunvu
			<!----<table cellpadding="1" cellspacing="0">
		<tr>
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
				<input type="hidden" name="attribute_2" value="total length" />
				<input type="text" name="attribute_value_2" value="#attribute_value_2#" size="3" id="attribute_value_2">
			</td>
			<td>
				<input type="hidden" name="attribute_units_3" value="#attribute_units_3#" id="attribute_units_3" />
				<input type="hidden" name="attribute_date_3" value="#attribute_date_3#" id="attribute_date_3" />
				<input type="hidden" name="attribute_determiner_3" value="#attribute_determiner_3#" id="attribute_determiner_3" />
				<input type="hidden" name="attribute_3" value="tail length" />
				<input type="text" name="attribute_value_3" value="#attribute_value_3#" size="3" id="attribute_value_3">
			</td>
			<td align='center'>
				<input type="hidden" name="attribute_units_4" value="#attribute_units_4#" id="attribute_units_4" />
				<input type="hidden" name="attribute_date_4" value="#attribute_date_4#" id="attribute_date_4" />
				<input type="hidden" name="attribute_determiner_4" value="#attribute_determiner_4#" id="attribute_determiner_4" />
				<input type="hidden" name="attribute_4" value="hind foot with claw" />
				<input type="text" name="attribute_value_4" value="#attribute_value_4#" size="3" id="attribute_value_4">
			</td>
			<td align='center'>
				<input type="hidden" name="attribute_units_5" value="#attribute_units_5#" id="attribute_units_5" />
				<input type="hidden" name="attribute_date_5" value="#attribute_date_5#" id="attribute_date_5" />
				<input type="hidden" name="attribute_determiner_5" value="#attribute_determiner_5#" id="attribute_determiner_5" />
				<input type="hidden" name="attribute_5" value="ear from notch" />
				<input type="text" name="attribute_value_5" value="#attribute_value_5#" size="3" id="attribute_value_5">
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
				<input type="hidden" name="attribute_date_6" value="#attribute_date_6#" id="attribute_date_6" />
				<input type="hidden" name="attribute_determiner_6" value="#attribute_determiner_6#" id="attribute_determiner_6" />
				<input type="hidden" name="attribute_6" value="weight" />
				<input type="text" name="attribute_value_6" value="#attribute_value_6#" size="3" id="attribute_value_6">
			</td>
			<td>
				<select name="attribute_units_6" size="1" id="attribute_units_6">
					<option value=""></option>
					<cfloop query="ctWeight_Units">
						<option <cfif #data.attribute_units_6# is #Weight_Units#> selected </cfif>value="#Weight_Units#">#Weight_Units#</option>
					</cfloop>
				</select>
			</td>
			<td>
				<input type="text" name="attribute_date_2" id="attribute_date_2" value="#attribute_date_2#">
			</td>
			<td>
				<input type="text" name="attribute_determiner_2" id="attribute_determiner_2"
					value="#attribute_determiner_2#"
					onchange="getAgent('nothing',this.id,'dataEntry',this.value);"
					onkeypress="return noenter(event);">

			</td>
		</tr>
		---->
	</table>
</cfoutput>