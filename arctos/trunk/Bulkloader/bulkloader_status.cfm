<cfinclude template="/includes/_header.cfm">
<cf_setDataEntryGroups>
<cfquery name="bulkSummary" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select 
		loaded, 
		accn, 
		enteredby, 
		guid_prefix,
		count(*) cnt
	from 
		bulkloader
	where
		upper(replace(guid_prefix,':','_')) IN (#ListQualify(inAdminGroups, "'")#)
	group by
		loaded, 
		accn, 
		enteredby, 
		guid_prefix
	order by 
		guid_prefix,
		enteredby
</cfquery>
<cfoutput>
	What's In The Bulkloader:
	<table border="1">
		<tr>
			<td>Collection</td>
			<td>Accn</td>
			<td>Entered By</td>
			<td>Status</td>
			<td>Count</td>
		</tr>
	<cfloop query="bulkSummary">
		<tr>
			<td>#guid_prefix#</td>
			<td>#accn#</td>
			<td>#EnteredBy#</td>
			<td>#Loaded#</td>
			<td>#cnt#</td>
		</tr>
	</cfloop>
	</table>
<p>&nbsp;</p>
<hr style="height:15px; background-color:red">
<p>&nbsp;</p>
<cfquery name="failures" datasource="uam_god">
	select bulkloader.collection_object_id,
		loaded,
		guid_prefix
	from
		bulkloader,
		bulkloader_attempts		
	where
		bulkloader.collection_object_id = B_COLLECTION_OBJECT_ID AND
		loaded <> 'spiffification complete' and
		upper(replace(bulkloader.guid_prefix,':','_')) IN (#ListQualify(inAdminGroups, "'")#)
	group by
		bulkloader.collection_object_id,
		loaded,
		guid_prefix
	order by
		guid_prefix,
		bulkloader.collection_object_id
</cfquery>

	Failures: (Loaded="waiting approval" indicates records which have failed to load and then viewed/fixed in the Data Entry application.)
	<table border="1">
		<tr>
			<td>
				Bulkloader ID
			</td>
			<td>Loaded</td>
		</tr>
	<cfloop query="failures">
		<tr>
			<td>
				<a href="/DataEntry.cfm?ImAGod=yes&action=editEnterData&pMode=edit&collection_object_id=#collection_object_id#">
					#collection_object_id#
				</a>
				 (#guid_prefix#)
			</td>
			<td>#loaded#</td>
		</tr>
	</cfloop>
	</table>
<cfquery name="success" datasource="uam_god">
	select bulkloader_attempts.collection_object_id,
		cataloged_item.cat_num,
		collection.guid_prefix
	from
		bulkloader_deletes,
		bulkloader_attempts,
		cataloged_item,
		collection	
	where
		bulkloader_deletes.collection_object_id = B_COLLECTION_OBJECT_ID AND
		bulkloader_attempts.collection_object_id = cataloged_item.collection_object_id AND
		cataloged_item.collection_id = collection.collection_id AND
		TSTAMP > ('#dateformat(now()-5,"yyyy-mm-dd")#') and
		upper(replace(bulkloader.guid_prefix,':','_')) IN (#ListQualify(inAdminGroups, "'")#)
	group by
		bulkloader_attempts.collection_object_id,
		cataloged_item.cat_num,
		collection.guid_prefix
	order by
		collection.guid_prefix,
		cataloged_item.cat_num
</cfquery>
<p>&nbsp;</p>
<hr style="height:15px; background-color:red">
<p>&nbsp;</p>
<cfset idList = valuelist(success.collection_object_id)>
Successfully Loaded in the last Five days:
<a href="/SpecimenResults.cfm?collection_object_id=#idList#">See All in SpecimenResults</a>
<table border="1">
		<tr>
			<td>Item</td>
		</tr>
	<cfloop query="success">
		<tr>
			<td>
				<a href="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">
					#guid_prefix# #cat_num#
				</a>
			</td>
		</tr>
	</cfloop>
	</table>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">