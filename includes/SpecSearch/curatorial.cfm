<cfoutput>
<cfquery name="ctPermitType" datasource="#Application.web_user#">
	select * from ctpermit_type
</cfquery>
<cfquery name="ctCollObjDisp" datasource="#Application.web_user#">
	select coll_obj_disposition from ctcoll_obj_disp
</cfquery>
<cfquery name="ctFlags" datasource="#Application.web_user#">
	select flags from ctflags
</cfquery>		
<table id="t_identifiers" class="ssrch">
	<tr>
		<td class="lbl">
			Permit Issued By:
		</td>
		<td class="srch">
			<input name="permit_issued_by" type="text" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			Permit Issued To:
		</td>
		<td class="srch">
			<input name="permit_issued_to" type="text" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			Permit Type:
		</td>
		<td class="srch">
			<select name="permit_Type" size="1">
				<option value=""></option>
				<cfloop query="ctPermitType">
					<option value = "#ctPermitType.permit_type#">#ctPermitType.permit_type#</option>
				 </cfloop>			
  			</select>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			Permit Number:
		</td>
		<td class="srch">
			<input type="text" name="permit_num" size="50">
			<span class="infoLink" onclick="getHelp('get_permit_number');">Pick</span>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			Entered By:
		</td>
		<td class="srch">
			<input type="text" name="entered_by" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			Disposition:
		</td>
		<td class="srch">
			<select name="coll_obj_disposition" size="1">
				<option value=""></option>
				<cfloop query="ctCollObjDisp">
					<option value="#ctCollObjDisp.coll_obj_disposition#">#ctCollObjDisp.coll_obj_disposition#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			Print Flag:
		</td>
		<td class="srch">
			<select name="print_fg" size="1">
				<option value=""></option>
				<option value="1">Box</option>
				<option value="2">Vial</option>
			</select>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			Entered Date:
		</td>
		<td class="srch">
			<input type="text" name="beg_entered_date" size="10" />-<input type="text" name="end_entered_date" size="10" />
		</td>
	</tr>
	<tr>
		<td class="lbl">
			Remarks:
		</td>
		<td class="srch">
			<input type="text" name="remark" size="50" />
		</td>
	</tr>
	<tr>
		<td class="lbl">
			Missing (flags):
		</td>
		<td class="srch">
			<select name="coll_obj_flags" size="1">
				<option value=""></option>
				<cfloop query="ctFlags">
					<option value="#flags#">#flags#</option>
				</cfloop>
			</select>
		</td>
	</tr>				
</table>
</cfoutput>