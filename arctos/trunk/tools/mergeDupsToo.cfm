
<cfinclude template="/includes/_header.cfm">
<cfif not isdefined("autorun")>
	<cfset autorun="nope">
</cfif>
<cfif #action# is "nothing">
<a href="mergeDupsToo.cfm?autorun=yep">Autorun</a>
 <p>First Hundred Duplicates:
	<cfquery name="findAllDups" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			cataloged_item.collection_object_id,
			collection,
			cat_num,
			concatSingleOtherId(cataloged_item.collection_object_id,'#session.customotheridentifier#') AS CustomID,
			concatencumbrances(cataloged_item.collection_object_id) encumbrances,
			scientific_name,
			RELATED_COLL_OBJECT_ID,
			flags,
			nvl(theSheet.barcode,'noSheet') sheetBarcode,
			nvl(theFolder.barcode,'noFolder') folderBarcode
		FROM
			collection,
			cataloged_item,
			coll_object,
			identification,
			biol_indiv_relations,
			collecting_event,
			locality,
			geog_auth_rec,
			specimen_part,
			coll_obj_cont_hist,
			container thePart,
			container theSheet,
			container theFolder			
		where
			cataloged_item.collection_id = collection.collection_id and
			cataloged_item.collection_object_id = identification.collection_object_id and
			cataloged_item.collection_object_id = coll_object.collection_object_id and
			accepted_id_fg=1 and
			cataloged_item.collection_object_id = biol_indiv_relations.collection_object_id and
			BIOL_INDIV_RELATIONSHIP = 'duplicate of' and
			cataloged_item.collecting_event_id=collecting_event.collecting_event_id and
			collecting_event.locality_id=locality.locality_id and
			locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
			verbatim_date='not recorded' and
			spec_locality='No specific locality recorded.' and
			higher_geog='no higher geography recorded' and
			cataloged_item.collection_object_id=specimen_part.derived_from_cat_item and
			specimen_part.collection_object_id = coll_obj_cont_hist.collection_object_id and
			coll_obj_cont_hist.container_id=thePart.container_id (+) and
			thePart.parent_container_id = theSheet.container_id (+) and
			theSheet.parent_container_id = theFolder.container_id (+) and
			concatencumbrances(cataloged_item.collection_object_id) is null and
			RELATED_COLL_OBJECT_ID not in (select collection_object_id from 
			coll_object_encumbrance) and
			rownum < 200
	</cfquery>
	<cfoutput>
		<table border>
			<tr>
				<td>Record One</td>
				<td>Record Two</td>
				<td>&nbsp;</td>
			</tr>

		<cfloop query="findAllDups">
			<cfquery name="dupRec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
					cataloged_item.collection_object_id,
					collection,
					cat_num,
					concatSingleOtherId(cataloged_item.collection_object_id,'#session.customOtherIdentifier#') AS CustomID,
					concatencumbrances(cataloged_item.collection_object_id) encumbrances,
					scientific_name,
					flags,
			nvl(theSheet.barcode,'noSheet') sheetBarcode,
			nvl(theFolder.barcode,'noFolder') folderBarcode
				FROM
					collection,
					cataloged_item,
					coll_object,
					identification,
			collecting_event,
			locality,
			geog_auth_rec,
			specimen_part,
			coll_obj_cont_hist,
			container thePart,
			container theSheet,
			container theFolder
				where
					cataloged_item.collection_id = collection.collection_id and
					cataloged_item.collection_object_id = identification.collection_object_id and
					accepted_id_fg=1 and
					cataloged_item.collection_object_id = coll_object.collection_object_id and
					flags is null and
					cataloged_item.collecting_event_id=collecting_event.collecting_event_id and
			collecting_event.locality_id=locality.locality_id and
			locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
			verbatim_date='not recorded' and
			spec_locality='No specific locality recorded.' and
			higher_geog='no higher geography recorded' and	
			cataloged_item.collection_object_id=specimen_part.derived_from_cat_item and
			specimen_part.collection_object_id = coll_obj_cont_hist.collection_object_id and
			coll_obj_cont_hist.container_id=thePart.container_id (+) and
			thePart.parent_container_id = theSheet.container_id (+) and
			theSheet.parent_container_id = theFolder.container_id (+) and
			nvl(theSheet.barcode,'noSheet')='#sheetBarcode#' and
			nvl(theFolder.barcode,'noFolder')='#folderBarcode#' and	
			concatencumbrances(cataloged_item.collection_object_id) is null and
					cataloged_item.collection_object_id = #RELATED_COLL_OBJECT_ID#
			</cfquery>
			<tr>
				<td><a href="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">#collection# #cat_num#</a> (#session.customOtherIdentifier# #CustomID#) <em>#scientific_name#</em></td>
				<td><a href="/SpecimenDetail.cfm?collection_object_id=#dupRec.collection_object_id#">#dupRec.collection# #dupRec.cat_num#</a>
					(#session.customOtherIdentifier# #dupRec.CustomID#) 
					<em>#dupRec.scientific_name#</em>
				</td>
				<td>#sheetBarcode# - #dupRec.sheetBarcode#</td>
				<td>#folderBarcode# - #dupRec.folderBarcode#</td>
				<TD>
					<cfif len(#dupRec.collection_object_id#) gt 0>
					<a href="mergeDupsToo.cfm?action=delOne&id1=#collection_object_id#&id2=#RELATED_COLL_OBJECT_ID#">delete</a>
					<cfif #autorun# is "yep">
							<script>
								document.location = 'mergeDupsToo.cfm?autorun=yep&action=delOne&id1=#collection_object_id#&id2=#RELATED_COLL_OBJECT_ID#';
							</script>
						</cfif>
					</cfif>
						</TD>
				<td>
					<cfif len(#dupRec.collection_object_id#) gt 0 and
						len(#encumbrances#) is 0 AND len(#dupRec.encumbrances#) is 0 and len(#flags#) is 0 and len(#duprec.flags#) is 0>
						<a href="mergeDups.cfm?action=merge&id1=#collection_object_id#&id2=#RELATED_COLL_OBJECT_ID#">Merge</a>
						<cfif #autorun# is "yep">
							<script>
								document.location = 'mergeDups.cfm?autorun=yep&action=merge&id1=#collection_object_id#&id2=#RELATED_COLL_OBJECT_ID#';
							</script>
						</cfif>
					<cfelse>
						no merge
					</cfif>
				</td>
			</tr>
		</cfloop>
			</table>
	
	</cfoutput>
</cfif>
<cfif #action# is "delOne">
	<cfoutput>
	<cfquery name="upAccn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	insert into coll_object_encumbrance (ENCUMBRANCE_ID,COLLECTION_OBJECT_ID) 
	values (1000025,#id2#)	
	</cfquery>
	done
	<cfif #autorun# is "yep">
			<cflocation url="mergeDupsToo.cfm?autorun=yep">
		</cfif>		
	</cfoutput>
</cfif>
