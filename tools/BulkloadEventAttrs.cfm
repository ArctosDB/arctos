

<!---- relies on table


drop table cf_temp_event_attrs;

CREATE TABLE cf_temp_event_attrs (
	KEY  NUMBER NOT NULL,
	STATUS VARCHAR2(4000),
	username VARCHAR2(255),
	collection_object_id NUMBER,
	collecting_event_id number,
	determined_by_agent_id number,
	guid VARCHAR2(60),
	event_name VARCHAR2(60),
 	event_attribute_type VARCHAR2(60),
 	event_attribute_value VARCHAR2(4000),
	event_attribute_units VARCHAR2(60),
	event_attribute_remark VARCHAR2(4000),
	event_determination_method VARCHAR2(4000),
	event_determined_date VARCHAR2(60),
	event_determiner VARCHAR2(60)
);




CREATE OR REPLACE TRIGGER trg_cf_temp_event_attrs before insert ON cf_temp_event_attrs for each row
    begin
    	:new.username:=sys_context('USERENV', 'SESSION_USER');
	    if :NEW.key is null then
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;
    end;
/

create or replace public synonym cf_temp_event_attrs for cf_temp_event_attrs;
grant all on cf_temp_event_attrs to manage_collection;

---->
<cfinclude template="/includes/_header.cfm">


<cfset title="Bulkload Event Attributes">



<!------------------------------------------------------->
<cfif action is "template">
	<cfoutput>
		<cfset d="guid,event_name,event_attribute_type,event_attribute_value,event_attribute_units,event_attribute_remark,event_determination_method,event_determined_date,event_determiner">
		<cffile action = "write"
		    file = "#Application.webDirectory#/download/BulkloadEventAttrs.csv"
		   	output = "#d#"
		   	addNewLine = "no">
		<cflocation url="/download.cfm?file=BulkloadEventAttrs.csv" addtoken="false">
		<a href="/download/BulkloadEventAttrs.csv">Click here if your file does not automatically download.</a>
	</cfoutput>
</cfif>

<!----------------------------------------->
<cfif action is "nothing">

	<cfoutput>
		<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_temp_event_attrs where upper(username)='#ucase(session.username)#'
		</cfquery>
		<p>
			<a href="BulkloadEventAttrs.cfm?action=managemystuff">Manage your existing #mine.recordcount# records</a>
		</p>
	</cfoutput>


CREATE TABLE cf_temp_event_attrs (
	KEY  NUMBER NOT NULL,
	STATUS VARCHAR2(4000),
	username VARCHAR2(255),
	collection_object_id NUMBER,
	collecting_event_id number,
	determined_by_agent_id number,
	 VARCHAR2(60),
 	 VARCHAR2(60),
 	 VARCHAR2(4000),
	 VARCHAR2(60),
	 VARCHAR2(4000),
	 VARCHAR2(4000),
	 VARCHAR2(60),
	 VARCHAR2(60)
);




	Step 1: Upload a comma-delimited text file including column headings. (<a href="BulkloadEventAttrs.cfm?action=template">download BulkloadEventAttrs.csv template</a>)
	<table border>
		<tr>
			<th>Column</th>
			<th>Required?</th>
			<th>Description</th>
			<th>Links</th>
		</tr>
		<tr>
			<td>guid</td>
			<td>conditionally</td>
			<td>You must provide specimen GUID _or_ event_name. You may not provide both, and you must be consistent throughout a single load.</td>
			<td></td>
		</tr>
		<tr>
			<td>event_name</td>
			<td>conditionally</td>
			<td>You must provide specimen GUID _or_ event_name. You may not provide both, and you must be consistent throughout a single load.</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTCOLL_OTHER_ID_TYPE">CTCOLL_OTHER_ID_TYPE</a></td>
		</tr>
		<tr>
			<td>event_attribute_type</td>
			<td>yes</td>
			<td>event_attribute_type</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTCOLL_EVENT_ATTR_TYPE">CTCOLL_EVENT_ATTR_TYPE</a></td>
		</tr>
		<tr>
			<td>event_attribute_value</td>
			<td>yes</td>
			<td>Some are controlled - follow the links in the code-table-code-table</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTCOLL_EVENT_ATT_ATT">CTCOLL_EVENT_ATT_ATT</a></td>
		</tr>
		<tr>
			<td>event_attribute_units</td>
			<td>conditionally</td>
			<td>Follow the links in the code-table-code-table</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTCOLL_EVENT_ATT_ATT">CTCOLL_EVENT_ATT_ATT</a></td>
		</tr>
		<tr>
			<td>event_attribute_remark</td>
			<td>no</td>
			<td></td>
			<td></td>
		</tr>
		<tr>
			<td>event_determination_method</td>
			<td>no</td>
			<td></td>
			<td></td>
		</tr>
		<tr>
			<td>event_determined_date</td>
			<td>no</td>
			<td>ISO8601</td>
			<td></td>
		</tr>

		<tr>
			<td>event_determiner</td>
			<td>no</td>
			<td>unique agent name</td>
			<td></td>
		</tr>
	</table>

	<div class="importantNotification">
	   This form will happily create duplicates. Make sure you aren't creating duplicates.
	</div>

	<cfform name="atts" method="post" enctype="multipart/form-data" action="BulkloadEventAttrs.cfm">
		<input type="hidden" name="action" value="getFile">
		<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" class="savBtn">
	</cfform>
