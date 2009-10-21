<cfcomponent>
<!----------------------------------------------------------------------------------------->
<cffunction name="getTags" access="remote">
	<cfargument name="media_id" required="yes">
	<cfinclude template="/includes/functionLib.cfm">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select
			tag_id,
			media_id,
			reftop,
			refleft,
			refh,
			refw,
			imgh,
			imgw,
			remark refcomment
		from tag where media_id=#media_id#
	</cfquery>
	<cfset i=1>
	<cfloop query="data">
		<cfset t=getTagReln(data.tag_id)>
		<cfset rft = ArrayNew(1)>
		<cfset rfi = ArrayNew(1)>
		<cfset rfs = ArrayNew(1)>
		<cfset rfl = ArrayNew(1)>

		<cfif listlen(t,"|") gte 1>
			<cfset rft[i]=listgetat(t,1,"|")>
		<cfelse>
			<cfset rft[i]="">
		</cfif>
		
		<cfif listlen(t,"|") gte 2>
			<cfset rfi[i]=listgetat(t,2,"|")>
		<cfelse>
			<cfset rfi[i]="">
		</cfif>
		
		<cfif listlen(t,"|") gte 3>
			<cfset rfs[i]=listgetat(t,3,"|")>
		<cfelse>
			<cfset rfs[i]="">
		</cfif>
		
		<cfif listlen(t,"|") gte 4>
			<cfset rfl[i]=listgetat(t,4,"|")>
		<cfelse>
			<cfset rfl[i]="">
		</cfif>
		
		
		
		
		
	</cfloop>
	
	<cfset temp = QueryAddColumn(data, "REFTYPE", "VarChar",rft)>
	<cfset temp = QueryAddColumn(data, "REFID", "Integer",rfi)>
	<cfset temp = QueryAddColumn(data, "REFSTRING", "VarChar",rfs)>
	<cfset temp = QueryAddColumn(data, "REFLINK", "VarChar",rfl)>
			
	<cfreturn data>
</cffunction>
<!--------------------------------------->
<cffunction name="newRef" access="remote">
	<cfargument name="media_id" required="yes">
	<cfargument name="reftype" required="yes">
	<cfargument name="refcomment" required="yes">
	<cfargument name="refid" required="yes">
	<cfargument name="reftop" required="yes">
	<cfargument name="refleft" required="yes">
	<cfargument name="refh" required="yes">
	<cfargument name="refw" required="yes">
	<cfargument name="imgh" required="yes">
	<cfargument name="imgw" required="yes">					
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
					</cfif>
					<cfif len(refcomment) gt 0>
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
					<cfif reftype is "cataloged_item" or reftype is "collecting_event">
						,#refid#
					</cfif>
					<cfif len(refcomment) gt 0>
						,'#refcomment#'
					</cfif>
				)
			</cfquery>
			<cfquery name="r" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select
					tag_id,
					media_id,
					reftop,
					refleft,
					refh,
					refw,
					imgh,
					imgw,
					'#reftype#' reftype,
					#refid# refid,
					'#refcomment#' refcomment,
					'stuff' REFSTRING
				from tag where tag_id=#pkey.n#
			</cfquery>
			
			<cfreturn r>
		</cftransaction>
	<cfcatch>
		<cfreturn "fail: #cfcatch.message# #cfcatch.detail#">
	</cfcatch>
	</cftry>	
	</cfoutput>
</cffunction>
<!--------------------------------------->

</cfcomponent>