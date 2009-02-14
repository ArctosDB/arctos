<cfinclude template="/includes/_pickHeader.cfm">
<cf_security access_level="student0">

<cfquery name="getCols" datasource="uam_god">
	select column_name from sys.user_tab_cols
	where table_name='BULKLOADER'
	order by internal_column_id
</cfquery>
<cfif not isdefined("order_by") or len(#order_by#) is 0>
	<cfset order_by = "collection_object_id">
</cfif>
<cfif not isdefined("order_order") or len(#order_order#) is 0>
	<cfset order_order = "ASC">
</cfif>
<cfoutput>
<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from bulkloader
	where enteredby = '#session.username#'
	ORDER BY #order_by# #order_order#
</cfquery>

<cfset rowNum = 1>
<table border cellpadding="0" cellspacing="0">
	<tr>
	
		<cfloop query="getCols">
			<td><span style="font-size:10px">
				<cfif #column_name# is "collection_object_id">ID<cfelse>#column_name#
			<a href="userBrowseBulked.cfm?order_by=#column_name#&order_order=asc">
				<img src="/images/up.gif" border="0"></a>
			<a href="userBrowseBulked.cfm?order_by=#column_name#&order_order=desc">
				<img src="/images/down.gif" border="0"></a>
				</cfif>
				</span>
			</td>
		</cfloop>
	</tr>
	
		
		
	<cfloop query="data">
		<cfset thisCollObjId = #collection_object_id#>
		<cfquery name="thisRec" dbtype="query">
			select * from data where collection_object_id=#collection_object_id#
		</cfquery>
		<tr <cfif len(#thisRec.loaded#) is 0> bgcolor="##00FF00"</cfif> >
			<cfloop query="getCols">
				<cfset thisData = evaluate("thisRec." & column_name)>
				<td nowrap="nowrap">
					<cfif #column_name# is "collection_object_id">
						<a href="/DataEntryStage.cfm?action=editEnterData&collection_object_id=#thisData#">#thisData#&nbsp;</a>
					<cfelse>
						#thisData#&nbsp;
					</cfif>
				</td>
			</cfloop>
		</tr>
	</cfloop>
	</table>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">