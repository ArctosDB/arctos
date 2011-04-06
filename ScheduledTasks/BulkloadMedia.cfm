<cfinclude template="/includes/_header.cfm">
<cfset numLabels=10>
<cfset numRelns=5>
<!------------------------------------------------------->
<cfif action is "report">
	<cfoutput>
	<cfquery name="who" datasource="uam_god">
		select username,user_agent_id from cf_temp_media group by username,user_agent_id
	</cfquery>
	<cfloop query="who">
		<cfquery name="e" datasource="uam_god">
			select address from electronic_address where address_type='e-mail' and agent_id=#user_agent_id#
		</cfquery>
		<cfquery name="s" datasource="uam_god">
			select status, count(*) c from cf_temp_media where username='#username#' group by status
		</cfquery>
		<cfmail to="#e.address#" bcc="arctos.database@gmail.com" subject="media bulkloader" cc="arctos.database@gmail.com" from="bulkmedia@#Application.fromEmail#" type="html">
			Dear #username#,
			<p>
				The following records are in the Media Bulkloader:
			</p>
			<p>
			<cfloop query="s">
				<br>#status#: #c#
			</cfloop>
			</p>
			<p>
			After logging in to Arctos, you may follow the links from the Media Bulkloader 
			(http://arctos.database.museum/tools/BulkloadMedia.cfm?action=myStuff) to review detailed status
			messages or delete your records. You will receive daily reminders until you have deleted all records in
			your temporary table.
			</p>
		</cfmail>
	</cfloop>
	</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "cleanup">
	<cfquery name="killOld" datasource="uam_god">
		delete from cf_temp_media_relations where key not in (select key from cf_temp_media)
	</cfquery>
	<cfquery name="killOld" datasource="uam_god">
		delete from cf_temp_media_labels where key not in (select key from cf_temp_media)
	</cfquery>
</cfif>
<!------------------------------------------------------->
<cfif action is "validate">
<cfoutput>
<cfset stime=now()>
<cfquery name="d" datasource="uam_god">
	select * from cf_temp_media where status is null and rownum<50
</cfquery>
#d.recordcount#....
<cfloop query="d">
	<cfset rec_stat="">
	<cfif len(media_license) gt 0>
		<cfquery name="ml" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select MEDIA_LICENSE_ID from ctmedia_license where display='#media_license#'
		</cfquery>
		<cfif len(ml.MEDIA_LICENSE_ID) is 0>
			<cfset rec_stat=listappend(rec_stat,'media license is invalid',";")>
		<cfelse>
			<cfquery name="mlk" datasource="uam_god">
				update cf_temp_media set media_license_id=#ml.media_license_id# where key=#key#
			</cfquery>
		</cfif>
	</cfif>
	<cfquery name="c" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select MIME_TYPE from CTMIME_TYPE where MIME_TYPE='#MIME_TYPE#'
	</cfquery>
	<cfif len(c.MIME_TYPE) is 0>
		<cfset rec_stat=listappend(rec_stat,'MIME_TYPE #MIME_TYPE# is invalid',";")>
	</cfif>
	<cfquery name="c" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select MEDIA_TYPE from CTMEDIA_TYPE where MEDIA_TYPE='#MEDIA_TYPE#'
	</cfquery>
	<cfif len(c.MEDIA_TYPE) is 0>
		<cfset rec_stat=listappend(rec_stat,'MEDIA_TYPE #MEDIA_TYPE# is invalid',";")>
	</cfif>
	<cfhttp url="#media_uri#" charset="utf-8" method="head" />
	<cfif left(cfhttp.statuscode,3) is not "200">
		<cfset rec_stat=listappend(rec_stat,'#media_uri# is invalid',";")>
	</cfif>
	<cfquery name="ago" datasource="uam_god">
		select count(*) c from media where media_uri='#media_uri#'
	</cfquery>
	<cfif ago.c is not 0>
		<cfset rec_stat=listappend(rec_stat,'#media_uri# already exists',";")>
	</cfif>
	<cfif len(preview_uri) gt 0>
		<cfhttp url="#preview_uri#" charset="utf-8" method="head" />
		<cfif left(cfhttp.statuscode,3) is not "200">
			<cfset rec_stat=listappend(rec_stat,'#preview_uri# is invalid',";")>
		</cfif>
	</cfif>
	<cfloop from="1" to="#numLabels#" index="i">
		<cfset ln=evaluate("media_label_" & i)>
		<cfif len(ln) gt 0>
			<cfset ln=evaluate("media_label_" & i)>
			<cfset lv=evaluate("media_label_value_" & i)>
			<cfquery name="c" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
				select MEDIA_LABEL from CTMEDIA_LABEL where MEDIA_LABEL='#ln#'
			</cfquery>
			<cfif len(c.MEDIA_LABEL) is 0>
				<cfset rec_stat=listappend(rec_stat,'media_label_#i# (#ln#) is invalid',";")>
			<cfelse>
				<cfquery name="i" datasource="uam_god">
					insert into cf_temp_media_labels (
						key,
						MEDIA_LABEL,
						ASSIGNED_BY_AGENT_ID,
						LABEL_VALUE
					) values (
						#key#,
						'#ln#',
						#user_agent_id#,
						'#lv#'
					)
				</cfquery>
			</cfif>
		</cfif>
	</cfloop>
	
	<cfloop from="1" to="#numRelns#" index="i">
		<cfset pf="">
		<cfset r=evaluate("media_relationship_" & i)>
			<cfif len(r) gt 0>
			<cfset rk=evaluate("media_related_key_" & i)>
			<cfset rt=evaluate("media_related_term_" & i)>
			<cfquery name="c" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
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
						<cfquery name="c" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
							select distinct(agent_id) agent_id from agent_name where agent_name ='#rt#'
						</cfquery>
						<cfif c.recordcount is 1 and len(c.agent_id) gt 0>
							<cfquery name="i" datasource="uam_god">
								insert into cf_temp_media_relations (
	 								key,
									MEDIA_RELATIONSHIP,
									CREATED_BY_AGENT_ID,
									RELATED_PRIMARY_KEY
								) values (
									#key#,
									'#r#',
									#user_agent_id#,
									#c.agent_id#
								)
							</cfquery>
						<cfelse>
							<cfset rec_stat=listappend(rec_stat,'Agent #rt# matched #c.recordcount# records.',";")>
						</cfif>
					<cfelseif table_name is "project">
						<cfquery name="c" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
							select distinct(project_id) project_id from project where PROJECT_NAME ='#rt#'
						</cfquery>
						<cfif c.recordcount is 0>
							<cfquery name="c" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
								select distinct(project_id) project_id from project where niceurl(PROJECT_NAME) ='#rt#'
							</cfquery>
						</cfif>
						<cfif c.recordcount is 1 and len(c.project_id) gt 0>
							<cfquery name="i" datasource="uam_god">
								insert into cf_temp_media_relations (
	 								key,
									MEDIA_RELATIONSHIP,
									CREATED_BY_AGENT_ID,
									RELATED_PRIMARY_KEY
								) values (
									#key#,
									'#r#',
									#user_agent_id#,
									#c.project_id#
								)
							</cfquery>
						<cfelse>
							<cfset rec_stat=listappend(rec_stat,'Project #lv# matched #c.recordcount# records.',";")>
						</cfif>
					<cfelseif table_name is "cataloged_item">
						<cfquery name="c" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
							select collection_object_id from 
								flat
							WHERE
								guid='#rt#'
						</cfquery>
						<cfif c.recordcount is 1 and len(c.collection_object_id) gt 0>
							<cfquery name="i" datasource="uam_god">
								insert into cf_temp_media_relations (
	 								key,
									MEDIA_RELATIONSHIP,
									CREATED_BY_AGENT_ID,
									RELATED_PRIMARY_KEY
								) values (
									#key#,
									'#r#',
									#user_agent_id#,
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
		</cfif>
	</cfloop>
	<cfif len(rec_stat) is 0>
		<cfset rec_stat='pass'>
	</cfif>
	<cfquery name="c" datasource="uam_god">
		update cf_temp_media set status='#rec_stat#' where key=#key#
	</cfquery>
</cfloop>
<cfset qtime=now()>
#stime#----------#qtime#
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "load">
<cfoutput>
	<cfquery name="media" datasource="uam_god">
		select 
			*
		from 
			cf_temp_media where status='pass' and rownum<500
	</cfquery>
	<cfloop query="media">
		<cftransaction>
			<cftry>
				<cfquery name="mid" datasource="uam_god">
					select sq_media_id.nextval nv from dual
				</cfquery>
				<cfset media_id=mid.nv>
				<cfquery name="makeMedia" datasource="uam_god">
					insert into media (media_id,media_uri,mime_type,media_type,preview_uri,media_license_id)
		            values (#media_id#,'#escapeQuotes(media_uri)#','#mime_type#','#media_type#','#preview_uri#',
		            <cfif len(media_license_id) gt 0>
						#media_license_id#
					<cfelse>
						NULL
					</cfif>)
				</cfquery>
				<cfquery name="media_relations" datasource="uam_god">
					select 
						*
					from 
						cf_temp_media_relations
					where
						key=#key#
				</cfquery>
				<cfloop query="media_relations">
					<cfquery name="makeRelation" datasource="uam_god">
						insert into 
							media_relations (
							media_id,media_relationship,related_primary_key,CREATED_BY_AGENT_ID
							)values (
							#media_id#,'#MEDIA_RELATIONSHIP#',#RELATED_PRIMARY_KEY#,#media.user_agent_id#)
					</cfquery>
				</cfloop>
				<cfquery name="medialabels" datasource="uam_god">
					select 
						*
					from 
						cf_temp_media_labels
					where
						key=#key#
				</cfquery>
				<cfloop query="medialabels">
					<cfquery name="makeRelation" datasource="uam_god">
						insert into media_labels (media_id,media_label,label_value,ASSIGNED_BY_AGENT_ID)
						values (#media_id#,'#MEDIA_LABEL#','#LABEL_VALUE#',#media.user_agent_id#)
					</cfquery>
				</cfloop>
				<cfquery name="tm" datasource="uam_god">
					update cf_temp_media set status='loaded',loaded_media_id=#media_id# where key=#key#
				</cfquery>
				<cfcatch>
					<cfquery name="tm" datasource="uam_god">
						update cf_temp_media set status='#cfcatch.message#: #cfcatch.detail#' where key=#key#
					</cfquery>
				</cfcatch>
			</cftry>
		</cftransaction>
	</cfloop>
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">