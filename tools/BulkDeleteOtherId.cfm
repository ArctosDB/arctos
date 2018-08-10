<cfsetting requesttimeout="600">

<cfinclude template="/includes/_header.cfm">

<cfset title="bulk DELETE identifiers">

<!---- make the table

drop table cf_temp_delete_oids;
drop public synonym cf_temp_delete_oids;

create table cf_temp_delete_oids (
	key number,
	collection_object_id number,
	guid varchar2(60) not null,
	other_id_type varchar2(255) not null,
	other_id_number varchar2(255) not null,
	other_id_references varchar2(255) not null,
	status varchar2(4000),
	username varchar2(60) not null
);

	create public synonym cf_temp_delete_oids for cf_temp_delete_oids;
	grant select,insert,update,delete on cf_temp_delete_oids to manage_collection;

	 CREATE OR REPLACE TRIGGER cf_temp_d_oids_key
 before insert  ON cf_temp_delete_oids
 for each row
    begin
    	if :NEW.key is null then
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;


		:NEW.username:=SYS_CONTEXT('USERENV', 'SESSION_USER');
    end;
/
sho err


------>
<cfif action is "template">
	<cfoutput>
		<cfset d="guid,other_id_type,other_id_number,other_id_references">
		<cffile action="write" addnewline="no" file="#Application.webDirectory#/download/BulkDeleteOtherId.csv" output="#d#">
		<cflocation url="/download.cfm?file=BulkDeleteOtherId.csv" addtoken="false">
		<a href="/download/BulkDeleteOtherId.csv">Click here if your file does not automatically download.</a>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------->
<cfif action is "nothing">
	Upload a comma-delimited text file (csv). This will delete your existing data from this application.
	<p>
		<a href="BulkDeleteOtherId.cfm?action=template">get a template here</a>
	</p>
	<div class="importantNotification">
		This add DELETES data. Proceed with caution.
	</div>
	<table border>
		<tr>
			<th>Column</th>
			<th>Required</th>
			<th>ExampleData</th>
			<th>Wutsitdo</th>
		</tr>
		<tr>
			<td>guid</td>
			<td>yes</td>
			<td>UAM:Mamm:12</td>
			<td>
				Specimen from which to remove OtherID.
			</td>
		</tr>
		<tr>
			<td>other_id_type</td>
			<td>yes</td>
			<td>
				OTHER_ID_TYPE from <a href="/info/ctDocumentation.cfm?table=CTCOLL_OTHER_ID_TYPE">CTCOLL_OTHER_ID_TYPE</a>
			</td>
			<td>
				part of ID to remove
			</td>
		</tr>
		<tr>
			<td>other_id_number</td>
			<td>yes</td>
			<td>
				Value of the other_id to delete
			</td>
			<td>
				part of ID to remove
			</td>
		</tr>
		<tr>
			<td>other_id_references</td>
			<td>yes</td>
			<td>
				other_id_references from <a href="/info/ctDocumentation.cfm?table=CTID_REFERENCES">CTID_REFERENCES</a>
			</td>
			<td>
				part of ID to remove
			</td>
		</tr>
	</table>
	<form name="oids" method="post" enctype="multipart/form-data" action="BulkDeleteOtherId.cfm">
		<input type="hidden" name="Action" value="getFile">
		<label for="">upload CSV</label>
		<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file">
	</form>
</cfif>
<!------------------------------------------------------->
<cfif action is "getFile">
<cfoutput>
	<!--- put this in a temp table --->
	<cfquery name="flush" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from cf_temp_delete_oids where upper(username)='#ucase(session.username)#'
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
		<cfif o is 1>
			<cfset colNames=replace(colNames,",","","first")>
		</cfif>
		<cfif len(colVals) gt 1>
			<cfset colVals=replace(colVals,",","","first")>
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into cf_temp_delete_oids (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>
	<p>
		Upload success. Proceed to <a href="BulkDeleteOtherId.cfm?action=validate">validate</a>.
	</p>
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "validate">
<cfoutput>
	<cfquery name="presetstatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update
			cf_temp_delete_oids
		set
			(status)=(
			select 'Found count: ' || count(*)
		from
			flat,
			coll_obj_other_id_num
		where
			flat.collection_object_id=coll_obj_other_id_num.collection_object_id and
			flat.guid=cf_temp_delete_oids.guid and
			coll_obj_other_id_num.other_id_type=cf_temp_delete_oids.other_id_type and
			coll_obj_other_id_num.display_value=cf_temp_delete_oids.other_id_number and
			coll_obj_other_id_num.ID_REFERENCES=cf_temp_delete_oids.other_id_references)
			where
			upper(username)='#ucase(session.username)#'
	</cfquery>
	<p>
		Validated. <a href="BulkDeleteOtherId.cfm?action=view_results">view_results</a>.
	</p>
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "view_results">
	<script src="/includes/sorttable.js"></script>
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_temp_delete_oids where upper(username)='#ucase(session.username)#'
		</cfquery>
		<div class="importantNotification">
			CAREFULLY review the table below. Anything where status is not "Found count: 1" probably isn't doing what you want.
			This application will happily do nothing (in the case of "Found count: 0") or delete many identifiers from a specimen
			(in the case of "Found count: {>1}").
		</div>
		<table border id="t" class="sortable">
			<tr>
				<th>guid</th>
				<th>other_id_type</th>
				<th>other_id_number</th>
				<th>other_id_references</th>
				<th>status</th>
			</tr>
			<cfloop query="d">
				<tr>
					<td><a href="/guid/#guid#" target="_blank">#guid#</a></td>
					<td>#other_id_type#</td>
					<td>#other_id_number#</td>
					<td>#other_id_references#</td>
					<td>#status#</td>
				</tr>
			</cfloop>
		</table>

		<div class="importantNotification">
			CAREFULLY review the table below. Anything where status is not "Found count: 1" probably isn't doing what you want.
			This application will happily do nothing (in the case of "Found count: 0") or delete many identifiers from a specimen
			(in the case of "Found count: {>1}").
		</div>

		<p>
			If you've read the warnings and reviewed the data, you can proceed to <a href="BulkDeleteOtherId.cfm?action=delete">delete</a>.
		</p>
		<p>
			If something isn't right, you can <a href="BulkDeleteOtherId.cfm?action=nothing">reload CSV</a>.
		</p>
	</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "delete">
	<cfoutput>

		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_temp_delete_oids where upper(username)='#ucase(session.username)#'
		</cfquery>

		<cfloop query="d">
			<cfquery name="buhBye" result="dq" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				delete from coll_obj_other_id_num where collection_object_id in (select collection_object_id from flat where guid='#guid#') and
				coll_obj_other_id_num.other_id_type='#other_id_type#' and
			coll_obj_other_id_num.display_value='#other_id_number#' and
			coll_obj_other_id_num.ID_REFERENCES='#other_id_references#'
			</cfquery>
			<br>Running: #dq.sql#
			<br>Records Deleted: #dq.RECORDCOUNT#
		</cfloop>
	</cfoutput>
	done
</cfif>
<cfinclude template="/includes/_footer.cfm">