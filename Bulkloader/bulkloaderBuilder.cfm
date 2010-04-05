<cfinclude template="/includes/_header.cfm">
<cfset title="BulkloaderBuilder">
<cfif action is "nothing">
<cfquery name="blt" datasource="uam_god">
	select column_name from user_tab_cols where table_name='BULKLOADER'
	order by internal_column_id
</cfquery>
<cfoutput>
	<cfset everything=valuelist(blt.column_name)>
	<cfset inListItems="">
	<cfset required="COLLECTION_OBJECT_ID,ENTEREDBY,ACCN,TAXON_NAME,NATURE_OF_ID,ID_MADE_BY_AGENT,MADE_DATE,VERBATIM_DATE,BEGAN_DATE,ENDED_DATE,HIGHER_GEOG,SPEC_LOCALITY,VERBATIM_LOCALITY,COLLECTION_CDE,INSTITUTION_ACRONYM,COLL_OBJ_DISPOSITION,CONDITION,COLLECTOR_AGENT_1,COLLECTOR_ROLE_1,PART_NAME_1,PART_CONDITION_1,PART_LOT_COUNT_1,PART_DISPOSITION_1,COLLECTING_METHOD,COLLECTING_SOURCE">
	<cfset inListItems=listappend(inListItems,required)>
	<cfset basicCoords="ORIG_LAT_LONG_UNITS, DATUM,LAT_LONG_REF_SOURCE,MAX_ERROR_DISTANCE,MAX_ERROR_UNITS,GEOREFMETHOD,DETERMINED_BY_AGENT,DETERMINED_DATE,LAT_LONG_REMARKS,VERIFICATIONSTATUS,GPSACCURACY,EXTENT,DATUM">
	<cfset inListItems=listappend(inListItems,basicCoords)>
	<cfset dms="LATDEG,LATMIN,LATSEC,LATDIR,LONGDEG,LONGMIN,LONGSEC,LONGDIR">
	<cfset inListItems=listappend(inListItems,dms)>
	<cfset ddm="LATDEG,DEC_LAT_MIN,LATDIR,LONGDEG,DEC_LONG_MIN,LONGDIR">
	<cfset inListItems=listappend(inListItems,ddm)>
	<cfset dd="DEC_LAT,DEC_LONG">
	<cfset inListItems=listappend(inListItems,dd)>
	<cfset utm="UTM_ZONE,UTM_EW,UTM_NS">
	<cfset inListItems=listappend(inListItems,utm)>
	<cfset n=5>
	<cfset oid="CAT_NUM"> 
	<cfloop from="1" to="#n#" index="i">
		<cfset oid=listappend(oid,"OTHER_ID_NUM_" & i)>
		<cfset oid=listappend(oid,"OTHER_ID_NUM_TYPE_" & i)>	
	</cfloop>
	<cfset inListItems=listappend(inListItems,oid)>
	<cfset n=8>
	<cfset coll=""> 
	<cfloop from="1" to="#n#" index="i">
		<cfset coll=listappend(coll,"COLLECTOR_AGENT_" & i)>
		<cfset coll=listappend(coll,"COLLECTOR_ROLE_" & i)>	
	</cfloop>
	<cfset inListItems=listappend(inListItems,coll)>
	<cfset n=12>
	<cfset part=""> 
	<cfloop from="1" to="#n#" index="i">
		<cfset part=listappend(part,"PART_NAME_" & i)>
		<cfset part=listappend(part,"PART_CONDITION_" & i)>
		<cfset part=listappend(part,"PART_BARCODE_" & i)>
		<cfset part=listappend(part,"PART_CONTAINER_LABEL_" & i)>
		<cfset part=listappend(part,"PART_LOT_COUNT_" & i)>
		<cfset part=listappend(part,"PART_DISPOSITION_" & i)>
		<cfset part=listappend(part,"PART_REMARK_" & i)>	
	</cfloop>
	<cfset inListItems=listappend(inListItems,part)>
	<cfset n=10>
	<cfset attr=""> 
	<cfloop from="1" to="#n#" index="i">
		<cfset attr=listappend(attr,"ATTRIBUTE_" & i)>
		<cfset attr=listappend(attr,"ATTRIBUTE_VALUE_" & i)>
		<cfset attr=listappend(attr,"ATTRIBUTE_UNITS_" & i)>
		<cfset attr=listappend(attr,"ATTRIBUTE_REMARKS_" & i)>
		<cfset attr=listappend(attr,"ATTRIBUTE_DATE_" & i)>
		<cfset attr=listappend(attr,"ATTRIBUTE_DET_METH_" & i)>
		<cfset attr=listappend(attr,"ATTRIBUTE_DETERMINER_" & i)>
	</cfloop>
	<cfset inListItems=listappend(inListItems,attr)>
	<cfset n=6>
	<cfset geol=""> 
	<cfloop from="1" to="#n#" index="i">
		<cfset geol=listappend(geol,"GEOLOGY_ATTRIBUTE_" & i)>
		<cfset geol=listappend(geol,"GEO_ATT_VALUE_" & i)>
		<cfset geol=listappend(geol,"GEO_ATT_DETERMINER_" & i)>
		<cfset geol=listappend(geol,"GEO_ATT_DETERMINED_DATE_" & i)>
		<cfset geol=listappend(geol,"GEO_ATT_DETERMINED_METHOD_" & i)>
		<cfset geol=listappend(geol,"GEO_ATT_REMARK_" & i)>
	</cfloop>
	<cfset inListItems=listappend(inListItems,geol)>
	<cfset leftovers=everything>
	<cfloop list="#inListItems#" index="thisElement">
		<cfset lPos=listfind(leftovers,thisElement)>
		<cfif lPos gt 0>
			<cfset leftovers=listdeleteat(leftovers,lPos)>
		</cfif>
	</cfloop>
