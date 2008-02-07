<cfinclude template="/includes/functionLib.cfm">
<cfset s = "here's a ">
<cfset s = '#s# "string"'>
<cfoutput >
	<br>s:#s#
	<br>fcn<input type="text" value="#stripQuotes(s)#">
	<br>39: #chr(39)#
	<br>34: #chr(34)#
<br>double<input type="text" value="#s#">
<br>none<input type=text value=#s#>
<cfset s = replace(s,"#chr(34)#","&quot;","all")>

<br>replace 34, quot w double<input name="bla" type="text" value="#s#">

</cfoutput>