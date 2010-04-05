
	
<!---- relies on table

drop table cf_temp_part_sample;

CREATE TABLE cf_temp_part_sample (
	r$institution_acronym VARCHAR2(60),
	r$collection_cde VARCHAR2(60),
	r$OTHER_ID_TYPE VARCHAR2(60),
 	r$OTHER_ID_NUMBER VARCHAR2(60),
 	r$exist_part_name VARCHAR2(60),
	exist_part_modifier VARCHAR2(60),
	exist_preserve_method VARCHAR2(60),
	r$sample_name varchar2(60),
	sample_modifier varchar2(60),
	sample_preserve_method varchar2(60),
	r$sample_disposition VARCHAR2(60),
	r$sample_condition VARCHAR2(60),
	r$sample_label varchar2(60),
	sample_barcode varchar2(60),
	sample_remarks VARCHAR2(60),
	i$validated_status varchar2(255),
	r$sample_container_type varchar2(255),
	i$collection_object_id NUMBER,
	i$KEY NUMBER NOT NULL,
	i$exist_part_id number,
	i$container_id number
	);
	
	comment on column cf_temp_part_sample.r$OTHER_ID_TYPE is '"catalog number" is a valid other_id_type';
	
alter table cf_temp_part_sample rename column sample_barcode to r$sample_barcode;

create or replace public synonym cf_temp_part_sample for cf_temp_part_sample;
grant all on cf_temp_part_sample to manage_specimens;

CREATE OR REPLACE TRIGGER cf_temp_part_sample_key                                         
 before insert  ON cf_temp_part_sample  
 for each row 
    begin     
    	if :NEW.i$key is null then                                                                                      
    		select somerandomsequence.nextval into :new.i$key from dual;
    	end if;                                
    end;                                                                                            
/
sho err
---->
<cfinclude template="/includes/_header.cfm">
<cfif #action# is "nothing">
<cfoutput>
	<cfquery name="template" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select column_name, comments from all_col_comments where lower(table_name) = 'cf_temp_part_sample'
	</cfquery>
Step 1: Upload a comma-delimited text file (csv). 
Include all column headings, spelled exactly as below, or use the following template.
Columns that begin with r$ are required; others are optional:
<ul>
	<cfset cols="">
	<cfloop query="template">
		<cfif left(column_name,2) is not 'i$'>
			<cfset cols=listappend(cols,column_name)>
			<li <cfif left(column_name,2) is "r$">  style="color:red"</cfif>>#column_name#
				<cfif len(comments) gt 0>
					<br><span style="padding-left:20px;font-size:small">#comments#</span></cfif>
			</li>
		</cfif>	
	</cfloop>
</ul>
<br>
	<div id="template">
		<label for="t">CSV Template</label>
		<textarea rows="2" cols="80" id="t">#cols#</textarea>
	</div> 
<p></p>
<label for="atts">Upload a CSV file</label>
<cfform name="atts" method="post" enctype="multipart/form-data" action="BulkPartSample.cfm">
			<input type="hidden" name="Action" value="getFile">
			  <input type="file"
		   name="FiletoUpload"
		   size="45">
			 <input type="submit" value="Upload this file"
		class="savBtn"
		onmouseover="this.className='savBtn btnhov'" 
		onmouseout="this.className='savBtn'">
  </cfform>
</cfoutput>
</cfif>
<!------------------------------------------------------->
<!------------------------------------------------------->

<!------------------------------------------------------->
<cfif #action# is "getFile">
<cfoutput>
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">

	<cfset fileContent=replace(fileContent,"'","''","all")>
	<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />

 <cfquery name="die" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	delete from cf_temp_part_sample
