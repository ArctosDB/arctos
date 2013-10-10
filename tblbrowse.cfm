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
		<cfloop collection="#url#" item="key">
		    <br>#key#: #StructFind(url, key)#<
		</cfloop>		
	</cfif>
	</cfoutput>
<cfinclude template="/includes/_footer.cfm">
