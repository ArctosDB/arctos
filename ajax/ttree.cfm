<cfoutput>
	<cfif id is "##">
		<cfquery name="d" datasource="uam_god">
			select term,tid from hierarchical_taxonomy where parent_tid is null
		</cfquery>
	</cfif>
	<cfset x=serializeJSON(d)>
	#x#
</cfoutput>
<!----------
[{
  "id":1,"text":"Root node","children":[
    {"id":2,"text":"Child node 1","children":true},
    {"id":3,"text":"Child node 2"}
  ]
}]


SELECT  LPAD(' ', 2 * LEVEL - 1) || term   FROM hierarchical_taxonomy   START WITH parent_tid is null  CONNECT BY PRIOR tid = parent_tid;
----------->