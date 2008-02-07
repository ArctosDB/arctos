<!--- 
	builds links to institution-specific pages 
	Run daily and at setup
--->
<cfquery  name="coll" datasource="#Application.web_user#">
	select * from collection
</cfquery>
<cfoutput >
	<cfloop query="coll">
		<cfset coll_dir_name = "#lcase(institution_acronym)#_#lcase(collection_cde)#">
		<cfset cDir = "#Application.webDirectory#/#coll_dir_name#">
		<cfif NOT DirectoryExists("#cDir#")>
			<cfdirectory action = "create" directory = "#cDir#" >
		</cfif>
		<!--- just rebuild guts --->
		<cfset fc = "<cfset client.exclusive_collection_id = ""#collection_id#"">
			<cflocation url=""/SpecimenSearch.cfm"">">
		<cffile action="write" file="#cDir#/index.cfm" nameconflict="overwrite" output="#fc#">
	</cfloop>
</cfoutput>