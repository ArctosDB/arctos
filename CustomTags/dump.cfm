<!--- 

CF_Dump.cfm v1.3
Part of the SmartObjects framework -- providing an Object Oriented foundation for CFML.
For more information, visit http://www.smart-objects.com

This tag dumps any variable or nested structure of variables to the screen using 
expanding DHTML tables.  Currently tested only on IE.

<CF_Dump variable="Application">

	variable : name of the variable in the caller's scope to be dumped.
               Alternatively, the shorthand v="name" can be used to 
			   accomplish the same task.

Version 1.3
* Added WDDX Lookup (long overdue)

Version 1.2  
* Removed dependancy on common javascript file in /common/scripts/spinner.js
  
Version 1.1  
* Added expandable DHTML controls.
  
Version 1.0  
* Custom tag dumps plain variables, arrays, structures, and queries.  Super cool!


--->

<cfif IsDefined("Attributes.v")>
	<cfset var = Evaluate("Caller." & Attributes.v)>
<cfelseif IsDefined("Attributes.variable")>
	<cfset var = Evaluate("Caller." & Attributes.variable)>
	<cfset Attributes.v = Attributes.variable>
<cfelse>
	<cfthrow type="SmartObjects.CF_Dump.MissingAttribute.Variable" message="CF_Dump: Required Attribute &quot;variable&quot; not defined">
</cfif>

<cfoutput>

	<script>
		<!--
		function spinner(spinner, division, icon)
		{
			if (spinner)
			{
				if (spinner.status)
				{
					spinner.status = false;
					division.style.display ='none';
					spinner.src = '/common/images/spinner/' + icon + '_up.gif';
				}
				else
				{
					spinner.status = true;
					division.style.display ='';
					spinner.src = '/common/images/spinner/' + icon + '_dn.gif';
				}
			}
		}	
		-->		
	</script>

	<cfif ListValueCountNoCase(GetBaseTagList(), "CF_Dump") IS 1>
		<p>
		<b>#Attributes.v# = </b>
	</cfif>
	
	<cfset id = Replace(CreateUUID(), "-", "_", "ALL")>
	
	<cfif IsQuery(var)>
	
		<table width="100%" border="1" cellspacing="0" cellpadding="3">
			<tr bgcolor="eeeeee">
				<td colspan="#ListLen(var.ColumnList)#">
					<a href="javascript:spinner(window.document.spinner_#id#, id_#id#, 'white')"
					><img 
						src="/common/images/spinner/white_up.gif" 
						name="spinner_#id#"
						height="15"
						width="15"
						border="0"
					></a>
					<b>QUERY with #ListLen(var.ColumnList)# fields and #var.RecordCount# records</b>
				</td>
			</tr>

			<tr><td>

				<div id="id_#id#" style="display:none;">

					<table width="100%" border="1" cellspacing="0" cellpadding="3">
						<tr>
							<cfloop index="i" list="#var.columnlist#">
								<td><font face="Arial" size="2">#i#</font></td>
							</cfloop>
						</tr>
				
						<cfloop index="i" from="1" to="#var.RecordCount#">
							<tr>
								<cfloop index="j" list="#var.columnlist#">
									<td valign="top" align="left"><font face="Arial" size="1">#HTMLEditFormat(Evaluate("var." & j & "[i]"))#</font>&nbsp;</td>
								</cfloop>
							</tr>
						</cfloop>
					</table>
				</div>
				
			</td></tr>
			
		</table>
		
	<cfelseif IsStruct(var)>
	
		<table width="100%" border="1" cellspacing="0" cellpadding="3">
			<tr bgcolor="eeeeee">
				<td colspan="2">
					<a href="javascript:spinner(window.document.spinner_#id#, id_#id#, 'white')"
					><img 
						src="/common/images/spinner/white_up.gif" 
						name="spinner_#id#"
						height="15"
						width="15"
						border="0"
					></a>
					<b>STRUCTURE with #StructCount(var)# elements</b>
				</td>
			</tr>
			<tr><td>
				<div id="id_#id#" style="display:none;">
					<table width="100%" border="1" cellspacing="0" cellpadding="3">
						<cfloop item="i" collection="#var#">
							<tr>
								<td nowrap valign="top">#i#</td>
								<td valign="top">
									<CF_Dump variable="var['#i#']">
								</td>
							</tr>
						</cfloop>
					</table>
				</div>
			</td></tr>
		</table>

	<cfelseif IsArray(var)>
	
		<table width="100%" border="1" cellspacing="0" cellpadding="3">
			<tr bgcolor="eeeeee">
				<td colspan="2">
					<a href="javascript:spinner(window.document.spinner_#id#, id_#id#, 'white')"
					><img 
						src="/common/images/spinner/white_up.gif" 
						name="spinner_#id#"
						height="15"
						width="15"
						border="0"
					></a>
					<b>ARRAY with #ArrayLen(var)# elements</b>
				</td>
			</tr>
			<tr><td>
				<div id="id_#id#" style="display:none;">
					<table width="100%" border="1" cellspacing="0" cellpadding="3">
						<cfloop index="i" from="1" to="#ArrayLen(var)#">
							<tr>
								<td nowrap valign="top">#i#</td>
								<td valign="top">
									<cftry>
										<CF_Dump variable="var[#i#]">
										<cfcatch type="Any">&nbsp;</cfcatch>
									</cftry>
								</td>
							</tr>
						</cfloop>
					</table>
				</div>
			</td></tr>
		</table>

	<!--- Attribute is a normal scalar value --->
	<cfelse>
		&quot;#HTMLEditFormat(var)#&quot;
		
		<!--- Output WDDX if possible --->
		<cftry>
			<cfwddx action="WDDX2CFML" input="#var#" output="wddx">
			<br><b>This Is A WDDX Variable</b>
			<CF_Dump variable="wddx">
			<cfcatch type="ANY"></cfcatch>
		</cftry>
	</cfif>

</cfoutput>

