<script type="text/javascript">
	jQuery(document).ready(function() {
		$("#beg_entered_date").datepicker();
		$("#end_entered_date").datepicker();
		$("#beg_last_edit_date").datepicker();
		$("#end_last_edit_date").datepicker();
	});
</script>
<cfoutput>
<cfquery name="ctPermitType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select permit_type from ctpermit_type order by permit_type
</cfquery>
<cfquery name="ctCollObjDisp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select coll_obj_disposition from ctcoll_obj_disp order by coll_obj_disposition
</cfquery>
<cfquery name="ctFlags" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select flags from ctflags order by flags
</cfquery>		
<table id="t_identifiers" class="ssrch">
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_entered_date">Part Barcode Scan Date:</span>
		</td>
		<td class="srch">
			<input type="text" name="beg_pbcscan_date" id="beg_pbcscan_date" size="10" />-
			<input type="text" name="end_pbcscan_date" id="end_pbcscan_date" size="10" />
		</td>
	</tr>
	
	<tr>
		<td class="lbl">
			<span class="helpLink" id="anybarcode">Any Barcode:</span>
		</td>
		<td class="srch">
			<input type="text" name="anybarcode" id="anybarcode" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_loan_number">Loan Number:</span>
		</td>
		<td class="srch">
			<input name="loan_number" id="loan_number" type="text" size="50">
			<span class="infoLink" onclick="var e=document.getElementById('loan_number');e.value='='+e.value;">Add = for exact match</span>
			<span class="infoLink" onclick="$('##loan_number').val('*');">; * for anything</span>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_permit_issued_by">Permit Issued By:</span>
		</td>
		<td class="srch">
			<input name="permit_issued_by" id="permit_issued_by" type="text" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_permit_issued_to">Permit Issued To:</span>
		</td>
		<td class="srch">
			<input name="permit_issued_to" id="permit_issued_to" type="text" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_permit_type">Permit Type:</span>
		</td>
		<td class="srch">
			<select name="permit_type" id="permit_type" size="1">
				<option value=""></option>
				<cfloop query="ctPermitType">
					<option value = "#ctPermitType.permit_type#">#ctPermitType.permit_type#</option>
				 </cfloop>			
  			</select>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_permit_number">Permit Number:</span>
		</td>
		<td class="srch">
			<input type="text" name="permit_num" id="permit_num" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_entered_by">Entered By:</span>
		</td>
		<td class="srch">
			<input type="text" name="entered_by" id="entered_by" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_entered_date">Entered Date:</span>
		</td>
		<td class="srch">
			<input type="text" name="beg_entered_date" id="beg_entered_date" size="10" />-
			<input type="text" name="end_entered_date" id="end_entered_date" size="10" />
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_last_edit_by">Last Edited By:</span>
		</td>
		<td class="srch">
			<input type="text" name="last_edit_by" id="last_edit_by" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="last_edit_date">Last Edited Date:</span>
		</td>
		<td class="srch">
			<input type="text" name="beg_last_edit_date" id="beg_last_edit_date" size="10">-
			<input type="text" name="end_last_edit_date" id="end_last_edit_date" size="10">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_disposition">Part Disposition:</span>
		</td>
		<td class="srch">
			<select name="part_disposition" id="part_disposition" size="1">
				<option value=""></option>
				<cfloop query="ctCollObjDisp">
					<option value="#ctCollObjDisp.coll_obj_disposition#">#ctCollObjDisp.coll_obj_disposition#</option>
				</cfloop>
			</select><span class="infoLink" onclick="getCtDoc('ctcoll_obj_disp',SpecData.part_disposition.value);">Define</span>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_print_flag">Print Flag:</span>
		</td>
		<td class="srch">
			<select name="print_fg" id="print_fg" size="1">
				<option value=""></option>
				<option value="1">Box</option>
				<option value="2">Vial</option>
			</select>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="coll_object_remarks">Remarks:</span>
		</td>
		<td class="srch">
			<input type="text" name="remark" id="remark" size="50" />
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="flags">Missing (flags):</span>
		</td>
		<td class="srch">
			<select name="coll_obj_flags" id="coll_obj_flags" size="1">
				<option value=""></option>
				<cfloop query="ctFlags">
					<option value="#flags#">#flags#</option>
				</cfloop>
			</select>
		</td>
	</tr>				
</table>
</cfoutput>