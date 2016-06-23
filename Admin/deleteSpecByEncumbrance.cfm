<cfinclude template="/includes/_header.cfm">
<cfif action is "getSQL">
<cfoutput>
delete from annotations where collection_object_id IN
		(
			select collection_object_id FROM coll_object_encumbrance WHERE
			encumbrance_id = #encumbrance_id#
		)
;
delete from specimen_archive where collection_object_id IN
		(
			select collection_object_id FROM coll_object_encumbrance WHERE
			encumbrance_id = #encumbrance_id#
		)
;

delete from coll_obj_other_id_num where collection_object_id IN
		(
			select collection_object_id FROM coll_object_encumbrance WHERE
			encumbrance_id = #encumbrance_id#
		)
;

delete from attributes where collection_object_id IN
		(
			select collection_object_id FROM coll_object_encumbrance WHERE
			encumbrance_id = #encumbrance_id#
		)
;

delete from collector where collection_object_id IN
		(
			select collection_object_id FROM coll_object_encumbrance WHERE
			encumbrance_id = #encumbrance_id#
		)
;

delete from specimen_part_attribute where COLLECTION_OBJECT_ID IN
		(
			select
				specimen_part.COLLECTION_OBJECT_ID
			FROM
				coll_object_encumbrance,
				specimen_part
			WHERE
				coll_object_encumbrance.collection_object_id=specimen_part.derived_from_cat_item and
				encumbrance_id = #encumbrance_id#
		)
;

delete from specimen_part where derived_from_cat_item IN
		(
			select collection_object_id FROM
			coll_object_encumbrance WHERE
			encumbrance_id = #encumbrance_id#
		)
;

delete from identification_taxonomy where identification_id IN
		(
			select identification_id FROM identification where collection_object_id IN
			(
				select collection_object_id FROM coll_object_encumbrance WHERE
				encumbrance_id = #encumbrance_id#
			)
		)
;

delete from identification_agent where identification_id IN
		(
			select identification_id FROM identification where collection_object_id IN
			(
				select collection_object_id FROM coll_object_encumbrance WHERE
				encumbrance_id = #encumbrance_id#
			)
		)
;


delete from identification where collection_object_id IN
		(
			select collection_object_id FROM coll_object_encumbrance WHERE
			encumbrance_id = #encumbrance_id#
		)
;

delete from coll_object_remark where collection_object_id IN
		(
			select collection_object_id FROM coll_object_encumbrance WHERE
			encumbrance_id = #encumbrance_id#
		)
;


delete from media_relations where media_relationship like '% cataloged_item' and related_primary_key IN
		(
			select collection_object_id FROM coll_object_encumbrance WHERE
			encumbrance_id = #encumbrance_id#
		)
;


delete from specimen_event where collection_object_id IN
		(
			select collection_object_id FROM coll_object_encumbrance WHERE
			encumbrance_id = #encumbrance_id#
		)
;
delete from cataloged_item where collection_object_id IN
		(
			select collection_object_id FROM coll_object_encumbrance WHERE
			encumbrance_id = #encumbrance_id#
		)
;

create table temp as select collection_object_id from coll_object_encumbrance where encumbrance_id = #encumbrance_id#;


delete from coll_object_encumbrance where collection_object_id IN (select collection_object_id from temp);

delete from coll_object where collection_object_id IN (select collection_object_id from temp);


drop table temp;

</cfoutput>

</cfif>
<cfif #action# is "nothing">
	<cfoutput>
		<cfquery name="specs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				cataloged_item.collection_object_id,
				cat_num,
				collection.guid_prefix collection,
				cat_num,
				scientific_name,
				encumbrance,
				encumbrance_action,
				getPreferredAgentName(encumbrance.encumbering_agent_id) encumberer,
				encumbrance.made_date as encumbered_date,
				expiration_date,
				remarks
				from
					cataloged_item
					inner join collection on (cataloged_item.collection_id = collection.collection_id)
					inner join identification on (cataloged_item.collection_object_id = identification.collection_object_id)
					inner join coll_object_encumbrance on
						(cataloged_item.collection_object_id = coll_object_encumbrance.collection_object_id)
					inner join encumbrance on (coll_object_encumbrance.encumbrance_id = encumbrance.encumbrance_id)
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
							#collection# #cat_num#</a>
					</td>
					<td>#scientific_name#</td>
					<td>#encumbrance# (#encumbrance_action#) by #encumberer# made #dateformat(encumbered_date,"yyyy-mm-dd")#, expires #dateformat(expiration_date,"yyyy-mm-dd")# #remarks#</td>
				</tr>
			</cfloop>
		</table>
		<p style="color:##FF0000">
			You are permanently deleting records from the database.
			<br />
			You are not removing encumbrances.
			<br />
			<br>(You should probably be making redirects too.)
			<br> You can really mess up here!
			<br />Forever and forever.
			<br />You have been warned.
			<br />
			If you are really sure about this, push the button.
			<br />Otherwise, <a href="/">go somewhere safe</a>
		</p>
		<p>
		<a href="deleteSpecByEncumbrance.cfm?action=goAway&encumbrance_id=#encumbrance_id#">[ delete these specimens ]</a>
		</p>
		<p>
		<a href="/SpecimenResults.cfm?encumbrance_id=#encumbrance_id#&loan_number=*">[ check for items on loan ]</a>
		</p>
		<br>

		<a href="deleteSpecByEncumbrance.cfm?action=getSQL&encumbrance_id=#encumbrance_id#">[ get the SQL ]</a>
	</cfoutput>
	<cfinclude template="/includes/_footer.cfm">
