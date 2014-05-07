<!---<cfinclude template="/includes/_frameHeader.cfm">--->
<table width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td rowspan="2" valign="top"><span style="font-size:.85em;font-style:italic;">
			Customize results and downloads. 
			Excessive options adversely affect performance.</span>
		</td>
		<td align="right" nowrap="nowrap">
			<span style="cursor:pointer;color:#2B547E;font-size:.85em;"
				onclick="closeCustom()">Close and Refresh</span>
		</td>
	</tr>
	<tr>
		<td align="right" nowrap="nowrap">
			<span style="cursor:pointer;color:#2B547E;font-size:.85em;"
				onclick="closeCustomNoRefresh()">Close Without Refresh</span>
		</td>
	</tr>
</table>
<table>
	<tr>
		<td style="border:1px solid green;padding:.2em;">
			<span style="font-size:smaller;font-weight:bold">Rows Per Page: </span>
			<select name="displayRows" id="displayRows" onchange="changedisplayRows(this.value);" size="1">
				<option <cfif session.displayRows is "10"> selected </cfif> value="10">10</option>
				<option  <cfif session.displayRows is "20"> selected </cfif> value="20" >20</option>
				<option  <cfif session.displayRows is "50"> selected </cfif> value="50">50</option>
				<option  <cfif session.displayRows is "100"> selected </cfif> value="100">100</option>
			</select>
		</td>
		<td style="border:1px solid green;padding:.2em;">
			<span style="font-size:smaller;font-weight:bold">Row-Removal Option: </span>
			<select name="killRow" id="killRow" onchange="changekillRows(this.value)">
				<option value="0" <cfif session.killRow neq 1> selected="selected" </cfif>>No</option>
				<option value="1" <cfif session.killRow is 1> selected="selected" </cfif>>Yes</option>
			</select>
			<!---
			
			<input type="checkbox" name="killRows" id="killRows" onchange=";changekillRows();" <cfif session.killrow is 1>checked="checked"</cfif>>
			--->
		</td>
	</tr>
</table>
<cfquery name="poss" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select * from ssrch_field_doc where SPECIMEN_RESULTS_COL=1
</cfquery>
<cfquery name="attribute" dbtype="query">
	select * from poss where category='attribute'
</cfquery>

<cfquery name="locality" dbtype="query">
	select * from poss where category='locality' order by disp_order
</cfquery>
<cfquery name="curatorial" dbtype="query">
	select * from poss where category IN ('curatorial','specimen')  order by disp_order
</cfquery>
<cffunction name="displayColumn">
	<cfargument name="cf_variable">
	<cfargument name="resultColList">
	
	<cfset retval = "<tr>">
	<cfset retval = '#retval#<td align="right"><label title="#cf_variable#: #DEFINITION#" for="#cf_variable#">#DISPLAY_TEXT#</label></td>'>
	<cfset retval = '#retval#<td align="left"><input type="checkbox" 
			name="#cf_variable#"
			id="#cf_variable#"'>
	<cfif listfindnocase(resultColList,cf_variable)> 
		<cfset retval = '#retval#checked="checked"'>
	</cfif>
	<cfset retval = '#retval#onchange="if(this.checked==true){crcloo(this.name,''in'')}else{crcloo(this.name,''out'')};"></td></tr>'>
	<cfreturn retval>
</cffunction>
<cfoutput>


<div align="right" style="width:100%;">
<form name="setPrefs" method="post" action="SpecimenResultsPrefs.cfm">
	<input type="hidden" name="action" value="set">

	<table border width="100%">
		<tr>
			<td align="center" valign="top">
				Locality
				<span class="infoLink" onclick="checkAllById('#lcase(valuelist(locality.cf_variable))#')">[check all]</span>
				<span class="infoLink" onclick="uncheckAllById('#lcase(valuelist(locality.cf_variable))#')">[check none]</span>
			</td>
			<td align="center">
				Random
				<span class="infoLink" onclick="checkAllById('#lcase(valuelist(curatorial.cf_variable))#')">[check all]</span>
				<span class="infoLink" onclick="uncheckAllById('#lcase(valuelist(curatorial.cf_variable))#')">[check none]</span>
			</td>
			<td align="center">
				Attributes
				<span class="infoLink" onclick="checkAllById('#lcase(valuelist(attribute.cf_variable))#')">[check all]</span>
				<span class="infoLink" onclick="uncheckAllById('#lcase(valuelist(attribute.cf_variable))#')">[check none]</span>
			</td>
		</tr>
		<tr>
			<td valign="top" align="center" nowrap="nowrap">
				<div style="height:350px; text-align:right; overflow:auto;position:relative;">
			<table cellpadding="0" cellspacing="0" width="100%">
				<cfloop query="locality">
					#displayColumn(cf_variable,session.resultColumnList)#
				</cfloop>
			</table>
				</div>
			</td>
			<td valign="top" align="center" nowrap="nowrap">
				<div style="height:350px; text-align:right; overflow:auto;position:relative;">
			<table cellpadding="0" cellspacing="0" width="100%">
				<cfloop query="curatorial">
					#displayColumn(cf_variable,session.resultColumnList)#					
				</cfloop>
			</table>
				</div>
			</td>
			<td valign="top" align="center" nowrap="nowrap">
				<div style="height:350px; text-align:right; overflow:auto;position:relative;">
			<table cellpadding="0" cellspacing="0" width="100%">
				<cfloop query="attribute">	
					#displayColumn(cf_variable,session.resultColumnList)#			
				</cfloop>
			</table>
				</div>
			</td>
		</tr>
	</table>
</form>
</div>
</cfoutput>