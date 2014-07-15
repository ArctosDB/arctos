<cfsetting requesttimeout="600">
	<cffunction name="csvToQuery">
<cfargument name="data" default="">
<cfargument name="cols" default="">
<cfargument name="delimiter" default=",">
<cfscript>
// init
csv = structNew();
loc = structNew();
rtn = structNew();
csv.newLine = chr(13) & chr(10);
csv.lineCount = 1;
rtn.message = "";
rtn.status = true;
rtn.data = "";
if ( listlen(data, csv.newLine) LTE 1 )
{
rtn.status = false;
rtn.message = "No Data";
return rtn;
}
</cfscript>
<cfloop list="#data#" index="csv.line" delimiters="#csv.newLine#">
<cfscript>
/*
if ( right( csv.line, 1 ) EQ delimiter )
csv.line = mid( csv.line, 1, len(csv.line)-1 );
*/
// get the header
if ( csv.lineCount EQ 1 )
{
csv.header = this.csvLineToArray( csv.line, delimiter );
for ( loc.i = 1; loc.i LTE arrayLen(csv.header); loc.i = loc.i + 1 )
csv.header[loc.i] = rereplacenocase( csv.header[loc.i], "[^a-z0-9]", "", "ALL" );
// make sure requires columns exist
if ( listlen(arguments.cols) NEQ 0 )
{
for ( loc.i = 1; loc.i LTE listlen(arguments.cols); loc.i = loc.i + 1 )
{
if ( NOT listFindNoCase( arrayToList(csv.header), listGetAt(arguments.cols,loc.i) ) )
{
rtn.status = false;
rtn.message = 'Required Columns Not Found. Column "#listGetAt(arguments.cols,loc.i)#" Not Found.';
rtn.data = csv.header;
return rtn;
}
}
}
// create a new query with the header
csv.query = queryNew( arrayToList(csv.header) );
}
// insert data into the query
else
{
csv.lineArr = this.csvLineToArray( csv.line, delimiter );
 
// check to make sure that the line is the same length as the header
if ( arraylen(csv.lineArr) EQ arrayLen(csv.header) )
{
queryAddRow( csv.query );
for ( loc.i = 1; loc.i LTE arrayLen(csv.header); loc.i = loc.i + 1 )
{
querySetCell( csv.query, rereplaceNoCase( csv.header[loc.i], "[^a-z0-9]", "", "ALL" ), csv.lineArr[loc.i] );
}
}
else
{
rtn.message = rtn.message & "Failed to add row #csv.lineCount#<br>";
}
//writeoutput( arrayToList( csv.lineArr ) & "<br>" );
}
// increment the counter
csv.lineCount = csv.LineCount + 1;
</cfscript>
</cfloop>
<cfscript>
rtn.data = csv.query;
return rtn;
</cfscript>
</cffunction>
<cffunction name="csvLineToArray">
<cfargument name="line" default="">
<cfargument name="delimiter" default=",">
<cfscript>
// init
csvLine = structNew();
notFound = true;
notFoundCounter = 1;
</cfscript>
 
