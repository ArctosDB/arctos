<cfinclude template="/includes/_header.cfm">
<cfif #action# is "nothing">
	<cfoutput>
		<cfquery name="specs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				cataloged_item.collection_object_id,
				cat_num,
				institution_acronym,
				collection.collection_cde,
				cat_num,
				scientific_name,
				encumbrance,
				encumbrance_action,
				made_encumbrance_name.agent_name as encumberer,
				encumbrance.made_date as encumbered_date,
				expiration_date,
				expiration_event,
				remarks
				from 
					cataloged_item
					inner join collection on (cataloged_item.collection_id = collection.collection_id) 
					inner join identification on (cataloged_item.collection_object_id = identification.collection_object_id) 
					inner join coll_object_encumbrance on 
						(cataloged_item.collection_object_id = coll_object_encumbrance.collection_object_id) 
					inner join encumbrance on (coll_object_encumbrance.encumbrance_id = encumbrance.encumbrance_id)
					inner join preferred_agent_name  made_encumbrance_name on 
						(encumbrance.encumbering_agent_id = made_encumbrance_name.agent_id)
				where
					identification.accepted_id_fg=1
					and encumbrance.encumbrance_id=#encumbrance_id#
				
		</cfquery>
		<table border>
			<tr>
				<td>Cataloged Item</td>
				<td>Scientific Name</td>
				<td>Encumbrance</td>
			</tr>
			<cfloop query="specs">
				<tr>
					<td>
						<a href="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">
							#institution_acronym# #collection_cde# #cat_num#</a>
					</td>
					<td>#scientific_name#</td>
					<td>#encumbrance# (#encumbrance_action#) by #encumberer# made #dateformat(encumbered_date,"dd mmm yyyy")#, expires #dateformat(expiration_date,"dd mmm yyyy")# #expiration_event# #remarks#</td>
				</tr>
			</cfloop>
		</table>
		<p style="color:##FF0000">
			You are permanently deleting records from the database.
			<br />
			You are not removing encumbrances.
			<br />
			You can really mess up here!
			<br />Forever and forever.
			<br />You have been warned.
			<br />
			If you are really sure about this, push the button.
			<br />Otherwise, <a href="/SpecimenSearch.cfm">go somewhere safe</a>
		</p>
		<input type="button" value="Delete All These Records" onclick="document.location='deleteSpecByEncumbrance.cfm?action=goAway&encumbrance_id=#encumbrance_id#'" />
	</cfoutput>
	<cfinclude template="/includes/_footer.cfm">
</cfif>
<cfif #action# is "goAway">
<cfoutput>
	<cfquery name="CatCllobjIds" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			collection_object_id
		from 
			coll_object_encumbrance
		where
			encumbrance_id=#encumbrance_id#
	</cfquery>
	<cfquery name="PartCollobjIds" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			specimen_part.collection_object_id
		from 
			coll_object_encumbrance,
			specimen_part
		where
			coll_object_encumbrance.collection_object_id = specimen_part.derived_from_cat_item AND
			encumbrance_id=#encumbrance_id#
	</cfquery>
	<cfset catIdList = valuelist(CatCllobjIds.collection_object_id)>		
	<cfset partIdList = valuelist(PartCollobjIds.collection_object_id)>		
<cftransaction>
<cfquery name="coll_obj_other_id_num" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	delete from coll_obj_other_id_num where collection_object_id IN 
		(
			select collection_object_id FROM coll_object_encumbrance WHERE
			encumbrance_id = #encumbrance_id#
		)
</cfquery>
<cfquery name="attributes" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	delete from attributes where collection_object_id IN 
		(
			select collection_object_id FROM coll_object_encumbrance WHERE
			encumbrance_id = #encumbrance_id#
		)
</cfquery>
<cfquery name="collector" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	delete from collector where collection_object_id IN 
		(
			select collection_object_id FROM coll_object_encumbrance WHERE
			encumbrance_id = #encumbrance_id#
		)
</cfquery>
<cfquery name="spcol" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">	
	delete from specimen_part where derived_from_cat_item IN 
		(
			select collection_object_id FROM 
			coll_object_encumbrance WHERE
			encumbrance_id = #encumbrance_id#
		)
</cfquery>
<cfquery name="spcoll_object" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">	
	delete from coll_object where collection_object_id IN 
		(#partIdList#)
</cfquery>
<cfquery name="identification_taxonomy" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	delete from identification_taxonomy where identification_id IN 
		(
			select identification_id FROM identification where collection_object_id IN 
			(
				select collection_object_id FROM coll_object_encumbrance WHERE
				encumbrance_id = #encumbrance_id#
			)
		)
</cfquery>
<cfquery name="identification_agent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	delete from identification_agent where identification_id IN 
		(
			select identification_id FROM identification where collection_object_id IN 
			(
				select collection_object_id FROM coll_object_encumbrance WHERE
				encumbrance_id = #encumbrance_id#
			)
		)
</cfquery>
<cfquery name="identification" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">	
	delete from identification where collection_object_id IN 
		(
			select collection_object_id FROM coll_object_encumbrance WHERE
			encumbrance_id = #encumbrance_id#
		)
</cfquery>
<cfquery name="coll_object_remark" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">	
	delete from coll_object_remark where collection_object_id IN 
		(
			select collection_object_id FROM coll_object_encumbrance WHERE
			encumbrance_id = #encumbrance_id#
		)
</cfquery>
<cfquery name="relations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">	
	delete from BIOL_INDIV_RELATIONS where collection_object_id IN 
		(
			select collection_object_id FROM coll_object_encumbrance WHERE
			encumbrance_id = #encumbrance_id#
		)
</cfquery>
<cfquery name="relations_related" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">	
	delete from BIOL_INDIV_RELATIONS where RELATED_COLL_OBJECT_ID IN 
		(
			select collection_object_id FROM coll_object_encumbrance WHERE
			encumbrance_id = #encumbrance_id#
		)
</cfquery>
<cfquery name="cataloged_item" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">	
	delete from cataloged_item where collection_object_id IN 
		(
			select collection_object_id FROM coll_object_encumbrance WHERE
			encumbrance_id = #encumbrance_id#
		)
</cfquery>

<cfquery name="coll_object_encumbrance" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">	
	delete from coll_object_encumbrance where collection_object_id IN 
		(#catIdList#)
</cfquery>

<cfquery name="coll_object" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">	
	delete from coll_object where collection_object_id IN 
		(#catIdList#)
</cfquery>

</cftransaction>
spiffy

</cfoutput>



</cfif>	
	