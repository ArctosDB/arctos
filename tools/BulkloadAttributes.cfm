<!---
 see migration/6.4 for DDL


ddl to load big batches:


declare
	-- update if you aren't me....
	myAgentId number := 2072;
begin
	for r in (select * from cf_temp_attributes where username='DLM') loop
		INSERT INTO attributes (
			attribute_id,
			collection_object_id,
			determined_by_agent_id,
			attribute_type,
			attribute_value
			,attribute_units
			,attribute_remark
			,determined_date
			,determination_method
		) VALUES (
			sq_attribute_id.nextval,
			r.collection_object_id,
			r.determined_by_agent_id,
			r.attribute,
			r.attribute_value,
			r.attribute_units,
			r.remarks,
			r.attribute_date,
			r.attribute_meth
		);
	end loop;
end;
/



--->
<cfinclude template="/includes/_header.cfm">
<cfset title="Bulkload Specimen Attributes">
<cfif action is "template">
	<cfoutput>
		<cfset d="OTHER_ID_TYPE,OTHER_ID_NUMBER,ATTRIBUTE,ATTRIBUTE_VALUE,ATTRIBUTE_UNITS,ATTRIBUTE_DATE,ATTRIBUTE_METH,DETERMINER,REMARKS,guid_prefix">
		<cffile action = "write"
		    file = "#Application.webDirectory#/download/BulkloadAttributesTemplate.csv"
		   	output = "#d#"
		   	addNewLine = "no">
		<cflocation url="/download.cfm?file=BulkloadAttributesTemplate.csv" addtoken="false">
		<a href="/download/BulkloadAttributesTemplate.csv">Click here if your file does not automatically download.</a>
	</cfoutput>
</cfif>
<!----------------------------------->
<cfif action is "nothing">
	<cfoutput>
		<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_temp_attributes where upper(username)='#ucase(session.username)#'
		</cfquery>
		<p>
			<a href="BulkloadAttributes.cfm?action=managemystuff">Manage your existing #mine.recordcount# records</a>
		</p>
	</cfoutput>
	Upload a comma-delimited text file (csv). <a href="BulkloadAttributes.cfm?action=template">Get a template here</a>
	Include column headings. This form will happily create duplicates; don't just randomly smash buttons. In the event of multiple
	determinations (varying in value or not), "duplicates" may be correct and desirable.
	<table border>
		<tr>
			<th>Column</th>
			<th>Required?</th>
			<th>Wutsit</th>
			<th>Vocabulary</th>
		</tr>
		<tr>
			<td>guid_prefix</td>
			<td>yes*</td>
			<td>
				UAM:Mamm - first two parts of tripartite GUID in specimen URL, or from manage collection. Specifies collection from which to find the specimens.
				Guid_prefix is unnecessary ONLY when OTHER_ID_TYPE is "UUID" (associated with records created from the specimen bulkloader)
			</td>
			<td></td>
		</tr>
		<tr>
			<td>OTHER_ID_TYPE</td>
			<td>yes</td>
			<td>Other ID type ("catalog number" is OK)</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTCOLL_OTHER_ID_TYPE">CTCOLL_OTHER_ID_TYPE</a></td>
		</tr>
		<tr>
			<td>OTHER_ID_NUMBER</td>
			<td>yes</td>
			<td>Value associated with OTHER_ID_NUMBER - integer-only for OTHER_ID_NUMBER=catalog number</td>
			<td></td>
		</tr>
		<tr>
			<td>ATTRIBUTE</td>
			<td>yes</td>
			<td>New attribute</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_TYPE">CTATTRIBUTE_TYPE</a></td>
		</tr>
		<tr>
			<td>ATTRIBUTE_VALUE</td>
			<td>yes</td>
			<td>varies - see CTATTRIBUTE_CODE_TABLES</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES">CTATTRIBUTE_CODE_TABLES</a></td>
		</tr>
		<tr>
			<td>ATTRIBUTE_UNITS</td>
			<td>sometimes</td>
			<td>varies - see CTATTRIBUTE_CODE_TABLES</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES">CTATTRIBUTE_CODE_TABLES</a></td>
		</tr>
		<tr>
			<td>ATTRIBUTE_DATE</td>
			<td>no</td>
			<td>ISO8601-format date/time</td>
			<td></td>
		</tr>
		<tr>
			<td>ATTRIBUTE_METH</td>
			<td>no</td>
			<td>method</td>
			<td></td>
		</tr>
		<tr>
			<td>DETERMINER</td>
			<td>yes</td>
			<td>agent - use preferred name</td>
			<td></td>
		</tr>
		<tr>
			<td>REMARKS</td>
			<td>no</td>
			<td></td>
			<td></td>
		</tr>
	</table>
	<cfform name="atts" method="post" enctype="multipart/form-data">
		<input type="hidden" name="Action" value="getFile">
		<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" class="savBtn">
	 </cfform>
