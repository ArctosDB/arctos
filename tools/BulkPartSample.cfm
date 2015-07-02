

<!---- relies on table

drop table cf_temp_part_sample;

CREATE TABLE cf_temp_part_sample (
	key number,
	guid varchar2(40),
	exists_barcode varchar2(40),
	exists_part VARCHAR2(60),
	sample_name varchar2(60) not null,
	sample_disposition VARCHAR2(60) not null,
	sample_condition VARCHAR2(60) not null,
	sample_barcode varchar2(60),
	sample_container_type  varchar2(60),
	sample_remarks VARCHAR2(60),
	status varchar2(255),
	collection_object_id number,
	exist_part_id number
	);


create or replace public synonym cf_temp_part_sample for cf_temp_part_sample;
grant all on cf_temp_part_sample to manage_specimens;

CREATE OR REPLACE TRIGGER cf_temp_part_sample_key
 before insert  ON cf_temp_part_sample
 for each row
    begin
    	if :NEW.key is null then
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;
    end;
/
sho err



---->
<cfinclude template="/includes/_header.cfm">



<cfif #action# is "nothing">
<cfoutput>



	<cfset thecolumns='guid,exists_barcode,exists_part,sample_name,sample_disposition,sample_condition,sample_barcode,sample_container_type,sample_remarks'>
	<cffile action = "write"
	    file = "#Application.webDirectory#/download/temp_part_sample.csv"
	    output = "#thecolumns#"
	    addNewLine = "no">

	<p>
	Split a part into subsamples, each derived from the parent.
	</p>
	<p>

	<a href="/download.cfm?file=temp_part_sample.csv">get the template</a>
	</p>

	Columns:
	<table border>
		<tr>
			<th>Column</th>
			<th>Reqd?</th>
			<th>Wut?</th>
		</tr>
		<tr>
			<td>guid</td>
			<td>unless exists_barcode</td>
			<td>Find the part to split by specimen+part name.</td>
		</tr>
		<tr>
			<td>exists_part</td>
			<td>unless exists_barcode</td>
			<td>Find the part to split by specimen+part name.</td>
		</tr>
		<tr>
			<td>exists_barcode</td>
			<td>unless guid+exists_part</td>
			<td>Find the part to split by part-parent (eg, nunc tube level) barcode. Will overwrite GUID.</td>
		</tr>
		<tr>
			<td>sample_name</td>
			<td>yes</td>
			<td>New part. <a href="/info/ctDocumentation.cfm?table=CTSPECIMEN_PART_NAME">CTSPECIMEN_PART_NAME</a></td>
		</tr>
		<tr>
			<td>sample_disposition</td>
			<td>yes</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTCOLL_OBJ_DISP">CTCOLL_OBJ_DISP</a></td>
		</tr>
		<tr>
			<td>sample_condition</td>
			<td>yes</td>
			<td></td>
		</tr>
		<tr>
			<td>sample_remarks</td>
			<td>no</td>
			<td></td>
		</tr>
		<tr>
			<td>sample_barcode</td>
			<td>no</td>
			<td>put new part in container</td>
		</tr>

		<tr>
			<td>sample_container_type</td>
			<td>no</td>
			<td>
				change sample_barcode container type. USE WITH CAUTION
				<a href="/info/ctDocumentation.cfm?table=CTCONTAINER_TYPE">CTCONTAINER_TYPE</a>
			</td>
		</tr>
	</table>
	<ul>


<label for="atts">Upload CSV</label>
<cfform name="atts" method="post" enctype="multipart/form-data" action="BulkPartSample.cfm">
			<input type="hidden" name="Action" value="getFile">
			  <input type="file"
		   name="FiletoUpload"
		   size="45" onchange="checkCSV(this);">
			 <input type="submit" value="Upload this file"
		class="savBtn"
		onmouseover="this.className='savBtn btnhov'"
		onmouseout="this.className='savBtn'">
  </cfform>
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "getFile">
	<cfoutput>
		<cfquery name="die" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from cf_temp_part_sample
		</cfquery>
		<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
        <cfset  util = CreateObject("component","component.utilities")>
		<cfset x=util.CSVToQuery(fileContent)>
        <cfset cols=x.columnlist>
        <cfloop query="x">
            <cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	            insert into cf_temp_part_sample (#cols#) values (
	            <cfloop list="#cols#" index="i">
	            	'#stripQuotes(evaluate(i))#'
	            	<cfif i is not listlast(cols)>
	            		,
	            	</cfif>
	            </cfloop>
	            )
            </cfquery>
        </cfloop>
		<cflocation url="BulkPartSample.cfm?action=validate" addtoken="false">
	</cfoutput>