<p>
	Build your own Bulkloader template.	
	You may toggle groups and individual items on and off.
</p>
<form name="controls" id="controls">
<table border>
	<tr>
		<td>Group</td>
		<td>
			<span class="likeLink" onclick="checkAll(1)">All On</span>
			<br><span class="likeLink" onclick="checkAll(0)">All Off</span>
		</td>
	</tr>
	<tr>
		<td>Required</td>
		<td><input type="checkbox" name="required" onchange="checkList(this.name, this.checked)"></td>
	</tr>
	<tr>
		<td>Coordinate Meta</td>
		<td><input type="checkbox" name="basicCoords" onchange="checkList(this.name, this.checked)"></td>
	</tr>
	<tr>
		<td>DMS Coordinates</td>
		<td><input type="checkbox" name="dms" onchange="checkList(this.name, this.checked)"></td>
	</tr>
	<tr>
		<td>DM.m Coordinates</td>
		<td><input type="checkbox" name="ddm" onchange="checkList(this.name, this.checked)"></td>
	</tr>
	<tr>
		<td>D.d Coordinates</td>
		<td><input type="checkbox" name="dd" onchange="checkList(this.name, this.checked)"></td>
	</tr>
	<tr>
		<td>UTM Coordinates</td>
		<td><input type="checkbox" name="utm" onchange="checkList(this.name, this.checked)"></td>
	</tr>
	<tr>
		<td>Identifiers</td>
		<td><input type="checkbox" name="oid" onchange="checkList(this.name, this.checked)"></td>
	</tr>
	<tr>
		<td>Agents</td>
		<td><input type="checkbox" name="coll" onchange="checkList(this.name, this.checked)"></td>
	</tr>
	<tr>
		<td>Parts</td>
		<td><input type="checkbox" name="part" onchange="checkList(this.name, this.checked)"></td>
	</tr>
	<tr>
		<td>Attributes</td>
		<td><input type="checkbox" name="attr" onchange="checkList(this.name, this.checked)"></td>
	</tr>
	<tr>
		<td>Geology</td>
		<td><input type="checkbox" name="geol" onchange="checkList(this.name, this.checked)"></td>
	</tr>
	<tr>
		<td>The Rest</td>
		<td><input type="checkbox" name="leftovers" onchange="checkList(this.name, this.checked)"></td>
	</tr>
