<cfquery name="d" datasource="uam_god">
	select * from dlm.my_temp_cf
</cfquery>

<cfdump var=#d#>

<!----
<cfloop query="d">
	<cfset data=serializeJSON(
</cfloop>


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