</cfif>


<!------------------------------------------------------->
<cfif action is "getCSV">
	<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_event_attrs where upper(username)='#ucase(session.username)#'
	</cfquery>
	<cfset  util = CreateObject("component","component.utilities")>
	<cfset csv = util.QueryToCSV2(Query=mine,Fields=mine.columnlist)>
	<cffile action = "write"
	    file = "#Application.webDirectory#/download/BulkloadEventAttrsData.csv"
    	output = "#csv#"
    	addNewLine = "no">
	<cflocation url="/download.cfm?file=BulkloadEventAttrsData.csv" addtoken="false">
</cfif>
<!------------------------------------------------------->
<cfif action is "getFile">
<cfoutput>

	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	<cfset fileContent=replace(fileContent,"'","''","all")>
	<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />
	<cfset colNames="">
	<cfloop from="1" to ="#ArrayLen(arrResult)#" index="o">
		<cfset colVals="">
			<cfloop from="1"  to ="#ArrayLen(arrResult[o])#" index="i">
				<cfset thisBit=arrResult[o][i]>
				<cfif o is 1>
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
				insert into cf_temp_event_attrs (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>
	<cflocation url="BulkloadEventAttrs.cfm?action=managemystuff" addtoken="false">
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------>
<cfif action is "deleteMine">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from cf_temp_parts  where upper(username)='#ucase(session.username)#'
	</cfquery>
	<cflocation url="BulkloadEventAttrs.cfm" addtoken="false">
</cfif>
<!---------------------------------------------------------------------------->
<cfif action is "managemystuff">
	<script src="/includes/sorttable.js"></script>
	<cfoutput>
		<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_temp_event_attrs where upper(username)='#ucase(session.username)#'
		</cfquery>



		<!----
		<cfset clist=mine.columnlist>
		<cfset clist=listdeleteat(clist,listfind(clist,'STATUS'))>
		<cfset clist=listdeleteat(clist,listfind(clist,'KEY'))>
		----->


		<p>
			You have #mine.recordcount# records in the staging table.
		</p>
		<p>
			<a href="BulkloadEventAttrs.cfm">Load more records</a>
		</p>
		<p>
			<a href="BulkloadEventAttrs.cfm?action=validate">validate records</a>
		</p>

		<p>
			<a href="BulkloadEventAttrs.cfm?action=deleteMine">delete all of your data from the staging table</a>
		</p>
		<p>
			<a href="BulkloadEventAttrs.cfm?action=getCSV">Download as CSV</a>
		</p>
		<cfquery name="willload" dbtype="query">
			select count(*) c from mine where status = 'valid'
		</cfquery>
		<cfif willload.c eq mine.recordcount>
			<p>
				The data should load. Check them one more time, then <a href="BulkloadEventAttrs.cfm?action=loadToDb">proceed to load</a>
			</p>
		<cfelse>
			<p>
				Load isn't available until all records validate.
			</p>

		</cfif>

		<cfdump var=#mine#>

	</cfoutput>
</cfif>



<!------------------------------------------------------->
<cfif action is "validate">
<cfoutput>
	<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update
				cf_temp_parts
			set
				status = NULL
			where
				status != 'loaded' and
				upper(username)='#ucase(session.username)#'
		</cfquery>

	<cfquery name="getParentContainerId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update
			cf_temp_parts
		set
			parent_container_id = (select container_id from container where container.barcode = cf_temp_parts.CONTAINER_BARCODE)
		where
			upper(username)='#ucase(session.username)#' and
			CONTAINER_BARCODE is not null
	</cfquery>


	<cfquery name="validateGotParent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update
			cf_temp_parts
		set
			status = status || ';Container Barcode not found'
		where
			CONTAINER_BARCODE is not null and
			parent_container_id is null and
			upper(username)='#ucase(session.username)#'
	</cfquery>
	<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update
			cf_temp_parts
		set
			status = status || ';Invalid part_name'
		where
			upper(username)='#ucase(session.username)#' and
		 	part_name NOT IN (
        	select part_name from ctspecimen_part_name where collection_cde=(select collection_cde from collection where guid_prefix=cf_temp_parts.guid_prefix))
	</cfquery>
	<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update
			cf_temp_parts
		set
			status = status || ';Invalid container_barcode'
		where
			container_barcode NOT IN (
				select barcode from container where barcode is not null
			)
		AND container_barcode is not null and
		upper(username)='#ucase(session.username)#'
	</cfquery>
	<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update
			cf_temp_parts
		set
			status = status || ';Invalid DISPOSITION'
		where
			DISPOSITION NOT IN (select COLL_OBJ_DISPOSITION from CTCOLL_OBJ_DISP) and
			upper(username)='#ucase(session.username)#'
	</cfquery>
	<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update
			cf_temp_parts
		set
			status = status || ';Invalid CONTAINER_TYPE'
		where
			change_container_type NOT IN (select container_type from ctcontainer_type) AND
			change_container_type is not null and
			upper(username)='#ucase(session.username)#'
	</cfquery>

	<!----
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_parts where status is null and
			upper(username)='#ucase(session.username)#'
	</cfquery>
	---->

	<!--- get things that don't resolve to single specimens ---->
	<cfquery name="collObjFail1" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update
			cf_temp_parts
		set
			status='ambiguous_specimen_reference'
		where
			key in (
			    select key
			     from
			        cf_temp_parts,
			        cataloged_item,
			        collection,
			        coll_obj_other_id_num
			      WHERE
			        cataloged_item.collection_id = collection.collection_id and
			        cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id and
			        collection.guid_prefix = cf_temp_parts.guid_prefix and
			        coll_obj_other_id_num.other_id_type = cf_temp_parts.other_id_type and
			        coll_obj_other_id_num.display_value = cf_temp_parts.other_id_number and
			        cf_temp_parts.other_id_type != 'catalog number' and
					upper(username)='#ucase(session.username)#' and
					status is null
			      having
			      	count(*) > 1
			      group by
			      	key
			    )
	</cfquery>


	<cfquery name="collObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_parts set COLLECTION_OBJECT_ID = (
			select
				cataloged_item.collection_object_id
			from
				cataloged_item,
				collection
			WHERE
				cataloged_item.collection_id = collection.collection_id and
				collection.guid_prefix = cf_temp_parts.guid_prefix and
				cat_num=cf_temp_parts.other_id_number
		) where
			other_id_type = 'catalog number' and
			upper(username)='#ucase(session.username)#' and
			status is null
	</cfquery>
	<cfquery name="collObj_nci" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_parts set COLLECTION_OBJECT_ID = (
			select
				cataloged_item.collection_object_id
			from
				cataloged_item,
				collection,
				coll_obj_other_id_num
			WHERE
				cataloged_item.collection_id = collection.collection_id and
				cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id and
				collection.guid_prefix = cf_temp_parts.guid_prefix and
				coll_obj_other_id_num.other_id_type = cf_temp_parts.other_id_type and
				coll_obj_other_id_num.display_value = cf_temp_parts.other_id_number
		) where
			other_id_type != 'catalog number' and
			upper(username)='#ucase(session.username)#' and
			status is null
	</cfquery>

	<cfquery name="collObj_nci" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_parts set status = status || ';Invalid cataloged item'
		where collection_object_id is null and
			upper(username)='#ucase(session.username)#'
	</cfquery>
	<!---
		"not containers" are:
			0: CONTAINER ZERO
			476089: UAM PARENTLESS VOID
			397630: MVZ PARENTLESS VOID
	---->
	<cfquery name="hasDupParts" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_parts set status = status || ';duplicate parts detected'
		where key in (
			select key from (
				select
				  specimen_part.part_name,
				  cf_temp_parts.key
				from
				  cf_temp_parts,
				  specimen_part,
				  coll_obj_cont_hist,
				  container
				where
				  specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
				  coll_obj_cont_hist.container_id=container.container_id and
				  container.parent_container_id in (0,476089,397630) and
				  specimen_part.derived_from_cat_item=cf_temp_parts.collection_object_id and
				  specimen_part.part_name=cf_temp_parts.part_name and
				  upper(cf_temp_parts.username)='#ucase(session.username)#' and
				  cf_temp_parts.collection_object_id is not null and
				  cf_temp_parts.USE_EXISTING=1 and
				  cf_temp_parts.status is null
				having count(*) > 1
				group by specimen_part.part_name,
				  cf_temp_parts.key
			)
		)
	</cfquery>
	<cfquery name="getExistingPart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update
			cf_temp_parts set USE_PART_ID = (
				select
					specimen_part.collection_object_id
				from
					specimen_part,
					coll_obj_cont_hist,
					container
				where
					specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
					coll_obj_cont_hist.container_id=container.container_id and
					container.parent_container_id in (0,476089,397630) and
					specimen_part.derived_from_cat_item=cf_temp_parts.collection_object_id and
					specimen_part.part_name=cf_temp_parts.part_name
			)
		where
			collection_object_id is not null and
			USE_EXISTING=1 and
			upper(username)='#ucase(session.username)#' and
			cf_temp_parts.status is null
	</cfquery>
	<cfquery name="getExistingPart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update
			cf_temp_parts set PARENT_CONTAINER_ID = (
				select
					container_id
				from
					container
				where
					barcode=cf_temp_parts.CONTAINER_BARCODE
				)
		where
			CONTAINER_BARCODE is not null and
			upper(username)='#ucase(session.username)#'
	</cfquery>

	<cfloop from="1" to="#numPartAttrs#" index="i">
		<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update
				cf_temp_parts
			set
				status = status || ';Invalid PART_ATTRIBUTE_TYPE_#i#'
			where
				upper(username)='#ucase(session.username)#' and
				PART_ATTRIBUTE_TYPE_#i# is not null and
			 	PART_ATTRIBUTE_TYPE_#i# NOT IN (select ATTRIBUTE_TYPE from CTSPECPART_ATTRIBUTE_TYPE)
		</cfquery>
		<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update
				cf_temp_parts
			set
				status = status || ';PART_ATTRIBUTE_VALUE_#i# is required when PART_ATTRIBUTE_TYPE_#i# is given'
			where
				upper(username)='#ucase(session.username)#' and
				PART_ATTRIBUTE_TYPE_#i# is not null and
			 	PART_ATTRIBUTE_VALUE_#i# is null
		</cfquery>
		<!--- units is not used at this point - add as necessary ---->
		<!---- there is no type/value/units relationship - add as necessary ---->

		<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update
				cf_temp_parts
			set
				status = status || ';PART_ATTRIBUTE_DATE_#i# is invalid'
			where
				upper(username)='#ucase(session.username)#' and
				PART_ATTRIBUTE_TYPE_#i# is not null and
			 	PART_ATTRIBUTE_DATE_#i# is not null and (
			 		is_iso8601(PART_ATTRIBUTE_DATE_#i#) != 'valid' or
			 		length(PART_ATTRIBUTE_DATE_#i#)!=10
			 	)
		</cfquery>
		<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update
				cf_temp_parts
			set
				status = status || ';PART_ATTRIBUTE_DETERMINER_#i# is invalid'
			where
				upper(username)='#ucase(session.username)#' and
				PART_ATTRIBUTE_TYPE_#i# is not null and
			 	PART_ATTRIBUTE_DETERMINER_#i# is not null and
			 	getAgentId(PART_ATTRIBUTE_DETERMINER_#i#) is null
		</cfquery>
	</cfloop>
	<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update
				cf_temp_parts
			set
				status = 'valid'
			where
				upper(username)='#ucase(session.username)#' and
				status is null
		</cfquery>

		<cflocation url="BulkloadParts.cfm?action=manageMyStuff" addtoken="false">

		<!----
		---->
</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------------------->
<cfif action is "loadToDb">
<cfoutput>

	<p>
		Timeout errors? Just reload....
	</p>
	<cfflush>


	<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_parts where upper(username)='#ucase(session.username)#' and status='valid'
	</cfquery>

	<!----
		OPTIONS;
			1) came in WITHOUT use_part_id and WITH parent_container_id:
				create a part and put it in a container
			2) came in WITH use_part_id and WITH parent_container_id:
				move an existing part
			3) came in WITHOUT use_part_id and WITHOUT parent_container_id:
				create a part, no containers
			4) something else
				abort




		Big load? Use this:




	---->
		<cfloop query="getTempData">
		<cftransaction>
			<cfif len(use_part_id) is 0 AND len(parent_container_id) gt 0><!--- 1 ---->
				<!--- new part, add container --->
				<cfquery name="NEXTID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select sq_collection_object_id.nextval NEXTID from dual
				</cfquery>
				<cfset thisPartID=NEXTID.NEXTID>
				<cfquery name="updateColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					INSERT INTO coll_object (
						COLLECTION_OBJECT_ID,
						COLL_OBJECT_TYPE,
						ENTERED_PERSON_ID,
						COLL_OBJECT_ENTERED_DATE,
						LAST_EDITED_PERSON_ID,
						COLL_OBJ_DISPOSITION,
						LOT_COUNT,
						CONDITION,
						FLAGS )
					VALUES (
						#thisPartID#,
						'SP',
						#session.myagentid#,
						sysdate,
						#session.myagentid#,
						'#DISPOSITION#',
						#lot_count#,
						'#condition#',
						0 )
				</cfquery>
				<cfquery name="newTiss" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					INSERT INTO specimen_part (
						COLLECTION_OBJECT_ID,
						PART_NAME,
						DERIVED_FROM_cat_item
					) VALUES (
						#thisPartID#,
						'#PART_NAME#',
						#collection_object_id#
					)
				</cfquery>
				<cfif len(remarks) gt 0>
					<!---- new remark --->
					<cfquery name="newCollRem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						INSERT INTO coll_object_remark (collection_object_id, coll_object_remarks)
						VALUES (#thisPartID#, '#remarks#')
					</cfquery>
				</cfif>
				<!--- only got here if we have a container ---->
				<cfstoredproc procedure="movePartToContainer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					<cfprocparam cfsqltype="CF_SQL_FLOAT" value="#thisPartId#"><!---- v_collection_object_id ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value=""><!---- v_barcode ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#parent_container_id#"><!---- v_container_id ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#change_container_type#"><!---- v_parent_container_type ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#change_container_label#"><!---- v_parent_container_label ---->
				</cfstoredproc>


			<!----
				<cfquery name="part_container_id" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select
						container_id
					from
						coll_obj_cont_hist
					where
						collection_object_id = #thisPartID#
				</cfquery>
				<cfquery name="upPart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update container set parent_container_id=#parent_container_id#
					where container_id = #part_container_id.container_id#
				</cfquery>
				<cfif len(change_container_type) gt 0>
					<cfquery name="upPart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						update container set
						container_type='#change_container_type#'
						where container_id=#parent_container_id#
					</cfquery>
				</cfif>
				---->
			<cfelseif len(parent_container_id) gt 0 and len(use_part_id) gt 0> <!---- 2 ----->
			<!--- there is an existing matching container that is not in a parent_container;
				all we need to do is move the container to a parent IF it exists and is specified, or nothing otherwise --->
				<cfset thisPartID=use_part_id>
				<cfstoredproc procedure="movePartToContainer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					<cfprocparam cfsqltype="CF_SQL_FLOAT" value="#thisPartId#"><!---- v_collection_object_id ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value=""><!---- v_barcode ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#parent_container_id#"><!---- v_container_id ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value=""><!---- v_parent_container_type ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#change_container_label#"><!---- v_parent_container_label ---->
				</cfstoredproc>
				<!----
				<cfquery name="upPart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update
						container
					set
						parent_container_id=#parent_container_id#
					where
						container_id = (select container_id from coll_obj_cont_hist where collection_object_id = #thisPartID#)
				</cfquery>
				---->
			<cfelseif len(parent_container_id) is 0 and len(use_part_id) is 0><!--- 3 ---->
				<!--- new part, no container --->
				<cfquery name="NEXTID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select sq_collection_object_id.nextval NEXTID from dual
				</cfquery>
				<cfset thisPartID=NEXTID.NEXTID>
				<cfquery name="updateColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					INSERT INTO coll_object (
						COLLECTION_OBJECT_ID,
						COLL_OBJECT_TYPE,
						ENTERED_PERSON_ID,
						COLL_OBJECT_ENTERED_DATE,
						LAST_EDITED_PERSON_ID,
						COLL_OBJ_DISPOSITION,
						LOT_COUNT,
						CONDITION,
						FLAGS )
					VALUES (
						#thisPartID#,
						'SP',
						#session.myagentid#,
						sysdate,
						#session.myagentid#,
						'#DISPOSITION#',
						#lot_count#,
						'#condition#',
						0 )
				</cfquery>
				<cfquery name="newTiss" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					INSERT INTO specimen_part (
						COLLECTION_OBJECT_ID,
						PART_NAME,
						DERIVED_FROM_cat_item
					) VALUES (
						#thisPartID#,
						'#PART_NAME#',
						#collection_object_id#
					)
				</cfquery>
				<cfif len(remarks) gt 0>
					<!---- new remark --->
					<cfquery name="newCollRem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						INSERT INTO coll_object_remark (collection_object_id, coll_object_remarks)
						VALUES (#thisPartID#, '#remarks#')
					</cfquery>
				</cfif>
			<cfelse>
				oops - no handler for that combination!
				<cfabort>
			</cfif>
			<cfloop from="1" to="#numPartAttrs#" index="i">
				<cfset thisAttr=evaluate("PART_ATTRIBUTE_TYPE_" & i)>
				<cfif len(thisAttr) gt 0>
					<cfset thisAttrVal=evaluate("PART_ATTRIBUTE_VALUE_" & i)>
					<cfset thisAttrUnit=evaluate("PART_ATTRIBUTE_UNITS_" & i)>
					<cfset thisAttrDate=evaluate("PART_ATTRIBUTE_DATE_" & i)>
					<cfset thisAttrDetr=evaluate("PART_ATTRIBUTE_DETERMINER_" & i)>
					<cfset thisAttrRem=evaluate("PART_ATTRIBUTE_REMARK_" & i)>
					<cfquery name="nattr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					 	insert into specimen_part_attribute (
					 		PART_ATTRIBUTE_ID,
					 		COLLECTION_OBJECT_ID,
					 		ATTRIBUTE_TYPE ,
					 		ATTRIBUTE_VALUE,
					 		ATTRIBUTE_UNITS,
					 		DETERMINED_DATE,
					 		DETERMINED_BY_AGENT_ID,
					 		ATTRIBUTE_REMARK
					 	) values (
					 		sq_PART_ATTRIBUTE_ID.nextval,
					 		#thisPartID#,
					 		'#thisAttr#',
					 		'#thisAttrVal#',
					 		'#thisAttrUnit#',
					 		<cfif len(thisAttrDate) gt 0>
					 			'#dateformat(thisAttrDate,'YYYY-MM-DD')#',
					 		<cfelse>
					 			NULL,
					 		</cfif>
					 		<cfif len(thisAttrDetr) gt 0>
					 			getAgentID('#thisAttrDetr#'),
					 		<cfelse>
					 			NULL,
					 		</cfif>
					 		'#escapeQuotes(thisAttrRem)#'
					 	)
					</cfquery>
				</cfif>

				<cfquery name="cleanup" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update cf_temp_parts set status='loaded' where key=#key#
				</cfquery>


			</cfloop>

			</cftransaction>
		</cfloop>
		<!--- clean up ---->


	Spiffy, all done.
	<a href="/SpecimenResults.cfm?collection_object_id=#valuelist(getTempData.collection_object_id)#">
		See in Specimen Results
	</a>

	<p>

	<a href="BulkloadParts.cfm?action=deletemyloaded">
		clean up the stuff that just loaded
	</a>


	</p>
</cfoutput>
</cfif>
<cfif action is "deletemyloaded">
	<cfquery name="cleanup" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from cf_temp_parts where  status='loaded' and upper(username)='#ucase(session.username)#'
	</cfquery>
</cfif>
<cfinclude template="/includes/_footer.cfm">