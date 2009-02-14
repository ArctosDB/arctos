<!--- 
	builds links to institution-specific pages 
	Run daily and at setup
--->
<cfquery  name="coll" datasource="cf_dbuser">
	select * from cf_collection
</cfquery>
<cfdump var="#coll#">
<cfoutput>
	<cfloop query="coll">
		<cfset coll_dir_name = "#lcase(portal_name)#">
		<cfset cDir = "#Application.webDirectory#/#coll_dir_name#">
		<cfif NOT DirectoryExists("#cDir#")>
			<cfdirectory action = "create" directory = "#cDir#" >
		</cfif>
		<!--- just rebuild guts --->
		<cfset fc = '<cfinclude template="/includes/functionLib.cfm">
			<cfset setDbUser(#cf_collection_id#)>
			<cflocation url="/SpecimenSearch.cfm">'>
		<cffile action="write" file="#cDir#/index.cfm" nameconflict="overwrite" output="#fc#">
	</cfloop>
</cfoutput>