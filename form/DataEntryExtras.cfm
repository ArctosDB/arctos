<cfif action is "addCollector">
<script>
		jQuery(document).ready(function() {

			$(".reqdClr:visible").each(function(e){
			    $(this).prop('required',true);
			});

			$( "#theForm" ).submit(function( event ) {
				event.preventDefault();
				$.ajax({
					url: "/component/Bulkloader.cfc?queryformat=column",
					type: "GET",
					dataType: "json",
					data: {
						method:  "saveNewCollector",
						q: $('#theForm').serialize()
					},
					success: function(r) {
						if (r=='success'){
							var retVal = confirm("Success! Click OK to close this, or CANCEL to create another ID.");
							if( retVal == true ){
						    	$("#dialog").dialog('close');
						 	}
						} else {
							alert('Error: ' + r);
						}
					},
					error: function (xhr, textStatus, errorThrown){
					    alert(errorThrown + ': ' + textStatus + ': ' + xhr);
					}
				});
			});
		});
	</script>
	<cfoutput>
		<cfquery name="ctcollector_role" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select collector_role from ctcollector_role order by collector_role
		</cfquery>
	    <label for="theForm"></label>Add Collector</label>
		<form name="theForm" id="theForm">
			<input type="hidden" id="uuid" name="uuid" value="#uuid#">
			<input type="hidden" name="nothing" id="nothing">
			<label for="collector_role">Role</label>
			<select name="collector_role" id="collector_role" size="1">
				<option></option>
				<cfloop query="ctcollector_role">
					<option	value="#ctcollector_role.collector_role#">#ctcollector_role.collector_role#</option>
				</cfloop>
			</select>
			<label for="coll_order">Order</label>
			<select name="coll_order" id="coll_order" size="1">
				<option></option>

				<cfloop from="6" to="15" index="i">
					<option	value="#i#">#i#</option>
				</cfloop>
			</select>
			<label for="agent_name">Agent Name</label>
			<input type="text" name="agent_name" id="agent_name" onchange="getAgent('nothing',this.id,'theForm',this.value);"
				onkeypress="return noenter(event);">
			<br><input type="submit" value="save">
	</cfoutput>
</cfif>
<!------------------------------------------------->
<cfif action is "addIdReln">
<script>
		jQuery(document).ready(function() {

			$(".reqdClr:visible").each(function(e){
			    $(this).prop('required',true);
			});

			$( "#theForm" ).submit(function( event ) {
				event.preventDefault();
				$.ajax({
					url: "/component/Bulkloader.cfc?queryformat=column",
					type: "GET",
					dataType: "json",
					data: {
						method:  "saveNewIdentifier",
						q: $('#theForm').serialize()
					},
					success: function(r) {
						if (r=='success'){
							var retVal = confirm("Success! Click OK to close this, or CANCEL to create another ID.");
							if( retVal == true ){
						    	$("#dialog").dialog('close');
						 	}
						} else {
							alert('Error: ' + r);
						}
					},
					error: function (xhr, textStatus, errorThrown){
					    alert(errorThrown + ': ' + textStatus + ': ' + xhr);
					}
				});
			});
		});
	</script>
	<cfoutput>
		<cfquery name="ctType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select other_id_type from ctcoll_other_id_type order by sort_order,other_id_type
		</cfquery>
		<cfquery name="ctid_references" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select id_references from ctid_references order by id_references
		</cfquery>

	    <label for="theForm"></label>Add ID/Relationship</label>
		<form name="theForm" id="theForm">
			<input type="hidden" id="uuid" name="uuid" value="#uuid#">
			<input type="hidden" name="nothing" id="nothing">
			 <label for="other_id_type">ID Type</label>
			<select name="other_id_type" id="other_id_type" size="1">
				<option></option>
				<cfloop query="ctType">
					<option	value="#ctType.other_id_type#">#ctType.other_id_type#</option>
				</cfloop>
			</select>
			<label for="other_id_value">ID Value</label>
			<input type="text" name="other_id_value" id="other_id_value">
			<label for="id_references">ID References</label>
			<select name="id_references" id="id_references" size="1">
				<cfloop query="ctid_references">
					<option	<cfif ctid_references.id_references is "self"> selected="selected"</cfif>
						value="#ctid_references.id_references#">#ctid_references.id_references#</option>
				</cfloop>
			</select>
			<br><input type="submit" value="save">
	</cfoutput>
