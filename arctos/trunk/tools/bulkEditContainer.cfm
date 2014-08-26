<cfinclude template="/includes/_header.cfm">
<cfset title="Bulk Edit Container">
<cfset thecolumns="BARCODE,LABEL,OLD_CONTAINER_TYPE,CONTAINER_TYPE,DESCRIPTION,CONTAINER_REMARKS,HEIGHT,LENGTH,WIDTH,NUMBER_POSITIONS">
<cfif action is "makeTemplate">
	<cfset header=thecolumns>
	<cffile action = "write"
    file = "#Application.webDirectory#/download/BulkContainerEdit.csv"
    output = "#header#"
    addNewLine = "no">
	<cflocation url="/download.cfm?file=BulkContainerEdit.csv" addtoken="false">
</cfif>
<!------------------------------------------------------------------------------------------->
<cfif action is "nothing">
	<p>
		Edit groups of containers by loading CSV.
	</p>
	<p>
		This form is not restricted to labels; it will alter ANY container.
	</p>
	<p>
		This form will happily overwrite existing <strong><em>important</em></strong> information. Use it with caution and make sure you know what it's doing!
	</p>
	<p>
		Upload CSV with the following columns. <a href="bulkEditContainer.cfm?action=makeTemplate">Get a template here</a>
	</p>
	<table border>
		<tr>
			<th>Column</th>
			<th>Description</th>
		</tr>
		<tr>
			<td>BARCODE</td>
			<td>Required; must be unique.</td>
		</tr>
		<tr>
			<td>OLD_CONTAINER_TYPE</td>
			<td>Required. <a href="/info/ctDocumentation.cfm?table=CTCONTAINER_TYPE">CTCONTAINER_TYPE</a></td>
		</tr>
		<tr>
			<td>CONTAINER_TYPE</td>
			<td>Required. New container type. <a href="/info/ctDocumentation.cfm?table=CTCONTAINER_TYPE">CTCONTAINER_TYPE</a></td>
		</tr>
		<tr>
			<td>LABEL</td>
			<td>Empty (no value) to ignore, new value to update.</td>
		</tr>
		<tr>
			<td>DESCRIPTION</td>
			<td>"NULL" (no quotes, case-sensitive) will update to NULL; blank will be ignored (no updates).</td>
		</tr>
		<tr>
			<td>CONTAINER_REMARKS</td>
			<td>"NULL" (no quotes, case-sensitive) will update to NULL; blank will be ignored (no updates).</td>
		</tr>
		<tr>
			<td>HEIGHT</td>
			<td>"0" (no quotes) will update to NULL; blank will be ignored (no updates).</td>
		</tr>
		<tr>
			<td>LENGTH</td>
			<td>"0" (no quotes) will update to NULL; blank will be ignored (no updates).</td>
		</tr>
		<tr>
			<td>WIDTH</td>
			<td>"0" (no quotes)  will update to NULL; blank will be ignored (no updates).</td>
		</tr>
		<tr>
			<td>NUMBER_POSITIONS</td>
			<td>"0" (no quotes)  will update to NULL; blank will be ignored (no updates).</td>
		</tr>	
	</table>
	<form enctype="multipart/form-data" action="bulkEditContainer.cfm" method="POST">
		<input type="hidden" name="action" value="getFile">
		<label for="FiletoUpload">Upload CSV</label>
		<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">

		<input type="submit" value="Upload this file" class="insBtn">
	</form>
</cfif>
<!------------------------------------------------------------------------------------------->
<cfif action IS "getFile">
	<cfoutput>
		<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from cf_temp_lbl2contr
		</cfquery>
		<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
		<cfset  util = CreateObject("component","component.utilities")>
		<cfset q = util.CSVToQuery(CSV=fileContent)>
		<cfset colNames=q.columnList>
		<!--- disallow some procedural stuff that sometimes ends up in the download/reload CSV --->
		<cfif listfindnocase(colNames,'status') gt 0>
			<cfset colNames=listdeleteat(colNames,listfindnocase(colNames,'status'))>
		</cfif>
		<cfif listfindnocase(colNames,'note') gt 0>
			<cfset colNames=listdeleteat(colNames,listfindnocase(colNames,'note'))>
		</cfif>
		<cfquery name="qclean" dbtype="query">
			select #colnames# from q
		</cfquery>	
		<cfset sql="insert all ">
		<cfloop query="qclean">		
			<cfset sql=sql & " into cf_temp_lbl2contr (#colnames#,status) values (">
			<cfloop list="#colnames#" index="i">
				<cfset sql=sql & "'#evaluate("qClean." & i)#',">
			</cfloop>
			<cfset sql=sql & "'')">	
		</cfloop>
		<cfset sql=sql & "SELECT 1 FROM DUAL">
		<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			#preserveSingleQuotes(sql)#
		</cfquery>
		<cflocation url="bulkEditContainer.cfm?action=validateUpload" addtoken="false">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------->
