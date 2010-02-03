<cfinclude template="/includes/_header.cfm">
<cfset title="Bulkload Identification">
<!---- make the table 

drop table cf_temp_id;
drop public synonym cf_temp_id;

create table cf_temp_id (
	key number,
	collection_object_id number,
	collection_cde varchar2(4),
	institution_acronym varchar2(6),
	other_id_type varchar2(60),
	other_id_number varchar2(60),
	scientific_name varchar2(255),
	made_date date,
	nature_of_id varchar2(30),
	accepted_fg number(1),
	identification_remarks varchar2(255),
	agent_1 varchar2(60),
	agent_2 varchar2(60),
	status varchar2(255),
	taxon_name_id number,
	taxa_formula varchar2(10),
	agent_1_id number,
	agent_2_id number
);
create public synonym cf_temp_id for cf_temp_id;
grant select,insert,update,delete on cf_temp_id to manage_specimens;

CREATE OR REPLACE TRIGGER cf_temp_id_key                                         
 before insert  ON cf_temp_id  
 for each row 
    begin     
    	if :NEW.key is null then                                                                                      
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;                                
    end;                                                                                            
/
sho err
------>
<cfif #action# is "nothing">
Step 1: Upload a comma-delimited text file (csv). 
Include column headings, spelled exactly as below. 
<br><span class="likeLink" onclick="document.getElementById('template').style.display='block';">view template</span>
	<div id="template" style="display:none;">
		<label for="t">Copy the following code and save as a .csv file</label>
		<textarea rows="2" cols="80" id="t">collection_cde,institution_acronym,other_id_type,other_id_number,scientific_name,made_date,nature_of_id,accepted_fg,identification_remarks,agent_1,agent_2</textarea>
	</div> 
