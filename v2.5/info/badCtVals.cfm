<!--- no security --->
<cfset i=1>
<cfoutput>
<cfset TblCtblFld = querynew("
	table_name,
	code_table_name,
	field_name")>
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

<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "addr", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctaddr_type", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "addr_type", #i#)>
<cfset i=#i#+1>

<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "agent", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctagent_type", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "agent_type", #i#)>
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
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "binary_object", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctbin_obj_aspect", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "aspect", #i#)>
<cfset i=#i#+1>

<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "binary_object", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctbin_obj_subject", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "subject", #i#)>
<cfset i=#i#+1>

<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "biol_indiv_relations", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctbiol_relations", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "biol_indiv_relationship", #i#)>
<cfset i=#i#+1>

<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "borrow", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctborrow_status", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "borrow_status", #i#)>
<cfset i=#i#+1>

<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "citation", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctcitation_type_status", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "type_status", #i#)>
<cfset i=#i#+1>

<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "collecting_event", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctcollecting_method", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "collecting_method", #i#)>
<cfset i=#i#+1>

<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "collecting_event", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctcollecting_source", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "collecting_source", #i#)>
<cfset i=#i#+1>

<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "collector", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctcollector_role", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "collector_role", #i#)>
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

<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "container", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctcontainer_type", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "container_type", #i#)>
<cfset i=#i#+1>

<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "electronic_address", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctelectronic_addr_type", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "address_type", #i#)>
<cfset i=#i#+1>

<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "encumbrance", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctencumbrance_action", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "encumbrance_action", #i#)>
<cfset i=#i#+1>

<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "fluid_container_history", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctfluid_concentration", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "concentration", #i#)>
<cfset i=#i#+1>

<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "fluid_container_history", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctfluid_type", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "fluid_type", #i#)>
<cfset i=#i#+1>

<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "geog_auth_rec", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctcontinent", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "continent_ocean", #i#)>
<cfset i=#i#+1>

<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "geog_auth_rec", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctfeature", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "feature", #i#)>
<cfset i=#i#+1>

<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "geog_auth_rec", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctisland_group", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "island_group", #i#)>
<cfset i=#i#+1>

<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "identification", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctnature_of_id", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "nature_of_id", #i#)>
<cfset i=#i#+1>

<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "locality", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctdepth_units", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "depth_units", #i#)>
<cfset i=#i#+1>

<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "lat_long", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctdatum", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "datum", #i#)>
<cfset i=#i#+1>

<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "lat_long", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctgeorefmethod", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "georefmethod", #i#)>
<cfset i=#i#+1>

<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "lat_long", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctlat_long_ref_source", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "lat_long_ref_source", #i#)>
<cfset i=#i#+1>
	
<cfset newrows = queryaddrow(TblCtblFld,1)>
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
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "specimen_part", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctspecimen_preserv_method", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "preserve_method", #i#)>
<cfset i=#i#+1>

<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "taxonomy", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctclass", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "phylclass", #i#)>
<!----
<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "table_name", "biol_indiv_remark", 6)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctage_det_method", 6)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "age_det_method", 6)>
----> 
<cfset CrapDataMessage = "">
	<cfloop query="TblCtblFld">
	<!---- first, things in the data that aren't in the code table --->
		<cfquery name="a" datasource="#Application.uam_dbo#">
			select distinct(#field_name#)  as thisFld from #table_name# where #field_name# not in (
				select #field_name# from #code_table_name#)
		</cfquery>
		<cfif #a.recordcount# gt 0>
			<cfset CrapDataMessage = "#CrapDataMessage#
				<hr><font color=""##FF0000"">The following values for #field_name# are in table 
				#table_name# but not in code table #code_table_name#:
				</font>">
			<cfloop query="a">
				<cfset CrapDataMessage = "#CrapDataMessage#<br>
				<font color=""##FF0000"">:#a.thisFld#:</font> ">
		  </cfloop>
		<cfelse>
			<cfset CrapDataMessage = '#CrapDataMessage#
				<hr> <font color="##00FF00">All #field_name# values 
				in #table_name# are in #code_table_name#!</font>'>
		</cfif>
	<!--- now, things in the code table that aren't in the data --->
		 <cfquery name="b" datasource="#Application.uam_dbo#">
			select distinct(#field_name#)  as thisFld from #code_table_name# where #field_name# not in (
				select #field_name# from #table_name#)
		</cfquery>
		select distinct(#field_name#)  as thisFld from #code_table_name# where #field_name# not in (
				select #field_name# from #table_name#)
		<cfif #b.recordcount# gt 0>
			<cfset CrapDataMessage = "#CrapDataMessage#
				<hr><font color=""##FF9900"">The following values for #field_name# are in 
				code table #code_table_name#
				 but not in table #table_name#:				
				</font>">
			<cfloop query="b">
				<cfset CrapDataMessage = "#CrapDataMessage#<br>
				<font color=""##FF9900"">#b.thisFld#</font> ">
		  </cfloop>
		 <cfelse>
		 	<cfset CrapDataMessage = '#CrapDataMessage#
				<hr> <font color="##00FF00">All #field_name# values 
				in #code_table_name# are used in #table_name#!</font>'>
	  </cfif>
	</cfloop>

<!----- attributes require some special handling ---->
<cfset i=1>
<cfset TblCtblFld = querynew("
	attribute_type,
	code_table_name,
	field_name")>
<cfset newrows = queryaddrow(TblCtblFld, 1)>
<cfset temp = QuerySetCell(TblCtblFld, "attribute_type", "age class", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "code_table_name", "ctage_class", #i#)>
<cfset temp = QuerySetCell(TblCtblFld, "field_name", "age_class", #i#)>
<cfset i=#i#+1>

<cfloop query="TblCtblFld">
	<!---- first, things in the data that aren't in the code table --->
		<cfquery name="a" datasource="#Application.uam_dbo#">
			select 
				distinct(attribute_value) as thisFld 
			from attributes 
			where 
				attribute_type='#attribute_type#' AND
				attribute_value not in (
				select 
					#field_name# 
				from 
					#code_table_name#)
		</cfquery>
		<cfif #a.recordcount# gt 0>
			<cfset CrapDataMessage = "#CrapDataMessage#
				<hr><font color=""##FF0000"">The following values for #field_name# are in table 
				attributes but not in code table #code_table_name#:
				</font>">
			<cfloop query="a">
				<cfset CrapDataMessage = "#CrapDataMessage#<br>
				<font color=""##FF0000"">:#a.thisFld#:</font> ">
		  </cfloop>
		<cfelse>
			<cfset CrapDataMessage = '#CrapDataMessage#
				<hr> <font color="##00FF00">All #field_name# values 
				in attributes are in #code_table_name#!</font>'>
		</cfif>
	<!--- now, things in the code table that aren't in the data --->
		 <cfquery name="b" datasource="#Application.uam_dbo#">
			select 
				distinct(#field_name#) as thisFld 
			from #code_table_name# where #field_name# not in (
				select 
					attribute_value 
				from 
					attributes 
				where 
					attribute_type = '#attribute_type#')
		</cfquery>
		
		<cfif #b.recordcount# gt 0>
			<cfset CrapDataMessage = "#CrapDataMessage#
				<hr><font color=""##FF9900"">The following values for #field_name# are in 
				code table #code_table_name#
				 but not in table attributes:				
				</font>">
			
			<cfloop query="b">
				<cfset CrapDataMessage = "#CrapDataMessage#<br>
				<font color=""##FF9900"">#b.thisFld#</font> ">
		  </cfloop>
		 <cfelse>
		 	<cfset CrapDataMessage = '#CrapDataMessage#
				<hr> <font color="##00FF00">All #field_name# values 
				in #code_table_name# are used in attributes!</font>'>
	  </cfif>
  </cfloop>
#CrapDataMessage#

<!----
<cfmail to="#Application.DataProblemReportEmail#" subject="Suspect Code Table Values" from="#mailFromAddress#" type="html">
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
----->
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