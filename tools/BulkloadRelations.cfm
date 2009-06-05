<!---
drop table cf_temp_relations;


create table cf_temp_relations (
	key number not null,
	institution_acronym varchar2(6) not null,
	collection_cde varchar2(6) not null,
	other_id_type varchar2(255) not null,
	other_id_val varchar2(255) not null,
	relationship varchar2(255) not null,
	related_institution_acronym varchar2(6) not null,
	related_collection_cde varchar2(6) not null,
	related_other_id_type varchar2(255) not null,
	related_other_id_val varchar2(255) not null,
	collection_object_id number,
	related_collection_object_id number,
	validated_status varchar2(255)
	);

	
create public synonym cf_temp_relations for cf_temp_relations;
grant all on cf_temp_relations to coldfusion_user;
grant select on cf_temp_relations to public;

 CREATE OR REPLACE TRIGGER cf_temp_relations_key                                         
 before insert  ON cf_temp_relations
 for each row 
    begin     
    	if :NEW.key is null then                                                                                      
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;                                
    end;                                                                                            
/
sho err


--->

<cfinclude template="/includes/_header.cfm">
<cfif #action# is "nothing">
Step 1: Upload a comma-delimited text file (csv). 
Include column headings, spelled exactly as below. 
<br><span class="likeLink" onclick="document.getElementById('template').style.display='block';">view template</span>
	<div id="template" style="display:none;">
		<label for="t">Copy and save as a .csv file</label>
		<textarea rows="2" cols="80" id="t">institution_acronym,collection_cde,other_id_type,other_id_val,relationship,related_institution_acronym,related_collection_cde,related_other_id_type,related_other_id_val</textarea>
	</div> 
<p></p>
Columns in <span style="color:red">red</span> are required; others are optional:
<ul>
	<li style="color:red">institution_acronym</li>
	<li style="color:red">collection_cde</li>
	<li style="color:red">other_id_type ("catalog number" is OK)</li>
	<li style="color:red">other_id_val</li>
	<li style="color:red">relationship</li>
	<li style="color:red">related_institution_acronym</li>
	<li style="color:red">related_collection_cde</li>
	<li style="color:red">related_other_id_type ("catalog number" is OK)</li>
	<li style="color:red">related_other_id_val</li>
</ul>

<cfform name="atts" method="post" enctype="multipart/form-data">
			<input type="hidden" name="Action" value="getFile">
			  <input type="file"
		   name="FiletoUpload"
		   size="45">
			 <input type="submit" value="Upload this file"
		class="savBtn"
		onmouseover="this.className='savBtn btnhov'" 
		onmouseout="this.className='savBtn'">
  </cfform>

</cfif>
<!------------------------------------------------------->
<!------------------------------------------------------->

