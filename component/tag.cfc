<cfcomponent>
<!----------------------------------------------------------------------------------------->
<cffunction name="deleteTag" access="remote">
	<cfargument name="tag_id" required="yes">
	<cftry>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from tag where tag_id=#tag_id#
		</cfquery>
			<cfreturn "success">
		<cfcatch>
			<cfreturn "#cfcatch.message# #cfcatch.detail# #cfcatch.sql#">
		</cfcatch>
	</cftry>
</cffunction>
<!----------------------------------------------------------------------------------------->
<cffunction name="getTagReln" access="public" output="true">
    <cfargument name="tag_id" required="true" type="numeric">
	<cfoutput>
		<cfquery name="r" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				tag_id,
				media_id,
				reftop,
				refleft,
				refh,
				refw,
				imgh,
				imgw,
				remark raw_remark,
				collection_object_id,
				collecting_event_id,
				locality_id,
				agent_id
			from tag where tag_id=#tag_id#
			order by
				collection_object_id,
				collecting_event_id,
				locality_id,
				agent_id,
				remark
		</cfquery>
		<cfif r.collection_object_id gt 0>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select guid from #session.flatTableName# where collection_object_id=#r.collection_object_id#
			</cfquery>
			<cfset rt="cataloged_item">
			<cfset rs="#d.guid#">
			<cfset ri="#r.collection_object_id#">
			<cfset rl="/guid/#d.guid#">
		<cfelseif r.collecting_event_id gt 0>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select verbatim_date, verbatim_locality from collecting_event where collecting_event_id=#r.collecting_event_id#
			</cfquery>
			<cfset rt="collecting_event">
			<cfset rs="#d.verbatim_locality# (#d.verbatim_date#)">
			<cfset ri="#r.collecting_event_id#">
			<cfset rl="/showLocality.cfm?action=srch&collecting_event_id=#r.collecting_event_id#">
		<cfelseif r.agent_id gt 0>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select agent_name from preferred_agent_name where agent_id=#r.agent_id#
			</cfquery>
			<cfset rt="agent">
			<cfset rs="#d.agent_name#">
			<cfset ri="#r.agent_id#">
			<cfset rl="/info/agentActivity.cfm?agent_id=#r.agent_id#">
		<cfelseif r.locality_id gt 0>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select spec_locality from locality where locality_id=#r.locality_id#
			</cfquery>
			<cfset rt="locality">
			<cfset rs="#d.spec_locality#">
			<cfset ri="#r.locality_id#">
			<cfset rl="/showLocality.cfm?action=srch&locality_id=#r.locality_id#">
		<cfelse>
			<cfset rt="comment">
			<cfset rs="">
			<cfset ri="">
			<cfset rl="">
		</cfif>
		
		<cfset remark=r.raw_remark>
		<cfif remark contains "[[" and remark contains "]]">
			<cfset remark=replace(remark,"[[","#chr(7)#*" ,"all")>
			<cfset remark=replace(remark,"]]", "*#chr(7)#" ,"all")>
			<cfloop list="#remark#" delimiters="#chr(7)#" index="x">
				<cfif left(x,1) is "*" and right(x,1) is "*">
					<cfset x=left(x,len(x)-1)>
					<cfset x=right(x,len(x)-1)>
					<cfif x contains "|">
						<cfset theLink=listfirst(x,"|")>
					<cfelse>
						<cfset theLink=x>
					</cfif>
					<cfif left(theLink,5) is "guid/">
						<cfif x contains "|">
							<cfset linktext=listlast(x,"|")>
						<cfelse>
							<cfset linktext=replace(x,"guid/","","all")>
						</cfif>
						<cfset htmlLink='<a href="#theLink#">#linktext#</a>'>
					</cfif>
				</cfif>
			</cfloop>			
		</cfif>




		
		<cfset rft = ArrayNew(1)>
		<cfset rfi = ArrayNew(1)>
		<cfset rfs = ArrayNew(1)>
		<cfset rfl = ArrayNew(1)>
		<cfset rmk = ArrayNew(1)>
		<cfset rft[1]=rt>
		<cfset rfi[1]=ri>
		<cfset rfs[1]=rs>
		<cfset rfl[1]=rl>
		<cfset rmk[1]=remark>
		<cfset temp = QueryAddColumn(r, "REFTYPE", "VarChar",rft)>
		<cfset temp = QueryAddColumn(r, "REFID", "Integer",rfi)>
		<cfset temp = QueryAddColumn(r, "REFSTRING", "VarChar",rfs)>
		<cfset temp = QueryAddColumn(r, "REFLINK", "VarChar",rfl)>
		<cfset temp = QueryAddColumn(r, "REMARK", "VarChar",rmk)>
		<cfreturn r>
	</cfoutput>
</cffunction>


<!----------------------------------------------------------------------------------------->
<cffunction name="getTags" access="remote">
	<cfargument name="media_id" required="yes">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
<cffunction name="saveEdit" access="remote">
	<cfargument name="tag_id" required="yes">
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
			<cfquery name="reset" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update tag set
					collection_object_id=NULL,
					collecting_event_id=NULL,
					locality_id=NULL,
					agent_id=NULL,
					remark=NULL
				where
					tag_id=#tag_id#
			</cfquery>

			<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update tag set
					reftop=#reftop#,
					refleft=#refleft#,
					refh=#refh#,
					refw=#refw#,
					imgh=#imgh#,
					imgw=#imgw#
					<cfif reftype is "cataloged_item">
						,collection_object_id=#refid#
					<cfelseif reftype is "collecting_event">
						,collecting_event_id=#refid#
					<cfelseif reftype is "locality">
						,locality_id=#refid#
					<cfelseif reftype is "agent">
						,agent_id=#refid#
					</cfif>
					<cfif len(remark) gt 0>
						,remark='#escapeQuotes(remark)#'
					</cfif>
				where
					tag_id=#tag_id#
			</cfquery>
			<cfset rx=getTagReln(tag_id)>
			<cfreturn rx>
		</cftransaction>
	<cfcatch>
		<cfreturn "fail: #cfcatch.message# #cfcatch.detail# #cfcatch.sql#">
	</cfcatch>
	</cftry>	
	</cfoutput>
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
			<cfquery name="pkey" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select sq_tag_id.nextval n from dual
			</cfquery>
			<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
					<cfelseif reftype is "agent">
						,agent_id
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
					<cfif reftype is "cataloged_item" or reftype is "collecting_event" or reftype is "locality" or reftype is "agent">
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