</cfif>
<!------------------------------------------------------->
<!------------------------------------------------------->
<cfif #action# is "validate">
<cfoutput>


		key number,
	guid varchar2(40),
	exists_barcode varchar2(40),
	exists_part VARCHAR2(60),
	sample_name varchar2(60),
	sample_disposition VARCHAR2(60),
	sample_condition VARCHAR2(60),
	sample_barcode varchar2(60),
	sample_container_type,
	sample_remarks VARCHAR2(60),
	status varchar2(255),
	collection_object_id number,
	exist_part_id number,
	container_id number


	<cfquery name="u2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_part_sample set status='duplicate part' where
		status is null and
		cf_temp_part_sample.guid is not null and
		cf_temp_part_sample.exists_part is not null and
		(
			select count(*) from
				specimen_part,
				cataloged_item,
				collection
				where
				specimen_part.derived_from_cat_item=cataloged_item.collection_object_id and
				cataloged_item.collection_id=collection.collection_id and
				collection.guid_prefix || cataloged_item.cat_num = cf_temp_part_sample.guid and
				specimen_part.part_name=cf_temp_part_sample.exists_part
		) != 1
	</cfquery>

	<cfquery name="u2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_part_sample set status='bad sample_name' where
		status is null and
		sample_name not in (select part_name from CTSPECIMEN_PART_NAME)
	</cfquery>
	<cfquery name="ue2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_part_sample set status='bad sample_container_type' where
		status is null and
		sample_container_type not in
		(select container_type from CTCONTAINER_TYPE)
	</cfquery>
	<cfquery name="ru2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_part_sample set status='bad sample_disposition' where
		status is null and
		sample_disposition not in
		(select COLL_OBJ_DISPOSITION from CTCOLL_OBJ_DISP)
	</cfquery>



	<cfquery name="u2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_part_sample set (exist_part_id)=(select specimen_part.collection_object_id from
		specimen_part,
		cataloged_item,
		collection
		where
		specimen_part.derived_from_cat_item=cataloged_item.collection_object_id and
		cataloged_item.collection_id=collection.collection_id and
		collection.guid_prefix || cataloged_item.cat_num = cf_temp_part_sample.guid and
		specimen_part.part_name=cf_temp_part_sample.exists_part
		) where
		cf_temp_part_sample.guid is not null and
		cf_temp_part_sample.exists_part is not null
	</cfquery>
	<cfquery name="u13" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_part_sample set (exist_part_id)=(select specimen_part.collection_object_id from
		specimen_part,
		coll_obj_cont_hist,
		container partc,
		container bcc
		where
		specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
		coll_obj_cont_hist.container_id=partc.container_id and
		partc.parent_container_id = bcc.container_id and
		bcc.barcode=cf_temp_part_sample.exists_barcode
		) where
		cf_temp_part_sample.exists_barcode is not null
	</cfquery>


	<cfquery name="u413" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_part_sample set 'part not found' where exist_part_id is null
	</cfquery>


	<cfquery name="u413" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_part_sample set 'lot count not 1' where exist_part_id is null
	</cfquery>






	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_part_sample where
			exist_part_id is null or
			status is not null
	</cfquery>
	<cfif d.recordcount gt 0>
		Will not load
		<cfdump var=#d#>
	<cfelse>
		<a href="BulkPartSample.cfm?action=loadToDb">continue</a>
	</cfif>

	<!---

	--->

</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------------------->

<cfif #action# is "loadToDb">

<cfoutput>
	<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_part_sample
	</cfquery>
	<cftransaction>
	<cfloop query="getTempData">
		<cfquery name="pPart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
			<cfquery name="lot_count" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update coll_object set lot_count=lot_count-1 where collection_object_id=#i$exist_part_id#
			</cfquery>
			<cfquery name="insColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
					sysdate,
					'#r$sample_disposition#',
					1,
					'#r$sample_condition#',
					0
				)
			</cfquery>
			<cfquery name="newTiss" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
				<cfquery name="newCollRem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					INSERT INTO coll_object_remark (collection_object_id, coll_object_remarks)
					VALUES (sq_collection_object_id.currval, '#sample_remarks#')
				</cfquery>
			</cfif>
			<cfquery name="pCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select container_id from coll_obj_cont_hist where collection_object_id=#nextID.nextID#
			</cfquery>
			<cfquery name="upCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update container set parent_container_id=#i$container_id# where container_id=#pCont.container_id#
			</cfquery>
			<cfquery name="upCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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