<!------------------------------------------------------->
<cfif #action# is "getFile">
	<cfoutput>
		<!--- put this in a temp table --->
		<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			delete from cf_temp_relations
		</cfquery>
		<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
		<cfset fileContent=replace(fileContent,"'","''","all")>
		<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />
		<cfset numberOfColumns = ArrayLen(arrResult[1])>
		<cfset colNames="">
		<cfloop from="1" to ="#ArrayLen(arrResult)#" index="o">
			<cfset colVals="">
				<cfloop from="1"  to ="#ArrayLen(arrResult[o])#" index="i">
					 <cfset numColsRec = ArrayLen(arrResult[o])>
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
				<cfif numColsRec lt numberOfColumns>
					<cfset missingNumber = numberOfColumns - numColsRec>
					<cfloop from="1" to="#missingNumber#" index="c">
						<cfset colVals = "#colVals#,''">
					</cfloop>
				</cfif>
				<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					insert into cf_temp_relations (#colNames#) values (#preservesinglequotes(colVals)#)
				</cfquery>
			</cfif>
		</cfloop>
	</cfoutput>
	<cflocation url="BulkloadAgents.cfm?action=validate">
</cfif>
<!------------------------------------------------------->
<!------------------------------------------------------->
<cfif #action# is "validate">
<cfoutput>
	<cfquery name="setStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update 
			cf_temp_relations 
		set 
			validated_status='bad_relationship'
		where 
			validated_status is null AND (
				relationship not in (select BIOL_INDIV_RELATIONSHIP from CTBIOL_RELATIONS)
			)
	</cfquery>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from cf_temp_relations
	</cfquery>
	<cfloop query="d">
		<cfif #other_id_type# is "catalog number">
			<cfquery name="collObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				SELECT 
					collection_object_id
				FROM
					cataloged_item,
					collection
				WHERE
					cataloged_item.collection_id = collection.collection_id and
					collection.collection_cde = '#collection_cde#' and
					collection.institution_acronym = '#institution_acronym#' and
					cat_num=#other_id_val#
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
					collection.collection_cde = '#collection_cde#' and
					collection.institution_acronym = '#institution_acronym#' and
					other_id_type = '#other_id_type#' and
					other_id_num = '#other_id_val#'
			</cfquery>				
		</cfif>
		<cfif #collObj.recordcount# is 1>					
			<cfquery name="insColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				UPDATE cf_temp_relations SET collection_object_id = #collObj.collection_object_id#
				where
				key = #key#
			</cfquery>
		<cfelse>				
			<cfquery name="insColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				UPDATE cf_temp_relations SET validated_status = 
				validated_status || 'identifier matched #collObj.recordcount# records' 
				where key = #key#
			</cfquery>
		</cfif>
		<cfif #related_other_id_type# is "catalog number">
			<cfquery name="rcollObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				SELECT 
					collection_object_id
				FROM
					cataloged_item,
					collection
				WHERE
					cataloged_item.collection_id = collection.collection_id and
					collection.collection_cde = '#related_collection_cde#' and
					collection.institution_acronym = '#related_institution_acronym#' and
					cat_num=#related_other_id_val#
			</cfquery>
		<cfelse>
			<cfquery name="rcollObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				SELECT 
					coll_obj_other_id_num.collection_object_id
				FROM
					coll_obj_other_id_num,
					cataloged_item,
					collection
				WHERE
					coll_obj_other_id_num.collection_object_id = cataloged_item.collection_object_id and
					cataloged_item.collection_id = collection.collection_id and
					collection.collection_cde = '#related_collection_cde#' and
					collection.institution_acronym = '#related_institution_acronym#' and
					other_id_type = '#related_other_id_type#' and
					other_id_num = '#related_other_id_val#'
			</cfquery>				
		</cfif>
		<cfif #rcollObj.recordcount# is 1>					
			<cfquery name="insColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				UPDATE cf_temp_relations SET related_collection_object_id = #rcollObj.collection_object_id#
				where
				key = #key#
			</cfquery>
		<cfelse>				
			<cfquery name="insColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				UPDATE cf_temp_relations SET validated_status = 
				validated_status || 'related identifier matched #rcollObj.recordcount# records.' 
				where key = #key#
			</cfquery>
		</cfif>
	</cfloop>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from cf_temp_relations
	</cfquery>	
	<cfquery name="b" dbtype="query">
		select count(*) c from d where validated_status is not null
	</cfquery>
	<cfif b.c gt 0>
		You must clean up the #b.recordcount# rows with validated_status != NULL in this table before proceeding.
	<cfelse>
		Check out the table below and <a href="BulkloadRelations.cfm?action=loadData">click here to proceed</a> when all looks OK
	</cfif>
	<cfdump var=#d#>
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif #action# is "loadData">

<cfoutput>
	
		
	<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from cf_temp_relations
	</cfquery>
	<cftransaction>
	<cfloop query="getTempData">
		<cfquery name="newAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			insert into biol_indiv_relations (
				collection_object_id,
				related_coll_obj_id,
				relationship
			) values (
				#collection_object_id number#,
				#related_collection_object_id#,
				'#relationship#'
			)
		</cfquery>
	</cfloop>
	</cftransaction>

	Spiffy, all done.
</cfoutput>
</cfif>

<cfinclude template="/includes/_footer.cfm">
