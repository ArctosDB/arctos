<cfoutput>
<cfset cat_num="">
<cfset q="cat_num=12">
	<cfloop list="#q#" index="p" delimiters="&">
		<cfset k=listgetat(p,1,"=")>
		<cfset v=listgetat(p,2,"=")>
		#k#::#v#
		<cfset evaluate("#k#")=v>
	</cfloop>
	==#cat_num#==
	-#k#-
	=#v#=


</cfoutput>