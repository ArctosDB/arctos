<cfsetting requesttimeout="600">

<cffunction name="CSVtoQuery2" access="remote" output="No">
  <cfargument name="file" required="yes" type="string">
  <cfargument name="columnlist" required="No" type="string" default="" hint="[Empty] Take the first row as the column header, [Auto] create new column names [Column list]">
  <cfargument name="fixColumn" required="No" type="boolean" default="Yes" hint="If columnlist taken from the first row of the file, validate names & fix it">
 
  <cfset local.fileReader = createobject("java","java.io.FileReader").init("#arguments.file#")>
  <cfset local.csvReader = createObject("java","au.com.bytecode.opencsv.CSVReader").init(fileReader, ',', '"', chr(1), false)>
  <cfset local.array = csvReader.readAll()>
 
  <!--- handle the column name --->
  <cfswitch expression="#arguments.columnlist#">
  <cfcase value="">
  <cfset local.clm = local.array[1]>
  <cfset local.start = 2>
  </cfcase>
  <cfcase value="auto">
  <cfset local.clm = ArrayNew(1)>
  <cfloop from="1" to="#ArrayLen(local.array[1])#" index="i">
  <cfset ArrayAppend(local.clm,'col_#i#')>
  </cfloop>
  <cfset local.start = 1>
  </cfcase>
  <cfdefaultcase>
  <cfset local.clm = ListToArray(arguments.columnlist)>
  <cfset local.start = 1>
  </cfdefaultcase>
  </cfswitch>
  <cfset local.clms = ArrayLen(local.clm)>
 
  <cfif YesNoFormat(arguments.fixColumn)>
  <!--- validate/fix column names --->
  <cfloop from="1" to="#local.clms#" index="i">
 <cfset local.clm[i] = rereplacenocase(trim(local.clm[i]),' |##|"|""|',"",'all')>
  <cfif not refindnocase('^[a-zA-Z_][a-zA-Z0-9_]*$',local.clm[i])>
  <cfset local.clm[i] = 'col_#i#'>
  </cfif>
  </cfloop>
  </cfif>
  <cfset local.q = QueryNew( ArrayToList( local.clm ) )>
 <!--- convert array to query --->
  <cfloop from="#local.start#" to="#ArrayLen(local.array)#" index="i">
  <cfset QueryAddRow(local.q)>
  <cfloop from="1" to="#local.clms#" index="c">
 <cfif ArrayIsDefined(local.array[i],c)>
  <cfset QuerySetCell(local.q,local.clm[c],ToString(local.array[i][c]))>
 </cfif>
  </cfloop>
  </cfloop>
 
  <cfreturn local.q>
 </cffunction>

<cffunction
name="CSVToQuery"
access="public"
returntype="query"
output="false"
hint="Converts the given CSV string to a query.">
 
<!--- Define arguments. --->
<cfargument
name="CSV"
type="string"
required="true"
hint="This is the CSV string that will be manipulated."
/>
 
<cfargument
name="Delimiter"
type="string"
required="false"
default=","
hint="This is the delimiter that will separate the fields within the CSV value."
/>
 
