

<!---- relies on table


SEE MIGRATION/6.4



drop table cf_temp_parts;

CREATE TABLE cf_temp_parts (
	KEY  NUMBER NOT NULL,
	collection_object_id NUMBER,
	institution_acronym VARCHAR2(60),
	collection_cde VARCHAR2(60),
	OTHER_ID_TYPE VARCHAR2(60),
 	OTHER_ID_NUMBER VARCHAR2(60),
 	part_name VARCHAR2(60),
	part_modifier VARCHAR2(60),
	preserve_method VARCHAR2(60),
	disposition VARCHAR2(60),
	condition VARCHAR2(60),
	lot_count VARCHAR2(60),
	remarks VARCHAR2(60),
	use_existing varchar2(1),
	container_barcode varchar2(255),
	validated_status varchar2(255),
	parent_container_id number,
	use_part_id number,
	change_container_type varchar2(255)
);

alter table cf_temp_parts modify part_name varchar2(255);
alter table cf_temp_parts drop column part_modifier;
alter table cf_temp_parts drop column preserve_method;



alter table cf_temp_parts rename column collection_cde to guid_prefix;

create or replace public synonym cf_temp_parts for cf_temp_parts;
grant all on cf_temp_parts to uam_query,uam_update;

---->
<cfinclude template="/includes/_header.cfm">


<cfset title="Bulkload Parts">



<cfset numPartAttrs=6>
<!------------------------------------------------------->
<cfif action is "template">
	<cfoutput>
		<cfset d="guid_prefix,other_id_type,other_id_number,part_name,condition,disposition,lot_count,remarks,use_existing,container_barcode">
		<cfloop from="1" to="#numPartAttrs#" index="i">
			<cfset d=d & ",PART_ATTRIBUTE_TYPE_#i#,PART_ATTRIBUTE_VALUE_#i#,PART_ATTRIBUTE_UNITS_#i#,PART_ATTRIBUTE_DATE_#i#,PART_ATTRIBUTE_DETERMINER_#i#,PART_ATTRIBUTE_REMARK_#i#">
		</cfloop>
		<cffile action = "write"
		    file = "#Application.webDirectory#/download/BulkloadParts.csv"
		   	output = "#d#"
		   	addNewLine = "no">
		<cflocation url="/download.cfm?file=BulkloadParts.csv" addtoken="false">
		<a href="/download/BulkloadParts.csv">Click here if your file does not automatically download.</a>
	</cfoutput>
</cfif>

