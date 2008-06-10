<cfoutput>
<cfset cat_num="">

<cfset s=structNew()>
<cfset q="cat_num=12">
	<cfloop list="#q#" index="p" delimiters="&">
		<cfset k=listgetat(p,1,"=")>
		<cfset v=listgetat(p,2,"=")>
		<cfset variables[ k ] = v >
	</cfloop>

	

	==#cat_num#==
	-#k#-
	=#v#=


</cfoutput>