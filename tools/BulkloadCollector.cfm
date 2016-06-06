<!-----

drop table cf_temp_collector;


create table cf_temp_collector (
	key number not null,
	username varchar2(255) not null,
	agent_name varchar2(255) not null,
	collector_role  varchar2(255) not null,
	guid varchar2(60),
	guid_prefix varchar2(60),
	other_id_type varchar2(60),
	other_id_number varchar2(60),
	COLL_ORDER number,
	agent_id number,
	collection_object_id number,
	uuid varchar2(255),
	status varchar2(255)
);


create or replace public synonym cf_temp_collector for cf_temp_collector;

grant all on cf_temp_collector to coldfusion_user;

CREATE OR REPLACE TRIGGER cf_temp_collector_KEY
before insert ON cf_temp_collector
for each row
begin
    if :NEW.key is null then
        select somerandomsequence.nextval into :new.key from dual;
    end if;
	 if :NEW.username is null then
        select sys_context('USERENV', 'SESSION_USER') into :new.username from dual;
    end if;
end;
/


---->
<cfinclude template="/includes/_header.cfm">
<cfsetting requestTimeOut = "1200">

<cfset numberToValidate=2000>


<cfset title="Bulkload Collectors">


<cfset thecolumns="agent_name,collector_role,guid,guid_prefix,other_id_type,other_id_number,COLL_ORDER">
<cfif action is "makeTemplate">
	<cfset header=thecolumns>
	<cffile action = "write"
    file = "#Application.webDirectory#/download/BulkloadCollector.csv"
    output = "#header#"
    addNewLine = "no">
	<cflocation url="/download.cfm?file=BulkloadCollector.csv" addtoken="false">
</cfif>
<cfif action is  "nothing">
	Use this form to ADD collectors.

	<p>
		<a href="BulkloadCollector.cfm?action=makeTemplate">download a CSV template</a>
	</p>
	<cfoutput>
		<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_temp_collector where upper(username)='#ucase(session.username)#'
		</cfquery>
		<cfif mine.recordcount gt 0>
			<p>
				<a href="BulkloadCollector.cfm?action=managemystuff">Manage your existing #mine.recordcount# records</a>
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
			<td>agent_name</td>
			<td>yes</td>
			<td>any unique name of existing agent</td>
		</tr>
		<tr>
			<td>COLL_ORDER</td>
			<td>yes (number)</td>
			<td>
				Relative order of collectors; value is unimportant. For example, you could use -1 to insure a new
				collector lands in the first position (existing data are integers starting with 1),
				or 9999 to ensure a collector lands in the second collector	position, or 1.1 to inject a new
				collector between the existing first and second. Any duplication within the data here combined
				with the existing data will result in arbitrary ordering for the non-unique records.
			</td>
		</tr>
		<tr>
			<td>collector_role</td>
			<td>yes</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTCOLLECTOR_ROLE">CTCOLLECTOR_ROLE</a></td>
		</tr>
		<tr>
			<td>guid</td>
			<td>conditional</td>
			<td>Given GUID, guid_prefix,other_id_type,other_id_number are ignored</td>
		</tr>
		<tr>
			<td>guid_prefix,other_id_type,other_id_number</td>
			<td>conditional</td>
			<td>Use these OR GUID (GUID preferred) to locate the specimen. "catalog number" is an acceptable other_id_type.</td>
		</tr>

	</table>

	Upload CSV:
	<form name="getFile" method="post" action="BulkloadCollector.cfm" enctype="multipart/form-data">
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
		select * from cf_temp_collector where upper(username)='#ucase(session.username)#'
	</cfquery>
	<cfset  util = CreateObject("component","component.utilities")>
	<cfset csv = util.QueryToCSV2(Query=mine,Fields=mine.columnlist)>
	<cffile action = "write"
	    file = "#Application.webDirectory#/download/BulkloadCollector.csv"
    	output = "#csv#"
    	addNewLine = "no">
	<cflocation url="/download.cfm?file=BulkloadCollector.csv" addtoken="false">
