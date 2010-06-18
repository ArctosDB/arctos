<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfparam name="old_path" default="">
<cfparam name="new_path" default="">
<cfoutput>
	<div>
	<div class="borderBox">
	Find redirects
	<form name="srch" method="post" action="redirect.cfm">
		<input type="hidden" name="action" id="action" value="search">
		<label for="old_path">old_path</label>
		<input type="text" name="old_path" id="old_path" value="#old_path#" size="60">
		<label for="new_path">new_path</label>
		<input type="text" name="new_path" id="new_path" value="#new_path#" size="60">
		<br>
		<input type="submit" value="Filter" class="lnkBtn">
	</form>
	</div>
	</div>
	<div>
	<div class="borderBox newRec">
	Create Redirect
	<form name="new" method="post" action="redirect.cfm">
		<input type="hidden" name="action" id="action" value="new">
		<label for="old">old (enter everything after the domain name, including a leading slash)</label>
		<input type="text" name="old" id="old" size="60">
		<label for="new">new (enter everything after the domain name, including a leading slash)</label>
		<input type="text" name="new" id="new" size="60">
		<br>
		<input type="submit" value="Create" class="lnkBtn">
	</form>
	</div>
	</div>
</cfoutput>
<cfif action is "new">
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			insert into redirect (old_path,new_path) values ('#old#','#new#')
		</cfquery>
		<cflocation url="redirect.cfm?old_path=#old#&new_path=#new#&action=search">
	</cfoutput>
</cfif>
<cfif action is "search">
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				*
			from 
				redirect
			where
				1=1
				<cfif len(old_path) gt 0>
					AND upper(old_path) like '%#ucase(old_path)#%'
				</cfif>
				<cfif len(new_path) gt 0>
					AND upper(new_path) like '%#ucase(new_path)#%'
				</cfif>
			ORDER BY 
				old_path,
				new_path
		</cfquery>
		<table border id="t" class="sortable">
		<tr>
			<th>old_path</th>
			<th>new_path</th>
		</tr>
		<cfloop query="d">
			<tr>
				<td><a href="#old_path#">#old_path#</a></td>
				<td><a href="#new_path#">#new_path#</a></td>
			</tr>
		</cfloop>
	</table>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">