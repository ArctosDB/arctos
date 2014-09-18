<cfinclude template="includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfset title = "Container Locations">
<cfoutput>
<cfif isdefined("container_id")>
	<p>
		<a href="/SpecimenResults.cfm?anyContainerId=#container_id#">Specimens</a>
	</p>
	<cfquery name="leaf" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select 
			container.container_id, 
			container.container_type,
			container.label,
			container.description,
			p.barcode,
			container.container_remarks
		from 
			container,
			container p
		where 
			container.parent_container_id=p.container_id (+) and
			container.container_type='collection object'
		start with 
			container.container_id=#container_id#
		connect by 
			container.parent_container_id = prior container.container_id
	</cfquery>
	<strong>
	<cfset partIDs="">
	<cfset displ="">
	<a href="ContDet.cfm?container_id=#container_id#" target="_detail">Container #container_id#</a>
	 has #leaf.recordcount# leaf containers:</strong>
	<table border id="t" class="sortable">
		<tr>
			<td><strong>Label</strong></td>
			<td><strong>Description</strong></td>
			<td><strong>In Barcode</strong></td>
			<td><strong>Remarks</strong></td>
			<td><strong>Part Name</strong></td>
			<td><strong>Disposition</strong></td>
			<td><strong>Cat Num</strong></td>
			<td><strong>Scientific Name</strong></td>
		</tr>
		<cfloop query="leaf">
		<cfquery name="specData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select 
				cataloged_item.collection_object_id,
				specimen_part.collection_object_id partID,
				scientific_name,
				part_name,
				cat_num,
				collection.guid_prefix,
				coll_object.COLL_OBJ_DISPOSITION
			FROM
				coll_obj_cont_hist,
				specimen_part,
				cataloged_item,
				identification,
				collection,
				coll_object
			WHERE
				coll_obj_cont_hist.collection_object_id = specimen_part.collection_object_id AND
				specimen_part.collection_object_id=coll_object.collection_object_id and
				specimen_part.derived_from_cat_item = cataloged_item.collection_object_id AND
				cataloged_item.collection_object_id = identification.collection_object_id AND
				cataloged_item.collection_id=collection.collection_id AND
				accepted_id_fg=1 AND
				container_id=#container_id#
		</cfquery>
		<cfset partIDs=listappend(partIDs,specData.partID)>
		<cfset displ=listappend(displ,specData.COLL_OBJ_DISPOSITION)>
		
		
		<tr>
			<td>
				<a href="ContDet.cfm?container_id=#container_id#" target="_detail">#label#</a>
			&nbsp;</td>
			<td>#description#&nbsp;</td>
			<td>#barcode#&nbsp;</td>
			<td>#container_remarks#&nbsp;</td>
			<td>#specData.part_name#</td>
			<td>#specData.COLL_OBJ_DISPOSITION#</td>
			<td>
				<a href="/SpecimenDetail.cfm?collection_object_id=#specData.collection_object_id#">
					#specData.guid_prefix# #specData.cat_num#
				</a>
			</td>
			<td>#specData.scientific_name#</td>
		</tr>
		</cfloop>
	</table>
</cfif>
<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select collection,collection_id from collection order by collection
</cfquery>
<cfif listcontains(displ,"on loan")>
	You can't use this to add loan items because some listed items are already on loan.
<cfelse>
	<label for="f">Add All Items To Loan and update part disposition to "on loan"</label>
	<form name="f" method="post" action="">
		<input type="hidden" name="Action" value="addPartsToLoan">
		<input type="hidden" name="partIDs" value="#partIDs#">
		<label for="collection">Collection</label>
		<select name="collection_id" id="collection_id">
			<cfloop query="ctcollection">
				<option value="#collection_id#">#collection#</option>
			</cfloop>
		</select>
		<label for="loan_number">Loan Number</label>
		<input type="text" name="loan_number" size="25">
		<br>
		<input type="submit" value="add all items to loan">
	</form>
</cfif>

</cfoutput>
<cfif action is "addPartsToLoan">
	<cfquery name="getLoan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select loan.transaction_id from loan,trans where loan.transaction_id=trans.transaction_id and
		loan.loan_number='#loan_number#' and
		trans.collection_id=#collection_id#
	</cfquery>
	<cfif getLoan.recordcount is not 1>
		error finding loan
		<cfdump var=#getLoan#>
		<cfabort>
	</cfif>
	<cftransaction>
		<cfloop list="#partIDs#" index="li">
			<cfquery name="insItem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
				insert into loan_item (
					TRANSACTION_ID,
					COLLECTION_OBJECT_ID,
					RECONCILED_BY_PERSON_ID,
					RECONCILED_DATE,
					ITEM_DESCR
				) values (
					#getLoan.transaction_id#,
					#li#,
					#session.myAgentId#,
					sysdate,
					(
						select 
							guid || ' ' || part_name 
						from 
							flat,
							specimen_part 
						where
							flat.collection_object_id=specimen_part.derived_from_cat_item and
							specimen_part.collection_object_id=#li#
					)
				)
			</cfquery>
			<cfquery name="upD" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
				update coll_object set COLL_OBJ_DISPOSITION='on loan' where COLLECTION_OBJECT_ID=#li#
			</cfquery>
		</cfloop>
	</cftransaction>
	<cfoutput>
		Added #listlen(partIDs)# items to loan <a href="Loan.cfm?action=editLoan&transaction_id=#getLoan.transaction_id#">#loan_number#</a>
	</cfoutput>
	<cfabort>
</cfif>


 <cfinclude template="includes/_footer.cfm">