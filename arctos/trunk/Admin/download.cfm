<cfinclude template="/includes/_header.cfm">
<cfset title="Downloads">
<cfif not isdefined("order_by")>
	<cfset order_by="username,download_date">
</cfif>
<cfif not isdefined("order_order")>
	<cfset order_order="ASC">
</cfif>
<cfoutput>
<cfquery name="dl" datasource="#Application.uam_dbo#">
	select * from cf_users, cf_user_data, cf_download
	where cf_users.user_id = cf_user_data.user_id and
	cf_users.user_id = cf_download.user_id 	
	order by #order_by# #order_order#
</cfquery>

<table border="1">
<form name="reorder" method="post" action="download.cfm">
<input type="text" name="order_by">
<input type="text" name="order_order">

<tr>
	<td>
		CF Username
		<cfset thisTerm = "username">
	<a href="javascript: void(0)" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='asc';reorder.submit();"
		onMouseOver="self.status='Sort Ascending.';#thisTerm#up.src='/images/up_mo.gif';return true;"
		onmouseout="self.status='';#thisTerm#up.src='/images/up.gif';return true;">
		<img src="/images/up.gif" border="0" name="#thisTerm#up"></a>
	<a href="javascript: void(0)" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='desc';reorder.submit();"
		onMouseOver="self.status='Sort Descending.';#thisTerm#dn.src='/images/down_mo.gif';return true;"
		onmouseout="self.status='';#thisTerm#dn.src='/images/down.gif';return true;">
		<img src="/images/down.gif" border="0" name="#thisTerm#dn"></a>
	</td>
	<td>
		First Name
		<cfset thisTerm = "first_name">
	<a href="javascript: void(0)" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='asc';reorder.submit();"
		onMouseOver="self.status='Sort Ascending.';#thisTerm#up.src='/images/up_mo.gif';return true;"
		onmouseout="self.status='';#thisTerm#up.src='/images/up.gif';return true;">
		<img src="/images/up.gif" border="0" name="#thisTerm#up"></a>
	<a href="javascript: void(0)" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='desc';reorder.submit();"
		onMouseOver="self.status='Sort Descending.';#thisTerm#dn.src='/images/down_mo.gif';return true;"
		onmouseout="self.status='';#thisTerm#dn.src='/images/down.gif';return true;">
		<img src="/images/down.gif" border="0" name="#thisTerm#dn"></a>
	</td>
	<td>
		Last Name
		<cfset thisTerm = "last_name">
	<a href="javascript: void(0)" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='asc';reorder.submit();"
		onMouseOver="self.status='Sort Ascending.';#thisTerm#up.src='/images/up_mo.gif';return true;"
		onmouseout="self.status='';#thisTerm#up.src='/images/up.gif';return true;">
		<img src="/images/up.gif" border="0" name="#thisTerm#up"></a>
	<a href="javascript: void(0)" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='desc';reorder.submit();"
		onMouseOver="self.status='Sort Descending.';#thisTerm#dn.src='/images/down_mo.gif';return true;"
		onmouseout="self.status='';#thisTerm#dn.src='/images/down.gif';return true;">
		<img src="/images/down.gif" border="0" name="#thisTerm#dn"></a>
	</td>
	<td>
		Affiliation
		<cfset thisTerm = "affiliation">
	<a href="javascript: void(0)" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='asc';reorder.submit();"
		onMouseOver="self.status='Sort Ascending.';#thisTerm#up.src='/images/up_mo.gif';return true;"
		onmouseout="self.status='';#thisTerm#up.src='/images/up.gif';return true;">
		<img src="/images/up.gif" border="0" name="#thisTerm#up"></a>
	<a href="javascript: void(0)" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='desc';reorder.submit();"
		onMouseOver="self.status='Sort Descending.';#thisTerm#dn.src='/images/down_mo.gif';return true;"
		onmouseout="self.status='';#thisTerm#dn.src='/images/down.gif';return true;">
		<img src="/images/down.gif" border="0" name="#thisTerm#dn"></a>
	</td>
	<td>
		Purpose
		<cfset thisTerm = "download_purpose">
	<a href="javascript: void(0)" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='asc';reorder.submit();"
		onMouseOver="self.status='Sort Ascending.';#thisTerm#up.src='/images/up_mo.gif';return true;"
		onmouseout="self.status='';#thisTerm#up.src='/images/up.gif';return true;">
		<img src="/images/up.gif" border="0" name="#thisTerm#up"></a>
	<a href="javascript: void(0)" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='desc';reorder.submit();"
		onMouseOver="self.status='Sort Descending.';#thisTerm#dn.src='/images/down_mo.gif';return true;"
		onmouseout="self.status='';#thisTerm#dn.src='/images/down.gif';return true;">
		<img src="/images/down.gif" border="0" name="#thisTerm#dn"></a>
		
	</td>
	<td>
		Date
		<cfset thisTerm = "download_date">
	<a href="javascript: void(0)" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='asc';reorder.submit();"
		onMouseOver="self.status='Sort Ascending.';#thisTerm#up.src='/images/up_mo.gif';return true;"
		onmouseout="self.status='';#thisTerm#up.src='/images/up.gif';return true;">
		<img src="/images/up.gif" border="0" name="#thisTerm#up"></a>
	<a href="javascript: void(0)" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='desc';reorder.submit();"
		onMouseOver="self.status='Sort Descending.';#thisTerm#dn.src='/images/down_mo.gif';return true;"
		onmouseout="self.status='';#thisTerm#dn.src='/images/down.gif';return true;">
		<img src="/images/down.gif" border="0" name="#thisTerm#dn"></a>
	</td>
	<td>
		## Records
		<cfset thisTerm = "num_records">
	<a href="javascript: void(0)" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='asc';reorder.submit();"
		onMouseOver="self.status='Sort Ascending.';#thisTerm#up.src='/images/up_mo.gif';return true;"
		onmouseout="self.status='';#thisTerm#up.src='/images/up.gif';return true;">
		<img src="/images/up.gif" border="0" name="#thisTerm#up"></a>
	<a href="javascript: void(0)" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='desc';reorder.submit();"
		onMouseOver="self.status='Sort Descending.';#thisTerm#dn.src='/images/down_mo.gif';return true;"
		onmouseout="self.status='';#thisTerm#dn.src='/images/down.gif';return true;">
		<img src="/images/down.gif" border="0" name="#thisTerm#dn"></a>
	</td>
	<td>
		Agree to Terms?
		<cfset thisTerm = "agree_to_terms">
	<a href="javascript: void(0)" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='asc';reorder.submit();"
		onMouseOver="self.status='Sort Ascending.';#thisTerm#up.src='/images/up_mo.gif';return true;"
		onmouseout="self.status='';#thisTerm#up.src='/images/up.gif';return true;">
		<img src="/images/up.gif" border="0" name="#thisTerm#up"></a>
	<a href="javascript: void(0)" 
		onClick="reorder.order_by.value='#thisTerm#';reorder.order_order.value='desc';reorder.submit();"
		onMouseOver="self.status='Sort Descending.';#thisTerm#dn.src='/images/down_mo.gif';return true;"
		onmouseout="self.status='';#thisTerm#dn.src='/images/down.gif';return true;">
		<img src="/images/down.gif" border="0" name="#thisTerm#dn"></a>
	</td>
</tr>
</form>
</cfoutput>
<cfoutput query="dl">
<tr>
	<td>#username#</td>
	<td>#first_name#</td>
	<td>#last_name#</td>
	<td>#affiliation#</td>
	<td>#download_purpose#</td>
	<td>#dateformat(download_date,"dd mmm yyyy")#</td>
	<td>#num_records#</td>
	<td>#agree_to_terms#</td>
</tr>
</cfoutput>

</table>

<cfinclude template="/includes/_footer.cfm">