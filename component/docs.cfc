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

<cffunction name="editRecord" access="remote">
	<cfargument name="cfgridaction" required="yes">
    <cfargument name="cfgridrow" required="yes">
	<cfargument name="cfgridchanged" required="yes">
	<cfoutput>
		<cfset colname = StructKeyList(cfgridchanged)>
		<cfset value = cfgridchanged[colname]>
		<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update ssrch_field_doc set  #colname# = '#value#'
			where SSRCH_FIELD_DOC_ID=#cfgridrow.SSRCH_FIELD_DOC_ID#
		</cfquery>
	</cfoutput>
</cffunction>
<!------------------------------------------------------------------------------------------------------------------------------>
<cffunction name="createDocDoc" access="remote" returnformat="plain" queryFormat="column">
	<cfargument name="CF_VARIABLE" type="string" required="true">
	<cfargument name="CONTROLLED_VOCABULARY" type="string" required="false">
	<cfargument name="DATA_TYPE" type="string" required="false">
	<cfargument name="DEFINITION" type="string" required="false">
	<cfargument name="DOCUMENTATION_LINK" type="string" required="false">
	<cfargument name="PLACEHOLDER_TEXT" type="string" required="false">
	<cfargument name="DISPLAY_TEXT" type="string" required="false">
	<cfargument name="SEARCH_HINT" type="string" required="false">
	<cfargument name="CATEGORY" type="string" required="false">
	<cfargument name="DISP_ORDER" type="string" required="false">
	<cfargument name="SPECIMEN_RESULTS_COL" type="string" required="false">
	<cfargument name="SQL_ELEMENT" type="string" required="false">	
	<cfargument name="specimen_query_term" type="string" required="false">	
	
					
	<cfif not isdefined("escapeQuotes")>
		<cfinclude template="/includes/functionLib.cfm">
	</cfif>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into ssrch_field_doc
				(
					CF_VARIABLE,
					DEFINITION,
					CONTROLLED_VOCABULARY,
					DOCUMENTATION_LINK,
					PLACEHOLDER_TEXT,
					DATA_TYPE,
					DISPLAY_TEXT,
					SEARCH_HINT,
					CATEGORY,
					DISP_ORDER,
					SPECIMEN_RESULTS_COL,
					SQL_ELEMENT,
					specimen_query_term
				) values (
					'#CF_VARIABLE#',
					'#escapeQuotes(DEFINITION)#',
					'#escapeQuotes(CONTROLLED_VOCABULARY)#',
					'#escapeQuotes(DOCUMENTATION_LINK)#',
					'#escapeQuotes(PLACEHOLDER_TEXT)#',
					'#escapeQuotes(DATA_TYPE)#',
					'#escapeQuotes(DISPLAY_TEXT)#',
					'#escapeQuotes(SEARCH_HINT)#',
					'#escapeQuotes(CATEGORY)#',
					'#escapeQuotes(DISP_ORDER)#',
					'#escapeQuotes(SPECIMEN_RESULTS_COL)#',
					'#escapeQuotes(SQL_ELEMENT)#',
					'#specimen_query_term#'
				)
		</cfquery>
		<cfquery name="trc" datasource="uam_god">
			Select count(*) c from ssrch_field_doc 
		</cfquery>
		<cfquery name="d" datasource="uam_god">
			select * from ssrch_field_doc where CF_VARIABLE='#CF_VARIABLE#'
		</cfquery>
		
		
			<cfset x=''>

		
		
			<cfloop query="d">
		<cfset response = structNew()>
		<cfloop list="#d.columnlist#" index="cname">
			<cfset response["#cname#"]=evaluate("d." & cname)>
		</cfloop>
		<cfset thisItem=serializeJSON(response)>
		<cfset x=listappend(x,thisItem)>
	</cfloop>
	<cfset result='{"Result":"OK","Record":[' & x & ']}'>
	
	
	
	<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------------------------------------>
<cffunction name="deleteDocDoc" access="remote" returnformat="plain" queryFormat="column">
	<cfargument name="SSRCH_FIELD_DOC_ID" type="numeric" required="true">
	<cftry>
		<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from  
				ssrch_field_doc
			where 
				SSRCH_FIELD_DOC_ID=#SSRCH_FIELD_DOC_ID#
		</cfquery>
		<cfset result='{"Result":"OK","Message":"success"}'>
		<cfcatch>
			<cfset result='{"Result":"ERROR","Message":"#cfcatch.message#: #cfcatch.detail#"}'>
		</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------------------------------------>