</cfif>
<!------------------------------------------------------->
<cfif action is "takeStudentRecords">
	<cfoutput>
		<a href="BulkloadSpecimenEvent.cfm?action=managemystuff">back to my stuff</a>
		<cfquery name="d" datasource="uam_god">
			select  count(*) c,
	        upper(username) username
	      from
	        cf_temp_attributes
	      where
	        upper(username) != 'DLM' and
	        upper(username) in (
	          select distinct
	               my_privs.grantee
	              from
	                dba_role_privs user_privs,
	                dba_role_privs my_privs,
	                cf_collection user_colns,
	                cf_collection my_colns
	              where
	                user_privs.granted_role = user_colns.portal_name and
	                my_privs.granted_role = my_colns.portal_name and
	                upper(user_privs.grantee)='#ucase(session.username)#' and
	                user_colns.portal_name=my_colns.portal_name
	              )
	        group by username order by username
			</cfquery>

		<!--- old and slow
		<cfquery name="d" datasource="uam_god">
			select
				count(*) c,
				upper(username) username
			from
				cf_temp_attributes
			where
				upper(username) != '#ucase(session.username)#' and
				upper(username) in (
					select
						upper(grantee)
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
			        			and upper(d.grantee) = '#ucase(session.username)#'
						) and
					upper(grantee) in (select upper(grantee) from dba_role_privs where upper(granted_role) = 'DATA_ENTRY')
					) group by upper(username) order by upper(username)
		</cfquery>
		---->
		<form name="d" method="post" action="BulkloadAttributes.cfm">
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
<!------------------------------------------------------------------------------------------------>
<cfif action is "saveClaimed">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_attributes set username='#ucase(session.username)#' where upper(username) in (#listqualify(username,"'")#)
	</cfquery>
	<cflocation url="BulkloadAttributes.cfm?action=managemystuff" addtoken="false">
</cfif>
<!------------------------------------------------------------------------------------------------>
<cfif action is "getGuidUUID">
	<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			other_id_number
		from
			cf_temp_attributes
		where
			upper(username)='#ucase(session.username)#' and
			guid_prefix is null and
			other_id_type='UUID' and
			other_id_number is not null
		group by
			other_id_number
	</cfquery>
	<cfloop query="mine">
		<cfquery name="gg" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				guid_prefix
			from
				collection,
				cataloged_item,
				coll_obj_other_id_num
			where
				collection.collection_id=cataloged_item.collection_id and
				cataloged_item.collection_object_id=coll_obj_other_id_num.collection_object_id and
				other_id_type='UUID' and
				display_value='#other_id_number#'
		</cfquery>
		<cfif gg.recordcount is 1>
			<cfquery name="gg" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update cf_temp_attributes set guid_prefix='#gg.guid_prefix#' where other_id_number='#other_id_number#'
			</cfquery>
		</cfif>
	</cfloop>
	<cflocation url="BulkloadAttributes.cfm?action=managemystuff" addtoken="false">
</cfif>
<!------------------------------------------------------->
<cfif action is "getFile">
<cfoutput>
	<cfif not isdefined("insmeth")>
		<cfset insmeth='sngle'>
	</cfif>

	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	<cfset  util = CreateObject("component","component.utilities")>
	<cfset q = util.CSVToQuery(CSV=fileContent)>
	<cfset colNames=q.columnList>
	<!--- disallow some procedural stuff that sometimes ends up in the download/reload CSV --->
	<cfif listfindnocase(colNames,'status') gt 0>
		<cfset colNames=listdeleteat(colNames,listfindnocase(colNames,'status'))>
	</cfif>
	<cfif listfindnocase(colNames,'COLLECTION_OBJECT_ID') gt 0>
		<cfset colNames=listdeleteat(colNames,listfindnocase(colNames,'COLLECTION_OBJECT_ID'))>
	</cfif>
	<cfif listfindnocase(colNames,'DETERMINED_BY_AGENT_ID') gt 0>
		<cfset colNames=listdeleteat(colNames,listfindnocase(colNames,'DETERMINED_BY_AGENT_ID'))>
	</cfif>
	<cfif listfindnocase(colNames,'KEY') gt 0>
		<cfset colNames=listdeleteat(colNames,listfindnocase(colNames,'KEY'))>
	</cfif>
	<cfif listfindnocase(colNames,'USERNAME') gt 0>
		<cfset colNames=listdeleteat(colNames,listfindnocase(colNames,'USERNAME'))>
	</cfif>
	<cfquery name="qclean" dbtype="query">
		select #colnames# from q
	</cfquery>
	<cfif insmeth is 'all'>
		<!--- for some crazy reason this is slow, so bypass for now ---->
		<cfset sql="insert all ">
		<cfloop query="qclean">
			<cfset sql=sql & " into cf_temp_attributes (#colnames#,status) values (">
			<cfloop list="#colnames#" index="i">
				<cfset sql=sql & "'#escapeQuotes(evaluate("qClean." & i))#',">
			</cfloop>
			<cfset sql=sql & "'new load')">
		</cfloop>
		<cfset sql=sql & "SELECT 1 FROM DUAL">
		<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			#preserveSingleQuotes(sql)#
		</cfquery>
	<cfelse>
		<cfloop query="qclean">
			<cfset sql="insert into cf_temp_attributes (#colnames#,status) values (">
			<cfloop list="#colnames#" index="i">
				<cfset sql=sql & "'#escapeQuotes(evaluate("qClean." & i))#',">
			</cfloop>
			<cfset sql=sql & "'new load')">
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				#preserveSingleQuotes(sql)#
			</cfquery>
		</cfloop>
	</cfif>
	<cflocation url="BulkloadAttributes.cfm?action=manageMyStuff" addtoken="false">
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "getCSV">
	<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_attributes where upper(username)='#ucase(session.username)#'
	</cfquery>
	<cfset  util = CreateObject("component","component.utilities")>
	<cfset csv = util.QueryToCSV2(Query=mine,Fields=mine.columnlist)>
	<cffile action = "write"
	    file = "#Application.webDirectory#/download/BulkloadAttributeData.csv"
    	output = "#csv#"
    	addNewLine = "no">
	<cflocation url="/download.cfm?file=BulkloadAttributeData.csv" addtoken="false">
</cfif>
<!------------------------------------------------------->
<cfif action is "validate">
	<cfoutput>
		<cfquery name="presetstatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update
				cf_temp_attributes
			set
				status=NULL,
				collection_object_id=null
			where
				upper(username)='#ucase(session.username)#'
		</cfquery>
		<cfquery name="presetstatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update
				cf_temp_attributes
			set
				status=decode(status,
					null,'click "get GUID Prefix" before validating',
					status || '; click "get GUID Prefix" before validating')
			where
				upper(username)='#ucase(session.username)#' and
				guid_prefix is null
		</cfquery>
		<cfquery name="collObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_temp_attributes set COLLECTION_OBJECT_ID = (
				select
					cataloged_item.collection_object_id
				from
					cataloged_item,
					collection
				WHERE
					cataloged_item.collection_id = collection.collection_id and
					collection.guid_prefix = cf_temp_attributes.guid_prefix and
					cat_num=cf_temp_attributes.other_id_number
			) where
				status is null and
				other_id_type = 'catalog number'
				and upper(username)='#ucase(session.username)#'
		</cfquery>
		<cfquery name="collObj_nci" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_temp_attributes set COLLECTION_OBJECT_ID = (
				select
					cataloged_item.collection_object_id
				from
					cataloged_item,
					collection,
					coll_obj_other_id_num
				WHERE
					cataloged_item.collection_id = collection.collection_id and
					cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id and
					collection.guid_prefix = cf_temp_attributes.guid_prefix and
					other_id_type = cf_temp_attributes.other_id_type and
					display_value = cf_temp_attributes.other_id_number
			) where
				status is null and
				other_id_type != 'catalog number' and
				upper(username)='#ucase(session.username)#'
		</cfquery>
		<cfquery name="collObj_fail" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update
				cf_temp_attributes
			set
				status=decode(status,
					null,'cataloged item not found',
					status || '; cataloged item not found')
			where
				collection_object_id is null and
				upper(username)='#ucase(session.username)#'
		</cfquery>

		<cfquery name="iva" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update
				cf_temp_attributes
			set
				status=decode(status,
					null,'attribute failed validation',
					status || '; attribute failed validation')
				where
					isValidAttribute(
						ATTRIBUTE,
						ATTRIBUTE_VALUE,
						ATTRIBUTE_UNITS,
						(select collection_cde from collection where collection.guid_prefix=cf_temp_attributes.guid_prefix)
					)=0 and
					upper(username)='#ucase(session.username)#'
		</cfquery>
		<cfquery name="chkDate" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update
				cf_temp_attributes
			set
				status=decode(status,
					null,'invalid date',
					status || '; invalid date')
			where
				ATTRIBUTE_DATE is not null and
				upper(username)='#ucase(session.username)#' and
				is_iso8601(ATTRIBUTE_DATE)!='valid'
		</cfquery>
		<cfquery name="attDet1" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_temp_attributes set DETERMINED_BY_AGENT_ID=getAgentID(determiner) where upper(username)='#ucase(session.username)#'
		</cfquery>
		<cfquery name="attDetFail" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update
				cf_temp_attributes
			set
				status=decode(status,
					null,'invalid determiner',
					status || '; invalid determiner')
			where
				DETERMINED_BY_AGENT_ID is null and
				determiner is not null and
				upper(username)='#ucase(session.username)#'
		</cfquery>
		<cfquery name="postsetstatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update
				cf_temp_attributes
			set
				status='valid'
			where
				status is null and
				upper(username)='#ucase(session.username)#'
		</cfquery>
		<cflocation url="BulkloadAttributes.cfm?action=manageMyStuff" addtoken="false">
	</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "manageMyStuff">
	<script src="/includes/sorttable.js"></script>
	<script>
		function cd(){
			yesDelete = window.confirm('Are you sure you want to delete all of your data in the attributes bulkloader?');
			if (yesDelete == true) {
				document.location='BulkloadAttributes.cfm?action=deletemine';
			}
		}
	</script>
	<cfoutput>
		<cfquery name="datadump" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_temp_attributes where upper(username)='#ucase(session.username)#'
		</cfquery>
		<cfquery name="nv" dbtype="query">
			select count(*) c from datadump where guid_prefix is null and other_id_type='UUID'
		</cfquery>
		<cfif nv.c gt 0>

				Records may be entered here via the data entry application, before any known-unique IDs exist.
				A UUID is therefore created to serve as a bridge to specimens. This form must have guid_prefix, which
				can be retrieved from cataloged items with complementary GUIDs, to work. This link will do nothing for those specimens
				which have not been entered (still in bulkloader) and for those which UUID has been altered or removed. Records
				with an existing guid_prefix will be ignored. Make sure the results are what you expect.
				<br><a href="BulkloadAttributes.cfm?action=getGuidUUID">get guid_prefix from UUID</a>
			<hr>
		</cfif>
		<cfquery name="pf" dbtype="query">
			select count(*) l from datadump where status != 'valid'
		</cfquery>
		<cfif session.roles contains "manage_collection">
			You have manage_collection, so you can "take" records from people in your collection(s). This is useful when students
			(who should generally not have access to this form) enter data here via the specimen bulkloader. Records which
			are still in the bulkloader will fail validation; they become your responsibility after you claim them, so
			make sure they are not deleted until the specimen exists and they are
			attached to it.

			<br>NOT ALL OF THESE WILL NECESSARILY BE YOUR SPECIMENS!! Read stuff, then click.
			<br>Use this with great caution. You may need to coordinate with other curatorial staff or involve a DBA.
			<br><a href="BulkloadAttributes.cfm?action=takeStudentRecords">Check for records entered by people in your collection(s)</a>
			<hr>
		</cfif>
		<p>
			<a href="BulkloadAttributes.cfm">upload more records</a>
		</p>
		<cfif pf.recordcount gt 0>
			<p>
				Not everything will load - <a href="BulkloadAttributes.cfm?action=validate">validate here</a>.
			</p>
		</cfif>
		<p>
			<a href="BulkloadAttributes.cfm?action=loadData">click to load and delete "valid" records</a>. Records with a status of anything
			except "valid" will be ignored. Status may be carried over from previous operations; click "validate" above
			if you're not absolutely sure that the data here are current. Carefully review the table below before proceeding.
		</p>
		<p>
			<a href="BulkloadAttributes.cfm?action=getCSV">Download all of your data as CSV</a> here. You might want to do this before
			clicking the "delete" link.
		</p>

		<p>

			<a href="##" onclick="cd();">Delete all of your data</a> here. Probably a good idea to grab a CSV backup first.
		</p>
		<form name="d" method="post" action="BulkloadAttributes.cfm">
			<input type="hidden" name="action" value="deleteChecked">
			<table border id="t" class="sortable">
				<tr>
					<th>delete</th>
					<th>STATUS</th>
					<th>Specimen</th>
					<th>GUID_PREFIX</th>
					<th>OTHER_ID_TYPE</th>
					<th>OTHER_ID_NUMBER</th>
					<th>ATTRIBUTE</th>
					<th>ATTRIBUTE_VALUE</th>
					<th>ATTRIBUTE_UNITS</th>
					<th>ATTRIBUTE_DATE</th>
					<th>ATTRIBUTE_METH</th>
					<th>DETERMINER</th>
					<th>REMARKS</th>
				</tr>
				<cfloop query="datadump">
					<tr>
						<td><input type="checkbox" name="key" value="#key#"></td>
						<td>#STATUS#</td>
						<td>
							<cfif status is "valid" and len(collection_object_id) gt 0>
								<a href="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">clicky</a>
							</cfif>
						</td>
						<td>#GUID_PREFIX#</td>
						<td>#OTHER_ID_TYPE#</td>
						<td>#OTHER_ID_NUMBER#</td>
						<td>#ATTRIBUTE#</td>
						<td>#ATTRIBUTE_VALUE#</td>
						<td>#ATTRIBUTE_UNITS#</td>
						<td>#ATTRIBUTE_DATE#</td>
						<td>#ATTRIBUTE_METH#</td>
						<td>#DETERMINER#</td>
						<td>#REMARKS#</td>
					</tr>
				</cfloop>
			</table>
			<br>
			<input type="submit" value="delete checked records">
		</form>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------>
