<script language="javascript" type="text/javascript">
function changecustomOtherIdentifier (tgt) {
	jQuery.getJSON("/component/functions.cfc",
		{
			method : "changecustomOtherIdentifier",
			tgt : tgt,
			returnformat : "json",
			queryformat : 'column'
		},
		success_changecustomOtherIdentifier
	);
}
function success_changecustomOtherIdentifier (result) {
	if (result == 'success') {
		document.getElementById('customOtherIdentifier').className='';
	} else {
		alert('An error occured: ' + result);
	}
}

function closeThis(){
	document.location=location.href;
	var theDiv = document.getElementById('customDiv');
	document.body.removeChild(theDiv);
}
function changefancyCOID (tgt) {
	jQuery.getJSON("/component/functions.cfc",
		{
			method : "changefancyCOID",
			tgt : tgt,
			returnformat : "json",
			queryformat : 'column'
		},
		success_changefancyCOID
	);
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
<cfquery name="OtherIdType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select distinct(other_id_type) FROM CTCOLL_OTHER_ID_TYPE ORDER BY other_Id_Type
</cfquery>
<cfquery name="collid" datasource="uam_god">
	select cf_collection_id,collection from cf_collection
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
						<cfif session.CustomOtherIdentifier is other_id_type>selected="selected"</cfif>
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
				<option <cfif #session.fancyCOID# is not 1>selected="selected"</cfif> value="">No</option>
				<option <cfif #session.fancyCOID# is 1>selected="selected"</cfif> value="1">Yes</option>
			</select>
		</td>
	</tr>
	<cfif len(session.roles) gt 0 and session.roles is "public">
	<tr>
		<td class="lbl">
			Filter By Collection
		</td>
		<td class="srch">
			<cfif isdefined("session.portal_id")>
				<cfset pid=session.portal_id>
			<cfelse>
				<cfset pid="">
			</cfif>
			<select name="exclusive_collection_id" id="exclusive_collection_id"
				onchange="this.className='red';changeexclusive_collection_id(this.value);" size="1">
			 	<option  <cfif pid is "" or pid is 0>selected="selected" </cfif> value="">All</option>
			  	<cfloop query="collid"> 
					<option <cfif pid is cf_collection_id>selected="selected" </cfif> value="#cf_collection_id#">#collection#</option>
			  	</cfloop> 
			</select>
		</td>
	</tr>
	</cfif>
</table>
</cfoutput>