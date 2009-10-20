<cfcomponent>
<!----------------------------------------------------------------------------------------->
<cffunction name="getTags" access="remote">
	<cfargument name="media_id" required="yes">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from tag where media_id=#media_id#
	</cfquery>
	<cfreturn data>
</cffunction>
<!--------------------------------------->
<cffunction name="newRef" access="remote">
	<cfargument name="media_id" required="yes">
	<cfargument name="reftype" required="yes">
	<cfargument name="refcomment" required="yes">
	<cfargument name="refid" required="yes">
	<cfargument name="top" required="yes">
	<cfargument name="left" required="yes">
	<cfargument name="height" required="yes">
	<cfargument name="width" required="yes">
	<cfargument name="img_h" required="yes">
	<cfargument name="img_w" required="yes">					
	<cftry>
		<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			insert into tag (
				media_id,
				reftop,
				refleft,
				refh,
				refw,
				imgh,
				imgw
				<cfif reftype is "cataloged_item">
					,collection_object_id
				<cfelseif reftype is "collecting_event">
					,collecting_event_id
				</cfif>
				<cfif len(refcomment) gt 0>
					,remark
				</cfif>
			) values (
				#media_id#,
				#reftop#,
				#refleft#,
				#refh#,
				#refw#,
				#imgh#,
				#imgw#
				<cfif reftype is "cataloged_item" or reftype is "collecting_event">
					,#refid#
				</cfif>
				<cfif len(refcomment) gt 0>
					,'#remark#'
				</cfif>
			)
		</cfquery>
	<cfcatch>
		<cfreturn "fail: #cfcatch.message# #cfcatch.detail#">
	</cfcatch>
	</cftry>				
	<cfreturn "success">
</cffunction>
<!--------------------------------------->

</cfcomponent>