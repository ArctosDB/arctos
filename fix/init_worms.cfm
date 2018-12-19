<!----

see if we can make full records from worms download

---->

<cfquery name="d" datasource="uam_god">
	select * from temp_worms where where rownum<2
</cfquery>
<cfdump var=#d#>

