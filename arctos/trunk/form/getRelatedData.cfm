<cfinclude template="/includes/alwaysInclude.cfm">
	<script>
		function saveCheck (id, val) {
			jQuery.getJSON("/component/functions.cfc",
				{
					method : "saveDeSettings",
					id : id,
					val : val,
					returnformat : "json",
					queryformat : 'column'
				},
				function (result){}
			);

		}
		function useThis(id) {


			var ev=$("#relpick_event").is(':checked');

			//$('#checkBox').attr('checked');
			var lo=$("#relpick_locality").is(':checked');
			var co=$("#relpick_collector").is(':checked');


		//console.log('ev= ' + ev);

			evv=$("#cevid_" + id).val();
			lov=$("#locid_" + id).val();
			cov=$("#colls_" + id).val();
			console.log('ev='+ev);
			if (ev==true){
				// use event
				parent.jQuery("#collecting_event_id").val(evv);
			} else {
				// do not update locality AND event
				if (lo==true) {
					parent.jQuery("#collecting_event_id").val('');
					parent.unpickEvent();
					parent.jQuery("#locality_id").val(lov);
				}
			}
			if (co==true){
				//parent.jQuery('select[id^="collector_role_"]').val('c');
				parent.jQuery('select[id^="collector_role_"]').val('Collector');
				parent.jQuery('input[id^="collector_agent_"]').val('');



				cary=cov.split(',');

				$.each(cary, function(key, value) {
					//console.log(key + ': ' + value);
					var thisKey=key+1;
					//console.log('thisKey= ' + thisKey);
					parent.jQuery("#collector_agent_" + thisKey).val(value);

				});


			}
			var clickedfrom=$("#clickedfrom").val();
			var idtype=$("#idtype").val();
			var idval=$("#idval").val();

			console.log('clickedfrom='+clickedfrom);
			console.log('idtype='+idtype);
			console.log('idval='+idval);
			parent.jQuery("#other_id_num_type_" + clickedfrom).val(idtype);
			parent.jQuery("#other_id_num_" + clickedfrom).val(idval);
			parent.closegetRelatedData();

		}
	</script>
	<cfoutput>
		<cfquery name="ctOtherIdType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			SELECT distinct(other_id_type) FROM ctColl_Other_id_type order by other_id_type
	    </cfquery>
		<form name="s" method="get" action="getRelatedData.cfm">
			<label for="idtype">
				ID Type
			</label>
			<select name="idtype" id="idtype">
				<cfloop query="ctOtherIdType">
					<option <cfif idtype is ctOtherIdType.other_id_type> selected="selected" </cfif>
						value="#other_id_type#">#other_id_type#</option>
				</cfloop>
			</select>
			<label for="idtype">
				ID
			</label>
			<input type="text" name="idval" value="#idval#" id="idval">
			<input type="hidden" name="clickedfrom" value="#clickedfrom#" id="clickedfrom">

			<br>
			<input type="submit" value="go">



		</form>
	<cfquery name="desettings" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			relpick_event,
			relpick_locality,
			relpick_collector
 		from cf_dataentry_settings where username='#session.username#'
	</cfquery>
	<cfquery name="d" datasource="uam_god">
		select
			collecting_event_id,
			locality_id,
			guid,
			scientific_name,
			higher_geog,
			spec_locality,
			verbatim_locality,
			verbatim_date,
			collectors
		from
			flat
		where
			upper(guid)='#ucase(idtype)#:#ucase(trim(idval))#'
		union
		select
			collecting_event_id,
			locality_id,
			guid,
			scientific_name,
			higher_geog,
			spec_locality,
			verbatim_locality,
			verbatim_date,
			collectors
		from
			flat,
			coll_obj_other_id_num
		where
			flat.collection_object_id=coll_obj_other_id_num.collection_object_id and
			coll_obj_other_id_num.other_id_type='#idtype#' and
			upper(coll_obj_other_id_num.display_value)='#ucase(trim(idval))#'
	</cfquery>
	Save to Data Entry....
		<table border>
			<tr>
				<td>Event (collecting_event_id)</td>
				<td>
					<input id="relpick_event"
						<cfif desettings.relpick_event is 1>checked="checked"</cfif>
						type="checkbox" value="#desettings.relpick_event#"
						onchange="saveCheck(this.id,this.checked)">
					</td>
			</tr>
			<tr>
				<td>Locality (locality_id)</td>
				<td>
					<input id="relpick_locality"
						<cfif desettings.relpick_locality is 1>checked="checked"</cfif>
						type="checkbox" value="#desettings.relpick_locality#"
						onchange="saveCheck(this.id,this.checked)">
					</td>
			</tr>
			<tr>
				<td>Collectors</td>
				<td>
					<input id="relpick_collector"
						<cfif desettings.relpick_collector is 1>checked="checked"</cfif>
						type="checkbox" value="#desettings.relpick_collector#"
						onchange="saveCheck(this.id,this.checked)">
					</td>
			</tr>
		</table>
	Check boxes for what you want to save above, then pick a specimen from the table below.
	<table border>
		<tr>
			<th></th>
			<th>GUID</th>
			<th>ID</th>
			<th>Geog</th>
			<th>SpecLocality</th>
			<th>VerbatimLocality</th>
			<th>VerbatimDate</th>
			<th>Collectors</th>
		</tr>
		<cfset i=1>


		<cfloop query="d">
			<input type="hidden" id="cevid_#i#" value="#collecting_event_id#">
			<input type="hidden" id="locid_#i#" value="#locality_id#">
			<input type="hidden" id="colls_#i#" value="#collectors#">
			<tr>
				<td><span class="likeLink" onclick="useThis(#i#)">[&nbsp;use&nbsp;]</span></td>
				<td>#guid#</td>
				<td>#scientific_name#</td>
				<td>#higher_geog#</td>
				<td>#spec_locality#</td>
				<td>#verbatim_locality#</td>
				<td>#verbatim_date#</td>
				<td>#collectors#</td>
			</tr>
			<cfset i=i+1>
		</cfloop>
	</table>
	</cfoutput>