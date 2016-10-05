<cfinclude template="/includes/_header.cfm">
<cfset title="Save Searches">
<cfif #action# is "nothing">
<cf_showMenuOnly>
"Can" the dynamic page that you are currently on to quickly return later. Results are data-based, so you may get different results the next time you visit; only your criteria are stored.

<cfoutput>
	<cfquery name="me" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
<cfquery name="i" datasource="cf_dbuser">
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


<cfif action is "manage">
<script type='text/javascript' src='/includes/_treeAjax.js'></script>
<script type="text/javascript" language="javascript">
	function killSS(canned_id) {
		var l=confirm('Are you sure you want to delete this Saved Search?');
		if(l===true){
			jQuery.getJSON("/component/functions.cfc",
				{
					method : "kill_canned_search",
					canned_id : canned_id,
					returnformat : "json",
					queryformat : 'column'
				},
				function (result) {
		  			if (IsNumeric(result)) {
						var e = "document.getElementById('tr" + result + "')";
						var el = eval(e);
						el.style.display='none';
					}else{
						alert(result);
					}
				}
			);
		} else {
			return false;
		}
	}

	function killAR(archive_name) {
		var l=confirm('Are you sure you want to delete this Archive?');
		if(l===true){
			jQuery.getJSON("/component/functions.cfc",
				{
					method : "kill_archive",
					archive_name : archive_name,
					returnformat : "json",
					queryformat : 'column'
				},
				function (result) {
		  			if (result== archive_name) {
		  				$("#ar_" + result).hide();
					}else{
						alert(result);
					}
				}
			);
		} else {
			return false;
		}
	}

</script>

<cfoutput>
	<cfquery name="hasCanned" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select SEARCH_NAME,URL,canned_id
	from cf_canned_search,cf_users
	where cf_users.user_id=cf_canned_search.user_id
	and username = '#session.username#'
	order by search_name
</cfquery>

<cfquery name="archive" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select
		archive_name.archive_id,
		archive_name,
		create_date,
		is_locked,
		count(specimen_archive.guid) c,
		doi
	from
		archive_name,
		specimen_archive,
		doi
	where
		archive_name.archive_id=specimen_archive.archive_id (+) and
		archive_name.archive_id=doi.archive_id (+) and
		upper(creator)='#ucase(session.username)#'
	group by
		archive_name.archive_id,
		archive_name,
		create_date,
		is_locked,
		doi
	order by
		archive_name
</cfquery>
<h2>
	Archives
</h2>
<cfif archive.recordcount is 0>
	<blockquote>
		You may create Archives from Specimen Results and manage them here.
	</blockquote>
<cfelse>
	<cfif session.roles contains "manage_collection">
		<div class="importantNotification">
			<strong>
				READ THIS!
				<br>You have access to LOCK Archives.
				<br>Locked Archives may not be unlocked or modified for any purpose.
				<br>Specimens in locked archives may not be encumbered or deleted. All other edits remain available.
				<br>Clicking a LOCK link below invokes a long-term curatorial committment.
				<br>Lock Archives to get a DOI.
			</strong>
		</div>
	</cfif>

	<table border>
		<tr>
			<th>Delete</th>
			<th>Archive Name</th>
			<th>DOI</th>
			<th>URL</th>
			<th>Date</th>
			<th>Locked?</th>
			<th>Specimens</th>
		</tr>
		<cfloop query="archive">
			<tr id="ar_#archive_name#">
				<td>
					<cfif is_locked is 0>
						<img src="/images/del.gif" class="likeLink" onClick="killAR('#archive_name#');" border="0">
					</cfif>
				</td>
				<td>#archive_name#</td>
				<td>
					<cfif len(doi) gt 0>
						#doi# <a href="http://dx.doi.org/#doi#">[ click ]</a>
					<cfelse>
						<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user") and is_locked is 1>
							<a href="/tools/doi.cfm?archive_id=#archive_id#">get a DOI</a>
						</cfif>
					</cfif>
				</td>
				<td>
					#application.serverRootURL#/archive/#archive_name#
					<a href="/archive/#archive_name#">[ click ]</a>
				</td>
				<td>#create_date#</td>
				<td>
					<cfif is_locked is 0>no<cfelse>yes</cfif>
					<cfif session.roles contains "manage_collection" and is_locked is 0>
						<span class="likeLink" onclick="lockArchive('#archive_name#')">[ LOCK ]</span>
					</cfif>
				</td>
				<td>#c#</td>
			</tr>
		</cfloop>
	</table>
</cfif>


<cfif hasCanned.recordcount is 0>
	You may save searches  from Specimen Results and manage them here.
<cfelse>
<h2>Saved Searches</h2>

<div style="border:3px solid red;margin-left:15%;margin-right:15%;padding:1em;">
	CAUTION: Copying and pasting saved searches which end with non-alphanumeric characters (such as punctuation) may produce
	unexpected results. Use the "email" function to ensure proper encoding, or re-save the search using URL-safe characters.
</div>

<table border>
	<tr>
		<td>&nbsp;</td>
		<td><strong>Name</strong></td>
		<td><strong>URL</strong></td>
		<td><strong>Email</strong></td>
	</tr>
<cfloop query="hasCanned">
	<tr id="tr#canned_id#">
		<td><img src="/images/del.gif" class="likeLink" onClick="killSS('#canned_id#');" border="0"></td>
		<td>#search_name#</td>
		<td>
			<a href="/saved/#URLEncodedFormat(search_name)#">#Application.ServerRootUrl#/saved/#URLEncodedFormat(search_name)#</a>
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