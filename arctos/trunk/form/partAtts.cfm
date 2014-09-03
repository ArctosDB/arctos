<cfinclude template="/includes/_pickHeader.cfm">
<cffunction name="getPartAttrSelect">
	<cfargument name="u_or_v" type="string">
	<cfargument name="patype" type="string">
	<cfargument name="val" type="string">
	<cfargument name="paid" type="numeric">
	<cfoutput>
		<cfset rv="">
		<cfquery name="k" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from ctspec_part_att_att where attribute_type='#patype#'
		</cfquery>
		<cfif u_or_v is "v">
			<cfif len(k.VALUE_code_table) gt 0>
				<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select * from #k.VALUE_code_table#
				</cfquery>
				<cfloop list="#d.columnlist#" index="i">
					<cfif i is not "description" and i is not "collection_cde">
						<cfquery name="r" dbtype="query">
							select #i# d from d order by #i#
						</cfquery>
					</cfif>
				</cfloop>
				<cfsavecontent variable="rv">
					<select name="attribute_value_#paid#">
						<cfloop query="r">
							<option <cfif val is r.d>selected="selected" </cfif> value="#r.d#">#r.d#</option>
						</cfloop>
					</select>
				</cfsavecontent>
			<cfelse>
				<cfsavecontent variable="rv">
					<input name="attribute_value_#paid#" value="#val#">
				</cfsavecontent>
			</cfif>
		<cfelseif u_or_v is "u">
			<cfif len(k.unit_code_table) gt 0>
				<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select * from #k.unit_code_table#
				</cfquery>
				<cfloop list="#d.columnlist#" index="i">
					<cfif i is not "description" and i is not "collection_cde">
						<cfquery name="r" dbtype="query">
							select #i# d from d order by #i#
						</cfquery>
					</cfif>
				</cfloop>
				<cfsavecontent variable="rv">
					<select name="attribute_units_#paid#">
						<cfloop query="r">
							<option <cfif val is r.d>selected="selected" </cfif> value="#r.d#">#r.d#</option>
						</cfloop>
					</select>
				</cfsavecontent>
			</cfif>
		</cfif>
	</cfoutput>
	<cfreturn rv>
</cffunction>
<cfif action is "nothing">
<script>
	jQuery(document).ready(function() {
		$("#determined_date_new").datepicker();
	});
</script>
<cfoutput>
	<cfquery name="ctspecpart_attribute_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select attribute_type from ctspecpart_attribute_type order by attribute_type
	</cfquery>

	<cfquery name="pAtt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			 part_attribute_id,
			 attribute_type,
			 attribute_value,
			 attribute_units,
			 determined_date,
			 determined_by_agent_id,
			 attribute_remark,
			 agent_name
		from
			specimen_part_attribute,
			preferred_agent_name
		where
			specimen_part_attribute.determined_by_agent_id=preferred_agent_name.agent_id (+) and
			collection_object_id=#partID#
	</cfquery>	
	<form name="f" method="post" action="partAtts.cfm">
		<input type="hidden" name="partID" value="#partID#">
		<input type="hidden" name="action">
	<table border>
		<tr>
			<th>Attribute</th>
			<th>Value</th>
			<th>Units</th>
			<th>Date</th>
			<th>DeterminedBy</th>
			<th>Remark</th>
			<th>Delete?</th>
		</tr>
		<cfset np=1>
		<cfloop query="pAtt">
			<tr id="r_#part_attribute_id#">
				<td>#attribute_type#</td>
				<td id="v_#part_attribute_id#">
					#getPartAttrSelect('v',attribute_type,attribute_value,part_attribute_id)#
				</td>
				<td id="u_#part_attribute_id#">
					#getPartAttrSelect('u',attribute_type,attribute_units,part_attribute_id)#
				</td>
				<td>
					<input type="text" name="determined_date_#part_attribute_id#" value="#dateformat(determined_date,"yyyy-mm-dd")#">
				</td>
				<td>
					<input type="hidden" name="determined_by_agent_id_#part_attribute_id#">
					<input type="text" name="determined_agent_#part_attribute_id#" id="determined_agent_#part_attribute_id#"
						onchange="getAgent('determined_by_agent_id_#part_attribute_id#',this.id,'f',this.value);" 
						onkeypress="return noenter(event);"
						value="#agent_name#">
					</td>
				<td>
					<input type="text" name="attribute_remark_#part_attribute_id#" value="#attribute_remark#">
				</td>
				<td>
					<input type="checkbox" name="delete_#part_attribute_id#" value="1">
				</td>
			</tr>
			<cfset np=np+1>
		</cfloop>
		<input type="hidden" name="patidlist" value="#valuelist(pAtt.part_attribute_id)#">
		<cfset np=np-1>
		<input type="hidden" name="numPAtt" value="#np#">	
		<tr>
			<td colspan="6" align="center">
				<input type="button" onclick="f.action.value='saveEdit';submit();" value="Save Edits" class="savBtn">
				<input type="button" onclick="closePartAtts();" value="Close Window" class="qutBtn">
			</td>
		</tr>
		<tr id="r_new" class="newRec">
			<td>
				<select id="attribute_type_new" name="attribute_type_new" onchange="setPartAttOptions('new',this.value)">
					<option value="">Create New Part Attribute....</option>
					<cfloop query="ctspecpart_attribute_type">
						<option value="#attribute_type#">#attribute_type#</option>
					</cfloop>
				</select>
			</td>
			<td id="v_new">
				<INPut type="hidden" name="attribute_value_new">
			</td>
			<td id="u_new">
				<input type="hidden" name="attribute_units_new">
			</td>
			<td id="d_new">
				<input type="text" name="determined_date_new" id="determined_date_new">
			</td>
			<td id="a_new">
				<input type="hidden" name="determined_id_new" id="determined_id_new">
				<input type="text" name="determined_agent_new" id="determined_agent_new"
					onchange="getAgent('determined_id_new',this.id,'f',this.value);" onkeypress="return noenter(event);">
			</td>
			<td id="r_new">
				<input type="text" name="attribute_remark_new" id="attribute_remark_new">
			</td>
			<td>
				<input type="button" onclick="f.action.value='insPart';submit();" class="insBtn" value="Create">
			</td>
		</tr>
	</table>
	</form>
