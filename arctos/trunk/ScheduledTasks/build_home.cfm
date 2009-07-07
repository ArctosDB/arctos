<!--- 
	builds links to institution-specific pages 
	Run daily and at setup
--->
<cfquery  name="coll" datasource="cf_dbuser">
	select * from cf_collection where PUBLIC_PORTAL_FG is 1
</cfquery>
<cfdump var="#coll#">
<cfoutput>
	<cfloop query="coll">
		<cfif len(portal_name) gt 0>
			<cfset coll_dir_name = "#lcase(portal_name)#">
			<cfset cDir = "#Application.webDirectory#/#coll_dir_name#">
			<cfif NOT DirectoryExists("#cDir#")>
				<cfdirectory action = "create" directory = "#cDir#" >
			</cfif>
			<!--- just rebuild guts --->
			<cfset fc = '<cfinclude template="/includes/functionLib.cfm">
				<cfset setDbUser(#cf_collection_id#)>
				<cflocation url="/SpecimenSearch.cfm" addtoken="false">'>
			<cffile action="write" file="#cDir#/index.cfm" nameconflict="overwrite" output="#fc#">
		</cfif>
	</cfloop>
</cfoutput>