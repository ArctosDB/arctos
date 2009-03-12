<cfinclude template = "/includes/_header.cfm">
<cfset title = "Partless Specimens">
<cfif action is "nothing">
<cfoutput>
	<h2>Find specimens with no parts</h2>
<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select collection_id,collection from collection order by collection
</cfquery>
<form method="post">
	<input type="hidden" name="action" value="show">
	<label for="collection_id">Collection</label>
	<select name="collection_id" id="collection_id">
		<option value="">All</option>
		<cfloop query="d">
			<option value="#collection_id#">#collection#</option>
		</cfloop>
	</select>
	<input type="submit" class="lnkBtn" value="Go">
</form>
</cfoutput>
</cfif>
<cfif action is "show">
<cfoutput>
<hr>The following specimens have no parts.
<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select  
		collection.collection,
		cataloged_item.cat_num
	from 
		collection, 
		cataloged_item, 
		specimen_part
	where 
		collection.collection_id = cataloged_item.collection_id and
		cataloged_item.collection_object_id=specimen_part.derived_From_cat_item (+) and
		specimen_part.derived_from_cat_item is null
		<cfif isdefined("collection_id") and collection_id gt 0>
			and collection.collection_id=#collection_id#
		</cfif>
	order by
		collection.collection,
		cat_num
</cfquery>
<cfset fileDir = "#Application.webDirectory#">
<cfset fileName = "ArctosData_#cfid#_#cftoken#.csv">
<cfset header="collection,cat_num">
<cffile action="write" file="#Application.webDirectory#/download/#fileName#" addnewline="yes" output="#header#">
<cfloop query="d">
	<cfset oneLine = "#collection#,#cat_num#">
	<cffile action="append" file="#Application.webDirectory#/download/#fileName#" addnewline="yes" output="#oneLine#">
</cfloop>
<a href="/download.cfm?file=#fileName#">Download as CSV</a>
<cfdump var=#d#>
</cfoutput>
</cfif>
<cfinclude template = "/includes/_footer.cfm">