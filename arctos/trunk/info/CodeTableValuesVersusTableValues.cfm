<cfinclude template="/includes/_header.cfm">
<cfset i=1>
<cfoutput>
<cfset TblCtblFld = querynew("
	table_name,
	code_table_name,
	field_name")>
<cfset newrows = queryaddrow(TblCtblFld, #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "specimen_part", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctspecimen_part_name", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "part_name", #i#)>
<cfset i=#i#+1>
<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "specimen_part", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctspecimen_part_modifier", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "part_modifier", #i#)>
<cfset i=#i#+1>
<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "accn", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctaccn_type", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "accn_type", #i#)>
<cfset i=#i#+1>
<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "geog_auth_rec", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctisland_group", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "island_group", #i#)>
<cfset i=#i#+1>
<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "lat_long", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctlat_long_ref_source", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "lat_long_ref_source", #i#)>
<cfset i=#i#+1>
<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "coll_obj_other_id_num", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctcoll_other_id_type", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "other_id_type", #i#)>
<cfset i=#i#+1>
<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "identification", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctnature_of_id", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "nature_of_id", #i#)>
<cfset i=#i#+1>
<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "agent_name", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctagent_name_type", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "agent_name_type", #i#)>
<cfset i=#i#+1>
<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "agent_relations", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctagent_relationship", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "agent_relationship", #i#)>
<cfset i=#i#+1>

<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "permit", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctpermit_type", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "permit_type", #i#)>
<cfset i=#i#+1>
</cfoutput>
<!----
<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "biol_indiv_remark", 6)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctage_det_method", 6)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "age_det_method", 6)>
---->
<cfoutput>
	<cfset CrapDataMessage = "">
	<cfloop query="TblCtblFld">
	<!---- first, things in the data that aren't in the code table --->
		<cfquery name="a" datasource="#Application.uam_dbo#">
			select distinct(':'||#field_name#||':')  as thisFld from #table_name# where #field_name# not in (
				select #field_name# from #code_table_name#)
		</cfquery>
		<cfset CrapDataMessage = "#CrapDataMessage#
		<hr>
		Query:
			<blockquote>
			select distinct(#field_name#)  as thisFld from #table_name# where #field_name# not in (
				select #field_name# from #code_table_name#)</blockquote>">
				
			
		<cfloop query="a">
			<cfset CrapDataMessage = "#CrapDataMessage#<br>
			<font color=""##FF0000"">#a.thisFld#</font> ">
	 	 </cfloop>
	<!--- now, things in the code table that aren't in the data --->
		 <cfquery name="b" datasource="#Application.uam_dbo#">
			select distinct(#field_name#)  as thisFld from #code_table_name# where #field_name# not in (
				select #field_name# from #table_name#)
		</cfquery>
		<cfset CrapDataMessage = "#CrapDataMessage#
		<hr>
		Query:
			<blockquote>
			select distinct(#field_name#)  as thisFld from #code_table_name# where #field_name# not in (
				select #field_name# from #table_name#)
			</blockquote>">
		<cfloop query="b">
			<cfset CrapDataMessage = "#CrapDataMessage#<br>
			<font color=""##FF0000"">#b.thisFld#</font> ">
	 	 </cfloop>
	</cfloop>

<!----

---->
#CrapDataMessage#

<!----
<cfmail to="#Application.DataProblemReportEmail#" subject="Suspect Code Table Values" from="fndlm@uaf.edu" type="html">
	This is an automatic message from the fine folks who brought you Arctos. Fix all the problems and they'll
	quit bugging you!
	<p></p>
	These are data values that are not in code tables, or code table values that are not in data.
	<p></p>
	Data not in code tables is BAD!! It breaks dropdowns, messes with forms, and makes the real data inaccessable. Fix it! Now!
	<p>
		Actually, you probably can't fix it - that's the problem! You have options:
			<ul>
				<li>Add the data value to the code table</li>
				<li>Send a list of bad data and replacement values to your friendly local programmer</li>
			</ul>
	</p>
	<p></p>
	Code Table data not used in tables may not be bad. People may be searching for things that don't exist, dropdowns are longer than they
	need be, but it isn't inaccurately representing specimens. Consider fixing it.
	<hr>
	#CrapDataMessage#
</cfmail>
---->
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
<cfinclude template="/includes/_footer.cfm">