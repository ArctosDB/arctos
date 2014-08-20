<cfsetting requesttimeout="600">

<cfinclude template="/includes/_header.cfm">

<cfset title="bulkload identifiers">

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


------>
<cfif action is "template">
	<cfoutput>
		<cfset d="GUID_PREFIX,EXISTING_OTHER_ID_TYPE,EXISTING_OTHER_ID_NUMBER,NEW_OTHER_ID_TYPE,NEW_OTHER_ID_NUMBER,NEW_OTHER_ID_REFERENCES">
		<cfset variables.encoding="UTF-8">
		<cfset variables.fileName="#Application.webDirectory#/download/BulkloadOtherId.csv">
		<cfscript>
			variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
			variables.joFileWriter.writeLine(d);
			variables.joFileWriter.close();
		</cfscript>
		<cflocation url="/download.cfm?file=BulkloadOtherId.csv" addtoken="false">
		<a href="/download/BulkloadOtherId.csv">Click here if your file does not automatically download.</a>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------->
<cfif action is "nothing">
	<p>
		<a href="BulkloadOtherId.cfm?action=managemystuff">Manage existing and reciprocal records</a>
	</p>
	Upload a comma-delimited text file (csv).
	<p><a href="BulkloadOtherId.cfm?action=template">get a template here</a>
	
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
	<cfform name="oids" method="post" enctype="multipart/form-data">
		<input type="hidden" name="Action" value="getFile">
		<label for="">upload CSV</label>
		<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file">
	</cfform>
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
<cfif action is "validate">
<cfoutput>


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
		Filter
		<form name="filter" method="post" action="BulkloadOtherId.cfm">
			<input type="hidden" name="action" value="getRecip">
			<label for="gp">guid_prefix</label>
			<select name="gp" multiple>
				<option value="">no filter</option>
				<cfloop query="ctguid_prefix">
					<option <cfif listcontains(gp,ctguid_prefix.guid_prefix)> selected="selected" </cfif>value="#ctguid_prefix.guid_prefix#">#ctguid_prefix.guid_prefix#</option>
				</cfloop>
			</select>
			<label for="ref">references</label>
			<select name="ref" multiple>
				<option value="">no filter</option>
				<cfloop query="ctref">
					<option <cfif listcontains(ref,ctref.new_other_id_references)> selected="selected" </cfif>value="#ctref.new_other_id_references#">#ctref.new_other_id_references#</option>
				</cfloop>
			</select>
			<br><input type="submit" value="filter">
		</form>
			
		<form name="f" method="post" action="BulkloadOtherId.cfm">
			<label for="">Select All</label>
			<input type="checkbox" id="selecctall">
			<input type="hidden" name="action" value="claimRecip">
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
			<input type="submit" value="claim checked records">
		</form>
	</cfoutput>
</cfif>
<!------------------------------------------------------->

<cfif action is "claimRecip">
<cfoutput>
	<p>
		Seeing UAM.IX_UCF_TEMP_OIDS_KEY errors? You're tryin to pull something that you've already pulled.
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

<!------------------------------------------------------->
<cfif action is "managemystuff">
	<script src="/includes/sorttable.js"></script>

	<cfoutput>

		<div class="ui-state-highlight ui-corner-all">
			<p><strong>READ THIS!</strong></p>
			This form creates otherIDs, and pulls suggested reciprocal relationships which may be created as IDs. 
			<p>
				Always download a CSV backup before using local tools.
			</p>
		</div>
		<cfquery name="recip" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select collection.collection,collection.collection_id, count(*) from 
			cf_temp_recip_oids,
			collection
			where cf_temp_recip_oids.collection_id=collection.collection_id and collection.collection_id in (
			select collection_id from cataloged_item) group by collection.collection,collection.collection_id order by collection.collection
		</cfquery>
		<cfif recip.recordcount gt 0>
			<p>
				Reciprocal relationships for your collection(s) have been detected. <a href="BulkloadOtherId.cfm?action=getRecip">check them here</a>
			</p>
		</cfif>
	
		<cfquery name="raw" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_temp_oids where upper(username)='#ucase(session.username)#'
		</cfquery>
		<cfquery name="data" dbtype="query">
			select * from raw  where status is not null
		</cfquery>			
		<cfif data.recordcount gt 0>
			<p><a href="BulkloadOtherId.cfm?action=validate">validate</a></p>
			<cfset d="status,guid_prefix,EXISTING_OTHER_ID_TYPE,EXISTING_OTHER_ID_NUMBER,NEW_OTHER_ID_TYPE,NEW_OTHER_ID_NUMBER,NEW_OTHER_ID_REFERENCES">
			<cfset variables.encoding="UTF-8">
			<cfset variables.fileName="#Application.webDirectory#/download/BulkloadOtherId_down.csv">
			<cfscript>
				variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
				variables.joFileWriter.writeLine(d);
			</cfscript>
			<cfloop query="raw">
				<cfset d='"#status#","#guid_prefix#","#EXISTING_OTHER_ID_TYPE#","#EXISTING_OTHER_ID_NUMBER#","#NEW_OTHER_ID_TYPE#","#NEW_OTHER_ID_NUMBER#","#NEW_OTHER_ID_REFERENCES#"'>
				<cfscript>
					variables.joFileWriter.writeLine(d);
				</cfscript>
			</cfloop>
			<cfscript>
				variables.joFileWriter.close();
			</cfscript>
			<p><a href="/download.cfm?file=BulkloadOtherId_down.csv">CSV</a> (delete status column to re-load)</p>
			<p><a href="BulkloadOtherId.cfm?action=deleteAlreadyExists">Delete "identifier exists" records</a></p>
			<p><a href="BulkloadOtherId.cfm?action=deleteLocalDuplicate">Merge "local duplicate" records</a></p>
				
		<cfelse>
			<a href="BulkloadOtherId.cfm?action=loadData">checks out...proceed to load #raw.recordcount# new IDs</a>
		</cfif>
		
		<table border id="t" class="sortable">
			<tr>
				<th>status</th>
				<th>guid_prefix</th>
				<th>existing_other_id_type</th>
				<th>existing_other_id_number</th>
				<th>new_other_id_references</th>
				<th>new_other_id_type</th>
				<th>new_other_id_number</th>
			</tr>			
			<cfloop query="raw">
				<tr>
					<td>#status#</td>
					<td>#guid_prefix#</td>
					<td>#existing_other_id_type#</td>
					<td>#existing_other_id_number#</td>
					<td>#new_other_id_references#</td>
					<td>#new_other_id_type#</td>
					<td>#new_other_id_number#</td>
				</tr>
			</cfloop>
		</table>		
	</cfoutput>
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
		</cftransaction>
		Spiffy, all done.
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">