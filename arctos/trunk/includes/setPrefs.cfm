<cfif isdefined("session.username")>
	<cfset username = #session.username#>
</cfif>
<cfquery name="getPrefs" datasource="#Application.web_user#">
		select * from cf_users
		 where 
		 username = '#username#' order by cf_users.user_id
	</cfquery>
	<cfquery name="id" datasource="#Application.web_user#" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
		select agent_id from agent_name where agent_name='#session.username#'
		and agent_name_type='login'
	</cfquery>
	<cfif id.recordcount is 1>
		<cfset session.myAgentId=#id.agent_id#>
	</cfif>
	<cfoutput query="getPrefs" group="user_id">
	<!--- set session variables with all their stored values --->
	<cfset session.last_login = "#last_login#">
	<cfset session.target = "#target#">
	<cfif len(displayRows) gt 0 and displayRows gt 0>
		<cfset session.displayrows = "#displayRows#">
	</cfif>
	<cfset session.mapSize = "#mapSize#">
	<cfset session.showObservations = "#showObservations#">
	<cfset session.resultcolumnlist = "#resultcolumnlist#">
	<cfif len(#active_loan_id#) gt 0>
		<cfset session.active_loan_id = "#active_loan_id#">
	<cfelse>
		<cfset session.loan_request_id = "-1">
	</cfif>
	<cfif len(#exclusive_collection_id#) gt 0>
		<cfset session.exclusive_collection_id = "#exclusive_collection_id#">
	<cfelse>
		<cfset session.exclusive_collection_id = "">
	</cfif>
	<cfif len(#fancyCOID#) gt 0>
		<cfset session.fancyCOID = "#fancyCOID#">
	<cfelse>
		<cfset session.fancyCOID = "">
	</cfif>
	<cfif len(#result_sort#) gt 0>
		<cfset session.result_sort = "#result_sort#">
	<cfelse>
		<cfset session.result_sort = "">
	</cfif>	
	<cfif len(#CustomOtherIdentifier#) gt 0>
		<cfset session.customOtherIdentifier = "#CustomOtherIdentifier#">
	<cfelse>
		<cfset session.customOtherIdentifier = "">
	</cfif>
	<cfset session.searchBy=""><!--- Clear anything they might have had hang around --->
		<cfif #parts# is 1>
			<cfset session.searchBy="#session.searchBy#,parts">
		</cfif>
		<cfif #miscellaneous# is 1>
			<cfset session.searchBy="#session.searchBy#,miscellaneous">
		</cfif>
		<cfif #images# is 1>
			<cfset session.searchBy="#session.searchBy#,images">
		</cfif>
		<cfif #Accn_Num# is 1>
			<cfset session.searchBy="#session.searchBy#,accn_num">
		</cfif>
		<cfif #locality# is 1>
			<cfset session.searchBy="#session.searchBy#,locality">
		</cfif>
		<cfif #permit# is 1>
			<cfset session.searchBy="#session.searchBy#,permit">
		</cfif>
		<cfif #citation# is 1>
			<cfset session.searchBy="#session.searchBy#,citation">
		</cfif>
		<cfif #project# is 1>
			<cfset session.searchBy="#session.searchBy#,project">
		</cfif>
		<cfif #attributes# is 1>
			<cfset session.searchBy="#session.searchBy#,attributes">
		</cfif>
		<cfif #Colls# is 1>
			<cfset session.searchBy="#session.searchBy#,colls">
		</cfif>
		<cfif #phylclass# is 1>
			<cfset session.searchBy="#session.searchBy#,phylclass">
		</cfif>
		<cfif #scinameoperator# is 1>
			<cfset session.searchBy="#session.searchBy#,scinameoperator">
		</cfif>
		<cfif #dates# is 1>
			<cfset session.searchBy="#session.searchBy#,dates">
		</cfif>
		<cfif #curatorial_stuff# is 1>
			<cfset session.searchBy="#session.searchBy#,curatorial_stuff">
		</cfif>
		<cfif #higher_taxa# is 1>
			<cfset session.searchBy="#session.searchBy#,higher_taxa">
		</cfif>
		<cfif #identifier# is 1>
			<cfset session.searchBy="#session.searchBy#,identifier">
		</cfif>
		<cfif #boundingbox# is 1>
			<cfset session.searchBy="#session.searchBy#,boundingbox">
		</cfif>	
		<cfif #bigsearchbox# is 1>
			<cfset session.searchBy="#session.searchBy#,bigsearchbox">
		</cfif>	
		<cfif #collecting_source# is 1>
			<cfset session.searchBy="#session.searchBy#,collecting_source">
		</cfif>	
		<cfif #scientific_name# is 1>
			<cfset session.searchBy="#session.searchBy#,scientific_name">
		</cfif>
		<cfif #max_error_in_meters# is 1>
			<cfset session.searchBy="#session.searchBy#,max_error_in_meters">
		</cfif>
		<cfif #killRow# is 1>
			<cfset session.killRow="1">
		<cfelse>
			<cfset session.killRow="0">
		</cfif>		
		<cfif #detail_level# gt 0>
			<cfset session.detailLevel="#detail_level#">
		</cfif>
	</cfoutput>