<cffunction name="updateDocDoc" access="remote" returnformat="plain" queryFormat="column">
	<cfargument name="SSRCH_FIELD_DOC_ID" type="numeric" required="true">
	<cfargument name="CF_VARIABLE" type="string" required="true">
	<cfargument name="CONTROLLED_VOCABULARY" type="string" required="false">
	<cfargument name="DATA_TYPE" type="string" required="false">
	<cfargument name="DEFINITION" type="string" required="false">
	<cfargument name="DOCUMENTATION_LINK" type="string" required="false">
	<cfargument name="PLACEHOLDER_TEXT" type="string" required="false">
	<cfargument name="DISPLAY_TEXT" type="string" required="false">
	<cfargument name="SEARCH_HINT" type="string" required="false">
	<cfargument name="CATEGORY" type="string" required="false">
	<cfargument name="DISP_ORDER" type="string" required="false">
	<cfargument name="SPECIMEN_RESULTS_COL" type="string" required="false">
	<cfargument name="SQL_ELEMENT" type="string" required="false">
	<cfargument name="specimen_query_term" type="string" required="false">
	
	<cfif not isdefined("escapeQuotes")>
		<cfinclude template="/includes/functionLib.cfm">
	</cfif>
	<cftry>
		<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update 
				ssrch_field_doc 
			set  
				CF_VARIABLE = '#escapeQuotes(CF_VARIABLE)#',
				CONTROLLED_VOCABULARY = '#escapeQuotes(CONTROLLED_VOCABULARY)#',
				DATA_TYPE = '#escapeQuotes(DATA_TYPE)#',
				DEFINITION = '#escapeQuotes(DEFINITION)#',
				DOCUMENTATION_LINK = '#escapeQuotes(DOCUMENTATION_LINK)#',
				PLACEHOLDER_TEXT = '#escapeQuotes(PLACEHOLDER_TEXT)#',
				DISPLAY_TEXT = '#escapeQuotes(DISPLAY_TEXT)#',
				SEARCH_HINT = '#escapeQuotes(SEARCH_HINT)#',
				CATEGORY = '#escapeQuotes(CATEGORY)#',
				DISP_ORDER = '#escapeQuotes(DISP_ORDER)#',
				SPECIMEN_RESULTS_COL = '#escapeQuotes(SPECIMEN_RESULTS_COL)#',
				SQL_ELEMENT = '#escapeQuotes(SQL_ELEMENT)#',
				specimen_query_term = '#escapeQuotes(specimen_query_term)#'
			where 
				SSRCH_FIELD_DOC_ID=#SSRCH_FIELD_DOC_ID#
		</cfquery>
		<cfset result='{"Result":"OK","Message":"success"}'>
		<cfcatch>
			<cfset result='{"Result":"ERROR","Message":"#cfcatch.message#: #cfcatch.detail#"}'>
		</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------------------------------------>
<cffunction name="listDocDoc" access="remote" returnformat="plain" queryFormat="column">
	<cfargument name="CF_VARIABLE" type="string" required="false">
	<cfargument name="SPECIMEN_RESULTS_COL" type="string" required="false">
	<cfargument name="specimen_query_term" type="string" required="false">
		
	<cfparam name="jtStartIndex" type="numeric" default="0">
	<cfparam name="jtPageSize" type="numeric" default="10">
	<cfparam name="jtSorting" type="string" default="CF_VARIABLE ASC">
	
	
	<cfset jtStopIndex=jtStartIndex+jtPageSize>
	<cfquery name="trc" datasource="uam_god">
		Select count(*) c from ssrch_field_doc 
	</cfquery>
	<cfquery name="d" datasource="uam_god">
		Select * from (
				Select a.*, rownum rnum From (
					select * from ssrch_field_doc where 1=1
					<cfif isdefined("CF_VARIABLE") and len(CF_VARIABLE) gt 0> and CF_VARIABLE like '%#lcase(CF_VARIABLE)#%'</cfif>
					<cfif isdefined("SPECIMEN_RESULTS_COL") and len(SPECIMEN_RESULTS_COL) gt 0> and SPECIMEN_RESULTS_COL=#SPECIMEN_RESULTS_COL#</cfif>
					<cfif isdefined("specimen_query_term") and len(specimen_query_term) gt 0> and specimen_query_term=#specimen_query_term#</cfif>
					 order by #jtSorting#
				) a where rownum <= #jtStopIndex#
			) where rnum >= #jtStartIndex#
	</cfquery>
	
	
	<cfoutput>
	
	<cfset coredata=''>
	<cfloop query="d">
		<cfset trow="">
		<cfloop list="#d.columnlist#" index="i">
			<cfset theData=evaluate("d." & i)>
			<cfset theData=replace(theData,'"','\"',"all")>
			<cfset theData=replace(theData,chr(10),'<br>',"all")>
			<cfset t = '"#i#":"' & theData  & '"'>
			<cfset trow=listappend(trow,t)>
		</cfloop>
		<cfset trow="{" & trow & "}">
		<cfset coredata=listappend(coredata,trow)>
	</cfloop>
	
	</cfoutput>
	<cfset result='{"Result":"OK","Records":[' & coredata & '],"TotalRecordCount":#trc.c#}'>
			
	<!-----		
			
			
	
	
	<cfset x=''>
	<cfloop query="d">
		<cfset response = structNew()>
		<cfloop list="#d.columnlist#" index="cname">
			<cfset response["#cname#"]=evaluate("d." & cname)>
		</cfloop>
		<cfset thisItem=serializeJSON(response)>
		<cfset x=listappend(x,thisItem)>
	</cfloop>
	<cfset result='{"Result":"OK","Records":[' & x & '],"TotalRecordCount":#trc.c#}'>
	
	---->
	
	
	<cfreturn result>
</cffunction>

</cfcomponent>