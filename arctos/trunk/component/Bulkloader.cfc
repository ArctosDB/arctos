<cfcomponent>
<cffunction name="saveNewRecord" access="remote">
	<cfargument name="q" required="yes">
	<cfoutput>
		<cfquery name="getCols" datasource="uam_god">
			select column_name from sys.user_tab_cols
			where table_name='BULKLOADER'
			order by internal_column_id
		</cfquery>
		<cfloop list="#q#" index="kv" delimiters="&">
			
			<cfset k=listfirst(kv,"=")>
			<cfset v=replace(kv,k & "=",'')>
			<br>#k# == #kv#
			<cfset "variables.#k#"=urldecode(v)>
		</cfloop>
		<cfdump var=#variables#>
		<cfset sql = "INSERT INTO bulkloader (">
		<cfset flds = "">
		<cfset data = "">
		<cfloop query="getCols">
			<cfif isDefined("variables.#column_name#")>
				<cfif column_name is not "collection_object_id">
					<cfset flds = "#flds#,#column_name#">
					<cfset thisData = evaluate("variables." & column_name)>
					<cfset thisData = replace(thisData,"'","''","all")>
					<cfset data = "#data#,'#thisData#'">
				</cfif>
			</cfif>
		</cfloop>
		<cfset flds = trim(flds)>
		<cfset flds=right(flds,len(flds)-1)>
		<cfset data = trim(data)>
		<cfset data=right(data,len(data)-1)>
		<cfset flds = "collection_object_id,#flds#">
		<cfset data = "bulkloader_PKEY.nextval,#data#">
		<cfset sql = "insert into bulkloader (#flds#) values (#data#)">	
		<hr>#sql#
		<!----
	<cfset ignoreList="colln,collection_object_id,action,nothing,browseRecs,ImAGod">
	
		<cfloop list="#q#" index="kv" delimiters="&">
			<cfset k=listfirst(kv,"=")>
			<cfset v=replace(kv,k & "=",'')>
			<br>#urldecode(kv)#
			<cfif not listfindnocase(ignoreList,k)>
				
				<br>K: #k#
				<br>V: #v#
			</cfif>
		</cfloop>
		---->
	</cfoutput>
	<cfreturn q>
</cffunction>
<!----------------------------------------------------------------------------------------->
<cffunction name="getPage" access="remote">
	<cfargument name="page" required="yes">
    <cfargument name="pageSize" required="yes">
	<cfargument name="gridsortcolumn" required="yes">
    <cfargument name="gridsortdirection" required="yes">
	<cfargument name="accn" required="yes">
	<cfargument name="enteredby" required="yes">
	<cfargument name="colln" required="yes">
	
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
	
	<cfif len(colln) gt 0>
		<cfset sql = "#sql# AND institution_acronym || ':' || collection_cde IN (#colln#)">
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