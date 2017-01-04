<cfsetting requesttimeout="600">

<cfinclude template="/includes/_header.cfm">

<cfset title="bulkload identifiers">
<p>
	<a href="BulkloadOtherId.cfm?action=managemystuff">Manage Existing Data</a>~
	<a href="http://arctosdb.org/documentation/other-id/">Docs</a>~
	<a href="/info/ctDocumentation.cfm?table=CTCOLL_OTHER_ID_TYPE">CodeTable</a>


</p>
<!---- make the table

drop table cf_temp_oids;
drop public synonym cf_temp_oids;

create table cf_temp_oids (
	key number,
	collection_object_id number,
	guid_prefix varchar2(20) not null,
	existing_other_id_type varchar2(60) not null,
	existing_other_id_number varchar2(60) not null,
	new_other_id_type varchar2(60) not null,
	new_other_id_number varchar2(60) not null,
	new_other_id_references varchar2(60),
	status varchar2(4000)
);

	create public synonym cf_temp_oids for cf_temp_oids;
	grant select,insert,update,delete on cf_temp_oids to manage_specimens;

	 CREATE OR REPLACE TRIGGER cf_temp_oids_key
 before insert  ON cf_temp_oids
 for each row
    begin
    	if :NEW.key is null then
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;
    end;
/
sho err


-- allow data entry
alter table cf_temp_oids modify guid_prefix null;
alter table cf_temp_oids modify key  not null;

create unique index iu_cf_temp_oids_key on cf_temp_oids(key) tablespace uam_idx_1;

create index ix_u_cftempoid_uname on cf_temp_oids (upper (username) ) tablespace uam_idx_1;


------>
<cfif action is "template">
	<cfoutput>
		<cfset d="GUID_PREFIX,EXISTING_OTHER_ID_TYPE,EXISTING_OTHER_ID_NUMBER,NEW_OTHER_ID_TYPE,NEW_OTHER_ID_NUMBER,NEW_OTHER_ID_REFERENCES">
		<cffile action="write" addnewline="no" file="#Application.webDirectory#/download/BulkloadOtherId.csv" output="#d#">
		<cflocation url="/download.cfm?file=BulkloadOtherId.csv" addtoken="false">
		<a href="/download/BulkloadOtherId.csv">Click here if your file does not automatically download.</a>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------->
<cfif action is "nothing">
	Upload a comma-delimited text file (csv).
	<p>
		<a href="BulkloadOtherId.cfm?action=template">get a upload/data template here</a>
	</p>
	<p>
		This form will happily create duplicates, which will not load. Use the provided tools after verification.
	</p>
	<table border>
		<tr>
			<th>Column</th>
			<th>Required</th>
			<th>ExampleData</th>
			<th>Wutsitdo</th>
		</tr>
		<tr>
			<td>guid_prefix</td>
			<td>yes</td>
			<td>UAM:Mamm - UAMObs:Mamm</td>
			<td>
				guid_prefix from manage collection; identifies the collection which owns the specimen
				to which the other ID is being attached. Usually a concatenation of institution_acronym and
				collection_cde
			</td>
		</tr>
		<tr>
			<td>existing_other_id_type</td>
			<td>yes</td>
			<td>
				"catalog number" or OTHER_ID_TYPE from <a href="/info/ctDocumentation.cfm?table=CTCOLL_OTHER_ID_TYPE">CTCOLL_OTHER_ID_TYPE</a>
			</td>
			<td>
				used to find the specimen; in conjunction with existing_other_id_number, must resolve to exactly one cataloged item
			</td>
		</tr>
		<tr>
			<td>existing_other_id_number</td>
			<td>yes</td>
			<td>
				Value of the existing_other_id
			</td>
			<td>
				used to find the specimen; in conjunction with existing_other_id_number, must resolve to exactly one cataloged item
			</td>
		</tr>
		<tr>
			<td>new_other_id_number</td>
			<td>yes</td>
			<td>
				catalog number when existing_other_id_type is "catalog number", or value corresponding to new_other_id_type
			</td>
			<td>
				value of identifier to add
			</td>
		</tr>
		<tr>
			<td>new_other_id_type</td>
			<td>yes</td>
			<td>
				OTHER_ID_TYPE from <a href="/info/ctDocumentation.cfm?table=CTCOLL_OTHER_ID_TYPE">CTCOLL_OTHER_ID_TYPE</a>
			</td>
			<td>
				type of identifier to add
			</td>
		</tr>
		<tr>
			<td>new_other_id_references</td>
			<td>no</td>
			<td>
				ID_REFERENCES from <a href="/info/ctDocumentation.cfm?table=CTID_REFERENCES">CTID_REFERENCES</a>.
			</td>
			<td>
				Labeled "relationship" in various forms, this defines
				the current specimen's (existing_other_id_type,existing_other_id_number) relationship to another specimen (given in
				new_other_id_type,new_other_id_number). Used when the other ID references another data object, such as a host's catalog number if
				existing specimen is a parasite. Creates relationships.
				leave blank or use "self" when the ID references this specimen (such as when loading GenBank numbers)
			</td>
		</tr>
	</table>
	<form name="oids" method="post" enctype="multipart/form-data" action="BulkloadOtherId.cfm">
		<input type="hidden" name="Action" value="getFile">
		<label for="">upload CSV</label>
		<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file">
	</form>