</cfif>
<!------------------------------------------------->
<cfif action is "addAttribute">
<script>
		jQuery(document).ready(function() {
			$("#attribute_date").datepicker();
			$( "#attribute_type" ).change(function() {
				$.ajax({
					url: "/component/DataEntry.cfc?queryformat=column&returnformat=json",
					type: "GET",
					dataType: "json",
					data: {
						method:  "getAttCodeTbl",
						attribute: $( "#attribute_type" ).val(),
						guid_prefix: $( "#guid_prefix" ).val(),
						element: 'nothing'
					},
					success: function(r) {
						var result=r.DATA;
						var resType=result.V[0];
						var x;
						var n=result.V.length;
						$("#attrvalcell").html('');
						$("#attrunitcell").html('');
						if (resType == 'value'){
							// value pick, no units
							var s=document.createElement('SELECT');
							s.name='attribute_value';
							s.id=s.name;
							var a = document.createElement("option");
							a.text = '';
					    	a.value = '';
							s.appendChild(a);
							for (i=2;i<result.V.length;i++) {
								var theStr = result.V[i];
								if(theStr=='_yes_'){
									theStr='yes';
								}
								if(theStr=='_no_'){
									theStr='no';
								}
								var a = document.createElement("option");
								a.text = theStr;
								a.value = theStr;
								s.appendChild(a);
							}
							$("#attrvalcell").append('<label for="attribute_value">Value</label>');
							$("#attrvalcell").append(s);
							$("#attribute_value").select();
							$("#attrunitcell").append('<input type="hidden" name="attribute_units" id="attribute_units" value="">');
						} else if (resType == 'units') {
							var s=document.createElement('SELECT');
							s.name='attribute_units';
							s.id=s.name;
							var a = document.createElement("option");
							a.text = '';
					    	a.value = '';
							s.appendChild(a);
							for (i=2;i<result.V.length;i++) {
								var theStr = result.V[i];
								if(theStr=='_yes_'){
									theStr='yes';
								}
								if(theStr=='_no_'){
									theStr='no';
								}
								var a = document.createElement("option");
								a.text = theStr;
								a.value = theStr;
								s.appendChild(a);
							}
							$("#attrunitcell").append('<label for="attribute_units">Units</label>');
							$("#attrunitcell").append(s);
							var s='<label for="attribute_value">Value</label><input type="number" step="any" class="reqdClr" required name="attribute_value" id="attribute_value">';
							$("#attrvalcell").append(s);

							$("#attribute_value").focus();
							$("#attribute_units").addClass('reqdClr').prop('required',true);
						} else if (resType == 'NONE') {
							var s='<label for="attribute_value">Value</label><input type="text" class="reqdClr" required name="attribute_value" id="attribute_value">';
							$("#attrvalcell").append(s);
							$("#attribute_value").focus();
							$("#attrunitcell").append('<input type="hidden" name="attribute_units" id="attribute_units" value="">');

						} else {
							alert('Something bad happened! Try selecting nothing, then re-selecting an attribute or reloading this page');
						}

					},
					error: function (xhr, textStatus, errorThrown){
					    alert(errorThrown + ': ' + textStatus + ': ' + xhr);
					}
				});
			});

			$(".reqdClr:visible").each(function(e){
			    $(this).prop('required',true);
			});

			$( "#theForm" ).submit(function( event ) {
				event.preventDefault();
				$.ajax({
					url: "/component/Bulkloader.cfc?queryformat=column",
					type: "GET",
					dataType: "json",
					data: {
						method:  "saveNewSpecimenAttribute",
						q: $('#theForm').serialize()
					},
					success: function(r) {
						if (r=='success'){
							var retVal = confirm("Success! Click OK to close this, or CANCEL to create another specimen attribute.");
							if( retVal == true ){
						    	$("#dialog").dialog('close');
						 	}
						} else {
							alert('Error: ' + r);
						}
					},
					error: function (xhr, textStatus, errorThrown){
					    alert(errorThrown + ': ' + textStatus + ': ' + xhr);
					}
				});
			});
		});
	</script>
	<cfoutput>
		<cfquery name="CTATTRIBUTE_TYPE" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	       	select
	       		attribute_type
	       	from
	       		CTATTRIBUTE_TYPE,
	       		collection
	       	where collection.collection_cde=CTATTRIBUTE_TYPE.collection_cde and
	       	collection.guid_prefix='#guid_prefix#' group by attribute_type order by attribute_type
	    </cfquery>

	    <label for="theForm"></label>Add Specimen Attribute</label>
		<form name="theForm" id="theForm">
			<input type="hidden" id="uuid" name="uuid" value="#uuid#">
			<input type="hidden" name="nothing" id="nothing">
		    <table>
		      <tr>
		        <td>
					<label for="attribute_type">Attribute</label>
					<select name="attribute_type" id="attribute_type" required>
						<option value="">pick an attribute....</option>
						<cfloop query="CTATTRIBUTE_TYPE">
							<option value="#CTATTRIBUTE_TYPE.attribute_type#">#CTATTRIBUTE_TYPE.attribute_type#</option>
						</cfloop>
					</select>
				</td>
				<td id="attrvalcell">pick an attribute...</td>
				<td id="attrunitcell">pick an attribute...</td>
				<td id="attrdatecell">
					<label for="attribute_date">Determined Date</label>
					<input type="text" name="attribute_date" id="attribute_date">
				</td>
				<td id="attrdetcell">
					<input type="hidden" name="determined_by_agent_id" id="determined_by_agent_id">
					<label for="attribute_determiner">Determiner</label>
					<input type="text" name="attribute_determiner" id="attribute_determiner" class="reqdClr" value="#session.username#"
						onchange="getAgent('determined_by_agent_id','attribute_determiner','theForm',this.value); return false;"
						onKeyPress="return noenter(event);">
				</td>
			</tr>
			<tr>
				<td colspan="3" id="attrmethcell">
					<label for="determination_method">Method</label>
					<textarea name="determination_method" id="determination_method" rows="1" cols="50"></textarea>
				</td>
				<td  colspan="2" id="attreemcell">
					<label for="attribute_remark">Remark</label>
					<textarea name="attribute_remark" id="attribute_remark" rows="1" cols="50"></textarea>
				</td>
			</tr>
	    </table>
		<input type="submit" value="Save Attribute">
	</cfoutput>