<cfloop condition="#notFound#">
<cfif notFoundCounter GTE 21>
<cfbreak>
</cfif>
<cfset line = replace(line,'#delimiter##delimiter#','#delimiter#""#delimiter#',"ALL")>
<cfset notFoundCounter = notFoundCounter + 1>
</cfloop>
 
 
<cfscript>
if ( right(line,1) EQ #delimiter# )
line = line & '""';
 
// init
csvLine.arr = arrayNew(1);
csvLine.openQuotes = false; // says if the cell is in double quotes
for ( csvLine.i = 1; csvLine.i LTE listlen(line, delimiter); csvLine.i = csvLine.i + 1 )
{
csvLine.cell = listgetat( line, csvLine.i, delimiter );
// is wrapped in quotes
if ( left( csvLine.cell,1 ) EQ '"' AND right( csvLine.cell,1 ) EQ '"' )
{
csvLine.cell = replace( csvLine.cell, '""','"',"ALL" );
if ( trim(csvLine.cell) EQ '"' )
{
csvLine.cell = "";	
}
else if ( len(trim(csvLine.cell)) NEQ 0 )
{
csvLine.cell = right( csvLine.cell, len(csvLine.cell) - 1 );
csvLine.cell = left( csvLine.cell, len(csvLine.cell) - 1 );
}
arrayAppend( csvLine.arr, csvLine.cell );
}
// is wrapped in quotes
else if ( left( csvLine.cell,1 ) EQ '"' )
{
csvLine.openQuotes = true;
// add the cell to the array without the opening quote
arrayAppend( csvLine.arr, right( csvLine.cell, len(csvLine.cell) - 1 ) );
}
// no wrapped in quotes
else if ( NOT csvLine.openQuotes )
{
if ( len(trim(csvLine.cell)) EQ 0 )
csvLine.cell = 'n/a';
arrayAppend( csvLine.arr, csvLine.cell );
}
else
{
if ( right( csvLine.cell,1 ) EQ '"' )
{
// close the quoted string
csvLine.openQuotes = false;
csvLine.cell = left( csvLine.cell, len(csvLine.cell) - 1 );
}
// build up the correct cell
csvLine.arr[ arrayLen(csvLine.arr) ] = csvLine.arr[ arrayLen(csvLine.arr) ] & ", " & csvLine.cell;
}
}
return csvLine.arr;
</cfscript>
</cffunction>
<!---
alter table cf_temp_attributes add status varchar2(255);


 CREATE OR REPLACE TRIGGER cf_temp_attributes_key
 before insert  ON cf_temp_attributes
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
<cfif #action# is "nothing">


<cfoutput>
		<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_temp_attributes where upper(username)='#ucase(session.username)#'
		</cfquery>
		<cfif mine.recordcount gt 0>
			<p>
				<a href="BulkloadAttributes.cfm?action=managemystuff">Manage your existing #mine.recordcount# records</a>
			</p>
		</cfif>
		</cfoutput>
		
		
		
		
		
		
		
Step 1: Upload a comma-delimited text file (csv).
Include column headings, spelled exactly as below.
<br><span class="likeLink" onclick="document.getElementById('template').style.display='block';">view template</span>
	<div id="template" style="display:none;">
		<label for="t">Copy the existing code and save as a .csv file</label>
		<textarea rows="2" cols="80" id="t">OTHER_ID_TYPE,OTHER_ID_NUMBER,ATTRIBUTE,ATTRIBUTE_VALUE,ATTRIBUTE_UNITS,ATTRIBUTE_DATE,ATTRIBUTE_METH,DETERMINER,REMARKS,guid_prefix</textarea>
	</div>
<p></p>




Columns in <span style="color:red">red</span> are required; others are optional:
<ul>
	<li style="color:red">guid_prefix</li>
	<li style="color:red">OTHER_ID_TYPE ("catalog number" is OK)</li>
	<li style="color:red">OTHER_ID_NUMBER</li>
	<li style="color:red">ATTRIBUTE</li>
	<li style="color:red">ATTRIBUTE_VALUE</li>
	<li>ATTRIBUTE_UNITS</li>
	<li>ATTRIBUTE_DATE</li>
	<li>ATTRIBUTE_METH</li>
	<li style="color:red">DETERMINER</li>
	<li>REMARKS</li>
</ul>

<cfform name="atts" method="post" enctype="multipart/form-data">
	<input type="hidden" name="Action" value="getFile">
	<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
	<input type="submit" value="Upload this file" class="savBtn">
  </cfform>
</cfif>
<!------------------------------------------------------->
<cfif action is "getFile">
<cfoutput>
	
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	
	
	
	

	
	
	<cfset theQuery=CSVtoQuery(fileContent)>
	
	
	<cfdump var=#theQuery#>
		<cfabort>
	
	
	<cfset fileContent=replace(fileContent,"'","''","all")>
	<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />
	
	
	
	<cfdump var=#arrResult#>
	<!--- first array element is column names ---->
	<cfset colNames=ArrayToList(arrResult[1])>

	<!--- don't accept internal junk ---->
	<cfset sIDX=listfindnocase(colNames,'status')>
	<cfset cidIDX=listfindnocase(colNames,'COLLECTION_OBJECT_ID')>			
	<cfset didIDX=listfindnocase(colNames,'DETERMINED_BY_AGENT_ID')>
	<cfset kIDX=listfindnocase(colNames,'KEY')>
	<cfset uIDX=listfindnocase(colNames,'USERNAME')>
			
	<cfif sIDX gt 0>
		<cfset colNames=listdeleteat(colNames,sIDX)>
	</cfif>
	<cfif cidIDX gt 0>
		<cfset colNames=listdeleteat(colNames,cidIDX)>
	</cfif>
	<cfif didIDX gt 0>
		<cfset colNames=listdeleteat(colNames,didIDX)>
	</cfif>
	<cfif kIDX gt 0>
		<cfset colNames=listdeleteat(colNames,kIDX)>
	</cfif>
	<cfif uIDX gt 0>
		<cfset colNames=listdeleteat(colNames,uIDX)>
	</cfif>
	




			<cfdump var=#sIDX#>

	<cfloop from="1" to ="#ArrayLen(arrResult)#" index="o">
	
	
	
	<!----
	
	





		<cfset colVals="">
			<cfloop from="1"  to ="#ArrayLen(arrResult[o])#" index="i">
				<cfset thisBit=arrResult[o][i]>
				<cfif o is 1>
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
				insert into cf_temp_attributes (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
		
		
		---->
	</cfloop>
	
	<!-----
	<cflocation url="BulkloadAttributes.cfm?action=manageMyStuff" addtoken="false">
	--->
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
	<cfquery name="collObj_fail" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">				
		update 
			cf_temp_attributes 
		set 
			status=null where 
			upper(username)='#ucase(session.username)#'
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
		) where other_id_type = 'catalog number' and upper(username)='#ucase(session.username)#'
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
				display_value = cf_temp_attributes.other_id_number and
				cat_num=cf_temp_attributes.other_id_number
		) where other_id_type != 'catalog number' and upper(username)='#ucase(session.username)#'
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
				isValidAttribute(ATTRIBUTE,ATTRIBUTE_VALUE,ATTRIBUTE_UNITS,(select collection_cde from collection where collection.guid_prefix=cf_temp_attributes.guid_prefix))=0 and
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
		update cf_temp_attributes set DETERMINED_BY_AGENT_ID=getAgentID(determiner)  where upper(username)='#ucase(session.username)#'
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
	
	<cflocation url="BulkloadAttributes.cfm?action=manageMyStuff" addtoken="false">