</cfif>
<!------------------------------------------------------------------------------>
<cfif #action# is "goAway">
<cfoutput>
	<cfquery name="CatCllobjIds" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			collection_object_id
		from
			coll_object_encumbrance
		where
			encumbrance_id=#encumbrance_id#
	</cfquery>
	<cfset catIdList = valuelist(CatCllobjIds.collection_object_id)>
	<cfif listlen(catIdList) gt 999>
		fail: listlen(catIdList)=#listlen(catIdList)#
		<cfabort>
	</cfif>
<cftransaction>

<cfquery name="specimen_archive" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	delete from specimen_archive where collection_object_id IN
		(
			select collection_object_id FROM coll_object_encumbrance WHERE
			encumbrance_id = #encumbrance_id#
		)
</cfquery>

<cfquery name="annotations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	delete from annotations where collection_object_id IN
		(
			select collection_object_id FROM coll_object_encumbrance WHERE
			encumbrance_id = #encumbrance_id#
		)
</cfquery>
<cfquery name="coll_obj_other_id_num" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	delete from coll_obj_other_id_num where collection_object_id IN
		(
			select collection_object_id FROM coll_object_encumbrance WHERE
			encumbrance_id = #encumbrance_id#
		)
</cfquery>
<cfquery name="attributes" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	delete from attributes where collection_object_id IN
		(
			select collection_object_id FROM coll_object_encumbrance WHERE
			encumbrance_id = #encumbrance_id#
		)
</cfquery>
<cfquery name="collector" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	delete from collector where collection_object_id IN
		(
			select collection_object_id FROM coll_object_encumbrance WHERE
			encumbrance_id = #encumbrance_id#
		)
</cfquery>


<cfquery name="spcolattr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	delete from specimen_part_attribute where COLLECTION_OBJECT_ID IN
		(
			select
				specimen_part.COLLECTION_OBJECT_ID
			FROM
				coll_object_encumbrance,
				specimen_part
			WHERE
				coll_object_encumbrance.collection_object_id=specimen_part.derived_from_cat_item and
				encumbrance_id = #encumbrance_id#
		)
</cfquery>


<cfquery name="spcol" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	delete from specimen_part where derived_from_cat_item IN
		(
			select collection_object_id FROM
			coll_object_encumbrance WHERE
			encumbrance_id = #encumbrance_id#
		)
</cfquery>
<cfquery name="identification_taxonomy" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	delete from identification_taxonomy where identification_id IN
		(
			select identification_id FROM identification where collection_object_id IN
			(
				select collection_object_id FROM coll_object_encumbrance WHERE
				encumbrance_id = #encumbrance_id#
			)
		)
</cfquery>

<cfquery name="specimen_event" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	delete from specimen_event where collection_object_id IN
		(
			select collection_object_id FROM coll_object_encumbrance WHERE
			encumbrance_id = #encumbrance_id#
		)
</cfquery>
<cfquery name="identification_agent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	delete from identification_agent where identification_id IN
		(
			select identification_id FROM identification where collection_object_id IN
			(
				select collection_object_id FROM coll_object_encumbrance WHERE
				encumbrance_id = #encumbrance_id#
			)
		)
</cfquery>
<cfquery name="identification" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	delete from identification where collection_object_id IN
		(
			select collection_object_id FROM coll_object_encumbrance WHERE
			encumbrance_id = #encumbrance_id#
		)
</cfquery>
<cfquery name="coll_object_remark" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	delete from coll_object_remark where collection_object_id IN
		(
			select collection_object_id FROM coll_object_encumbrance WHERE
			encumbrance_id = #encumbrance_id#
		)
</cfquery>
<cfquery name="cataloged_item" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	delete from cataloged_item where collection_object_id IN
		(
			select collection_object_id FROM coll_object_encumbrance WHERE
			encumbrance_id = #encumbrance_id#
		)
</cfquery>

<cfquery name="coll_object_encumbrance" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	delete from coll_object_encumbrance where collection_object_id IN
		(#catIdList#)
</cfquery>

<cfquery name="coll_object" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	delete from coll_object where collection_object_id IN
		(#catIdList#)
</cfquery>

</cftransaction>
spiffy

</cfoutput>



</cfif>
