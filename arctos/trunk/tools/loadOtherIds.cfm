<cfinclude template="/includes/_header.cfm">
<cfif #Action# is "nothing">
This application reads data from s:\pubpool\OtherIdentifiers.mdb table OtherIdentifiers. It is meant to load other ID numbers, primarily GenBank sequence accessions, into Arctos.
<p>
The data from Access table OtherIdentifiers are presented below. Before you may load these data, you must:
	<ul>
		<li>Verify that the Found Specimen columns contains a link to 
				specimen data, and that data is for the specimen you intend to load
		</li>
		<li>
			The other ID type is green in the Load ID Type column. Red means it was not found in the code table and will not successfully load.
		</li>
	</ul>

<p>
	To change data, just change the Access table and reload this page.
	
<p>
	Access table OtherIdentifiers:
	<ul>
		<li>rowid: Used by Access to identify records. Don't mess with it.</li>
		<li>OracleCollectionObjectId: Populated by ColdFusion when a match has been identified. You may also enter the cataloged item collection_object_id from Arctos here.</li>
		<li>CollectionCode: Collection code of the specimen for which you are loading data. Required. (in Mamm, Herp, Bird, Herb)</li>
		<li>CatalogNumber: Catalog Number of the specimen you intend to load Other IDs for. Optional.</li>
		<li>FindCatByIdentifierType: Type of identifier provided in FindCatByIdentifierNumber (ie, "AF Number", "original field number")</li>
		<li>FindCatByIdentifierNumber: Existing other identifier (ie, AF Number) ColdFusion can use to match the record.</li>
		<li>LoadIdentifierType: Type of Other ID to be laoded (ie, GenBank sequence accession)</li>
		<li>LoadIdentifierNumber: Value of the Other ID to be loaded</li>
	</ul>
	
</p>
</p>


</p> 
<br>

<cfquery name="genbank" datasource="genbank">
	select * from OtherIdentifiers
	order by OracleCollectionObjectId	
</cfquery>
<cfoutput>
<cfloop query="genbank">

<!--- see if we can get a collection_object_id for these cataloged items --->
<!--- 1st option: We got a cat number and a collection code --->
<cfif len(#catalogNumber#) gt 0 AND len(#collectionCode#) gt 0>
	<cfquery name="CatColl" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		select collection_object_id FROM cataloged_item WHERE cat_num=#catalogNumber# and collection_cde='#collectionCode#'
	</cfquery>
	<cfif len(#CatColl.collection_object_id#) gt 0>
		<cfif CatColl.recordcount is 1>
			<cfquery name="gotCatColl" datasource="genbank">
				UPDATE OtherIdentifiers 
				SET OracleCollectionObjectId = #CatColl.collection_object_id#
				WHERE rowid = #rowid#
			</cfquery>
		</cfif>
	</cfif>
</cfif>
<!--- 2nd option: We got a collection code, and other id type, and an other ID number --->
<cfif len(#collectionCode#) gt 0 AND len(#FindCatByIdentifierNumber#) gt 0 AND len(#FindCatByIdentifierType#) gt 0>
	<cfquery name="OtherID" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		select cataloged_item.collection_object_id 
		FROM cataloged_item,coll_obj_other_id_num
		WHERE 
			cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id AND
			other_id_type='#FindCatByIdentifierType#' AND
			other_id_num = '#FindCatByIdentifierNumber#' AND
			collection_cde='#collectionCode#'
	</cfquery>
	<cfif len(#OtherID.collection_object_id#) gt 0>
		<cfif OtherID.recordcount is 1>
			<cfquery name="gotCatColl" datasource="genbank">
				UPDATE OtherIdentifiers 
				SET OracleCollectionObjectId = #OtherID.collection_object_id#
				WHERE rowid = #rowid#
			</cfquery>
		</cfif>
	</cfif>
</cfif>
</cfloop>
<!--- requery access and see what we got --->
<cfquery name="didItWork" datasource="genbank">
	select * from OtherIdentifiers order by 
	OracleCollectionObjectId,
	catalogNumber,
	FindCatByIdentifierType,
	FindCatByidentifierNumber	
</cfquery>
<table border>
<tr>
	<td>Catalog Number</td>
	<td>Collection Code</td>
	<td>Find Catalog Number by ID Type</td>
	<td>Find Catalog Number by ID Number</td>
	<td>Load ID type</td>
	<td>Load ID Number</td>
	<td>Found Specimen</td>
</tr>
<cfset i=1>
<cfloop query="didItWork">
<tr>
	<td>#catalogNumber#</td>
	<td>#collectionCode#</td>
	<td>#FindCatByIdentifierType#</td>
	<td>#FindCatByidentifierNumber#</td>
	<td>
		<cfquery name="isCt" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			select other_id_type from ctcoll_other_id_type
			where other_id_type='#LoadIdentifierType#'
			AND collection_cde='#collectionCode#'
		</cfquery>
		<cfif isCT.recordcount gt 0>
            <font color="##00FF66">#LoadIdentifierType#</font> 
            <cfelse>
            <font color="##FF0000">#LoadIdentifierType#</font> 
          </cfif>
	</td>
	<td>#loadidentifierNumber#</td>
	<td>
	 <cfif len(#OracleCollectionObjectId#) gt 0 AND #OracleCollectionObjectId# gt 0>
	 	<a href="SpecimenDetail.cfm?collection_object_id=#OracleCollectionObjectId#">check data</a>
	<cfelse>
            <font color="##FF0000">Not found!!</font> 
          </cfif>
	</td>
	
</tr>
<cfset i=#i#+1>
</cfloop>
</table>
<form name="load" method="post" action="loadOtherIds.cfm">
	<input type="hidden" name="action" value="loadData">
	<input type="submit" value="Load These Data">
</form>
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------>
<cfif #Action# is "loadData">
<cfoutput>
<!--- get the data --->
	<cfquery name="genbank" datasource="genbank">
		select * from OtherIdentifiers
	</cfquery>
<!--- loop through each record and check data --->
	<cfloop query="genbank">
	<!--- check data once more --->
		<!--- code-table values ---->
		<cfquery name="isGoodType" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			select other_id_type from ctcoll_other_id_type
			where other_id_type='#LoadIdentifierType#'
			AND collection_cde='#collectionCode#'
		</cfquery>
			<cfif isGoodType.recordcount is not 1>
				Validation failed! Nothing has been loaded!
				<br>Bad code table value.
				<cfabort>		
			</cfif>
		<!----- got coll obj id ---->
		<cfif #OracleCollectionObjectId# lt 1>
				Validation failed! Nothing has been loaded!
				<br>Record not found.
				<cfabort>
		</cfif>
		<!---- looks like this record exists --->
		<cfquery name="isCat" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			select cat_num from cataloged_item 
			where collection_object_id = #OracleCollectionObjectId#
			and collection_cde = '#collectionCode#'
		</cfquery>
		<cfif isCat.recordcount is not 1>
				Validation failed! Nothing has been loaded!
				<br> Cat Number match funky.
				<cfabort>		
			</cfif>
		</cfloop>
<!--- loop through again and load each record --->
	<cfloop query="genbank">
		
		<cfquery name="load" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			INSERT INTO coll_obj_other_id_num (collection_object_id, other_id_type, other_id_num)
			VALUES (#OracleCollectionObjectId#, '#LoadIdentifierType#', '#loadidentifierNumber#')
		</cfquery>
		</cfloop>
		all done!
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------>
<cfinclude template="/includes/_footer.cfm">