<cfcomponent>
<!----------------------------------------------------------------------------------------->
<cffunction name="getPage" access="remote">
	<cfargument name="page" required="yes">
    <cfargument name="pageSize" required="yes">
	<cfargument name="gridsortcolumn" required="yes">
    <cfargument name="gridsortdirection" required="yes">
	<cfargument name="accn" required="yes">
	<cfargument name="enteredby" required="yes">
	
	<cfset startrow=page * pageSize>
	<cfset stoprow=startrow + pageSize>
	<cfif len(gridsortcolumn) is 0>
		<cfset gridsortcolumn="collection_object_id">
	</cfif>
<cfoutput>
	<!----
	<cfset sql="Select * from ( Select a.*, rownum rnum From (">
	<cfset sql=sql & "select * from bulkloader where 1=1">
	<cfif len(accn) gt 0>
		<cfset sql=sql & " and accn IN (#accn#)">
	</cfif>
	<cfif len(enteredby) gt 0>
		<cfset sql=sql & " and enteredby IN (#enteredby#)">
	</cfif>
	
	<cfset sql=sql & " order by #gridsortcolumn# #gridsortdirection#">
	<cfset sql=sql & " ) a where rownum <= #stoprow#) where rnum >= #startrow#">

	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(sql)#
	</cfquery>
	---->
	<cfset sql="select * from bulkloader where 1=1">
	<cfif len(accn) gt 0>
		<cfset sql=sql & " and accn IN (#accn#)">
	</cfif>
	<cfif len(enteredby) gt 0>
		<cfset sql=sql & " and enteredby IN (#enteredby#)">
	</cfif>
	
	<cfset sql=sql & " order by #gridsortcolumn# #gridsortdirection#">

	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(sql)#
	</cfquery>
</cfoutput>
	      <cfreturn queryconvertforgrid(data,page,pagesize)/>
</cffunction>
<!--------------------------------------->
<cffunction name="editRecord" access="remote">
	<cfargument name="cfgridaction" required="yes">
    <cfargument name="cfgridrow" required="yes">
	<cfargument name="cfgridchanged" required="yes">
	<cfoutput>
		<cfset colname = StructKeyList(cfgridchanged)>
		<cfset value = cfgridchanged[colname]>
		<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			update bulkloader set  #colname# = '#value#'
			where collection_object_id=#cfgridrow.collection_object_id#
		</cfquery>
	</cfoutput>
</cffunction>
</cfcomponent>