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
	document.location=parent.href;
	var theDiv = document.getElementById('customDiv');
	document.body.removeChild(theDiv);
}

function changeexclusive_collection_id (tgt) {
	DWREngine._execute(_cfscriptLocation, null, 'changeexclusive_collection_id',tgt, success_changeexclusive_collection_id);
}
function success_changeexclusive_collection_id (result) {
	if (result == 'success') {
		var e = document.getElementById('exclusive_collection_id').className='';
	} else {
		alert('An error occured: ' + result);
	}
}


function changefancyCOID (tgt) {
	DWREngine._execute(_cfscriptLocation, null, 'changefancyCOID',tgt, success_changefancyCOID);
}
function success_changefancyCOID (result) {
	if (result == 'success') {
		var e = document.getElementById('fancyCOID').className='';
	} else {
		alert('An error occured: ' + result);
	}
}

</script>
<cfoutput>
<cfif len(#client.exclusive_collection_id#) gt 0>
	<cfset oidTable = "cCTCOLL_OTHER_ID_TYPE#exclusive_collection_id#">
<cfelse>
	<cfset oidTable = "CTCOLL_OTHER_ID_TYPE">
</cfif>
<cfset myId=client.CustomOtherIdentifier>
<cfset mcid=client.exclusive_collection_id>
<cfquery name="OtherIdType" datasource="#Application.web_user#">
	select distinct(other_id_type) FROM #oidTable# ORDER BY other_Id_Type
</cfquery>
<cfquery name="collid" datasource="#Application.web_user#">
	select collection_id,collection  from collection
	order by collection
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
	<tr>
		<td class="lbl">
			Show 3-part ID Search:
		</td>
		<td class="srch">
			<select name="fancyCOID" id="fancyCOID"
				size="1" onchange="this.className='red';changefancyCOID(this.value);">
				<option <cfif #client.fancyCOID# is not 1>selected="selected"</cfif> value="">No</option>
				<option <cfif #client.fancyCOID# is 1>selected="selected"</cfif> value="1">Yes</option>
			</select>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			Filter By Collection
		</td>
		<td class="srch">
			<select name="exclusive_collection_id" id="exclusive_collection_id"
				onchange="this.className='red';changeexclusive_collection_id(this.value);" size="1">
			 	<option value="">All</option>
			  	<cfloop query="collid"> 
					<option <cfif #mcid# is "#collection_id#"> selected=selected </cfif> value="#collection_id#">#collection#</option>
			  	</cfloop> 
			</select>
		</td>
	</tr>
		
		

</table>
</cfoutput>