</cfif>
<!------------------------------------------------------------>
<cfif action is "addPart">
	<script>
		jQuery(document).ready(function() {
			$("input[id^='part_attribute_date_']").each(function(e){
			    $(this).datepicker();
			});
			$(".reqdClr:visible").each(function(e){
			    $(this).prop('required',true);
			});

			$( "#theForm" ).submit(function( event ) {
				event.preventDefault();
				$.ajax({
					url: "/component/Bulkloader.cfc?queryformat=column",
					type: "GET",
					dataType: "json",
					data: {
						method:  "saveNewSpecimenPart",
						q: $('#theForm').serialize()
					},
					success: function(r) {
						if (r=='success'){
							var retVal = confirm("Success! Click OK to close this, or CANCEL to create another specimen part.");
							if( retVal == true ){
						    	$("#dialog").dialog('close');
						 	}
						} else {
							alert('Error: ' + r);
						}
					},
					error: function (xhr, textStatus, errorThrown){
					    alert(errorThrown + ': ' + textStatus + ': ' + xhr);
					}
				});
			});
		});

		function pattrChg(i){
			if ($("#part_attribute_type_" + i).val().length > 0) {
				$("#part_attribute_value_" + i).addClass('reqdClr').prop('required',true);
			} else {

				$("#part_attribute_value_" + i).removeClass().prop('required',false);
			}
		}
	</script>

	<cfoutput>
		<cfquery name="ctspecimen_part_name" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	       	select
	       		ctspecimen_part_name.part_name,
	       		collection.collection_cde
	       	from
	       		ctspecimen_part_name,
	       		collection
	       	where
	       		collection.collection_cde=ctspecimen_part_name.collection_cde and
	       		collection.guid_prefix='#guid_prefix#'
	       	group by ctspecimen_part_name.part_name,
	       		collection.collection_cde order by ctspecimen_part_name.part_name
	    </cfquery>
	    <cfquery name="cc" dbtype="query">
	    	select distinct collection_cde from ctspecimen_part_name
	    </cfquery>


	    <cfquery name="CTSPECPART_ATTRIBUTE_TYPE" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	       	select ATTRIBUTE_TYPE from CTSPECPART_ATTRIBUTE_TYPE group by ATTRIBUTE_TYPE  order by ATTRIBUTE_TYPE
	    </cfquery>
		<cfquery name="ctDisp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select coll_obj_disposition from ctcoll_obj_disp order by coll_obj_disposition
		</cfquery>
		<cfquery name="ctcontainer_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select container_type from ctcontainer_type order by container_type
		</cfquery>
	    <label for="theForm"></label>Add Specimen Part</label>
		<form name="theForm" id="theForm">
			<input type="hidden" id="uuid" name="uuid" value="#uuid#">
			<input type="hidden" name="nothing" id="nothing">
		    <table>
		      <tr>
		        <td>
					<label for="part_name">Part Name</label>
					<input type="text" name="part_name" id="part_name" class="reqdClr"
						onchange="findPart(this.id,this.value,'#cc.collection_cde#');"
						onkeypress="return noenter(event);">
				</td>
		        <td>
					<label for="disposition">Disposition</label>
					<select name="disposition" id="disposition" size="1"  class="reqdClr">
			            <cfloop query="ctDisp">
			              <option value="#ctDisp.coll_obj_disposition#">#ctDisp.coll_obj_disposition#</option>
			            </cfloop>
			          </select>
				</td>
		        <td>
					<label for="condition">Condition</label>
					<input type="text" name="condition" id="condition" class="reqdClr">
				</td>
		        <td>
					<label for="lot_count">Count</label>
					<input type="text" pattern="\d*" name="lot_count" class="reqdClr" size="2">
				</td>
		        <td>
					<label for="remarks">Remark</label>
					<input type="text" name="remarks" id="remarks">
				</td>
		        <td>
					<label for="container_barcode">Barcode</label>
					<input type="text" name="container_barcode">
				</td>
		        <td>
					<label for="change_container_type">Change Container Type</label>
					<select name="change_container_type" id="change_container_type" size="1">
						<option value=""></option>
			            <cfloop query="ctcontainer_type">
			              <option value="#ctcontainer_type.container_type#">#ctcontainer_type.container_type#</option>
			            </cfloop>
			          </select>
				</td>
		      </tr>
			<tr>
				<td colspan="8">
					Attributes
				</td>
			</tr>
			<tr>
				<td colspan="8">
					<table border>
						<tr>
							<th>Type</th>
							<th>Value</th>
							<th>Units</th>
							<th>Date</th>
							<th>Determiner</th>
							<th>Remark</th>
						</tr>
						<cfloop from="1" to="6" index="i">
							<tr>
								<td>
									<select name="part_attribute_type_#i#" id="part_attribute_type_#i#" size="1" onchange="pattrChg('#i#');">
										<option value=""></option>
							            <cfloop query="CTSPECPART_ATTRIBUTE_TYPE">
							              <option value="#CTSPECPART_ATTRIBUTE_TYPE.ATTRIBUTE_TYPE#">#CTSPECPART_ATTRIBUTE_TYPE.ATTRIBUTE_TYPE#</option>
							            </cfloop>
							          </select>

								</td>
								<td>
									<input type="text" name="part_attribute_value_#i#" id="part_attribute_value_#i#">
								</td>
								<td>
									<input type="text" name="part_attribute_units_#i#" id="part_attribute_units_#i#">
								</td>
								<td>
									<input type="text" name="part_attribute_date_#i#" id="part_attribute_date_#i#">
								</td>
								<td>
									<input type="text" name="part_attribute_determiner_#i#" id="part_attribute_determiner_#i#"
										onchange="getAgent('nothing','part_attribute_determiner_#i#','theForm',this.value); return false;"
										 onKeyPress="return noenter(event);">
								</td>
								<td>
									<input type="text" name="part_attribute_remark_#i#" id="part_attribute_remark_#i#">
								</td>
							</tr>
						</cfloop>
					</table>
				</td>
			</tr>
    </table>
	<input type="submit" value="Save Part">
	</cfoutput>