<cfif action IS "validateUpload">
	<script src="/includes/sorttable.js"></script>
	<cfoutput>
		<cfquery name="upsbc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update 
				cf_temp_lbl2contr 
			set 
				status='barcode_not_found' 
			where 
				barcode not in (select barcode from container)
		</cfquery>
		<cfquery name="uasdfasps" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update 
				cf_temp_lbl2contr 
			set 
				status='new/old container type mismatch' 
			where 
				status is null and
				OLD_CONTAINER_TYPE is null and 
				CONTAINER_TYPE is not null
		</cfquery>
		<cfquery name="ups" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update 
				cf_temp_lbl2contr 
			set 
				status='old_container_type_nomatch' 
			where 
				status is null and
				(barcode,old_container_type) not in (select barcode,container_type from container)
		</cfquery>
		<cfquery name="upn_descr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update 
				cf_temp_lbl2contr 
			set 
				note=note || '; ' || 'existing container has description' 
			where 
				description ='NULL' and 
				barcode in (select barcode from container where description is not null)
		</cfquery>
		
		<cfquery name="upn_r" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update 
				cf_temp_lbl2contr 
			set 
				note=note || '; ' || 'existing container has remark' 
			where 
				container_remarks='NULL' and 
				barcode in (select barcode from container where container_remarks is not null)
		</cfquery>
		<cfquery name="upn_l" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update 
				cf_temp_lbl2contr 
			set 
				note=note || '; ' || 'existing container has length' 
			where 
				length =0 and 
				barcode in (select barcode from container where length is not null)
		</cfquery>
		<cfquery name="upn_h" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update 
				cf_temp_lbl2contr 
			set 
				note=note || '; ' || 'existing container has height' 
			where 
				height =0 and 
				barcode in (select barcode from container where height is not null)
		</cfquery>
		<cfquery name="upn_w" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update 
				cf_temp_lbl2contr 
			set 
				note=note || '; ' || 'existing container has width' 
			where 
				width =0 and 
				barcode in (select barcode from container where width is not null)
		</cfquery>
		<cfquery name="upn_w" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update 
				cf_temp_lbl2contr 
			set 
				note=note || '; ' || 'existing container has number_positions' 
			where 
				number_positions =0 and 
				barcode in (select barcode from container where number_positions is not null)
		</cfquery>
		<cfquery name="fail" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select count(*) c from cf_temp_lbl2contr where status is not null
		</cfquery>
		<cfif fail.c gt 0>
			There are problems. Fix the data and try again.
		<cfelse>
			Validation complete. Carefully recheck the data and <a href="bulkEditContainer.cfm?action=finalizeUpload">click here to finalize the upload</a>.
			Pay special attention to the "note" column - these are not "errors" but information here may be an indication that 
			you are about to make a huge mess.
		</cfif>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_temp_lbl2contr
		</cfquery>
		<table border id="t" class="sortable">
			<tr>
				<th>barcode</th>
				<th>label</th>
				<th>status</th>
				<th>note</th>
				<th>old_container_type</th>
				<th>container_type</th>
				<th>description</th>
				<th>container_remarks</th>
				<th>height</th>
				<th>length</th>
				<th>width</th>
				<th>number_positions</th>
			</tr>
			<cfloop query="d">
				<tr>
					<td>#barcode#</td>
					<td>
						<cfif len(label) eq 0>
							NO UPDATE
						<cfelse>
							#label#
						</cfif>
					</td>
					<td>#status#</td>
					<td>#note#</td>
					<td>#old_container_type#</td>
					<td>#container_type#</td>
					<td>
						<cfif len(description) eq 0>
							NO UPDATE
						<cfelse>
							#description#
						</cfif>
					</td>
					<td>
						<cfif len(container_remarks) eq 0>
							NO UPDATE
						<cfelse>
							#container_remarks#
						</cfif>
					</td>
					<td>
						<cfif len(height) eq 0>
							NO UPDATE
						<cfelse>
							#height#
						</cfif>
					</td>
					<td>
						<cfif len(length) eq 0>
							NO UPDATE
						<cfelse>
							#length#
						</cfif>
					</td>
					<td>
						<cfif len(width) eq 0>
							NO UPDATE
						<cfelse>
							#width#
						</cfif>
					</td>
					<td>
						<cfif len(number_positions) eq 0>
							NO UPDATE
						<cfelse>
							#number_positions#
						</cfif>
					</td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
