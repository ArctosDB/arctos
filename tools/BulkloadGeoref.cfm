<!---
drop table cf_temp_georef;

create table cf_temp_georef (
	key NUMBER NOT NULL,
	DETERMINED_BY_AGENT_ID number,
 	HigherGeography VARCHAR2(255) NOT NULL,
 	SpecLocality VARCHAR2(255) NOT NULL,
	Locality_ID number NOT NULL,
	Dec_Lat NUMBER(12,10),
	Dec_Long NUMBER(13,10),
	MAX_ERROR_DISTANCE number,
	MAX_ERROR_UNITS VARCHAR2(2),
	LAT_LONG_REMARKS VARCHAR2(255),
	DETERMINED_BY_AGENT VARCHAR2(255) NOT NULL,
	GEOREFMETHOD VARCHAR2(255) NOT NULL,
	ORIG_LAT_LONG_UNITS VARCHAR2(20) NOT NULL,
	DATUM VARCHAR2(55) NOT NULL,
	DETERMINED_DATE DATE NOT NULL,
	LAT_LONG_REF_SOURCE VARCHAR2(255) NOT NULL,
	EXTENT NUMBER(8,3),
	GPSACCURACY NUMBER(8,3),
	VERIFICATIONSTATUS VARCHAR2(40) NOT NULL,
	SPATIALFIT NUMBER(4,3)
);


create or replace public synonym cf_temp_georef for cf_temp_georef;
grant all on cf_temp_georef to manage_locality;
grant select on cf_temp_georef to public;

CREATE OR REPLACE TRIGGER cf_temp_georef_key                                         
 before insert  ON cf_temp_georef  
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
	HigherGeography, SpecLocality, and locality_id must all match Arctos data or this form will not work.
	<br>
	<a href="http://g-arctos.appspot.com/arctosdoc/lat_long.html">Help is here</a>
	
Step 1: Ensure that Media and objects media will relate to exist.
Step 2: Upload a comma-delimited text file (csv). 
Include column headings, spelled exactly as below. 
<br><span class="likeLink" onclick="document.getElementById('template').style.display='block';">view template</span>
	<div id="template" style="display:none;">
		<label for="t">Copy and save as a .csv file</label>
		<textarea rows="2" cols="80" id="t">HigherGeography,SpecLocality,Locality_ID,Dec_Lat,Dec_Long,MAX_ERROR_DISTANCE,MAX_ERROR_UNITS,LAT_LONG_REMARKS,DETERMINED_BY_AGENT,GEOREFMETHOD,ORIG_LAT_LONG_UNITS,DATUM,DETERMINED_DATE,LAT_LONG_REF_SOURCE,EXTENT,GPSACCURACY,VERIFICATIONSTATUS,SPATIALFIT</textarea>
	</div> 
<p></p>
Columns in <span style="color:red">red</span> are required; others are optional:
<ul>
	<li style="color:red">HigherGeography</li>
	<li style="color:red">SpecLocality</li>
	<li style="color:red">Locality_ID</li>
	<li style="color:red">Dec_Lat</li>
	<li style="color:red">Dec_Long</li>
	<li style="color:red">DETERMINED_BY_AGENT</li>
	<li style="color:red">GEOREFMETHOD<span class="infoLink" onclick="getCtDoc('ctGEOREFMETHOD','');">Define</span></li>
	<li style="color:red">ORIG_LAT_LONG_UNITS<span class="infoLink" onclick="getCtDoc('CTLAT_LONG_UNITS','');">Define</span></li>
	<li style="color:red">DATUM<span class="infoLink" onclick="getCtDoc('CTDATUM','');">Define</span></li>
	<li style="color:red">DETERMINED_DATE</li>
	<li style="color:red">LAT_LONG_REF_SOURCE</li>
	<li style="color:red">VERIFICATIONSTATUS<span class="infoLink" onclick="getCtDoc('CTVERIFICATIONSTATUS','');">Define</span></li>
	<li>MAX_ERROR_DISTANCE</li>
	<li>MAX_ERROR_UNITS<span class="infoLink" onclick="getCtDoc('CTLAT_LONG_ERROR_UNITS','');">Define</span></li>
	<li>LAT_LONG_REMARKS</li>
	<li>EXTENT</li>	
	<li>GPSACCURACY</li>	
	<li>SPATIALFIT</li>			 
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
		delete from cf_temp_georef
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
				insert into cf_temp_georef (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>

		</cfif>
	</cfloop>
</cfoutput>
 <!---
	<cflocation url="BulkloadMedia.cfm?action=validate">

---->
</cfif>
<!------------------------------------------------------->
<!------------------------------------------------------->
<cfif #action# is "validate">
<cfoutput>
<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from cf_temp_media
</cfquery>
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
				<cfelseif table_name is "collecting_event">
					<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						select collecting_event_id from collecting_event where collecting_event_id ='#lv#'
					</cfquery>
					<cfif c.recordcount is 1 and len(c.collecting_event_id) gt 0>
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
								#c.collecting_event_id#
							)
						</cfquery>
					<cfelse>
						<cfset rec_stat=listappend(rec_stat,'collecting_event #lv# matched #c.recordcount# records.',";")>
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
					<cftry>
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
					<cfcatch>
						<cfset rec_stat=listappend(rec_stat,'#lv# is not a proper DWC Triplet.',";")>
					</cfcatch>
					</cftry>
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
	<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update cf_temp_media set status='#rec_stat#' where key=#key#
	</cfquery>
