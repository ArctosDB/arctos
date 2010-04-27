<cfinclude template="/includes/_pickHeader.cfm">
<script language="JavaScript" src="/includes/jquery/jquery.ui.datepicker.min.js" type="text/javascript"></script>
<script>
	jQuery(document).ready(function() {
		jQuery(function() {
			jQuery("#made_date").datepicker();
			jQuery("#began_date").datepicker();
			jQuery("#ended_date").datepicker();	
			jQuery("#determined_date").datepicker();
			for (i=1;i<=12;i++){
				jQuery("#geo_att_determined_date_" + i).datepicker();
				jQuery("#attribute_date_" + i).datepicker();
			}
		});
		jQuery("input[type=text]").focus(function(){
		    //this.select();
		});
		$("select[id^='geology_attribute_']").each(function(e){
			var gid='geology_attribute_' + String(e+1);
			populateGeology(gid);			
		});		
	});
</script>
<cfoutput>
	<cfquery name="ctspecpart_attribute_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select attribute_type from ctspecpart_attribute_type order by attribute_type
	</cfquery>

	<cfquery name="pAtt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select
			 part_attribute_id,
			 attribute_type,
			 attribute_value,
			 attribute_units,
			 determined_date,
			 determined_by_agent_id,
			 attribute_remark
		from
			specimen_part_attribute
		where
			collection_object_id=#partID#
	</cfquery>
	
	<hr>
	<form name="f">
	<table border>
		<tr>
			<th>Attribute</th>
			<th>Value</th>
			<th>Units</th>
			<th>Date</th>
			<th>DeterminedBy</th>
			<th>Remark</th>
		</tr>
		<tr id="r_new" class="newRec">
			<td>
				<select id="attribute_type_new" name="attribute_type_new" onchange="setPartAttOptions('new',this.value)">
					<option value=""></option>
					<cfloop query="ctspecpart_attribute_type">
						<option value="#attribute_type#">#attribute_type#</option>
					</cfloop>
				</select>
			</td>
			<td id="v_new"></td>
			<td is="u_new"></td>
			<td id="d_new">
				<input type="text" name="determined_date_new" id="determined_date_new">
			</td>
			<td id="a_new">
				<input type="hidden" name="determined_id_new" id="determined_id_new">
				<input type="text" name="determined_agent_new" id="determined_agent_new"
					onchange="getAgent('determined_id_new',this.id,'f',this.value);" onkeypress="return noenter(event);">
			</td>
			<td id="r_new">
				<input type="text" name="attribute_remark" id="attribute_remark">
			</td>
		</tr>
	</table>
	</form>
	<cfdump var="#pAtt#">

</cfoutput>	
