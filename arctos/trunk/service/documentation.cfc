<cfcomponent>
	<cfinclude template="/includes/alwaysInclude.cfm">
	<cfoutput>
		<cffunction name="getDefinitionByDispName" access="remote" returntype="string" output="no">
	    	<cfargument name="fld" type="string" required="true">
	   		 <cftry>
				<cfquery name="data" datasource="#web_user#">
					select colname, definition,display_name, more_info from documentation where
					lower(display_name) IN ( '#lcase(replace(fld,",","','","all"))#' )
				</cfquery>
			<cfcatch>
				<cfxml variable="returnData">
					<result>
						<status>500</status>
						<query>#fld#</query>
						<error>#cfcatch.message#; #cfcatch.detail#;</error>
					</result>
				</cfxml>
				<cfreturn returnData>
			</cfcatch>
			</cftry>
			<cfif #data.recordcount# gt 0 and #len(data.definition)# gt 0>
			<cfxml variable="returnData">
					<result><status>200</status><cfloop query="data"><record><name>#colname#</name><definition>#definition#</definition><display_name>#display_name#</display_name><more_info>#more_info#</more_info></record></cfloop></result>
				</cfxml>
			<cfelse>
				<cfxml variable="returnData">
					<result>
						<status>404</status>
						<query>#fld#</query>
						<error>No data found.</error>
					</result>
				</cfxml>
			</cfif>
			<cfreturn returnData>             
	  	</cffunction>
	  	
		<cffunction name="getDefinition" access="remote" returntype="string" output="no">
	    	<cfargument name="fld" type="string" required="true">
	   		 <cftry>
				<cfquery name="data" datasource="#web_user#">
					select colname, definition,display_name, more_info from documentation where
					lower(colname) IN ( '#lcase(replace(fld,",","','","all"))#' )
				</cfquery>
			<cfcatch>
				<cfxml variable="returnData">
					<result>
						<status>500</status>
						<query>#fld#</query>
						<error>#cfcatch.message#; #cfcatch.detail#; #cfcatch.sql#</error>
					</result>
				</cfxml>
				<cfreturn returnData>
			</cfcatch>
			</cftry>
			<cfif #data.recordcount# gt 0 and #len(data.definition)# gt 0>
			<cfxml variable="returnData">
					<result>
						<status>200</status>
							<cfloop query="data">
								<record>
									<name>
										#colname#
									</name>
									<definition>
										#definition#
									</definition>
									<display_name>
										#display_name#
									</display_name>
									<more_info>
										#more_info#
									</more_info>
								</record>
							</cfloop>
					</result>
				</cfxml>
			<cfelse>
				<cfxml variable="returnData">
					<result>
						<status>404</status>
						<query>#fld#</query>
						<error>No data found.</error>
					</result>
				</cfxml>
			</cfif>
			<cfreturn returnData>             
	  	</cffunction>
	</cfoutput>
</cfcomponent>


		
