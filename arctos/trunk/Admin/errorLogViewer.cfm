<cfinclude template="/includes/_header.cfm">

<script src="https://google-code-prettify.googlecode.com/svn/loader/run_prettify.js?lang=css&amp;lang=ml"></script>


<cfif not isdefined("log")>
	<cfset log="log">
</cfif>
<a href="errorLogViewer.cfm?log=log">log</a>
<a href="errorLogViewer.cfm?log=404log">404log</a>
<a href="errorLogViewer.cfm?log=missingGUIDlog">missingGUIDlog</a>
<a href="errorLogViewer.cfm?log=blacklistlog">blacklistlog</a>
<a href="errorLogViewer.cfm?log=emaillog">emaillog</a>


<cffile action="read" file="#Application.webDirectory#/log/#log#.txt" variable="logtxt">




<cfoutput>


 <pre class="prettyprint lang-xml"><root><test>test</test></root></pre> 

</cfoutput>
<!----
<cfoutput>	
	<cfset x=xmlparse("<logs>" & logtxt & "</logs>")>
	<cfdump var=#x#>
	
	
	<br />#logtxt#
	
	
	
</cfoutput>
------>
<cfinclude template="/includes/_footer.cfm">
