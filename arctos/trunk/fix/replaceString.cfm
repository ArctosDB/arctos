<!----
<cfif #action# is "nothing">
	<form name="r" method="post" action="replaceString.cfm">
		<input type="hidden" name="action" value="repl">
		
		File:
		<input type="text" name="file">
		Old:
		<input type="text" name="oldString">
		New:
		<input type="text" name="newString">
		<input type="submit">
	</form>
</cfif>

<cfif #action# is "repl">
	
</cfif>
<cffile action="read" file="/var/www/html/testFile.cfm" variable="theFile">
<cfset theNewFile = replace(theFile,'datasource="##Application.uam_dbo##">','datasource="user_login" username="##client.username##" password="##decrypt(client.epw,cfid)##">',"all")>
#theFile#
<cffile action="write" file="/var/www/html/someTest.cfm" nameconflict="error" output="#theNewFile#">
<hr><hr>#theNewFile#

<cfoutput>
<cfdirectory directory="/home/fndlm/cfConversion" action="list" name="base">
<cfloop query="base">
	#name#<br>
</cfloop>
</cfoutput>
---->


<cfset initialDir = "/var/www/html/cfConversion">
<cfdirectory directory="#initialDir#" recurse="yes" name="files" sort="directory asc">

<cfset display(files,initialDir)>

<cffunction name="display" returnType="void" output="true">
   <cfargument name="files" type="query" required="true">
   <cfargument name="parent" type="string" required="true">
   <cfset var justMyKids = "">
   
   <cfquery name="justMyKids" dbtype="query">
   select   *
   from   arguments.files
   where   directory = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.parent#">
   order by name
   </cfquery>   
   
   <cfoutput><ul></cfoutput>
   
   <cfoutput query="justMyKids">
     
	  <li> <a href="replaceString.cfm?action=doThisOne&f=#directory#/#name#">#directory#/#name#</a></li>
      <cfif type is "Dir">
        #display(arguments.files, directory & "/" & name)#
      </cfif>
   </cfoutput>
   
   <cfoutput></ul></cfoutput>
   
</cffunction>


<cfif #action# is "doThisOne">
	<cffile action="read" file="#f#" variable="theFile">
<cfset theNewFile = replace(theFile,'datasource="##Application.uam_dbo##">','datasource="user_login" username="##client.username##" password="##decrypt(client.epw,cfid)##">',"all")>

<cffile action="write" file="#f#" nameconflict="overwrite" output="#theNewFile#">
spiffy
</cfif>