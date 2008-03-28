						
<table id="t_identifiers" class="ssrch">
	<tr>
		<td class="lbl">
			<a href="javascript:void(0);"
				onClick="getHelp('incl_date'); return false;"
				onMouseOver="self.status='Click for Date Search help.';return true;"
				onmouseout="self.status='';return true;">Inclusive Date Search?
			</a>
		</td>
		<td class="srch">
			<input type="checkbox" name="inclDateSearch" value="yes">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<a href="javascript:void(0);"
				onClick="getHelp('incl_date'); return false;"
				onMouseOver="self.status='Click for Date Search help.';return true;"
				onmouseout="self.status='';return true;">Inclusive Date Search?
			</a>
		</td>
		<td class="srch">
			<input type="checkbox" name="inclDateSearch" value="yes">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<a href="javascript:void(0);"
				onClick="getHelp('month_collected'); return false;"
				onMouseOver="self.status='Click for Year Collected help.';return true;"
				onmouseout="self.status='';return true;">Month Collected:
			</a>
		</td>
		<td class="srch">
			<table cellpadding="0" cellspacing="0">
				<tr>
					<td width="40%">
						<select name="begMon" size="1">
							<option value=""></option>
							<option value="01">January</option>
							<option value="02">February</option>
							<option value="03">March</option>
							<option value="04">April</option>
							<option value="05">May</option>
							<option value="06">June</option>
							<option value="07">July</option>
							<option value="08">August</option>
							<option value="09">September</option>
							<option value="10">October</option>
							<option value="11">November</option>
							<option value="12">December</option>						
						</select>
					</td>
					<td width="10%">
						<span class="infoLink" 
  							onclick="SpecData.endMon.value=SpecData.begMon.value;">Copy&nbsp;--></span>
					</td>
					<td width="40%">
						<select name="endMon" size="1">
				<option value=""></option>
				<option value="01">January</option>
				<option value="02">February</option>
				<option value="03">March</option>
				<option value="04">April</option>
				<option value="05">May</option>
				<option value="06">June</option>
				<option value="07">July</option>
				<option value="08">August</option>
				<option value="09">September</option>
				<option value="10">October</option>
				<option value="11">November</option>
				<option value="12">December</option>						
			</select>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<a href="javascript:void(0);"
				onClick="getHelp('day_collected'); return false;"
				onMouseOver="self.status='Click for Year Collected help.';return true;"
				onmouseout="self.status='';return true;">Day Collected:
			</a>
		</td>
		<td class="srch">
			<table width="250" cellpadding="0" cellspacing="0">
									<tr>
										<td width="40%">
											<select name="begDay" size="1">
									<option value=""></option>
										<cfloop from="1" to="31" index="day">
											<option value="#day#">#day#</option>
										</cfloop>
								</select>
										</td>
										<td width="10%">
											<span class="infoLink" 
					  							onclick="SpecData.endDay.value=SpecData.begDay.value;">Copy&nbsp;--></span>
										</td>
										<td width="40%">
											<select name="endDay" size="1">
									<option value=""></option>
										<cfloop from="1" to="31" index="day">
											<option value="#day#">#day#</option>
										</cfloop>
								</select>
										</td>
									</tr>
								</table>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<a href="javascript:void(0);"
				onClick="getHelp('fulldate_collected'); return false;"
				onMouseOver="self.status='Click for Year Collected help.';return true;"
				onmouseout="self.status='';return true;">Full Date Collected:
			</a>
		</td>
		<td class="srch">
			<table width="250" cellpadding="0" cellspacing="0">
									<tr>
										<td width="40%">
											<input name="begDate" type="text" size="15">
										</td>
										<td width="10%">
											<span class="infoLink" 
					  							onclick="SpecData.endDate.value=SpecData.begDate.value;">Copy&nbsp;--></span>
										</td>
										<td width="40%">
											<input name="endDate" type="text" size="15">
										</td>
									</tr>
								</table>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<a href="javascript:void(0);"
				onClick="getHelp('month_in'); return false;"
				onMouseOver="self.status='Click for Year Collected help.';return true;"
				onmouseout="self.status='';return true;">Month:
			</a>
		</td>
		<td class="srch">
			<select name="inMon" size="4" multiple>
				<option value=""></option>
				<option value="'01'">January</option>
				<option value="'02'">February</option>
				<option value="'03'">March</option>
				<option value="'04'">April</option>
				<option value="'05'">May</option>
				<option value="'06'">June</option>
				<option value="'07'">July</option>
				<option value="'08'">August</option>
				<option value="'09'">September</option>
				<option value="'10'">October</option>
				<option value="'11'">November</option>
				<option value="'12'">December</option>						
			</select>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<a href="javascript:void(0);"
				onClick="getHelp('verbatim_date'); return false;"
				onMouseOver="self.status='Click for Year Collected help.';return true;"
				onmouseout="self.status='';return true;">Verbatim Date:
			</a>
		</td>
		<td class="srch">
			<input type="text" name="verbatim_date" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<a href="javascript:void(0);" 
				onClick="getHelp('chronological_extent'); return false;"
				onMouseOver="self.status='Click for Chronological Extent help.';return true;" 
				onmouseout="self.status='';return true;">Chronological Extent:
			</a>
		</td>
		<td class="srch">
			<input type="text" name="chronological_extent">
		</td>
	</tr>
</table>