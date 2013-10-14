<cfinclude template="/includes/_header.cfm">
<cfset title="Compare thingee">
<cfoutput>
	<cfdump var=#form#>
	
	
	<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select collection,collection_id from collection order by collection
	</cfquery>

	<cfif not isdefined('collection_id')>
		<cfset collection_id="">
	</cfif>
	
	<cfif not isdefined('parts')>
		<cfset parts="">
	</cfif>
	<form name="pc" method="post" action="db_vs_colln.cfm">
		<label for="collection">Collection</label>
		<cfset cid=collection_id>
		<select name="collection_id" id="collection_id">
			<cfloop query="ctcollection">
				<option <cfif cid is ctcollection.collection_id> selected="selected" </cfif>value="#collection_id#">#collection#</option>
			</cfloop>
		</select>
		<input type="submit" value="choose collection">
	</form>
	<cfif len(collection_id) is 0>
		pick a collection to continue<cfabort>
	</cfif>
	<cfquery name="ctspecimen_part_name" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select 
			part_name 
		from
			specimen_part,
			cataloged_item
		where
			specimen_part.derived_from_cat_item=cataloged_item.collection_object_id and
			cataloged_item.collection_id=#cid#
		 group by part_name order by 
		 	part_name
	</cfquery>
	<form name="findStuff" method="post" action="db_vs_colln.cfm">
		<input type="text" name="collection_id" value="#collection_id#">
		<label for="part_name">Part Names</label>
		<input type="hidden" name="part_name" id="part_name">
		<select name="parts" id="v" multiple="multiple" size="20">
			<cfloop query="ctspecimen_part_name">
				<option <cfif listfind(parts,part_name)> selected="selected" </cfif>value="#part_name#">#part_name#</option>
			</cfloop>
		</select>
		<br><input type="submit" value="find specimens">
	</form>
	<cfif isdefined("parts") and len(parts) gt 0>
		#parts#
	</cfif>
</cfoutput>

<cfinclude template="/includes/_footer.cfm">