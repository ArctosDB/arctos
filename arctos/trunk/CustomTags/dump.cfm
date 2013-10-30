<!----

this produces a table


<cfif IsDefined("Attributes.v")><cfset var = Evaluate("Caller." & Attributes.v)><cfelseif IsDefined("Attributes.variable")>
<cfset var = Evaluate("Caller." & Attributes.variable)><cfset Attributes.v = Attributes.variable><cfelse>
<cfthrow type="SmartObjects.CF_Dump.MissingAttribute.Variable" message="CF_Dump: Required Attribute &quot;variable&quot; not defined"></cfif>
<cfoutput><cfif IsQuery(var)><table width="100%" border="1" cellspacing="0" cellpadding="3"><tr>
<td colspan="#ListLen(var.ColumnList)#"><b>QUERY with #ListLen(var.ColumnList)# fields and #var.RecordCount# records</b></td>
</tr><tr><td><table width="100%" border="1" cellspacing="0" cellpadding="3"><tr>
<cfloop index="i" list="#var.columnlist#"><td>#trim(i)#</td></cfloop></tr>
<cfloop index="i" from="1" to="#var.RecordCount#"><tr><cfloop index="j" list="#var.columnlist#">
<td valign="top" align="left">#trim(HTMLEditFormat(Evaluate("var." & j & "[i]")))#</td></cfloop></tr></cfloop></table>
</td></tr></table><cfelseif IsStruct(var)><table width="100%" border="1" cellspacing="0" cellpadding="3">
<tr bgcolor="eeeeee"><td colspan="2"><b>STRUCTURE with #StructCount(var)# elements</b></td></tr><tr><td>
<table width="100%" border="1" cellspacing="0" cellpadding="3"><cfloop item="i" collection="#var#"><tr>
<td nowrap valign="top">#trim(i)#</td><td valign="top"><CF_Dump variable="var['#i#']"></td></tr></cfloop>
</table></td></tr></table><cfelseif IsArray(var)><table width="100%" border="1" cellspacing="0" cellpadding="3">
<tr bgcolor="eeeeee"><td colspan="2"><b>ARRAY with #ArrayLen(var)# elements</b></td>
</tr><tr><td><table width="100%" border="1" cellspacing="0" cellpadding="3">
<cfloop index="i" from="1" to="#ArrayLen(var)#"><tr><td nowrap valign="top">#trim(i)#</td><td valign="top"><cftry>
<CF_Dump variable="var[#i#]"><cfcatch type="Any">&nbsp;</cfcatch></cftry></td></tr></cfloop>
</table></td></tr></table><cfelse>#trim(HTMLEditFormat(var))#</cfif></cfoutput>


-------->



<cfif IsDefined("Attributes.v")><cfset var = Evaluate("Caller." & Attributes.v)><cfelseif IsDefined("Attributes.variable")>
<cfset var = Evaluate("Caller." & Attributes.variable)><cfset Attributes.v = Attributes.variable><cfelse>
<cfthrow type="SmartObjects.CF_Dump.MissingAttribute.Variable" message="CF_Dump: Required Attribute &quot;variable&quot; not defined"></cfif>
<cfoutput>

<cfif IsQuery(var)>
	<cfloop index="i" list="#var.columnlist#">
		asdfasdasfskj  #trim(i)#
	</cfloop>
	<cfloop index="i" from="1" to="#var.RecordCount#">
		<cfloop index="j" list="#var.columnlist#">
 			asdfasgdhgrt  #trim(HTMLEditFormat(Evaluate("var." & j & "[i]")))#
		</cfloop>
	</cfloop>
<cfelseif IsStruct(var)>
	<cfloop item="i" collection="#var#"> 
		<#trim(i)#><CF_Dump variable="var['#i#']"></#trim(i)#>
	</cfloop>
<cfelseif IsArray(var)>
	<cfloop index="i" from="1" to="#ArrayLen(var)#">
		 <#trim(i)#>
		<cftry>
			<CF_Dump variable="var[#i#]">
			<cfcatch type="Any">&nbsp;</cfcatch>
		</cftry>
		</#trim(i)#>
	</cfloop>

<cfelse>
	 khaugbuybfuesvb   #trim(HTMLEditFormat(var))#
</cfif>

</cfoutput>
