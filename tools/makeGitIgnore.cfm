<!---- barf out the contents of a .gitignore file ---->
<cfoutput>

<cfset static=".project,*.gz,*.xml">


<cfquery  name="coll" datasource="cf_dbuser">
	select * from cf_collection where PUBLIC_PORTAL_FG = 1
</cfquery>
<cfdump var="#coll#">

<!----
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
	---->
</cfoutput>



