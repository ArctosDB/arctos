<cfset ignore_list = "FIELDNAMES,SEARCHPARAMS,mapurl,newquery,ORDER_ORDER,ORDER_BY,newsearch,STARTROW,TGTFORM,TGTFORM1">
<cfset returnURL = "">
<cfloop list="#StructKeyList(form)#" index="key">
	<cfif len(#form[key]#) gt 0 and listfindnocase(ignore_list,key) is 0>
		<cfset returnURL='#returnURL#&#key#=#form[key]#'>
	</cfif>
</cfloop>
<cfloop list="#StructKeyList(url)#" index="key">
	<cfif len(#url[key]#) gt 0 and listfindnocase(ignore_list,key) is 0>
		<cfset returnURL='#returnURL#&#key#=#url[key]#'>
	</cfif>
</cfloop>
<cfset Caller.returnURL=replace(returnURL,"&","?","first")>