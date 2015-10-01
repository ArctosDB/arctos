<cffunction name="getQueryRow" returntype="query" output="no">
    <cfargument name="qry" type="query" required="yes">
    <cfargument name="row" type="numeric" required="yes">
    <cfset arguments.qryRow=QueryNew(arguments.qry.columnlist)>
    <cfset QueryAddRow(arguments.qryRow)>
    <cfloop list="#arguments.qry.columnlist#" index="arguments.column">
        <cfset QuerySetCell(arguments.qryRow,arguments.column,Evaluate("arguments.qry.#arguments.column#[arguments.row]"))>
    </cfloop>
    <cfreturn arguments.qryRow>
</cffunction>
<cffunction name="QueryToArray" access="public" returntype="array" output="false"
    hint="This turns a query into an array of structures.">

    <!--- Define arguments. --->
    <cfargument name="Data" type="query" required="yes" />

    <cfscript>
        // Define the local scope.
        var LOCAL = StructNew();
        // Get the column names as an array.
        LOCAL.Columns = ListToArray( ARGUMENTS.Data.ColumnList );
        // Create an array that will hold the query equivalent.
        LOCAL.QueryArray = ArrayNew( 1 );
        // Loop over the query.
        for (LOCAL.RowIndex = 1 ; LOCAL.RowIndex LTE ARGUMENTS.Data.RecordCount ; LOCAL.RowIndex = (LOCAL.RowIndex + 1)){
            // Create a row structure.
            LOCAL.Row = StructNew();
            // Loop over the columns in this row.
            for (LOCAL.ColumnIndex = 1 ; LOCAL.ColumnIndex LTE ArrayLen( LOCAL.Columns ) ; LOCAL.ColumnIndex = (LOCAL.ColumnIndex + 1)){
                // Get a reference to the query column.
                LOCAL.ColumnName = LOCAL.Columns[ LOCAL.ColumnIndex ];
                // Store the query cell value into the struct by key.
                LOCAL.Row[ LOCAL.ColumnName ] = ARGUMENTS.Data[ LOCAL.ColumnName ][ LOCAL.RowIndex ];
            }
            // Add the structure to the query array.
            ArrayAppend( LOCAL.QueryArray, LOCAL.Row );
        }
        // Return the array equivalent.
        return( LOCAL.QueryArray );
    </cfscript>
</cffunction>

<cfquery name="d" datasource="uam_god">
	select * from dlm.my_temp_cf
</cfquery>
<cfoutput>
<cfdump var=#d#>
<cfloop query="d">
	<cfset x=getQueryRow(qry=d,row=currentRow)>
	<cfdump var=#x#>
	<cfset j=serializeJSON(x,false)>
	<cfdump var=#j#>
	<cfset a=QueryToArray(Data=x)>
	<cfdump var=#a#>
</cfloop>
</cfoutput>
<!----


<cfset data='[
  {
    "bottomsubstrate":"rocks, sand",
    "mintemp":"20C",
    "maxtemp":"28C",
    "pH":"7.0"
  },
  {
    "bottomsubstrate":"this=\"that\"",
    "mintemp":"bla",
    "maxtemp":"boogity",
    "pH":"stuff"
  }
]'>
<cfset sdata=DeserializeJSON(data)>
<cfdump var=#sdata#>
---->