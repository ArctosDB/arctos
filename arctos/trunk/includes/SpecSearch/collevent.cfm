<cfquery name="ctcollecting_source" datasource="#Application.web_user#">
	select collecting_source from ctcollecting_source
</cfquery>						
<table id="t_identifiers" class="ssrch">
	<tr>
		<td class="lbl">
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
			<a href="javascript:void(0);" 
				onClick="getHelp('collecting_source'); return false;"
				onMouseOver="self.status='Click for Collecting Source help.';return true;" 
				onmouseout="self.status='';return true;">Collecting Source:
			</a>
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
			<a href="javascript:void(0);"
				onClick="getHelp('day_collected'); return false;"
				onMouseOver="self.status='Click for Year Collected help.';return true;"
				onmouseout="self.status='';return true;">Day Collected:
			</a>
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
			<a href="javascript:void(0);"
				onClick="getHelp('fulldate_collected'); return false;"
				onMouseOver="self.status='Click for Year Collected help.';return true;"
				onmouseout="self.status='';return true;">Full Date Collected:
			</a>
		</td>
		<td class="srch">
			<input name="begDate" type="text" size="15">
			&nbsp;<span class="infoLink" onclick="SpecData.endDate.value=SpecData.begDate.value;">-->&nbsp;Copy&nbsp;--></span>&nbsp;
			<input name="endDate" type="text" size="15">
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