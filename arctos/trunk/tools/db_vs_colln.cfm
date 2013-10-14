<cfinclude template="/includes/_header.cfm">
<cfset title="Compare thingee">
<cfoutput>

	<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select collection,collection_id from collection order by collection
	</cfquery>

	<cfif not isdefined('collection_id')>
		<cfset cid="">
	<cfelse>
		<cfset cid=collection_id>
	</cfif>
	<form name="pc" method="post" action="db_vs_colln.cfm">
		<label for="collection">Collection</label>
		<select name="collection_id" id="collection_id">
			<cfloop query="ctcollection">
				<option <cfif cid is ctcollection.collection_id> selected="selected" </cfif>value="#collection_id#">#collection#</option>
			</cfloop>
		</select>
		<input type="submit" value="choose collection">
	</form>
	<cfif len(cid) is 0>
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
		 order by 
		 	part_name
	</cfquery>
	<form name="findStuff" method="post" action="db_vs_colln.cfm">
		<input type="hidden" name="cid" value="#cid#">
		<label for="part_name">Part Names</label>
		<input type="hidden" name="part_name" id="part_name">
		<select name="part_name" id="part_name" multiple="multiple" size="20">
			<cfloop query="ctspecimen_part_name">
				<option value="#part_name#">#part_name#</option>
			</cfloop>
		</select>
		<br><input type="submit" value="find specimens">
	</form>
	<cfif len(part_name) gt 0>
		#part_name#
	</cfif>
</cfoutput>

<cfinclude template="/includes/_footer.cfm">