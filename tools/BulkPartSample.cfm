

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
	exist_part_id number,
	container_id number
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
			<cfif len(x.sample_name) gt 0>
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
			</cfif>
        </cfloop>
		<cflocation url="BulkPartSample.cfm?action=validate" addtoken="false">
	</cfoutput>
</cfif>
<!------------------------------------------------------->
<!------------------------------------------------------->
<cfif #action# is "validate">
<cfoutput>

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
		update cf_temp_part_sample set
			(exist_part_id,collection_object_id)
			=(
				select specimen_part.collection_object_id,specimen_part.derived_from_cat_item from
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
		update cf_temp_part_sample set (exist_part_id,collection_object_id)=(
		select specimen_part.collection_object_id,specimen_part.derived_from_cat_item from
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

	<cfquery name="u13" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_part_sample set (container_id)=(select container_id from
		container where container.barcode=cf_temp_part_sample.sample_barcode)
		where status is null and
		sample_barcode is not null
	</cfquery>


	<cfquery name="u413" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_part_sample set status='part not found' where exist_part_id is null
	</cfquery>
	<cfquery name="u4r13" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_part_sample set status='container not found' where sample_barcode is not null and container_id is null
	</cfquery>

	<cfquery name="u413" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_part_sample set status= 'lot count not 1' where
			(select lot_count from coll_object where coll_object.collection_object_id=cf_temp_part_sample.exist_part_id) != 1
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
			<cfquery name="pid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select sq_collection_object_id.nextval nid from dual
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
					#pid.nid#,
					'SP',
					#session.myAgentId#,
					sysdate,
					#session.myAgentId#,
					'#sample_disposition#',
					1,
					'#sample_condition#',
					0 )
			</cfquery>
			<cfquery name="newTiss" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				INSERT INTO specimen_part (
					  COLLECTION_OBJECT_ID,
					  PART_NAME,
					  SAMPLED_FROM_OBJ_ID,
					  derived_from_cat_item
				) VALUES (
					#pid.nid#,
				  	'#sample_name#',
					#exist_part_id#,
					#collection_object_id#
				)
			</cfquery>
			<cfif len(sample_remarks) gt 0>
				<cfquery name="newCollRem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					INSERT INTO coll_object_remark (collection_object_id, coll_object_remarks)
					VALUES (#pid.nid#, '#sample_remarks#')
				</cfquery>
			</cfif>
			<cfif len(sample_barcode) gt 0>

				<cfstoredproc procedure="movePartToContainer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					<cfprocparam cfsqltype="CF_SQL_FLOAT" value="#pid.nid#"><!---- v_collection_object_id ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#sample_barcode#"><!---- v_barcode ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value=""><!---- v_container_id ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#sample_container_type#"><!---- v_parent_container_type ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value=""><!---- v_parent_container_label ---->
				</cfstoredproc>


				<!---
				<cfquery name="pCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select container_id from coll_obj_cont_hist where collection_object_id=#pid.nid#
				</cfquery>
				<cfif len(sample_container_type) gt 0>
					<cfquery name="cct" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						update container set container_type='#sample_container_type#' where container_id=#container_id#
					</cfquery>
				</cfif>
				<cfquery name="upCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update container set parent_container_id=#container_id# where container_id=#pCont.container_id#
				</cfquery>
				---->
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