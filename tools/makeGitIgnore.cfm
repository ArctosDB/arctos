<!---- barf out the contents of a .gitignore file ---->
<cfoutput>

<cfset ignorefiles=".project,*.gz,*.xml,.git,robots.txt,">
<cfset ignorefolders="mediaUploads/,temp/,/bnhmMaps/tabfiles/,cache/,download/,sandbox/">



<cfquery  name="coll" datasource="cf_dbuser">
	select lower(portal_name) pname from cf_collection where PUBLIC_PORTAL_FG = 1 and portal_name is not null
</cfquery>
<cfset colnFldrs=valuelist(coll.pname)>


<cfset allIgnore="">
<cfset allIgnore=listappend(allIgnore,ignorefiles)>
<cfset allIgnore=listappend(allIgnore,ignorefolders)>
<cfset allIgnore=listappend(allIgnore,colnFldrs)>

<cfset allIgnore=listChangeDelims(allIgnore,chr(10))>


<textarea>#allIgnore#</textarea>
</cfoutput>



