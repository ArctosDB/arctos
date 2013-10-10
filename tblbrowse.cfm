<cfinclude template="/includes/_header.cfm">
	<cfif not isdefined("tbl")>
		<cfabort>
	</cfif>
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
		<cfdump var=#tcols#>
		<form name="s" method="get" action="tblbrowse.cfm">
			<input type="hidden" name="action" id="action" value="srch">
			<input type="hidden" name="tbl" id="tbl" value="#tbl#">
			<cfloop query="tcols">
				<label for="#COLUMN_NAME#">#COLUMN_NAME#</label>
				<input type="text" name="#COLUMN_NAME#" value="" id="#COLUMN_NAME#">
			
			</cfloop>
			<br>
			<input type="submit" value="search">
		</form>
	<cfif action is "srch">
		<cfdump var="#url#">
		<!--------
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from tbl where 
		</cfquery>
		-------->
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
			<table border>
				<tr>
					<cfloop query="tcols">
						<th>#COLUMN_NAME#</th>
					</cfloop>
				</tr>
				<cfloop query="d">
					<cfloop query="tcols">
						<td>#evaluate("d." & COLUMN_NAME)#</td>
					</cfloop>
				</cfloop>
			</table>
		</cfif>
	</cfif>
	</cfoutput>
<cfinclude template="/includes/_footer.cfm">