</cfif>
<!------------------------------------------>
<cfif action IS "finalizeUpload">

	<!--- lots of possibliities here, so break this into a few simpler queries ---->
	<cftransaction>
		<cfquery name="changeContainerType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update 
				container 
			set (
				container.container_type
			)=(
				select 
					cf_temp_lbl2contr.container_type
				from 
					cf_temp_lbl2contr
				where 
					cf_temp_lbl2contr.barcode=container.barcode
			)
			where exists (
				select
					1
				from
					cf_temp_lbl2contr
				where
					cf_temp_lbl2contr.barcode=container.barcode and
					cf_temp_lbl2contr.container_type != container.container_type
			)
		</cfquery>
		<cfquery name="description" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update 
				container 
			set (
				container.description
			)=(
				select 
					decode(
						cf_temp_lbl2contr.description,
						'NULL',null,
						cf_temp_lbl2contr.description
					)
				from 
					cf_temp_lbl2contr
				where 
					cf_temp_lbl2contr.barcode=container.barcode
			)
			where exists (
				select
					1
				from
					cf_temp_lbl2contr
				where
					cf_temp_lbl2contr.description is not null and
					cf_temp_lbl2contr.barcode=container.barcode
			)
		</cfquery>
		<cfquery name="container_remarks" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update 
				container 
			set (
				container.container_remarks
			)=(
				select 
					decode(
						cf_temp_lbl2contr.container_remarks,
						'NULL',null,
						cf_temp_lbl2contr.container_remarks
					)
				from 
					cf_temp_lbl2contr
				where 
					cf_temp_lbl2contr.barcode=container.barcode
			)
			where exists (
				select
					1
				from
					cf_temp_lbl2contr
				where
					cf_temp_lbl2contr.container_remarks is not null and
					cf_temp_lbl2contr.barcode=container.barcode
			)
		</cfquery>
		<cfquery name="label" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update 
				container 
			set (
				container.label
			)=(
				select 
					cf_temp_lbl2contr.label
				from 
					cf_temp_lbl2contr
				where 
					cf_temp_lbl2contr.barcode=container.barcode
			)
			where exists (
				select
					1
				from
					cf_temp_lbl2contr
				where
					cf_temp_lbl2contr.label is not null and
					cf_temp_lbl2contr.barcode=container.barcode
			)
		</cfquery>
		<cfquery name="height" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update 
				container 
			set (
				container.height
			)=(
				select 
					decode(
						cf_temp_lbl2contr.height,
						'0',null,
						cf_temp_lbl2contr.height
					)
				from 
					cf_temp_lbl2contr
				where 
					cf_temp_lbl2contr.barcode=container.barcode
			)
			where exists (
				select
					1
				from
					cf_temp_lbl2contr
				where
					cf_temp_lbl2contr.height is not null and
					cf_temp_lbl2contr.barcode=container.barcode
			)
		</cfquery>
		<cfquery name="length" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update 
				container 
			set (
				container.length
			)=(
				select 
					decode(
						cf_temp_lbl2contr.length,
						'0',null,
						cf_temp_lbl2contr.length
					)
				from 
					cf_temp_lbl2contr
				where 
					cf_temp_lbl2contr.barcode=container.barcode
			)
			where exists (
				select
					1
				from
					cf_temp_lbl2contr
				where
					cf_temp_lbl2contr.length is not null and
					cf_temp_lbl2contr.barcode=container.barcode
			)
		</cfquery>
		<cfquery name="width" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update 
				container 
			set (
				container.width
			)=(
				select 
					decode(
						cf_temp_lbl2contr.width,
						'0',null,
						cf_temp_lbl2contr.width
					)
				from 
					cf_temp_lbl2contr
				where 
					cf_temp_lbl2contr.barcode=container.barcode
			)
			where exists (
				select
					1
				from
					cf_temp_lbl2contr
				where
					cf_temp_lbl2contr.width is not null and
					cf_temp_lbl2contr.barcode=container.barcode
			)
		</cfquery>
		<cfquery name="number_positions" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update 
				container 
			set (
				container.number_positions
			)=(
				select 
					decode(
						cf_temp_lbl2contr.number_positions,
						'0',null,
						cf_temp_lbl2contr.number_positions
					)
				from 
					cf_temp_lbl2contr
				where 
					cf_temp_lbl2contr.barcode=container.barcode
			)
			where exists (
				select
					1
				from
					cf_temp_lbl2contr
				where
					cf_temp_lbl2contr.number_positions is not null and
					cf_temp_lbl2contr.barcode=container.barcode
			)
		</cfquery>
	</cftransaction>
	all done
</cfif>
<cfinclude template="/includes/_footer.cfm">