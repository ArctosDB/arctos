<!-----

drop table cf_temp_geog;



create table cf_temp_geog (
	key number not null,
	status varchar2(255),
	CONTINENT_OCEAN varchar2(255),
	COUNTRY varchar2(255),
	STATE_PROV varchar2(255),
	COUNTY varchar2(255),
	QUAD varchar2(255),
	FEATURE varchar2(255),
	ISLAND varchar2(255),
	ISLAND_GROUP varchar2(255),
	SEA varchar2(255),
	SOURCE_AUTHORITY varchar2(255),
	GEOG_REMARK varchar2(255),
	srchtrm_1 varchar2(255),
	srchtrm_2 varchar2(255),
	srchtrm_3 varchar2(255),
	srchtrm_4 varchar2(255),
	srchtrm_5 varchar2(255)
);

create or replace public synonym cf_temp_geog for cf_temp_geog;

grant all on cf_temp_geog to coldfusion_user;


CREATE OR REPLACE TRIGGER trg_cf_temp_geog_biu
    BEFORE INSERT ON cf_temp_geog
    FOR EACH ROW
    BEGIN
	   if :NEW.key is null then
	   	:NEW.key:=sq_somerandomsequence.nextval;
	   end if;
end;
/


---->
<cfinclude template="/includes/_header.cfm">
	<cfsetting requestTimeOut = "1200">


<cfset title="geog">

