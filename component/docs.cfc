<cfcomponent>
<cffunction name="getPage" access="remote">
	<cfargument name="page" required="yes">
    <cfargument name="pageSize" required="yes">
	<cfargument name="gridsortcolumn" required="yes">
    <cfargument name="gridsortdirection" required="yes">
	<cfset startrow=page * pageSize>
	<cfset stoprow=startrow + pageSize>
	<cfif len(gridsortcolumn) is 0>
		<cfset gridsortcolumn="SSRCH_FIELD_DOC_ID">
	</cfif>
<cfoutput>
	

	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from ssrch_field_doc order by #gridsortcolumn# #gridsortdirection#
	</cfquery>
</cfoutput>
	      <cfreturn queryconvertforgrid(data,page,pagesize)/>
</cffunction>




<cffunction name="saveEdits" access="remote">
	<cfargument name="q" required="yes">
	<cfoutput>
		<cfquery name="getCols" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select column_name from sys.user_tab_cols
			where lower(table_name)='ssrch_field_doc'
			order by internal_column_id
		</cfquery>
		<cfloop list="#q#" index="kv" delimiters="&">
			<cfset k=listfirst(kv,"=")>
			<cfset v=replace(kv,k & "=",'')>
			<cfset "variables.#k#"=urldecode(v)>
		</cfloop>
		<cfset sql = "UPDATE ssrch_field_doc SET ">
		<cfloop query="getCols">
			<cfif isDefined("variables.#column_name#")>
				<cfif column_name is not "SSRCH_FIELD_DOC_ID">
					<cfset thisData = evaluate("variables." & column_name)>
					<cfset thisData = replace(thisData,"'","''","all")>
					<cfset sql = "#SQL#,#COLUMN_NAME# = '#thisData#'">
				</cfif>
			</cfif>
		</cfloop>
		<cfset sql = "#SQL# where SSRCH_FIELD_DOC_ID = #SSRCH_FIELD_DOC_ID#">
		<cfset sql = replace(sql,"UPDATE ssrch_field_doc SET ,","UPDATE ssrch_field_doc SET ")>
		<cftry>
			<cftransaction>
				<cfquery name="new" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					#preservesinglequotes(sql)#
				</cfquery>
				<cfset result = querynew("SSRCH_FIELD_DOC_ID,RSLT")>
				<cfset temp = queryaddrow(result,1)>
				<cfset temp = QuerySetCell(result, "SSRCH_FIELD_DOC_ID", SSRCH_FIELD_DOC_ID, 1)>
				<cfset temp = QuerySetCell(result, "rslt",  "success", 1)>
			
			</cftransaction>
		<cfcatch>
			<cfset result = querynew("SSRCH_FIELD_DOC_ID,RSLT")>
			<cfset temp = queryaddrow(result,1)>
			<cfset temp = QuerySetCell(result, "SSRCH_FIELD_DOC_ID", SSRCH_FIELD_DOC_ID, 1)>
			<cfset temp = QuerySetCell(result, "rslt",  cfcatch.message & "; " &  cfcatch.detail, 1)>
		</cfcatch>
		</cftry>
		<cfset x=SerializeJSON(result, true)>
		<cfreturn x>
	</cfoutput>
</cffunction>



</cfcomponent>