</cfquery>

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
		<cfif #o# is 1>
			<cfset colNames=replace(colNames,",","","first")>
		</cfif>	
		<cfif len(#colVals#) gt 1>
			<cfset colVals=replace(colVals,",","","first")>
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into cf_temp_part_sample (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>
	<cflocation url="BulkPartSample.cfm?action=validate">
</cfoutput>
</cfif>
<!------------------------------------------------------->
<!------------------------------------------------------->
<cfif #action# is "validate">
<cfoutput>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from cf_temp_part_sample
	</cfquery>
	<cfloop query="d">
		<cfset status="">
		<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select count(*) c from ctspecimen_part_name where part_name='#R$SAMPLE_NAME#' and collection_cde='#R$COLLECTION_CDE#'
		</cfquery>
		<cfif bads.c is not 1>
			<cfset status=listappend(status,'bad R$SAMPLE_NAME')>
		</cfif>
		<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select count(*) c from ctspecimen_part_name where part_name='#R$EXIST_PART_NAME#' and collection_cde='#R$COLLECTION_CDE#'
		</cfquery>
		<cfif bads.c is not 1>
			<cfset status=listappend(status,'bad R$EXIST_PART_NAME')>
		</cfif>
		<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select count(*) c from CTCOLL_OBJ_DISP where COLL_OBJ_DISPOSITION='#R$SAMPLE_DISPOSITION#'
		</cfquery>
		<cfif bads.c is not 1>
			<cfset status=listappend(status,'bad R$SAMPLE_DISPOSITION')>
		</cfif>
		
		<cfif #R$OTHER_ID_TYPE# is "catalog number">
			<cfquery name="collObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				SELECT 
					collection_object_id
				FROM
					cataloged_item,
					collection
				WHERE
					cataloged_item.collection_id = collection.collection_id and
					collection.collection_cde = '#R$COLLECTION_CDE#' and
					collection.institution_acronym = '#R$INSTITUTION_ACRONYM#' and
					cat_num=#R$OTHER_ID_NUMBER#
			</cfquery>
		<cfelse>
			<cfquery name="collObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				SELECT 
					coll_obj_other_id_num.collection_object_id
				FROM
					coll_obj_other_id_num,
					cataloged_item,
					collection
				WHERE
					coll_obj_other_id_num.collection_object_id = cataloged_item.collection_object_id and
					cataloged_item.collection_id = collection.collection_id and
					collection.collection_cde = '#R$COLLECTION_CDE#' and
					collection.institution_acronym = '#R$INSTITUTION_ACRONYM#' and
					other_id_type = '#R$OTHER_ID_TYPE#' and
					display_value = '#R$OTHER_ID_NUMBER#'
			</cfquery>
		</cfif>
		<cfif collObj.recordcount is 1 and len(collObj.collection_object_id) gt 0>			
			<cfset cat_item_id=collObj.collection_object_id>
		<cfelse>
			<cfset status=listappend(status,'cataloged item not found')>
			<cfset cat_item_id=-1>
		</cfif>
		<cfif len(R$SAMPLE_CONTAINER_TYPE) gt 0>
			<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select count(*) c from ctcontainer_type where container_type='#R$SAMPLE_CONTAINER_TYPE#'
			</cfquery>
			<cfif bads.c is not 1>
				<cfset status=listappend(status,'bad R$SAMPLE_CONTAINER_TYPE')>
			</cfif>
		</cfif>
		<cfif len(R$SAMPLE_LABEL) is 0>
			<cfset status=listappend(status,'bad R$SAMPLE_LABEL')>
		</cfif>
		<cfif len(R$SAMPLE_CONDITION) is 0>
			<cfset status=listappend(status,'bad R$SAMPLE_CONDITION')>
		</cfif>
		<cfquery name="container" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select container_id from container where barcode='#R$SAMPLE_BARCODE#'
		</cfquery>
		<cfif container.recordcount is 1 and len(container.container_id) gt 0>
			<cfset container_id=container.container_id>
		<cfelse>
			<cfset container_id=-1>
			<cfset status=listappend(status,'bad R$SAMPLE_BARCODE')>
		</cfif>

		<cfquery name="pPart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select min(collection_object_id)  collection_object_id
			from 
			specimen_part where
			derived_from_cat_item=#cat_item_id# and
			part_name='#r$exist_part_name#'
		</cfquery>
		<cfif pPart.recordcount is 1 and len(pPart.collection_object_id) gt 0>
			<cfset partID=pPart.collection_object_id>
		<cfelse>
			<cfset partID=-1>
			<cfset status=listappend(status,'parent part not found')>
		</cfif>
		<cfquery name="status" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			update cf_temp_part_sample set
				i$validated_status='#status#',
				i$collection_object_id=#cat_item_id#,
				i$exist_part_id=#partID#,
				i$container_id=#container_id#
			where i$KEY = #i$KEY#
		</cfquery>
	</cfloop>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from cf_temp_part_sample
	</cfquery>
	
	
	<cfquery name="b" dbtype="query">
		select count(*) c from d where i$validated_status is not null
	</cfquery>
	<cfif b.c gt 0>
		You must clean up the #b.recordcount# rows with i$validated_status != NULL in this table before proceeding.
		<br>
		<cfdump var=#d#>
	<cfelse>
		<cflocation url="BulkPartSample.cfm?action=loadToDb">
	</cfif>

	<!---

	--->

</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------------------->

<cfif #action# is "loadToDb">

<cfoutput>
	<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from cf_temp_part_sample
	</cfquery>
	<cfset thisDate = dateformat(now(),"dd-mmm-yyyy")>	
	<cftransaction>
	<cfloop query="getTempData">
		<cfquery name="pPart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				*
			from 
				specimen_part,
				coll_object
			where
				specimen_part.collection_object_id=coll_object.collection_object_id and
				specimen_part.collection_object_id=#i$exist_part_id#
		</cfquery>
		<cfif pPart.lot_count lte 1>
			I can't yet deal with parent lot count <= 1.
			<cfabort>
		<cfelse><!--- parent lot count check --->
			<cfquery name="lot_count" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				update coll_object set lot_count=lot_count-1 where collection_object_id=#i$exist_part_id#
			</cfquery>
			<cfquery name="insColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				INSERT INTO coll_object (
					COLLECTION_OBJECT_ID,
					COLL_OBJECT_TYPE,
					ENTERED_PERSON_ID,
					COLL_OBJECT_ENTERED_DATE,
					COLL_OBJ_DISPOSITION,
					LOT_COUNT,
					CONDITION,
					FLAGS )
				VALUES (
					sq_collection_object_id.nextval,
					'SP',
					#session.myAgentId#,
					'#thisDate#',
					'#r$sample_disposition#',
					1,
					'#r$sample_condition#',
					0
				)		
			</cfquery>
			<cfquery name="newTiss" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				INSERT INTO specimen_part (
				  COLLECTION_OBJECT_ID,
				  PART_NAME
					,DERIVED_FROM_cat_item,
					SAMPLED_FROM_OBJ_ID)
				VALUES (
					sq_collection_object_id.currval,
				  '#r$sample_name#'
					,#i$collection_object_id#,
					#i$exist_part_id#
				)
			</cfquery>
			<cfif len(#sample_remarks#) gt 0>
				<cfquery name="newCollRem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					INSERT INTO coll_object_remark (collection_object_id, coll_object_remarks)
					VALUES (sq_collection_object_id.currval, '#sample_remarks#')
				</cfquery>
			</cfif>
			<cfquery name="pCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select container_id from coll_obj_cont_hist where collection_object_id=#nextID.nextID#
			</cfquery>
			<cfquery name="upCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				update container set parent_container_id=#i$container_id# where container_id=#pCont.container_id#
			</cfquery>
			<cfquery name="upCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				update container set label='#r$sample_label#',
				container_type='#r$sample_container_type#' where container_id=#i$container_id#
			</cfquery>	
		</cfif><!--- parent lot count check --->
	</cfloop>
	</cftransaction>
	Spiffy, all done.
	<a href="/SpecimenResults.cfm?collection_object_id=#valuelist(getTempData.i$collection_object_id)#">
		See in Specimen Results
	</a>
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">