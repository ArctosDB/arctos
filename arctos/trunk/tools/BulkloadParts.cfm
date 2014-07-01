
	
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


create or replace public synonym cf_temp_parts for cf_temp_parts;
grant all on cf_temp_parts to uam_query,uam_update;

---->
<cfinclude template="/includes/_header.cfm">






<cfset numPartAttrs=6>
<!------------------------------------------------------->
<cfif action is "template">
	<cfoutput>
		<cfset d="guid_prefix,other_id_type,other_id_number,part_name,disposition,lot_count,remarks,use_existing,container_barcode,condition">
		<cfloop from="1" to="#numPartAttrs#" index="i">
			<cfset d=d & ",PART_ATTRIBUTE_TYPE_#i#,PART_ATTRIBUTE_VALUE_#i#,PART_ATTRIBUTE_UNITS_#i#,PART_ATTRIBUTE_DATE_#i#,PART_ATTRIBUE_DETERMINER_#i#,PART_ATTRIBUE_REMARK_#i#">
		</cfloop>
		<cfset variables.encoding="UTF-8">
		<cfset variables.fileName="#Application.webDirectory#/download/BulkloadParts.csv">
		<cfscript>
			variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
			variables.joFileWriter.writeLine(d);
			variables.joFileWriter.close();
		</cfscript>
		<cflocation url="/download.cfm?file=BulkloadParts.csv" addtoken="false">
		<a href="/download/BulkloadParts.csv">Click here if your file does not automatically download.</a>
	</cfoutput>
</cfif>

<!----------------------------------------->
<cfif action is "nothing">
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
			<td>PART_ATTRIBUE_DETERMINER_n</td>
			<td>no</td>
			<td>determiner for PART_ATTRIBUTE_TYPE_n; agent_name</td>
			<td></td>
		</tr>
		<tr>
			<td>PART_ATTRIBUE_REMARK_m</td>
			<td>no</td>
			<td>remark for PART_ATTRIBUTE_TYPE_n</td>
			<td></td>
		</tr>
	</table>
	
	
			
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
	<cflocation url="BulkloadParts.cfm?action=managemystuff">
</cfoutput>
</cfif>


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

<cfif action is "managemystuff">
	<script src="/includes/sorttable.js"></script>
	<cfoutput>	
		<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_temp_parts where upper(username)='#ucase(session.username)#'
		</cfquery>
		<cfset clist=mine.columnlist>
		<cfset clist=listdeleteat(clist,listfind(clist,'STATUS'))>
		<cfset clist=listdeleteat(clist,listfind(clist,'KEY'))>
		<p>
			You have #mine.recordcount# records in the staging table.
		</p>
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
		<cfif willload.recordcount eq mine.recordcount>
			<p>
				The data should load. Check them one more time, then <a href="BulkloadParts.cfm?action=validateFromFile">proceed to load</a>
			</p>
		</cfif>
		<form name="d" method="post" action="BulkloadParts.cfm">
		<input type="hidden" name="action" value="deleteChecked">
		<table border id="t" class="sortable">
			<tr>
				<th>Delete</th>
				<th>Status</th>
				<cfloop list="#clist#" index="i">
					<th>#i#</th>
				</cfloop>
			</tr>
			<cfloop query="mine">
				<tr>
					<td><input type="checkbox" name="key" value="#key#"></td>
					<td>#status#</td>
					<cfloop list="#clist#" index="i">
						<cfset tval=evaluate("mine." & i)>
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