</cfloop>
<cfquery name="bad" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from cf_temp_media where status is not null
</cfquery>
<cfif len(bad.key) gt 0>
	Oops! You must fix everything below before proceeding (see STATUS column).
	<cfdump var=#bad#>
<cfelse>
	Yay! Everything looks OK. Check it over in the tables below, then 
	<a href="BulkloadMedia.cfm?action=load">click here</a> to proceed.
	(Note that the table below is "flattened." Media entries are repeated for every Label and Relationship.)
	<cfquery name="media" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			cf_temp_media.key, 
			status,
			MEDIA_URI,
			MIME_TYPE,
			MEDIA_TYPE,
			PREVIEW_URI,
			MEDIA_RELATIONSHIP,
			RELATED_PRIMARY_KEY,
			MEDIA_LABEL,
			LABEL_VALUE
		from 
			cf_temp_media,
			cf_temp_media_labels,
			cf_temp_media_relations
		where
			cf_temp_media.key=cf_temp_media_labels.key (+) and
			cf_temp_media.key=cf_temp_media_relations.key (+)
		group by
			cf_temp_media.key, 
			status,
			MEDIA_URI,
			MIME_TYPE,
			MEDIA_TYPE,
			PREVIEW_URI,
			MEDIA_RELATIONSHIP,
			RELATED_PRIMARY_KEY,
			MEDIA_LABEL,
			LABEL_VALUE
	</cfquery>
	<cfdump var=#media#>	
</cfif>
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif #action# is "load">
<cfoutput>
	<cfquery name="media" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			*
		from 
			cf_temp_media
	</cfquery>
	<cftransaction>
		<cfloop query="media">
			<cfquery name="mid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select sq_media_id.nextval nv from dual
			</cfquery>
			<cfset media_id=mid.nv>
			<cfquery name="makeMedia" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into media (media_id,media_uri,mime_type,media_type,preview_uri)
	            values (#media_id#,'#escapeQuotes(media_uri)#','#mime_type#','#media_type#','#preview_uri#')
			</cfquery>
			<cfquery name="media_relations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
					*
				from 
					cf_temp_media_relations
				where
					key=#key#
			</cfquery>
			<cfloop query="media_relations">
				<cfquery name="makeRelation" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					insert into 
						media_relations (
						media_id,media_relationship,related_primary_key
						)values (
						#media_id#,'#MEDIA_RELATIONSHIP#',#RELATED_PRIMARY_KEY#)
				</cfquery>
			</cfloop>
			<cfquery name="medialabels" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
					*
				from 
					cf_temp_media_labels
				where
					key=#key#
			</cfquery>
			<cfloop query="medialabels">
				<cfquery name="makeRelation" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					insert into media_labels (media_id,media_label,label_value)
					values (#media_id#,'#MEDIA_LABEL#','#LABEL_VALUE#')
				</cfquery>
			</cfloop>
		</cfloop>
	</cftransaction>
	Spiffy, all done.
</cfoutput>
</cfif>

<cfinclude template="/includes/_footer.cfm">
