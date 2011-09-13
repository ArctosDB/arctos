<cfoutput>
<cfinclude template="/includes/_header.cfm">
<cfset title="code table documentation">
<script src="/includes/sorttable.js"></script>
<cfparam name="coln" default="">

<cfif not isdefined("table")>
	<cfquery name="getCTName" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select 
			distinct(table_name) table_name 
		from 
			sys.user_tables 
		where 
			table_name like 'CT%'
		UNION 
			select 'CTGEOLOGY_ATTRIBUTE' table_name from dual
		 order by table_name
	</cfquery>
	<b>Code Table Documentation</b>
	<cfloop query="getCTName">
		<br><a href="ctDocumentation.cfm?table=#table_name#">#table_name#</a>
	</cfloop>
</cfif>
<cfif isdefined("table")>
<cfset tableName = right(table,len(table)-2)>
<cfif not isdefined("field") or field is "undefined">
	<cfset field="">
</cfif>
<cfset title="#table# - code table documentation">
Documentation for code table <strong>#tableName#</strong> ~ <a href="ctDocumentation.cfm">[ table list ]</a>
	<cfquery name="docs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select * from #table# <cfif len(coln) gt 0> where collection_cde='#coln#'</cfif>
	</cfquery>
	<cfif docs.columnlist contains "collection_cde">
			<cfquery name="ccde" datasource="cf_dbuser" cachedwithin="#createtimespan(0,0,60,0)#">
				select collection_cde from ctcollection_cde order by collection_cde
			</cfquery>
		<form name="f" method="get" action="ctDocumentation.cfm">
			<input type="hidden" name="table" value="#table#">
			<select name="coln">
				<option value="">All</option>
				<cfloop query="ccde">
					<option <cfif coln is collection_cde>selected="selected"</cfif> value="#collection_cde#">#collection_cde#</option>
				</cfloop>
			</select>
		</form>
	</cfif>
	<cfif table is "ctmedia_license">
		<table border id="t" class="sortable">
			<tr>
				<th>
					<strong>License</strong>
				</th>
				<th><strong>Description</strong></th>
				<th>
					<strong>URI</strong>
				</th>
			</tr>
			<cfloop query="docs">
				<tr>
					<td>#display#</td>
					<td>#description#</td>
					<td><a href="#uri#" target="_blank" class="external">#uri#</a></td>
				</tr>
			</cfloop>
		</table>
	<cfelseif table is "ctcollection_cde">
		<cfset i=1>
		<table border id="t" class="sortable">
			<tr>
				<th>
					<strong>Collection_Cde</strong>
				</th>
			</tr>
			<cfloop query="docs">
				<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
					<td nowrap>#collection_cde#</td>
				</tr>
				<cfset i=i+1>
			</cfloop>
		</table>
	<cfelse>
		
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
			<cfif docs.columnlist contains "collection_cde">
				order by collection_cde
			</cfif>
		</cfquery>
		
		<table border id="t" class="sortable">
			<tr>
				<th>
					<strong>Data Value</strong>
				</th>
				<th><strong>Collection</strong></th>
				<th>
					<strong>Documentation</strong>
				</th>
			</tr>
			<cfif len(field) gt 0>
				<cfif docs.columnList contains "collection_cde">
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
			<cfif docs.columnList contains "collection_cde">
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
	</cfif>
</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">