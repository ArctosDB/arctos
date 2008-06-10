<cfoutput>
<cfset cat_num="">

<cfset s=structNew()>
<cfset q="cat_num=12">
	<cfloop list="#q#" index="p" delimiters="&">
		<cfset k=listgetat(p,1,"=")>
		<cfset v=listgetat(p,2,"=")>
		<cfset temp=StructInsert(s, k, v)>
	</cfloop>
	<cfdump var=#s#>
	<cfloop list="#StructKeyList(s)#" index="key">
		<cfif len(#s[key]#) gt 0>
		<cfset #key# = s[key]>
			
</cfif>
</cfloop>
	==#cat_num#==
	-#k#-
	=#v#=


</cfoutput>