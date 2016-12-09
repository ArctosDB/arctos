
<cfoutput>
	<cfif id is "##">
		<cfquery name="d" datasource="uam_god">
			select term,tid from hierarchical_taxonomy where parent_tid is null
		</cfquery>
		<cfset x="[">
		<cfset i=1>
		<cfloop query="d">
			<cfset x=x & '{"id":#tid#,"text":"#term#","children":true}'>
			<cfif i lt d.recordcount>
				<cfset x=x & ",">
			</cfif>
			<cfset i=i+1>
		</cfloop>
		<cfset x=x & "]">
	<cfelse>
		<!---- get children of the passed-in node ---->
		<cfquery name="d" datasource="uam_god">
			select term,tid from hierarchical_taxonomy where parent_tid = #id#
		</cfquery>
		<cfdump var=#d#
	</cfif>

	#x#
</cfoutput>


<!----------


[{
  "id":1,"text":"Root node","children":true
},
{
  "id":2,"text":"Root node2","children":true
}]



[{
  "id":1,"text":"Root node","children":[
    {"id":2,"text":"Child node 1","children":true},
    {"id":3,"text":"Child node 2"}
  ]
}]




[
	{"id":82783984, "text":"Eukaryota","children":"true"}
	{"id":82783975, "text":"adassfas","children":"true"}
]



[
       { "id" : "ajson1", "parent" : "#", "text" : "Simple root node" },
       { "id" : "ajson2", "parent" : "#", "text" : "Root node 2" },
       { "id" : "ajson3", "parent" : "ajson2", "text" : "Child 1" },
       { "id" : "ajson4", "parent" : "ajson2", "text" : "Child 2" },
]


[{
  "id":1,"text":"Root node","children":[
    {"id":2,"text":"Child node 1","children":true},
    {"id":3,"text":"Child node 2"}
  ]
}]


SELECT  LPAD(' ', 2 * LEVEL - 1) || term   FROM hierarchical_taxonomy   START WITH parent_tid is null  CONNECT BY PRIOR tid = parent_tid;
----------->