<!------------------------------------------------------->
<cfif action is "validate">
validate
<cfoutput>
	<cfquery name="getParentContainerId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update 
			cf_temp_parts 
		set 
			parent_container_id = (select container_id from container where container.barcode = cf_temp_parts.CONTAINER_BARCODE)
		where
			upper(username)='#ucase(session.username)#'
	</cfquery>
	<cfquery name="validateGotParent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update 
			cf_temp_parts 
		set 
			validated_status = validated_status || ';Container Barcode not found'
		where 
			CONTAINER_BARCODE is not null and 
			parent_container_id is null and 
			upper(username)='#ucase(session.username)#'
	</cfquery>
	<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update 
			cf_temp_parts 
		set 
			validated_status = validated_status || ';Invalid part_name'
		where 
			upper(username)='#ucase(session.username)#' and 
			part_name|| '|' ||collection_cde NOT IN (
				select part_name|| '|' ||collection_cde from ctspecimen_part_name
			)
	</cfquery>
	<cfquery name="isValid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update 
			cf_temp_parts 
		set 
			validated_status = validated_status || ';Invalid use_existing flag'
		where 
			upper(username)='#ucase(session.username)#' and
			(use_existing not in ('0','1') OR use_existing is null)
	</cfquery>
	<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update 
			cf_temp_parts 
		set 
			validated_status = validated_status || ';Invalid container_barcode'
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
			validated_status = validated_status || ';Invalid DISPOSITION'
		where 
			DISPOSITION NOT IN (select COLL_OBJ_DISPOSITION from CTCOLL_OBJ_DISP) and
			upper(username)='#ucase(session.username)#'
	</cfquery>
	<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update 
			cf_temp_parts 
		set 
			validated_status = validated_status || ';Invalid CONTAINER_TYPE'
		where 
			change_container_type NOT IN (select container_type from ctcontainer_type) AND 
			change_container_type is null and
			upper(username)='#ucase(session.username)#'
	</cfquery>
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_parts where validated_status is null and
			upper(username)='#ucase(session.username)#'
	</cfquery>
	<cfloop query="data">
		<cfif other_id_type is "catalog number">
			<cfquery name="collObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					SELECT 
						collection_object_id
					FROM
						cataloged_item,
						collection
					WHERE
						cataloged_item.collection_id = collection.collection_id and
						collection.guid_prefix = '#guid_prefix#' and
						cat_num='#other_id_number#' and
						upper(username)='#ucase(session.username)#'
				</cfquery>
			<cfelse>
				<cfquery name="collObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					SELECT 
						coll_obj_other_id_num.collection_object_id
					FROM
						coll_obj_other_id_num,
						cataloged_item,
						collection
					WHERE
						coll_obj_other_id_num.collection_object_id = cataloged_item.collection_object_id and
						cataloged_item.collection_id = collection.collection_id and
						collection.guid_prefix = '#guid_prefix#' and
						other_id_type = '#other_id_type#' and
						display_value = '#other_id_number#' and
						upper(username)='#ucase(session.username)#'
				</cfquery>
			</cfif>
			<cfif collObj.recordcount is 1>					
				<cfquery name="insColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					UPDATE 
						cf_temp_parts 
					SET 
						collection_object_id = #collObj.collection_object_id#,
						validated_status='VALID'
					where
						key = #key#
				</cfquery>
				<br>updating #key# to #collObj.collection_object_id#
			<cfelse>				
				<cfquery name="insColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					UPDATE cf_temp_parts SET validated_status = 
					validated_status || ';#data.institution_acronym# #data.collection_cde# #data.other_id_type# #data.other_id_number# could not be found.' 
					where key = #key#
				</cfquery>
				<br>fail...
			</cfif>
		</cfloop>
		<!---
			Things that can happen here:
				1) Upload a part that doesn't exist
					Solution: create a new part, optionally put it in a container that they specify in the upload.
				2) Upload a part that already exists
					a) use_existing = 1
						1) part is in a container
							Solution: warn them, create new part, optionally put it in a container that they've specified
						 2) part is NOT already in a container
						 	Solution: put the existing part into the new container that they've specified or, if
						 	they haven't specified a new container, ignore this line as it does nothing.
					b) use_existing = 0
						1) part is in a container
							Solution: warn them, create a new part, optionally put it in the container they've specified
						2) part is not in a container
							Solution: same: warning and new part		
		---->
		<br>before bads....
		<cfquery name="tt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select validated_status,count(*) c from cf_temp_parts group by validated_status
		</cfquery>
		<cfdump var=#tt#>
		<!----
		<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update 
				cf_temp_parts 
			set 
				(validated_status) = (
				select 
					decode(parent_container_id,
					0,'NOTE: PART EXISTS IN CONTAINER ZERO',
					476089,'NOTE: PART EXISTS IN UAM PARENTLESS VOID',
					397630,'NOTE: PART EXISTS IN MVZ PARENTLESS VOID',
					'NOTE: PART EXISTS IN PARENT CONTAINER')	
					from 
						specimen_part,
						coll_obj_cont_hist,
						container 
					where
						specimen_part.collection_object_id = coll_obj_cont_hist.collection_object_id AND
						coll_obj_cont_hist.container_id = container.container_id AND
						derived_from_cat_item = cf_temp_parts.collection_object_id AND
						cf_temp_parts.part_name=specimen_part.part_name
					group by 
						parent_container_id
				)
			where validated_status='VALID' 
		</cfquery>
		---->
		<br>after bads....
		<cfquery name="tt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select validated_status,count(*) c from cf_temp_parts group by validated_status
		</cfquery>
		<cfdump var=#tt#>
		
		<cfquery name="gonenowback" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_temp_parts set validated_status='VALID' where validated_status is null
		</cfquery>
		<br>after reuip....
		<cfquery name="tt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select validated_status,count(*) c from cf_temp_parts group by validated_status
		</cfquery>
		<cfdump var=#tt#>
		<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_temp_parts set (parent_container_id) = (
			select container_id
			from container where
			barcode=container_barcode)
			where substr(validated_status,1,5) IN ('VALID','NOTE:')
		</cfquery>
		<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_temp_parts set (use_part_id) = (
			select min(specimen_part.collection_object_id)			
			from specimen_part where
			cf_temp_parts.part_name=specimen_part.part_name)
			where validated_status = 'NOTE: PART EXISTS' AND
			use_existing = 1
		</cfquery>
		<cflocation url="BulkloadParts.cfm?action=checkValidate">
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "checkValidate">
<style>
 .int {font-size:xx-small;color:green;}
