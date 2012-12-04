<cfoutput>
	<cfquery name="ctgeology_attribute" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select geology_attribute from ctgeology_attribute order by geology_attribute
	</cfquery>
	<table cellpadding="0" cellspacing="0" class="fs">
		<tr>
			<td>
				<img src="/images/info.gif" border="0" onClick="getDocs('geology_attributes')" class="likeLink" alt="[ help ]">
				<table cellpadding="0" cellspacing="0">
					<tr>
						<th nowrap="nowrap"><span class="f11a">Geol Att.</span></th>
						<th><span class="f11a">Geol Att. Value</span></th>
						<th><span class="f11a">Determiner</span></th>
						<th><span class="f11a">Date</span></th>
						<th><span class="f11a">Method</span></th>
						<th><span class="f11a">Remark</span></th>
					</tr>
					<cfloop from="1" to="6" index="i">
						<div id="#i#">
						<tr id="d_geology_attribute_#i#">
							<td>
								<select name="geology_attribute_#i#" id="geology_attribute_#i#" size="1" onchange="populateGeology(this.id);">
									<option value=""></option>
									<cfloop query="ctgeology_attribute">
										<option value="#geology_attribute#">#geology_attribute#</option>
									</cfloop>
								</select>
							</td>
							<td>
								<select name="geo_att_value_#i#" id="geo_att_value_#i#">

								</select>
							</td>
							<td>
								<input type="text"
									name="geo_att_determiner_#i#"
									id="geo_att_determiner_#i#"
									onchange="getAgent('nothing',this.id,'dataEntry',this.value);"
									onkeypress="return noenter(event);">
							</td>
							<td>
								<input type="text"
									name="geo_att_determined_date_#i#"
									id="geo_att_determined_date_#i#"
									size="10">
							</td>
							<td>
								<input type="text"
									name="geo_att_determined_method_#i#"
									id="geo_att_determined_method_#i#"
									size="15">
							</td>
							<td>
								<input type="text"
									name="geo_att_remark_#i#"
									id="geo_att_remark_#i#"
									size="15">
							</td>
						</tr>
						</div>
					</cfloop>
				</table>
			</td>
		</tr>
	</table>
</cfoutput>