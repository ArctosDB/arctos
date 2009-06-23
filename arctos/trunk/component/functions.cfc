<cfcomponent>	
<cffunction name="addPartToLoan" access="remote">
	<cfargument name="transaction_id" type="numeric" required="yes">
	<cfargument name="partID" type="numeric" required="yes">
	<cfargument name="remark" type="string" required="yes">
	<cfargument name="instructions" type="string" required="yes">
	<cfargument name="subsample" type="numeric" required="yes">
	<cfset thisDate = dateformat(now(),"dd-mmm-yyyy")>
	<cfoutput>
	<cftransaction>
		<cftry>
			<cfquery name="n" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select sq_collection_object_id.nextval n from dual
			</cfquery>
			
			<cfquery name="meta" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select cataloged_item.collection_object_id,
				cat_num,collection,part_name
				from
				cataloged_item,
				collection,
				specimen_part 
				where
				cataloged_item.collection_id=collection.collection_id and
				cataloged_item.collection_object_id=specimen_part.derived_from_cat_item and
				specimen_part.collection_object_id=#partID#
			</cfquery>
			<cfif #subsample# is 1>
			<cfquery name="parentData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				SELECT 
					coll_obj_disposition, 
					condition,
					part_name,
					part_modifier,
					PRESERVE_METHOD,
					derived_from_cat_item,
					is_tissue
				FROM
					coll_object, specimen_part
				WHERE 
					coll_object.collection_object_id = specimen_part.collection_object_id AND
					coll_object.collection_object_id = #partID#
			</cfquery>
			<cfquery name="newCollObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				INSERT INTO coll_object (
					COLLECTION_OBJECT_ID,
					COLL_OBJECT_TYPE,
					ENTERED_PERSON_ID,
					COLL_OBJECT_ENTERED_DATE,
					LAST_EDITED_PERSON_ID,
					LAST_EDIT_DATE,
					COLL_OBJ_DISPOSITION,
					LOT_COUNT,
					CONDITION)
				VALUES
					(#n.n#,
					'SS',
					#session.myAgentId#,
					'#thisDate#',
					#session.myAgentId#,
					'#thisDate#',
					'#parentData.coll_obj_disposition#',
					1,
					'#parentData.condition#')
			</cfquery>
			<cfquery name="newPart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				INSERT INTO specimen_part (
					COLLECTION_OBJECT_ID
					,PART_NAME
					<cfif len(#parentData.PART_MODIFIER#) gt 0>
						,PART_MODIFIER
					</cfif>
					,SAMPLED_FROM_OBJ_ID
					<cfif len(#parentData.PRESERVE_METHOD#) gt 0>
						,PRESERVE_METHOD
					</cfif>
					,DERIVED_FROM_CAT_ITEM,
					is_tissue)
				VALUES (
					#n.n#
					,'#parentData.part_name#'
					<cfif len(#parentData.PART_MODIFIER#) gt 0>
						,'#parentData.PART_MODIFIER#'
					</cfif>
					,#partID#
					<cfif len(#parentData.PRESERVE_METHOD#) gt 0>
						,'#parentData.PRESERVE_METHOD#'
					</cfif>
					,#parentData.derived_from_cat_item#,
					#parentData.is_tissue#)				
			</cfquery>
		</cfif>
		<cfquery name="addLoanItem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			INSERT INTO loan_item (
				TRANSACTION_ID,
				COLLECTION_OBJECT_ID,
				RECONCILED_BY_PERSON_ID,
				RECONCILED_DATE
				,ITEM_DESCR
				<cfif len(#instructions#) gt 0>
					,ITEM_INSTRUCTIONS
				</cfif>
				<cfif len(#remark#) gt 0>
					,LOAN_ITEM_REMARKS
				</cfif>
				       )
			VALUES (
				#TRANSACTION_ID#,
				<cfif #subsample# is 1>
					#n.n#,
				<cfelse>
					#partID#,
				</cfif>		
				#session.myagentid#,
				'#thisDate#'
				,'#meta.collection# #meta.cat_num# #meta.part_name#'
				<cfif len(#instructions#) gt 0>
					,'#instructions#'
				</cfif>
				<cfif len(#remark#) gt 0>
					,'#remark#'
				</cfif>
				)
		</cfquery>		
		<cfquery name="setDisp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			UPDATE coll_object SET coll_obj_disposition = 'on loan'
			where collection_object_id = 
		<cfif #subsample# is 1>
				#n.n#
			<cfelse>
				#partID#
			</cfif>
		</cfquery>
	<cfcatch>
		<cfset result = "0|#cfcatch.message# #cfcatch.detail##cfcatch.sql#">
		<cfreturn result>
	</cfcatch>
	</cftry>
	<cfreturn "1|#partID#">
	</cftransaction>
	</cfoutput>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="getMedia" access="remote">
	<cfargument name="idList" type="string" required="yes">
	<cfset theResult=queryNew("media_id,collection_object_id,media_relationship")>
	<cfset r=1>
	<cfset tableList="cataloged_item,collecting_event">
	<cftry>
	<cfloop list="#idList#" index="cid">
		<cfloop list="#tableList#" index="tabl">
			<cfquery name="mid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select getMediaBySpecimen('#tabl#',#cid#) midList from dual
			</cfquery>
			<cfif len(mid.midList) gt 0>
				<cfset t = queryaddrow(theResult,1)>
				<cfset t = QuerySetCell(theResult, "collection_object_id", "#cid#", r)>
				<cfset t = QuerySetCell(theResult, "media_id", "#mid.midList#", r)>
				<cfset t = QuerySetCell(theResult, "media_relationship", "#tabl#", r)>
				<cfset r=r+1>
			</cfif>
		</cfloop>		
	</cfloop>
	<cfcatch>
				<cfset craps=queryNew("media_id,collection_object_id,media_relationship")>
				<cfset temp = queryaddrow(craps,1)>
				<cfset t = QuerySetCell(craps, "collection_object_id", "12", 1)>
				<cfset t = QuerySetCell(craps, "media_id", "45", 1)>
				<cfset t = QuerySetCell(craps, "media_relationship", "#cfcatch.message# #cfcatch.detail#", 1)>
				<cfreturn craps>
		</cfcatch>
	</cftry>
	<cfreturn theResult>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="getTypes" access="remote">
	<cfargument name="idList" type="string" required="yes">
	<cfset theResult=queryNew("collection_object_id,typeList")>
	<cfset r=1>
	<cftry>
	<cfloop list="#idList#" index="cid">
		<cfquery name="ts" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select type_status from citation where collection_object_id=#cid#
		</cfquery>
		<cfif ts.recordcount gt 0>
			<cfset tl="">
			<cfloop query="ts">
				<cfset tl=listappend(tl,ts.type_status,";")> 
			</cfloop>
			<cfset t = queryaddrow(theResult,1)>
			<cfset t = QuerySetCell(theResult, "collection_object_id", "#cid#", r)>
			<cfset t = QuerySetCell(theResult, "typeList", "#tl#", r)>
			<cfset r=r+1>
		</cfif>		
	</cfloop>
	<cfcatch>
		<cfset t = queryaddrow(theResult,1)>
		<cfset t = QuerySetCell(theResult, "collection_object_id", "-1", 1)>
		<cfset t = QuerySetCell(theResult, "typeList", "#cfcatch.detail#", 1)>
	</cfcatch>
	</cftry>
	<cfreturn theResult>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="saveSearch" access="remote">
	<cfargument name="returnURL" type="string" required="yes">
	<cfargument name="srchName" type="string" required="yes">
	<cfset srchName=urldecode(srchName)>
	<cftry>
		<cfquery name="me" datasource="cf_dbuser">
			select user_id
			from cf_users
			where username='#session.username#'
		</cfquery>
		<cfquery name="alreadyGotOne" datasource="cf_dbuser">
			select search_name
			from cf_canned_search
			where search_name='#srchName#'
		</cfquery>
		<cfif len(alreadyGotOne.search_name) gt 0>
			<cfset msg="The name of your saved search is already in use.">
		<cfelse>
			<cfquery name="alreadyThere" datasource="cf_dbuser">
				select search_name
				from cf_canned_search
				where user_id=#me.user_id# and
				url='#returnURL#'
			</cfquery>
			<cfif len(alreadyThere.search_name) gt 0>
				<cfset msg="That search is already saved as '#alreadyThere.search_name#'.">
			<cfelse>
				<cfquery name="i" datasource="cf_dbuser">
					insert into cf_canned_search (
					user_id,
					search_name,
					url
					) values (
					 #me.user_id#,
					 '#srchName#',
					 '#returnURL#')
				</cfquery>
				<cfset msg="success">
			</cfif>
		</cfif>
	<cfcatch>
		<cfset msg="An error occured while saving your search: #cfcatch.message# #cfcatch.detail#">
	</cfcatch>
	</cftry>
	<cfreturn msg>
</cffunction>
<!------------------------------------->
<cffunction name="changeresultSort" access="remote">
	<cfargument name="tgt" type="string" required="yes">
	<cftry>
			<cfquery name="up" datasource="cf_dbuser">
				UPDATE cf_users SET
					result_sort = '#tgt#'
				WHERE username = '#session.username#'
			</cfquery>
			<cfset session.result_sort = "#tgt#">
		<cfset result="success">
	<cfcatch>
		<cfset result = "#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="changekillRows" access="remote">
	<cfargument name="tgt" type="string" required="yes">
	<cftry>
			<cfif tgt is not 1>
				<cfset tgt=0>
			</cfif>
			<cfquery name="up" datasource="cf_dbuser">
				UPDATE cf_users SET
					KILLROW = #tgt#
				WHERE username = '#session.username#'
			</cfquery>
			<cfset session.KILLROW = "#tgt#">
		<cfset result="success">
	<cfcatch>
		<cfset result = "#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!----------------------------------------------------------------------------------------->	
<cffunction name="changedisplayRows" access="remote">
	<cfargument name="tgt" type="string" required="yes">
	<cftry>
			<cfquery name="up" datasource="cf_dbuser">
				UPDATE cf_users SET
					displayrows = #tgt#
				WHERE username = '#session.username#'
			</cfquery>
			<cfset session.displayrows = "#tgt#">
		<cfset result="success">
	<cfcatch>
		<cfset result = "#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!----------------------------------------------------------------------------------------->	
<cffunction name="setSrchVal" access="remote">
	<cfargument name="name" type="string" required="yes">
	<cfargument name="tgt" type="numeric" required="yes">
	<cftry>
			<cfquery name="up" datasource="cf_dbuser">
				UPDATE cf_users SET
					#name# = 
					#tgt#
				WHERE username = '#session.username#'
			</cfquery>
			<cfif #tgt# is 1>
				<cfset session.searchBy="#session.searchBy#,#name#">
			<cfelse>
				<cfset i = listfindnocase(session.searchBy,name,",")>
				<cfif i gt 0>
					<cfset session.searchBy=listdeleteat(session.searchBy,i)>
				</cfif>
			</cfif>
		<cfset result="success">
	<cfcatch>
		<cfset result = "#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!----------------------------------------------------------------------------------------->
<cffunction name="changeAttDetr" returntype="string">
	<cfargument name="attribute_id" type="numeric" required="yes">
	<cfargument name="i" type="numeric" required="yes">
	<cfargument name="attribute_determiner" type="string" required="yes">
	  	<cfquery name="names" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select agent_name,agent_id
			from preferred_agent_name
			where upper(agent_name) like '%#ucase(attribute_determiner)#%'
		</cfquery>
		<cfif #names.recordcount# is 0>
			<cfset result = "Nothing matched.">
		<cfelseif #names.recordcount# is 1>
			<cftry>
				<cfquery name="upatt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					update attributes set DETERMINED_BY_AGENT_ID = #names.agent_id#
					where attribute_id = #attribute_id#		 
				</cfquery>
				<cfset result = '#i#::#names.agent_name#'>
			<cfcatch>
				<cfset result = 'A database error occured!'>
			</cfcatch>
			</cftry>			
		<cfelse>
			<cfset result = "#i#::">
			<cfloop query="names">
				<cfset result = "#result#|#agent_name#">
			</cfloop>
		</cfif>
	  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>
<!----------------------------------------------------------------------------------------->
<!----------------------------------------------------------------------------------------->
<cffunction name="changeAttDetrId" access="remote">
	<cfargument name="attribute_id" type="numeric" required="yes">
	<cfargument name="i" type="numeric" required="yes">
	<cfargument name="agent_id" type="numeric" required="yes">
	<cfquery name="names" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select agent_name,agent_id
		from preferred_agent_name
		where agent_id = #agent_id#
	</cfquery>
	<cfif #names.recordcount# is 0>
		<cfset result = "Nothing matched.">
	<cfelseif #names.recordcount# is 1>
		<cftry>
			<cfquery name="upatt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				update attributes set DETERMINED_BY_AGENT_ID = #names.agent_id#
				where attribute_id = #attribute_id#		 
			</cfquery>
			<cfset result = '#i#::#names.agent_name#'>
		<cfcatch>
			<cfset result = 'A database error occured!'>
		</cfcatch>
		</cftry>			
	<cfelse>
		<cfset result = "#i#::">
		<cfloop query="names">
			<cfset result = "#result#|#agent_name#">
		</cfloop>
	</cfif>
	<cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
	<cfreturn result>
</cffunction>
<!----------------------------------------------------------------------------------------->
<cffunction name="addAnnotation" access="remote">
	<cfargument name="collection_object_id" type="numeric" required="yes">
	<cfargument name="scientific_name" type="string" required="yes">
	<cfargument name="higher_geography" type="string" required="yes">
	<cfargument name="specific_locality" type="string" required="yes">
	<cfargument name="annotation_remarks" type="string" required="yes">
	<cfinclude template="/includes/functionLib.cfm">
	<cftry>
		<cfset sql = "insert into specimen_annotations (
				collection_object_id,
				cf_username">
		<cfif len(#higher_geography#) gt 0 and #higher_geography# is not "Annotate">
			<cfset sql = "#sql#,higher_geography">
		</cfif>
		<cfif len(#scientific_name#) gt 0 and #scientific_name# is not "Annotate">
			<cfset sql = "#sql#,scientific_name">
		</cfif>
		<cfif len(#specific_locality#) gt 0 and #specific_locality# is not "Annotate">
			<cfset sql = "#sql#,specific_locality">
		</cfif>
		<cfif len(#annotation_remarks#) gt 0 and #annotation_remarks# is not "Annotate">
			<cfset sql = "#sql#,annotation_remarks">
		</cfif>
		<cfset sql = "#sql# ) values (
				#collection_object_id#,
				'#session.username#'">		
		<cfif len(#higher_geography#) gt 0 and #higher_geography# is not "Annotate">
			<cfset sql = "#sql#,'#stripQuotes(urldecode(higher_geography))#'">
		</cfif>
		<cfif len(#scientific_name#) gt 0 and #scientific_name# is not "Annotate">
			<cfset sql = "#sql#,'#stripQuotes(urldecode(scientific_name))#'">
		</cfif>
		<cfif len(#specific_locality#) gt 0 and #specific_locality# is not "Annotate">
			<cfset sql = "#sql#,'#stripQuotes(urldecode(specific_locality))#'">
		</cfif>
		<cfif len(#annotation_remarks#) gt 0 and #annotation_remarks# is not "Annotate">
			<cfset sql = "#sql#,'#stripQuotes(urldecode(annotation_remarks))#'">
		</cfif>	
		<cfset sql = "#sql# )">
		<cfquery name="insAnn" datasource="uam_god">
			#preservesinglequotes(sql)#
		</cfquery>
		<cfquery name="whoTo" datasource="uam_god">
			select
				address
			FROM
				cataloged_item,
				collection,
				collection_contacts,
				electronic_address
			WHERE
				cataloged_item.collection_id = collection.collection_id AND
				collection.collection_id = collection_contacts.collection_id AND
				collection_contacts.contact_agent_id = electronic_address.agent_id AND
				collection_contacts.CONTACT_ROLE = 'data quality' and
				electronic_address.ADDRESS_TYPE='e-mail' and
				cataloged_item.collection_object_id=#collection_object_id#
		</cfquery>
		<cfif len(#whoTo.address#) gt 0>
			<cfset mailTo = valuelist(whoTo.address)>
		<cfelse>	
			<cfset mailTo = #Application.bugReportEmail#>
		</cfif>		
		<cfmail to="#mailTo#" from="annotation@#Application.fromEmail#" subject="Annotation Submitted" type="html">
			Arctos User #session.username# has submitted a specimen annotation. View details at
			<a href="#Application.ServerRootUrl#/info/annotate.cfm?action=show&collection_object_id=#collection_object_id#">
			#Application.ServerRootUrl#/info/annotate.cfm?action=show&collection_object_id=#collection_object_id#
			</a>
		</cfmail>	
	<cfcatch>
		<cfset result = "A database error occured: #cfcatch.message# #cfcatch.detail# #sql#">
		<cfreturn result>
	</cfcatch>
	</cftry>
	<cfset result = "success">
	<cfreturn result>	
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="changeshowObservations" access="remote">
	<cfargument name="tgt" type="string" required="yes">
	<cfif #tgt# is "true">
		<cfset t = 1>
	<cfelse>
		<cfset t = 0>
	</cfif>
	<cftry>
		<cfquery name="up" datasource="cf_dbuser">
			UPDATE cf_users SET
				showObservations = #t#
			WHERE username = '#session.username#'
		</cfquery>
		<cfset session.showObservations = "#t#">
		<cfset result="success">
		<cfcatch>
			<cfset result = "#cfcatch.Message# #cfcatch.Detail#">
		</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="saveSpecSrchPref" access="remote">
	<cfargument name="id" type="string" required="yes">
	<cfargument name="onOff" type="numeric" required="yes">
	<cfif isdefined("session.username") and len(#session.username#) gt 0>
		<cftry>
			<cfquery name="ins" datasource="cf_dbuser">
				select specsrchprefs from cf_users
				where username='#session.username#'
			</cfquery>
			<cfset cv=valuelist(ins.specsrchprefs)>
			<cfif onOff is 1>
				<cfif not listfind(cv,id)>
					<cfset nv=listappend(cv,id)>
				</cfif>
			<cfelse>
				<cfif listfind(cv,id)>
					<cfset nv=listdeleteat(cv,listfind(cv,id))>
				</cfif>
			</cfif>
			<cfquery name="ins" datasource="cf_dbuser">
				update cf_users set specsrchprefs='#nv#'
				where username='#session.username#'
			</cfquery>
			<cfcatch><!-- nada --></cfcatch>
		</cftry>
		<cfreturn "saved">
	</cfif>
	<cfreturn "cookie,#id#,#onOff#">
</cffunction>
<!-------------------------------------------->
</cfcomponent>