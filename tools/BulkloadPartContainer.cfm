<!------------------------------
CREATE OR REPLACE TRIGGER cf_temp_barcode_parts_key                                         
 before insert  ON cf_temp_barcode_parts  
 for each row 
    begin     
    	if :NEW.key is null then                                                                                      
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;                                
    end;                                                                                            
/
sho err
		create table cf_temp_barcode_parts (
			 KEY number not null,
			 OTHER_ID_TYPE varchar2(255),
			 OTHER_ID_NUMBER varchar2(60),
			 COLLECTION_CDE varchar2(20),
			 INSTITUTION_ACRONYM varchar2(20),
			 part_name varchar2(255),
			 barcode varchar2(255),
			 COLLECTION_OBJECT_ID number,
			 container_id number
			 );
		CREATE PUBLIC SYNONYM cf_temp_barcode_parts FOR cf_temp_barcode_parts;
		GRANT select,insert,update,delete ON cf_temp_barcode_parts to manage_container;
		
		alter table cf_temp_barcode_parts add status varchar2(255);
		alter table cf_temp_barcode_parts add parent_container_id number;
		alter table cf_temp_barcode_parts add part_container_id number;
------------------------------------->
<cfinclude template="/includes/_header.cfm">
<cfif action is "makeTemplate">
	<cfset header="OTHER_ID_TYPE,OTHER_ID_NUMBER,COLLECTION_CDE,INSTITUTION_ACRONYM,PART_NAME,PRINT_FG,NEW_CONTAINER_TYPE,BARCODE">
	<cffile action = "write" 
    file = "#Application.webDirectory#/download/BulkPartContainer.csv"
    output = "#header#"
    addNewLine = "no">
	<cflocation url="/download.cfm?file=BulkPartContainer.csv" addtoken="false">
</cfif>
<cfif action is  "nothing">
	Use this form to put collection objects (that is, parts) in containers. Parts and containers must already exist.
	This form will not create parts - use <a href="BulkloadParts.cfm">BulkloadParts</a> for that.
	<ul>
		<li><a href="BulkloadPartContainer.cfm?action=makeTemplate">download a CSV template</a></li>
		<li>
			<a href="/info/ctDocumentation.cfm?table=ctcoll_other_id_type" target="_blank">[ OTHER_ID_TYPE values ]</a>
			<br>"catalog number" is also a valid other_id_type.
		<cfset header=",,
				
					PRINT_FG,,">
		</li>
		<li>Collection_Cde is case-sensitive, e.g., "Mamm"</li>
		<li>Institution_Acronym is case-sensitive, e.g., "UAM"</li>
		
		<li>
			Part_Name is case-sensitive and collection-specific	
			<br><a href="/info/ctDocumentation.cfm?table=ctspecimen_part_name" target="_blank">part_name values</a>
		</li>
		<li>BARCODE is the barcode of the container (usually a NUNC tube) into which you want to place the part</li>
		<li>
			PRINT_FG - a UAM Mammals thing? What is this? 
			<br>0 - nothing, remove all print flags
	 		<br>1 - container
			<br> 2 - vial
		</li>
		<li>
			NEW_CONTAINER_TYPE - the container into which you wish to place the part may be a label of some sort.
			Use this to change it to a 
			<a href="/info/ctDocumentation.cfm?table=ctcontainer_type" target="_blank">valid container type</a>
		</li>
	</ul>
	
	Upload a file:
	<cfform name="getFile" method="post" action="BulkloadPartContainer.cfm" enctype="multipart/form-data">
		<input type="hidden" name="action" value="getFileData">
		 <input type="file"
			   name="FiletoUpload"
			   size="45">
		<input type="submit" value="Upload this file" class="savBtn">
	</cfform>
</cfif>
<!---------------------------------------------------------------------->
  <cfif action is "getFileData">
