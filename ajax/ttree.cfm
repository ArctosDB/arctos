
<cfoutput>
		<cfif isdefined("q") and len(q) gt 0>
			<!--- run a query ---->
			<cfquery name="d" datasource="uam_god">
SELECT TID,PARENT_TID,TERM term   FROM hierarchical_taxonomy   START WITH tid in (select tid from hierarchical_taxonomy where term like '#q#%')  CONNECT BY PRIOR parent_tid=tid
</cfquery>
<cfdump var=#d#>

<cfset x="[">
			<cfset i=1>
			<cfloop query="d">
				<cfset x=x & '{"id":"id_#tid#","text":"#term# (#rank#)","parent":"id_#parent_tid#"}'>
				<cfif i lt d.recordcount>
					<cfset x=x & ",">
				</cfif>
				<cfset i=i+1>
			</cfloop>
			<cfset x=x & "]">





		<cfelse>
			<!--- initial load, or..... ---->
			<cfset dbid=replace(id,"id_","")>




		<cfif dbid is "##">
			<cfquery name="d" datasource="uam_god">
				select term,tid,rank from hierarchical_taxonomy where parent_tid is null
			</cfquery>
			<cfset x="[">
			<cfset i=1>
			<cfloop query="d">
				<cfset x=x & '{"id":"id_#tid#","text":"#term# (#rank#)","children":true}'>
				<cfif i lt d.recordcount>
					<cfset x=x & ",">
				</cfif>
				<cfset i=i+1>
			</cfloop>
			<cfset x=x & "]">
			<!--- getting children of  anode ---->
		<cfelse>
			<!---- get children of the passed-in node ---->
			<cfquery name="d" datasource="uam_god">
				select term,tid,rank from hierarchical_taxonomy where parent_tid = #dbid#
			</cfquery>
			<cfset x="[">
			<cfset i=1>
			<cfloop query="d">
				<cfset x=x & '{"id":"id_#tid#","text":"#term# (#rank#)","state": "closed","children":true}'>
				<cfif i lt d.recordcount>
					<cfset x=x & ",">
				</cfif>
				<cfset i=i+1>
			</cfloop>
			<cfset x=x & "]">



		</cfif>
			</cfif>

		#x#
</cfoutput>
<!------

[{"id": "animal", "parent": "#", "text": "Animals<cfif isdefined("test")><cfoutput>#test#</cfoutput></cfif>"},{"id": "device", "parent": "#", "text": "Devices"},{"id": "dog", "parent": "animal", "text": "Dogs"} ]


-- this works
[
                    {"id": "animal", "parent": "#", "text": "Animals"},
                    {"id": "device", "parent": "#", "text": "Devices"},
                    {"id": "dog", "parent": "animal", "text": "Dogs"},
                    {"id": "lion", "parent": "animal", "text": "Lions"},
                    {"id": "mobile", "parent": "device", "text": "Mobile Phones"},
                    {"id": "lappy", "parent": "device", "text": "Laptops"},
                    {"id": "daburman", "parent": "dog", "text": "Dabur Man", "icon": "/"},
                    {"id": "dalmatian", "parent": "dog", "text": "Dalmatian", "icon": "/"},
                    {"id": "african", "parent": "lion", "text": "African Lion", "icon": "/"},
                    {"id": "indian", "parent": "lion", "text": "Indian Lion", "icon": "/"},
                    {"id": "apple", "parent": "mobile", "text": "Apple IPhone 6", "icon": "/"},
                    {"id": "samsung", "parent": "mobile", "text": "Samsung Note II", "icon": "/"},
                    {"id": "lenevo", "parent": "lappy", "text": "Lenevo", "icon": "/"},
                    {"id": "hp", "parent": "lappy", "text": "HP", "icon": "/"}
                ]
				--- end works
<cfoutput>
	<cfif isdefined('getChild')>
		<cfset dbid=replace(id,"id_","")>
		<cfif dbid is "##">
			<cfquery name="d" datasource="uam_god">
				select term,tid,rank from hierarchical_taxonomy where parent_tid is null
			</cfquery>
			<cfset x="[">
			<cfset i=1>
			<cfloop query="d">
				<cfset x=x & '{"id":"id_#tid#","text":"#term# (#rank#)","children":true}'>
				<cfif i lt d.recordcount>
					<cfset x=x & ",">
				</cfif>
				<cfset i=i+1>
			</cfloop>
			<cfset x=x & "]">
		<cfelse>
			<!---- get children of the passed-in node ---->
			<cfquery name="d" datasource="uam_god">
				select term,tid,rank from hierarchical_taxonomy where parent_tid = #dbid#
			</cfquery>
			<cfset x="[">
			<cfset i=1>
			<cfloop query="d">
				<cfset x=x & '{"id":"id_#tid#","text":"#term# (#rank#)","state": "closed","children":true}'>
				<cfif i lt d.recordcount>
					<cfset x=x & ",">
				</cfif>
				<cfset i=i+1>
			</cfloop>
			<cfset x=x & "]">



		</cfif>

		#x#
	</cfif>
</cfoutput>

---->
<!----------

"id":"id_#tid#",



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