<cfargument
name="Qualifier"
type="string"
required="false"
default=""""
hint="This is the qualifier that will wrap around fields that have special characters embeded."
/>
 
 
<!--- Define the local scope. --->
<cfset var LOCAL = StructNew() />
 
 
<!---
When accepting delimiters, we only want to use the first
character that we were passed. This is different than
standard ColdFusion, but I am trying to make this as
easy as possible.
--->
<cfset ARGUMENTS.Delimiter = Left( ARGUMENTS.Delimiter, 1 ) />
 
<!---
When accepting the qualifier, we only want to accept the
first character returned. Is is possible that there is
no qualifier being used. In that case, we can just store
the empty string (leave as-is).
--->
<cfif Len( ARGUMENTS.Qualifier )>
 
<cfset ARGUMENTS.Qualifier = Left( ARGUMENTS.Qualifier, 1 ) />
 
</cfif>
 
 
<!---
Set a variable to handle the new line. This will be the
character that acts as the record delimiter.
--->
<cfset LOCAL.LineDelimiter = Chr( 10 ) />
 
 
<!---
We want to standardize the line breaks in our CSV value.
A "line break" might be a return followed by a feed or
just a line feed. We want to standardize it so that it
is just a line feed. That way, it is easy to check
for later (and it is a single character which makes our
life 1000 times nicer).
--->
<cfset ARGUMENTS.CSV = ARGUMENTS.CSV.ReplaceAll(
"\r?\n",
LOCAL.LineDelimiter
) />
 
 
<!---
Let's get an array of delimiters. We will need this when
we are going throuth the tokens and building up field
values. To do this, we are going to strip out all
characters that are NOT delimiters and then get the
character array of the string. This should put each
delimiter at it's own index.
--->
<cfset LOCAL.Delimiters = ARGUMENTS.CSV.ReplaceAll(
"[^\#ARGUMENTS.Delimiter#\#LOCAL.LineDelimiter#]+",
""
)
 
<!---
Get character array of delimiters. This will put
each found delimiter in its own index (that should
correspond to the tokens).
--->
.ToCharArray()
/>
 
 
<!---
Add a blank space to the beginning of every theoretical
field. This will help in make sure that ColdFusion /
Java does not skip over any fields simply because they
do not have a value. We just have to be sure to strip
out this space later on.
 
First, add a space to the beginning of the string.
--->
<cfset ARGUMENTS.CSV = (" " & ARGUMENTS.CSV) />
 
<!--- Now add the space to each field. --->
<cfset ARGUMENTS.CSV = ARGUMENTS.CSV.ReplaceAll(
"([\#ARGUMENTS.Delimiter#\#LOCAL.LineDelimiter#]{1})",
"$1 "
) />
 
 
<!---
Break the CSV value up into raw tokens. Going forward,
some of these tokens may be merged, but doing it this
way will help us iterate over them. When splitting the
string, add a space to each token first to ensure that
the split works properly.
 
BE CAREFUL! Splitting a string into an array using the
Java String::Split method does not create a COLDFUSION
ARRAY. You cannot alter this array once it has been
created. It can merely be referenced (read only).
 
We are splitting the CSV value based on the BOTH the
field delimiter and the line delimiter. We will handle
this later as we build values (this is why we created
the array of delimiters above).
--->
<cfset LOCAL.Tokens = ARGUMENTS.CSV.Split(
"[\#ARGUMENTS.Delimiter#\#LOCAL.LineDelimiter#]{1}"
) />
 
 
<!---
Set up the default records array. This will be a full
array of arrays, but for now, just create the parent
array with no indexes.
--->
<cfset LOCAL.Rows = ArrayNew( 1 ) />
 
<!---
Create a new active row. Even if we don't end up adding
any values to this row, it is going to make our lives
more smiple to have it in existence.
--->
<cfset ArrayAppend(
LOCAL.Rows,
ArrayNew( 1 )
) />
 
<!---
Set up the row index. THis is the row to which we are
actively adding value.
--->
<cfset LOCAL.RowIndex = 1 />
 
 
<!---
Set the default flag for wether or not we are in the
middle of building a value across raw tokens.
--->
<cfset LOCAL.IsInValue = false />
 
 
<!---
Loop over the raw tokens to start building values. We
have no sense of any row delimiters yet. Those will
have to be checked for as we are building up each value.
--->
<cfloop
index="LOCAL.TokenIndex"
from="1"
to="#ArrayLen( LOCAL.Tokens )#"
step="1">
 
 
<!---
Get the current field index. This is the current
index of the array to which we might be appending
values (for a multi-token value).
--->
<cfset LOCAL.FieldIndex = ArrayLen(
LOCAL.Rows[ LOCAL.RowIndex ]
) />
 
<!---
Get the next token. Trim off the first character
which is the empty string that we added to ensure
proper splitting.
--->
<cfset LOCAL.Token = LOCAL.Tokens[ LOCAL.TokenIndex ].ReplaceFirst(
"^.{1}",
""
) />
 
 
<!---
Check to see if we have a field qualifier. If we do,
then we might have to build the value across
multiple fields. If we do not, then the raw tokens
should line up perfectly with the real tokens.
--->
<cfif Len( ARGUMENTS.Qualifier )>
 
 
<!---
Check to see if we are currently building a
field value that has been split up among
different delimiters.
--->
<cfif LOCAL.IsInValue>
 
 
<!---
ASSERT: Since we are in the middle of
building up a value across tokens, we can
assume that our parent FOR loop has already
executed at least once. Therefore, we can
assume that we have a previous token value
ALREADY in the row value array and that we
have access to a previous delimiter (in
our delimiter array).
--->
 
<!---
Since we are in the middle of building a
value, we replace out double qualifiers with
a constant. We don't care about the first
qualifier as it can ONLY be an escaped
qualifier (not a field qualifier).
--->
<cfset LOCAL.Token = LOCAL.Token.ReplaceAll(
"\#ARGUMENTS.Qualifier#{2}",
"{QUALIFIER}"
) />
 
 
<!---
Add the token to the value we are building.
While this is not easy to read, add it
directly to the results array as this will
allow us to forget about it later. Be sure
to add the PREVIOUS delimiter since it is
actually an embedded delimiter character
(part of the whole field value).
--->
<cfset LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ] = (
LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ] &
LOCAL.Delimiters[ LOCAL.TokenIndex - 1 ] &
LOCAL.Token
) />
 
 
<!---
Now that we have removed the possibly
escaped qualifiers, let's check to see if
this field is ending a multi-token
qualified value (its last character is a
field qualifier).
--->
<cfif (Right( LOCAL.Token, 1 ) EQ ARGUMENTS.Qualifier)>
 
<!---
Wooohoo! We have reached the end of a
qualified value. We can complete this
value and move onto the next field.
Remove the trailing quote.
 
Remember, we have already added to token
to the results array so we must now
manipulate the results array directly.
Any changes made to LOCAL.Token at this
point will not affect the results.
--->
<cfset LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ] = LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ].ReplaceFirst( ".{1}$", "" ) />
 
<!---
Set the flag to indicate that we are no
longer building a field value across
tokens.
--->
<cfset LOCAL.IsInValue = false />
 
</cfif>
 
 
<cfelse>
 
 
<!---
We are NOT in the middle of building a field
value which means that we have to be careful
of a few special token cases:
 
1. The field is qualified on both ends.
2. The field is qualified on the start end.
--->
 
<!---
Check to see if the beginning of the field
is qualified. If that is the case then either
this field is starting a multi-token value OR
this field has a completely qualified value.
--->
<cfif (Left( LOCAL.Token, 1 ) EQ ARGUMENTS.Qualifier)>
 
 
<!---
Delete the first character of the token.
This is the field qualifier and we do
NOT want to include it in the final value.
--->
<cfset LOCAL.Token = LOCAL.Token.ReplaceFirst(
"^.{1}",
""
) />
 
<!---
Remove all double qualifiers so that we
can test to see if the field has a
closing qualifier.
--->
<cfset LOCAL.Token = LOCAL.Token.ReplaceAll(
"\#ARGUMENTS.Qualifier#{2}",
"{QUALIFIER}"
) />
 
<!---
Check to see if this field is a
self-closer. If the first character is a
qualifier (already established) and the
last character is also a qualifier (what
we are about to test for), then this
token is a fully qualified value.
--->
<cfif (Right( LOCAL.Token, 1 ) EQ ARGUMENTS.Qualifier)>
 
<!---
This token is fully qualified.
Remove the end field qualifier and
append it to the row data.
--->
<cfset ArrayAppend(
LOCAL.Rows[ LOCAL.RowIndex ],
LOCAL.Token.ReplaceFirst(
".{1}$",
""
)
) />
 
<cfelse>
 
<!---
This token is not fully qualified
(but the first character was a
qualifier). We are buildling a value
up across differen tokens. Set the
flag for building the value.
--->
<cfset LOCAL.IsInValue = true />
 
<!--- Add this token to the row. --->
<cfset ArrayAppend(
LOCAL.Rows[ LOCAL.RowIndex ],
LOCAL.Token
) />
 
</cfif>
 
 
<cfelse>
 
 
<!---
We are not dealing with a qualified
field (even though we are using field
qualifiers). Just add this token value
as the next value in the row.
--->
<cfset ArrayAppend(
LOCAL.Rows[ LOCAL.RowIndex ],
LOCAL.Token
) />
 
 
</cfif>
 
 
</cfif>
 
 
<!---
As a sort of catch-all, let's remove that
{QUALIFIER} constant that we may have thrown
into a field value. Do NOT use the FieldIndex
value as this might be a corrupt value at
this point in the token iteration.
--->
<cfset LOCAL.Rows[ LOCAL.RowIndex ][ ArrayLen( LOCAL.Rows[ LOCAL.RowIndex ] ) ] = Replace(
LOCAL.Rows[ LOCAL.RowIndex ][ ArrayLen( LOCAL.Rows[ LOCAL.RowIndex ] ) ],
"{QUALIFIER}",
ARGUMENTS.Qualifier,
"ALL"
) />
 
 
<cfelse>
 
 
<!---
Since we don't have a qualifier, just use the
current raw token as the actual value. We are
NOT going to have to worry about building values
across tokens.
--->
<cfset ArrayAppend(
LOCAL.Rows[ LOCAL.RowIndex ],
LOCAL.Token
) />
 
 
</cfif>
 
 
 
<!---
Check to see if we have a next delimiter and if we
do, is it going to start a new row? Be cautious that
we are NOT in the middle of building a value. If we
are building a value then the line delimiter is an
embedded value and should not percipitate a new row.
--->
<cfif (
(NOT LOCAL.IsInValue) AND
(LOCAL.TokenIndex LT ArrayLen( LOCAL.Tokens )) AND
(LOCAL.Delimiters[ LOCAL.TokenIndex ] EQ LOCAL.LineDelimiter)
)>
 
<!---
The next token is indicating that we are about
start a new row. Add a new array to the parent
and increment the row counter.
--->
<cfset ArrayAppend(
LOCAL.Rows,
ArrayNew( 1 )
) />
 
<!--- Increment row index to point to next row. --->
<cfset LOCAL.RowIndex = (LOCAL.RowIndex + 1) />
 
</cfif>
 
</cfloop>
 
 
<!---
ASSERT: At this point, we have parsed the CSV into an
array of arrays (LOCAL.Rows). Now, we can take that
array of arrays and convert it into a query.
--->
 
 
<!---
To create a query that fits this array of arrays, we
need to figure out the max length for each row as
well as the number of records.
 
The number of records is easy - it's the length of the
array. The max field count per row is not that easy. We
will have to iterate over each row to find the max.
 
However, this works to our advantage as we can use that
array iteration as an opportunity to build up a single
array of empty string that we will use to pre-populate
the query.
--->
 
<!--- Set the initial max field count. --->
<cfset LOCAL.MaxFieldCount = 0 />
 
<!---
Set up the array of empty values. As we iterate over
the rows, we are going to add an empty value to this
for each record (not field) that we find.
--->
<cfset LOCAL.EmptyArray = ArrayNew( 1 ) />
 
 
<!--- Loop over the records array. --->
<cfloop
index="LOCAL.RowIndex"
from="1"
to="#ArrayLen( LOCAL.Rows )#"
step="1">
 
<!--- Get the max rows encountered so far. --->
<cfset LOCAL.MaxFieldCount = Max(
LOCAL.MaxFieldCount,
ArrayLen(
LOCAL.Rows[ LOCAL.RowIndex ]
)
) />
 
<!--- Add an empty value to the empty array. --->
<cfset ArrayAppend(
LOCAL.EmptyArray,
""
) />
 
</cfloop>
 
 
<!---
ASSERT: At this point, LOCAL.MaxFieldCount should hold
the number of fields in the widest row. Additionally,
the LOCAL.EmptyArray should have the same number of
indexes as the row array - each index containing an
empty string.
--->
 
 
<!---
Now, let's pre-populate the query with empty strings. We
are going to create the query as all VARCHAR data
fields, starting off with blank. Then we will override
these values shortly.
--->
<cfset LOCAL.Query = QueryNew( "" ) />
 
<!---
Loop over the max number of fields and create a column
for each records.
--->
<cfloop
index="LOCAL.FieldIndex"
from="1"
to="#LOCAL.MaxFieldCount#"
step="1">
 
<!---
Add a new query column. By using QueryAddColumn()
rather than QueryAddRow() we are able to leverage
ColdFusion's ability to add row values in bulk
based on an array of values. Since we are going to
pre-populate the query with empty values, we can
just send in the EmptyArray we built previously.
--->
<cfset QueryAddColumn(
LOCAL.Query,
"COLUMN_#LOCAL.FieldIndex#",
"CF_SQL_VARCHAR",
LOCAL.EmptyArray
) />
 
</cfloop>
 
 
<!---
ASSERT: At this point, our return query LOCAL.Query
contains enough columns and rows to handle all the
data that we have stored in our array of arrays.
--->
 
 
<!---
Loop over the array to populate the query with
actual data. We are going to have to loop over
each row and then each field.
--->
<cfloop
index="LOCAL.RowIndex"
from="1"
to="#ArrayLen( LOCAL.Rows )#"
step="1">
 
<!--- Loop over the fields in this record. --->
<cfloop
index="LOCAL.FieldIndex"
from="1"
to="#ArrayLen( LOCAL.Rows[ LOCAL.RowIndex ] )#"
step="1">
 
<!---
Update the query cell. Remember to cast string
to make sure that the underlying Java data
works properly.
--->
<cfset LOCAL.Query[ "COLUMN_#LOCAL.FieldIndex#" ][ LOCAL.RowIndex ] = JavaCast(
"string",
LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ]
) />
 
</cfloop>
 
</cfloop>
 
 
<!---
Our query has been successfully populated.
Now, return it.
--->
<cfreturn LOCAL.Query />
 
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
	
	
	
	
	<cfset theQuery=CSVtoQuery2(fileContent)>
	
	
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