</cfif>
<!----------------------------------------------------------------->
<cfif action is "seeWhatsThere">
	<cfset numPartAttrs=6>
	<cfquery name="ese" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from  cf_temp_specevent  where UUID='#UUID#'
	</cfquery>
	<cfif ese.recordcount is 0>
		<p>There are no external specimen-events for this UUID/entry</p>
	<cfelse>
		<cfoutput>
			<p>There are #ese.recordcount# external specimen-events for this UUID/entry. (View details under
			<a href="/tools/BulkloadSpecimenEvent.cfm?action=managemystuff" target="_blank">EnterData/BatchTools</a>.) </p>
			<table border>
				<tr>
					<th>SPECIMEN_EVENT_TYPE</th>
					<th>Geog</th>
					<th>Locality</th>
					<th>Event</th>
				</tr>
				<cfloop query="ese">
					<tr>
						<td>#SPECIMEN_EVENT_TYPE#</td>
						<td>#HIGHER_GEOG#</td>
						<td>#SPEC_LOCALITY# (#LOCALITY_ID#)</td>
						<td>#VERBATIM_LOCALITY# @#VERBATIM_DATE# (#COLLECTING_EVENT_ID#)</td>
					</tr>
				</cfloop>
			</table>
		</cfoutput>
	</cfif>


	<cfquery name="ese" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from  cf_temp_parts  where other_id_number='#UUID#'
	</cfquery>
	<cfif ese.recordcount is 0>
		<p>There are no external specimen parts for this UUID/entry</p>
	<cfelse>
		<cfoutput>
			<p>There are #ese.recordcount# external specimen parts for this UUID/entry. (View details under
			<a href="/tools/BulkloadParts.cfm?action=managemystuff" target="_blank">EnterData/BatchTools</a>.) </p>
			<table border>
				<tr>
					<th>Part Name</th>
					<th>Barcode</th>
					<th>Attributes</th>
				</tr>
				<cfloop query="ese">
					<cfset pattrs="">
					<cfloop from="1" to="#numPartAttrs#" index="i">
						<cfset thisAttr=evaluate("PART_ATTRIBUTE_TYPE_" & i)>
						<cfset thisVal=evaluate("PART_ATTRIBUTE_VALUE_" & i)>
						<cfif len(thisAttr) gt 0 and len(thisVal) gt 0>
							<cfset pattrs=listappend(pattrs,"#thisAttr#=#thisVal#",";")>
						</cfif>
					</cfloop>

					<tr>
						<td>#part_name#</td>
						<td>#container_barcode#</td>
						<td>#pattrs#</td>
					</tr>
				</cfloop>
			</table>
		</cfoutput>
	</cfif>
	<cfquery name="ese" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from  cf_temp_attributes  where other_id_number='#UUID#'
	</cfquery>
	<cfif ese.recordcount is 0>
		<p>There are no external specimen attributes for this UUID/entry</p>
	<cfelse>
		<cfoutput>
			<p>There are #ese.recordcount# external specimen attributes for this UUID/entry. (View details under
			<a href="/tools/BulkloadAttributes.cfm?action=managemystuff" target="_blank">EnterData/BatchTools</a>.) </p>
			<table border>
				<tr>
					<th>Attribute</th>
					<th>Value</th>
				</tr>
				<cfloop query="ese">
					<tr>
						<td>#ATTRIBUTE#</td>
						<td>#ATTRIBUTE_VALUE# #ATTRIBUTE_UNITS#</td>
					</tr>
				</cfloop>
			</table>
		</cfoutput>
	</cfif>
	<cfquery name="ese" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from  cf_temp_oids  where EXISTING_OTHER_ID_NUMBER='#UUID#'
	</cfquery>
	<cfif ese.recordcount is 0>
		<p>There are no external IDs for this UUID/entry</p>
	<cfelse>
		<cfoutput>
			<p>There are #ese.recordcount# external IDs for this UUID/entry. (View details under
			<a href="/tools/BulkloadOtherId.cfm?action=managemystuff" target="_blank">EnterData/BatchTools</a>.) </p>
			<table border>
				<tr>
					<th>Type</th>
					<th>Value</th>
					<th>References</th>
				</tr>
				<cfloop query="ese">
					<tr>
						<td>#NEW_OTHER_ID_TYPE#</td>
						<td>#NEW_OTHER_ID_NUMBER#</td>
						<td>#NEW_OTHER_ID_REFERENCES#</td>
					</tr>
				</cfloop>
			</table>
		</cfoutput>
	</cfif>
