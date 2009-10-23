<cfcomponent>
<!----------------------------------------------------------------------------------------->
<cffunction name="deleteTag" access="remote">
	<cfargument name="tag_id" required="yes">
	<cftry>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			delete from tag where tag_id=#tag_id#
		</cfquery>
			<cfreturn "success">
		<cfcatch>
			<cfreturn "#cfcatch.message# #cfcatch.detail# #cfcatch.sql#">
		</cfcatch>
	</cftry>
</cffunction>
<!----------------------------------------------------------------------------------------->
<cffunction name="getTags" access="remote">
	<cfargument name="media_id" required="yes">
	<cfinclude template="/includes/functionLib.cfm">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select
			tag_id
		from tag where media_id=#media_id#
	</cfquery>
	<cfset i=1>
	<cfloop query="data">
		<cfset "t#i#"=getTagReln(data.tag_id)>
		<cfset i=i+1>
	</cfloop>
	<cfif i gt 1>
		<cfset x=i-1>
		<cfquery name="q" dbtype="query">
			select * from t1
			<cfloop from="2" to="#x#" index="o">
				union select * from t#o#
			</cfloop>
		</cfquery>
		
		<cfreturn q>
	<cfelse>
		<cfreturn />
	</cfif>
</cffunction>
<!--------------------------------------->
<cffunction name="newRef" access="remote">
	<cfargument name="media_id" required="yes">
	<cfargument name="reftype" required="yes">
	<cfargument name="remark" required="yes">
	<cfargument name="refid" required="yes">
	<cfargument name="reftop" required="yes">
	<cfargument name="refleft" required="yes">
	<cfargument name="refh" required="yes">
	<cfargument name="refw" required="yes">
	<cfargument name="imgh" required="yes">
	<cfargument name="imgw" required="yes">
	<cfinclude template="/includes/functionLib.cfm">
	<cfoutput>
	<cftry>
		<cftransaction>
			<cfquery name="pkey" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select sq_tag_id.nextval n from dual
			</cfquery>
			<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into tag (
					tag_id,
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
					<cfelseif reftype is "locality">
						,locality_id
					</cfif>
					<cfif len(remark) gt 0>
						,remark
					</cfif>
				) values (
					#pkey.n#,
					#media_id#,
					#reftop#,
					#refleft#,
					#refh#,
					#refw#,
					#imgh#,
					#imgw#
					<cfif reftype is "cataloged_item" or reftype is "collecting_event" or reftype is "locality">
						,#refid#
					</cfif>
					<cfif len(remark) gt 0>
						,'#remark#'
					</cfif>
				)
			</cfquery>
			<cfset rx=getTagReln(pkey.n)>
			<cfreturn rx>
		</cftransaction>
	<cfcatch>
		<cfreturn "fail: #cfcatch.message# #cfcatch.detail# #cfcatch.sql#">
	</cfcatch>
	</cftry>	
	</cfoutput>
</cffunction>
<!--------------------------------------->

</cfcomponent>