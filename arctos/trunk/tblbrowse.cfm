<cfinclude template="/includes/_header.cfm">
	<cfif not isdefined("tbl")>
		<cfabort>
	</cfif>
	<cfoutput>
		<cfquery name="tcols" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select 
			COLUMN_NAME
			from
			user_tab_cols
			where
			TABLE_NAME='ucase(#tbl#)'
			order by
			INTERNAL_COLUMN_ID
		</cfquery>
		<form name="s" method="get" action="tbrowse.cfm">
			<input type="hidden" name="action" id="action" value="srch">
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
		
		
	</cfif>
	</cfoutput>
<cfinclude template="/includes/_footer.cfm">
