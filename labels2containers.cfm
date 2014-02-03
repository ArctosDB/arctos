<cfinclude template="/includes/_header.cfm">
<cfset title="labels2containers">
<cfif action is "uploadCSV">
	<p>
		Upload CSV with the following columns. 
		
		<br>Barcode is the key.
		<br>old_container_type is required and must match current values (probably some type of label - 
		this restriction prevents re-re-purposing labels; develop a label handling system if this seems burdensome)
		<br>Everything else is an intended/new value, and all are optional. However, leaving them NULL will update the existing record to NULL. 
		<br>Code table, datatype, etc. rules apply.
		If that doesn't make sense, please do NOT use this form until it does.
		<ul>
			<li>barcode</li>
			<li>old_container_type</li>
			<li>container_type</li>
			<li>description</li>
			<li>container_remarks</li>
			<li>height</li>
			<li>length</li>
			<li>width</li>
			<li>number_positions</li>		
		</ul>
	</p>
	
	
	<form enctype="multipart/form-data" action="labels2containers.cfm" method="POST">
		<input type="hidden" name="action" value="getFile">
		<label for="FiletoUpload">Upload CSV</label>
		<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">

		<input type="submit" value="Upload this file" class="insBtn">
	</form>
	
	
</cfif>

<cfif action IS "getFile">
	<!--- put this in a temp table --->
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from cf_temp_lbl2contr
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
		<cfif #o# is 1>
			<cfset colNames=replace(colNames,",","","first")>
		</cfif>
		<cfif len(#colVals#) gt 1>
			<cfset colVals=replace(colVals,",","","first")>
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into cf_temp_lbl2contr (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>
	<cflocation url="labels2containers.cfm?action=validateUpload" addtoken="false">
</cfif>
<!------------------------------------------>
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
	
		<cfquery name="ups" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update 
				cf_temp_lbl2contr 
			set 
				status='old_container_type_nomatch' 
			where 
				status is null and
				barcode || '|' || old_container_type not in (select barcode || '|' || container_type from container)
		</cfquery>
	
	
		<cfquery name="upn_descr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update 
				cf_temp_lbl2contr 
			set 
				notes=notes || '; ' || 'existing container has description' 
			where 
				description is null and 
				barcode in (select barcode from container where description is not null)
		</cfquery>
		
		
		<cfquery name="fail" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select count(*) c from cf_temp_lbl2contr where status is not null
		</cfquery>
		<cfif fail.c gt 0>
			There are problems. Fix the data and try again.
		<cfelse>
			Validation complete. Carefully recheck the data and <a href="labels2containers.cfm?action=finalizeUpload">click here to finalize the upload</a>
		</cfif>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_temp_lbl2contr
		</cfquery>
		<table border id="t" class="sortable">
			<tr>
				<th>barcode</th>
				<th>status</th>
				<th>notes</th>
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
					<td>#status#</td>
					<td>#notes#</td>
					<td>#old_container_type#</td>
					<td>#container_type#</td>
					<td>#description#</td>
					<td>#container_remarks#</td>
					<td>#height#</td>
					<td>#length#</td>
					<td>#width#</td>
					<td>#number_positions#</td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
</cfif>

<!------------------------------------------>
<cfif action IS "finalizeUpload">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update container set (container_type,description,container_remarks,height,length,width,number_positions)
		=(select container_type,description,container_remarks,height,length,width,number_positions
		from cf_temp_lbl2contr )
		where cf_temp_lbl2contr.barcode=container.barcode
	</cfquery>
		update 
			container 
		set (
			container.container_type,
			container.description,
			container.container_remarks,
			container.height,
			container.length,
			container.width,
			container.number_positions
		)=(
			select 
				cf_temp_lbl2contr.container_type,
				cf_temp_lbl2contr.description,
				cf_temp_lbl2contr.container_remarks,
				cf_temp_lbl2contr.height,
				cf_temp_lbl2contr.length,
				cf_temp_lbl2contr.width,
				cf_temp_lbl2contr.number_positions
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
				cf_temp_lbl2contr.barcode=container.barcode
		)
	
	
	UPDATE table1 t1
   SET (name, desc) = (SELECT t2.name, t2.desc
                         FROM table2 t2
                        WHERE t1.id = t2.id)
 WHERE EXISTS (
    SELECT 1
      FROM table2 t2
     WHERE t1.id = t2.id )
	all done
</cfif>
<!------------------------------------------>
<cfif action IS "nothing">
	<p>
		This form will function with a few thousand labels. If you need to do more, break them into batches or get a DBA to help.
	</p>
To use this form, all of the following must be true:

<ul>
	<li>You want to make labels into containers</li>
	<li>All the containers have barcodes</li>
	<li>The barcodes are
		<ul>
			<li>base-10 Integers</li>
			<li>base-10 Integers with a prefix</li>
		</ul>
	</li>
</ul>

<a href="labels2containers.cfm?action=uploadCSV">upload a CSV file instead</a>


<cfoutput>
	<cfquery name="ctContainerType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select distinct(container_type) container_type from ctcontainer_type
		where container_type <> 'collection object'
	</cfquery>
	<form name="wtf" method="post" action="labels2containers.cfm">
		<input type="hidden" name="action" value="change">
		<label for="origContType">Original Container Type</label>
		<select name="origContType" id="origContType" size="1" class="reqdClr">
			<cfloop query="ctContainerType">
				<option value="#container_type#">#container_type#</option>
			</cfloop>
		</select>
		<label for="newContType">New Container Type</label>
		<select name="newContType" id="newContType" size="1" class="reqdClr">
			<cfloop query="ctContainerType">
				<option value="#container_type#">#container_type#</option>
			</cfloop>
		</select>
		<label for="barcode_prefix">Barcode Prefix (include spaces, leading zeros if necessary)</label>
		<input type="text" name="barcode_prefix" id="barcode_prefix" size="3">
		<!---
		<label for="barcode_suffix">Barcode Suffix</label>
		<input type="text" name="barcode_suffix" id="barcode_suffix" size="3">
		--->
		<label for="begin_barcode">Low barcode (integer component)</label>
		<input type="text" name="begin_barcode" id="begin_barcode" class="reqdClr">
		<label for="end_barcode">High barcode (integer component)</label>
		<input type="text" name="end_barcode" id="end_barcode" class="reqdClr">
		<label for="description">New Description</label>
		<input type="text" name="description" id="description">
		<label for="container_remarks">New Remark</label>
		<input type="text" name="container_remarks" id="container_remarks">
		<label for="height">New Height</label>
		<input type="text" name="height" id="height">
		<label for="length">New Length</label>
		<input type="text" name="length" id="length">
		<label for="width">New Width</label>
		<input type="text" name="width" id="width">
		<label for="number_positions">New Number of Positions</label>
		<input type="text" name="number_positions" id="number_positions">
		<br><input type="button" value="Test Changes (recommended)" class="lnkBtn" onclick="wtf.action.value='test';submit();">
		<br><input type="button" value="Make Changes (scary)" class="savBtn" onclick="wtf.action.value='change';submit();">
	</form>
</cfoutput>
</cfif>
<!--------------------------------------->
<cfif action is "test">
	<cfoutput>
		This form will execute the select portion of the update statement.
		<br>If this page contains the word FAIL, you probably aren't doing what you think you're doing.
		<br>Use your back button, then click Make Changes to finish.
		<hr>
		<cfloop from="#begin_barcode#" to="#end_barcode#" index="i">
			<cfset bc = barcode_prefix & i>
			<cfquery name="bctest" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select barcode from container
				where
					container_type='#origContType#' and
					barcode = '#bc#'
			</cfquery>
			#bc#: <cfif bctest.recordcount is 1>spiffy<cfelse>FAIL</cfif><br>
		</cfloop>
	</cfoutput>
</cfif>

<cfif #action# IS "change">
<cfoutput>
<cfif #origContType# is "collection object">
	You can't use this with #origContType#!
	<cfabort>
</cfif>
	<cftransaction>
		<cfloop from="#begin_barcode#" to="#end_barcode#" index="i">
			<cfset bc = barcode_prefix & i>
			<cfquery name="upContainer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update container set 
					container_type='#newContType#'
					<cfif len(#DESCRIPTION#) gt 0>
						,DESCRIPTION='#DESCRIPTION#'
					</cfif>
					<cfif len(#CONTAINER_REMARKS#) gt 0>
						,CONTAINER_REMARKS='#CONTAINER_REMARKS#'
					</cfif>
					<cfif len(#WIDTH#) gt 0>
						,WIDTH=#WIDTH#
					</cfif>
					<cfif len(#HEIGHT#) gt 0>
						,HEIGHT=#HEIGHT#
					</cfif>
					<cfif len(#LENGTH#) gt 0>
						,LENGTH=#LENGTH#
					</cfif>
					<cfif len(#NUMBER_POSITIONS#) gt 0>
						,NUMBER_POSITIONS=#NUMBER_POSITIONS#
					</cfif>
				where
					container_type='#origContType#' and
					barcode = '#bc#'
			</cfquery>
		</cfloop>
	</cftransaction>
</cfoutput>
	Done. Check containers to make sure you did what you thought you were doing.
</cfif>
<cfinclude template="/includes/_footer.cfm">