<script type="text/javascript">
	jQuery(document).ready(function() {
		$("#begDate").datepicker();
		$("#endDate").datepicker();
		$("#inMon").multiselect();
	});
</script>
<cfquery name="ctcollecting_source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select collecting_source from ctcollecting_source order by collecting_source
</cfquery>
<cfquery name="ctverificationstatus"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select verificationstatus from ctverificationstatus group by verificationstatus order by verificationstatus 
</cfquery>
<cfquery name="ctspecimen_event_type"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select specimen_event_type from ctspecimen_event_type group by specimen_event_type order by specimen_event_type 
</cfquery>


<cfoutput>
<table id="t_identifiers" class="ssrch">
	<tr>
		<td class="lbl">
			<span class="helpLink" id="year_collected">Collected On or After:</span>
		</td>
		<td class="srch">
			<table>
				<tr>
					<td>
						<label for="begYear">Year</label>
						<input type="number" min="1000" max="2500" step="1" name="begYear" id="begYear">
					</td>
					<td>
						<label for="begMon">Month</label>
						<select name="begMon" id="begMon" size="1">
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
					<td>
						<label for="begDay">Day</label>
						<select name="begDay" id="begDay" size="1">
							<option value=""></option>
							<cfloop from="1" to="31" index="day">
								<option value="#day#">#day#</option>
							</cfloop>
						</select>
					</td>
					<td valign="bottom"><span style="font-size:small;font-style:italic;font-weight:bold;">OR</span></td>
					<td>
						<label for="begDate">ISO8601 Date/Time</label>
						<input name="begDate" id="begDate" size="10" type="text">
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="year_collected">Collected On or Before:</span>
		</td>
		<td class="srch">
			<table>
				<tr>
					<td>
						<label for="endYear">Year</label>						
						<input type="number" min="1000" max="2500" step="1" name="endYear" id="endYear">
					</td>
					<td>
						<label for="endMon">Month</label>
						<select name="endMon" id="endMon" size="1">
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
					<td>
						<label for="endDay">Day</label>
						<select name="endDay" id="endDay" size="1">
							<option value=""></option>
							<cfloop from="1" to="31" index="day">
								<option value="#day#">#day#</option>
							</cfloop>
						</select>
					</td>
					<td valign="bottom"><span style="font-size:small;font-style:italic;font-weight:bold;">OR</span></td>
					<td>
						<label for="endDate">ISO8601 Date/Time</label>
						<input name="endDate" id="endDate" size="10" type="text">
					</td>
				</tr>
			</table>
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
	<!---
	<tr>
		<td class="lbl">
			<span class="helpLink" id="incl_date">Strict Date Search?</span>
		</td>
		<td class="srch">
			<input type="checkbox" name="inclDateSearch" id="inclDateSearch" value="yes">
		</td>
	</tr>
	----->
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
			<span class="helpLink" id="_specimen_event_type">Specimen/Event Type:</span>
		</td>
		<td class="srch">
			<select name="specimen_event_type" id="specimen_event_type" size="1">
				<option value=""></option>
				<cfloop query="ctspecimen_event_type">
					<option value="#ctspecimen_event_type.specimen_event_type#">#ctspecimen_event_type.specimen_event_type#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_specimen_event_remark">Specimen/Event Remark:</span>
		</td>
		<td class="srch">
			<input type="text" name="specimen_event_remark" id="specimen_event_remark" size="50">
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
			<span class="helpLink" id="_collecting_method">Collecting Method:</span>
			</a>
		</td>
		<td class="srch">
			<input type="text" name="collecting_method" id="collecting_method" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_verificationstatus">Verification Status:</span>
		</td>
		<td class="srch">
			<select name="verificationstatus" id="verificationstatus" size="1">
				<option value=""></option>
				<cfloop query="ctverificationstatus">
					<option value="#ctverificationstatus.verificationstatus#">#ctverificationstatus.verificationstatus#</option>
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
	
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_coll_event_remarks">Collecting Event Remark:</span>
		</td>
		<td class="srch">
			<input type="text" name="coll_event_remarks" id="coll_event_remarks" size="50">
		</td>
	</tr>
</table>
</cfoutput>