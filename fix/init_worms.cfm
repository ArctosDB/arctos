<!----

see if we can make full records from worms download


first pass: do something with the stuff we just made
---->

<cfquery name="d" datasource="uam_god">
	select * from temp_worms where status='valid' and rownum<2
</cfquery>
<cfdump var=#d#>