</cfif>
<!------------------------------------------------------->
<cfif action is "getFile">
<cfoutput>
	<!--- put this in a temp table --->
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	<cfset fileContent=replace(fileContent,"'","''","all")>
	<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />
	<cfset colNames="">
	<cfloop from="1" to ="#ArrayLen(arrResult)#" index="o">
		<cfset colVals="">
			<cfloop from="1"  to ="#ArrayLen(arrResult[o])#" index="i">
				<cfset thisBit=arrResult[o][i]>
				<cfif #o# is 1>
					<cfset colNames="#colNames#,#thisBit#">
				<cfelse>
					<cfset colVals="#colVals#,'#thisBit#'">
				</cfif>
			</cfloop>
		<cfif o is 1>
			<cfset colNames=replace(colNames,",","","first")>
		</cfif>
		<cfif len(colVals) gt 1>
			<cfset colVals=replace(colVals,",","","first")>
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into cf_temp_oids (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>
	<cflocation url="BulkloadOtherId.cfm?action=managemystuff" addtoken="false">
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "srsq">
<cfoutput>
	<div class="infoBox">
		If you're seeing this, the check has probably timed out.
		This process only checks not-"catalog number" records and can be slow. You may need to deal with any
		non-unique IDs and reload.
		<a href="BulkloadOtherId.cfm?action=managemystuff">back to manage</a>.

	</div>

	<cftransaction>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_temp_oids where upper(username)='#ucase(session.username)#' and existing_other_id_type != 'catalog number'
		</cfquery>

		<cfloop query="#d#">
			<cfquery name="grc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select
					cataloged_item.collection_object_id
				from
					cataloged_item,
					collection,
					coll_obj_other_id_num
				WHERE
					cataloged_item.collection_id = collection.collection_id and
					cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id and
					collection.guid_prefix = '#guid_prefix#' and
					other_id_type = '#existing_other_id_type#' and
					display_value = '#existing_other_id_number#'
			</cfquery>
			<cfif grc.recordcount gt 1>
				<br>#guid_prefix# #existing_other_id_type# #existing_other_id_number# returns #grc.recordcount# records
				<a href="/SpecimenResults.cfm?collection_object_id=#valuelist(grc.collection_object_id)#" target="_blank">
					click for specimens
				</a>
				<cfquery name="nuq" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update
						cf_temp_oids
					set
						status=decode(status,
							null,'existing ID is not unique',
							status || '; existing ID is not unique')
					where
						key=#key# and
						upper(username)='#ucase(session.username)#'
				</cfquery>
			</cfif>
		</cfloop>
	</cftransaction>
	<cflocation url="BulkloadOtherId.cfm?action=managemystuff" addtoken="false">
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "validate">
<cfoutput>
	<div class="infoBox">
		<strong>single-row subquery returns more than one row problems</strong>?
		<a href="BulkloadOtherId.cfm?action=srsq">Click here to find them</a>. This error is caused by nonunique data -
		usually two specimens sharing an ID used here. Check status for "existing ID is not unique" after performing this check.
	</div>
	<cfquery name="presetstatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update
			cf_temp_oids
		set
			status=NULL where upper(username)='#ucase(session.username)#'
	</cfquery>
	<cfquery name="collObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_oids set COLLECTION_OBJECT_ID = (
			select
				cataloged_item.collection_object_id
			from
				cataloged_item,
				collection
			WHERE
				cataloged_item.collection_id = collection.collection_id and
				collection.guid_prefix = cf_temp_oids.guid_prefix and
				cat_num=cf_temp_oids.existing_other_id_number
		)
		where
			existing_other_id_type = 'catalog number' and
			upper(username)='#ucase(session.username)#'
	</cfquery>
	<cfquery name="collObj_nci" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_oids set COLLECTION_OBJECT_ID = (
			select
				cataloged_item.collection_object_id
			from
				cataloged_item,
				collection,
				coll_obj_other_id_num
			WHERE
				cataloged_item.collection_id = collection.collection_id and
				cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id and
				collection.guid_prefix = cf_temp_oids.guid_prefix and
				other_id_type = cf_temp_oids.existing_other_id_type and
				display_value = cf_temp_oids.existing_other_id_number
		)
		where
			existing_other_id_type != 'catalog number' and
			upper(username)='#ucase(session.username)#'
	</cfquery>
	<cfquery name="collObj_fail" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update
			cf_temp_oids
		set
			status=decode(status,
				null,'cataloged item not found',
				status || '; cataloged item not found')
		where
			collection_object_id is null and
			upper(username)='#ucase(session.username)#'
	</cfquery>


	<cfquery name="iva" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update
			cf_temp_oids
		set
			status=decode(status,
			null,'new_other_id_references not found',
			status || '; new_other_id_references not found')
		where
			new_other_id_references != 'catalog number' and
			new_other_id_references not in (select ID_REFERENCES from CTID_REFERENCES) and
			upper(username)='#ucase(session.username)#'
	</cfquery>
	<cfquery name="iva" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update
			cf_temp_oids
		set
			status=decode(status,
			null,'existing_other_id_type not found',
			status || '; existing_other_id_type not found')
		where
			existing_other_id_type != 'catalog number' and
			existing_other_id_type not in (select OTHER_ID_TYPE from CTCOLL_OTHER_ID_TYPE) and
			upper(username)='#ucase(session.username)#'
	</cfquery>
	<cfquery name="iva" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update
			cf_temp_oids
		set
			status=decode(status,
			null,'new_other_id_type not found',
			status || '; new_other_id_type not found')
		where
			new_other_id_type not in (select OTHER_ID_TYPE from CTCOLL_OTHER_ID_TYPE) and
			upper(username)='#ucase(session.username)#'
	</cfquery>

	<cfquery name="alreadyGotOne" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update
			cf_temp_oids
		set
			status=decode(status,
			null,'identifier exists',
			status || '; identifier exists')
		where
			upper(username)='#ucase(session.username)#' and
			collection_object_id is not null and
			(
				collection_object_id,
				new_other_id_type,
				new_other_id_number,
				nvl(new_other_id_references,'self')
			) IN
			(
				select
					collection_object_id,
					other_id_type,
					display_value,
					id_references
				from
					coll_obj_other_id_num
			)
	</cfquery>

	<cfquery name="alreadyGotOne" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update
			cf_temp_oids
		set
			status=decode(status,
				null,'local duplicate',
				status || '; local duplicate')
		where
			upper(username)='#ucase(session.username)#' and
			(
			guid_prefix,
			new_other_id_type,
			new_other_id_number,
			nvl(new_other_id_references,'self'),
			existing_other_id_type,
			existing_other_id_number
			) in (select guid_prefix,
				new_other_id_type,
				new_other_id_number,
				nvl(new_other_id_references,'self'),
				existing_other_id_type,
				existing_other_id_number
			from
				cf_temp_oids
			having count(*) > 1 group by
				guid_prefix,
				new_other_id_type,
				new_other_id_number,
				nvl(new_other_id_references,'self'),
				existing_other_id_type,
				existing_other_id_number
			)
	</cfquery>

	<cfquery name="fail" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_oids set status='valid' where status is null and upper(username)='#ucase(session.username)#'
	</cfquery>

	<cflocation url="BulkloadOtherId.cfm?action=managemystuff" addtoken="false">
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "getRecip">
	<script src="/includes/sorttable.js"></script>
	<script>
		$(document).ready(function() {
		    $('#selecctall').click(function(event) {  //on click
		        if(this.checked) { // check select status
		            $(':checkbox').each(function() { //loop through each checkbox
		                this.checked = true;  //select all checkboxes with class "checkbox1"
		            });
		        }else{
		            $(':checkbox').each(function() { //loop through each checkbox
		                this.checked = false; //deselect all checkboxes with class "checkbox1"
		            });
		        }
		    });

		});
	</script>
	<cfparam name="gp" default="">
	<cfparam name="ref" default="">
	<cfoutput>
		<cfquery name="recip" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				collection.collection,
				key,
				cf_temp_recip_oids.collection_id,
				cf_temp_recip_oids.guid_prefix,
				existing_other_id_type,
				existing_other_id_number,
				new_other_id_type,
				new_other_id_number,
				new_other_id_references,
				found_date
			from
				cf_temp_recip_oids,
				collection
			where
				cf_temp_recip_oids.collection_id=collection.collection_id and
				collection.collection_id in (
					select collection_id from cataloged_item
				)
				<cfif len(gp) gt 0>
					and cf_temp_recip_oids.guid_prefix in (#listqualify(gp,"'")#)
				</cfif>
				<cfif len(ref) gt 0>
					and cf_temp_recip_oids.new_other_id_references in (#listqualify(ref,"'")#)
				</cfif>
			order by
				collection.collection,
				new_other_id_references,
				cf_temp_recip_oids.guid_prefix,
				new_other_id_type
		</cfquery>
		<cfquery name="ctguid_prefix" dbtype="query">
			select guid_prefix from recip group by guid_prefix order by guid_prefix
		</cfquery>
		<cfquery name="ctref" dbtype="query">
			select new_other_id_references from recip group by new_other_id_references order by new_other_id_references
		</cfquery>
		These specimens have unreciprocated relationships to your collections.
		<ol>
			<li>
				Check box(es) and click "claim" to pull them into your otherID bulkloader.
			</li>
			<li>Click Validate</li>
			<li>Click Finalize</li>
			<li>Use the Contact link below there are complications</li>
		</ol>
		<a href="##forceRefreshLinks">scroll down</a> to force-refresh
		<hr>
		Filter
		<form name="filter" method="post" action="BulkloadOtherId.cfm">
			<input type="hidden" name="action" value="getRecip">
			<label for="gp">guid_prefix</label>
			<select name="gp" multiple>
				<option value="">no filter</option>
				<cfloop query="ctguid_prefix">
					<option
						<cfif listcontains(gp,ctguid_prefix.guid_prefix)> selected="selected" </cfif>
						value="#ctguid_prefix.guid_prefix#">#ctguid_prefix.guid_prefix#</option>
				</cfloop>
			</select>
			<label for="ref">references</label>
			<select name="ref" multiple>
				<option value="">no filter</option>
				<cfloop query="ctref">
					<option
						<cfif listcontains(ref,ctref.new_other_id_references)> selected="selected" </cfif>
						value="#ctref.new_other_id_references#">#ctref.new_other_id_references#</option>
				</cfloop>
			</select>
			<br><input type="submit" value="update filter">
		</form>
		<hr>
		<form name="f" method="post" action="BulkloadOtherId.cfm">
			<label for="">Select All</label>
			<input type="checkbox" id="selecctall">
			<input type="hidden" name="action" value="claimRecip">

			<input type="submit" value="claim checked records">
			<table border id="t" class="sortable">
			<tr>
				<th>Claim</th>
				<th>My Specimen</th>
				<th>Relationship</th>
				<th>Related Specimen</th>
			</tr>
			<cfloop query="recip">
				<tr>
					<td><input type="checkbox" name="key" value="#key#"></td>
					<td>
						<a href="/guid/#guid_prefix#:#existing_other_id_number#" target="_blank">#guid_prefix#:#existing_other_id_number#</a>
					</td>
					<td>#new_other_id_references#</td>
					<td>
						<a href="/guid/#new_other_id_type#:#new_other_id_number#" target="_blank">#new_other_id_type#:#new_other_id_number#</a>
					</td>
				</tr>
			</cfloop>
			</table>
			<!--- "long view" - not needed as long as these data come only from the scheduled task; we can make this easier to read.
			<table border id="t" class="sortable">
			<tr>
				<th>Claim</th>
				<th>Collection</th>
				<th>existing_other_id_type</th>
				<th>existing_other_id_number</th>
				<th>new_other_id_references</th>
				<th>new_other_id_type</th>
				<th>new_other_id_number</th>
			</tr>
			<cfloop query="recip">
				<tr>
					<td><input type="checkbox" name="key" value="#key#"></td>
					<td>#guid_prefix#</td>
					<td>#existing_other_id_type#</td>
					<td>#existing_other_id_number#</td>
					<td>#new_other_id_references#</td>
					<td>#new_other_id_type#</td>
					<td>#new_other_id_number#</td>
				</tr>
			</cfloop>
			</table>

			---->
			<input type="submit" value="claim checked records">
		</form>
		<a name="forceRefreshLinks"></a>
		<cfquery name="mycollections" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select guid_prefix,collection.collection_id from collection,cataloged_item group by guid_prefix,collection.collection_id order by guid_prefix
		</cfquery>
		<p>
			These data are refreshed daily; "claiming" or loading records does NOT remove them from this form. Pulling same-day records twice will error;
			delete from your bulkloader to re-pull. You may also force-refresh the reciprocal relationship data with the link(s) below.
			(Let the new page fully load, then close it and refresh this page.)
			<ul>
				<cfloop query="mycollections">
					<li>
						<a href="/ScheduledTasks/pendingRelations.cfm?cid=#collection_id#" target="_blank">refresh #guid_prefix#</a>
					</li>
				</cfloop>
			</ul>
		</p>
	</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "claimRecip">
	<cfoutput>
		<p>
			Seeing UAM.IX_UCF_TEMP_OIDS_KEY errors? You're trying to pull something that you've already pulled. Delete from your otherID
			bulkloader and/or get a DBA to run the reciprocal-relationship checker-thingee.
		</p>
		<cfquery name="gimme" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into cf_temp_oids (
				key,
				guid_prefix,
				existing_other_id_type,
				existing_other_id_number,
				new_other_id_type,
				new_other_id_number,
				new_other_id_references,
				status
			) (
				select
					key,
					guid_prefix,
					existing_other_id_type,
					existing_other_id_number,
					new_other_id_type,
					new_other_id_number,
					new_other_id_references,
					'claimed reciprocal'
				from
					cf_temp_recip_oids
				where key in (#key#)
			)
		</cfquery>
		<cflocation url="BulkloadOtherId.cfm?action=managemystuff" addtoken="false">
	</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------->
<cfif action is "getGuidPrefixFromUUID">
	<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			EXISTING_OTHER_ID_NUMBER
		from
			cf_temp_oids
		where
			upper(username)='#ucase(session.username)#' and
			guid_prefix is null and
			EXISTING_OTHER_ID_TYPE='UUID' and
			EXISTING_OTHER_ID_NUMBER is not null
		group by
			EXISTING_OTHER_ID_NUMBER
	</cfquery>
	<cfloop query="mine">
		<cfquery name="gg" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				guid_prefix
			from
				collection,
				cataloged_item,
				coll_obj_other_id_num
			where
				collection.collection_id=cataloged_item.collection_id and
				cataloged_item.collection_object_id=coll_obj_other_id_num.collection_object_id and
				other_id_type='UUID' and
				display_value='#EXISTING_OTHER_ID_NUMBER#'
		</cfquery>
		<cfif gg.recordcount is 1>
			<cfquery name="gg" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update cf_temp_oids set guid_prefix='#gg.guid_prefix#' where EXISTING_OTHER_ID_NUMBER='#EXISTING_OTHER_ID_NUMBER#'
			</cfquery>
		</cfif>
	</cfloop>
	<cflocation url="BulkloadOtherId.cfm?action=managemystuff" addtoken="false">
</cfif>
<!------------------------------------------------------->
<cfif action is "managemystuff">
	<script src="/includes/sorttable.js"></script>
	<cfoutput>
		<div class="ui-state-highlight ui-corner-all">
			<p><strong>READ THIS!</strong></p>
			This form creates otherIDs, and pulls suggested reciprocal relationships which may be created as IDs/relationships.
			<p>
				Always download a CSV backup before using local tools.
			</p>
			<p>
				Records will be deleted when they're successfully loaded.
			</p>
			<p>
				Change status by fixing problems and clicking validate. Re-validate after anything has changed.
			</p>
			<p>
				Use "get GUID Prefix" to find specimens added here from the specimen bulkloader and linked via UUID. This will
				only work after the relevant specimen has been loaded to Arctos.
			</p>
		</div>
		<cfquery name="recip" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select collection.collection,collection.collection_id, count(*) from
			cf_temp_recip_oids,
			collection
			where cf_temp_recip_oids.collection_id=collection.collection_id and collection.collection_id in (
			select collection_id from cataloged_item) group by collection.collection,collection.collection_id order by collection.collection
		</cfquery>
		<cfquery name="raw" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				cf_temp_oids.KEY,
				cf_temp_oids.COLLECTION_OBJECT_ID,
				cf_temp_oids.GUID_PREFIX,
				cf_temp_oids.EXISTING_OTHER_ID_TYPE,
				cf_temp_oids.EXISTING_OTHER_ID_NUMBER,
				cf_temp_oids.NEW_OTHER_ID_TYPE,
				cf_temp_oids.NEW_OTHER_ID_NUMBER,
				cf_temp_oids.NEW_OTHER_ID_REFERENCES,
				cf_temp_oids.STATUS,
				cf_temp_oids.USERNAME,
				flat.guid
			from
				cf_temp_oids,
				flat
			where
				cf_temp_oids.COLLECTION_OBJECT_ID=flat.COLLECTION_OBJECT_ID (+) and
				upper(username)='#ucase(session.username)#'
		</cfquery>
		<cfif recip.recordcount gt 0>
			<p>
				Reciprocal relationships for your collection(s) have been detected.
				<a href="BulkloadOtherId.cfm?action=getRecip">check them here</a>
			</p>
		</cfif>
		<a href="BulkloadOtherId.cfm?action=loadData">Load ("Valid" only)</a>
		<div class="infoBox">
			Note: If no records are "Valid" this will happily do nothing and report successfully doing so.
		</div>
		<p><a href="BulkloadOtherId.cfm?action=nothing">upload CSV</a></p>
		<p><a href="BulkloadOtherId.cfm?action=validate">validate</a></p>
		<p><a href="BulkloadOtherId.cfm?action=getCSV">download CSV</a> (delete status column to re-load)</p>
		<p><a href="BulkloadOtherId.cfm?action=deleteAlreadyExists">Delete "identifier exists" records</a></p>
		<p><a href="BulkloadOtherId.cfm?action=deleteLocalDuplicate">Merge "local duplicate" records</a></p>
		<p><a href="BulkloadOtherId.cfm?action=getGuidPrefixFromUUID">Get Guid Prefix from UUID</a></p>
		<p><a href="BulkloadOtherId.cfm?action=deleteMine">Delete all of your records from this loader</a></p>
		<cfif session.roles contains "manage_collection">
			You have manage_collection, so you can "take" records from people in your collection(s). This is useful when students
			(who should generally not have access to this form) enter data here via the specimen bulkloader. Records which
			are still in the bulkloader will fail validation; they become your responsibility after you claim them, so
			make sure they are not deleted until the specimen exists and they are
			attached to it.

			<br>NOT ALL OF THESE WILL NECESSARILY BE YOUR SPECIMENS!! Read stuff, then click.
			<br>Use this with great caution. You may need to coordinate with other curatorial staff or involve a DBA.
			<br><a href="BulkloadOtherId.cfm?action=takeStudentRecords">Check for records entered by people in your collection(s)</a>
			<hr>
		</cfif>
		<form name="f" method="pos" action="BulkloadOtherId.cfm">
			<input name="action" value="deleteChecked" type="hidden">
			<input type="submit" value="delete checked">
			<table border id="t" class="sortable">
				<tr>
					<th>delete</th>
					<th>status</th>
					<th>specimen</th>
					<th>guid_prefix</th>
					<th>existing_other_id_type</th>
					<th>existing_other_id_number</th>
					<th>new_other_id_references</th>
					<th>new_other_id_type</th>
					<th>new_other_id_number</th>
				</tr>
				<cfloop query="raw">
					<tr>
						<td><input type=checkbox name="key" value="#key#"></td>
						<td>#status#</td>
						<td>
							<cfif len(guid) gt 0>
								<a href="/guid/#guid#" target="_blank">#guid#</a>
							</cfif>
						</td>
						<td>#guid_prefix#</td>
						<td>#existing_other_id_type#</td>
						<td>#existing_other_id_number#</td>
						<td>#new_other_id_references#</td>
						<td>#new_other_id_type#</td>
						<td>#new_other_id_number#</td>
					</tr>
				</cfloop>
			</table>
			<input type="submit" value="delete checked">
		</form>
	</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "takeStudentRecords">
	<cfoutput>
		<a href="BulkloadOtherId.cfm?action=managemystuff">back to my stuff</a>
		<cfquery name="d" datasource="uam_god">
			select
				count(*) c,
				username
			from
				cf_temp_oids
			where
				upper(username) != '#ucase(session.username)#' and
				upper(username) in (
			        select distinct grantee
			        from dba_role_privs
			        where granted_role in (
			                select c.portal_name
			                from dba_role_privs d, cf_collection c
			                where d.granted_role = c.portal_name
			                and d.grantee = '#ucase(session.username)#')
			        and grantee in (
			                select grantee
			                from dba_role_privs
			                where granted_role = 'DATA_ENTRY')
			)
			group by username
			order by username
		</cfquery>
		<form name="d" method="post" action="BulkloadOtherId.cfm">
			<input type="hidden" name="action" value="saveClaimed">
			<table border id="t" class="sortable">
				<tr>
					<th>Claim</th>
					<th>User</th>
					<th>Count</th>
				</tr>
				<cfloop query="d">
					<tr>
						<td><input type="checkbox" name="username" value="#username#"></td>
						<td>#username#</td>
						<td>#c#</td>
					</tr>
				</cfloop>
			</table>
			<br>
			<input type="submit" value="Claim all checked records for checked users">
		</form>
	</cfoutput>
</cfif>

<!------------------------------------------------------------------------------------------------>
<cfif action is "saveClaimed">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_oids set username='#ucase(session.username)#' where upper(username) in (#listqualify(ucase(username),"'")#)
	</cfquery>
	<cflocation url="BulkloadOtherId.cfm?action=managemystuff" addtoken="false">
</cfif>
<!---------------------------------------------------------------------------->
<cfif action is "deleteChecked">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from cf_temp_oids where upper(username)='#ucase(session.username)#' and key in (#key#)
	</cfquery>
	<cflocation url="BulkloadOtherId.cfm?action=managemystuff" addtoken="false">
</cfif>
<!---------------------------------------------------------------------------->
<cfif action is "getCSV">
	<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_oids where upper(username)='#ucase(session.username)#'
	</cfquery>
	<cfset  util = CreateObject("component","component.utilities")>
	<cfset csv = util.QueryToCSV2(Query=mine,Fields=mine.columnlist)>
	<cffile action = "write"
	    file = "#Application.webDirectory#/download/BulkloadOherIDData.csv"
    	output = "#csv#"
    	addNewLine = "no">
	<cflocation url="/download.cfm?file=BulkloadOherIDData.csv" addtoken="false">
</cfif>
<!------------------------------------------------------->
<cfif action is "deleteLocalDuplicate">
	<cfoutput>
		<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from
				cf_temp_oids
			where
				upper(username)='#ucase(session.username)#' and
				status like '%local duplicate%' and
				key in (
					select
						key
					from
						cf_temp_oids a
					where
						rowid > (
							select
								min(rowid)
							from
								cf_temp_oids b
							where
								a.guid_prefix = b.guid_prefix and
								a.new_other_id_type = b.new_other_id_type and
								a.new_other_id_number = b.new_other_id_number and
								nvl(a.new_other_id_references,'self') = nvl(b.new_other_id_references,'self') and
								a.existing_other_id_type = b.existing_other_id_type and
								a.existing_other_id_number = b.existing_other_id_number
							)
						)
		</cfquery>
		<cflocation url="BulkloadOtherId.cfm?action=managemystuff" addtoken="false">
	</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "deleteAlreadyExists">
	<cfoutput>
		<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from cf_temp_oids where  upper(username)='#ucase(session.username)#' and status like '%identifier exists%'
		</cfquery>
		<cflocation url="BulkloadOtherId.cfm?action=managemystuff" addtoken="false">
	</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "deleteMine">
	<cfoutput>
		<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from cf_temp_oids where upper(username)='#ucase(session.username)#'
		</cfquery>
		<cflocation url="BulkloadOtherId.cfm?action=managemystuff" addtoken="false">
	</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "loadData">
	<cfoutput>
		<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_temp_oids where status='valid' and upper(username)='#ucase(session.username)#'
		</cfquery>
		<cftransaction>
			<cfloop query="getTempData">
				loading #collection_object_id#<br>
				<!---<cfquery name="newID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				 	{EXEC parse_other_id(#collection_object_id#, '#new_other_id_number#', '#new_other_id_type#')}
				</cfquery>
				--->
				<cfstoredproc procedure="parse_other_id" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				    <cfprocparam cfsqltype="cf_sql_numeric" value="#collection_object_id#">
				    <cfprocparam cfsqltype="cf_sql_varchar" value="#new_other_id_number#">
					<cfprocparam cfsqltype="cf_sql_varchar" value="#new_other_id_type#">
					<cfprocparam cfsqltype="cf_sql_varchar" value="#new_other_id_references#">
				</cfstoredproc>
			</cfloop>
			<cfquery name="deleteMine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				delete from cf_temp_oids where status='valid' and upper(username)='#ucase(session.username)#'
			</cfquery>
		</cftransaction>
		Spiffy, all done. <a href="BulkloadOtherId.cfm?action=managemystuff">managemystuff</a>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">