<cfoutput>
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		delete from cf_temp_barcode_parts
	</cfquery>
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
		<cfif #o# is 1>
			<cfset colNames=replace(colNames,",","","first")>
		</cfif>	
		<cfif len(#colVals#) gt 1>
			<cfset colVals=replace(colVals,",","","first")>
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into cf_temp_barcode_parts (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>
	<cflocation url="BulkloadPartContainer.cfm?action=validateFromFile">
</cfoutput>
</cfif>
<!--------------------------------------------------------------------------->
<cfif action is "validateFromFile">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select KEY,
			INSTITutION_ACRONYM,
			COLLECTION_CDE,
			OTHER_ID_TYPE,
			OTHER_ID_NUMBER oidNum,
			part_name,
			barcode parent_barcode,
			print_fg,
			new_container_type
		from 
			cf_temp_barcode_parts
	</cfquery>
	<cfquery name="goodContainers" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update cf_temp_barcode_parts set status='bad_container_type'
		where new_container_type NOT IN (
			select container_type from ctcontainer_type)
	</cfquery>
	<cfoutput>
		<cfloop query="data">
			<cfset sts=''>
			<cfif other_id_type is "catalog number">
				<cfquery name="coll_obj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select specimen_part.collection_object_id FROM
						cataloged_item,
						specimen_part,
						collection
					WHERE
						cataloged_item.collection_object_id = specimen_part.derived_from_cat_item AND
						cataloged_item.collection_id = collection.collection_id AND
						collection.COLLECTION_CDE='#COLLECTION_CDE#' AND
						collection.INSTITutION_ACRONYM = '#INSTITutION_ACRONYM#' AND
						cat_num='#oidnum#' AND
						part_name='#part_name#'
				</cfquery>
			<cfelse>
				<cfquery name="coll_obj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select specimen_part.collection_object_id FROM
						cataloged_item,
						specimen_part,
						coll_obj_other_id_num,
						collection
					WHERE
						cataloged_item.collection_object_id = specimen_part.derived_from_cat_item AND
						cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id AND
						cataloged_item.collection_id = collection.collection_id AND
						collection.COLLECTION_CDE='#COLLECTION_CDE#' AND
						collection.INSTITutION_ACRONYM = '#INSTITutION_ACRONYM#' AND
						other_id_type='#other_id_type#' AND
						display_value= '#oidnum#' AND
						part_name='#part_name#'
				</cfquery>
			</cfif>
			<cfif debug is true>
				<cfdump var=#coll_obj#>
			</cfif>
			<cfif coll_obj.recordcount is not 1>
				<cfset sts='item_not_found'>
			</cfif>
			<!--- see if they gave a valid parent container ---->
			<cfquery name="isGoodParent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select container_id from container where container_type <> 'collection object'
				and barcode='#parent_barcode#'
			</cfquery>
			<cfif isGoodParent.recordcount is not 1>
				<cfset sts='parent_barcode_not_found'>
			</cfif>
			<cfif sts is ''>
				<cfquery name="cont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select container_id FROM coll_obj_cont_hist where
					collection_object_id=#coll_obj.collection_object_id#
				</cfquery>
				<cfif len(cont.container_id) is 0>
					<cfset sts='part_container_not_found'>
				</cfif>
			</cfif>
			<cfif sts is ''>
				<cfquery name="setter" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					update cf_temp_barcode_parts set
						parent_container_id=#isGoodParent.container_id#,
						part_container_id=#cont.container_id#
					where key=#key#
				</cfquery>
			<cfelse>
				<cfquery name="ssetter" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					update cf_temp_barcode_parts set
						status='#sts#'
					where key=#key#
				</cfquery>
			</cfif>
		</cfloop>
	</cfoutput>
	<cflocation url="BulkloadPartContainer.cfm?action=load">
</cfif>
<cfif action is "load">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from cf_temp_barcode_parts
	</cfquery>
	<cfif listlen(valuelist(d.status)) gt 0>
		Fix this and reload - nothing's been saved.
		<cfdump var=#d#>
	<cfelse>
		<cftransaction>
			<cfloop query="d">
				<cfquery name="flagIT" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					update 
						container 
					set 
						print_fg=#print_fg#,
						container_type='#NEW_CONTAINER_TYPE#'
					where 
						container_id = #parent_container_id#						
				</cfquery>
				<cfquery name="moveIt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					UPDATE 
						container 
					SET 
						parent_container_id = #parent_container_id#
					 WHERE
					container_id=#part_container_id#
				</cfquery>
			</cfloop>
		</cftransaction>	
	</cfif>
</cfif>
<!------------------------------------------------------------------->
<cfinclude template="/includes/_footer.cfm"/>