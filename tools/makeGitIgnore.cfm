<!---- barf out the contents of a .gitignore file ---->
<cfoutput>

<cfset static=".project,*.gz,*.xml">


<cfquery  name="coll" datasource="cf_dbuser">
	select lower(portal_name) pname from cf_collection where PUBLIC_PORTAL_FG = 1 and portal_name is not null
</cfquery>
<cfset colnFldrs=valuelist(coll.pname)>


<cfdump var=#colnFldrs#>


</cfoutput>



