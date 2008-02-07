<!--- no security --->
<cfset i=1>
<cfoutput>
<cfset TblCtblFld = querynew("
	table_name,
	code_table_name,
	field_name")>
<!------------------
- a ----------------------->
<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "accn", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctaccn_type", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "accn_type", #i#)>
<cfset i=#i#+1>
<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "accn", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctaccn_status", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "accn_status", #i#)>
<cfset i=#i#+1>


<!------------------ c--------------------->
<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "citation", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctcitation_type_status", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "type_status", #i#)>
<cfset i=#i#+1>
<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "coll_object", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctcoll_obj_disp", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "coll_obj_disposition", #i#)>
<cfset i=#i#+1>
<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "coll_obj_other_id_num", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctcoll_other_id_type", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "other_id_type", #i#)>
<cfset i=#i#+1>
<!-----------------d ---------------------------->
<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "lat_long", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctdatum", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "datum", #i#)>
<cfset i=#i#+1>
<!------------------ f --------------------------->
<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "geog_auth_rec", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctfeature", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "feature", #i#)>
<cfset i=#i#+1>

<!------------------ g --------------------------->
<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "geog_auth_rec", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctisland_group", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "island_group", #i#)>
<cfset i=#i#+1>

<!----------------- I ------------------------------------->
<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "identification", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctnature_of_id", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "nature_of_id", #i#)>
<cfset i=#i#+1>

<!----------------- L ------------------------------------->
<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "lat_long", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctlat_long_ref_source", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "lat_long_ref_source", #i#)>
<cfset i=#i#+1>

<!---------------------- S --------------------------------->
<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "specimen_part", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctspecimen_part_name", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "part_name", #i#)>
<cfset i=#i#+1>
<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "specimen_part", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctspecimen_part_modifier", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "part_modifier", #i#)>

<!---------------------- attributes --------------------->

</cfoutput>
<!----
<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "biol_indiv_remark", 6)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctage_det_method", 6)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "age_det_method", 6)>
---->

<cfoutput>
	<cfloop query="TblCtblFld">
	<!---- first, things in the data that aren't in the code table --->
		<cfquery name="a" datasource="#Application.uam_dbo#">
			select distinct(':'||#field_name#||':')  as thisFld from #table_name# where #field_name# not in (
				select #field_name# from #code_table_name#)
		</cfquery>
		<hr>
		Query:
			<blockquote>
			select distinct(#field_name#)  as thisFld from #table_name# where #field_name# not in (
				select #field_name# from #code_table_name#)
				<!---
			SELECT 
			<br>&nbsp;&nbsp;distinct(#fld#)
			<br>FROM 
			<br>&nbsp;&nbsp;#tbl# 
			<br>WHERE 
			<br>&nbsp;&nbsp;#fld# 
			<br>NOT IN
			<br>&nbsp;&nbsp;(
			<br>&nbsp;&nbsp;&nbsp;&nbsp;SELECT 
			<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#fld# 
			<br>&nbsp;&nbsp;&nbsp;&nbsp;FROM
			<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#ctbl#
			<br>&nbsp;&nbsp;)
			--->
			</blockquote>
		<cfloop query="a">
			<br>
			<font color="##FF0000">#a.thisFld#</font> 
	 	 </cfloop>
	<!--- now, things in the code table that aren't in the data --->
		 <cfquery name="b" datasource="#Application.uam_dbo#">
			select distinct(#field_name#)  as thisFld from #code_table_name# where #field_name# not in (
				select #field_name# from #table_name#)
		</cfquery>
		<hr>
		Query:
			<blockquote>
			select distinct(#field_name#)  as thisFld from #code_table_name# where #field_name# not in (
				select #field_name# from #table_name#)
			</blockquote>
		<cfloop query="b">
			<br>
			<font color="##FF0000">#b.thisFld#</font> 
	 	 </cfloop>
	</cfloop>



</cfoutput>

<!----
<cfquery name="a" datasource="#Application.uam_dbo#">
	select distinct(part_name) from ctspecimen_part_name where part_name not in (
		select part_name from specimen_part)
</cfquery>
<cfoutput>
<hr>
The following parts are in the code table, but not specimen_part:
<cfloop query="a">
	<br>
    <font color="##FF0000">#a.part_name#</font> 
  </cfloop>
</cfoutput>

<cfquery name="a" datasource="#Application.uam_dbo#">
	select distinct(part_modifier) from specimen_part where part_modifier not in (
		select part_modifier from ctspecimen_part_modifier)
</cfquery>
<cfoutput>
<hr>The following part_modifier are used, but not in the code table:
<cfloop query="a">
	<br>
    <font color="##FF0000">#a.part_modifier#</font> 
  </cfloop>
</cfoutput>

<cfquery name="a" datasource="#Application.uam_dbo#">
	select distinct(part_modifier) from ctspecimen_part_modifier where part_modifier not in (
		select part_modifier from specimen_part)
</cfquery>
<cfoutput>
<hr>
The following part_modifier are in the code table, but not specimen_part:
<cfloop query="a">
	<br>
    <font color="##FF0000">#a.part_modifier#</font> 
  </cfloop>
</cfoutput>

--->