</cfoutput>

</cfif>
<!------------------------------------------------------->
<cfif #action# is "manageMyStuff">

<cfoutput>


	<cfquery name="datadump" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_attributes where upper(username)='#ucase(session.username)#'
	</cfquery>
		<cfquery name="pf" dbtype="query">
		select count(*) l from datadump where status is not null
	</cfquery>
	
	<p>
		<a href="BulkloadAttributes.cfm">load more records</a>
	</p>
	<cfif pf.recordcount gt 0>
		Oops - something's hinky. Review the table below and try again.
		
	<p>
		<a href="BulkloadAttributes.cfm?action=validate">validate</a>
	</p>
	<cfelse>
		Your data should load. Review the table below and <a href="BulkloadAttributes.cfm?action=loadData">click to continue</a>.
	</cfif>
	<script>
		function cd(){
			yesDelete = window.confirm('Are you sure you want to delete all of your data in the attributes bulkloader?');
			if (yesDelete == true) {
				document.location='BulkloadAttributes.cfm?action=deletemine';
			}
		}
	</script>
	<p>
		<a href="##" onclick="cd();">delete all of your data</a>
	</p>
	<p>
		<a href="BulkloadAttributes.cfm?action=getCSV">get CSV</a>
	</p>
	
	
	<table border>
		<tr>
			<th>KEY</th>
			<th>STATUS</th>
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
				<td>#KEY#</td>
				<td>#STATUS#</td>
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
</cfoutput>
</cfif>



<!------------------------------------------------------->
<cfif action is "deletemine">
	<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from cf_temp_attributes where upper(username)='#ucase(session.username)#'
	</cfquery>
	<cflocation url="BulkloadAttributes.cfm" addtoken="false">
</cfif>
<!------------------------------------------------------->
<cfif #action# is "loadData">

<cfoutput>


	<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_attributes
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
	</cftransaction>

	Spiffy, all done.
</cfoutput>
</cfif>

<cfinclude template="/includes/_footer.cfm">
