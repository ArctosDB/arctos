
	
<!---- relies on table

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
<!------------------------------------------------------->
<cfif action is "csv">
	<cfoutput>
		<cfset d="institution_acronym,collection_cde,other_id_type,other_id_number,part_name,disposition,lot_count,remarks,use_existing,container_barcode,condition">
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
	Step 1: Upload a comma-delimited text file including column headings. (<a href="BulkloadParts.cfm?action=csv">download BulkloadParts.csv template</a>)
	Columns in <span style="color:red">red</span> are required; others are optional:
	<ul>
		<li style="color:red">institution_acronym</li>
		<li style="color:red">collection_cde</li>
		<li style="color:red">other_id_type ("catalog number" is OK)</li>
		<li style="color:red">other_id_number</li>
		<li style="color:red">part_name</li>
		<li style="color:red">disposition</li>
		<li style="color:red">lot_count</li>
		<li>remarks</li>		
		<li style="color:red">use_existing
			<span style="font-size:smaller;font-style:italic;padding-left:20px;">
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
			</span>	
		</li>
		<li>container_barcode
			<span style="font-size:smaller;font-style:italic;padding-left:20px;">
				<ul>
					<li>Container barcode in which to place this part</li>
				</ul>
			</span>	
		</li>	
		<li>change_container_type</li>
		<li style="color:red">condition</li>		 
	</ul>
	<cfform name="atts" method="post" enctype="multipart/form-data" action="BulkloadParts.cfm">
		<input type="hidden" name="action" value="getFile">
		<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" class="savBtn">
	</cfform>
</cfif>
<!------------------------------------------------------->
<cfif action is "getFile">
<cfoutput>
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	<cfset fileContent=replace(fileContent,"'","''","all")>
	<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />
	<cfquery name="die" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from cf_temp_parts
	</cfquery>
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
	<cflocation url="BulkloadParts.cfm?action=validate">
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "validate">
validate
<cfoutput>
	<cfquery name="getParentContainerId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_parts set parent_container_id = 
		(select container_id from container where container.barcode = cf_temp_parts.CONTAINER_BARCODE)
	</cfquery>
	<cfquery name="validateGotParent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_parts set validated_status = validated_status || ';Container Barcode not found'
		where CONTAINER_BARCODE is not null and parent_container_id is null
	</cfquery>
	<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_parts set validated_status = validated_status || ';Invalid part_name'
		where part_name|| '|' ||collection_cde NOT IN (
			select part_name|| '|' ||collection_cde from ctspecimen_part_name
			)
			OR part_name is null
	</cfquery>
	<cfquery name="isValid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_parts set validated_status = validated_status || ';Invalid use_existing flag'
			where use_existing not in ('0','1') OR
			use_existing is null
	</cfquery>
	<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_parts set validated_status = validated_status || ';Invalid container_barcode'
		where container_barcode NOT IN (
			select barcode from container where barcode is not null
			)
		AND container_barcode is not null
	</cfquery>
	<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_parts set validated_status = validated_status || ';Invalid DISPOSITION'
		where DISPOSITION NOT IN (
			select COLL_OBJ_DISPOSITION from CTCOLL_OBJ_DISP
			)
			OR disposition is null
	</cfquery>
	<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_parts set validated_status = validated_status || ';Invalid CONTAINER_TYPE'
		where change_container_type NOT IN (
			select container_type from ctcontainer_type
			)
			AND change_container_type is null
	</cfquery>
	<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_parts set validated_status = validated_status || ';Invalid CONDITION'
		where CONDITION is null
	</cfquery>
	<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_parts set validated_status = validated_status || ';Invalid LOT_COUNT'
		where (
			LOT_COUNT is null OR
			is_number(lot_count) = 0
			)
	</cfquery>
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_parts where validated_status is null
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
						collection.collection_cde = '#collection_cde#' and
						collection.institution_acronym = '#institution_acronym#' and
						cat_num='#other_id_number#'
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
						collection.collection_cde = '#collection_cde#' and
						collection.institution_acronym = '#institution_acronym#' and
						other_id_type = '#other_id_type#' and
						display_value = '#other_id_number#'
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