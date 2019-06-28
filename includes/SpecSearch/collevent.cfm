<script type="text/javascript">
	jQuery(document).ready(function() {
		$("#begDate").datepicker();
		$("#endDate").datepicker();
		$("#inMon").multiselect();

		$(document).on("change", '[id^="ceattribute_type_placeholder_"]', function(){
			console.log('change');
			var i =  this.id;
			console.log('i:'+i);

			i=i.replace("ceattribute_type_placeholder_", "");

			console.log('i:'+i);

			var thisVal=this.value;

			console.log('thisVal:'+thisVal);

			if ($('#' + thisVal).length){
				alert('That Attribute has already been added.');
				$("#" + this.id).val('');
				return;
			}
			var thisTxt=$("#" + this.id + " option:selected").text();
			console.log('thisTxt:'+thisTxt);
			var nEl='<input type="text" name="' + thisVal + '" id="' + thisVal + '" placeholder="' + thisTxt + '">';
			//nEl+='<span class="infoLink" onclick="resetCEAttr(' + this.id + ')">reset</span>';
			console.log('nEl:'+nEl);

			$("#ceattribute_type_placeholder_" + i).html(nEl);
			// hide the placeholder/picker
			var nlbl='<span class="helpLink" id="_' +thisVal+'">'+thisTxt+'</span>';
			$("#" + this.id).hide().after(nlbl);
		});

	});

	function moreCEAttr(){
		var i;
		console.log('i:'+i);
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



	function populateEvtAttrs(id) {
		//console.log('populateEvtAttrs==got id:'+id);
		var idNum=id.replace('event_attribute_type_','');
		var currentTypeValue=$("#event_attribute_type_" + idNum).val();
		var valueObjName="event_attribute_value_" + idNum;
		var unitObjName="event_attribute_units_" + idNum;
		var unitsCellName="event_attribute_units_cell_" + idNum;
		var valueCellName="event_attribute_value_cell_" + idNum;
		if (currentTypeValue.length==0){
			//console.log('zero-length type; resetting');
			var s='<input  type="hidden" name="'+unitObjName+'" id="'+unitObjName+'" value="">';
			$("#"+unitsCellName).html(s);
			var s='<input  type="hidden" name="'+valueObjName+'" id="'+valueObjName+'" value="">';
			$("#"+valueCellName).html(s);
			return false;
		}
		//console.log('did not return false');
		var currentValue=$("#" + valueObjName).val();
		var currentUnits=$("#" + unitObjName).val();
		//console.log('currentTypeValue:'+currentTypeValue);
		//console.log('currentValue:'+currentValue);
		//console.log('currentUnits:'+currentUnits);

		jQuery.getJSON("/component/DataEntry.cfc",
			{
				method : "getEvtAttCodeTbl",
				attribute : currentTypeValue,
				element : currentTypeValue,
				returnformat : "json",
				queryformat : 'column'
			},
			function (r) {
				//console.log(r);
				if (r.STATUS != 'success'){
					alert('error occurred in getEvtAttCodeTbl');
					return false;
				} else {
					if (r.CTLFLD=='units'){
						var dv=$.parseJSON(r.DATA);
						//console.log(dv);
						var s='<select name="'+unitObjName+'" id="'+unitObjName+'">';
						s+='<option></option>';
						$.each(dv, function( index, value ) {
							//console.log(value[0]);
							s+='<option value="' + value[0] + '">' + value[0] + '</option>';
						});
						s+='</select>';
						//console.log(s);
						$("#"+unitsCellName).html(s);
						$("#"+unitObjName).val(currentUnits);

						var s='<input  type="number" step="any" name="'+valueObjName+'" id="'+valueObjName+'"  placeholder="value">';
						$("#"+valueCellName).html(s);
						$("#"+valueObjName).val(currentValue);
					}
					if (r.CTLFLD=='values'){
						var dv=$.parseJSON(r.DATA);
						var s='<select name="'+valueObjName+'" id="'+valueObjName+'">';
						s+='<option></option>';
						$.each(dv, function( index, value ) {
							s+='<option value="' + value[0] + '">' + value[0] + '</option>';
						});
						s+='</select>';

						$("#"+valueCellName).html(s);
						$("#"+valueObjName).val(currentValue);

						var s='<input  type="hidden" name="'+unitObjName+'" id="'+unitObjName+'" value="">';
						$("#"+unitsCellName).html(s);
					}
					if (r.CTLFLD=='none'){
						var s='<input type="text" size="40"  name="'+valueObjName+'" id="'+valueObjName+'" placeholder="value">';
						$("#"+valueCellName).html(s);
						$("#"+valueObjName).val(currentValue);

						var s='<input  type="hidden" name="'+unitObjName+'" id="'+unitObjName+'" value="">';
						$("#"+unitsCellName).html(s);
					}
				}
			}
		);
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
<cfquery name="ctcoll_event_attr_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select event_attribute_type from ctcoll_event_attr_type order by event_attribute_type
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
			<span class="helpLink" id="_event_attributes">Event Attributes:</span>
		</td>
		<td >
			<table border>
				<cfloop from="1" to="3" index="na">
					<tr class="">
						<td>
							<select name="event_attribute_type_#na#" id="event_attribute_type_#na#" onchange="populateEvtAttrs(this.id)">
								<option value="">select event attribute</option>
								<cfloop query="ctcoll_event_attr_type">
									<option value="#event_attribute_type#">#event_attribute_type#</option>
								</cfloop>
							</select>
						</td>
						<td id="event_attribute_value_cell_#na#">
							<select name="event_attribute_value_#na#" id="event_attribute_value_#na#"></select>
						</td>
						<td id="event_attribute_units_cell_#na#">
							<select name="event_attribute_units_#na#" id="event_attribute_units_#na#"></select>
						</td>
						<!----
						<td>
							<input type="hidden" name="evt_att_determiner_id_new_#na#" id="evt_att_determiner_id_new_#na#">
							<input placeholder="determiner" type="text" name="evt_att_determiner_new_#na#" id="evt_att_determiner_new_#na#" value="" size="20"
								onchange="pickAgentModal('evt_att_determiner_id_new_#na#',this.id,this.value); return false;"
			 					onKeyPress="return noenter(event);">
						</td>
						<td>
							<input type="text" name="event_att_determined_date_new_#na#" id="event_att_determined_date_new_#na#">

						</td>
						<td>
							<input type="text" name="event_determination_method_new_#na#" id="event_determination_method_new_#na#" size="20">
						</td>
						<td>
							<input type="text" name="event_attribute_remark_new_#na#" id="event_attribute_remark_new_#na#" size="20">
						</td>
						---->
					</tr>
				</cfloop>
			</table>
		</td>
</tr>

</table>
</cfoutput>