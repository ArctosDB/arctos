<cfinclude template="/includes/_header.cfm">
<cfset title="Compare thingee">
<cfoutput>
	<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select collection,collection_id from collection order by collection
	</cfquery>

	<cfif not isdefined('collection_id')>
		<cfset collection_id="">
	</cfif>
	
	<cfif not isdefined('parts')>
		<cfset parts="">
	</cfif>
	<cfif not isdefined('exclCatNum')>
		<cfset exclCatNum="">
	</cfif>
	<cfif not isdefined('idname')>
		<cfset idname="">
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
			part_name,
			count(*) c
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
		<label for="part_name">Part Names (collection count in parens)</label>
		<select name="parts" id="v" multiple="multiple" size="20">
			<cfloop query="ctspecimen_part_name">
				<option <cfif listfind(parts,part_name)> selected="selected" </cfif>value="#part_name#">#part_name# (#c#)</option>
			</cfloop>
		</select>
		<label for="idname">Scientific Name</label>
		<input type="text" value="#idname#" name="idname" id="idname">
		<label for="exclCatNum">Exclude cat nums (comma list)</label>
		<textarea name="exclCatNum" id="exclCatNum" rows="10" cols="50">#exclCatNum#</textarea>
		<br><input type="submit" value="find specimens">
	</form>
	<cfif isdefined("parts") and len(parts) gt 0>
		<cfquery name="specs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				guid_prefix || ':' || cat_num guid,
				scientific_name,
				part_name,
				COLL_OBJ_DISPOSITION
			from
				collection,
				cataloged_item,
				identification,
				specimen_part,
				coll_object
			where
				collection.collection_id=cataloged_item.collection_id and
				cataloged_item.collection_object_id=specimen_part.derived_from_cat_item and
				cataloged_item.collection_object_id=identification.collection_object_id and
				identification.accepted_id_fg=1 and
				specimen_part.collection_object_id=coll_object.collection_object_id and
				collection.collection_id=#collection_id# and
				part_name in (#listqualify(parts,chr(39))#)
			<cfif len(exclCatNum) gt 0>
				and cat_num not in (#listqualify(exclCatNum,chr(39))#)
			</cfif>
			<cfif len(idname) gt 0>
				and upper(scientific_name) like '%#ucase(idname)#%'
			</cfif>
		</cfquery>
		<cfquery name="s" dbtype="query">
			select guid,scientific_name from specs group by guid,scientific_name order by guid
		</cfquery>
		<cfif s.recordcount lt 1000>
			<a href="/SpecimenResults.cfm?guid=#valuelist(s.guid)#" target="_blank">specresults</a>
		<cfelse>
			link only available for <1k records
		</cfif>
		<table border>
			<tr>
				<th>GUID</th>
				<th>ID</th>
				<th>Parts</th>
			</tr>
			<cfloop query="s">
				<cfquery name="p" dbtype="query">
					select part_name,COLL_OBJ_DISPOSITION from specs where guid='#guid#'
				</cfquery>
				<tr>
					<td><a href="/guid/#guid#" target="_blank">#guid#</a></td>
					<td>#scientific_name#</td>
					<td>
						<cfloop query="p">
							<div>
								#part_name# (#COLL_OBJ_DISPOSITION#)
							</div>
						</cfloop>
					</td>
				</tr>
			</cfloop>
		</table>
	</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">