</cfoutput>	
</cfif>
<cfif action is "insPart">
	<cfif not isdefined("attribute_value_new")>
		<cfset attribute_value_new="">
	</cfif>
	<cfif not isdefined("attribute_units_new")>
		<cfset attribute_units_new="">
	</cfif>
	<cfquery name="k" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		insert into specimen_part_attribute (
			collection_object_id,
			attribute_type,
			attribute_value,
			attribute_units,
			determined_date,
			determined_by_agent_id,
			attribute_remark
		) values (
			#partID#,
			'#attribute_type_new#',
			'#attribute_value_new#',
			'#attribute_units_new#',
			'#determined_date_new#',
			'#determined_id_new#',
			'#attribute_remark_new#'
		)	
	</cfquery>
	<cflocation url="partAtts.cfm?partID=#partID#" addtoken="false">
</cfif>
<cfif action is "saveEdit">
	<cfdump var="#form#">
	<cfoutput>
		<cftransaction>
		<cfloop from="1" to="#listlen(patidlist)#" index="i">
			<cfset thisPartAtId=listgetat(patidlist,i)>
			<cftry>
				<cfset thisDeleteFlag=evaluate("delete_" & thisPartAtId)>
				<cfcatch>
					<cfset thisDeleteFlag="">
				</cfcatch>
			</cftry>
			<cftry>
				<cfset thisAttributeUnits=evaluate("attribute_units_" & thisPartAtId)>
				<cfcatch>
					<cfset thisAttributeUnits="">
				</cfcatch>
			</cftry>
			<cfset thisAttributeRemark=evaluate("attribute_remark_" & thisPartAtId)>
			<cfset thisAttributeValue=evaluate("attribute_value_" & thisPartAtId)>
			<cfset thisDeterminerId=evaluate("determined_by_agent_id_" & thisPartAtId)>
			<cfset thisDate=evaluate("determined_date_" & thisPartAtId)>
			<cfif thisDeleteFlag is 1>
				<cfquery name="k" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					delete from specimen_part_attribute where part_attribute_id=#thisPartAtId#
				</cfquery>
			<cfelse>
				<cfquery name="k" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update specimen_part_attribute set
						attribute_units='#thisAttributeUnits#',
						attribute_remark='#thisAttributeRemark#',
						attribute_value='#thisAttributeValue#',
						determined_by_agent_id='#thisDeterminerId#',
						determined_date='#thisDate#'
					where part_attribute_id=#thisPartAtId#
				</cfquery>
			</cfif>
		</cfloop>
		</cftransaction>
		<cflocation url="partAtts.cfm?partID=#partID#" addtoken="false">
	</cfoutput>
</cfif>