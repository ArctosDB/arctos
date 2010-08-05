<script language="JavaScript" src="/includes/jquery/jquery.ui.core.min.js" type="text/javascript"></script>
<script language="JavaScript" src="/includes/jquery/jquery.ui.datepicker.min.js" type="text/javascript"></script>
<script type="text/javascript">
	jQuery(document).ready(function() {
		jQuery(function() {
			jQuery("#begDate").datepicker();
			jQuery("#endDate").datepicker();
		});
	});
</script>
<cfquery name="ctcollecting_source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select collecting_source from ctcollecting_source
</cfquery>
<cfoutput>
<table id="t_identifiers" class="ssrch">
	<tr>
		<td class="lbl">
			<span class="helpLink" id="year_collected">Collected After:</span>
		</td>
		<td class="srch">
			<label for="begYear" class="h">Year:</label><input name="begYear" id="begYear" type="text" size="4">
			<label for="begMon" class="h">Month:</label><select name="begMon" id="begMon" size="1">
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
			<label for="begDay" class="h">Day:</label><select name="begDay" id="begDay" size="1">
				<option value=""></option>
				<cfloop from="1" to="31" index="day">
					<option value="#day#">#day#</option>
				</cfloop>
			</select>
			<br><label for="begDate" class="h">Full Date:</label>
			<input name="begDate" id="begDate" size="10" type="text">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="year_collected">Collected Before:</span>
		</td>
		<td class="srch">
			<label for="endYear" class="h">Year:</label><input name="endYear" id="endYear" type="text" size="4">
			<label for="endMon" class="h">Month:</label><select name="endMon" id="endMon" size="1">
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
			<label for="endDay" class="h">Day:</label><select name="endDay" id="endDay" size="1">
				<option value=""></option>
				<cfloop from="1" to="31" index="day">
					<option value="#day#">#day#</option>
				</cfloop>
			</select>
			<br><label for="endDate" class="h">Full Date:</label>
			<input name="endDate" id="endDate" size="10" type="text">
			<span style="font-size:x-small;">(Leave blank to use Collected After values)</span>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="month_in">Month:</span>
		</td>
		<td class="srch">
			<select name="inMon" id="inMon" size="4" multiple>
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
			<span class="helpLink" id="incl_date">Strict Date Search?</span>
		</td>
		<td class="srch">
			<input type="checkbox" name="inclDateSearch" id="inclDateSearch" value="yes">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_verbatim_date">Verbatim Date:</span>
		</td>
		<td class="srch">
			<input type="text" name="verbatim_date" id="verbatim_date" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_chronological_extent">Chronological Extent:</span>
			</a>
		</td>
		<td class="srch">
			<input type="text" name="chronological_extent" id="chronological_extent">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_collecting_source">Collecting Source:</span>
		</td>
		<td class="srch">
			<select name="collecting_source" id="collecting_source" size="1">
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
			<span class="helpLink" id="_verbatim_locality">Verbatim Locality:</span>
		</td>
		<td class="srch">
			<input type="text" name="verbatim_locality" id="verbatim_locality" size="50">
			<span class="infoLink" onclick="var e=document.getElementById('verbatim_locality');e.value='='+e.value;">Add = for exact match</span>
		</td>
	</tr>
</table>
</cfoutput>