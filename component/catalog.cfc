<cfcomponent>
<!------------------------------------------------------------->
<cffunction name="updateSciName" returntype="string" access="remote">
	<cfargument name="collection_object_id" type="numeric" required="yes">
	<cfargument name="sciname" type="string" required="yes">
	<cfset result = "success">
	<cfquery name="isThere" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
		select taxon_name_id from taxonomy
		where scientific_name = '#sciname#'
	</cfquery>
	<cfif isThere.recordcount is 1 and len(isThere.taxon_name_id) gt 0>
		<cftry>
			<cfquery name="idid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
				select identification_id,taxa_formula from identification where
				collection_object_id = #collection_object_id#
				and accepted_id_fg = 1		
			</cfquery>
			<cfif idid.taxa_formula contains 'B'>
				<cfset result = "You cannot update this scientific name. Add an identification.">
			<cfelse>
				<cfquery name="idt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
					update identification_taxonomy set
					taxon_name_id = #isThere.taxon_name_id#
					where identification_id = #idid.identification_id#
				</cfquery>
				<cfquery name="o" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
						update identification set scientific_name = '#sciname#',
						taxa_formula='A'
						where identification_id = #idid.identification_id#		
				</cfquery>
			</cfif>
		<cfcatch>
			<cfset result = "An unknown error occured.">
		</cfcatch>
		</cftry>
	<cfelse>
		<cfset result = "An error occured. There are #isThere.recordcount# matching names in Taxonomy.">
	</cfif>
	<cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
	<cfreturn result>
</cffunction>
</cfcomponent>