<!---
drop table cf_temp_media;
drop table cf_temp_media_relations;
drop table cf_temp_media_labels;

create table cf_temp_media (
 key NUMBER,
 status varchar2(255),
 MEDIA_URI VARCHAR2(255),
 MIME_TYPE VARCHAR2(255),
 MEDIA_TYPE VARCHAR2(255),
 PREVIEW_URI VARCHAR2(255),
 media_license varchar2(60),
 media_relationship_1 varchar2(60),
 media_related_key_1 number,
 media_related_term_1 varchar2(255),
 media_label_1 varchar2(60),
 media_label_value_1 varchar2(60),
 media_relationship_2 varchar2(60),
 media_related_key_2 number,
 media_related_term_2 varchar2(255),
 media_label_2 varchar2(60),
 media_label_value_2 varchar2(60)
);


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
<cfset title="Bulkload Media">
<cfset numLabels=2>
<cfset numRelns=2>
<cfif action is "makeTemplate">
	<cfset header="MEDIA_URI,MIME_TYPE,MEDIA_TYPE,PREVIEW_URI,media_license">
	<cfloop from="1" to="#nL#" index="i">
		<cfset header=listappend(header,"media_label_#i#")>
		<cfset header=listappend(header,"media_label_value_#i#")>
	</cfloop>
	<cfloop from="1" to="#nR#" index="i">
		<cfset header=listappend(header,"media_relationship_#i#")>
		<cfif hK is 1>
			<cfset header=listappend(header,"media_related_key_#i#")>
		</cfif>
		<cfset header=listappend(header,"media_related_term_#i#")>
	</cfloop>
	<cffile action = "write" 
    file = "#Application.webDirectory#/download/BulkMedia.csv"
    output = "#header#"
    addNewLine = "no">
	<cflocation url="/download.cfm?file=BulkMedia.csv" addtoken="false">


</cfif>
<cfif action is "nothing">
	<cfoutput>
	<cfparam name="nL" default="#numLabels#">
	<cfparam name="nR" default="#numRelns#">
	<cfparam name="hK" default="1">
	Step 1: Ensure that binary objects exist in a web-accessible location and objects media will relate to exist.

	Download CSV template:
	<form name="temp" method="post" action="BulkloadMedia.cfm">
		<input type="hidden" name="action" value="makeTemplate">
		<label for="nL">Number of Labels</label>
		<select name="nL" id="nL">
			<cfloop from="1" to="#numLabels#" index="i">
				<option <cfif i is nL> selected="selected" </cfif>value="#i#">#i#</option>
			</cfloop>
		</select>
		<label for="nR">Number of Relationships</label>
		<select name="nR" id="nR">
			<cfloop from="1" to="#numRelns#" index="i">
				<option <cfif i is nR> selected="selected" </cfif>value="#i#">#i#</option>
			</cfloop>
		</select>
		<label for="hK">include keys?</label>
		<select name="hK" id="hK">
			<option <cfif hK is 1> selected="selected" </cfif>value="1">yes</option>
			<option <cfif hK is 0> selected="selected" </cfif>value="0">no</option>
		</select>
		<br>
		<input type="submit" value="get template">
	</form>
	</cfoutput>
Step 2: Upload a comma-delimited text file (csv). 

This form will blindly accept related key assertions.

Project names may be either of:
<ul>
	<li>
		Exact string match
	</li>
	<li>
		"niceURL" (both a CF and Oracle function), of the form "willow-identification" (from project 
		"http://arctos.database.museum/project/willow-identification")
	</li>
</ul>

<cfinclude template="/info/ctDocumentation.cfm?table=ctmedia_relationship">

<cfinclude template="/info/ctDocumentation.cfm?table=ctmedia_label">

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
<cfif action is "getFile">
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
<cfif action is "validate">
<cfoutput>
<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from cf_temp_media
</cfquery>
<cfloop query="d">
	<cfset rec_stat="">
	<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select MIME_TYPE from CTMIME_TYPE where MIME_TYPE='#MIME_TYPE#'
	</cfquery>
	<cfif len(c.MIME_TYPE) is 0>
		<cfset rec_stat=listappend(rec_stat,'MIME_TYPE #MIME_TYPE# is invalid',";")>
	</cfif>
	<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
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
	<cfloop from="1" to="#numLabels#" index="i">
		<cfif len("media_label_#i#") gt 0>
			<cfset ln=evaluate("media_label_" & i)>
			<cfset lv=evaluate("media_label_value_" & i)>
			<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
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
		</cfif>
	</cfloop>
	
	
	
	
	
	
	<cfloop from="1" to="#numRelns#" index="i">
		<cfset pf="">
		<cfset r=evaluate("media_relationship_" & i)>
		<cfset rk=evaluate("media_related_key_" & i)>
		<cfset rt=evaluate("media_related_term_1" & i)>
		<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select MEDIA_RELATIONSHIP from CTMEDIA_RELATIONSHIP where MEDIA_RELATIONSHIP='#r#'
		</cfquery>
		<cfif len(c.MEDIA_RELATIONSHIP) is 0>
			<cfset rec_stat=listappend(rec_stat,'Media relationship #r# is invalid',";")>
			<cfset pf="f">
		</cfif>
		<cfif len(rk) gt 0 and len(rt) gt 0>
			<cfset rec_stat=listappend(rec_stat,'You cannot specify a relationship key and term',";")>
			<cfset pf="f">
		</cfif>
		<cfif len(pf) is 0>
			<cfset table_name = listlast(r," ")>
			<cfif len(rt) gt 0><!--- blindly accept related key assertions --->
				<cfif table_name is "agent">
					<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
						select distinct(agent_id) agent_id from agent_name where agent_name ='#rt#'
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
								'#r#',
								#session.myAgentId#,
								#c.agent_id#
							)
						</cfquery>
					<cfelse>
						<cfset rec_stat=listappend(rec_stat,'Agent #rt# matched #c.recordcount# records.',";")>
					</cfif>
				<cfelseif table_name is "project">
					<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
						select distinct(project_id) project_id from project where PROJECT_NAME ='#rt#'
					</cfquery>
					<cfif c.recordcount is 0>
						<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
							select distinct(project_id) project_id from project where niceurl(PROJECT_NAME) ='#rt#'
						</cfquery>
					</cfif>
					<cfif c.recordcount is 1 and len(c.project_id) gt 0>
						<cfquery name="i" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							insert into cf_temp_media_relations (
 								key,
								MEDIA_RELATIONSHIP,
								CREATED_BY_AGENT_ID,
								RELATED_PRIMARY_KEY
							) values (
								#key#,
								'#r#',
								#session.myAgentId#,
								#c.project_id#
							)
						</cfquery>
					<cfelse>
						<cfset rec_stat=listappend(rec_stat,'Project #lv# matched #c.recordcount# records.',";")>
					</cfif>
				<cfelseif table_name is "cataloged_item">
					<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
						select collection_object_id from 
							flat
						WHERE
							guid='#rt#'
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
								'#r#',
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
		</cfif>
	</cfloop>
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
	<a href="BulkloadMedia.cfm?action=load"><strong>click here</strong></a> to proceed.
	<br>^^^ that thing. You must click it.
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