<cfif action is  "nothing">
	Use this form to ADD specimen-events.
	<p>
		<a href="BulkloadSpecimenEvent.cfm?action=upfish">fishnet repatriation upload</a> (see code for usage - you'll need pl/sql access to use this)
	</p>
	<p>
		You may NOT create localities with geology attributes from this form - create them in Arctos, name them, and use locality_name here.
		<a href="/contact.cfm">contact us</a> if you need other functionality.
	</p>
	<p>
		Localities and events will be re-used if possible or created if nothing suitable exists.
	</p>
	<p>
		Coordinates will go to collecting_event (verbatim coordinates) and locality. Pre-create events and use collecting_event_id if you need more control.
	</p>
	<p>
		This form will happily make duplicates. Be careful!
	</p>
	<p>
		<a href="BulkloadSpecimenEvent.cfm?action=makeTemplate">download a CSV template</a>
	</p>
	<cfoutput>
		<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_temp_specevent where upper(username)='#ucase(session.username)#'
		</cfquery>
		<cfif mine.recordcount gt 0>
			<p>
				<a href="BulkloadSpecimenEvent.cfm?action=managemystuff">Manage your existing #mine.recordcount# records</a>
			</p>
		</cfif>
		</cfoutput>
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
			<td>ASSIGNED_BY_AGENT</td>
			<td>yes</td>
			<td>unique agent_name</td>
		</tr>
		<tr>
			<td>ASSIGNED_DATE</td>
			<td>yes</td>
			<td>ISO8601</td>
		</tr>
		<tr>
			<td>SPECIMEN_EVENT_REMARK</td>
			<td>no</td>
			<td></td>
		</tr>
		<tr>
			<td>SPECIMEN_EVENT_TYPE</td>
			<td>yes</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTSPECIMEN_EVENT_TYPE">CTSPECIMEN_EVENT_TYPE</a></td>
		</tr>
		<tr>
			<td>COLLECTING_METHOD</td>
			<td>no</td>
			<td></td>
		</tr>
		<tr>
			<td>COLLECTING_SOURCE</td>
			<td>no</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTCOLLECTING_SOURCE">CTCOLLECTING_SOURCE</a></td>
		</tr>
		<tr>
			<td>VERIFICATIONSTATUS</td>
			<td>yes</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTVERIFICATIONSTATUS">CTVERIFICATIONSTATUS</a></td>
		</tr>
		<tr>
			<td>HABITAT</td>
			<td>no</td>
			<td></td>
		</tr>
		<tr>
			<td>COLLECTING_EVENT_ID</td>
			<td>no</td>
			<td>Specify an existing COLLECTING_EVENT.COLLECTING_EVENT_ID to use an existing event. This will IGNORE anything
			else entered under event, locality, geography.
			COLLECTING_EVENT_ID gets precedence over COLLECTING_EVENT_NAME - but don't provide both or you'll confuse yourself.
			</td>
		</tr>
		<tr>
			<td>COLLECTING_EVENT_NAME</td>
			<td>no</td>
			<td>Specify an existing COLLECTING_EVENT.COLLECTING_EVENT_NAME to use an existing event. This will IGNORE anything
			else entered under event, locality, geography
			COLLECTING_EVENT_ID gets precedence over COLLECTING_EVENT_NAME - but don't provide both or you'll confuse yourself.
			</td>
		</tr>
		<tr>
			<td>VERBATIM_DATE</td>
			<td>required if COLLECTING_EVENT_ID or COLLECTING_EVENT_NAME is not given</td>
			<td>text</td>
		</tr>
		<tr>
			<td>VERBATIM_LOCALITY</td>
			<td>required if COLLECTING_EVENT_ID or COLLECTING_EVENT_NAME is not given</td>
			<td></td>
		</tr>
		<tr>
			<td>COLL_EVENT_REMARKS</td>
			<td>no</td>
			<td></td>
		</tr>
		<tr>
			<td>BEGAN_DATE</td>
			<td>required if COLLECTING_EVENT_ID or COLLECTING_EVENT_NAME is not given</td>
			<td>ISO8601</td>
		</tr>
		<tr>
			<td>ENDED_DATE</td>
			<td>required if COLLECTING_EVENT_ID or COLLECTING_EVENT_NAME is not given</td>
			<td>ISO8601</td>
		</tr>
		<tr>
			<td>ORIG_LAT_LONG_UNITS</td>
			<td>no</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTLAT_LONG_UNITS">CTLAT_LONG_UNITS</a></td>
		</tr>
		<tr>
			<td>LAT_DEG</td>
			<td>required if ORIG_LAT_LONG_UNITS is "deg. min. sec." or "degrees dec. minutes"</td>
			<td>integer, 0-90</td>
		</tr>
		<tr>
			<td>DEC_LAT_MIN</td>
			<td>required if ORIG_LAT_LONG_UNITS is "degrees dec. minutes"</td>
			<td>number, 0-60</td>
		</tr>
		<tr>
			<td>LAT_MIN</td>
			<td>required if ORIG_LAT_LONG_UNITS is "deg. min. sec."</td>
			<td>number, 0-60</td>
		</tr>
		<tr>
			<td>LAT_SEC</td>
			<td>required if ORIG_LAT_LONG_UNITS is "deg. min. sec."</td>
			<td>number, 0-60</td>
		</tr>
		<tr>
			<td>LAT_DIR</td>
			<td>required if ORIG_LAT_LONG_UNITS is "deg. min. sec." or "degrees dec. minutes"</td>
			<td>N or S</td>
		</tr>
		<tr>
			<td>LONG_DEG</td>
			<td>required if ORIG_LAT_LONG_UNITS is "deg. min. sec." or "degrees dec. minutes"</td>
			<td>integer, -180 - 180</td>
		</tr>
		<tr>
			<td>DEC_LONG_MIN</td>
			<td>required if ORIG_LAT_LONG_UNITS is "degrees dec. minutes"</td>
			<td>number, 0-60</td>
		</tr>
		<tr>
			<td>LONG_MIN</td>
			<td>required if ORIG_LAT_LONG_UNITS is "deg. min. sec."</td>
			<td>number, 0-60</td>
		</tr>
		<tr>
			<td>LONG_SEC</td>
			<td>required if ORIG_LAT_LONG_UNITS is "deg. min. sec."</td>
			<td>number, 0-60</td>
		</tr>
		<tr>
			<td>LONG_DIR</td>
			<td>required if ORIG_LAT_LONG_UNITS is "deg. min. sec." or "degrees dec. minutes"</td>
			<td>E or W</td>
		</tr>
		<tr>
			<td>DEC_LAT</td>
			<td>required if ORIG_LAT_LONG_UNITS is "decimal degrees"</td>
			<td>number, -90-90</td>
		</tr>
		<tr>
			<td>DEC_LONG</td>
			<td>required if ORIG_LAT_LONG_UNITS is "decimal degrees"</td>
			<td>number, -180-180</td>
		</tr>
		<tr>
			<td>DATUM</td>
			<td>required if ORIG_LAT_LONG_UNITS is given</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTDATUM">CTDATUM</a></td>
		</tr>
		<tr>
			<td>UTM_ZONE</td>
			<td>required if ORIG_LAT_LONG_UNITS is "UTM"</td>
			<td>char</td>
		</tr>
		<tr>
			<td>UTM_EW</td>
			<td>required if ORIG_LAT_LONG_UNITS is "UTM"</td>
			<td>number</td>
		</tr>
		<tr>
			<td>UTM_NS</td>
			<td>required if ORIG_LAT_LONG_UNITS is "UTM"</td>
			<td>number</td>
		</tr>
		<tr>
			<td>LOCALITY_ID</td>
			<td>no</td>
			<td>
				If given, overrides all locality and geog information.
				LOCALITY_ID gets precedence over LOCALITY_NAME - but don't provide both or you'll confuse yourself.
			</td>
		</tr>
		<tr>
			<td>LOCALITY_NAME</td>
			<td>no</td>
			<td>if given, overrides all locality and geog information
			LOCALITY_ID gets precedence over LOCALITY_NAME - but don't provide both or you'll confuse yourself.
			</td>
		</tr>
		<tr>
			<td>SPEC_LOCALITY</td>
			<td>required if LOCALITY_ID, LOCALITY_NAME, COLLECTING_EVENT_ID, or COLLECTING_EVENT_NAME not given</td>
			<td></td>
		</tr>
		<tr>
			<td>MINIMUM_ELEVATION</td>
			<td>required if ORIG_ELEV_UNITS given</td>
			<td>number</td>
		</tr>
		<tr>
			<td>MAXIMUM_ELEVATION</td>
			<td>required if ORIG_ELEV_UNITS given</td>
			<td>number</td>
		</tr>
		<tr>
			<td>ORIG_ELEV_UNITS</td>
			<td>no</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTORIG_ELEV_UNITS">CTORIG_ELEV_UNITS</a></td>
		</tr>
		<tr>
			<td>MIN_DEPTH</td>
			<td>required if DEPTH_UNITS given</td>
			<td>number</td>
		</tr>
		<tr>
			<td>MAX_DEPTH</td>
			<td>required if DEPTH_UNITS given</td>
			<td>number</td>
		</tr>
		<tr>
			<td>DEPTH_UNITS</td>
			<td>no</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTDEPTH_UNITS">CTDEPTH_UNITS</a></td>
		</tr>
		<tr>
			<td>MAX_ERROR_DISTANCE</td>
			<td>required if MAX_ERROR_UNITS given</td>
			<td>number</td>
		</tr>
		<tr>
			<td>MAX_ERROR_UNITS</td>
			<td>no</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTLAT_LONG_ERROR_UNITS">CTLAT_LONG_ERROR_UNITS</a></td>
		</tr>
		<tr>
			<td>LOCALITY_REMARKS</td>
			<td>no</td>
			<td></td>
		</tr>
		<tr>
			<td>GEOREFERENCE_SOURCE</td>
			<td>required if ORIG_LAT_LONG_UNITS is given</td>
			<td>text</td>
		</tr>
		<tr>
			<td>GEOREFERENCE_PROTOCOL</td>
			<td>required if ORIG_LAT_LONG_UNITS is given</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTGEOREFERENCE_PROTOCOL">CTGEOREFERENCE_PROTOCOL</a></td>
		</tr>
		<tr>
			<td>GEOG_AUTH_REC_ID</td>
			<td>either GEOG_AUTH_REC_ID or HIGHER_GEOG is required if LOCALITY_ID, LOCALITY_NAME, COLLECTING_EVENT_ID, or COLLECTING_EVENT_NAME is not given
				GEOG_AUTH_REC_ID gets precedence over HIGHER_GEOG - but don't provide both or you'll confuse yourself.
			</td>
			<td></td>
		</tr>
		<tr>
			<td>HIGHER_GEOG</td>
			<td>either GEOG_AUTH_REC_ID or HIGHER_GEOG is required if LOCALITY_ID, LOCALITY_NAME, COLLECTING_EVENT_ID, or COLLECTING_EVENT_NAME is not given.
			GEOG_AUTH_REC_ID gets precedence over HIGHER_GEOG - but don't provide both or you'll confuse yourself.
			</td>
			<td></td>
		</tr>

        <tr>
            <td>wkt_polygon</td>
            <td>no
            </td>
            <td>Well-known text</td>
        </tr>


	</table>

	Upload CSV:
	<form name="getFile" method="post" action="BulkloadSpecimenEvent.cfm" enctype="multipart/form-data">
		<input type="hidden" name="action" value="getFileData">
		 <input type="file"
			   name="FiletoUpload"
			   size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" class="savBtn">
	</form>
</cfif>
<!---------------------------------------------------------------------------->
<cfif action is "getCSV">
	<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_specevent where upper(username)='#ucase(session.username)#'
	</cfquery>
	<cfset  util = CreateObject("component","component.utilities")>
	<cfset csv = util.QueryToCSV2(Query=mine,Fields=mine.columnlist)>
	<cffile action = "write"
	    file = "#Application.webDirectory#/download/BulkloadSpecimenEventData.csv"
    	output = "#csv#"
    	addNewLine = "no">
	<cflocation url="/download.cfm?file=BulkloadSpecimenEventData.csv" addtoken="false">
</cfif>
<!---------------------------------------------------------------------------->
<cfif action is "getGuidUUID">
	<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select uuid from cf_temp_specevent where upper(username)='#ucase(session.username)#' and guid is null group by uuid
	</cfquery>
	<cfloop query="mine">
		<cfquery name="gg" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select guid from flat,coll_obj_other_id_num where flat.collection_object_id=coll_obj_other_id_num.collection_object_id and
			other_id_type='UUID' and display_value='#uuid#'
		</cfquery>
		<cfif gg.recordcount is 1>
			<cfquery name="gg" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update cf_temp_specevent set guid='#gg.guid#' where uuid='#uuid#'
			</cfquery>
		</cfif>
	</cfloop>
	<cflocation url="BulkloadSpecimenEvent.cfm?action=managemystuff" addtoken="false">
</cfif>
<!---------------------------------------------------------------------------->

<cfif action is "saveClaimed">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_specevent set username='#session.username#' where username in (#listqualify(username,"'")#)
	</cfquery>
	<cflocation url="BulkloadSpecimenEvent.cfm?action=managemystuff" addtoken="false">
</cfif>
<!---------------------------------------------------------------------------->

<cfif action is "takeStudentRecords">
	<cfoutput>
		<a href="BulkloadSpecimenEvent.cfm?action=managemystuff">back to my stuff</a>
		<cfquery name="d" datasource="uam_god">
			select count(*) c,username from cf_temp_specevent where upper(username) != '#ucase(session.username)#' and upper(username) in (
			select
				grantee
			from
				dba_role_privs
			where
				granted_role in (
	        		select
						c.portal_name
					from
						dba_role_privs d,
						cf_collection c
	        		where
						d.granted_role = c.portal_name
	        			and d.grantee = '#ucase(session.username)#'
				)
				and grantee in (select grantee from dba_role_privs where granted_role = 'DATA_ENTRY')
			) group by username order by username
		</cfquery>
		<form name="d" method="post" action="BulkloadSpecimenEvent.cfm">
			<input type="hidden" name="action" value="saveClaimed">
			<table border id="t" class="sortable">
				<tr>
					<th>Claim</th>
					<th>User</th>
					<th>Count</th>
				</tr>
				<cfloop query="d">
					<tr>
						<td><input type="checkbox" name="username" value="#username#"></td>
						<td>#username#</td>
						<td>#c#</td>
					</tr>
				</cfloop>
			</table>
			<br>
			<input type="submit" value="Claim all checked records for checked users">
		</form>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->

<cfif action is "managemystuff">
	<script src="/includes/sorttable.js"></script>
	<cfoutput>
		<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_temp_specevent where upper(username)='#ucase(session.username)#'
		</cfquery>
		<cfquery name="summary" dbtype="query">
			select status,count(*) c from mine group by status order by status
		</cfquery>
		<cfif summary.recordcount gt 0>
			<p>Summary</p>
			<table border>
				<tr>
					<th>Status</th>
					<th>Count</th>
				</tr>
				<cfloop query="summary">
					<tr>
						<td>#status#</td>
						<td>#c#</td>
					</tr>
				</cfloop>
			</table>
		</cfif>
		<cfset clist=mine.columnlist>
		<cfset clist=listdeleteat(clist,listfind(clist,'STATUS'))>
		<cfset clist=listdeleteat(clist,listfind(clist,'GUID'))>
		<cfset clist=listdeleteat(clist,listfind(clist,'UUID'))>
		<cfset clist=listdeleteat(clist,listfind(clist,'KEY'))>
		<p>
			You have #mine.recordcount# records in the staging table.
		</p>
		<cfif session.roles contains "manage_collection">
			<p>
				You have manage_collection, so you can "take" records from people in your collection.
				<br>NOT ALL OF THESE ARE NECESSARILY YOUR SPECIMENS!!
				<br>Use this with great caution, especially if the originating user has acess to multiple collections.
				You may need to coordinate with other curatorial staff or involve a DBA.
				<br><a href="BulkloadSpecimenEvent.cfm?action=takeStudentRecords">Check for records entered by people in your collection(s)</a>
			</p>

		</cfif>
		<p>

		</p>
		<p>
			<a href="BulkloadSpecimenEvent.cfm?action=deleteMine">delete all of your data from the staging table</a>
		</p>
		<p>
			<a href="BulkloadSpecimenEvent.cfm?action=nothing">upload from CSV</a>
		</p>
		<p>
			<a href="BulkloadSpecimenEvent.cfm?action=getCSV">Download as CSV</a>
		</p>
		<cfquery name="willload" dbtype="query">
			select count(*) c from mine where status = 'valid'
		</cfquery>
		<cfif willload.c eq mine.recordcount>
			<p>
				The data should load. Check them one more time, then <a href="BulkloadSpecimenEvent.cfm?action=load">proceed to load</a>
				<br>IMPORTANT: Only about 1000 records will load at a time. Records will be DELETED from the specimen-event loader as they are
				loaded and attached to specimens. If you have a lot of stuff you'll probably have to come back here
				and click the link a few times.
			</p>
		</cfif>
		<p>
			Validation only works with NULL status. If you've fixed something, you can
			<a href="BulkloadSpecimenEvent.cfm?action=resetStatus">reset non-valid status</a> here
		</p>
		<cfquery name="nog" dbtype="query">
			select count(*) c from mine where guid is null
		</cfquery>
		<cfif nog.c gt 0>
			<p>
				<a href="BulkloadSpecimenEvent.cfm?action=getGuidUUID">Find GUIDs from UUID</a>
			</p>
		</cfif>
		<cfif willload.c neq mine.recordcount>
			<p>
				Your data require <a href="BulkloadSpecimenEvent.cfm?action=validateFromFile">validation</a>
				<br>IMPORTANT: Records without GUID will be ignored.
				<br>IMPORTANT: Validation is slow; it'll only run on #numberToValidate# records at a time. Click the link,
				grab a cup of coffee, then click the link again if necessary.
			</p>
		</cfif>
		<p>
			Use the Contact link in the footer to tell us what Tools would be useful here.
		</p>

		<p>
		  select-to-delete/full-view table WILL eat your browser if you have much data.
		  <br>Don't click <a href="BulkloadSpecimenEvent.cfm?action=showMyTable">here</a> unless you know what you're doing.
		</p>


	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------>
<cfif action is "showMyTable">
	   <script src="/includes/sorttable.js"></script>

    <cfoutput>
      back to <a href="BulkloadSpecimenEvent.cfm?action=managemystuff">managemystuff</a>

    <cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
        select * from cf_temp_specevent   where upper(username)='#ucase(session.username)#'
    </cfquery>

	   <cfset clist=mine.columnlist>
        <cfset clist=listdeleteat(clist,listfind(clist,'STATUS'))>
        <cfset clist=listdeleteat(clist,listfind(clist,'GUID'))>
        <cfset clist=listdeleteat(clist,listfind(clist,'UUID'))>
        <cfset clist=listdeleteat(clist,listfind(clist,'KEY'))>


	   <form name="d" method="post" action="BulkloadSpecimenEvent.cfm">
        <input type="hidden" name="action" value="deleteChecked">
        <table border id="t" class="sortable">
            <tr>
                <th>Delete</th>
                <th>Status</th>
                <th>GUID</th>
                <th>UUID</th>
                <cfloop list="#clist#" index="i">
                    <th>#i#</th>
                </cfloop>
            </tr>



            <cfloop query="mine">
                <tr>
                    <td><input type="checkbox" name="key" value="#key#"></td>
                    <td>#status#</td>
                    <td>#GUID#</td>
                    <td><a href="BulkloadSpecimenEvent.cfm?action=findUUID&uuid=#uuid#">#UUID#</a></td>
                    <cfloop list="#clist#" index="i">
                        <cfset tval=evaluate("mine." & i)>
                        <td>#tval#</td>
                    </cfloop>
                </tr>
            </cfloop>
        </table>
        <br>
        <input type="submit" value="delete checked records">
        </form>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------>
<cfif action is "resetStatus">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_specevent  set status=null where status != 'valid' and upper(username)='#ucase(session.username)#'
	</cfquery>
	<cflocation url="BulkloadSpecimenEvent.cfm?action=managemystuff" addtoken="false">
</cfif>
<!------------------------------------------------------------------------------------------------>
<cfif action is "deleteChecked">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from cf_temp_specevent  where key in (#listqualify(key,"'")#)
	</cfquery>
	<cflocation url="BulkloadSpecimenEvent.cfm?action=managemystuff" addtoken="false">
</cfif>
<!------------------------------------------------------------------------------------------------>
<cfif action is "findUUID">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select collection_object_id, enteredby,ENTEREDTOBULKDATE from bulkloader  where OTHER_ID_NUM_4='#uuid#'
	</cfquery>
	<cfif data.recordcount is 0>
		Bulkloader record not found!
		<p>
			If the record has been loaded, try <a href="BulkloadSpecimenEvent.cfm?action=getGuidUUID">Find GUIDs from UUID</a>.
		</p>
		<p>
			If the UUID has been changed or the bulkloader record deleted, the information here may be irretrievably lost.
		</p>
	<cfelse>
		<cfoutput>
			<table border>
				<tr>
					<th>Record in Data Entry</th>
					<th>EnteredBy</th>
					<th>EnteredDate</th>
				</tr>
				<cfloop query="data">
					<tr>
						<td><a href="/DataEntry.cfm?action=edit&collection_object_id=#collection_object_id#">#collection_object_id#</a></td>
						<td>#enteredby#</td>
						<td>#ENTEREDTOBULKDATE#</td>
					</tr>
				</cfloop>
			</table>
		</cfoutput>
	</cfif>
</cfif>
<!------------------------------------------------------------------------------------------------>
<cfif action is "deleteMine">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from cf_temp_specevent  where upper(username)='#ucase(session.username)#'
	</cfquery>
	<cflocation url="BulkloadSpecimenEvent.cfm" addtoken="false">
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
	            insert into cf_temp_specevent (#cols#) values (
	            <cfloop list="#cols#" index="i">
	               <cfif i is "wkt_polygon">
	            		<cfqueryparam value="#evaluate(i)#" cfsqltype="cf_sql_clob">
	                <cfelse>
	            		'#stripQuotes(evaluate(i))#'
	            	</cfif>
	            	<cfif i is not listlast(cols)>
	            		,
	            	</cfif>
	            </cfloop>
	            )
            </cfquery>
        </cfloop>
		<cflocation url="BulkloadSpecimenEvent.cfm?action=managemystuff" addtoken="false">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->
<cfif action is "validateFromFile">
<!----
	<cfquery name="guid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_specevent set status='guid not found'
		where upper(username)='#ucase(session.username)#' and guid NOT IN (select guid from flat)
	</cfquery>
	---->
	<cfquery name="SPECIMEN_EVENT_TYPE" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_specevent set status='SPECIMEN_EVENT_TYPE not found'
		where upper(username)='#ucase(session.username)#' and SPECIMEN_EVENT_TYPE NOT IN (select SPECIMEN_EVENT_TYPE from CTSPECIMEN_EVENT_TYPE) and
		guid is not null
	</cfquery>
	<cfquery name="COLLECTING_SOURCE" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_specevent set status='COLLECTING_SOURCE not found'
		where upper(username)='#ucase(session.username)#' and
		COLLECTING_SOURCE is not null and
		COLLECTING_SOURCE NOT IN (select COLLECTING_SOURCE from CTCOLLECTING_SOURCE) and
		guid is not null
	</cfquery>

	<cfquery name="geog" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
        update cf_temp_specevent set status='HIGHER_GEOG not found'
        where upper(username)='#ucase(session.username)#' and
		COLLECTING_EVENT_ID IS NULL AND
		LOCALITY_ID IS NULL AND
		GEOG_AUTH_REC_ID IS NULL AND
		HIGHER_GEOG NOT IN (select HIGHER_GEOG from GEOG_AUTH_REC)
    </cfquery>
	<cfquery name="coordeps" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
        update cf_temp_specevent set status='datum,GEOREFERENCE_SOURCE,GEOREFERENCE_PROTOCOL'
        where upper(username)='#ucase(session.username)#' and
       orig_lat_long_units is not null AND
	   (
	       datum is null or
	       GEOREFERENCE_SOURCE is null or
	       GEOREFERENCE_PROTOCOL is null
	   )
    </cfquery>




	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_specevent where upper(username)='#ucase(session.username)#' and
		status is null and
		rownum<=#numberToValidate# and
		guid is not null
	</cfquery>

	<cfloop query="data">
		<cfset s=''>
		<cfset checkEvent=true>
		<cfset checkLocality=true>
		<cfset lcl_collection_object_id = 0>
		<cfset lcl_collecting_event_id = 0>
		<cfset lcl_locality_id = 0>
		<cfset lcl_geog_auth_rec_id = 0>

		<cfset lcl_event_assigned_id = 0>


		<cfquery name="getCatItem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select collection_object_id from flat where guid='#guid#'
		</cfquery>
		<cfif len(getCatItem.collection_object_id) is 0>
			<cfset s=listappend(s,'guid not found',';')>
		<cfelse>
			<cfset lcl_collection_object_id=getCatItem.collection_object_id>
		</cfif>

		<cfquery name="aba" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select agent_id from agent_name where agent_name='#ASSIGNED_BY_AGENT#' group by agent_id
		</cfquery>
		<cfif aba.recordcount is 1 and len(aba.agent_id) gt 0>
			<cfset lcl_event_assigned_id=aba.agent_id>
		<cfelse>
			<cfset s=listappend(s,'ASSIGNED_BY_AGENT not found',';')>
		</cfif>
		<cfquery name="dd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select is_iso8601('#ASSIGNED_DATE#') isdate from dual
		</cfquery>
		<cfif dd.isdate is not "valid">
			<cfset s=listappend(s,'ASSIGNED_DATE not a valid date',';')>
		</cfif>
		<cfif len(collecting_event_id) gt 0>
			<cfset checkEvent=false>
			<cfset checkLocality=false>
			<cfquery name="collecting_event" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
				select collecting_event_id from collecting_event where collecting_event_id=#collecting_event_id#
			</cfquery>
			<cfif collecting_event.recordcount is not 1>
				<cfset s=listappend(s,'not a valid collecting_event_id',';')>
			<cfelse>
				<cfset lcl_collecting_event_id=collecting_event.collecting_event_id>
			</cfif>
		</cfif>
		<cfif len(collecting_event_name) gt 0>
			<cfset checkEvent=false>
			<cfset checkLocality=false>
			<cfquery name="collecting_event" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
				select min(collecting_event_id) collecting_event_id from collecting_event where collecting_event_name='#collecting_event_name#'
			</cfquery>
			<cfif collecting_event.recordcount is 1 and len(collecting_event.collecting_event_id) gt 0>
				<cfset lcl_collecting_event_id=collecting_event.collecting_event_id>
			<cfelse>
				<cfset s=listappend(s,'not a valid collecting_event_name',';')>
			</cfif>
		</cfif>
		<cfif len(LOCALITY_ID) gt 0>
			<cfset checkLocality=false>
			<cfquery name="LOCALITY" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
				select min(LOCALITY_ID) LOCALITY_ID from LOCALITY where LOCALITY_ID=#LOCALITY_ID#
			</cfquery>
			<cfdump var=#LOCALITY#>
			<cfif LOCALITY.recordcount is 1 and len(LOCALITY.LOCALITY_ID) gt 0>
				<cfset lcl_locality_id=LOCALITY.LOCALITY_ID>
			<cfelse>
				<cfset s=listappend(s,'not a valid LOCALITY_ID',';')>
			</cfif>
		</cfif>
		<cfif len(LOCALITY_NAME) gt 0>
			<cfset checkLocality=false>
			<cfquery name="LOCALITY" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
				select min(LOCALITY_ID) LOCALITY_ID from LOCALITY where LOCALITY_NAME='#LOCALITY_NAME#'
			</cfquery>
			<cfif LOCALITY.recordcount is 1 and len(LOCALITY.LOCALITY_ID) gt 0>
				<cfset lcl_locality_id=LOCALITY.LOCALITY_ID>
			<cfelse>
				<cfset s=listappend(s,'not a valid LOCALITY_NAME',';')>
			</cfif>
		</cfif>
		<cfif checkEvent is true>
			<cfif len(VERBATIM_DATE) is 0>
				<cfset s=listappend(s,'VERBATIM_DATE is required',';')>
			</cfif>
			<cfif len(VERBATIM_LOCALITY) is 0>
				<cfset s=listappend(s,'VERBATIM_LOCALITY is required',';')>
			</cfif>
			<cfquery name="dd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
				select is_iso8601('#BEGAN_DATE#') isdate from dual
			</cfquery>
			<cfif dd.isdate is not "valid">
				<cfset s=listappend(s,'BEGAN_DATE is not a valid date',';')>
			</cfif>
			<cfquery name="dd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
				select is_iso8601('#ENDED_DATE#') isdate from dual
			</cfquery>
			<cfif dd.isdate is not "valid">
				<cfset s=listappend(s,'ENDED_DATE is not a valid date',';')>
			</cfif>
			<cfif len(ORIG_LAT_LONG_UNITS) gt 0>
				<cfquery name="dd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
					select count(*) c from CTLAT_LONG_UNITS where ORIG_LAT_LONG_UNITS='#ORIG_LAT_LONG_UNITS#'
				</cfquery>
				<cfif dd.c is not 1>
					<cfset s=listappend(s,'ORIG_LAT_LONG_UNITS is not valid',';')>
				</cfif>
				<cfquery name="dd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
					select count(*) c from ctDATUM where DATUM='#DATUM#'
				</cfquery>
				<cfif dd.c is not 1>
					<cfset s=listappend(s,'DATUM is not valid',';')>
				</cfif>
				<cfquery name="dd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
					select count(*) c from ctGEOREFERENCE_PROTOCOL where GEOREFERENCE_PROTOCOL='#GEOREFERENCE_PROTOCOL#'
				</cfquery>
				<cfif dd.c is not 1>
					<cfset s=listappend(s,'GEOREFERENCE_PROTOCOL is not valid',';')>
				</cfif>
				<cfif ORIG_LAT_LONG_UNITS is "decimal degrees">
					<cfif DEC_LAT gt 90 or DEC_LAT lt -90 or DEC_LONG gt 180 or DEC_LONG lt -180>
						<cfset s=listappend(s,'coordinates not valid',';')>
					</cfif>
				<cfelseif orig_lat_long_units is 'deg. min. sec.'>
					<cfif LAT_DEG gt 90 or LAT_DEG lt 0 or
						LAT_MIN lt 0 or LAT_MIN gt 60 or
						LAT_SEC  lt 0 or LAT_SEC gt 60 or
						LONG_DEG gt 90 or LONG_DEG lt 0 or
						LONG_MIN lt 0 or LONG_MIN gt 60 or
						LONG_SEC  lt 0 or LONG_SEC gt 60 or
						(LAT_DIR is not "N" and LAT_DIR is not "S") or
						(LONG_DIR is not "W" and LONG_DIR is not "E")>
						<cfset s=listappend(s,'coordinates not valid',';')>
					</cfif>
				<cfelseif orig_lat_long_units is 'degrees dec. minutes'>
					<cfif LAT_DEG gt 90 or LAT_DEG lt 0 or
						DEC_LAT_MIN lt 0 or DEC_LAT_MIN gt 60 or
						LONG_DEG gt 90 or LONG_DEG lt 0 or
						DEC_LONG_MIN lt 0 or DEC_LONG_MIN gt 60 or
						(LAT_DIR is not "N" and LAT_DIR is not "S") or
						(LONG_DIR is not "W" and LONG_DIR is not "E")>
						<cfset s=listappend(s,'coordinates not valid',';')>
					</cfif>
				<cfelseif orig_lat_long_units is 'UTM'>
					<cfif not (isnumeric(UTM_EW) and isnumeric(UTM_NS))>
						<cfset s=listappend(s,'coordinates not valid',';')>
					</cfif>
				</cfif>
			</cfif>
		</cfif>
		<cfif checkLocality is true>
			<cfif len(SPEC_LOCALITY) is 0>
				<cfset s=listappend(s,'SPEC_LOCALITY is required',';')>
			</cfif>
			<cfif len(ORIG_ELEV_UNITS) gt 0>
				<cfquery name="dd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
					select count(*) c from ctORIG_ELEV_UNITS where ORIG_ELEV_UNITS='#ORIG_ELEV_UNITS#'
				</cfquery>
				<cfif dd.c is not 1>
					<cfset s=listappend(s,'ORIG_ELEV_UNITS is not valid',';')>
				</cfif>
				<cfif len(MINIMUM_ELEVATION) is 0 or len(MAXIMUM_ELEVATION) is 0 or (not isnumeric(MINIMUM_ELEVATION))
					 or (not isnumeric(MAXIMUM_ELEVATION)) or (MINIMUM_ELEVATION gt MAXIMUM_ELEVATION)>
					<cfset s=listappend(s,'elevation is wonky',';')>
				</cfif>
			</cfif>
			<cfif len(DEPTH_UNITS) gt 0>
				<cfquery name="dd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
					select count(*) c from ctDEPTH_UNITS where DEPTH_UNITS='#DEPTH_UNITS#'
				</cfquery>
				<cfif dd.c is not 1>
					<cfset s=listappend(s,'DEPTH_UNITS is not valid',';')>
				</cfif>
				<cfif len(MIN_DEPTH) is 0 or len(MAX_DEPTH) is 0 or (not isnumeric(MIN_DEPTH))
					 or (not isnumeric(MAX_DEPTH)) or (MIN_DEPTH gt MAX_DEPTH)>
					<cfset s=listappend(s,'depth is wonky',';')>
				</cfif>
			</cfif>
			<cfif len(MAX_ERROR_UNITS) gt 0>
				<cfquery name="dd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
					select count(*) c from CTLAT_LONG_ERROR_UNITS  where LAT_LONG_ERROR_UNITS='#MAX_ERROR_UNITS#'
				</cfquery>
				<cfif dd.c is not 1>
					<cfset s=listappend(s,'MAX_ERROR_UNITS is not valid',';')>
				</cfif>
				<cfif len(MAX_ERROR_DISTANCE) is 0>
					<cfset s=listappend(s,'MAX_ERROR_DISTANCE is required when MAX_ERROR_UNITS is given',';')>
				</cfif>
			</cfif>
			<cfif len(GEOG_AUTH_REC_ID) gt 0>
				<cfquery name="GEOG_AUTH_REC" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
					select nvl(GEOG_AUTH_REC_ID,0) GEOG_AUTH_REC_ID from GEOG_AUTH_REC where GEOG_AUTH_REC_ID=#GEOG_AUTH_REC_ID#
				</cfquery>
				<cfset lcl_geog_auth_rec_id=GEOG_AUTH_REC.GEOG_AUTH_REC_ID>
				<cfif GEOG_AUTH_REC.GEOG_AUTH_REC_ID is 0>
					<cfset s=listappend(s,'GEOG_AUTH_REC_ID is not valid',';')>
				</cfif>
			<cfelseif len(HIGHER_GEOG) gt 0>
				<cfquery name="GEOG_AUTH_REC" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
					select nvl(GEOG_AUTH_REC_ID,0) GEOG_AUTH_REC_ID  from GEOG_AUTH_REC where HIGHER_GEOG='#HIGHER_GEOG#'
				</cfquery>
				<cfset lcl_geog_auth_rec_id=GEOG_AUTH_REC.GEOG_AUTH_REC_ID>
				<cfif GEOG_AUTH_REC.GEOG_AUTH_REC_ID is 0>
					<cfset s=listappend(s,'HIGHER_GEOG is not valid',';')>
				</cfif>
			<cfelse>
				<cfset s=listappend(s,'Either HIGHER_GEOG or GEOG_AUTH_REC_ID is required.',';')>
			</cfif>
		</cfif>
		<cfif len(s) eq 0>
			<cfset s='valid'>
		</cfif>
		<cfquery name="dd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update
				cf_temp_specevent
			set
				l_collection_object_id=#lcl_collection_object_id#,
				l_collecting_event_id=#lcl_collecting_event_id#,
				l_locality_id=#lcl_locality_id#,
				l_geog_auth_rec_id=#lcl_geog_auth_rec_id#,
				l_event_assigned_id=#lcl_event_assigned_id#,
				status='#s#' where key=#key#
		</cfquery>
	</cfloop>


	did some validating - hit reload or go to <a href="BulkloadSpecimenEvent.cfm?action=managemystuff">managemystuff</a> if you think it's done.
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
				<cfset verbatimcoordinates="">
				<p>
					running for <a href="/guid/#guid#" target="_blank">#guid#</a>
					<br>lcl_locality_id: #lcl_locality_id#
					<br>l_collecting_event_id: #l_collecting_event_id#

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