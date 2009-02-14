<cfif #action# is "getDefinition">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select
			colname,
			definition,
			display_name,
			more_info,
			search_hint
		from 
			documentation 
		where lower(colname) = ( '#lcase(fld)#' )
	</cfquery>
	<cfoutput>
		<cfsavecontent variable="response"><div position="relative"><cfif #addCtl# is "1"><span class="docControl" onclick="removeHelpDiv()">X</span></cfif><cfif data.recordcount is 1><div class="docTitle">#data.display_name#</div><div class="docDef">#data.definition#</div><div class="docSrchTip">#data.search_hint#</div><cfif len(#data.more_info#) gt 0><a class="docMoreInfo" href="#data.more_info#" <cfif #addCtl# is "1">target="_docMoreWin" onclick="removeHelpDiv()"</cfif>>More Information</div></cfif><cfelse><div class="docTitle">No documentation is available for #fld#.</div></cfif></div></cfsavecontent>
		<cfscript>
	        getPageContext().getOut().clearBuffer();
	        writeOutput(response);
		</cfscript>
	</cfoutput>
</cfif>
<!---
<cfcomponent style="document">
	<cffunction name="getDefinition" access="remote" output="true" returntype="String">
	<cfargument required="true" name="fld" type="string">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select
			colname,
			definition,
			display_name,
			more_info 
		from 
			documentation 
		where lower(colname) IN ( '#lcase(replace(fld,",","','","all"))#' )
	</cfquery>
	<cfif data.recordcount is 1>
		<cfoutput>
		<cfsavecontent variable="r">
		
		<div class="docTitle">
			#data.display_name#
		</div>
		<div class="docDef">#data.display_name#</div>
		<a class="docMoreInfo" href="#data.more_info#">More Information</div>
		</cfsavecontent>
		</cfoutput>
	<cfelse>
	<cfsavecontent variable="r">
		Yikes! Found #data.recordcount# matches.
		</cfsavecontent>
		
	</cfif>
		<cfreturn r> 
</cffunction>
</cfcomponent>

		<cffunction name="getDefinitionByDispName" access="remote" returntype="string" output="no">
	    	<cfargument name="fld" type="string" required="true">
	   		 <cftry>
				<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select colname, definition,display_name, more_info from documentation where
					lower(display_name) IN ( '#lcase(replace(fld,",","','","all"))#' )
				</cfquery>
			<cfcatch>
				<cfxml variable="returnData">
					<result>
						<status>500</status>
						<query>#fld#</query>
						<error>#cfcatch.message#; #cfcatch.detail#</error>
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
				<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select colname, definition,display_name, more_info from documentation where
					lower(colname) IN ( '#lcase(replace(fld,",","','","all"))#' )
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

	--->