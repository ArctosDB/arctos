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


<cfquery name="d" datasource="uam_god">
	select * from dlm.my_temp_cf
</cfquery>

<cfdump var=#d#>
<cfloop query="d">
	<cfset x=getQueryRow(qry=d,row=currentRow)>
	<cfdump var=#x#>
</cfloop>

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