<!----------------------------------------->
<cfif action is "nothing">

	<cfoutput>
		<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_temp_parts where upper(username)='#ucase(session.username)#'
		</cfquery>
		<p>
			<a href="BulkloadParts.cfm?action=managemystuff">Manage your existing #mine.recordcount# records</a>
		</p>
	</cfoutput>



	This form will probably do something strange and mess up all your data. Try it out with a very small
	representative sample first.
	<p>
		You can use this form to:
		<ul>
			<li>Bulk-add parts to specimens</li>
			<li>Bulk-add parts to specimens, and put those new parts into containers</li>
			<li>
				Bulk-add parts only when they don't exist NOTE: You can only use existing parts when that part is not in a container. Use
				<a href="BulkloadPartContainer.cfm">BulkloadPartContainer</a> to move stuff around between containers.
			</li>
		</ul>
	</p>
	<p>
		You cannot use this form to:
		<ul>
			<li>Create subsamples</li>
			<li>Move existing parts between containers - use <a href="BulkloadPartContainer.cfm">BulkloadPartContainer</a> instead</li>
		</ul>
	</p>
	Step 1: Upload a comma-delimited text file including column headings. (<a href="BulkloadParts.cfm?action=template">download BulkloadParts.csv template</a>)
	<table border>
		<tr>
			<th>Column</th>
			<th>Required?</th>
			<th>Description</th>
			<th>Links</th>
		</tr>
		<tr>
			<td>guid_prefix</td>
			<td>yes</td>
			<td>UAM:Mamm - first two parts of tripartite GUID in specimen URL, or from manage collection</td>
			<td></td>
		</tr>
		<tr>
			<td>other_id_type</td>
			<td>yes</td>
			<td>Code table value or "catalog number" (given as integer)</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTCOLL_OTHER_ID_TYPE">CTCOLL_OTHER_ID_TYPE</a></td>
		</tr>
		<tr>
			<td>other_id_number</td>
			<td>yes</td>
			<td>value of identifier ("23")</td>
			<td></td>
		</tr>
		<tr>
			<td>part_name</td>
			<td>yes</td>
			<td>part to create</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTSPECIMEN_PART_NAME">CTSPECIMEN_PART_NAME</a></td>
		</tr>


		<tr>
			<td>condition</td>
			<td>yes</td>
			<td>part condition</td>
			<td></td>
		</tr>
		<tr>
			<td>disposition</td>
			<td>yes</td>
			<td>part disposition</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTCOLL_OBJ_DISP">CTCOLL_OBJ_DISP</a></td>
		</tr>
		<tr>
			<td>lot_count</td>
			<td>yes</td>
			<td>integer</td>
			<td></td>
		</tr>
		<tr>
			<td>remarks</td>
			<td>no</td>
			<td>part remarks</td>
			<td></td>
		</tr>
		<tr>
			<td>use_existing</td>
			<td>yes</td>
			<td>
				<ul>
					<li>0: create a new part regardless of current parts</li>
					<li>1: use existing parts when:
						<ul>
							<li>
								A part of the same type exists
							</li>
							<li>That part is not already in a container</li>
						</ul>
					</li>
				</ul>
			</td>
			<td></td>
		</tr>
		<tr>
			<td>container_barcode</td>
			<td>no</td>
			<td>Container barcode (eg, barcode on Nunc tube) in which to place this part</td>
			<td></td>
		</tr>
		<tr>
			<td>change_container_type</td>
			<td>no</td>
			<td>New type of container - change a "label" to a real container</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTCONTAINER_TYPE">CTCONTAINER_TYPE</a></td>
		</tr>
		<tr>
			<td>PART_ATTRIBUTE_TYPE_n</td>
			<td>no</td>
			<td>part attribute</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTSPECPART_ATTRIBUTE_TYPE">CTSPECPART_ATTRIBUTE_TYPE</a></td>
		</tr>
		<tr>
			<td>PART_ATTRIBUTE_VALUE_n</td>
			<td>if PART_ATTRIBUTE_TYPE_n is given</td>
			<td>value of part attribute</td>
			<td>various</td>
		</tr>
		<tr>
			<td>PART_ATTRIBUTE_UNITS_n</td>
			<td>for PART_ATTRIBUTE_TYPE_n types requiring units</td>
			<td>units of PART_ATTRIBUTE_TYPE_n</td>
			<td>various</td>
		</tr>
		<tr>
			<td>PART_ATTRIBUTE_DATE_n</td>
			<td>no</td>
			<td>date for PART_ATTRIBUTE_TYPE_n; day-date format only</td>
			<td></td>
		</tr>
		<tr>
			<td>PART_ATTRIBUTE_DETERMINER_n</td>
			<td>no</td>
			<td>determiner for PART_ATTRIBUTE_TYPE_n; agent_name</td>
			<td></td>
		</tr>
		<tr>
			<td>PART_ATTRIBUTE_REMARK_m</td>
			<td>no</td>
			<td>remark for PART_ATTRIBUTE_TYPE_n</td>
			<td></td>
		</tr>
	</table>

	<div class="importantNotification">
	   This form will happily create duplicates. Make sure you aren't loading duplicates.
	</div>

	<cfform name="atts" method="post" enctype="multipart/form-data" action="BulkloadParts.cfm">
		<input type="hidden" name="action" value="getFile">
		<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" class="savBtn">
	</cfform>