</style>
	<cfoutput>
	<cfquery name="inT" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_parts
	</cfquery>
	<table border>
		<tr>
			<td>Problem</td>
			<td>IA:CC</td>
			<td>ID_TYPE</td>
			<td>ID_NUMBER</td>
			<td>part_name</td>
			<td>disposition</td>
			<td>lot_count</td>
			<td>remarks</td>
			<td>condition</td>
			<td>Container_Barcode</td>
			<td>use_existing</td>
			<td>change_container_type</td>
		</tr>
		<cfloop query="inT">
			<tr>
				<td>
					<span class="int">#key#</span>
					<span class="int"> #collection_object_id# </span>
					<span class="int"> \#validated_status#\ </span>
					<cfif len(collection_object_id) gt 0 and validated_status is 'VALID'>
						<a href="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#" target="_blank">Specimen</a>
					<cfelseif left(validated_status,5) is 'NOTE:'>
						<a href="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#" target="_blank">Specimen</a> (#validated_status#)
					<cfelse>
						#validated_status#					
					</cfif>
				</td>
				<td>#institution_acronym#:#collection_cde#</td>
				<td>#OTHER_ID_TYPE#</td>
				<td>#OTHER_ID_NUMBER#</td>
				<td>
					<span class="int">#use_part_id#</span>
					#part_name#
				</td>
				<td>#disposition#</td>
				<td>#lot_count#</td>
				<td>#remarks#</td>
				<td>#condition#</td>
				<td>
					<span class="int">#parent_container_id#</span>
					#Container_Barcode#
				</td>
				<td>#use_existing#</td>
				<td>#change_container_type#</td>				
			</tr>
		</cfloop>
	</table>
	</cfoutput>
	<cfquery name="allValid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) as cnt from cf_temp_parts where substr(validated_status,1,5) NOT IN
			('VALID','NOTE:')
	</cfquery>
	<cfif allValid.cnt is 0>
		<a href="BulkloadParts.cfm?action=loadToDb">Load these parts....</a>
	<cfelse>
		You must fix everything above to proceed.
	</cfif>
</cfif>
<!-------------------------------------------------------------------------------------------->
<cfif action is "loadToDb">
<cfoutput>
	<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_parts
	</cfquery>
	<cftransaction>
	<cfloop query="getTempData">
	<cfif len(use_part_id) is 0 AND len(parent_container_id) gt 0>
		<!--- new part, add container --->
		<cfquery name="NEXTID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select sq_collection_object_id.nextval NEXTID from dual
		</cfquery>
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
				#NEXTID.NEXTID#,
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
				#NEXTID.NEXTID#,
				'#PART_NAME#',
				#collection_object_id#
			)
		</cfquery>
		<cfif len(remarks) gt 0>
			<!---- new remark --->
			<cfquery name="newCollRem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				INSERT INTO coll_object_remark (collection_object_id, coll_object_remarks)
				VALUES (#NEXTID.NEXTID#, '#remarks#')
			</cfquery>
		</cfif>
		<cfif len(container_barcode) gt 0>
			<cfquery name="part_container_id" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select 
					container_id
				from 
					coll_obj_cont_hist
				where
					collection_object_id = #NEXTID.NEXTID#
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
		</cfif>
	<cfelseif len(parent_container_id) gt 0 and len(use_part_id) gt 0>
	<!--- there is an existing matching container that is not in a parent_container;
		all we need to do is move the container to a parent IF it exists and is specified, or nothing otherwise --->
		<cfquery name="upPart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update container set parent_container_id=#parent_container_id# 
			where container_id = #use_part_id#
		</cfquery>
	<cfelseif len(parent_container_id) is 0 and len(use_part_id) is 0>
		<!--- new part, no container --->
		<cfquery name="NEXTID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select sq_collection_object_id.nextval NEXTID from dual
		</cfquery>
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
				#NEXTID.NEXTID#,
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
				#NEXTID.NEXTID#,
				'#PART_NAME#',
				#collection_object_id#
			)
		</cfquery>
		<cfif len(remarks) gt 0>
			<!---- new remark --->
			<cfquery name="newCollRem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				INSERT INTO coll_object_remark (collection_object_id, coll_object_remarks)
				VALUES (#NEXTID.NEXTID#, '#remarks#')
			</cfquery>
		</cfif>
	<cfelse>
		oops - no handler
		<cfabort>
	</cfif>
	</cfloop>
	</cftransaction>
	Spiffy, all done.
	<a href="/SpecimenResults.cfm?collection_object_id=#valuelist(getTempData.collection_object_id)#">
		See in Specimen Results
	</a>
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">