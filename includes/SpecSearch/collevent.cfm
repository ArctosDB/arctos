<script type="text/javascript">
	jQuery(document).ready(function() {
		$("#begDate").datepicker();
		$("#endDate").datepicker();
		$("#inMon").multiselect();

		$(document).on("change", '[id^="ceattribute_type_placeholder_"]', function(){
			console.log('change');
			var i =  this.id;
			i=i.replace("ceattribute_type_placeholder_", "");
			var thisVal=this.value;
			if ($('#' + thisVal).length){
				alert('That Attribute has already been added.');
				$("#" + this.id).val('');
				return;
			}
			var thisTxt=$("#" + this.id + " option:selected").text();
			var nEl='<input type="text" name="' + thisVal + '" id="' + thisVal + '" placeholder="' + thisTxt + '">';
			//nEl+='<span class="infoLink" onclick="resetCEAttr(' + this.id + ')">reset</span>';
			$("#ceattribute_type_placeholder_" + i).html(nEl);
			// hide the placeholder/picker
			var nlbl='<span class="helpLink" id="_' +thisVal+'">'+thisTxt+'</span>';
			$("#" + this.id).hide().after(nlbl);
		});

	});

	function moreCEAttr(){
		var i;
		 $('[id^= "ceattribute_type_placeholder_"]').each(function(){
            i=this.id.replace("ceattribute_type_placeholder_", "");
        });
        var lastNum=i;
        var nextNum=parseInt(i)+parseInt(1);
        var nelem='<tr><td class="lbl">';
        nelem+='<select name="ceattribute_type_placeholder_'+nextNum+'" id="attribute_type_placeholder_'+nextNum+'" size="1"></select>';
        nelem+='</td><td class="srch"><span id="ceattribute_value_placeholder_'+nextNum+'"></span></td></tr>';
        $('#ceattrCtlTR').before(nelem);
        $('#ceattribute_type_placeholder_1').find('option').clone().appendTo('#ceattribute_type_placeholder_' + nextNum);
	}
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
<cfquery name="ctCeAttributeType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select distinct(event_attribute_type) from ctcoll_event_attr_type order by event_attribute_type
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
				<option value="!unaccepted">NOT unaccepted</option>
				<cfloop query="ctverificationstatus">
					<option value="#ctverificationstatus.verificationstatus#">#ctverificationstatus.verificationstatus#</option>
				</cfloop>
			</select>
			<span class="infoLink" onclick="getCtDoc('ctverificationstatus',SpecData.verificationstatus.value);">Define</span>

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


	<tr>
		<td class="lbl">
			<select name="ceattribute_type_placeholder_1" id="ceattribute_type_placeholder_1" size="1">
				<option selected value="">[ pick an event-attribute ]</option>
					<cfloop query="ctCeAttributeType">
						<option value="#ctCeAttributeType.event_attribute_type#">#ctCeAttributeType.event_attribute_type#</option>
					</cfloop>
			  </select>
		</td>
		<td class="srch">
			<span id="ceattribute_value_placeholder_1"></span>
		</td>
	</tr>
	<tr id="ceattrCtlTR">
		<td colspan="2">
			<div style="margin-left:3em;margin:1em;padding:.5em;border:1px solid green;;">
				<div>
					<span class="likeLink" onclick="moreCEAttr()">Add Event-Attribute</span> for more search options.
					Click the label after selecting an attribute type for more information.
					Empty values are ignored.
				</div>
			</div>
		</td>

	</tr>
</table>
</cfoutput>