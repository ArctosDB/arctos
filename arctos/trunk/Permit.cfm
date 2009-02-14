<cfinclude template = "includes/_header.cfm">
<!--- no security --->
<cfquery name="ctPermitType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from ctpermit_type
</cfquery>
<cfif #action# is "nothing">
<cfoutput>
Search for permits. Any part of dates and names accepted, case isn't important.<br>
Leave "until date" fields empty unless you use the field to its left.<br>
<cfform name="findPermit" action="Permit.cfm" method="post">
	<input type="hidden" name="Action" value="search">
	<table><tr>
			<td align="right">Issued By</td>
			<td><input type="text" name="IssuedByAgent"></td>
			<td align="right">Issued To</td>
			<td><input type="text" name="IssuedToAgent"></td>
		</tr>
		<tr>
			<td align="right">Issued Date</td>
			<td><input type="text" name="issued_date"></td>
			<td align="right">Issued Until Date (leave blank otherwise)</td>
			<td><input type="text" name="issued_until_date"></td>
		</tr>
		<tr>
			<td align="right">Renewed Date</td>
			<td><input type="text" name="renewed_date"></td>
			<td align="right">Renewed Until Date (leave blank otherwise)</td>
			<td><input type="text" name="renewed_until_date"></td>
		</tr>
		<tr>
			<td align="right">Expiration Date</td>
			<td><input type="text" name="exp_date"></td>
			<td align="right">Expiration Until Date (leave blank otherwise)</td>
			<td><input type="text" name="exp_until_date"></td>
		</tr>
		<tr>
			<td align="right">Permit Type</td>
			<td>
				<select name="permit_type" size="1">
					<option value=""></option>
					<cfloop query="ctPermitType">
						<option value = "#ctPermitType.permit_type#">#ctPermitType.permit_type#</option>
					</cfloop>
				</select>
			</td>
			<td align="right">Remarks</td>
			<td><input type="text" name="permit_remarks"></td>
		</tr>
		<tr>
			<td align="right">Permit Number</td>
			<td><input type="text" name="permit_num"></td>
			<td align="right">Contact Agent</td>
			<td><input type="text" name="ContactAgent"></td>
		</tr>
		<tr>
			<td colspan="4" align="center">

				<input type="button" value="Search" class="schBtn"
   					onmouseover="this.className='schBtn btnhov'" onmouseout="this.className='schBtn'"
					onClick="findPermit.Action.value='search';submit();">




				 <input type="reset" value="Clear" class="qutBtn"
   onmouseover="this.className='qutBtn btnhov'" onmouseout="this.className='qutBtn'">

				<input type="button" value="Create New Permit" class="insBtn"
   onmouseover="this.className='insBtn btnhov'" onmouseout="this.className='insBtn'"
   onClick="findPermit.Action.value='newPermit';submit();">

			</td>
		</tr>
	</table>
