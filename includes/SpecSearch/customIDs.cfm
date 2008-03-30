
<script>
function changecustomOtherIdentifier (tgt) {
	DWREngine._execute(_cfscriptLocation, null, 'changecustomOtherIdentifier',tgt, success_changecustomOtherIdentifier);
}
function success_changecustomOtherIdentifier (result) {
	if (result == 'success') {
		var e = document.getElementById('customOtherIdentifier').className='';
	} else {
		alert('An error occured: ' + result);
	}
}

function closeThis(){
	var theDiv = document.getElementById('customDiv');
	document.body.removeChild(theDiv);
}
</script>
<cfoutput>
<cfif len(#exclusive_collection_id#) gt 0>
	<cfset oidTable = "cCTCOLL_OTHER_ID_TYPE#exclusive_collection_id#">
<cfelse>
	<cfset oidTable = "CTCOLL_OTHER_ID_TYPE">
</cfif>
<cfset myId=client.CustomOtherIdentifier>
<cfquery name="OtherIdType" datasource="#Application.web_user#">
	select distinct(other_id_type) FROM #oidTable# ORDER BY other_Id_Type
</cfquery>

	
<table class="ssrch">
	<tr>
		<td colspan="2" class="secHead">
				<span class="secLabel">Customize Identifiers</span>
				<span class="secControl" id="c_collevent"
					onclick="closeThis();">Close</span>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			My Other Identifier:
		</td>
		<td class="srch">
			<select name="customOtherIdentifier" id="customOtherIdentifier"
				size="1" onchange="this.className='red';changecustomOtherIdentifier(this.value);">
				<option value="">None</option>
				<cfloop query="OtherIdType">
					<option 
						<cfif myId is other_id_type>selected="selected"</cfif>
						value="#other_id_type#">#other_id_type#</option>
				</cfloop> 
			</select>
		</td>
	</tr>
</table>
</cfoutput>