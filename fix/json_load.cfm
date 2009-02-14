<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	 SELECT  
	 	rownum,
	 	level lvl,
	 	geology_attribute_hierarchy_id,
	 	parent_id,
		attribute
	FROM
		geology_attribute_hierarchy
	start with parent_id is null
	CONNECT BY PRIOR 
		geology_attribute_hierarchy_id = parent_id
</cfquery>
<cfdump var="#data#">
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
		<cfset nrn=rownum+1>
		<cfquery name="nl" dbtype="query">
			select lvl from data where rownum=#nrn#
		</cfquery>
		<cfset nextlevel=nl.lvl>
		<!--- always start a "family" with [ - not needed if "family" is only one member --->
		<cfif nextlevel gt lvl>
			"children:" [
		</cfif>
		<!--- this stuff is there no matter what --->
		{ "id":#geology_attribute_hierarchy_id#, "info":["Page Title(#i#)", "#attribute# (#lvl#)", "2007-06-09 2:44 pm"]
		<!--- close up when at end of family --->
		<cfif nextlevel is 1>
			<cfloop from="1" to="#lvl#" index="i">
				<!--- closing } for every level, including one --->
				}				
			</cfloop>
			<cfif lvl gt 1>
				<!--- and closing ] for multiple levels --->
				]
			</cfif>
		</cfif>

		
		<!---
		<cfif i is 1>] }</cfif>
		<cfif level is 1 and lastlevel gt 1>
			<cfloop from="1" to="#lastlevel#" index="ll">
				] } 
			</cfloop>
		</cfif>
		<cfif #level# gt 1>
			"children":
		</cfif>
		,
		<br>
		--->
		<cfset lastLevel=lvl>
		<cfset i=i+1>
	</cfloop>
</cfoutput>
<!---
{ "requestFirstIndex" : 0, "firstIndex" : 0, "count": 22, "totalCount" : 22, "columns":["Title(ID)", "Owner", "Updated"], "items": 
[ 
	{ 
		-- level1 "id":1, "info":["Page Title(1)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"] 
	}, 
	{ 
		-- level1 "id":2, "info":["Page Title(2)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"], 
		"children": 
		[ 
			{ 
				--level2 "id":3, "info":["Page Title(3)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"],
 				"children": 
				[ 
					{ 
						-- level3 "id":4, "info":["Page Title(4)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"] 
					} 
				] 
			} 
		] 
	}, 
{ "id":5, "info":["Page Title(5)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"], 
	"children": [ { "id":6, "info":["Page Title(6)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"], 
		"children": [ { "id":7, "info":["Page Title(7)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"] } ] } ] }, 
{ "id":8, "info":["Page Title(8)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"], 
	"children": [ { "id":9, "info":["Page Title(9)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"], 
	"children": [ { "id":10, "info":["Page Title(10)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"] } ] } ] }, { "id":11, "info":["Page Title(11)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"] }, { "id":12, "info":["Page Title(12)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"] }, { "id":13, "info":["Page Title(13)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"] }, { "id":14, "info":["Page Title(14)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"] }, { "id":15, "info":["Page Title(15)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"] }, { "id":16, "info":["Page Title(16)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"] }, { "id":17, "info":["Page Title(17)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"], "children": [ { "id":18, "info":["Page Title(18)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"], "children": [ { "id":19, "info":["Page Title(19)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"] } ] } ] }, { "id":20, "info":["Page Title(20)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"], "children": [ { "id":21, "info":["Page Title(21)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"], "children": [ { "id":22, "info":["Page Title(22)", "Bernardo PÌÁdua", "2007-06-09 2:44 pm"] } ] } ] } ] }



{ "id":1283222, "info":["Page Title(4)", "numeric age (1)", "2007-06-09 2:44 pm"] } ,
"children": { "id":1283207, "info":["Page Title(5)", "Ar39/Ar40 (2)", "2007-06-09 2:44 pm"] ,
"children": { "id":1283208, "info":["Page Title(6)", "C14 (2)", "2007-06-09 2:44 pm"] ,
} ] } ] 


--->
