[
	{"id":82783984,parent: "##", "text":"Eukaryota"}
	{"id":82783975,parent: "##", "text":"adassfas"}
]
<!----------

<cfoutput>
	<cfif id is "##">
		<cfquery name="d" datasource="uam_god">
			select term,tid from hierarchical_taxonomy where parent_tid is null
		</cfquery>
	</cfif>
	<cfset x="[">
	<cfloop query="d">
		<cfset x=x & '{"id":#tid#,parent: "####", "text":"#term#"}'>
	</cfloop>
	<cfset x=x & "]">
	#x#
</cfoutput>


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