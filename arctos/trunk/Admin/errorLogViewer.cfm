<cfinclude template="/includes/_header.cfm">

<cfif not isdefined("log")>
	<cfset log="log">
</cfif>
<a href="errorLogViewer.cfm?log=log">log</a>
<a href="errorLogViewer.cfm?log=404log">404log</a>
<a href="errorLogViewer.cfm?log=missingGUIDlog">missingGUIDlog</a>
<a href="errorLogViewer.cfm?log=blacklistlog">blacklistlog</a>
<a href="errorLogViewer.cfm?log=emaillog">emaillog</a>



<cfoutput>


<iframe src="xmlView.cfm?log=#log#">

</iframe>




</cfoutput>
<!----
<cfoutput>	
	<cfset x=xmlparse("<logs>" & logtxt & "</logs>")>
	<cfdump var=#x#>
</cfoutput>
------>
<cfinclude template="/includes/_footer.cfm">
