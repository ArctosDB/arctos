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
	select * from cf_spec_res_cols order by column_name
</cfquery>
<cfquery name="attribute" dbtype="query">
	select * from poss where category='attribute'
</cfquery>

<cfquery name="locality" dbtype="query">
	select * from poss where category='locality'
</cfquery>
<cfquery name="curatorial" dbtype="query">
	select * from poss where category IN ('curatorial','specimen')
</cfquery>
<cffunction name="displayColumn">
	<cfargument name="column_name">
	<cfargument name="resultColList">
	<cfif left(column_name,1) is "_">
		<cfset cname=right(column_name,len(column_name)-1)>
	<cfelse>
		<cfset cname=column_name>
	</cfif>
	<cfset retval = "<tr>">
	<cfset retval = '#retval#<td align="right"><label for="#lcase(column_name)#">#cname#</label></td>'>
	<cfset retval = '#retval#<td align="left"><input type="checkbox" 
			name="#column_name#"
			id="#lcase(column_name)#"'>
	<cfif listfindnocase(resultColList,column_name)> 
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
				<span class="infoLink" onclick="checkAllById('#lcase(valuelist(locality.column_name))#')">[check all]</span>
				<span class="infoLink" onclick="uncheckAllById('#lcase(valuelist(locality.column_name))#')">[check none]</span>
			</td>
			<td align="center">
				Random
				<span class="infoLink" onclick="checkAllById('#lcase(valuelist(curatorial.column_name))#')">[check all]</span>
				<span class="infoLink" onclick="uncheckAllById('#lcase(valuelist(curatorial.column_name))#')">[check none]</span>
			</td>
			<td align="center">
				Attributes
				<span class="infoLink" onclick="checkAllById('#lcase(valuelist(attribute.column_name))#')">[check all]</span>
				<span class="infoLink" onclick="uncheckAllById('#lcase(valuelist(attribute.column_name))#')">[check none]</span>
			</td>
		</tr>
		<tr>
			<td valign="top" align="center" nowrap="nowrap">
				<div style="height:350px; text-align:right; overflow:auto;position:relative;">
			<table cellpadding="0" cellspacing="0" width="100%">
				<cfloop query="locality">
					#displayColumn(column_name,session.resultColumnList)#
				</cfloop>
			</table>
				</div>
			</td>
			<td valign="top" align="center" nowrap="nowrap">
				<div style="height:350px; text-align:right; overflow:auto;position:relative;">
			<table cellpadding="0" cellspacing="0" width="100%">
				<cfloop query="curatorial">
					#displayColumn(column_name,session.resultColumnList)#					
				</cfloop>
			</table>
				</div>
			</td>
			<td valign="top" align="center" nowrap="nowrap">
				<div style="height:350px; text-align:right; overflow:auto;position:relative;">
			<table cellpadding="0" cellspacing="0" width="100%">
				<cfloop query="attribute">	
					#displayColumn(column_name,session.resultColumnList)#			
				</cfloop>
			</table>
				</div>
			</td>
		</tr>
	</table>
</form>
</div>
</cfoutput>