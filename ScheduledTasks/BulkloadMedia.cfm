<cfinclude template="/includes/_header.cfm">
<cfset numLabels=10>
<cfset numRelns=5>
<cfif not isdefined("debug")><cfset debug=false></cfif>
<!------------------------------------------------------->
<cfif action is "nothing">
	<a href="BulkloadMedia.cfm?action=validate&debug=true">validate&debug</a>
	<br><a href="BulkloadMedia.cfm?action=report">report</a>
	<br><a href="BulkloadMedia.cfm?action=cleanup">cleanup</a>
	<br><a href="BulkloadMedia.cfm?action=load">load</a>

</cfif>
<cfif action is "report">
	<cfoutput>
	<cfquery name="who" datasource="uam_god">
		select username,user_agent_id from cf_temp_media group by username,user_agent_id
	</cfquery>
	<cfloop query="who">
		<cfquery name="e" datasource="uam_god">
			select get_address(#user_agent_id#,'email') address from dual
		</cfquery>
		<cfquery name="s" datasource="uam_god">
			select status, count(*) c from cf_temp_media where username='#username#' group by status
		</cfquery>

		<cfif len(e.address) is 0>
			<cfset mailto="arctos.database@gmail.com">
			<cfset msubj="media bulkloader: no contact info">
		<cfelse>

			<cfset mailto=e.address>
			<cfset msubj="media bulkloader">

		</cfif>
		<cfmail to="#mailto#" bcc="arctos.database@gmail.com" subject="#msubj#" cc="#Application.LogEmail#" from="bulkmedia@#Application.fromEmail#" type="html">
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
	select * from cf_temp_media where status is null and rownum<51
</cfquery>
#d.recordcount#....
<cfif debug is true>
	#d.recordcount#....
	<cfdump var=#d#>
	</cfif>
<cfloop query="d">
	<cftransaction>
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
		<cfif debug is true>
			<cfdump var=#cfhttp#>
		</cfif>
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
			<cfif debug is true>
				<cfdump var=#cfhttp#>
			</cfif>
			<cfif left(cfhttp.statuscode,3) is not "200">
				<cfset rec_stat=listappend(rec_stat,'#preview_uri# is invalid',";")>
			</cfif>
		</cfif>
		<cfif debug>
			<br>start labels...
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
					<cfif debug>
						<br>media_label_#i# (#ln#) is invalid'
					</cfif>
				</cfif>
			</cfif>
		</cfloop>

		<cfif debug>
			<br>start relationships...
		</cfif>
		<cfloop from="1" to="#numRelns#" index="i">
			<cfset pf="">
			<cfset r=evaluate("media_relationship_" & i)>
				<cfif debug is true>
					<br>r: #r#
				</cfif>
				<cfif len(r) gt 0>
				<cfset rk=evaluate("media_related_key_" & i)>
				<cfset rt=evaluate("media_related_term_" & i)>
				<cfif debug>
					<br>rk: #rk#
					<br>rt: #rt#
				</cfif>
				<cfquery name="c" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
					select MEDIA_RELATIONSHIP from CTMEDIA_RELATIONSHIP where MEDIA_RELATIONSHIP='#r#'
				</cfquery>
				<cfif len(c.MEDIA_RELATIONSHIP) is 0>
					<cfset rec_stat=listappend(rec_stat,'Media relationship #r# is invalid',";")>
					<cfset pf="f">
				</cfif>
				<cfif len(rk) gt 0 and len(rt) gt 0>
					<!--- ignore event lookups, they're legit ---->
					<cfif not (listlast(r," ") is "collecting_event" and rt is "lookup")>
						<cfset rec_stat=listappend(rec_stat,'You cannot specify a relationship key and term',";")>
						<cfset pf="f">
					</cfif>
				</cfif>
				<cfif len(pf) is 0>
					<cfset table_name = listlast(r," ")>
					<cfif debug is true>
						<br>table_name:==#table_name#=============
					</cfif>
					<cfif len(rt) gt 0>
						<cfif table_name is "agent">
							<cfquery name="c" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
								select distinct(agent_id) agent_id from agent_name where agent_name ='#rt#'
							</cfquery>
							<cfif c.recordcount is 1 and len(c.agent_id) gt 0>
								<cfquery name="i" datasource="uam_god">
									update cf_temp_media set media_related_key_#i#=#c.agent_id# where key=#key#
								</cfquery>
							<cfelse>
								<cfset rec_stat=listappend(rec_stat,'Agent #rt# matched #c.recordcount# records.',";")>
							</cfif>
						<cfelseif table_name is "collecting_event">
							<cfif len(rk) is 0 and rt is "lookup">

								<p>
									running getMakeCollectingEvent.....
								</p>
								<!--- get a collecting event or throw an error ---->
								<!----
									well crap
									CF10 ignores dbvarname
									so we have to pass these things in in order or fail
									crap.
									srsly.
									crap.
								---->
								<cftry>
								<cfstoredproc procedure="getMakeCollectingEvent" datasource="uam_god">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#COLLECTING_EVENT_ID#" dbvarname="v_COLLECTING_EVENT_ID">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#COLLECTING_EVENT_NAME#" dbvarname="v_COLLECTING_EVENT_NAME">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#VERBATIM_DATE#" dbvarname="v_VERBATIM_DATE">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#BEGAN_DATE#" dbvarname="v_BEGAN_DATE">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#ENDED_DATE#" dbvarname="v_ENDED_DATE">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#VERBATIM_LOCALITY#" dbvarname="v_VERBATIM_LOCALITY">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#COLL_EVENT_REMARKS#" dbvarname="v_COLL_EVENT_REMARKS">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#LOCALITY_ID#" dbvarname="v_LOCALITY_ID">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#SPEC_LOCALITY#" dbvarname="v_SPEC_LOCALITY">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#LOCALITY_NAME#" dbvarname="v_LOCALITY_NAME">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#ORIG_ELEV_UNITS#" dbvarname="v_ORIG_ELEV_UNITS">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#MINIMUM_ELEVATION#" dbvarname="v_MINIMUM_ELEVATION">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#MAXIMUM_ELEVATION#" dbvarname="v_MAXIMUM_ELEVATION">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#DEPTH_UNITS#" dbvarname="v_DEPTH_UNITS">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#MIN_DEPTH#" dbvarname="v_MIN_DEPTH">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#MAX_DEPTH#" dbvarname="v_MAX_DEPTH">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#ORIG_LAT_LONG_UNITS#" dbvarname="v_ORIG_LAT_LONG_UNITS">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#DATUM#" dbvarname="v_DATUM">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#GEOREFERENCE_SOURCE#" dbvarname="v_GEOREFERENCE_SOURCE">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#GEOREFERENCE_PROTOCOL#" dbvarname="v_GEOREFERENCE_PROTOCOL">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#MAX_ERROR_UNITS#" dbvarname="v_MAX_ERROR_UNITS">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#MAX_ERROR_DISTANCE#" dbvarname="v_MAX_ERROR_DISTANCE">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#DEC_LAT#" dbvarname="v_DEC_LAT">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#DEC_LONG#" dbvarname="v_DEC_LONG">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#LAT_DEG#" dbvarname="v_LAT_DEG">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#LAT_MIN#" dbvarname="v_LAT_MIN">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#LAT_SEC#" dbvarname="v_LAT_SEC">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#LAT_DIR#" dbvarname="v_LAT_DIR">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#LONG_DEG#" dbvarname="v_LONG_DEG">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#LONG_MIN#" dbvarname="v_LONG_MIN">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#LONG_SEC#" dbvarname="v_LONG_SEC">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#LONG_DIR#" dbvarname="v_LONG_DIR">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#DEC_LAT_MIN#" dbvarname="v_DEC_LAT_MIN">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#DEC_LONG_MIN#" dbvarname="v_DEC_LONG_MIN">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#UTM_ZONE#" dbvarname="v_UTM_ZONE">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#UTM_EW#" dbvarname="v_UTM_EW">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#UTM_NS#" dbvarname="v_UTM_NS">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#WKT_POLYGON#" dbvarname="v_WKT_POLYGON">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#LOCALITY_REMARKS#" dbvarname="v_LOCALITY_REMARKS">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#HIGHER_GEOG#" dbvarname="v_HIGHER_GEOG">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geology_attribute_1#" dbvarname="v_geology_attribute_1">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_value_1#" dbvarname="v_geo_att_value_1">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determined_date_1#" dbvarname="v_geo_att_determined_date_1">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determiner_1#" dbvarname="v_geo_att_determiner_1">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determined_method_1#" dbvarname="v_geo_att_determined_method_1">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_remark_1#" dbvarname="v_geo_att_remark_1">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geology_attribute_2#" dbvarname="v_geology_attribute_2">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_value_2#" dbvarname="v_geo_att_value_2">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determined_date_2#" dbvarname="v_geo_att_determined_date_2">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determiner_2#" dbvarname="v_geo_att_determiner_2">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determined_method_2#" dbvarname="v_geo_att_determined_method_2">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_remark_2#" dbvarname="v_geo_att_remark_2">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geology_attribute_3#" dbvarname="v_geology_attribute_3">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_value_3#" dbvarname="v_geo_att_value_3">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determined_date_3#" dbvarname="v_geo_att_determined_date_3">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determiner_3#" dbvarname="v_geo_att_determiner_3">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determined_method_3#" dbvarname="v_geo_att_determined_method_3">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_remark_3#" dbvarname="v_geo_att_remark_3">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geology_attribute_4#" dbvarname="v_geology_attribute_4">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_value_4#" dbvarname="v_geo_att_value_4">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determined_date_4#" dbvarname="v_geo_att_determined_date_4">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determiner_4#" dbvarname="v_geo_att_determiner_4">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determined_method_4#" dbvarname="v_geo_att_determined_method_4">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_remark_4#" dbvarname="v_geo_att_remark_4">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geology_attribute_5#" dbvarname="v_geology_attribute_5">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_value_5#" dbvarname="v_geo_att_value_5">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determined_date_5#" dbvarname="v_geo_att_determined_date_5">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determiner_5#" dbvarname="v_geo_att_determiner_5">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determined_method_5#" dbvarname="v_geo_att_determined_method_5">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_remark_5#" dbvarname="v_geo_att_remark_5">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geology_attribute_6#" dbvarname="v_geology_attribute_6">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_value_6#" dbvarname="v_geo_att_value_6">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determined_date_6#" dbvarname="v_geo_att_determined_date_6">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determiner_6#" dbvarname="v_geo_att_determiner_6">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determined_method_6#" dbvarname="v_geo_att_determined_method_6">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_remark_6#" dbvarname="v_geo_att_remark_6">
									<cfprocparam type="out" cfsqltype="cf_sql_numeric" variable="ceid" dbvarname="v_r_ceid">
								</cfstoredproc>
								<cfif debug>
									<p>
										update cf_temp_media set media_related_key_#i#=#ceid# where key=#key#
									</p>
								</cfif>
								<cfquery name="i" datasource="uam_god">
									update cf_temp_media set media_related_key_#i#=#ceid# where key=#key#
								</cfquery>
								<cfcatch>
									<cfset rec_stat=listappend(rec_stat,'event unresolvable: #cfcatch.message# #cfcatch.detail#',";")>
									<cfif debug>
										<br>catch!
										<br>#cfcatch.message# #cfcatch.detail#'
										<br>rec_stat: #rec_stat#
									</cfif>
								</cfcatch>
								</cftry>
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
									update cf_temp_media set media_related_key_#i#=#c.project_id# where key=#key#
								</cfquery>
							<cfelse>
								<cfset rec_stat=listappend(rec_stat,'Project #lv# matched #c.recordcount# records.',";")>
							</cfif>
						<cfelseif table_name is "media">
							<cfquery name="c" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
								select distinct(media_id) media_id from media where media_uri ='#rt#'
							</cfquery>
							<cfif c.recordcount is 1 and len(c.media_id) gt 0>
								<cfquery name="i" datasource="uam_god">
									update cf_temp_media set media_related_key_#i#=#c.media_id# where key=#key#
								</cfquery>
							<cfelse>
								<cfset rec_stat=listappend(rec_stat,'Media #lv# matched #c.recordcount# records.',";")>
							</cfif>
						<cfelseif table_name is "cataloged_item">
							<cfif debug is true>
								-----------here we are now-------------
								---------------
								select collection_object_id from
										flat
									WHERE
										guid='#rt#'
										---------
							</cfif>
							<!--- accepts GUID or barcode. We're screwed if anyone ever orders barcodes with a guid-like format, but until then....---->
							<cfif listlen(rt,':') is 3>
								<!--- guid --->
								<cfquery name="c" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
									select collection_object_id from
										flat
									WHERE
										guid='#rt#'
								</cfquery>
							<cfelse>
								<!--- barcode or stoopids --->
								<cfquery name="c" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
									select flat.collection_object_id from
										flat,
										container child,
										container parent,
										specimen_part,
										coll_obj_cont_hist
									WHERE
										flat.collection_object_id=specimen_part.derived_from_cat_item and
										specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
										coll_obj_cont_hist.container_id=child.container_id and
										child.parent_container_id=parent.container_id and
										parent.barcode='#rt#'
								</cfquery>
							</cfif>
							<cfif debug is true>
								<cfdump var=#c#>
							</cfif>
							<cfif c.recordcount is 1 and len(c.collection_object_id) gt 0>
								<cfquery name="i" datasource="uam_god">
									update cf_temp_media set media_related_key_#i#=#c.collection_object_id# where key=#key#
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
		<cfif len(rec_stat) gt 254>
			<cfset rec_stat=left(rec_stat,250) & '...'>
		</cfif>
		<cfif debug>
			<br>final: #rec_stat#
			<hr>
		</cfif>
		<cfquery name="c" datasource="uam_god">
			update cf_temp_media set status='#trim(rec_stat)#' where key=#key#
		</cfquery>
	</cftransaction>
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
				<cfloop from="1" to="#numRelns#" index="i">
					<cfset r=evaluate("media_relationship_" & i)>
					<cfif len(r) gt 0>
						<cfset rk=evaluate("media_related_key_" & i)>
						<cfset table_name = listlast(r," ")>
						<cfquery name="makeRelation" datasource="uam_god">
							insert into media_relations (
								media_id,media_relationship,related_primary_key,CREATED_BY_AGENT_ID
							) values (
								#media_id#,'#r#',#rk#,#user_agent_id#
							)
						</cfquery>
					</cfif>
				</cfloop>
				<cfloop from="1" to="#numLabels#" index="i">
					<cfset ln=evaluate("media_label_" & i)>
					<cfif len(ln) gt 0>
						<cfset ln=evaluate("media_label_" & i)>
						<cfset lv=evaluate("media_label_value_" & i)>
						<cfquery name="makeRelation" datasource="uam_god">
							insert into media_labels (
								media_id,media_label,label_value,ASSIGNED_BY_AGENT_ID
							) values (
								#media_id#,'#ln#','#lv#',#media.user_agent_id#
							)
						</cfquery>
					</cfif>
				</cfloop>
				<cfquery name="tm" datasource="uam_god">
					update cf_temp_media set status='loaded',loaded_media_id=#media_id# where key=#key#
				</cfquery>
				<cfcatch>
					<cftransaction action="rollback">
					<cfset temp=cfcatch.message & ": " & cfcatch.detail>
					<cfif isdefined("cfcatch.sql")>
						<cfset temp=temp & ":: " & cfcatch.sql>
					</cfif>
					<cfquery name="tm" datasource="uam_god">
						update cf_temp_media set status='#trim(temp)#' where key=#key#
					</cfquery>
				</cfcatch>
			</cftry>
		</cftransaction>
	</cfloop>
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">