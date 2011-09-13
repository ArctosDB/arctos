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
			<label for="coln">Show only collection type</label>
			<select name="coln">
				<option value="">All</option>
				<cfloop query="ccde">
					<option <cfif coln is collection_cde>selected="selected"</cfif> value="#collection_cde#">#collection_cde#</option>
				</cfloop>
			</select>
			<input type="submit" value="filter">
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
		<cfloop list="#docs.columnlist#" index="colName">
			<cfif colName is not "COLLECTION_CDE" and colName is not "DESCRIPTION">
				<cfset theColumnName = colName>
			</cfif>
		</cfloop>
		<cfquery name="theRest" dbtype="query">
			select * from docs order by #theColumnName#
			<cfif docs.columnlist contains "collection_cde">
				 ,collection_cde
			</cfif>
		</cfquery>
		<table border id="t" class="sortable">
			<tr>
				<th>
					<strong>#theColumnName#</strong>
				</th>
				<cfif docs.columnlist contains "collection_cde">
					<th><strong>Collection</strong></th>
				</cfif>
				<cfif docs.columnlist contains "description">
					<th><strong>Documentation</strong></th>
				</cfif>
			</tr>
			<cfset i=1>
			<cfloop query="theRest">
				<cfset thisVal=trim(evaluate(theColumnName))>
				<cfif field is thisVal>
					-----------#field# is #thisVal#---------
					<tr style="border:2px solid red;color:red;">
				<cfelse>
				-----------=#field#= is NOT =#thisVal#=---------
					<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
				</cfif>
				<td>#thisVal#</td>
				<cfif docs.columnlist contains "collection_cde">
					<td>#collection_cde#</td>
				</cfif>
				<cfif docs.columnlist contains "description">
					<td>#description#</td>
				</cfif>
				</tr>
			</cfloop>
		</table>
	</cfif>
</cfif>		
</cfoutput>
<cfinclude template="/includes/_footer.cfm">