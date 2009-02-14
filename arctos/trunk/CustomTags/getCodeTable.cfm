<cfinclude template="/includes/alwaysInclude.cfm">
<cfset table = attributes.table>
<cfset hasCollCde = 0>
<cfset hasDescription = 0>
<cfif not isdefined ("attributes.format")>
	<cfset format = "table">
<cfelse>
	<cfset format = attributes.format>
</cfif>
<cfoutput>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from #table#
	</cfquery>
	<cfset colList = ucase(d.columnlist)>
	<cfif listfind(colList,"COLLECTION_CDE")>
		<cfset hasCollCde = 1>
		<cfset colList=replace(colList,"COLLECTION_CDE","","ALL")>
	</cfif>
	<cfif listfind(colList,"DESCRIPTION")>
		<cfset hasDescription = 1>
		<cfset colList=replace(colList,"DESCRIPTION","","ALL")>
	</cfif>
	<cfset colList=replace(colList,",","","ALL")>
	<cfquery name="tabData" dbtype="query">
		select * from d order by 
		<cfif #hasCollCde# is 1>
			collection_cde,
		</cfif>
		#colList#
	</cfquery>
	<cfset dVal = REReplace(LCase(colList), "(^[[:alpha:]]|[[:blank:]][[:alpha:]])", "\U\1\E", "ALL")>
	<cfif #format# is "table">
		<table border="1">
			<tr>
				<cfif #hasCollCde# is 1>
					<th>Collection</th>
				</cfif>
				<th>#dVal#</th>
				<cfif #hasDescription# is 1>
					<th>Description</th>
				</cfif>
			</tr>
			<cfloop query="tabData">
				<cfset thisVal = evaluate(#colList#)>
				<tr>
					<cfif #hasCollCde# is 1>
						<td>#collection_cde#</td>
					</cfif>
					<td>
						
						#thisVal#
					</td>
					<cfif #hasDescription# is 1>
						<td>#description#</td>
					</cfif>
					
				</tr>
			</cfloop>
		</table>
	</cfif>
	<cfif #format# is "list">
		<ul>
			<cfloop query="tabData">
				<cfset thisVal = evaluate(#colList#)>
				<li>
					<cfif #hasCollCde# is 1>
						#collection_cde#:&nbsp;
					</cfif>					
					#thisVal#
					<cfif #hasDescription# is 1 and len(#description#) gt 0>
						<br>
						<span style="font-size:smaller;font-style:italic;padding-left:20px;">
							#description#
						</span>						
					</cfif>
				</li>
			</cfloop>
		</ul>
	</cfif>
</cfoutput>