<p></p>
<ul>
	<li style="color:red">institution_acronym</li>
	<li style="color:red">collection_cde</li>
	<li style="color:red">other_id_type ("catalog number" is OK)</li>
	<li style="color:red">other_id_number</li>
	<li style="color:red">scientific_name</li>
	<li>made_date</li>
	<li style="color:red">nature_of_id</li>
	<li style="color:red">accepted_fg (0 [no] or 1 [yes])</li>
	<li>identification_remarks</li>
	<li style="color:red">agent_1</li>
	<li>agent_2</li>
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
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		delete from cf_temp_id
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
				insert into cf_temp_id (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>	
	<cflocation url="BulkloadIdentification.cfm?action=validate" addtoken="false">	
</cfoutput>
</cfif>
<!------------------------------------------------------->

<!------------------------------------------------------->
<cfif #action# is "validate">
<cfoutput>
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update cf_temp_id set status='missing data'
		where
		other_id_type is null or
		other_id_number is null or
		collection_cde is null or
		institution_acronym is null or
		scientific_name is null or
		nature_of_id is null or
		accepted_fg is null or
		agent_1 is null
	</cfquery>
	
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from cf_temp_id where status is null
	</cfquery>
	<cfloop query="data">
		<cfset problem="">
		<cfif #other_id_type# is not "catalog number">
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
						other_id_type = '#trim(other_id_type)#' and
						display_value = '#trim(other_id_number)#'
				</cfquery>
			<cfelse>
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
						cat_num=#other_id_number#
				</cfquery>
			</cfif>
			<cfif #collObj.recordcount# is not 1>
				<cfif len(#problem#) is 0>
					<cfset problem = "SELECT 
						collection_object_id
					FROM
						cataloged_item,
						collection
					WHERE
						cataloged_item.collection_id = collection.collection_id and
						collection.collection_cde = '#collection_cde#' and
						collection.institution_acronym = '#institution_acronym#' and
						cat_num=#other_id_number#">
				<cfelse>
					<cfset problem = "#problem#; #data.other_id_number# #data.other_id_type# #data.collection_cde# #data.institution_acronym# could not be found">
				</cfif>
			<cfelse>
				<cfquery name="insColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					UPDATE cf_temp_id SET collection_object_id = #collObj.collection_object_id# where
					key = #key#
				</cfquery>
			</cfif>
			<cfif right(scientific_name,4) is " sp.">
				<cfset scientific_name=left(scientific_name,len(scientific_name) -4)>
				<cfset tf = "A sp.">
				<cfset TaxonomyTaxonName=left(scientific_name,len(scientific_name) - 4)>
			<cfelseif right(scientific_name,4) is " cf.">
				<cfset scientific_name=left(scientific_name,len(scientific_name) -4)>
				<cfset tf = "A cf.">
				<cfset TaxonomyTaxonName=left(scientific_name,len(scientific_name) - 4)>
			<cfelseif right(scientific_name,2) is " ?">
				<cfset scientific_name=left(scientific_name,len(scientific_name) -2)>
				<cfset tf = "A ?">
				<cfset TaxonomyTaxonName=left(scientific_name,len(scientific_name) - 2)>
			<cfelse>
				<cfset  tf = "A">
				<cfset TaxonomyTaxonName="#scientific_name#">
			</cfif>

			<cfquery name="isTaxa" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				SELECT taxon_name_id FROM taxonomy WHERE scientific_name = '#TaxonomyTaxonName#'
				AND valid_catalog_term_fg=1
			</cfquery>
			<cfif #isTaxa.recordcount# is not 1>
				<cfif len(#problem#) is 0>
					<cfset problem = "taxonomy not found">
				<cfelse>
					<cfset problem = "#problem#; taxonomy not found">
				</cfif>
			<cfelse>
				<cfquery name="insColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					UPDATE cf_temp_id SET taxon_name_id = #isTaxa.taxon_name_id#,taxa_formula='#tf#' where
					key = #key#
				</cfquery>
			</cfif>
			<cfquery name="noid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select count(*) c from ctnature_of_id where nature_of_id='#nature_of_id#'
			</cfquery>
			<cfif #noid.c# is not 1>
				<cfif len(#problem#) is 0>
					<cfset problem = "nature_of_id not found">
				<cfelse>
					<cfset problem = "#problem#; nature_of_id not found">
				</cfif>
			</cfif>
			<cfif accepted_fg is not 1 and accepted_fg is not 0>
				<cfif len(#problem#) is 0>
					<cfset problem = "accepted_fg must be 1 or 0">
				<cfelse>
					<cfset problem = "#problem#; accepted_fg must be 1 or 0">
				</cfif>
			</cfif>
			<cfquery name="a1" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select agent_id from agent_name where agent_name='#agent_1#'
			</cfquery>
			<cfif #a1.recordcount# is not 1>
				<cfif len(#problem#) is 0>
					<cfset problem = "agent_1 matched #a1.recordcount# records">
				<cfelse>
					<cfset problem = "#problem#; agent_1 matched #a1.recordcount# records">
				</cfif>
			<cfelse>
				<cfquery name="insColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					UPDATE cf_temp_id SET agent_1_id = #a1.agent_id# where
					key = #key#
				</cfquery>
			</cfif>
			<cfif len(agent_2) gt 0>
				<cfquery name="a2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select agent_id from agent_name where agent_name='#agent_2#'
				</cfquery>
				<cfif #a2.recordcount# is not 1>
					<cfif len(#problem#) is 0>
						<cfset problem = "agent_2 matched #a2.recordcount# records">
					<cfelse>
						<cfset problem = "#problem#; agent_2 matched #a2.recordcount# records">
					</cfif>
				<cfelse>
					<cfquery name="insColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						UPDATE cf_temp_id SET agent_2_id = #a2.agent_id# where
						key = #key#
					</cfquery>
				</cfif>
			</cfif>
			<cfif len(#problem#) gt 0>
				<cfquery name="insColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					UPDATE cf_temp_id SET status = '#problem#' where
					key = #key#
				</cfquery>
			</cfif>
		</cfloop>
		
		<cfquery name="valData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from cf_temp_id order by status,
			other_id_type,
			other_id_number
		</cfquery>
		<cfquery name="isProb" dbtype="query">
			select count(*) c from valData where status is not null
		</cfquery>
		 #isProb.c#
		<cfif #isProb.c# is 0 or len(isprob.c) is 0>
			Data validated. Double-check below. If everything looks OK, <a href="BulkloadIdentification.cfm?action=loadData">proceed to load</a>
		<cfelse>
			The data you loaded do not validate. See STATUS column below.
		</cfif>
		<cfdump var=#valData#>
		<!---
	<cflocation url="BulkloadCitations.cfm?action=loadData">
	---->
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif #action# is "loadData">
<cfoutput>		
	<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from cf_temp_id
	</cfquery>
	<cftransaction>
	<cfloop query="getTempData">
		<cfif ACCEPTED_FG is 1>
			<cfquery name="whackOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				update identification set ACCEPTED_ID_FG=0 where COLLECTION_OBJECT_ID=#COLLECTION_OBJECT_ID#
			</cfquery>
		</cfif>
		<cfquery name="insert" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			insert into identification (
				IDENTIFICATION_ID,
				COLLECTION_OBJECT_ID,
				MADE_DATE,
				NATURE_OF_ID,
				ACCEPTED_ID_FG,
				IDENTIFICATION_REMARKS,
				TAXA_FORMULA,
				SCIENTIFIC_NAME
			) values (
				sq_identification_id.nextval,
				#COLLECTION_OBJECT_ID#,
				to_date('#dateformat(MADE_DATE,"dd-mmm-yyyy")#'),
				'#NATURE_OF_ID#',
				#ACCEPTED_FG#,
				'#IDENTIFICATION_REMARKS#',
				'#TAXA_FORMULA#',
				'#SCIENTIFIC_NAME#'				
			)
		</cfquery>
		<cfquery name="insertidt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			insert into identification_taxonomy (
				IDENTIFICATION_ID,
				TAXON_NAME_ID,
				VARIABLE
			) values (
				sq_identification_id.currval,
				#TAXON_NAME_ID#,
				'A'
			)
		</cfquery>
		<cfquery name="insertida1" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			insert into identification_agent (
				IDENTIFICATION_ID,
				AGENT_ID,
				IDENTIFIER_ORDER
			) values (
				sq_identification_id.currval,
				#agent_1_id#,
				1
			)
		</cfquery>
		<cfif len(agent_2_id) gt 0>
			<cfquery name="insertida1" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into identification_agent (
					IDENTIFICATION_ID,
					AGENT_ID,
					IDENTIFIER_ORDER
				) values (
					sq_identification_id.currval,
					#agent_2_id#,
					2
				)
			</cfquery>
		</cfif>
		<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			update cf_temp_id set status='loaded' where key=#key#			
		</cfquery>
	</cfloop>
	</cftransaction>
<cflocation url="BulkloadIdentification.cfm?action=allDone">
</cfoutput>
</cfif>
<!-------------------------------------------------------------------------->
<cfif #action# is "allDone">
	<cfoutput>
		<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select count(*) c from cf_temp_id where status != 'loaded'
		</cfquery>
		<cfif #getTempData.c# is not 0>
			Something very strange happened. Contact a sysadmin.
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select * from cf_temp_id
			</cfquery>
			<cfdump var=#d#>		
		<cfelse>
			Spiffy! Tis done.
		</cfif>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">