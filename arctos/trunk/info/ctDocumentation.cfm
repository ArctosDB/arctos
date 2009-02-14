<cfoutput>
<cfif not isdefined("table")>
	<!---- probably a bot ---->
	<cfabort>
</cfif>
<cfinclude template="/includes/_frameHeader.cfm">
<cfset tableName = right(table,len(table)-2)>
<cfif not isdefined("field")>
	<cfset field="">
</cfif>
	<table>
		<tr>
			<td>
				<font size="+1">Documentation for code table <strong>#tableName#</strong>:</font>			</td>
		</tr>
	</table>
	<!--- see if we have docs yet, die if not
	<cftry>
		<cfquery name="isThere" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select description from #table#
		</cfquery>
		<cfcatch>
			An error has occured, probably because there is no documentation for the 
			field you clicked on.
			<cfabort>
		</cfcatch>
	</cftry>
	 ---->
	<cfquery name="docs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from #table#
	</cfquery>
	<!--- figure out the name of the field they want info about - already have the table name,
		passed in as a JS variable ---->
	<cfloop list="#docs.columnlist#" index="colName">
		<cfif #colName# is not "COLLECTION_CDE" and #colName# is not "DESCRIPTION">
			<cfset theColumnName = #colName#>
		</cfif>
	</cfloop>
	
	<!---- first, documentation for the field they selected ---->
	<cfquery name="chosenOne" dbtype="query">
		select * from docs where #theColumnName# = '#field#'
		<cfif #docs.columnlist# contains "collection_cde">
			order by collection_cde
		</cfif>
	</cfquery>
	
	<table border="1">
		<tr>
			<td>
				<strong>Data Value</strong>
			</td>
			<td><strong>Collection</strong></td>
			<td>
				<strong>Documentation</strong>
			</td>
		</tr>
		<cfif len(#field#) gt 0>
			<cfif #docs.columnList# contains "collection_cde">
				<cfloop query="chosenOne">
					<tr style="background-color:##339999 ">
						<td nowrap>#field#</td>
						<td>#collection_cde#</td>
						<td>
							<cfif isdefined("description")>
								#description#&nbsp;
							</cfif>
						</td>
					</tr>
				</cfloop>
			<cfelse>
					<tr style="background-color:##339999 ">
						<td nowrap>#field#</td>
						<td>All</td>
						<td>
							<cfif isdefined("chosenOne.description")>
								#chosenOne.description#&nbsp;
							</cfif>
						</td>
					</tr>					
			</cfif>
		</cfif>
	<cfquery name="theRest" dbtype="query">
		select * from docs where #theColumnName# <> '#field#'
			order by #theColumnName#
		<cfif #docs.columnlist# contains "collection_cde">
			 ,collection_cde
		</cfif>
	</cfquery>
		<cfset i=1>
		<cfif #docs.columnList# contains "collection_cde">
				<cfloop query="theRest">
					 <tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
						<td nowrap>#evaluate(theColumnName)#</td>
						<td>#collection_cde#</td>
						<td>
							<cfif isdefined("description")>
								#description#&nbsp;
							</cfif>
						</td>
					</tr>
					<cfset i=#i#+1>
				</cfloop>
			<cfelse>
					<cfloop query="theRest">
					<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
						<td nowrap>#evaluate(theColumnName)#</td>
						<td>All</td>
						<td>
							<cfif isdefined("description")>
								#description#&nbsp;
							</cfif>
						</td>
						<cfset i=#i#+1>
					</tr>
				</cfloop>	
			</cfif>
	</table>
	
</cfoutput>