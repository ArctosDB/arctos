<cfcomponent>

<cffunction
name="QueryToCSV2"
access="public"
returntype="string"
output="false"
hint="I take a query and convert it to a comma separated value string.">
 
<!--- Define arguments. --->
<cfargument
name="Query"
type="query"
required="true"
hint="I am the query being converted to CSV."
/>
 
<cfargument
name="Fields"
type="string"
required="true"
hint="I am the list of query fields to be used when creating the CSV value."
/>
 
<cfargument
name="CreateHeaderRow"
type="boolean"
required="false"
default="true"
hint="I flag whether or not to create a row of header values."
/>
 
<cfargument
name="Delimiter"
type="string"
required="false"
default=","
hint="I am the field delimiter in the CSV value."
/>
 
<!--- Define the local scope. --->
<cfset var LOCAL = {} />
 
<!---
First, we want to set up a column index so that we can
iterate over the column names faster than if we used a
standard list loop on the passed-in list.
--->
<cfset LOCAL.ColumnNames = [] />
 
<!---
Loop over column names and index them numerically. We
are going to be treating this struct almost as if it
were an array. The reason we are doing this is that
look-up times on a table are a bit faster than look
up times on an array (or so I have been told).
--->
<cfloop
index="LOCAL.ColumnName"
list="#ARGUMENTS.Fields#"
delimiters=",">
 
<!--- Store the current column name. --->
<cfset ArrayAppend(
LOCAL.ColumnNames,
Trim( LOCAL.ColumnName )
) />
 
</cfloop>
 
<!--- Store the column count. --->
<cfset LOCAL.ColumnCount = ArrayLen( LOCAL.ColumnNames ) />
 
 
<!--- Create a short hand for the new line characters. --->
<cfset LOCAL.NewLine = (Chr( 13 ) & Chr( 10 )) />
 
<!--- Create an array to hold the set of row data. --->
<cfset LOCAL.Rows = [] />
 
 
<!--- Check to see if we need to add a header row. --->
<cfif ARGUMENTS.CreateHeaderRow>
 
<!--- Create array to hold row data. --->
<cfset LOCAL.RowData = [] />
 
<!--- Loop over the column names. --->
<cfloop
index="LOCAL.ColumnIndex"
from="1"
to="#LOCAL.ColumnCount#"
step="1">
 
<!--- Add the field name to the row data. --->
<cfset LOCAL.RowData[ LOCAL.ColumnIndex ] = """#LOCAL.ColumnNames[ LOCAL.ColumnIndex ]#""" />
 
</cfloop>
 
<!--- Append the row data to the string buffer. --->
<cfset ArrayAppend(
LOCAL.Rows,
ArrayToList( LOCAL.RowData, ARGUMENTS.Delimiter )
) />
 
</cfif>
 
 
<!---
Now that we have dealt with any header value, let's
convert the query body to CSV. When doing this, we are
going to qualify each field value. This is done be
default since it will be much faster than actually
checking to see if a field needs to be qualified.
--->
 
<!--- Loop over the query. --->
<cfloop query="ARGUMENTS.Query">
 
<!--- Create array to hold row data. --->
<cfset LOCAL.RowData = [] />
 
<!--- Loop over the columns. --->
<cfloop
index="LOCAL.ColumnIndex"
from="1"
to="#LOCAL.ColumnCount#"
step="1">
 
<!--- Add the field to the row data. --->
<cfset LOCAL.RowData[ LOCAL.ColumnIndex ] = """#Replace( ARGUMENTS.Query[ LOCAL.ColumnNames[ LOCAL.ColumnIndex ] ][ ARGUMENTS.Query.CurrentRow ], """", """""", "all" )#""" />
 
</cfloop>
 
 
<!--- Append the row data to the string buffer. --->
<cfset ArrayAppend(
LOCAL.Rows,
ArrayToList( LOCAL.RowData, ARGUMENTS.Delimiter )
) />
 
</cfloop>
 
 
<!---
Return the CSV value by joining all the rows together
into one string.
--->
<cfreturn ArrayToList(
LOCAL.Rows,
LOCAL.NewLine
) />
</cffunction>


</cfcomponent>