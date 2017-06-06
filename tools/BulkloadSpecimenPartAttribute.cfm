<!-----
BulkloadSpecimenPartAttribute.cfm


drop table cf_temp_specPartAttr;



create table cf_temp_specPartAttr (
	key number not null,
	status varchar2(255),
	guid varchar2(60) not null,
	part_name varchar2(60) not null,
	ATTRIBUTE_TYPE varchar2(60) not null,
	ATTRIBUTE_VALUE varchar2(60) not null,
	ATTRIBUTE_UNITS  varchar2(60),
	DETERMINED_DATE  varchar2(60),
	determiner  varchar2(60),
	remark  varchar2(4000),
	part_id number,
	spec_id number
);
create or replace public synonym cf_temp_specPartAttr for cf_temp_specPartAttr;

grant all on cf_temp_specPartAttr to coldfusion_user;


CREATE OR REPLACE TRIGGER trg_cf_temp_specprtat_biu
    BEFORE INSERT OR UPDATE ON cf_temp_specPartAttr
    FOR EACH ROW
    BEGIN
  	if :NEW.key is null then
		select somerandomsequence.nextval into :new.key from dual;
    end if;
end;
/
sho err


---->
<cfinclude template="/includes/_header.cfm">
<cfsetting requestTimeOut = "1200">

<cfif action is  "nothing">
	Use this form to ADD specimen part attributes.

	<p>
		This form will only work if GUID + part_name is unique. (File an Issue for more.)
	</p>
	<p>
		This form INSERTs; that is all. "Old" data will not be changed in any way.
	</p>
	<p>
		This form will happily make duplicates. Be careful!
	</p>
	<p>
		<a href="BulkloadSpecimenPartAttribute.cfm?action=makeTemplate">download a CSV template</a>
	</p>
	<table border>
		<tr>
			<th>Column</th>
			<th>Required?</th>
			<th>more</th>
		</tr>
		<tr>
			<td>guid</td>
			<td>yes</td>
			<td>UAM:Mamm:12 format</td>
		</tr>
		<tr>
			<td>part_name</td>
			<td>yes</td>
			<td>existing part name</td>
		</tr>
		<tr>
			<td>ATTRIBUTE_TYPE</td>
			<td>yes</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTSPECPART_ATTRIBUTE_TYPE">CTSPECPART_ATTRIBUTE_TYPE</a></td>
		</tr>
		<tr>
			<td>ATTRIBUTE_VALUE</td>
			<td>yes</td>
			<td>varies</td>
		</tr>

		<tr>
			<td>ATTRIBUTE_UNITS</td>
			<td>conditionally</td>
			<td>varies</td>
		</tr>
		<tr>
			<td>DETERMINED_DATE</td>
			<td>no</td>
			<td>ISO8601</td>
		</tr>
		<tr>
			<td>determiner</td>
			<td>no</td>
			<td>Unique agent name</td>
		</tr>
		<tr>
			<td>remark</td>
			<td>no</td>
			<td>-</td>
		</tr>
	</table>

	Upload CSV:
	<form name="getFile" method="post" action="BulkloadSpecimenPartAttribute.cfm" enctype="multipart/form-data">
		<input type="hidden" name="action" value="getFileData">
		 <input type="file"
			   name="FiletoUpload"
			   size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" class="savBtn">
	</form>
</cfif>


<!------------------------------------------------------------------------------------------------>


<cfif action is "makeTemplate">
	<cfset header="guid,part_name,ATTRIBUTE_TYPE,ATTRIBUTE_VALUE,ATTRIBUTE_UNITS,DETERMINED_DATE,determiner,remark">

	<cffile action = "write"
    file = "#Application.webDirectory#/download/BulkloadSpecimenPartAtt.csv"
    output = "#header#"
    addNewLine = "no">
	<cflocation url="/download.cfm?file=BulkloadSpecimenPartAtt.csv" addtoken="false">
</cfif>


<!------------------------------------------------------------------------------------------------>
<cfif action is "getFileData">
	<cfoutput>
		<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
        <cfset  util = CreateObject("component","component.utilities")>
		<cfset x=util.CSVToQuery(fileContent)>
        <cfset cols=x.columnlist>
        <cfloop query="x">
            <cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	            insert into cf_temp_specPartAttr (#cols#) values (
	            <cfloop list="#cols#" index="i">
	            	'#stripQuotes(evaluate(i))#'
	            	<cfif i is not listlast(cols)>
	            		,
	            	</cfif>
	            </cfloop>
	            )
            </cfquery>
        </cfloop>
		Loaded to table. Now <a href="BulkloadSpecimenPartAttribute.cfm?action=validate">validate</a>
	</cfoutput>
</cfif>






