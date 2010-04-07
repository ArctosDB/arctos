<cfinclude template="/includes/_frameHeader.cfm">
<cfif #action# is "nothing">
<table width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td rowspan="2" valign="top"><span style="font-size:.85em;font-style:italic;">Check fields to show them in your results and downloads. Uncheck to remove. Adding too much here will adversely affect performance.</span></td>
		<td align="right" nowrap="nowrap">
			<span style="cursor:pointer;color:#2B547E;font-size:.85em;"
				onclick="closeCustom()">Close and Refresh Data</span>
		</td>
	</tr>
	<tr>
		<td align="right" nowrap="nowrap">
			<span style="cursor:pointer;color:#2B547E;font-size:.85em;"
				onclick="closeCustomNoRefresh()">Close Without Refresh</span>
		</td>
	</tr>
</table>
<cfquery name="poss" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
	<cfset retval = '#retval#<td><label for="#lcase(column_name)#">#cname#</label></td>'>
	<cfset retval = '#retval#<td><input type="checkbox" 
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
			<table cellpadding="0" cellspacing="0">
				<cfloop query="locality">
					#displayColumn(column_name,session.resultColumnList)#
				</cfloop>
			</table>
				</div>
			</td>
			<td valign="top" align="center" nowrap="nowrap">
				<div style="height:350px; text-align:right; overflow:auto;position:relative;">
			<table cellpadding="0" cellspacing="0">
				<cfloop query="curatorial">
					#displayColumn(column_name,session.resultColumnList)#					
				</cfloop>
			</table>
				</div>
			</td>
			<td valign="top" align="center" nowrap="nowrap">
				<div style="height:350px; text-align:right; overflow:auto;position:relative;">
			<table cellpadding="0" cellspacing="0">
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
</cfif>