</cfif>
<cfif action is "help">
	<p>
		This form extends the specimen bulkloader to include non-specimen bulkloaders. This is a limited-scope form;
		for specimen-events, most limitations may be bypassed by pre-creating collecting events or localities.
	</p>
	<p>
		After specimens exist, load data through the appropriate loader in EnterData/BatchTools.
	</p>
	<p>
		To use this form, other_id_num_type_4 MUST be a UUID, and other_id_val_4 MUST be a unique identifier. It
		is recommended to allow the application to generate these values; simply leave other_id_4 NULL to do so.
	</p>
	<p>
		The UUID is the link to related records created here; do not alter or remove it until all data have been
		loaded and associated with the proper specimen. After all data are loaded, it's OK but not necessary to delete the UUID.
	</p>
</cfif>
<!--------------------------------------------------------->
<cfif action is "addSE">
	<style>
		.grpDiv {border:1px solid green;}
	</style>
	<script>
		/// everything here is copy/pasted from DE and then injected into the same page, so it shared ID - bla - cheat with find
		jQuery(document).ready(function() {
			$("#assigned_date").datepicker();
			$("#began_date1").datepicker();
			$("#ended_date1").datepicker();
			$(".reqdClr:visible").each(function(e){
			    $(this).prop('required',true);
			});

			$( "#theForm" ).submit(function( event ) {
				event.preventDefault();
				$.ajax({
					url: "/component/Bulkloader.cfc?queryformat=column",
					type: "GET",
					dataType: "json",
					data: {
						method:  "saveNewSpecimenEvent",
						q: $('#theForm').serialize()
					},
					success: function(r) {
						if (r=='success'){
							var retVal = confirm("Success! Click OK to close this, or CANCEL to create another specimen-event.");
							if( retVal == true ){
						    	$("#dialog").dialog('close');
						 	}
						} else {
							alert('Error: ' + r);
						}
					},
					error: function (xhr, textStatus, errorThrown){
					    alert(errorThrown);
					}
				});
			});
		});

		function typeEvent(oo){
			if (oo=='on'){
				// clicked from "pick event" to "type event"
				// pick event off
				$("#opnPickEventDiv").hide();
				// type event on
				$("#opnEnterEventDiv").show();
				// pick locality on
				$("#opnPickLocalityDiv").show();
				// type locality off
				$("#opnEnterkLocalityDiv").hide();

				$("#letype").val('type_event');
			} else {
				// clicked from "type event" to "pick event"
				// pick event on
				$("#opnPickEventDiv").show();
				// type event off
				$("#opnEnterEventDiv").hide();
				// all locality off
				$("#opnPickLocalityDiv").hide();
				$("#opnEnterkLocalityDiv").hide();
				$("#letype").val('pick_event');
			}
		}
		function typeLocality(oo){
			if (oo=='on'){
				// clicked from "pick locality" to "type locality"
				$("#opnPickLocalityDiv").hide();
				$("#opnEnterkLocalityDiv").show();
				$("#letype").val('type_locality');
			} else {
				$("#opnPickLocalityDiv").show();
				$("#opnEnterkLocalityDiv").hide();
				$("#letype").val('pick_locality');
			}
		}

		function pickLL(OrigUnits){
			var dms=$("#mptab").find("[id='dms']");
			var ddm=$("#mptab").find("[id='ddm']");
			var dd=$("#mptab").find("[id='dd']");
			var utm=$("#mptab").find("[id='utm']");
			var lat_long_meta=$("#mptab").find("[id='lat_long_meta']");
			dms.hide();
			ddm.hide();
			dd.hide();
			utm.hide();
			lat_long_meta.hide();
			if (OrigUnits == 'deg. min. sec.') {
				lat_long_meta.show();
				dms.show();
			} else if (OrigUnits == 'decimal degrees') {
				lat_long_meta.show();
				dd.show();
			} else if (OrigUnits == 'degrees dec. minutes') {
				lat_long_meta.show();
				ddm.show();
			} else if (OrigUnits == 'UTM') {
				lat_long_meta.show();
				utm.show();
			}
		}
	</script>
	<cfoutput>
		<cfquery name="ctgeoreference_protocol" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select georeference_protocol from ctgeoreference_protocol order by georeference_protocol
		</cfquery>
		<cfquery name="cterror" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	    	select LAT_LONG_ERROR_UNITS from ctLAT_LONG_ERROR_UNITS order by lat_long_error_units
	    </cfquery>
		<cfquery name="ctdatum" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select datum from ctdatum order by datum
	    </cfquery>
		<cfquery name="ctgeorefmethod" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	       	select georefmethod from ctgeorefmethod order by georefmethod
	    </cfquery>
		<cfquery name="ctverificationstatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	       	select verificationstatus from ctverificationstatus order by verificationstatus
	    </cfquery>
		<cfquery name="ctspecimen_event_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select specimen_event_type from ctspecimen_event_type order by specimen_event_type
		</cfquery>
		<cfquery name="ctcollecting_source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	        select COLLECTING_SOURCE from ctcollecting_source order by COLLECTING_SOURCE
	     </cfquery>
		<cfquery name="ctcollecting_source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	        select COLLECTING_SOURCE from ctcollecting_source order by COLLECTING_SOURCE
	     </cfquery>
		<cfquery name="ctunits" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	       select ORIG_LAT_LONG_UNITS from ctLAT_LONG_UNITS order by orig_lat_long_units
	    </cfquery>
		<cfquery name="ctOrigElevUnits" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	       	select orig_elev_units from ctorig_elev_units
	    </cfquery>
	    <label for="theForm">Add Specimen-Event</label>
		<form name="theForm" id="theForm">
			<input type="hidden" id="uuid" name="uuid" value="#uuid#">
			<input type="hidden" name="nothing" id="nothing">
			<input type="hidden" name="letype" id="letype" value="pick_event">
			<table id="mptab">
				<tr>
					<td>
						<label for="specimen_event_type">Specimen/Event Type</label>
						<select name="specimen_event_type" id="specimen_event_type" size="1" class="reqdClr">
							<cfloop query="ctspecimen_event_type">
								<option value="#ctspecimen_event_type.specimen_event_type#">#ctspecimen_event_type.specimen_event_type#</option>
						    </cfloop>
						</select>
					</td>
					<td>
						<label for="assigned_by_agent">Event Assigned by Agent</label>
						<input type="text" name="assigned_by_agent" id="assigned_by_agent" class="reqdClr" size="40" value="#session.dbuser#"
							 onchange="getAgent('assigned_by_agent_id','assigned_by_agent','theForm',this.value); return false;"
							 onKeyPress="return noenter(event);">
						<input type="hidden" name="assigned_by_agent_id" id="assigned_by_agent_id" value="#session.myAgentId#">
					</td>
					<td>
						<label for="assigned_date">Specimen/Event Assigned Date</label>
						<input type="text" name="assigned_date" id="assigned_date" value="#dateformat(now(),'yyyy-mm-dd')#" class="reqdClr">
					</td>
					<td>
						<label for="VerificationStatus">Verification Status</label>
						<select name="VerificationStatus" id="verificationstatus" size="1" class="reqdClr">
							<option value="unverified">unverified</option>
						</select>
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="specimen_event_remark" class="infoLink">Specimen/Event Remark</label>
						<input type="text" name="specimen_event_remark" id="specimen_event_remark" value="" size="75">
					</td>
					<td colspan="2">
						<label for="habitat">Habitat</label>
						<input type="text" name="habitat" id="habitat" size="75">
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="collecting_source">Collecting Source</label>
						<select name="collecting_source" id="collecting_source" size="1">
							<option value=""></option>
							<cfloop query="ctcollecting_source">
								<option value="#ctcollecting_source.COLLECTING_SOURCE#">#ctcollecting_source.COLLECTING_SOURCE#</option>
							</cfloop>
						</select>
					</td>
					<td colspan="2">
						<label for="collecting_method" class="infoLink">Collecting Method</label>
						<input type="text" name="collecting_method" id="collecting_method" value="" size="75">
					</td>
				</tr>
				<tr>
					<td colspan="4">
						<div class="grpDiv" id="opnPickEventDiv" >
						<label for="opnPickEventDiv">Pick a collecting event</label>
							<table width="100%">
								<tr>
									<td  >
										<label for="">Find Collecting Event by Nickname</label>
										<input type="text" name="collecting_event_name" class="" id="collecting_event_name" size="60"
											onchange="findCollEvent('collecting_event_id','theForm','cepick',this.value);">
									</td>
									<td>
										<input type="button" class="picBtn" value="more pick options" onclick="findCollEvent('collecting_event_id','theForm','cepick');">
									</td>
									<td>
										<input type="hidden" id="collecting_event_id" name="collecting_event_id" value="">
										<label for="">(Verbatim Locality of picked Events will go here)</label>
										<input type="text" size="50" name="cepick" class="readClr" readonly="readonly">
									</td>
									<td><input type="button" class="lnkBtn" value="Type Event Instead" onclick="typeEvent('on');"></td>
								</tr>

							</table>
						</div>
					</td>
				</tr>
				<tr>
					<td colspan="4">
						<div class="grpDiv" id="opnEnterEventDiv" style="display:none;">
						<label for="opnEnterEventDiv">Create a collecting event</label>
							<table>
								<tr>
									<td colspan="3">
										<label for="verbatim_locality">Verbatim Locality</label>
										<input type="text" name="verbatim_locality" class="reqdClr" size="80" id="verbatim_locality">
									</td>
									<td>
										<input type="button" class="lnkBtn" value="Back to Pick Event" onclick="typeEvent('off');">
									</td>
								</tr>
								<tr>
									<td colspan="2">
										<label for="verbatim_date">VerbatimDate</label>
										<input type="text" name="verbatim_date" class="reqdClr" id="verbatim_date" size="40">
									</td>
									<td>
										<label for="began_date">BeginDate</label>
										<input type="text" name="began_date" class="reqdClr" id="began_date1" size="20">
									</td>
									<td>
										<label for="ended_date">EndDate</label>
										<input type="text" name="ended_date" class="reqdClr" id="ended_date1" size="20">
									</td>
								</tr>
								<tr>
									<td colspan="3">
										<label for="coll_event_remarks">Collecting Event Remarks</label>
										<input type="text" name="coll_event_remarks" size="80" id="coll_event_remarks">
									</td>
								</tr>
								<tr>
									<td colspan="4">
										<div class="grpDiv" id="opnPickLocalityDiv">
										<label for="opnPickLocalityDiv">Pick a Locality</label>
											<table>
												<tr>
													<td>
														<label for="locality_name">Pick Locality By Nickname</label>
														<input type="text" name="locality_name" class="" id="locality_name" size="60"
															onchange="LocalityPick('locality_id','pickedSpecloc','theForm',this.value);">
														<input type="button" class="picBtn" value="more pick options"
															onclick="LocalityPick('locality_id','pickedSpecloc','theForm',''); return false;">
															<input type="hidden" name="locality_id" id="locality_id" class="readClr" size="8">
													</td>
													<td>
														<label for="pickedSpecloc">Picked SpecificLocality</label>
														<input type="text" name="pickedSpecloc" id="pickedSpecloc" class="readClr" size="60">
														<input type="button" class="lnkBtn" value="Type Locality Instead" onclick="typeLocality('on');">
													</td>
												</tr>
											</table>

										</div>
									</td>
								</tr>
							</table>
						</div>
					</td>
				</tr>
				<tr>
					<td colspan="4" >

						<div class="grpDiv" id="opnEnterkLocalityDiv" style="display:none;">
							<label for="opnPickLocalityDiv">Create a Locality</label>
							<table>
								<tr>
									<td>
										<label for="higher_geog">Pick Higher Geography</label>
										<input type="text" name="higher_geog" class="reqdClr" id="higher_geog" size="80"
											onchange="GeogPick('nothing',this.id,'theForm',this.value)">

										<input type="button" class="lnkBtn" value="Pick Locality Instead" onclick="typeLocality('off');">

									</td>
								</tr>
								<tr>
									<td>
										<label for="spec_locality">Specific Locality</label>
										<input type="text" name="spec_locality" class="reqdClr" id="spec_locality" size="80">
									</td>
								</tr>
								<tr>
									<td>
										<label for="locality_remarks">Locality Remarks</label>
										<input type="text" name="locality_remarks" class="" id="locality_remarks" size="80">
									</td>
								</tr>
								<tr>
									<td>
										<table>
											<tr>
												<td>
													<label for+"orig_elev_units">Elevation Units</label>
													<select name="orig_elev_units" size="1" id="orig_elev_units">
														<option value=""></option>
														<cfloop query="ctOrigElevUnits">
															<option value="#orig_elev_units#">#orig_elev_units#</option>
														</cfloop>
													</select>
												</td>
												<td>
													<label for+"minimum_elevation">MinElevation</label>
													<input type="text" name="minimum_elevation" size="4" id="minimum_elevation">
												</td>
												<td>
													<label for+"maximum_elevation">MaxElevation</label>
													<input type="text" name="maximum_elevation" size="4" id="maximum_elevation">
												</td>
											</tr>
										</table>
									</td>
								</tr>
								<tr>
									<td>
										<label for="orig_lat_long_units">Coordinate Units</label>
										<select name="orig_lat_long_units" id="orig_lat_long_units"	onChange="pickLL(this.value);">
											<option value=""></option>
											<cfloop query="ctunits">
											  <option value="#ctunits.ORIG_LAT_LONG_UNITS#">#ctunits.ORIG_LAT_LONG_UNITS#</option>
											</cfloop>
										</select>
										<!----
										<span style="font-size:small" class="likeLink" onclick="geolocate()">[ geolocate ]</span>
										<div id="geoLocateResults" style="font-size:small"></div>
										---->
									</td>
								</tr>
								<tr>
									<td>
										<div id="lat_long_meta" style="display:none;">
											<table cellpadding="0" cellspacing="0">
												<tr>
													<td align="right"><span class="f11a">Max Error</span></td>
													<td>
														<input type="text" name="max_error_distance" id="max_error_distance" size="10">
														<select name="max_error_units" size="1" id="max_error_units">
															<option value=""></option>
															<cfloop query="cterror">
															  <option value="#cterror.LAT_LONG_ERROR_UNITS#">#cterror.LAT_LONG_ERROR_UNITS#</option>
															</cfloop>
														</select>
													</td>
												</tr>
												<tr>
													<td align="right"><span class="f11a">Datum</span></td>
													<td>
														<select name="datum" size="1" class="reqdClr" id="datum">
															<option value=""></option>
															<cfloop query="ctdatum">
																<option value="#datum#">#datum#</option>
															</cfloop>
														</select>
													</td>
												</tr>


												<tr>
													<td align="right"><span class="f11a">Georeference Source</span></td>
													<td colspan="3" nowrap="nowrap">
														<input type="text" name="georeference_source" id="georeference_source"  class="reqdClr" size="60">
													</td>
												</tr>
												<tr>
													<td align="right"><span class="f11a">Georeference Protocol</span></td>
													<td>
														<select name="georeference_protocol" size="1" class="reqdClr" style="width:130px" id="georeference_protocol">
															<option value=""></option>
															<cfloop query="ctgeoreference_protocol">
																<option value="#ctgeoreference_protocol.georeference_protocol#">#ctgeoreference_protocol.georeference_protocol#</option>
															</cfloop>
														</select>
													</td>
												</tr>
											</table>
										</div>
										<div id="dms" style="display:none;">
											<table cellpadding="0" cellspacing="0">
												<tr>
													<td align="right"><span class="f11a">Lat Deg</span></td>
													<td>
														<input type="text" name="latdeg" size="4" id="latdeg" class="reqdClr">
													</td>
													<td align="right"><span class="f11a">Min</span></td>
													<td>
														<input type="text"
															 name="LATMIN"
															size="4"
															id="latmin"
															class="reqdClr">
													</td>
													<td align="right"><span class="f11a">Sec</span></td>
													<td>
														<input type="text"
															 name="latsec"
															size="6"
															id="latsec"
															class="reqdClr">
														</td>
													<td align="right"><span class="f11a">Dir</span></td>
													<td>
														<select name="latdir" size="1" id="latdir" class="reqdClr">
															<option value=""></option>
															<option value="N">N</option>
															<option value="S">S</option>
														  </select>
													</td>
												</tr>
												<tr>
													<td align="right"><span class="f11a">Long Deg</span></td>
													<td>
														<input type="text"
															name="longdeg"
															size="4"
															id="longdeg"
															class="reqdClr">
													</td>
													<td align="right"><span class="f11a">Min</span></td>
													<td>
														<input type="text"
															name="longmin"
															size="4"
															id="longmin"
															class="reqdClr">
													</td>
													<td align="right"><span class="f11a">Sec</span></td>
													<td>
														<input type="text"
															 name="longsec"
															size="6"
															id="longsec"
															class="reqdClr">
													</td>
													<td align="right"><span class="f11a">Dir</span></td>
													<td>
														<select name="longdir" size="1" id="longdir" class="reqdClr">
															<option value=""></option>
															<option value="E">E</option>
															<option value="W">W</option>
														  </select>
													</td>
												</tr>
											</table>
										</div>
										<div id="ddm"  style="display:none;">
											<table cellpadding="0" cellspacing="0">
												<tr>
													<td align="right"><span class="f11a">Lat Deg</span></td>
													<td>
														<input type="text"
															 name="decLAT_DEG"
															size="4"
															id="decLAT_DEG"
															class="reqdClr"
															onchange="dataEntry.latdeg.value=this.value;">
													</td>
													<td align="right"><span class="f11a">Dec Min</span></td>
													<td>
														<input type="text"
															name="dec_lat_min"
															 size="8"
															id="dec_lat_min"
															class="reqdClr">
													</td>
													<td align="right"><span class="f11a">Dir</span></td>
													<td>
														<select name="decLAT_DIR"
															size="1"
															id="decLAT_DIR"
															class="reqdClr"
															onchange="dataEntry.latdir.value=this.value;">
															<option value=""></option>
															<option value="N">N</option>
															<option value="S">S</option>
														</select>
													</td>
												</tr>
												<tr>
													<td align="right"><span class="f11a">Long Deg</span></td>
													<td>
														<input type="text"
															name="decLONGDEG"
															size="4"
															id="decLONGDEG"
															class="reqdClr"
															onchange="dataEntry.longdeg.value=this.value;">
													</td>
													<td align="right"><span class="f11a">Dec Min</span></td>
													<td>
														<input type="text"
															name="DEC_LONG_MIN"
															size="8"
															id="dec_long_min"
															class="reqdClr">
													</td>
													<td align="right"><span class="f11a">Dir</span></td>
													<td>
														<select name="decLONGDIR"
															 size="1"
															id="decLONGDIR"
															class="reqdClr"
															onchange="dataEntry.longdir.value=this.value;">
															<option value=""></option>
															<option value="E">E</option>
															<option value="W">W</option>
														</select>
													</td>
												</tr>
											</table>
										</div>
										<div id="dd"  style="display:none;">
											<span class="f11a">Dec Lat</span>
											<input type="text"
												 name="dec_lat"
												size="8"
												id="dec_lat"
												class="reqdClr">
											<span class="f11a">Dec Long</span>
												<input type="text"
													 name="dec_long"
													size="8"
													id="dec_long"
													class="reqdClr">
										</div>
										<div id="utm" style="display:none;">
											<span class="f11a">UTM Zone</span>
											<input type="text"
												 name="utm_zone"
												size="8"
												id="utm_zone"
												class="reqdClr">
											<span class="f11a">UTM E/W</span>
											<input type="text"
												 name="utm_ew"
												size="8"
												id="utm_ew"
												class="reqdClr">
											<span class="f11a">UTM N/S</span>
											<input type="text"
												 name="utm_ns"
												size="8"
												id="utm_ns"
												class="reqdClr">
										</div>
									</td>
								</tr>
							</table>
						</div>
					</td>
				</tr>
			</table>
			<input type="submit" value="Save Event">
		</form>
	</cfoutput>
</cfif>