<!---------------------------------------------------------------------------->
<cfif action is "validate">

	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_specPartAttr
	</cfquery>
	<cfoutput>
		<cfloop query="d">
			<cftransaction>
				<cfset sid=''>
				<cfset pid=''>
				<cfquery name="a" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select
						cataloged_item.collection_object_id sid,
						specimen_part.collection_object_id pid
					from
						collection
						cataloged_item,
						specimen_part
					where
						collection.collection_id=cataloged_item.collection_id and
						cataloged_item.collection_object_id=specimen_part.derived_from_cat_item and
						collection.guid_prefix || ':' || cataloged_item.cat_num = '#guid#' and
						specimen_part.part_name='#part_name#'
				</cfquery>
				<cfif a.recordcount is not 1 or len(a.sid) lt 1 or len(a.pid) lt 1>
					fail
					<cfdump var=#a#>
				<cfelse>
					<br>got spec and part
				</cfif>


			</cftransaction>
		</cfloop>
	</cfoutput>


yokay
</cfif>
<!------------------------------------------------------------------------------------------------>
<cfif action is "load">
	<cfoutput>
		<p>
			IMPORTANT!! This application will load as many records as it can before it times out. That number varies wildly depending on
			how much data must be created, heterogeneity of data being created, and maybe sunspot activity.
		</p>
		<p>
			SCROLL TO THE BOTTOM OF THIS PAGE after it stops loading, which will take a couple minutes. If there are timeout errors, hit reload or
			go back to <a href="BulkloadSpecimenEvent.cfm?action=managemystuff">the manage screen</a> and hit load again.
		</p>
		<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_temp_specevent where status='valid' and upper(username)='#ucase(session.username)#'
		</cfquery>
		<cfloop query="data">
			<cftransaction>
				<cfset lcl_locality_id=l_locality_id>
				<cfset lcl_collecting_event_id=l_collecting_event_id>
				<p>
					running for <a href="/guid/#guid#" target="_blank">#guid#</a>
					<cfif lcl_collecting_event_id is 0>
						<!--- we'll have to find or build an event - see about locality ---->
						<cfif lcl_locality_id is 0>
							<!--- we'll have to find or build a locality ---->
							<!--- coordinates? --->
							<cfif orig_lat_long_units is 'deg. min. sec.'>
								<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
									select  dms_to_string ('#latdeg#','#latmin#','#latsec#','#latdir#','#longdeg#','#longmin#','#longsec#','#longdir#') vc from dual
								</cfquery>
								<cfset verbatimcoordinates=data.vc>
							<cfelseif orig_lat_long_units is 'degrees dec. minutes'>
								<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
									select  dm_to_string ('#latdeg#','#dec_lat_min#','#latdir#','#longdeg#','#dec_long_min#''#longdir#') vc from dual
								</cfquery>
								<cfset verbatimcoordinates=data.vc>
							<cfelseif orig_lat_long_units is 'decimal degrees'>
								<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
									select  dd_to_string ('#DEC_LAT#','#DEC_LONG#') vc from dual
								</cfquery>
								<cfset verbatimcoordinates=data.vc>
							<cfelseif orig_lat_long_units is 'UTM'>
								<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
									select  utm_to_string ('#UTM_NS#','#UTM_EW#','#UTM_ZONE#') vc from dual
								</cfquery>
								<cfset verbatimcoordinates=data.vc>
							<cfelse>
								<cfset verbatimcoordinates=''>
							</cfif>
							<cfif len(wkt_polygon) is 0>
								<cfset wkthash=''>
							<cfelse>
								<cfset wkthash=hash(wkt_polygon)>
							</cfif>

							<!---
								locality_name IS NULL AND -- because we tested that above and will use it if it exists
							--->
							<cfquery name="eLoc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								select nvl(min(locality.locality_id),-1) locality_id
					            FROM
					            	locality
					            WHERE
					                geog_auth_rec_id = #l_geog_auth_rec_id# AND
					                NVL(MAXIMUM_ELEVATION,-1) = NVL('#maximum_elevation#',-1) AND
					            	NVL(MINIMUM_ELEVATION,-1) = NVL('#minimum_elevation#',-1) AND
					            	NVL(ORIG_ELEV_UNITS,'NULL') = NVL('#orig_elev_units#','NULL') AND
					            	NVL(MIN_DEPTH,-1) = nvl('#min_depth#',-1) AND
					            	NVL(MAX_DEPTH,-1) = nvl('#max_depth#',-1) AND
					            	NVL(SPEC_LOCALITY,'NULL') = NVL('#spec_locality#','NULL') AND
					            	NVL(LOCALITY_REMARKS,'NULL') = NVL('#locality_remarks#','NULL') AND
					            	NVL(DEPTH_UNITS,'NULL') = NVL('#depth_units#','NULL') AND
					            	NVL(dec_lat,-1) = nvl('#dec_lat#',-1) AND
					            	NVL(dec_long,-1) = nvl('#dec_long#',-1) AND
                                    NVL(md5hash(wkt_polygon),'NULL') = nvl('#wkthash#','NULL') AND
					            	locality_name IS NULL AND
					                locality_id not in (select locality_id from geology_attributes)
							</cfquery>
							<cfif eLoc.locality_id gt 0>
								<br>found existing locality
								<cfset lcl_locality_id=eLoc.locality_id>
							<cfelse>
								<br>making locality

								<!--- make a locality ---->
								<cfquery name="nLocId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
									select sq_locality_id.nextval nv from dual
								</cfquery>
								<cfset lid=nLocId.nv>
								<cfquery name="newLocality" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
									INSERT INTO locality (
										LOCALITY_ID,
										GEOG_AUTH_REC_ID,
										MAXIMUM_ELEVATION,
										MINIMUM_ELEVATION,
										ORIG_ELEV_UNITS,
										SPEC_LOCALITY,
										LOCALITY_REMARKS,
										DEPTH_UNITS,
										MIN_DEPTH,
										MAX_DEPTH,
										DEC_LAT,
										DEC_LONG,
										MAX_ERROR_DISTANCE,
										MAX_ERROR_UNITS,
										DATUM,
										georeference_source,
										georeference_protocol,
										wkt_polygon
									)  values (
										#lid#,
										#l_geog_auth_rec_id#,
										<cfif len(MAXIMUM_ELEVATION) gt 0>
											#MAXIMUM_ELEVATION#
										<cfelse>
											NULL
										</cfif>,
										<cfif len(MINIMUM_ELEVATION) gt 0>
											#MINIMUM_ELEVATION#
										<cfelse>
											NULL
										</cfif>,
										'#ORIG_ELEV_UNITS#',
										'#SPEC_LOCALITY#',
										'#LOCALITY_REMARKS#',
										'#DEPTH_UNITS#',
										<cfif len(MIN_DEPTH) gt 0>
											#MIN_DEPTH#
										<cfelse>
											NULL
										</cfif>,
										<cfif len(MAX_DEPTH) gt 0>
											#MAX_DEPTH#
										<cfelse>
											NULL
										</cfif>,
										<cfif len(DEC_LAT) gt 0>
											#DEC_LAT#
										<cfelse>
											NULL
										</cfif>,
										<cfif len(DEC_LONG) gt 0>
											#DEC_LONG#
										<cfelse>
											NULL
										</cfif>,
										<cfif len(MAX_ERROR_DISTANCE) gt 0>
											#MAX_ERROR_DISTANCE#
										<cfelse>
											NULL
										</cfif>,
										'#MAX_ERROR_UNITS#',
										'#DATUM#',
										'#georeference_source#',
										'#georeference_protocol#',
										 <cfqueryparam value="#wkt_polygon#" cfsqltype="cf_sql_clob">
									)
								</cfquery>
								<cfset lcl_locality_id=lid>
							</cfif>
						</cfif>
						<!--- we should have a locality_id here, so see if we have a collecting_event.---->
						<cfquery name="findEvent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							select
					    	    nvl(MIN(collecting_event_id),-1) collecting_event_id
					    	from
					    	    collecting_event
					    	where
					    	    locality_id = #lcl_locality_id# and
					    	    nvl(verbatim_date,'NULL') = nvl('#verbatim_date#','NULL') and
					    	    nvl(VERBATIM_LOCALITY,'NULL') = nvl('#VERBATIM_LOCALITY#','NULL') and
					    	    nvl(COLL_EVENT_REMARKS,'NULL') = nvl('#COLL_EVENT_REMARKS#','NULL') and
					    	    nvl(began_date,'NULL') = nvl('#began_date#','NULL') and
					    	    nvl(ended_date,'NULL') = nvl('#ended_date#','NULL') and
					    	    COLLECTING_EVENT_NAME IS NULL AND -- or we'd have found it at that check
					    	    nvl(verbatim_coordinates,'NULL') = nvl('#verbatimcoordinates#','NULL') and
					    	    nvl(DATUM,'NULL') = nvl('#DATUM#','NULL') and
					    	    nvl(ORIG_LAT_LONG_UNITS,'NULL') = nvl('#ORIG_LAT_LONG_UNITS#','NULL')
		   	    		</cfquery>
		   				<cfif findEvent.collecting_event_id gt 0>
							<cfset lcl_collecting_event_id=findEvent.collecting_event_id>
						<cfelse>
							<!---- make a collecting event ---->
							<cfquery name="nCevId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								select sq_collecting_event_id.nextval nv from dual
							</cfquery>
							<cfset lcl_collecting_event_id=nCevId.nv>
							<cfquery name="makeEvent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					    		insert into collecting_event (
					    			collecting_event_id,
					    			locality_id,
					    			verbatim_date,
					    			VERBATIM_LOCALITY,
					    			began_date,
					    			ended_date,
					    			coll_event_remarks,
					    			LAT_DEG,
					    			DEC_LAT_MIN,
					    			LAT_MIN,
					    			LAT_SEC,
					    			LAT_DIR,
					    			LONG_DEG,
					    			DEC_LONG_MIN,
					    			LONG_MIN,
					    			LONG_SEC,
					    			LONG_DIR,
					    			DEC_LAT,
					    			DEC_LONG,
					    			DATUM,
					    			UTM_ZONE,
					    			UTM_EW,
					    			UTM_NS,
					    			ORIG_LAT_LONG_UNITS
					    		) values (
					    			#lcl_collecting_event_id#,
					    			#lcl_locality_id#,
					    			'#verbatim_date#',
					    			'#VERBATIM_LOCALITY#',
					    			'#began_date#',
					    			'#ended_date#',
					    			'#coll_event_remarks#',
					    			<cfif len(LAT_DEG) gt 0>
										#LAT_DEG#
									<cfelse>
										NULL
									</cfif>,
					    			<cfif len(DEC_LAT_MIN) gt 0>
										#DEC_LAT_MIN#
									<cfelse>
										NULL
									</cfif>,
					    			<cfif len(LAT_MIN) gt 0>
										#LAT_MIN#
									<cfelse>
										NULL
									</cfif>,
					    			<cfif len(LAT_SEC) gt 0>
										#LAT_SEC#
									<cfelse>
										NULL
									</cfif>,
					    			'#LAT_DIR#',
					    			<cfif len(LONG_DEG) gt 0>
										#LONG_DEG#
									<cfelse>
										NULL
									</cfif>,
					    			<cfif len(DEC_LONG_MIN) gt 0>
										#DEC_LONG_MIN#
									<cfelse>
										NULL
									</cfif>,
					    			<cfif len(LONG_MIN) gt 0>
										#LONG_MIN#
									<cfelse>
										NULL
									</cfif>,
					    			<cfif len(LONG_SEC) gt 0>
										#LONG_SEC#
									<cfelse>
										NULL
									</cfif>,
					    			'#LONG_DIR#',
					    			<cfif len(DEC_LAT) gt 0>
										#DEC_LAT#
									<cfelse>
										NULL
									</cfif>,
					    			<cfif len(DEC_LONG) gt 0>
										#DEC_LONG#
									<cfelse>
										NULL
									</cfif>,
					    			'#DATUM#',
					    			'#UTM_ZONE#',
					    			<cfif len(UTM_EW) gt 0>
										#UTM_EW#
									<cfelse>
										NULL
									</cfif>,
					    			<cfif len(UTM_NS) gt 0>
										#UTM_NS#
									<cfelse>
										NULL
									</cfif>,
					    			'#ORIG_LAT_LONG_UNITS#'
					    		)
		   					</cfquery>
						</cfif>
					</cfif>
					<!--- at this point, we should have a collecting event ID, so make the specimen_event --->
					<cfquery name="makeSpecEvent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						INSERT INTO specimen_event (
				            COLLECTION_OBJECT_ID,
				            COLLECTING_EVENT_ID,
				            ASSIGNED_BY_AGENT_ID,
				            ASSIGNED_DATE,
				            SPECIMEN_EVENT_REMARK,
				            SPECIMEN_EVENT_TYPE,
				            COLLECTING_METHOD,
				            COLLECTING_SOURCE,
				            VERIFICATIONSTATUS,
				            HABITAT
				        ) VALUES (
				            #l_collection_object_id#,
				            #lcl_collecting_event_id#,
				            #l_event_assigned_id#,
				            '#ASSIGNED_DATE#',
				            '#SPECIMEN_EVENT_REMARK#',
				            '#SPECIMEN_EVENT_TYPE#',
				            '#COLLECTING_METHOD#',
				            '#COLLECTING_SOURCE#',
				            '#VERIFICATIONSTATUS#',
				            '#HABITAT#'
				        )
					</cfquery>
					<br>inserted for <a href="http://arctos.database.museum/SpecimenDetail.cfm?collection_object_id=#l_collection_object_id#">#l_collection_object_id#</a>
					<cfquery name="gotit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						delete from cf_temp_specevent where key=#key#
					</cfquery>
					<br>deleted for #l_collection_object_id#
				</p>
			</cftransaction>
		</cfloop>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">