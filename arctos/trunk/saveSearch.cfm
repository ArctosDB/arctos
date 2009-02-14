<cfinclude template="/includes/_header.cfm">
<cfset title="Save Searches">
<cfif #action# is "nothing">
<cf_showMenuOnly>
"Can" the dynamic page that you are currently on to quickly return later. Results are data-based, so you may get different results the next time you visit; only your criteria are stored.

<cfoutput>
	<cfquery name="me" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select user_id from cf_users where username='#session.username#'
	</cfquery>
	<cfif len(#me.user_id#) is 0>
		<p>	
			You must <a href="/login.cfm">log in</a> to use this feature.
		</p>
		<cfabort>
	</cfif>
	<form name="canMe" method="post" action="saveSearch.cfm">
		<input type="hidden" name="action" value="saveThis">
		<input type="hidden" name="user_id" value="#me.user_id#">
		<input type="hidden" name="returnURL" value="#returnURL#">
		<label for="srchName">Name this Search</label>
		<input type="text" name="srchName" id="srchName" value="" class="reqdClr">
		<input type="submit" value="Can It!" class="savBtn"
   					onmouseover="this.className='savBtn btnhov'" onmouseout="this.className='savBtn'">
		<input type="button" value="Nevermind...." class="qutBtn" onClick="self.close();"
   					onmouseover="this.className='qutBtn btnhov'" onmouseout="this.className='qutBtn'">	
	</form>
	<script>
		document.getElementById('srchName').focus();
	</script>
	<p>
	<a href="saveSearch.cfm?action=manage">[ Manage ]</a>
	
</cfoutput>
</cfif>
<cfif #action# is "saveThis">
<cfquery name="i" datasource="#Application.uam_dbo#">
	insert into cf_canned_search (
	user_id,
	search_name,
	url
	) values (
	 #user_id#,
	 '#srchName#',
	 '#returnURL#')
</cfquery>
<script>self.close();</script>
</cfif>


<cfif #action# is "manage">
<script type='text/javascript' src='/includes/_treeAjax.js'></script>
<script>
	function killMe(canned_id) {
		//alert(canned_id);
		DWREngine._execute(_cfscriptLocation, null,'kill_canned_search',canned_id,killMe_success);

	}
	function killMe_success (result) {
		//alert(result);
		if (is_number(result)) {
			var e = "document.getElementById('tr" + result + "')";
			var el = eval(e);
			el.style.display='none';
			//alert('spiffy');
		}else{
			alert(result);
			}
		}
</script>

<cfoutput>
	<cfquery name="hasCanned" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select SEARCH_NAME,URL,canned_id
	from cf_canned_search,cf_users
	where cf_users.user_id=cf_canned_search.user_id
	and username = '#session.username#'
	order by search_name
</cfquery>
<cfif hasCanned.recordcount is 0>
	You may save searches from Specimen Results for later reference.
<cfelse>

<table border>
	<tr>
		<td>&nbsp;</td>
		<td><strong>Name</strong></td>
		<td><strong>URL</strong></td>
		<td><strong>Email</strong></td>
	</tr>
<cfloop query="hasCanned">
	<tr id="tr#canned_id#">
		<td><img src="/images/del.gif" class="likeLink" onClick="killMe('#canned_id#');" border="0"></td>
		<td>#search_name#</td>
		<td>
			<a href="/go.cfm?id=#canned_id#">#Application.ServerRootUrl#/go.cfm?id=#canned_id#</a>
		</td>
		<td>
			<span class="likeLink" onclick="window.open('/tools/mailSaveSearch.cfm?canned_id=#canned_id#','_mail','height=300,width=400,resizable,scrollbars')">Mail</span>
		</td>
	</tr>
</cfloop>
</table>
</cfif>
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">