</cfform>
<hr>
</cfoutput>
</cfif>
<!--------------------------------------------------------------------------->
<cfif #Action# is "search">
<cfparam name="IssuedByAgent" default="">
<cfparam name="IssuedToAgent" default="">
<cfparam name="issued_Date" default="">
<cfparam name="renewed_Date" default="">
<cfparam name="exp_Date" default="">
<cfparam name="permit_Num" default="">
<cfparam name="permit_Type" default="">
<cfparam name="permit_remarks" default="">
<cfparam name="permit_id" default="">
<cfparam name="ContactAgent" default="">
<cfoutput>
<!--- set dateformat --->
<cfif not isdefined("sql") or len(#sql#) is 0>
	<!--- regular old search ---->
<cfset sql = "select permit.permit_id,
	issuedBy.agent_name as IssuedByAgent,
	issuedTo.agent_name as IssuedToAgent,
	Contact.agent_name as ContactAgent,
	issued_Date,
	renewed_Date,
	exp_Date,
	permit_Num,
	permit_Type,
	permit_remarks
from
	permit,  preferred_agent_name issuedTo, preferred_agent_name issuedBy, preferred_agent_name Contact
where
	permit.issued_by_agent_id = issuedBy.agent_id (+) and
	permit.issued_to_agent_id = issuedTo.agent_id (+) and
	permit.contact_agent_id = Contact.agent_id (+)">

<cfif len(#IssuedByAgent#) gt 0>
	<cfset sql = "#sql# AND upper(issuedBy.agent_name) like '%#ucase(IssuedByAgent)#%'">
</cfif>
<cfif len(#IssuedToAgent#) gt 0>
	<cfset sql = "#sql# AND upper(issuedTo.agent_name) like '%#ucase(IssuedToAgent)#%'">
</cfif>
<cfif len(#issued_date#) gt 0>
	<cfif len(#issued_until_date#) gt 0>
		<cfset sql = "#sql# AND upper(issued_date) between to_date('#issued_date#', 'DD Mon YYYY')
														and to_date('#issued_until_date#', 'DD Mon YYYY')">
	<cfelse>
		<cfset sql = "#sql# AND upper(issued_date) like to_date('#issued_date#', 'DD Mon YYYY')">
	</cfif>
</cfif>
<cfif len(#renewed_date#) gt 0>
	<cfif len(#renewed_until_date#) gt 0>
		<cfset sql = "#sql# AND upper(renewed_date) between to_date('#renewed_date#', 'DD Mon YYYY')
														and to_date('#renewed_until_date#', 'DD Mon YYYY')">
	<cfelse>
		<cfset sql = "#sql# AND upper(renewed_date) like to_date('#renewed_date#', 'DD Mon YYYY')">
	</cfif>
</cfif>
<cfif len(#exp_date#) gt 0>
	<cfif len(#exp_until_date#) gt 0>
		<cfset sql = "#sql# AND upper(exp_date) between to_date('#exp_date#', 'DD Mon YYYY')
														and to_date('#exp_until_date#', 'DD Mon YYYY')">
	<cfelse>
		<cfset sql = "#sql# AND upper(exp_date) like to_date('#exp_date#', 'DD Mon YYYY')">
	</cfif>
</cfif>
<cfif len(#permit_Num#) gt 0>
	<cfset sql = "#sql# AND upper(permit_Num) like '%#ucase(permit_Num)#%'">
</cfif>
<cfif len(#ContactAgent#) gt 0>
	<cfset sql = "#sql# AND upper(Contact.agent_name) like '%#ucase(ContactAgent)#%'
			AND permit.contact_agent_id = Contact.agent_id">
</cfif>
<cfif len(#permit_type#) gt 0>
	<cfset permit_Type = #replace(permit_type,"'","''","All")#>
	<cfset sql = "#sql# AND permit_type = '#permit_type#'">
</cfif>
<cfif len(#permit_remarks#) gt 0>
	<cfset sql = "#sql# AND upper(permit_remarks) like '%#ucase(permit_remarks)#%'">
</cfif>
<cfif len(#permit_id#) gt 0>
	<cfset sql = "#sql# AND permit_id = #permit_id#">
</cfif>

<cfif #sql# is "select * from permit, agent_name issuedTo, agent_name issuedBy where permit.issued_by_agent_id = issuedBy.agent_id and permit.issued_to_agent_id = issuedTo.agent_id ">
	Enter some criteria.<cfabort>
</cfif>
<cfset thisSql = #sql#>
<cfelse><!--- came in with sql defined ---->
	<cfset thisSql = "#sql# ORDER BY #order_by# #order_order#">
</cfif><!--- end sql isdefined --->
<cfquery name="matchPermit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	#preservesinglequotes(thisSql)#
</cfquery>

<table border>
	<tr>
	<form name="reorder" method="post" action="Permit.cfm">
		<input type="hidden" name="sql" value="#sql#">
		<input type="hidden" name="action" value="search">
		<input type="hidden" name="order_by">
		<input type="hidden" name="order_order">
		<td>
			<strong>Permit Number</strong>
			<cfset thisTerm = "permit_num">
			<cfset thisName = #replace(thisTerm,",","_","all")#>
			<br>
			<a href="javascript: void"
				onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='asc';reorder.submit();"
				onMouseOver="self.status='Sort Ascending.';#thisName#up.src='/images/up_mo.gif';return true;"
				onmouseout="self.status='';#thisName#up.src='/images/up.gif';return true;">
				<img src="/images/up.gif" border="0" name="#thisName#up"></a>
			<a href="javascript: void"
				onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='desc';reorder.submit();"
				onMouseOver="self.status='Sort Descending.';#thisName#dn.src='/images/down_mo.gif';return true;"
				onmouseout="self.status='';#thisName#dn.src='/images/down.gif';return true;">
				<img src="/images/down.gif" border="0" name="#thisName#dn"></a>
		</td>
		<td>
			<strong>Permit Type</strong>
			<cfset thisTerm = "permit_Type">
			<cfset thisName = #replace(thisTerm,",","_","all")#>
			<br>
			<a href="javascript: void"
				onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='asc';reorder.submit();"
				onMouseOver="self.status='Sort Ascending.';#thisName#up.src='/images/up_mo.gif';return true;"
				onmouseout="self.status='';#thisName#up.src='/images/up.gif';return true;">
				<img src="/images/up.gif" border="0" name="#thisName#up"></a>
			<a href="javascript: void"
				onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='desc';reorder.submit();"
				onMouseOver="self.status='Sort Descending.';#thisName#dn.src='/images/down_mo.gif';return true;"
				onmouseout="self.status='';#thisName#dn.src='/images/down.gif';return true;">
				<img src="/images/down.gif" border="0" name="#thisName#dn"></a>
		</td>
		<td>
			<strong>Issued To</strong>
			<cfset thisTerm = "IssuedToAgent">
			<cfset thisName = #replace(thisTerm,",","_","all")#>
			<br>
			<a href="javascript: void"
				onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='asc';reorder.submit();"
				onMouseOver="self.status='Sort Ascending.';#thisName#up.src='/images/up_mo.gif';return true;"
				onmouseout="self.status='';#thisName#up.src='/images/up.gif';return true;">
				<img src="/images/up.gif" border="0" name="#thisName#up"></a>
			<a href="javascript: void"
				onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='desc';reorder.submit();"
				onMouseOver="self.status='Sort Descending.';#thisName#dn.src='/images/down_mo.gif';return true;"
				onmouseout="self.status='';#thisName#dn.src='/images/down.gif';return true;">
				<img src="/images/down.gif" border="0" name="#thisName#dn"></a>
		</td>
		<td>
			<strong>Issued By</strong>
			<cfset thisTerm = "IssuedByAgent">
			<cfset thisName = #replace(thisTerm,",","_","all")#>
			<br>
			<a href="javascript: void"
				onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='asc';reorder.submit();"
				onMouseOver="self.status='Sort Ascending.';#thisName#up.src='/images/up_mo.gif';return true;"
				onmouseout="self.status='';#thisName#up.src='/images/up.gif';return true;">
				<img src="/images/up.gif" border="0" name="#thisName#up"></a>
			<a href="javascript: void"
				onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='desc';reorder.submit();"
				onMouseOver="self.status='Sort Descending.';#thisName#dn.src='/images/down_mo.gif';return true;"
				onmouseout="self.status='';#thisName#dn.src='/images/down.gif';return true;">
				<img src="/images/down.gif" border="0" name="#thisName#dn"></a>
		</td>
		<td>
			<strong>Issued Date</strong>
			<cfset thisTerm = "issued_Date">
			<cfset thisName = #replace(thisTerm,",","_","all")#>
			<br>
			<a href="javascript: void"
				onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='asc';reorder.submit();"
				onMouseOver="self.status='Sort Ascending.';#thisName#up.src='/images/up_mo.gif';return true;"
				onmouseout="self.status='';#thisName#up.src='/images/up.gif';return true;">
				<img src="/images/up.gif" border="0" name="#thisName#up"></a>
			<a href="javascript: void"
				onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='desc';reorder.submit();"
				onMouseOver="self.status='Sort Descending.';#thisName#dn.src='/images/down_mo.gif';return true;"
				onmouseout="self.status='';#thisName#dn.src='/images/down.gif';return true;">
				<img src="/images/down.gif" border="0" name="#thisName#dn"></a>
		</td>
		<td>
			<strong>Renewed Date</strong>
			<cfset thisTerm = "renewed_Date">
			<cfset thisName = #replace(thisTerm,",","_","all")#>
			<br>
			<a href="javascript: void"
				onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='asc';reorder.submit();"
				onMouseOver="self.status='Sort Ascending.';#thisName#up.src='/images/up_mo.gif';return true;"
				onmouseout="self.status='';#thisName#up.src='/images/up.gif';return true;">
				<img src="/images/up.gif" border="0" name="#thisName#up"></a>
			<a href="javascript: void"
				onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='desc';reorder.submit();"
				onMouseOver="self.status='Sort Descending.';#thisName#dn.src='/images/down_mo.gif';return true;"
				onmouseout="self.status='';#thisName#dn.src='/images/down.gif';return true;">
				<img src="/images/down.gif" border="0" name="#thisName#dn"></a>
		</td>
		<td>
			<strong>Expires Date</strong>
			<br>
			<cfset thisTerm = "exp_Date">
			<cfset thisName = #replace(thisTerm,",","_","all")#>
			<a href="javascript: void"
				onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='asc';reorder.submit();"
				onMouseOver="self.status='Sort Ascending.';#thisName#up.src='/images/up_mo.gif';return true;"
				onmouseout="self.status='';#thisName#up.src='/images/up.gif';return true;">
				<img src="/images/up.gif" border="0" name="#thisName#up"></a>
			<a href="javascript: void"
				onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='desc';reorder.submit();"
				onMouseOver="self.status='Sort Descending.';#thisName#dn.src='/images/down_mo.gif';return true;"
				onmouseout="self.status='';#thisName#dn.src='/images/down.gif';return true;">
				<img src="/images/down.gif" border="0" name="#thisName#dn"></a>
		</td>
		<td><strong>Remarks</strong></td>
		<td>
			<strong>Contact</strong>
			<br>
			<cfset thisTerm = "ContactAgent">
			<cfset thisName = #replace(thisTerm,",","_","all")#>
			<a href="javascript: void"
				onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='asc';reorder.submit();"
				onMouseOver="self.status='Sort Ascending.';#thisName#up.src='/images/up_mo.gif';return true;"
				onmouseout="self.status='';#thisName#up.src='/images/up.gif';return true;">
				<img src="/images/up.gif" border="0" name="#thisName#up"></a>
			<a href="javascript: void"
				onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='desc';reorder.submit();"
				onMouseOver="self.status='Sort Descending.';#thisName#dn.src='/images/down_mo.gif';return true;"
				onmouseout="self.status='';#thisName#dn.src='/images/down.gif';return true;">
				<img src="/images/down.gif" border="0" name="#thisName#dn"></a>
		</td>
		<td>&nbsp;</td>
	</form>
	</tr>
</cfoutput>
<a href="Permit.cfm">Search Again</a>
<cfoutput query="matchPermit" group="permit_id">
	<cfif len(#exp_Date#) gt 0>
		<cfset ExpiresInDays = #datediff("d",now(),exp_Date)#>
		<cfif ExpiresInDays lt 0>
			<cfset tabCol = "##666666">
		<cfelseif ExpiresInDays lt 10>
			<cfset tabCol = "##FF0000">
		<cfelseif ExpiresInDays lt 30>
			<cfset tabCol = "##FF8040">
		<cfelseif ExpiresInDays lt 180>
			<cfset tabCol = "##FFFF00">
		<cfelseif ExpiresInDays gte 180>
			<cfset tabCol = "##00FF00">
		<cfelse>
			<cfset tabCol = "##FFFFFF">
		</cfif>
	<cfelse>
		<!--- there's a permit with no exp date - treat this as bad! --->
		<cfset tabCol = "##FF0000">
	</cfif>
	<tr>
		<td>#permit_Num#</td>
		<td>#permit_Type#</td>
		<td>#IssuedToAgent#</td>
		<td>#IssuedByAgent#</td>
		<td>#dateformat(issued_Date,"dd mmm yyyy")#</td>
		<td>#dateformat(renewed_Date,"dd mmm yyyy")#</td>
		<td style="background-color:#tabCol#; ">
			#dateformat(exp_Date,"dd mmm yyyy")#
			<cfif len(#exp_Date#) is 0>
				not given!
			<cfelseif #ExpiresInDays# lt 0>
				<font size="-2"><br>(expired)</font>
			<cfelse>
				<font size="-2"><br>(exp in #ExpiresInDays# d.)</font>
			</cfif>
		</td>
		<td>#permit_remarks#</td>
		<td>#contactAgent#</td>
		<td>
	<form action="Permit.cfm" method="post" name="Copy">
	<input type="hidden" name="permit_id" value="#permit_id#">
	<input type="hidden" name="Action" value="editPermit">
		<input type="submit" value="Edit this permit" class="lnkBtn"
   				onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'">
	</form>
	<form action="editAccn.cfm" method="post">
	<input type="hidden" name="permit_id" value="#permit_id#">
	<input type="hidden" name="Action" value="findAccessions">
		<input type="submit" value="Accession List" class="lnkBtn"
				onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'">
	</form>
	<form action="Reports/permit.cfm" method="post">
	<input type="hidden" name="permit_id" value="#permit_id#">
		<input type="submit" value="Permit Report" class="lnkBtn"
				onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'">
	</form>
		</td>
	</tr>




</cfoutput>
</table>
</cfif>
<!--------------------------------------------------------------------------->
<!--------------------------------------------------------------------------->
<cfif #Action# is "newPermit">
<font size="+1"><strong>New Permit</strong></font><br>
	<cfoutput>
	<cfform name="newPermit" action="Permit.cfm" method="post">
	<input type="hidden" name="Action" value="createPermit">
	<table>
		<tr>
			<td>Issued By</td>
			<td colspan="3">
			<input type="hidden" name="IssuedByAgentId">
			<input type="text" name="IssuedByAgent" class="reqdClr" size="50"
		 onchange="getAgent('IssuedByAgentId','IssuedByAgent','newPermit',this.value); return false;"
			  onKeyUp="return noenter();">


</td>
		</tr>
			<tr>
			<td>Issued To</td>
			<td colspan="3">
			<input type="hidden" name="IssuedToAgentId">
			<input type="text" name="IssuedToAgent" class="reqdClr" size="50"
		 onchange="getAgent('IssuedToAgentId','IssuedToAgent','newPermit',this.value); return false;"
			  onKeyUp="return noenter();">


		</td>
		</tr>
		<tr>
			<td>Contact Person</td>
			<td colspan="3">
			<input type="hidden" name="contact_agent_id">
			<input type="text" name="ContactAgent" size="50"
		 		onchange="getAgent('contact_agent_id','ContactAgent','newPermit',this.value); return false;"
			  	onKeyUp="return noenter();">


		</td>
		</tr>
		<tr>
			<td>Issued Date</td>
			<td><input type="text" name="issued_Date"></td>
			<td>Renewed Date</td>
			<td><input type="text" name="renewed_Date"></td>
		</tr>
		<tr>
			<td>Expiration Date</td>
			<td><input type="text" name="exp_Date"></td>
			<td>Permit Number</td>
			<td><input type="text" name="permit_Num"></td>
		</tr>
		<tr>
			<td>Permit Type</td>
			<td>
				<select name="permit_Type" size="1" class="reqdClr">
					<option value=""></option>
					<cfloop query="ctPermitType">
						<option value = "#ctPermitType.permit_type#">#ctPermitType.permit_type#</option>
					</cfloop>
				</select>
			</td>
			<td>Remarks</td>
			<td><input type="text" name="permit_remarks"></td>
		</tr>
		<tr>
			<td colspan="4" align="center">
				<input type="submit" value="Save this permit" class="insBtn"
   					onmouseover="this.className='insBtn btnhov'" onmouseout="this.className='insBtn'">

					<input type="button" value="Quit" class="qutBtn"
   					onmouseover="this.className='qutBtn btnhov'" onmouseout="this.className='qutBtn'"
					 onClick="document.location='Permit.cfm'">

			</td>
		</tr>
	</table>
</cfform>
	</cfoutput>
</cfif>
<!--------------------------------------------------------------------------------------------------->
<!--------------------------------------------------------------------------------------------------->
<cfif #Action# is "editPermit">
<font size="+1"><strong>Edit Permit</strong></font><br>
<cfoutput>
<cfif not isdefined("permit_id") OR len(#permit_id#) is 0>
	Something bad happened. You didn't pass this form a permit_id. Go back and try again.<cfabort>
</cfif>
<cfquery name="permitInfo" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select permit.permit_id,
	issuedBy.agent_name as IssuedByAgent,
	issuedBy.agent_id as IssuedByAgentID,
	issuedTo.agent_name as IssuedToAgent,
	issuedTo.agent_id as IssuedToAgentID,
	contact_agent_id,
	contact.agent_name as ContactAgent,
	issued_Date,
	renewed_Date,
	exp_Date,
	permit_Num,
	permit_Type,
	permit_remarks
	from
		permit,
		preferred_agent_name issuedTo,
		preferred_agent_name issuedBy ,
		preferred_agent_name contact
	where
		permit.issued_by_agent_id = issuedBy.agent_id (+) and
	permit.issued_to_agent_id = issuedTo.agent_id (+) AND
	permit.contact_agent_id = contact.agent_id (+)
	and permit_id=#permit_id#
	order by permit_id
</cfquery>
</cfoutput>
<cfoutput query="permitInfo" group="permit_id">
<cfform name="newPermit" action="Permit.cfm" method="post">
	<input type="hidden" name="Action">
	<input type="hidden" name="permit_id" value="#permit_id#">
	<table>
		<tr>
			<td>Issued By</td>
			<td colspan="3">
				<input type="hidden" name="IssuedByAgentId">
				<input type="hidden" name="IssuedByOldAgentId" value="#IssuedByAgentID#">
				<input type="text" name="IssuedByAgent" class="reqdClr" size="50"
				value="#IssuedByAgent#"
		 onchange="getAgent('IssuedByAgentId','IssuedByAgent','newPermit',this.value); return false;"
			  onKeyUp="return noenter();">

		  </td>
		</tr>
		<tr>
			<td>Issued To</td>
			<td colspan="3">
				<input type="hidden" name="IssuedToAgentId">
				<input type="text" name="IssuedToAgent" class="reqdClr" size="50"
				value="#IssuedToAgent#"
		 onchange="getAgent('IssuedToAgentId','IssuedToAgent','newPermit',this.value); return false;"
			  onKeyUp="return noenter();">
			</td>
		</tr>
		<tr>
			<td>Contact Person</td>
			<td colspan="3">
			<input type="hidden" name="contact_agent_id" value="#contact_agent_id#">
			<input type="text" name="ContactAgent" class="reqdClr" size="50" value="#ContactAgent#"
		 onchange="getAgent('contact_agent_id','ContactAgent','newPermit',this.value); return false;"
			  onKeyUp="return noenter();">


		</td>
		</tr>
		<tr>
			<td>Issued Date</td>
			<td><input type="text" name="issued_Date" value="#dateformat(issued_Date,"dd-mmm-yyyy")#"></td>
			<td>Renewed Date</td>
			<td><input type="text" name="renewed_Date" value="#dateformat(renewed_Date,"dd-mmm-yyyy")#"></td>
		</tr>
		<tr>
			<td>Expiration Date</td>
			<td><input type="text" name="exp_Date" value="#dateformat(exp_Date,"dd-mmm-yyyy")#"></td>
			<td>Permit Number</td>
			<td><input type="text" name="permit_Num" value="#permit_Num#"></td>
		</tr>
		<tr>
			<td>Permit Type</td>
			<td>
				<select name="permit_Type" size="1">
					<option value=""></option>
					<cfloop query="ctPermitType">
						<option <cfif #ctPermitType.permit_type# is "#permitInfo.permit_type#"> selected </cfif>value = "#ctPermitType.permit_type#">#ctPermitType.permit_type#</option>
					</cfloop>
				</select>
			</td>
			<td>Remarks</td>
			<td><input type="text" name="permit_remarks" value="#permit_remarks#"></td>
		</tr>
		<tr>
			<td colspan="4" align="center">
				<input type="submit" value="Save changes" class="savBtn"
   					onmouseover="this.className='savBtn btnhov'" onmouseout="this.className='savBtn'"
					onCLick="newPermit.Action.value='saveChanges';">

				<input type="button" value="Quit" class="qutBtn"
   					onmouseover="this.className='qutBtn btnhov'" onmouseout="this.className='qutBtn'"
					 onClick="document.location='Permit.cfm'">

				<input type="button" value="Delete" class="delBtn"
   onmouseover="this.className='delBtn btnhov'" onmouseout="this.className='delBtn'"
   onCLick="newPermit.Action.value='deletePermit';confirmDelete('newPermit');">

			</td>
		</tr>
	</table>
</cfform>
</cfoutput>
</cfif>
<!--------------------------------------------------------------------------------------------------->
<!--------------------------------------------------------------------------------------------------->
<cfif #Action# is "saveChanges">
<cfoutput>
<cfquery name="updatePermit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
UPDATE permit SET
	permit_id = #permit_id#
	<cfif len(#issuedByAgentId#) gt 0>
	 	,ISSUED_BY_AGENT_ID = #issuedByAgentId#
    </cfif>
	 <cfif len(#ISSUED_DATE#) gt 0>
	 	,ISSUED_DATE = '#ISSUED_DATE#'
	 </cfif>
	 <cfif len(#IssuedToAgentId#) gt 0>
	 	,ISSUED_TO_AGENT_ID = #IssuedToAgentId#
	 </cfif>
	 <cfif len(#RENEWED_DATE#) gt 0>
	 	,RENEWED_DATE = '#RENEWED_DATE#'
	 </cfif>
	 <cfif len(#EXP_DATE#) gt 0>
	 	,EXP_DATE = '#EXP_DATE#'
	 </cfif>
	 <cfif len(#PERMIT_NUM#) gt 0>
	 	,PERMIT_NUM = '#PERMIT_NUM#'
	 </cfif>
	 <cfif len(#PERMIT_TYPE#) gt 0>
	 	,PERMIT_TYPE = '#PERMIT_TYPE#'
	 </cfif>
	<cfif len(#PERMIT_REMARKS#) gt 0>
	 	,PERMIT_REMARKS = '#PERMIT_REMARKS#'
    </cfif>
	 <cfif len(#contact_agent_id#) gt 0>
	 	,contact_agent_id = #contact_agent_id#
	<cfelse>
		,contact_agent_id = null
	 </cfif>
	 where  permit_id = #permit_id#
</cfquery>
<cflocation url="Permit.cfm?Action=editPermit&permit_id=#permit_id#">
</cfoutput>
</cfif>
<!--------------------------------------------------------------------------------------------------->
<!--------------------------------------------------------------------------------------------------->
<cfif #Action# is "createPermit">
<cfoutput>
<cfquery name="nextPermit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select sq_permit_id.nextval nextPermit from dual
</cfquery>
<cftry>
<cfquery name="newPermit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
INSERT INTO permit (
	 PERMIT_ID,
	 ISSUED_BY_AGENT_ID
	 <cfif len(#ISSUED_DATE#) gt 0>
	 	,ISSUED_DATE
	 </cfif>
	 ,ISSUED_TO_AGENT_ID
	  <cfif len(#RENEWED_DATE#) gt 0>
	 	,RENEWED_DATE
	 </cfif>
	 <cfif len(#EXP_DATE#) gt 0>
	 	,EXP_DATE
	 </cfif>
	 <cfif len(#PERMIT_NUM#) gt 0>
	 	,PERMIT_NUM
	 </cfif>
	 ,PERMIT_TYPE
	<cfif len(#PERMIT_REMARKS#) gt 0>
	 	,PERMIT_REMARKS
	 </cfif>
	  <cfif len(#contact_agent_id#) gt 0>
	 	,contact_agent_id
	 </cfif>)
VALUES (
	#nextPermit.nextPermit#,
	 #IssuedByAgentId#
	 <cfif len(#ISSUED_DATE#) gt 0>
	 	,'#dateformat(ISSUED_DATE,"dd-mmm-yyyy")#'
	 </cfif>
	 ,#IssuedToAgentId#
	  <cfif len(#RENEWED_DATE#) gt 0>
	 	,'#dateformat(RENEWED_DATE,"dd-mmm-yyyy")#'
	 </cfif>
	 <cfif len(#EXP_DATE#) gt 0>
	 	,'#dateformat(EXP_DATE,"dd-mmm-yyyy")#'
	 </cfif>
	 <cfif len(#PERMIT_NUM#) gt 0>
	 	,'#PERMIT_NUM#'
	 </cfif>
	 ,'#PERMIT_TYPE#'
	<cfif len(#PERMIT_REMARKS#) gt 0>
	 	<cfset remarks = #replace(permit_remarks,"'","''")#>
		,'#remarks#'
	 </cfif>
	   <cfif len(#contact_agent_id#) gt 0>
	 	,#contact_agent_id#
	 </cfif>)
</cfquery>
	<cfcatch>
		<cfset sql=cfcatch.sql>
		<cfset message=cfcatch.message>
		<cfset queryError=cfcatch.queryError>
		<cf_queryError>
	</cfcatch>
</cftry>
	<cflocation url="Permit.cfm?Action=editPermit&permit_id=#nextPermit.nextPermit#">
  </cfoutput>
</cfif>
<!--------------------------------------------------------------------------------------------------->
<cfif #Action# is "deletePermit">
<cfoutput>
<cftry>
<cfquery name="deletePermit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
DELETE FROM permit WHERE permit_id = #permit_id#
</cfquery>
	<cfcatch>
		<cfset sql=cfcatch.sql>
		<cfset message=cfcatch.message>
		<cfset queryError=cfcatch.queryError>
		<cf_queryError>
	</cfcatch>
</cftry>
	<cflocation url="Permit.cfm">
  </cfoutput>
</cfif>
<cfinclude template = "includes/_footer.cfm">