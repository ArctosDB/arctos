<cfif isdefined("client.username")>
	<cfset username = #client.username#>
</cfif>
<cfquery name="getPrefs" datasource="#Application.web_user#">
		select * from cf_users
		 where 
		 username = '#username#' order by cf_users.user_id
	</cfquery>
	<cfquery name="id" datasource="#Application.web_user#" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
		select agent_id from agent_name where agent_name='#client.username#'
		and agent_name_type='login'
	</cfquery>
	<cfif id.recordcount is 1>
		<cfset client.myAgentId=#id.agent_id#>
	</cfif>
	<cfoutput query="getPrefs" group="user_id">
	<!--- set session variables with all their stored values --->
	<cfset client.last_login = "#last_login#">
	<cfset client.target = "#target#">
	<cfset client.displayrows = "#displayRows#">
	<cfset client.mapSize = "#mapSize#">
	<cfset client.showObservations = "#showObservations#">
	<cfset client.resultcolumnlist = "#resultcolumnlist#">
	<cfif len(#active_loan_id#) gt 0>
		<cfset client.active_loan_id = "#active_loan_id#">
	<cfelse>
		<cfset client.loan_request_id = "-1">
	</cfif>
	<cfif len(#exclusive_collection_id#) gt 0>
		<cfset client.exclusive_collection_id = "#exclusive_collection_id#">
	<cfelse>
		<cfset client.exclusive_collection_id = "">
	</cfif>
	<cfif len(#fancyCOID#) gt 0>
		<cfset client.fancyCOID = "#fancyCOID#">
	<cfelse>
		<cfset client.fancyCOID = "">
	</cfif>
	<cfif len(#result_sort#) gt 0>
		<cfset client.result_sort = "#result_sort#">
	<cfelse>
		<cfset client.result_sort = "">
	</cfif>	
	<cfif len(#CustomOtherIdentifier#) gt 0>
		<cfset client.customOtherIdentifier = "#CustomOtherIdentifier#">
	<cfelse>
		<cfset client.customOtherIdentifier = "">
	</cfif>
	<cfset client.searchBy=""><!--- Clear anything they might have had hang around --->
		<cfif #parts# is 1>
			<cfset client.searchBy="#client.searchBy#,parts">
		</cfif>
		<cfif #miscellaneous# is 1>
			<cfset client.searchBy="#client.searchBy#,miscellaneous">
		</cfif>
		<cfif #images# is 1>
			<cfset client.searchBy="#client.searchBy#,images">
		</cfif>
		<cfif #Accn_Num# is 1>
			<cfset client.searchBy="#client.searchBy#,accn_num">
		</cfif>
		<cfif #locality# is 1>
			<cfset client.searchBy="#client.searchBy#,locality">
		</cfif>
		<cfif #permit# is 1>
			<cfset client.searchBy="#client.searchBy#,permit">
		</cfif>
		<cfif #citation# is 1>
			<cfset client.searchBy="#client.searchBy#,citation">
		</cfif>
		<cfif #project# is 1>
			<cfset client.searchBy="#client.searchBy#,project">
		</cfif>
		<cfif #attributes# is 1>
			<cfset client.searchBy="#client.searchBy#,attributes">
		</cfif>
		<cfif #Colls# is 1>
			<cfset client.searchBy="#client.searchBy#,colls">
		</cfif>
		<cfif #phylclass# is 1>
			<cfset client.searchBy="#client.searchBy#,phylclass">
		</cfif>
		<cfif #scinameoperator# is 1>
			<cfset client.searchBy="#client.searchBy#,scinameoperator">
		</cfif>
		<cfif #dates# is 1>
			<cfset client.searchBy="#client.searchBy#,dates">
		</cfif>
		<cfif #curatorial_stuff# is 1>
			<cfset client.searchBy="#client.searchBy#,curatorial_stuff">
		</cfif>
		<cfif #higher_taxa# is 1>
			<cfset client.searchBy="#client.searchBy#,higher_taxa">
		</cfif>
		<cfif #identifier# is 1>
			<cfset client.searchBy="#client.searchBy#,identifier">
		</cfif>
		<cfif #boundingbox# is 1>
			<cfset client.searchBy="#client.searchBy#,boundingbox">
		</cfif>	
		<cfif #bigsearchbox# is 1>
			<cfset client.searchBy="#client.searchBy#,bigsearchbox">
		</cfif>	
		<cfif #collecting_source# is 1>
			<cfset client.searchBy="#client.searchBy#,collecting_source">
		</cfif>	
		<cfif #scientific_name# is 1>
			<cfset client.searchBy="#client.searchBy#,scientific_name">
		</cfif>
		<cfif #max_error_in_meters# is 1>
			<cfset client.searchBy="#client.searchBy#,max_error_in_meters">
		</cfif>
		<cfif #killRow# is 1>
			<cfset client.killRow="1">
		<cfelse>
			<cfset client.killRow="0">
		</cfif>		
		<cfif #detail_level# gt 0>
			<cfset client.detailLevel="#detail_level#">
		</cfif>
	</cfoutput>