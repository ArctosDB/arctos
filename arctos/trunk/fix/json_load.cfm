<cfquery name="data" datasource="#application.web_user#">
	 SELECT  
	 	level,
	 	geology_attribute_hierarchy_id,
	 	parent_id,
		attribute
	FROM
		geology_attribute_hierarchy
	start with parent_id is null
	CONNECT BY PRIOR 
		geology_attribute_hierarchy_id = parent_id
</cfquery>
<cfoutput>
{
	"requestFirstIndex" : 0, 
	"firstIndex" : 0, 
	"count": 22, 
	"totalCount" : 22, 
	"columns":["Title(ID)", "Owner", "Updated"], "items": [
	<cfset i=1>
	<cfset lastLevel=1>
	<cfloop query="data">
		<cfif level is 1 and lastlevel gt 1>
			<cfloop from="1" to="#lastlevel#" index="ll">
				} ]
			</cfloop>
		</cfif>
		<cfif #level# gt 1>
			"children":
		</cfif>
		{ "id":#geology_attribute_hierarchy_id#, "info":["Page Title(#i#)", "#attribute# (#level#)", "2007-06-09 2:44 pm"] 
		<cfif #level# is 1>}</cfif>
		,
		<br>
		
		<cfset lastLevel=level>
		<cfset i=i+1>
	</cfloop>
</cfoutput>
<!---
{ "requestFirstIndex" : 0, "firstIndex" : 0, "count": 22, "totalCount" : 22, "columns":["Title(ID)", "Owner", "Updated"], "items": [
 { "id":1, "info":["Page Title(1)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"] }, 
{ "id":2, "info":["Page Title(2)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"], 
	"children": [ { "id":3, "info":["Page Title(3)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"],
 		"children": [ { "id":4, "info":["Page Title(4)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"] } ] } ] }, 
{ "id":5, "info":["Page Title(5)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"], 
	"children": [ { "id":6, "info":["Page Title(6)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"], 
		"children": [ { "id":7, "info":["Page Title(7)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"] } ] } ] }, 
{ "id":8, "info":["Page Title(8)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"], 
	"children": [ { "id":9, "info":["Page Title(9)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"], "children": [ { "id":10, "info":["Page Title(10)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"] } ] } ] }, { "id":11, "info":["Page Title(11)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"] }, { "id":12, "info":["Page Title(12)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"] }, { "id":13, "info":["Page Title(13)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"] }, { "id":14, "info":["Page Title(14)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"] }, { "id":15, "info":["Page Title(15)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"] }, { "id":16, "info":["Page Title(16)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"] }, { "id":17, "info":["Page Title(17)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"], "children": [ { "id":18, "info":["Page Title(18)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"], "children": [ { "id":19, "info":["Page Title(19)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"] } ] } ] }, { "id":20, "info":["Page Title(20)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"], "children": [ { "id":21, "info":["Page Title(21)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"], "children": [ { "id":22, "info":["Page Title(22)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"] } ] } ] } ] }
--->