<cfif action is "deleteChecked">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from cf_temp_attributes  where key in (#listqualify(key,"'")#)
	</cfquery>
	<cflocation url="BulkloadAttributes.cfm?action=managemystuff" addtoken="false">
</cfif>
<!------------------------------------------------------->
<cfif action is "deletemine">
	<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from cf_temp_attributes where upper(username)='#ucase(session.username)#'
	</cfquery>
	<cflocation url="BulkloadAttributes.cfm" addtoken="false">
</cfif>
<!------------------------------------------------------->
<cfif action is "loadData">
	<cfoutput>
		<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_temp_attributes where upper(username)='#ucase(session.username)#' and status='valid'
		</cfquery>
		<cftransaction>
			<cfloop query="getTempData">
				<cfquery name="newAtt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				INSERT INTO attributes (
					attribute_id,
					collection_object_id,
					determined_by_agent_id,
					attribute_type,
					attribute_value
					<cfif len(#attribute_units#) gt 0>
						,attribute_units
					</cfif>
					<cfif len(#remarks#) gt 0>
						,attribute_remark
					</cfif>
					,determined_date
					<cfif len(#attribute_meth#) gt 0>
						,determination_method
					</cfif>
					)
				VALUES (
					sq_attribute_id.nextval,
					#collection_object_id#,
					#determined_by_agent_id#,
					'#attribute#'
					,'#attribute_value#'
					<cfif len(#attribute_units#) gt 0>
						,'#attribute_units#'
					</cfif>
					<cfif len(#remarks#) gt 0>
						,'#remarks#'
					</cfif>
					,'#dateformat(attribute_date,"yyyy-mm-dd")#'
					<cfif len(#attribute_meth#) gt 0>
						,'#attribute_meth#'
					</cfif>
					)
					</cfquery>
			</cfloop>
			<cfquery name="delJustLoaded" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				delete from cf_temp_attributes where upper(username)='#ucase(session.username)#' and status='valid'
			</cfquery>
		</cftransaction>
		Spiffy, all done. <a href="BulkloadAttributes.cfm">load more Attributes</a>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">