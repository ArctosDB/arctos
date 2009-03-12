<!---
drop table cf_temp_media;
drop table cf_temp_media_relations;
drop table cf_temp_media_labels;

create table cf_temp_media (
 key NUMBER,
 MEDIA_URI VARCHAR2(255),
 MIME_TYPE VARCHAR2(255),
 MEDIA_TYPE VARCHAR2(255),
 PREVIEW_URI VARCHAR2(255),
MEDIA_RELATIONSHIPS VARCHAR2(244),
 MEDIA_LABELS VARCHAR2(255)
);

alter table cf_temp_media add status varchar2(255);

create table cf_temp_media_relations (
 key NUMBER,
 MEDIA_RELATIONSHIP VARCHAR2(40),
 CREATED_BY_AGENT_ID NUMBER,
 RELATED_PRIMARY_KEY NUMBER
);

create table cf_temp_media_labels (
key NUMBER,
 MEDIA_LABEL VARCHAR2(255),
LABEL_VALUE VARCHAR2(255),
 ASSIGNED_BY_AGENT_ID NUMBER
);

create or replace public synonym cf_temp_media for cf_temp_media;
grant all on cf_temp_media to manage_media;
grant select on cf_temp_media to public;

create public synonym cf_temp_media_relations for cf_temp_media_relations;
grant all on cf_temp_media_relations to manage_media;
grant select on cf_temp_media_relations to public;

create public synonym cf_temp_media_labels for cf_temp_media_labels;
grant all on cf_temp_media_labels to manage_media;
grant select on cf_temp_media_labels to public;

CREATE OR REPLACE TRIGGER cf_temp_media_key                                         
 before insert  ON cf_temp_media  
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
		<textarea rows="2" cols="80" id="t">MEDIA_URI,MIME_TYPE,MEDIA_TYPE,PREVIEW_URI,MEDIA_RELATIONSHIPS,MEDIA_LABELS</textarea>
	</div> 
<p></p>




Columns in <span style="color:red">red</span> are required; others are optional:
<ul>
	<li style="color:red">MEDIA_URI</li>
	<li style="color:red">MIME_TYPE</li>
	<li style="color:red">MEDIA_TYPE</li>
	<li>PREVIEW_URI</li>
	<li>MEDIA_RELATIONSHIPS</li>
	<li>MEDIA_LABELS</li>			 
</ul>

<p>
	The format for MEDIA_RELATIONSHIPS is {media_relationship}={value}[;{media_relationship}={value}]
	<br>Examples:
	<ul>
		<li>
			created by agent=Carla Cicero
		</li>
		<li>
			created by agent=Carla Cicero;assigned to project=Vocal variation in Pipilo maculatus
		</li>
		<li>
			created by agent=Carla Cicero;assigned to project=Vocal variation in Pipilo maculatus;shows cataloged_item=MVZObs:Bird:12345
		</li>
	</ul>
	Acceptable values are:
	<ul>
		<li>Agent Name (must resolve to one agent_id)</li>
		<li>Project Title (exact string match)</li>
		<li>Cataloged Item (DWC triplet)</li>
	</ul>
	
</p>

<p>
	The format for MEDIA_LABELS is {media_label}={value}[;{media_label}={value}]
	<br>Examples:
	<ul>
		<li>
			audio bit resolution=whatever
		</li>
		<li>
			audio bit resolution=2;audio cut id=5
		</li>
		<li>
			audio bit resolution=2;audio cut id=5;made date=7 January 1964
		</li>
	</ul>
		
