<cfinclude template="/includes/_header.cfm">
<!---- make the table 

drop table cf_temp_oids;
drop public synonym cf_temp_oids;

create table cf_temp_oids (
	key number,
	collection_object_id number,
	collection_cde varchar2(4),
	institution_acronym varchar2(6),
	existing_other_id_type varchar2(60),
	existing_other_id_number varchar2(60),
	new_other_id_type varchar2(60),
	new_other_id_number varchar2(60)
	);

	create public synonym cf_temp_oids for cf_temp_oids;
	grant select,insert,update,delete on cf_temp_oids to uam_query,uam_update;
	
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
<CFINclude template="/includes/functionLib.cfm">
<cfif #action# is "nothing">
Step 1: Upload a comma-delimited text file (csv). 
Include column headings, spelled exactly as below. 
<br><span class="likeLink" onclick="document.getElementById('template').style.display='block';">view template</span>
	<div id="template" style="display:none;">
		<label for="t">Copy the following code and save as a .csv file</label>
		<textarea rows="2" cols="80" id="t">COLLECTION_CDE,INSTITUTION_ACRONYM,EXISTING_OTHER_ID_TYPE,EXISTING_OTHER_ID_NUMBER,NEW_OTHER_ID_TYPE,NEW_OTHER_ID_NUMBER</textarea>
	</div> 
<p></p>

<ul>
	<li style="color:red">COLLECTION_CDE</li>
	<li style="color:red">INSTITUTION_ACRONYM</li>
	<li style="color:red">EXISTING_OTHER_ID_TYPE ("catalog number" is OK)</li>
	<li style="color:red">EXISTING_OTHER_ID_NUMBER</li>
	<li style="color:red">NEW_OTHER_ID_TYPE</li>
	<li style="color:red">NEW_OTHER_ID_NUMBER</li>
</ul>


<cfform name="oids" method="post" enctype="multipart/form-data">
			<input type="hidden" name="Action" value="getFile">
			  <input type="file"
		   name="FiletoUpload"
		   size="45">
			  <input type="submit" value="Upload this file" #saveClr#>
  </cfform>

</cfif>
<!------------------------------------------------------->
<!------------------------------------------------------->

<!------------------------------------------------------->
<cfif #action# is "getFile">
<cfoutput>
	<!--- put this in a temp table --->
	<cfquery name="killOld" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		delete from cf_temp_oids
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
			<cfquery name="ins" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				insert into cf_temp_oids (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>
	<!----
	
	
		<cfset i=1>
	<cfloop index="line" list="#fileContent#" delimiters="#chr(10)#">
		<cfset sql = "">
		<cfset line = #replace(line,'#chr(9)##chr(9)#','#chr(9)#null#chr(9)#','all')#>
		<cfloop index="field" list="#line#" delimiters="#chr(9)#">
			<cfset field = #replace(field,"'","''","all")#>
			<cfset sql = #replace(sql,'{comma}',',','all')#>
			<cfset sql = "#sql#'#trim(replace(field,'"','','all'))#',">
			
		</cfloop>
	 	<cfset sql = #reverse(replace(reverse(sql),",","","first"))#>
		<cfset sql = "#i#,#sql#">
		<cfset i=#i#+1>
		<cfquery name="newRec" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			INSERT INTO cf_temp_oids (
				key,
				collection_cde,
				institution_acronym,
				existing_other_id_type,
				existing_other_id_number,
				new_other_id_type,
				new_other_id_number
				) 
			VALUES (
				#preservesinglequotes(sql)#
				)	 
			</cfquery>
    </cfloop>
	---->
	<cflocation url="BulkloadOtherId.cfm?action=validate">
</cfoutput>
</cfif>
<!------------------------------------------------------->
<!------------------------------------------------------->
<cfif #action# is "validate">
<cfoutput>

	<cfquery name="data" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		select * from cf_temp_oids
	</cfquery>
	<cfloop query="data">
		<cfif len(#existing_other_id_type#) is 0>
			You must specify an other ID type.
			<cfabort>
		</cfif>
		<cfif len(#existing_other_id_number#) is 0>
			You must specify an other ID number.
			<cfabort>
		</cfif>
		<cfif len(#collection_cde#) is 0>
			You must specify a collection_cde.
			<cfabort>
		</cfif>
		<cfif len(#institution_acronym#) is 0>
			You must specify a institution_acronym.
			<cfabort>
		</cfif>
		<cfif #existing_other_id_type# is not "catalog number">
			<cfquery name="collObj" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
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
						other_id_type = '#existing_other_id_type#' and
						display_value = '#existing_other_id_number#'
				</cfquery>
			<cfelse>
				<cfquery name="collObj" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
					SELECT 
						collection_object_id
					FROM
						cataloged_item,
						collection
					WHERE
						cataloged_item.collection_id = collection.collection_id and
						collection.collection_cde = '#collection_cde#' and
						collection.institution_acronym = '#institution_acronym#' and
						cat_num=#existing_other_id_number#
				</cfquery>
			</cfif>
			<cfif #collObj.recordcount# is not 1>
					
					#data.existing_other_id_number# #data.existing_other_id_type# #data.collection_cde# #data.institution_acronym#
					could not be found!
					<br>The load process has aborted!
					<br>You must fix the original file and start over.
					<cfabort>
			</cfif>
			<cfquery name="insColl" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				UPDATE cf_temp_oids SET collection_object_id = #collObj.collection_object_id# where
				key = #key#
			</cfquery>
			<cfquery name="isValid" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				select other_id_type from 
				ctcoll_other_id_type where other_id_type = '#new_other_id_type#' and collection_cde='#collection_cde#'
			</cfquery>
			<cfif #isValid.recordcount# is not 1>
				Other ID type #new_other_id_type# was not found for collection #collection_cde#
				<br>You must reload the file and start over.
			</cfif>
			
		</cfloop>
	<cflocation url="BulkloadOtherId.cfm?action=loadData">
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif #action# is "loadData">

<cfoutput>
	
		
	<cfquery name="getTempData" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		select * from cf_temp_oids
	</cfquery>
	
	<cftransaction>
	<cfloop query="getTempData">
		<!---<cfquery name="newID" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		 	{EXEC parse_other_id(#collection_object_id#, '#new_other_id_number#', '#new_other_id_type#')}
		</cfquery>
		--->
		<cfstoredproc procedure="parse_other_id" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
    
    
    <cfprocparam
      cfsqltype="cf_sql_numeric"
      value="#collection_object_id#">
      
    <cfprocparam
      cfsqltype="cf_sql_varchar"
      value="#new_other_id_number#">
	<cfprocparam
      cfsqltype="cf_sql_varchar"
      value="#new_other_id_type#">
      
  </cfstoredproc>
  
	</cfloop>
	</cftransaction>

	Spiffy, all done.
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">
