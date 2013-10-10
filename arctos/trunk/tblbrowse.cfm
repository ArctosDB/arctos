<cfinclude template="/includes/_header.cfm">
	<cfif not isdefined("tbl")>
		var tbl notfound
		<cfabort>
	</cfif>
	<cfset title="table browser thingee">
	<script src="/includes/sorttable.js"></script>

	<cfoutput>
		<cfquery name="tcols" datasource="uam_god">
			select 
			COLUMN_NAME
			from
			user_tab_cols
			where
			TABLE_NAME='#ucase(tbl)#'
			and HIDDEN_COLUMN='NO'
			order by
			INTERNAL_COLUMN_ID
		</cfquery>
		<form name="s" method="get" action="tblbrowse.cfm">
			<input type="hidden" name="action" id="action" value="srch">
			<input type="hidden" name="tbl" id="tbl" value="#tbl#">
			<cfloop query="tcols">
				<cfif structkeyexists(url,"#COLUMN_NAME#")>
					<cfset v=structfind(url,"#COLUMN_NAME#")>
				<cfelse>
					<cfset v="">
				</cfif>
				<label for="#COLUMN_NAME#">#COLUMN_NAME#</label>
				<input type="text" name="#COLUMN_NAME#" value="#v#" id="#COLUMN_NAME#">
			</cfloop>
			<br>
			<input type="submit" value="search">
		</form>
	<cfif action is "srch">
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from #tbl# where 1=1
			<cfloop collection="#url#" item="key">
				<cfif key is not "tbl" and key is not "action" and len(url[key]) gt 0>
					and upper(#key#) like '%#ucase(url[key])#%'
				</cfif>
			</cfloop>
			and rownum<1001
		</cfquery>
		<cfif d.recordcount gt 0>
			max 1k rows
			<table border id="t" class="sortable">
				<tr>
					<cfloop query="tcols">
						<th>#COLUMN_NAME#</th>
					</cfloop>
				</tr>
				<cfloop query="d">
					<tr>
						<cfloop query="tcols">
							<td>#evaluate("d." & COLUMN_NAME)#</td>
						</cfloop>
					</tr>
				</cfloop>
			</table>
		<cfelse>
			notfound
		</cfif>
	</cfif>
	</cfoutput>
<cfinclude template="/includes/_footer.cfm">