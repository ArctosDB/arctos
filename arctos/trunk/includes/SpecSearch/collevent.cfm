<cfquery name="ctcollecting_source" datasource="#Application.web_user#">
	select collecting_source from ctcollecting_source
</cfquery>						
<table id="t_identifiers" class="ssrch">
	<tr>
		<td class="lbl">
			<span class="helpLink infoLink" id="collector">help</span>
			<select name="coll_role" size="1">
				<option value="" selected="selected">Collector</option>
				<option value="p">Preparator</option>
			</select>
		</td>
		<td class="srch">
			<input type="text" name="coll" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="collecting_source">Collecting Source:</span>
		</td>
		<td class="srch">
			<select name="collecting_source" size="1">
				<option value=""></option>
				<cfloop query="ctcollecting_source">
					<option value="#ctcollecting_source.collecting_source#">
						#ctcollecting_source.collecting_source#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="incl_date">Inclusive Date Search?</span>
		</td>
		<td class="srch">
			<input type="checkbox" name="inclDateSearch" value="yes">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="month_collected">Month Collected:</span>
		</td>
		<td class="srch">
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
			&nbsp;<span class="infoLink" onclick="SpecData.endMon.value=SpecData.begMon.value;">-->&nbsp;Copy&nbsp;--></span>&nbsp;
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
	<tr>
		<td class="lbl">
			<span class="helpLink" id="day_collected">Day Collected:</span>
		</td>
		<td class="srch">
			<select name="begDay" size="1">
				<option value=""></option>
				<cfloop from="1" to="31" index="day">
					<option value="#day#">#day#</option>
				</cfloop>
			</select>
			&nbsp;<span class="infoLink" onclick="SpecData.endDay.value=SpecData.begDay.value;">-->&nbsp;Copy&nbsp;--></span>&nbsp;
			<select name="endDay" size="1">
				<option value=""></option>
				<cfloop from="1" to="31" index="day">
					<option value="#day#">#day#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="fulldate_collected">Full Date Collected:</span>
		</td>
		<td class="srch">
			<input name="begDate" type="text" size="15">
			&nbsp;<span class="infoLink" onclick="SpecData.endDate.value=SpecData.begDate.value;">-->&nbsp;Copy&nbsp;--></span>&nbsp;
			<input name="endDate" type="text" size="15">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="month_in">Month:</span>
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
			<span class="helpLink" id="verbatim_date">Verbatim Date:</span>
		</td>
		<td class="srch">
			<input type="text" name="verbatim_date" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="chronological_extent">Chronological Extent:</span>
			</a>
		</td>
		<td class="srch">
			<input type="text" name="chronological_extent">
		</td>
	</tr>
</table>