</cfif>
<!------------------------------------------------------->
<cfif action is "getCSV">
	<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_parts where upper(username)='#ucase(session.username)#'
	</cfquery>
	<cfset  util = CreateObject("component","component.utilities")>
	<cfset csv = util.QueryToCSV2(Query=mine,Fields=mine.columnlist)>
	<cffile action = "write"
	    file = "#Application.webDirectory#/download/BulkloadSpecimenPartData.csv"
    	output = "#csv#"
    	addNewLine = "no">
	<cflocation url="/download.cfm?file=BulkloadSpecimenPartData.csv" addtoken="false">
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
				insert into cf_temp_parts (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>
	<cflocation url="BulkloadParts.cfm?action=managemystuff" addtoken="false">
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "takeStudentRecords">
	<cfoutput>
		<a href="BulkloadSpecimenEvent.cfm?action=managemystuff">back to my stuff</a>
		<cfquery name="d" datasource="uam_god">
			select count(*) c,username from cf_temp_parts where upper(username) != '#ucase(session.username)#' and upper(username) in (
			select
				grantee
			from
				dba_role_privs
			where
				granted_role in (
	        		select
						c.portal_name
					from
						dba_role_privs d,
						cf_collection c
	        		where
						d.granted_role = c.portal_name
	        			and d.grantee = '#ucase(session.username)#'
				)
				and grantee in (select grantee from dba_role_privs where granted_role = 'DATA_ENTRY')
			) group by username order by username
		</cfquery>
		<form name="d" method="post" action="BulkloadParts.cfm">
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
		update cf_temp_parts set username='#session.username#' where username in (#listqualify(username,"'")#)
	</cfquery>
	<cflocation url="BulkloadParts.cfm?action=managemystuff" addtoken="false">
</cfif>
<!------------------------------------------------------------------------------------------------>
<cfif action is "deleteMine">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from cf_temp_parts  where upper(username)='#ucase(session.username)#'
	</cfquery>
	<cflocation url="BulkloadParts.cfm" addtoken="false">
</cfif>
<!---------------------------------------------------------------------------->
<cfif action is "getGuidUUID">
	<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select other_id_number from cf_temp_parts where upper(username)='#ucase(session.username)#' and guid_prefix is null
		and other_id_type='UUID' and other_id_number is not null
		group by other_id_number
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
				display_value='#other_id_number#'
		</cfquery>
		<cfif gg.recordcount is 1>
			<cfquery name="gg" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update cf_temp_parts set guid_prefix='#gg.guid_prefix#' where other_id_number='#other_id_number#'
			</cfquery>
		</cfif>
	</cfloop>
	<cflocation url="BulkloadParts.cfm?action=managemystuff" addtoken="false">
</cfif>
<!---------------------------------------------------------------------------->
<cfif action is "managemystuff">
	<script src="/includes/sorttable.js"></script>
	<cfoutput>
		<cfquery name="clist" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select column_name from user_tab_cols where table_name='CF_TEMP_PARTS' ORDER BY INTERNAL_COLUMN_ID
		</cfquery>

		<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_temp_parts where upper(username)='#ucase(session.username)#'
		</cfquery>


		<!----
		<cfset clist=mine.columnlist>
		<cfset clist=listdeleteat(clist,listfind(clist,'STATUS'))>
		<cfset clist=listdeleteat(clist,listfind(clist,'KEY'))>
		----->


        <cfquery name="dupc" dbtype="query">
		  select collection_object_id, count(collection_object_id) as c from mine where collection_object_id is not null group by collection_object_id
		</cfquery>
        <cfquery name="dupc2" dbtype="query">
		  select count(*) c from dupc where c > 1
		</cfquery>
		<p>
		   Caution: Duplicate existing data cannot be detected from here. This form will create duplicate parts.
          Make sure the data you are trying to load do not already exist.
		</p>
		<cfif dupc2.c gt 0>
		  <div class="importantNotification">
		       Potential duplicates detected. Sort by collection_object_id.
		    </div>
		</cfif>
		<p>
			You have #mine.recordcount# records in the staging table.
		</p>
		<p>
			<a href="BulkloadParts.cfm">Load more records</a>
		</p>
		<p>
			<a href="BulkloadParts.cfm?action=validate">validate records</a>
		</p>

		<cfquery name="nv" dbtype="query">
			select count(*) c from mine where guid_prefix is null and other_id_type='UUID'
		</cfquery>
		<cfif nv.c gt 0>
			<p>
				<a href="BulkloadParts.cfm?action=getGuidUUID">get guid_prefix from UUID</a>
			</p>
		</cfif>
		<cfif session.roles contains "manage_collection">
			<p>
				You have manage_collection, so you can "take" records from people in your collection.
				<br>NOT ALL OF THESE ARE NECESSARILY YOUR SPECIMENS!!
				<br>Use this with great caution. You may need to coordinate with other curatorial staff or involve a DBA.
				<a href="BulkloadParts.cfm?action=takeStudentRecords">Check for records entered by people in your collection(s)</a>
			</p>

		</cfif>
		<p>
			<a href="BulkloadParts.cfm?action=deleteMine">delete all of your data from the staging table</a>
		</p>
		<p>
			<a href="BulkloadParts.cfm?action=getCSV">Download as CSV</a>
		</p>
		<cfquery name="willload" dbtype="query">
			select count(*) c from mine where status = 'valid'
		</cfquery>
		<cfif willload.c eq mine.recordcount>
			<p>
				The data should load. Check them one more time, then <a href="BulkloadParts.cfm?action=loadToDb">proceed to load</a>
			</p>
		</cfif>
		<form name="d" method="post" action="BulkloadParts.cfm">
		<input type="hidden" name="action" value="deleteChecked">
		<table border id="t" class="sortable">
			<tr>
				<th>Delete</th>
				<th>Status</th>
				<cfloop query="clist">
					<th>#column_name#</th>
				</cfloop>
			</tr>
			<cfloop query="mine">
				<tr>
					<td><input type="checkbox" name="key" value="#key#"></td>
					<td>#status#</td>
					<cfloop query="clist">
						<cfset tval=evaluate("mine." & column_name)>
						<td>#tval#</td>
					</cfloop>
				</tr>
			</cfloop>
		</table>
		<br>
		<input type="submit" value="delete checked records">
		</form>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------>
<cfif action is "deleteChecked">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from cf_temp_parts  where key in (#listqualify(key,"'")#)
	</cfquery>
	<cflocation url="BulkloadParts.cfm?action=managemystuff" addtoken="false">
</cfif>
<!------------------------------------------------------->
<cfif action is "validate">
validate
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
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_parts where status is null and
			upper(username)='#ucase(session.username)#'
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
		) where other_id_type = 'catalog number'
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
		) where other_id_type != 'catalog number'
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
			upper(username)='#ucase(session.username)#'
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