</table>
</form>
<script>
	var l_everything='#everything#';
	var l_required='#required#';
	var l_basicCoords='#basicCoords#';
	var l_dms='#dms#';
	var l_ddm='#ddm#';
	var l_dd='#dd#';
	var l_utm='#utm#';
	var l_oid='#oid#';
	var l_coll='#coll#';
	var l_part='#part#';
	var l_attr='#attr#';
	var l_geol='#geol#';
	var l_leftovers='#leftovers#';
	
	function checkAll(v){
		var radios = document.getElementById ('controls');
		if (radios) {
			var inputs = radios.getElementsByTagName ('input');
				if (inputs) {
					for (var i = 0; i < inputs.length; ++i) {
		        		inputs[i].checked = inputs[i].value == v;
		        		//console.log('checkAll: ' + inputs[i].name + ' ' + v);
		        		checkList(inputs[i].name,v);
		  			}
				}
		}
	}
	function checkList(list, v) {
		//console.log('i am checklist');
		var theList=eval('l_' + list);
		var a = theList.split(',');
		for (i=0; i<a.length; ++i) {
			//console.log('i: ' + i);
			//alert(eid);
			if (document.getElementById(a[i])) {
				//alert(eid);
				if (v=='1'){
					document.getElementById(a[i]).checked=true;
				} else {
					document.getElementById(a[i]).checked=false;
				}
			}
		}
		var cStr=eval('document.controls.' + list);
		
		if (v=='1'){
			cStr.checked=true;
		} else {
			cStr.checked=false;
		}
	}
</script>
	<form name="f" method="post" action="bulkloaderBuilder.cfm">
		<input type="hidden" name="action" value="getTemplate">
		<label for="fileFormat">Format</label>
		<select name="fileFormat" id="fileFormat">
			<option value="txt">Tab-delimited text</option>
			<option value="csv">CSV</option>
		</select>
		<input type="submit" value="Download Template">
		<table border>
			<tr>
				<td>Field</td>
				<td>Include?</td>
			</tr>
		<cfloop query="blt">
			<tr>
				<td>#column_name#</td>
				<td><input type="checkbox" name="fld" id="#column_name#" value="#column_name#"></td>
			</tr> 
		</cfloop>
		</table>
	</form>
	<script>
		checkAll(0);
		checkList('required',1);
	</script>
</cfoutput>
</cfif>
<cfif action is 'getTemplate'>
<cfoutput>
	<cfset fileDir = "#Application.webDirectory#">
		<cfif #fileFormat# is "csv">
			<cfset fileName = "CustomBulkloaderTemplate.csv">
			<cfset header=#trim(fld)#>
			<cffile action="write" file="#Application.webDirectory#/download/#fileName#" addnewline="yes" output="#header#">
			<cflocation url="/download.cfm?file=#fileName#" addtoken="false">
			<a href="/download/#fileName#">Click here if your file does not automatically download.</a>
		<cfelseif #fileFormat# is "txt">
			<cfset fileName = "CustomBulkloaderTemplate.txt">
			<cfset header = replace(fld,",","#chr(9)#","all")>
			<cfset header=#trim(header)#>
			<cffile action="write" file="#Application.webDirectory#/download/#fileName#" addnewline="yes" output="#header#">
			<cflocation url="/download.cfm?file=#fileName#" addtoken="false">
			<a href="/download/#fileName#">Click here if your file does not automatically download.</a>
		<cfelse>
			That file format doesn't seem to be supported yet!
		</cfif>
</cfoutput>
</cfif>