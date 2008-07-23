<cfinclude template="/includes/_header.cfm">
<cfset title="Specimen Annotations">
<cfoutput>
<cfquery name="c" datasource="#Application.web_user#">
	select collection cln from collection order by collection
</cfquery>
Filter By:
<form name="filter" method="post" action='annotate.cfm'>
	<input type="hidden" name="action" value="show">
	<label for="collection">Collection</label>
	<select name="collection" size="1">
		<option value=""></option>
		<cfloop query="c">
			<option value="#cln#">#cln#</option>
		</cfloop>
	</select>
	<br>
	<input type="submit" 
		class="lnkBtn"
		onmouseover="this.className='lnkBtn btnhov'" 
		onmouseout="this.className='lnkBtn'"
		value="Filter">
	<input type="reset" 
		class="clrBtn"
		onmouseover="this.className='clrBtn btnhov'" 
		onmouseout="this.className='clrBtn'"
		value="Clear Form">
</form>
</cfoutput>
<cfif #action# is "show">
<cfoutput>
	<cfquery name="annotations" datasource="#Application.web_user#">
		select
			 specimen_annotations.ANNOTATION_ID,
			 specimen_annotations.ANNOTATE_DATE,
			 specimen_annotations.CF_USERNAME,
			 specimen_annotations.COLLECTION_OBJECT_ID,
			 specimen_annotations.SCIENTIFIC_NAME,
			 specimen_annotations.HIGHER_GEOGRAPHY,
			 specimen_annotations.SPECIFIC_LOCALITY,
			 specimen_annotations.ANNOTATION_REMARKS,
			 collection.collection,
			 cataloged_item.cat_num,
			 identification.scientific_name idAs,
			 geog_auth_rec.higher_geog,
			 locality.spec_locality,
			 cf_user_data.email
		FROM
			specimen_annotations,
			cataloged_item,
			collection,
			collecting_event,
			locality,
			geog_auth_rec,
			identification,
			cf_user_data,
			cf_users
		WHERE
			specimen_annotations.COLLECTION_OBJECT_ID = cataloged_item.COLLECTION_OBJECT_ID AND
			cataloged_item.collection_id = collection.collection_id AND
			cataloged_item.collection_object_id = identification.collection_object_id AND
			accepted_id_fg=1 AND
			cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND
			collecting_event.locality_id = locality.locality_id AND
			locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND
			specimen_annotations.CF_USERNAME=cf_users.username and
			cf_users.user_id = cf_user_data.user_id
			<cfif isdefined("collection_object_id") and len(#collection_object_id#) gt 0>
				AND specimen_annotations.collection_object_id = #collection_object_id#
			</cfif>
			<cfif isdefined("collection") and len(#collection#) gt 0>
				AND collection.collection = '#collection#'
			</cfif>
	</cfquery>
	<cfquery name="items" dbtype="query">
		select
			COLLECTION_OBJECT_ID,
			collection,
			cat_num,
			idAs,
			higher_geog,
			spec_locality
		from 
			annotations 
		group by
			COLLECTION_OBJECT_ID,
			collection,
			cat_num,
			idAs,
			higher_geog,
			spec_locality
	</cfquery>
	<table>
		<Cfset i=1>
		<cfloop query="items">
			<tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
				<td>
					<a href="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">#collection# #cat_num#</a>
					<br><em>#idAs#</em>
					<br>#higher_geog#
					<br>#spec_locality#
			<cfquery name="itemAnno" dbtype="query">
				select * from annotations where collection_object_id = #collection_object_id#
			</cfquery>
			<cfloop query="itemAnno">
				<blockquote>
					Annotation by <strong>#CF_USERNAME#</strong> (#email#) on #dateformat(ANNOTATE_DATE,"dd Mmm yyyy")#:
					<div style="font-size:.9em;padding-left:20px;">
					<cfif len(#scientific_name#) gt 0>
						<br>Scientific Name: #scientific_name#
					</cfif>
					<cfif len(#higher_geography#) gt 0>
						<br>Higher Geography: #higher_geography#
					</cfif>
					<cfif len(#specific_locality#) gt 0>
						<br>Specific Locality: #specific_locality#
					</cfif>
					<cfif len(#ANNOTATION_REMARKS#) gt 0>
						<br>Remarks: #ANNOTATION_REMARKS#
					</cfif>
					</div>
				</blockquote>
			</cfloop>
				</td>
			</tr>
			<cfset i=#i#+1>
		</cfloop>
	</table>
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">