<cfset title="SVN">
<cfinclude template="/includes/_header.cfm">

	<cfexecute name="#Application.svn#"
		arguments="info #Application.webDirectory#" 
		timeout="30"
		variable="result"/> 
				
	<cfoutput>
		<h2>Current Environment</h2>
		
		<cfset result = replace(result,"#chr(10)#","<br>","all")>
		<p>#result#</p>
		<p>
			<h3>Tools</h3>
			<a href="svn.cfm?action=updateSubversion">Update Subversion</a>
		</p>
	</cfoutput>
<!---------------------------------->
<cfif #action# is "updateSubversion">
	<cfexecute name="#Application.svn#"
		arguments="up #Application.webDirectory#" 
		timeout="30"/> 
	<cflocation url="svn.cfm">
</cfif>
<!---------------------------------->
<cfinclude template="/includes/_footer.cfm">