</p>
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
		delete from cf_temp_media
	</cfquery>
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		delete from cf_temp_media_relations
	</cfquery>
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		delete from cf_temp_media_labels
	</cfquery>
	
	
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	<cfset fileContent=replace(fileContent,"'","''","all")>
	<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />
	<cfdump var=#arrResult#>
	

	<cfset numberOfColumns = ArrayLen(arrResult[1])>

	
	<cfset colNames="">
	<cfloop from="1" to ="#ArrayLen(arrResult)#" index="o">
		<cfset colVals="">
			<cfloop from="1"  to ="#ArrayLen(arrResult[o])#" index="i">
				 <!---
				 <cfdump var="#arrResult[o]#">
				 --->
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
				insert into cf_temp_media (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>

		</cfif>
	</cfloop>
</cfoutput>
	<cflocation url="BulkloadMedia.cfm?action=validate">
 <!---

---->
</cfif>
<!------------------------------------------------------->
<!------------------------------------------------------->
<cfif #action# is "validate">
<cfoutput>
<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from cf_temp_media
</cfquery>
<cfdump var=#d#>
<cfloop query="d">
	<cfset rec_stat="">
	<cfif len(MEDIA_LABELS) gt 0>
		<cfloop list="#media_labels#" index="l" delimiters=";">
			<cfset ln=listgetat(l,1,"=")>
			<cfset lv=listgetat(l,2,"=")>
			<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select MEDIA_LABEL from CTMEDIA_LABEL where MEDIA_LABEL='#ln#'
			</cfquery>
			<cfif len(c.MEDIA_LABEL) is 0>
				<cfset rec_stat=listappend(rec_stat,'Media label #ln# is invalid',";")>
			<cfelse>
				<cfquery name="i" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					insert into cf_temp_media_labels (
						key,
						MEDIA_LABEL,
						ASSIGNED_BY_AGENT_ID,
						LABEL_VALUE
					) values (
						#key#,
						'#ln#',
						#session.myAgentId#,
						'#lv#'
					)
				</cfquery>
			</cfif>
		</cfloop>
	</cfif>
	<cfif len(MEDIA_RELATIONSHIPS) gt 0>
		<cfloop list="#MEDIA_RELATIONSHIPS#" index="l" delimiters=";">
			<cfset ln=listgetat(l,1,"=")>
			<cfset lv=listgetat(l,2,"=")>
			<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select MEDIA_RELATIONSHIP from CTMEDIA_RELATIONSHIP where MEDIA_RELATIONSHIP='#ln#'
			</cfquery>
			<cfif len(c.MEDIA_RELATIONSHIP) is 0>
				<cfset rec_stat=listappend(rec_stat,'Media relationship #ln# is invalid',";")>
			<cfelse>
				<cfset table_name = listlast(ln," ")>
				<cfif table_name is "agent">
					<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						select distinct(agent_id) agent_id from agent_name where agent_name ='#lv#'
					</cfquery>
					<cfif c.recordcount is 1 and len(c.agent_id) gt 0>
						<cfquery name="i" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							insert into cf_temp_media_relations (
 								key,
								MEDIA_RELATIONSHIP,
								CREATED_BY_AGENT_ID,
								RELATED_PRIMARY_KEY
							) values (
								#key#,
								'#ln#',
								#session.myAgentId#,
								#c.agent_id#
							)
						</cfquery>
					<cfelse>
						<cfset rec_stat=listappend(rec_stat,'Agent #lv# matched #c.recordcount# records.',";")>
					</cfif>
				<cfelseif table_name is "project">
					<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						select distinct(project_id) project_id from project where PROJECT_NAME ='#lv#'
					</cfquery>
					<cfif c.recordcount is 1 and len(c.project_id) gt 0>
						<cfquery name="i" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							insert into cf_temp_media_relations (
 								key,
								MEDIA_RELATIONSHIP,
								CREATED_BY_AGENT_ID,
								RELATED_PRIMARY_KEY
							) values (
								#key#,
								'#ln#',
								#session.myAgentId#,
								#c.project_id#
							)
						</cfquery>
					<cfelse>
						<cfset rec_stat=listappend(rec_stat,'Project #lv# matched #c.recordcount# records.',";")>
					</cfif>
				<cfelseif table_name is "cataloged_item">
					<cfset institution_acronym = listgetat(lv,1,":")>
					<cfset collection_cde = listgetat(lv,2,":")>
					<cfset cat_num = listgetat(lv,3,":")>
					<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						select collection_object_id from 
							cataloged_item,
							collection
						WHERE
							cataloged_item.collection_id = collection.collection_id AND
							cat_num = #cat_num# AND
							lower(collection.collection_cde)='#lcase(collection_cde)#' AND
							lower(collection.institution_acronym)='#lcase(institution_acronym)#'
					</cfquery>
					<cfif c.recordcount is 1 and len(c.collection_object_id) gt 0>
						<cfquery name="i" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							insert into cf_temp_media_relations (
 								key,
								MEDIA_RELATIONSHIP,
								CREATED_BY_AGENT_ID,
								RELATED_PRIMARY_KEY
							) values (
								#key#,
								'#ln#',
								#session.myAgentId#,
								#c.collection_object_id#
							)
						</cfquery>
					<cfelse>
						<cfset rec_stat=listappend(rec_stat,'Cataloged Item #lv# matched #c.recordcount# records.',";")>
					</cfif>
				<cfelse>
					<cfset rec_stat=listappend(rec_stat,'Media relationship #ln# is not handled',";")>
				</cfif>
			</cfif>
		</cfloop>
	</cfif>
	<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select MIME_TYPE from CTMIME_TYPE where MIME_TYPE='#MIME_TYPE#'
	</cfquery>
	<cfif len(c.MIME_TYPE) is 0>
		<cfset rec_stat=listappend(rec_stat,'MIME_TYPE #MIME_TYPE# is invalid',";")>
	</cfif>
	<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select MEDIA_TYPE from CTMEDIA_TYPE where MEDIA_TYPE='#MEDIA_TYPE#'
	</cfquery>
	<cfif len(c.MEDIA_TYPE) is 0>
		<cfset rec_stat=listappend(rec_stat,'MEDIA_TYPE #MEDIA_TYPE# is invalid',";")>
	</cfif>
	<cfhttp url="#media_uri#" charset="utf-8" method="get" />
	<cfif left(cfhttp.statuscode,3) is not "200">
		<cfset rec_stat=listappend(rec_stat,'#media_uri# is invalid',";")>
	</cfif>
	<cfif len(preview_uri) gt 0>
		<cfhttp url="#preview_uri#" charset="utf-8" method="get" />
		<cfif left(cfhttp.statuscode,3) is not "200">
			<cfset rec_stat=listappend(rec_stat,'#preview_uri# is invalid',";")>
		</cfif>
	</cfif>
	rec_stat: #rec_stat#
	<hr>
</cfloop>


<!----
<cfquery name="setStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	update cf_temp_agents set status='missing_data'
	where agent_type is null OR
	preferred_name is null
</cfquery>
<cfquery name="setStatus2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	update cf_temp_agents set status='bad_type'
	where status is null AND (
		agent_type not in (select agent_type from ctagent_type))
</cfquery>
<cfquery name="setStatus2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	update cf_temp_agents set status='bad_prefix'
	where status is null AND 
	prefix is not null and (
		prefix not in (select prefix from ctprefix))
</cfquery>
<cfquery name="setStatus2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	update cf_temp_agents set status='bad_suffix'
	where status is null AND 
	suffix is not null and (
		suffix not in (select suffix from ctsuffix))
</cfquery>
<cfquery name="setStatus2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	update cf_temp_agents set status='last_name_required'
	where status is null AND 
		agent_type ='person' and
		last_name is null
</cfquery>
<cfquery name="setStatus2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	update cf_temp_agents set status='not_a_person'
	where status is null AND 
	agent_type != 'person' and (
		suffix is not null OR
		prefix is not null OR
		birth_date is not null OR
		death_date is not null OR
		first_name is not null OR
		middle_name is not null OR
		last_name is not null)
</cfquery>
<cfquery name="setStatus2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	update cf_temp_agents set status='missing_name_type'
	where status is null AND 
	other_name is not null and other_name_type is null
</cfquery>
<cfquery name="setStatus2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	update cf_temp_agents set status='bad_name_type'
	where status is null AND 
	other_name is not null and other_name_type is not null and
	other_name_type not in (select agent_name_type from ctagent_name_type)
</cfquery>
<cfquery name="setStatus3" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	update cf_temp_agents set status='bad_name_type'
	where status is null AND 
	other_name_2 is not null and other_name_type_2 is not null and
	other_name_type_2 not in (select agent_name_type from ctagent_name_type)
</cfquery>
<cfquery name="setStatus4" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	update cf_temp_agents set status='bad_name_type'
	where status is null AND 
	other_name_3 is not null and other_name_type_3 is not null and
	other_name_type_3 not in (select agent_name_type from ctagent_name_type)
</cfquery>
<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from cf_temp_agents where status is not null
</cfquery>

<cfif bads.recordcount gt 0>
	Your data will not load! See STATUS column below for more information.
	<cfdump var=#bads#>
<cfelse>
	Review the dump below. If everything seems OK, 
	<a href="BulkloadAgents.cfm?action=loadData">click here to proceed</a>.
	<cfdump var=#d#>
</cfif>

---->
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif #action# is "loadData">

<cfoutput>
	
		
	<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from cf_temp_agents
	</cfquery>
	<cftransaction>
	<cfloop query="getTempData">
		<cfquery name="newAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			insert into agent ( AGENT_ID,AGENT_TYPE ,AGENT_REMARKS , PREFERRED_AGENT_NAME_ID)
			values (sq_agent_id.nextval,'#agent_type#','#agent_remark#',#agent_name_id#)
		</cfquery>
		<cfquery name="newAgentName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			insert into agent_name ( AGENT_NAME_ID,AGENT_ID,AGENT_NAME_TYPE,AGENT_NAME )
			values (sq_agent_name_id.nextval,sq_agent_id.currval,'preferred','#preferred_name#')
		</cfquery>
		
		<cfif #agent_type# is "person">
			<cfquery name="newProj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into person (PERSON_ID,PREFIX,LAST_NAME,FIRST_NAME,
					MIDDLE_NAME,SUFFIX,BIRTH_DATE,DEATH_DATE)
				values (sq_agent_id.currval,'#PREFIX#','#LAST_NAME#','#FIRST_NAME#',
					'#MIDDLE_NAME#','#SUFFIX#','#dateformat(BIRTH_DATE,"dd-mmm-yyyy")#', '#dateformat(DEATH_DATE,"dd-mmm-yyyy")#')
			</cfquery>
		</cfif>
		<cfif len(#OTHER_NAME#) gt 0>
			<cfset agent_name_id = #agent_name_id# + 1>
			<cfquery name="newAgentName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into agent_name ( AGENT_NAME_ID,AGENT_ID,AGENT_NAME_TYPE,AGENT_NAME )
				values (sq_agent_name_id.nextval,sq_agent_id.currval,'#OTHER_NAME_TYPE#','#OTHER_NAME#')
			</cfquery>
		</cfif>
        <cfif len(#OTHER_NAME_2#) gt 0>
			<cfset agent_name_id = #agent_name_id# + 1>
			<cfquery name="newAgentName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into agent_name ( AGENT_NAME_ID,AGENT_ID,AGENT_NAME_TYPE,AGENT_NAME )
				values (sq_agent_name_id.nextval,sq_agent_id.currval,'#OTHER_NAME_TYPE_2#','#OTHER_NAME_2#')
			</cfquery>
		</cfif>
        <cfif len(#OTHER_NAME_3#) gt 0>
			<cfset agent_name_id = #agent_name_id# + 1>
			<cfquery name="newAgentName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into agent_name ( AGENT_NAME_ID,AGENT_ID,AGENT_NAME_TYPE,AGENT_NAME )
				values (sq_agent_name_id.nextval,sq_agent_id.currval,'#OTHER_NAME_TYPE_3#','#OTHER_NAME_3#')
			</cfquery>
		</cfif>
	</cfloop>
	</cftransaction>

	Spiffy, all done.
</cfoutput>
</cfif>

<cfinclude template="/includes/_footer.cfm">
