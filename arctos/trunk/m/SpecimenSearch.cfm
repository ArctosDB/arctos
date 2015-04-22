<cfinclude template="includes/_header.cfm">
<script src="/includes/jquery.multiselect.min.js"></script>
<cfset title="Specimen Search">
<cfset metaDesc="Search for museum specimens and observations by taxonomy, identifications, specimen attributes, and usage history.">
<cfoutput>
	<cfquery name="getCount" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select count(collection_object_id) as cnt from cataloged_item
</cfquery>
	<cfquery name="ctmedia_type" datasource="cf_dbuser" cachedwithin="#createtimespan(0,0,60,0)#">
	select media_type from ctmedia_type order by media_type
</cfquery>
	<cfquery name="ctcataloged_item_type" datasource="cf_dbuser" cachedwithin="#createtimespan(0,0,60,0)#">
	select cataloged_item_type from ctcataloged_item_type order by cataloged_item_type
</cfquery>
	<div>
		Access to #numberformat(getCount.cnt,",")# records
	</div>
	<form method="post" action="SpecimenResults.cfm" name="SpecData" id="SpecData" onSubmit="getFormValues();">
	<input type="submit" value="Search" class="schBtn">
	<cfquery name="ctInst" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		SELECT
			collection.institution,
			collection.collection,
			collection.collection_id
		FROM
			collection,
			cf_collection
		where
			collection.collection_id=cf_collection.collection_id and
			PUBLIC_PORTAL_FG=1
		order by collection.collection
	</cfquery>
	<cfif isdefined("collection_id") and len(collection_id) gt 0>
		<cfset thisCollId = collection_id>
	<cfelse>
		<cfset thisCollId = "">
	</cfif>
	<label for="collection_id">
		Collection
	</label>
	<cfquery name="cfi" dbtype="query">
                    select institution from ctInst group by institution order by institution
                </cfquery>
	<select name="collection_id" id="collection_id" size="3" multiple="multiple">
		<cfloop query="cfi">
			<cfquery name="ic" dbtype="query">
                            select collection, collection_id FROM ctInst where institution='#cfi.institution#' order by collection
                        </cfquery>
			<optgroup label="#institution#">
				<cfloop query="ic">
					<option
					<cfif thisCollId is ic.collection_id>
						selected="selected"
					</cfif>
					value="#ic.collection_id#">#ic.collection#</option>
				</cfloop>
			</optgroup>
		</cfloop>
	</select>
	<label for="listcatnum">
		Catalog&nbsp;Number
	</label>
	<input type="text" name="listcatnum" id="listcatnum" size="50" value="">
	<label for="scientific_name">
		Taxonomy
	</label>
	<input type="text" name="taxon_name" id="taxon_name" size="50" value="" placeholder="Taxonomy">
	<label for="scientific_name">
		Place Name
	</label>
	<input type="text" name="any_geog" id="any_geog" size="50" value="" placeholder="Geography">
	<label for="coll">
		Collector
	</label>
	<input type="text" name="coll" id="collg" size="50" value="" placeholder="Collector">
</cfoutput>
<cfinclude template = "includes/_footer.cfm">