</cfif>
<!---------------------------------------------------------------------------->
<cfif action is "getGuidUUID">
	<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			OTHER_ID_NUMBER uuid
		from
			cf_temp_collector
		where
			OTHER_ID_TYPE='UUID' and
			upper(username)='#ucase(session.username)#' and
			guid is null
		group by
			OTHER_ID_NUMBER
	</cfquery>
	<cfloop query="mine">
		<cfquery name="gg" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select guid from flat,coll_obj_other_id_num where flat.collection_object_id=coll_obj_other_id_num.collection_object_id and
			other_id_type='UUID' and display_value='#uuid#'
		</cfquery>

		<cfdump var=#mine#>
		<cfdump var=#gg#>

		<cfif gg.recordcount is 1>
			<cfquery name="gg" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update
					cf_temp_collector
				set
					guid='#gg.guid#'
				where
					OTHER_ID_TYPE='UUID' and
					OTHER_ID_NUMBER='#uuid#'
			</cfquery>
		</cfif>
	</cfloop>
	<cflocation url="BulkloadCollector.cfm?action=managemystuff" addtoken="false">

	<!----
	---->
</cfif>
<!---------------------------------------------------------------------------->

<cfif action is "saveClaimed">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_collector set username='#session.username#' where username in (#listqualify(username,"'")#)
	</cfquery>
	<cflocation url="BulkloadCollector.cfm?action=managemystuff" addtoken="false">
</cfif>
<!---------------------------------------------------------------------------->

<cfif action is "takeStudentRecords">
	<cfoutput>
		<a href="BulkloadCollector.cfm?action=managemystuff">back to my stuff</a>
		<cfquery name="d" datasource="uam_god">
			select count(*) c,username from cf_temp_collector where upper(username) != '#ucase(session.username)#' and upper(username) in (
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
		<form name="d" method="post" action="BulkloadCollector.cfm">
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
			select * from cf_temp_collector where upper(username)='#ucase(session.username)#'
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
				<br><a href="BulkloadCollector.cfm?action=takeStudentRecords">Check for records entered by people in your collection(s)</a>
			</p>

		</cfif>
		<p>

		</p>
		<p>
			<a href="BulkloadCollector.cfm?action=deleteMine">delete all of your data from the staging table</a>
		</p>
		<p>
			<a href="BulkloadCollector.cfm?action=nothing">upload from CSV</a>
		</p>
		<p>
			<a href="BulkloadCollector.cfm?action=getCSV">Download as CSV</a>
		</p>
		<cfquery name="willload" dbtype="query">
			select count(*) c from mine where status = 'valid'
		</cfquery>
		<cfif willload.c eq mine.recordcount>
			<p>
				The data should load. Check them one more time, then <a href="BulkloadCollector.cfm?action=load">proceed to load</a>
				<br>IMPORTANT: Only about 1000 records will load at a time. Records will be DELETED from the loader as they are
				loaded and attached to specimens. If you have a lot of stuff you'll probably have to come back here
				and click the link a few times.
			</p>
		</cfif>
		<p>
			Validation only works with NULL status. If you've fixed something, you can
			<a href="BulkloadCollector.cfm?action=resetStatus">reset non-valid status</a> here
		</p>
		<cfquery name="nog" dbtype="query">
			select count(*) c from mine where guid is null
		</cfquery>
		<cfif nog.c gt 0>
			<p>
				<a href="BulkloadCollector.cfm?action=getGuidUUID">Find GUIDs from UUID</a>
			</p>
		</cfif>
		<cfif willload.c neq mine.recordcount>
			<p>
				Your data require <a href="BulkloadCollector.cfm?action=validateFromFile">validation</a>
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
		  <br>Don't click <a href="BulkloadCollector.cfm?action=showMyTable">here</a> unless you know what you're doing.
		</p>


	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------>
<cfif action is "showMyTable">
	   <script src="/includes/sorttable.js"></script>

    <cfoutput>
      back to <a href="BulkloadCollector.cfm?action=managemystuff">managemystuff</a>

    <cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
        select * from cf_temp_collector   where upper(username)='#ucase(session.username)#'
    </cfquery>

	   <cfset clist=mine.columnlist>
        <cfset clist=listdeleteat(clist,listfind(clist,'STATUS'))>
        <cfset clist=listdeleteat(clist,listfind(clist,'GUID'))>
        <cfset clist=listdeleteat(clist,listfind(clist,'UUID'))>
        <cfset clist=listdeleteat(clist,listfind(clist,'KEY'))>


	   <form name="d" method="post" action="BulkloadCollector.cfm">
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
                    <td><a href="BulkloadCollector.cfm?action=findUUID&uuid=#uuid#">#UUID#</a></td>
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
		update cf_temp_collector  set status=null where status != 'valid' and upper(username)='#ucase(session.username)#'
	</cfquery>
	<cflocation url="BulkloadCollector.cfm?action=managemystuff" addtoken="false">
</cfif>
<!------------------------------------------------------------------------------------------------>
<cfif action is "deleteChecked">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from cf_temp_collector  where key in (#listqualify(key,"'")#)
	</cfquery>
	<cflocation url="BulkloadCollector.cfm?action=managemystuff" addtoken="false">
</cfif>
<!------------------------------------------------------------------------------------------------>
<cfif action is "findUUID">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select collection_object_id, enteredby,ENTEREDTOBULKDATE from bulkloader  where OTHER_ID_NUM_4='#uuid#'
	</cfquery>
	<cfif data.recordcount is 0>
		Bulkloader record not found!
		<p>
			If the record has been loaded, try <a href="BulkloadCollector.cfm?action=getGuidUUID">Find GUIDs from UUID</a>.
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
		delete from cf_temp_collector  where upper(username)='#ucase(session.username)#'
	</cfquery>
	<cflocation url="BulkloadCollector.cfm" addtoken="false">
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
	            insert into cf_temp_collector (#cols#) values (
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
		<cflocation url="BulkloadCollector.cfm?action=managemystuff" addtoken="false">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->
<cfif action is "validateFromFile">
	<cfquery name="presetstatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update
			cf_temp_collector
		set
			status=NULL,
			collection_object_id=null
		where
			upper(username)='#ucase(session.username)#'
	</cfquery>

	<cfquery name="presetstatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update
			cf_temp_collector
		set
			status=decode(status,
				null,'click "get GUID Prefix" before validating',
				status || '; click "get GUID Prefix" before validating')
		where
			upper(username)='#ucase(session.username)#' and
			guid_prefix is null and guid is null
	</cfquery>




	<cfquery name="ctcitation_TYPE_STATUS" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update
			cf_temp_collector
		set
			status=decode(status,
				null,'bad agent_role',
				status || '; bad agent_role')
		where
			status is null and
			upper(username)='#ucase(session.username)#' and
			collector_role not in (select collector_role from ctcollector_role)
	</cfquery>


	<cfquery name="agent_id" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_collector set agent_id=getAgentId(agent_name)
		where upper(username)='#ucase(session.username)#' and
		agent_id is not null
	</cfquery>


	<cfquery name="agent_idfail" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update
			cf_temp_collector
		set
			status=decode(status,
				null,'agent not found',
				status || '; agent not found')
		where
			agent_id is null and
			upper(username)='#ucase(session.username)#'
	</cfquery>

	<cfquery name="collObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_collector set COLLECTION_OBJECT_ID = (
			select
				cataloged_item.collection_object_id
			from
				cataloged_item,
				collection
			WHERE
				cataloged_item.collection_id = collection.collection_id and
				collection.guid_prefix || ':' || cataloged_item.cat_num = cf_temp_collector.guid
		) where
			status is null and
			COLLECTION_OBJECT_ID is null and
			upper(username)='#ucase(session.username)#'
	</cfquery>

	<cfquery name="collObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_collector set COLLECTION_OBJECT_ID = (
			select
				cataloged_item.collection_object_id
			from
				cataloged_item,
				collection
			WHERE
				cataloged_item.collection_id = collection.collection_id and
				collection.guid_prefix = cf_temp_collector.guid_prefix and
				cat_num=cf_temp_collector.other_id_number
		) where
			status is null and
			other_id_type = 'catalog number' and
			collection_object_id is null and
			upper(username)='#ucase(session.username)#'
	</cfquery>
	<cfquery name="collObj_nci" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_collector set COLLECTION_OBJECT_ID = (
			select
				cataloged_item.collection_object_id
			from
				cataloged_item,
				collection,
				coll_obj_other_id_num
			WHERE
				cataloged_item.collection_id = collection.collection_id and
				cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id and
				collection.guid_prefix = cf_temp_collector.guid_prefix and
				other_id_type = cf_temp_collector.other_id_type and
				display_value = cf_temp_collector.other_id_number
		) where
			status is null and
			collection_object_id is null and
			other_id_type != 'catalog number' and
			upper(username)='#ucase(session.username)#'
	</cfquery>
	<cfquery name="collObj_fail" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update
			cf_temp_collector
		set
			status=decode(status,
				null,'cataloged item not found',
				status || '; cataloged item not found')
		where
			collection_object_id is null and
			upper(username)='#ucase(session.username)#'
	</cfquery>
	<cfquery name="postsetstatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update
			cf_temp_collector
		set
			status='valid'
		where
			status is null and
			upper(username)='#ucase(session.username)#'
	</cfquery>



	did some validating - hit reload or go to <a href="BulkloadCollector.cfm?action=managemystuff">managemystuff</a> if you think it's done.
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
			go back to <a href="BulkloadCollector.cfm?action=managemystuff">the manage screen</a> and hit load again.
		</p>
		<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_temp_collector where status='valid' and upper(username)='#ucase(session.username)#'
			order by collection_object_id
		</cfquery>
		<cfquery name="ucid" dbtype="query">
			select collection_object_id from data group by collection_object_id order by collection_object_id
		</cfquery>
		<cfloop query="ucid">
			<cftransaction>
				<!--- grab one record so we can sort out order --->
				<cfquery name="tr" dbtype="query">
					select * from data where collection_object_id=#collection_object_id# order by COLL_ORDER
				</cfquery>
				<cfdump var=#tr#>
				<!--- see what's there ---->
				<cfquery name="ec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select * from collector where collection_object_id=#collection_object_id# order by coll_order
				</cfquery>
				<cfdump var=#ec#>
				<cfquery name="oldnnew" dbtype="query">
					select
						AGENT_ID,
						COLLECTION_OBJECT_ID,
						COLLECTOR_ROLE,
						COLL_ORDER
					from
						ec
					union
					select
						AGENT_ID,
						COLLECTION_OBJECT_ID,
						COLLECTOR_ROLE,
						COLL_ORDER
					from
						tr
				</cfquery>

				<cfdump var=#oldnnew#>
				<cfquery name="oldnnew_o" dbtype="query">
					select * from oldnnew order by COLL_ORDER
				</cfquery>
				<cfdump var=#oldnnew_o#>
				<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					delete from collector where collection_object_id=#collection_object_id#
				</cfquery>
				<cfset co=1>
				<cfloop query="oldnnew_o">
					<cfquery name="inscol" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						insert into collector (
							AGENT_ID,
							COLLECTION_OBJECT_ID,
							COLLECTOR_ROLE,
							COLL_ORDER
						) values (
							#AGENT_ID#,
							#COLLECTION_OBJECT_ID#,
							'#COLLECTOR_ROLE#',
							#co#
						)
					</cfquery>
					<cfset co=co+1>
				</cfloop>
				<br>inserted for <a href="#Application.ServerRootURL#/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">#collection_object_id#</a>
				<!---- this may have inserted multiple rows, delete for specimen NOT key ---->
				<cfquery name="gotit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					delete from cf_temp_collector where COLLECTION_OBJECT_ID=#COLLECTION_OBJECT_ID#
				</cfquery>
				<br>deleted for #collection_object_id#
			</cftransaction>
		</cfloop>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">