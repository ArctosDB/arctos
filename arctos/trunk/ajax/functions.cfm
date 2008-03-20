<!--- hint="type=keyvalue, jsreturn=array , listdelimiter=| , delimiter='='" --->
<cfinclude template="/ajax/core/cfajax.cfm">
<cffunction name="suggestGeologyAttribute" returntype="query">
	<cfargument name="searchString" type="string" required="yes">
		<cfquery name="ins" datasource="#Application.web_user#">
			SELECT geology_attribute
		FROM ctgeology_attribute
		WHERE upper(geology_attribute) LIKE '#ucase(searchString)#%'
		</cfquery>
	<cfreturn ins>

</cffunction>
<cffunction name="suggestGeologyAttVal" returntype="query">
	<cfargument name="searchString" type="string" required="yes">
		<cfquery name="ins" datasource="#Application.web_user#">
			SELECT attribute_value
		FROM geology_attribute_hierarchy
		WHERE upper(attribute_value) LIKE '#ucase(searchString)#%'
		group by attribute_value
		</cfquery>
	<cfreturn ins>

</cffunction>
<cffunction name="getSessionTimeout" returntype="string">
	<cfif isdefined("client.username") and len(#client.username#) gt 0>
		<cfif isdefined("cookie.ArctosSession")>
			<cfset thisTime = #dateconvert('local2Utc',now())#>
			<cfset cookieTime = #cookie.ArctosSession#>		
			<cfset cage = DateDiff("n",cookieTime, thisTime)>
			<cfset tleft = Application.session_timeout - cage>
		<cfelse>
			<!--- log them out immediately --->
			<cfcookie name="ArctosSession" value="-" expires="NOW" domain="#Application.domain#" path="/">
			<cfset tleft=0>
		</cfif>
		
		<cfif tleft lt 5>
			<cfset err = "Your Arctos session is expiring soon.\n
				You will lose all unsaved data in #tleft# minutes.\n
				Save changes immediately to avoid data loss.">
			<script>
				alert('#err#');
			</script>
		<cfelse>
			<cfset err = "test;;Your Arctos session is expiring soon.\n
				You will lose all unsaved data in #tleft# minutes.\n
				Save changes immediately to avoid data loss.">
			<script>
				alert('#err#');
			</script>
		
		</cfif> 
		
		<cfreturn tleft>
	<cfelse>
		<!--- nobody logged in here - no reason to expire anything --->
		<cfreturn "">
	</cfif>
</cffunction>
<!-------------------------------------------->

<cffunction name="setUserFormAccess" returntype="string">
	<cfargument name="role" type="string" required="yes">
	<cfargument name="form" type="string" required="yes">
	<cfargument name="onoff" type="string" required="yes">
	<cfif onoff is "true">
		<cfquery name="ins" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			insert into cf_form_permissions (form_path,role_name) values ('#form#','#role#')
		</cfquery>
	<cfelseif onoff is "false">
		<cfquery name="ins" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			delete from cf_form_permissions where
				form_path = '#form#' and
				role_name = '#role#'
		</cfquery>
	<cfelse>
		<cfreturn "Error:invalud state">			 
	</cfif>
	<cfreturn "Success:#form#:#role#:#onoff#">
</cffunction>
<!-------------------------------------------->
<cffunction name="getCatalogedItemCitation" returntype="query">
	<cfargument name="collection_id" type="numeric" required="yes">
	<cfargument name="cat_num" type="numeric" required="yes">
	<cfoutput>
	<cftry>
	<cfquery name="result" datasource="#Application.web_user#">
		select 
			cataloged_item.COLLECTION_OBJECT_ID,
			scientific_name
		from
			cataloged_item,
			identification
		where
			cataloged_item.collection_object_id = identification.collection_object_id AND
			accepted_id_fg=1 and
			cat_num=#cat_num# and
			collection_id=#collection_id#
	</cfquery>
		<cfcatch>
			<cfset result = querynew("collection_object_id,scientific_name")>
			<cfset temp = queryaddrow(result,1)>
			<cfset temp = QuerySetCell(result, "collection_object_id", "-1", 1)>
			<cfset temp = QuerySetCell(result, "scientific_name", "#cfcatch.Message# #cfcatch.Detail#", 1)>
		</cfcatch>
	</cftry>
	<cfreturn result>
	</cfoutput>
</cffunction>

<cffunction name="addPartToLoan" returntype="string">
	<cfargument name="transaction_id" type="numeric" required="yes">
	<cfargument name="partID" type="numeric" required="yes">
	<cfargument name="remark" type="string" required="yes">
	<cfargument name="instructions" type="string" required="yes">
	<cfargument name="subsample" type="numeric" required="yes">
	<cfoutput>
	<cftransaction>
	<cftry>
		<cfquery name="RECONCILED_BY_PERSON_ID" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			select agent_id from agent_name where agent_name = '#client.username#'
		</cfquery>
		<cfif len(#RECONCILED_BY_PERSON_ID.agent_id#) is 0>
			<cfset result = "0|You are not logged in as a recognized agent.">
			<cfreturn result>
		</cfif>
		<cfset thisDate = dateformat(now(),"dd-mmm-yyyy")>
<cfquery name="meta" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
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
		<!--- make a subsample --->
		<cfquery name="nextID" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			select max(collection_object_id) + 1 as nextID from coll_object
		</cfquery>
		
		<cfquery name="parentData" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
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
		<cfquery name="newCollObj" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
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
				(#nextID.nextID#,
				'SS',
				#RECONCILED_BY_PERSON_ID.agent_id#,
				'#thisDate#',
				#RECONCILED_BY_PERSON_ID.agent_id#,
				'#thisDate#',
				'#parentData.coll_obj_disposition#',
				1,
				'#parentData.condition#')
		</cfquery>
		<cfquery name="newPart" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
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
				#nextID.nextID#
				,'#parentData.part_name#'
				<cfif len(#parentData.PART_MODIFIER#) gt 0>
					,'#parentData.PART_MODIFIER#'
				</cfif>
				,#meta.collection_object_id#
				<cfif len(#parentData.PRESERVE_METHOD#) gt 0>
					,'#parentData.PRESERVE_METHOD#'
				</cfif>
				,#parentData.derived_from_cat_item#,
				#parentData.is_tissue#)				
		</cfquery>
		
	
	</cfif>
	<cfquery name="addLoanItem" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
	
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
			#nextID.nextID#,
		<cfelse>
			#partID#,
		</cfif>		
		#RECONCILED_BY_PERSON_ID.agent_id#,
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
		
		<cfquery name="setDisp" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			UPDATE coll_object SET coll_obj_disposition = 'on loan'
			where collection_object_id = 
		<cfif #subsample# is 1>
				#nextID.nextID#
			<cfelse>
				#partID#
			</cfif>
		</cfquery>
<cfcatch>
<cfset result = "0|#cfcatch.message# #cfcatch.detail#">
			<cfreturn result>
</cfcatch>
</cftry>
<cfreturn "1|#partID#">


</cftransaction>


	</cfoutput>
</cffunction>
<cffunction name="getLoanPartResults" returntype="query">
	<cfargument name="transaction_id" type="numeric" required="yes">
	<cfoutput>
	<cfset userTableName = "SearchResults_#cfid#_#cftoken#">
	<cfquery name="result" datasource="#Application.web_user#">
		select 
			cataloged_item.COLLECTION_OBJECT_ID,
			specimen_part.collection_object_id partID,
			COLL_OBJ_DISPOSITION,
			LOT_COUNT,
			CONDITION,
			PART_NAME,
			PART_MODIFIER,
			SAMPLED_FROM_OBJ_ID,
			PRESERVE_METHOD,
			IS_TISSUE,
			concatEncumbrances(cataloged_item.collection_object_id) as encumbrance_action,
			transaction_id
		from
			#userTableName#,
			cataloged_item,
			coll_object,
			specimen_part,
			(select * from loan_item where transaction_id = #transaction_id#) loan_item
		where
			#userTableName#.collection_object_id = cataloged_item.collection_object_id AND
			cataloged_item.collection_object_id = specimen_part.derived_from_cat_item AND
			specimen_part.collection_object_id =coll_object.collection_object_id and
			specimen_part.SAMPLED_FROM_OBJ_ID is null and
			specimen_part.collection_object_id = loan_item.collection_object_id (+) 
		order by
			cataloged_item.collection_object_id, part_name
	</cfquery>
	<cfreturn result>
	</cfoutput>
</cffunction>

<cffunction name="removeItems" returntype="string">
	<cfargument name="removeList" type="string" required="yes">
	<cfoutput>
	<cfquery name="remove" datasource="#Application.web_user#">
		delete from SearchResults_#cfid#_#cftoken# where
		collection_object_id IN (#removeList#)
	</cfquery>
	<cfreturn "spiffy">
	</cfoutput>
</cffunction>

<cffunction name="getSpecResultsData" returntype="query">
	<cfargument name="startrow" type="numeric" required="yes">
	<cfargument name="numRecs" type="numeric" required="yes">
	<cfargument name="orderBy" type="string" required="yes">
	<cfset stopRow = startrow + numRecs -1>
	<!--- strip Safari idiocy --->
	<cfset orderBy=replace(orderBy,"%20"," ","all")>
	<cfset orderBy=replace(orderBy,"%2C",",","all")>
	<cftry>
		<cfquery name="result" datasource="#Application.web_user#">
			Select * from (
				Select a.*, rownum rnum From (
					select * from SEARCHRESULTS_#CFID#_#CFTOKEN# order by #orderBy#
				) a where rownum <= #stoprow#
			) where rnum >= #startrow#
		</cfquery>
		<cfquery name="cols" datasource="#Application.web_user#">
			 select column_name from user_tab_cols where 
			 upper(table_name)=upper('SEARCHRESULTS_#CFID#_#CFTOKEN#') order by internal_column_id
		</cfquery>
		<!--- return the columns we got in the query --->
		<cfset clist = result.columnList>
		<cfset t = arrayNew(1)>
		<cfset temp = queryaddcolumn(result,"columnList",t)>
		<cfset temp = QuerySetCell(result, "columnList", "#valuelist(cols.column_name)#", 1)>


		<!---
		<cfquery name="result" datasource="#Application.web_user#">
			select -1 collection_object_id,'Select * from (
				Select a.*, rownum rnum From (
					select * from SEARCHRESULTS_#CFID#_#CFTOKEN# order by #orderBy# #orderOrder#
				) a where rownum <= #startrow#
			) where rnum >= #stoprow#' message from dual
		</cfquery>
		
		
	--->
	<cfcatch>
			<cfset result = querynew("collection_object_id,message")>
			<cfset temp = queryaddrow(result,1)>
			<cfset temp = QuerySetCell(result, "collection_object_id", "-1", 1)>
			<cfset temp = QuerySetCell(result, "message", "#cfcatch.Message# #cfcatch.Detail#", 1)>
		</cfcatch>
		
	</cftry>

	<cfreturn result>
</cffunction>

<!--------------
	<cftry>
		<cfquery name="tieRef" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			update greffy set refset_id=#refset_id# where gref_id=#gref_id#
		</cfquery>
		<cfcatch>
			<cfset result="There was a problem saving your refset!">
		</cfcatch>
		<cfset result='success'>
	</cftry>
	----------------------->
<cffunction name="ssvar" returntype="string">
	<cfargument name="startrow" type="numeric" required="yes">
	<cfargument name="maxrows" type="numeric" required="yes">
	<cfset session.maxrows=#maxrows#>
	<cfset session.startrow=#startrow#>
	<cfset result="ok">
	<cfreturn result>
</cffunction>
<cffunction name="clientResultColumnList" returntype="string">
	<cfargument name="ColumnList" type="string" required="yes">
	<cfargument name="in_or_out" type="string" required="yes">
	<cfif not isdefined("client.ResultColumnList")>
		<cfset client.ResultColumnList=''>
	</cfif>
	<cfset result="OK">
	<cfif in_or_out is "in">
		<cfloop list="#ColumnList#" index="i">
		<cfif not ListFindNoCase(client.resultColumnList,i,",")>
			<cfset client.resultColumnList = ListAppend(client.resultColumnList, i,",")>
		</cfif>
		</cfloop>
	<cfelse>
		<cfloop list="#ColumnList#" index="i">
		<cfif ListFindNoCase(client.resultColumnList,i,",")>
			<cfset client.resultColumnList = ListDeleteAt(client.resultColumnList, ListFindNoCase(client.resultColumnList,i,","),",")>
		</cfif>
		</cfloop>
	</cfif>
	<cfquery name ="upDb" datasource="#Application.web_user#">
		update cf_users set resultcolumnlist='#client.resultColumnList#' where
		username='#client.username#'
	</cfquery>
	<cfreturn result>
</cffunction>


<!---
<cffunction name="clientResultColumnList" returntype="string">
	<cfargument name="ColumnList" type="string" required="yes">
	<cfargument name="in_or_out" type="string" required="yes">
	<cfif not isdefined("client.ResultColumnList")>
		<cfset client.ResultColumnList=''>
	</cfif>
	<cfset crl=client.ResultColumnList>
	<cfif in_or_out is "in">
		<cfif not ListContainsNoCase(client.resultColumnList,ColumnList)>
			<cfset crl = ListAppend(client.resultColumnList, ColumnList)>
		</cfif>
	<cfelse>
		<cfif ListContainsNoCase(client.resultColumnList,ColumnList)>
			<cfset crl = ListDeleteAt(client.resultColumnList, ListFindNoCase(client.resultColumnList,ColumnList))>
		</cfif>
	</cfif>
	<cfset client.resultColumnList = crl>
	<cfquery name ="upDb" datasource="#Application.web_user#">
		update cf_users set resultcolumnlist='#crl#' where
		username='#client.username#'
	</cfquery>
	<cfreturn "ok">
</cffunction>

---->

<cffunction name="setClientDetailLevel" returntype="string">
	<cfargument name="detail_level" type="numeric" required="yes">
	<cfargument name="map_url" type="string" required="yes">
	<cfset client.detail_level=#detail_level#>
	<cfset result="ok">
	<cfreturn "#detail_level#|#map_url#">
</cffunction>

<cffunction name="setSrchVal" returntype="string">
	<cfargument name="name" type="string" required="yes">
	<cfargument name="tgt" type="numeric" required="yes">
	<cftry>
			<cfquery name="up" datasource="#Application.web_user#">
				UPDATE cf_users SET
					#name# = 
					#tgt#
				WHERE username = '#client.username#'
			</cfquery>
			<cfif #tgt# is 1>
				<!--- just add it --->
				<cfset client.searchBy="#client.searchBy#,#name#">
			<cfelse>
				<cfset i = listfindnocase(client.searchBy,name,",")>
				<cfif i gt 0>
					<cfset client.searchBy=listdeleteat(client.searchBy,i)>
				</cfif>
			</cfif>
		<cfset result="success">
	<cfcatch>
		<cfset result = "#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<cffunction name="changedetail_level" returntype="string">
	<cfargument name="tgt" type="numeric" required="yes">
	<cftry>
			<cfquery name="up" datasource="#Application.web_user#">
				UPDATE cf_users SET
					detail_level = 
					#tgt#
				WHERE username = '#client.username#'
			</cfquery>
			<cfset client.detail_level = "#tgt#">
		<cfset result="success">
	<cfcatch>
		<cfset result = "#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<cffunction name="changecustomOtherIdentifier" returntype="string">
	<cfargument name="tgt" type="string" required="yes">
	<cftry>
			<cfquery name="up" datasource="#Application.web_user#">
				UPDATE cf_users SET
					customOtherIdentifier = 
					<cfif len(#tgt#) gt 0>
						'#tgt#'
					<cfelse>
						NULL
					</cfif>
				WHERE username = '#client.username#'
			</cfquery>
			<cfset client.customOtherIdentifier = "#tgt#">
		<cfset result="success">
	<cfcatch>
		<cfset result = "#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>


<cffunction name="changeshowObservations" returntype="string">
	<cfargument name="tgt" type="string" required="yes">
	<cfif #tgt# is "true">
		<cfset t = 1>
	<cfelse>
		<cfset t = 0>
	</cfif>
	<cftry>
			<cfquery name="up" datasource="#Application.web_user#">
				UPDATE cf_users SET
					showObservations = #t#
				WHERE username = '#client.username#'
			</cfquery>
			<cfset client.showObservations = "#t#">
		<cfset result="success">
	<cfcatch>
		<cfset result = "#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<cffunction name="changeexclusive_collection_id" returntype="string">
	<cfargument name="tgt" type="string" required="yes">
	<cftry>
			<cfquery name="up" datasource="#Application.web_user#">
				UPDATE cf_users SET
					exclusive_collection_id = 
					<cfif #tgt# gt 0>
						#tgt#
					<cfelse>
						NULL
					</cfif>
				WHERE username = '#client.username#'
			</cfquery>
			<cfif #tgt# gt 0>
				<cfset client.exclusive_collection_id = "#tgt#">
			<cfelse>
				<cfset client.exclusive_collection_id = "">
			</cfif>
		<cfset result="success">
	<cfcatch>
		<cfset result = "#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!------------------------------------->
<cffunction name="changedisplayRows" returntype="string">
	<cfargument name="tgt" type="string" required="yes">
	<cftry>
			<cfquery name="up" datasource="#Application.web_user#">
				UPDATE cf_users SET
					displayrows = #tgt#
				WHERE username = '#client.username#'
			</cfquery>
			<cfset client.displayrows = "#tgt#">
		<cfset result="success">
	<cfcatch>
		<cfset result = "#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>

<cffunction name="changeTarget" returntype="string">
	<cfargument name="tgt" type="string" required="yes">
	<cftry>
			<cfquery name="up" datasource="#Application.web_user#">
				UPDATE cf_users SET
					target = '#tgt#'
				WHERE username = '#client.username#'
			</cfquery>
			<cfset client.target = "#tgt#">
		<cfset result="success">
	<cfcatch>
		<cfset result = "#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>


 <cffunction name="saveIdentifierChange" returntype="string">
	<cfargument name="idId" type="string" required="yes">
	<cfargument name="newAgentId" type="numeric" required="yes">
	<cfargument name="identification_id" type="numeric" required="yes">
	<cfargument name="agent_id" type="numeric" required="yes">
	<cftry>
			<cfquery name="up" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				update identification_agent set 
				agent_id=#newAgentId#
				where identification_id=#identification_id# 
				and agent_id=#agent_id#
			</cfquery>
		<cfset result="success|#idId#">
	<cfcatch>
		<cfset result = "failure|#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!------------------------------------->


 <cffunction name="deleteIdentification" returntype="string">
	<cfargument name="identification_id" type="numeric" required="yes">
	<cftry>
		<!---
		
		--->
		<cftransaction>
			<cfquery name="delIdTax" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				delete from identification_taxonomy where 
				identification_id=#identification_id#
			</cfquery>
			<cfquery name="delIdA" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				delete from identification_agent where 
				identification_id=#identification_id#
			</cfquery>	
			<cfquery name="delId" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				delete from identification where 
				identification_id=#identification_id#
			</cfquery>
		</cftransaction>
		<cfset result="success|#identification_id#">
	<cfcatch>
		<cfset result = "failure|#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!------------------------------------->
 <cffunction name="flippedAccepted" returntype="string">
	<cfargument name="accepted_id_fg" type="numeric" required="yes">
	<cfargument name="collection_object_id" type="numeric" required="yes">
	<cfargument name="identification_id" type="numeric" required="yes">
	<cftry>
		<cfquery name="flipOld" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			update identification set accepted_id_fg=0
			where
			collection_object_id=#collection_object_id#
		</cfquery>
		<cfquery name="newIdentifier" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			update identification set accepted_id_fg=#accepted_id_fg#
			where
			IDENTIFICATION_ID=#identification_id#
		</cfquery>
		<cfset result="success|#identification_id#::#collection_object_id#">
	<cfcatch>
		<cfset result = "failure|#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!------------------------------------->
 <cffunction name="saveIdRemarks" returntype="string">
	<cfargument name="identification_id" type="numeric" required="yes">
	<cfargument name="remark" type="string" required="yes">
	<cftry>
		<cfquery name="newIdentifier" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			update identification set identification_remarks='#remark#'
			where
			IDENTIFICATION_ID=#identification_id#
		</cfquery>
		<cfset result="success|#identification_id#">
	<cfcatch>
		<cfset result = "failure|#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!------------------------------------->
 <cffunction name="saveNatureOfId" returntype="string">
	<cfargument name="identification_id" type="numeric" required="yes">
	<cfargument name="nature_of_id" type="string" required="yes">
	<cftry>
		<cfquery name="newIdentifier" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			update identification set nature_of_id='#nature_of_id#'
			where
			IDENTIFICATION_ID=#identification_id#
		</cfquery>
		<cfset result="success|#identification_id#::#nature_of_id#">
	<cfcatch>
		<cfset result = "failure|#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!------------------------------------->

<cffunction name="saveIdDateChange" returntype="string">
	<cfargument name="identification_id" type="numeric" required="yes">
	<cfargument name="idDate" type="string" required="yes">
	<cftry>
		<cfquery name="newIdentifier" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			update identification set made_date='#dateformat(idDate,"dd-mmm-yyyy")#'
			where
			IDENTIFICATION_ID=#identification_id#
		</cfquery>
		<cfset result="success|#identification_id#::#dateformat(idDate,"dd mmm yyyy")#">
	<cfcatch>
		<cfset result = "failure|#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!----------------------------->
<cffunction name="removeIdentifier" returntype="string">
	<cfargument name="identification_id" type="numeric" required="yes">
	<cfargument name="agent_id" type="numeric" required="yes">
	<!--- see what the max ID already used is --->
	
	<cftry>
		<cfquery name="newIdentifier" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			delete from identification_agent 
			where
			AGENT_ID=#agent_id# and
			IDENTIFICATION_ID=#identification_id#
		</cfquery>
		<!--- serialize --->
		<cfset result="success|#identification_id#::#agent_id#">
	<cfcatch>
		<cfset result = "failure|#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	
	
	<cfreturn result>
</cffunction>
<!------------------------------------------------------->
<cffunction name="addIdentifier" returntype="string">
	<cfargument name="inpBox" type="string" required="yes">
	<cfargument name="id_id" type="numeric" required="yes">
	<cfargument name="agent_id" type="numeric" required="yes">
	<!--- see what the max ID already used is --->
	<cfquery name="i" datasource="#Application.web_user#">
		select max(IDENTIFIER_ORDER) mio from identification_agent
		where identification_id=#id_id#
	</cfquery>
	<cfif #len(i.mio)#  is 0>
		<cfset nextInLine = 1>
	<cfelse>
		<cfset nextInLine = i.mio + 1>
	</cfif>
	<!--- insert --->
	<cftry>
		<cfquery name="newIdentifier" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			insert into identification_agent (IDENTIFICATION_ID,AGENT_ID,IDENTIFIER_ORDER)
			values (#id_id#,#agent_id#,#nextInLine#)
		</cfquery>
		<cfquery name="getName" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			select agent_name from preferred_agent_name where agent_id=#agent_id#
		</cfquery>
		<cfset result="success|#inpBox#::#id_id#::#getName.agent_name#::#nextInLine#::#agent_id#">
	<cfcatch>
		<cfset result = "failure|#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!------------------------------------------------------->

<cffunction name="kill_canned_search" returntype="string">
	<cfargument name="canned_id" type="numeric" required="yes">
	<cftry>
		<cfquery name="res" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			delete from cf_canned_search where canned_id=#canned_id#
		</cfquery>
		<cfset result="#canned_id#">
	<cfcatch>
		<cfset result = "failure: #cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
		<cfreturn result>
</cffunction>
<!---------------------------------->
<cffunction name="get_sql_result" returntype="query">
	<cfargument name="sql" type="string" required="yes">
	<cfargument name="id" type="string" required="yes">
	<cftry>
		<cfquery name="res" datasource="#Application.web_user#">
			#preservesinglequotes(sql)#			
		</cfquery>
	<cfcatch>
		<cfset result = querynew("recordcount,result,id")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "recordcount", "0", 1)>
		<cfset temp = QuerySetCell(result, "result", "#cfcatch.Message# #cfcatch.Detail#", 1)>
		<cfset temp = QuerySetCell(result, "id", "#id#", 1)>
	</cfcatch>
	</cftry>
	<cfif #res.recordcount# is 0>
		<cfset result = querynew("recordcount,result,id")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "recordcount", "0", 1)>
		<cfset temp = QuerySetCell(result, "result", "Your search returned no results.", 1)>		
		<cfset temp = QuerySetCell(result, "id", "#id#", 1)>
	<cfelseif #res.recordcount# is 1>
		<cfset result = querynew("recordcount,result,id")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "recordcount", "1", 1)>
		<cfset temp = QuerySetCell(result, "result", "#res.value#", 1)>	
		<cfset temp = QuerySetCell(result, "id", "#id#", 1)>
	<cfelse>
		<cfset result = querynew("recordcount,result,id")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "recordcount", "0", 1)>
		<cfset temp = QuerySetCell(result, "result", "Your search returned #res.recordcount# values.", 1)>	
		<cfset temp = QuerySetCell(result, "id", "#id#", 1)>
	</cfif>
		<cfreturn result>
</cffunction>
<!----------------------------------------->
<cffunction name="getCollectionData" returntype="query">
		<cfquery name="ctInst" datasource="#Application.web_user#">
			SELECT institution_acronym, collection, collection_id FROM collection
			<cfif len(#exclusive_collection_id#) gt 0>
				WHERE collection_id = #exclusive_collection_id#
			</cfif>						
		</cfquery>
		
		
		<cfset result = querynew("name,data,display")>
		<cfset i=1>
		<cfloop query="ctInst">
			<cfset temp = queryaddrow(result,1)>
			<cfset temp = QuerySetCell(result, "name", "collection_id", #i#)>
			<cfset temp = QuerySetCell(result, "data", "#collection_id#", #i#)>			
			<cfset temp = QuerySetCell(result, "display", "#institution_acronym# #collection#", #i#)>
			<cfset i=#i#+1>
		</cfloop>
		<cfreturn result>
</cffunction>
<!----------------------------------------->

<cffunction name="testThis" returntype="string">
		<cfset result="something">
		<cfreturn result>
</cffunction>
<!----------------------------------------->

<cffunction name="updateLoanItemRemarks" returntype="query">
	<cfargument name="part_id" type="numeric" required="yes">
	<cfargument name="transaction_id" type="numeric" required="yes">
	<cfargument name="loan_item_remarks" type="string" required="yes">
	<cftry>
		<cftransaction>
			<cfquery name="upIns" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				update loan_item set
				loan_item_remarks = '#loan_item_remarks#'
				where
				TRANSACTION_ID=#transaction_id# and
				COLLECTION_OBJECT_ID = #part_id#
			</cfquery>
		</cftransaction>
		<cfset result = querynew("part_id,message")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "message", "success", 1)>
	<cfcatch>
		<cfset result = querynew("part_id,message")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "message", "A query error occured: #cfcatch.Message# #cfcatch.Detail#", 1)>
	</cfcatch>
	
	</cftry>
		<cfreturn result>
</cffunction>
<!------------------------------------------->
<cffunction name="updateInstructions" returntype="query">
	<cfargument name="part_id" type="numeric" required="yes">
	<cfargument name="transaction_id" type="numeric" required="yes">
	<cfargument name="item_instructions" type="string" required="yes">
	<cftry>
		<cftransaction>
			<cfquery name="upIns" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				update loan_item set
				ITEM_INSTRUCTIONS = '#item_instructions#'
				where
				TRANSACTION_ID=#transaction_id# and
				COLLECTION_OBJECT_ID = #part_id#
			</cfquery>
		</cftransaction>
		<cfset result = querynew("part_id,message")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "message", "success", 1)>
	<cfcatch>
		<cfset result = querynew("part_id,message")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "message", "A query error occured: #cfcatch.Message# #cfcatch.Detail#", 1)>
	</cfcatch>
	
	</cftry>
		<cfreturn result>
</cffunction>
<!------------------------------------------->

<cffunction name="del_remPartFromLoan" returntype="query">
	<cfargument name="part_id" type="numeric" required="yes">
	<cfargument name="transaction_id" type="numeric" required="yes">
	<cftry>
		<cftransaction>
			<cfquery name="killPart" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				delete from loan_item where
				collection_object_id = #part_id# and
				transaction_id=#transaction_id#
			</cfquery>		
			<cfquery name="killPart" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				delete from specimen_part where collection_object_id = #part_id#
			</cfquery>
		</cftransaction>
		<cfset result = querynew("part_id,message")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "message", "success", 1)>
	<cfcatch>
		<cfset result = querynew("part_id,message")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "message", "A query error occured: #cfcatch.Message# #cfcatch.Detail#", 1)>
	</cfcatch>
	
	</cftry>
		<cfreturn result>
</cffunction>
<!------------------------------------------->
<cffunction name="remPartFromLoan" returntype="query">
	<cfargument name="part_id" type="numeric" required="yes">
	<cfargument name="transaction_id" type="numeric" required="yes">
	<cftry>
		<cfquery name="killPart" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			delete from loan_item where
			collection_object_id = #part_id# and
			transaction_id=#transaction_id#
		</cfquery>
		<cfset result = querynew("part_id,message")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "message", "success", 1)>
	<cfcatch>
		<cfset result = querynew("part_id,message")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "message", "A query error occured: #cfcatch.Message# #cfcatch.Detail#", 1)>
	</cfcatch>
	
	</cftry>
		<cfreturn result>
</cffunction>
<!------------------------------------------->

<cffunction name="moveContainerLocation" returntype="string">
	<cfargument name="barcode" type="string" required="yes">
	<cfargument name="parent_barcode" type="string" required="yes">
	<cfargument name="timestamp" type="string" required="yes">	
	<cftry>
		<cfquery name="childID" datasource="#Application.web_user#">
			select container_id,barcode,label,container_type from container where barcode = '#barcode#'
		</cfquery>
		<cfquery name="parentID" datasource="#Application.web_user#">
			select container_id,barcode,label,container_type from container where barcode = '#parent_barcode#'
		</cfquery>
		<cfset thisDate = "#dateformat(timestamp,'DD-MMM-YYYY')# #timeformat(timestamp,'HH:mm:ss')#">
		<cfif #childID.recordcount# is not 1>
			<cfset result = "fail|Child container not found.">
			<cfreturn result>
		</cfif> 
		
		<cfif parentID.recordcount is not 1>
			<cfset result = "fail|Parent container not found.">
			<cfreturn result>
		</cfif>
		<cftransaction>
			<cfquery name="alterTime" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				ALTER SESSION set nls_date_format = 'DD-MON-YYYY HH24:MI:SS'
			</cfquery>
			<cfquery name="moveIt" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				update container set parent_container_id=#parentID.container_id#,
				parent_install_date='#thisDate#'
				where
				container_id = #childID.container_id#
			</cfquery>
		</cftransaction>
		<cfset result = "success|#childID.barcode# (#childID.label#, #childID.container_type#) moved to #parentID.barcode# (#parentID.label#, #parentID.container_type#)">
			<cfreturn result>
	<cfcatch>
		<cfset result = "fail|#cfcatch.message#: #cfcatch.Detail#">
		<cfreturn result>
	</cfcatch>
	</cftry>
	
	<!------>
	<cfset result = "bla">
		<cfreturn result>
</cffunction>
<!------------------------------------------->

<cffunction name="updatePartDisposition" returntype="query">
	<cfargument name="part_id" type="numeric" required="yes">
	<cfargument name="disposition" type="string" required="yes">
	<cftry>
		<cfquery name="upPartDisp" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			update coll_object set COLL_OBJ_DISPOSITION
			='#disposition#' where
			collection_object_id=#part_id#
		</cfquery>
		<cfset result = querynew("status,part_id,disposition")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "status", "success", 1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "disposition", "#disposition#", 1)>
	<cfcatch>
		<cfset result = querynew("part_id,disposition")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "status", "failure", 1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "disposition", "A query error occured: #cfcatch.Message# #cfcatch.Detail#", 1)>
	</cfcatch>
	
	</cftry>
		<cfreturn result>
</cffunction>
<!------------------------------------->
<cffunction name="moveContainer" returntype="string">
	<cfargument name="box_position" type="numeric" required="yes">
	<cfargument name="position_id" type="numeric" required="yes">
	<cfargument name="barcode" type="string" required="yes">
	<cfset thisContainerId = "">
	<cfset thisDate = dateformat(now(),"dd-mmm-yyyy")>
	<CFTRY>
		<cfquery name="thisID" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			select container_id,label from container where barcode='#barcode#'
			AND container_type = 'cryovial'		
		</cfquery>
		<cfif #thisID.recordcount# is 0>
			<cfquery name="thisID" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				select container_id,label from container where barcode='#barcode#'
				AND container_type = 'cryovial label'		
			</cfquery>
			<cfif #thisID.recordcount# is 1>
				<cfquery name="update" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
					update container set container_type='cryovial'
					where container_id=#thisID.container_id#
				</cfquery>
				<cfset thisContainerId = #thisID.container_id#>
			</cfif>
		<cfelse>
			<cfset thisContainerId = #thisID.container_id#>	
		</cfif>
		
		<cfif len(#thisContainerId#) gt 0>
			<cfquery name="putItIn" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				update container set
				parent_container_id = #position_id#,
				PARENT_INSTALL_DATE = '#thisDate#'
				where container_id = #thisContainerId#
			</cfquery>
			<cfset result = "#box_position#|#thisID.label#">
		<cfelse>
			<cfset result = "-#box_position#|Container not found.">
		</cfif>
	<cfcatch>
		<cfset result = "-#box_position#|#cfcatch.Message#">
	</cfcatch>
	</CFTRY>
	<cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>
<!------------------------------------------->
<cffunction name="saveEditPart" returntype="query">
	<cfargument name="part_id" type="numeric" required="yes">
	<cfargument name="part_name" type="sring" required="yes">
	<cfargument name="valid_for_items" type="numeric" required="yes">
	<cfargument name="collection_cde" type="string" required="yes">
	<cfargument name="description" type="string" required="yes">
	
	<cfquery name="result" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			select * from part_hierarchy 
			where part_id=#id#
		</cfquery>
		<cfreturn result>
</cffunction>
<!------------------------------------->
<cffunction name="getPartRecDet" returntype="query">
	<cfargument name="id" type="numeric" required="yes">
	<cfquery name="result" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			select * from part_hierarchy 
			where part_id=#id#
		</cfquery>
		<cfreturn result>
</cffunction>
<!------------------------------------->
<cffunction name="movePartInTree" returntype="string">
	<cfargument name="id" type="numeric" required="yes">
	<cfargument name="parent_id" type="numeric" required="yes">
	<cftry>
		<cfquery name="up" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			update part_hierarchy set parent_part_id=#parent_id# 
			where part_id=#id#
		</cfquery>
		<cfset result='success'>
	<cfcatch>
		<cfset result='failure'>
	</cfcatch>
	</cftry>
	
	<cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>
<!------------------------------------->
<cffunction name="getBlankCatNum" returntype="string">
	<cfargument name="coll" type="string" required="yes">
	<cfset theSpace = find(" " ,coll)>
	<cfset inst = trim(left(coll,theSpace))>
	<cfset coll = trim(mid(coll,theSpace,len(coll)))>
	
	<cfquery name="collID" datasource="#Application.web_user#">
		select collection_id from collection where
		institution_acronym='#inst#' and
		collection_cde='#coll#'
	</cfquery>
	<!---
	<cfset i=1>
	<cfset result="">
	<cfloop condition="i lt 200">
		<cfquery name="q" datasource="#Application.web_user#">
			select min(cat_num + #i#) as nextnum
			from cataloged_item t1
			where 
			collection_id=#collID.collection_id# and
			not exists (
			select cat_num
			from cataloged_item t2
			where t2.cat_num = t1.cat_num + #i#
			and collection_id=#collID.collection_id#
			)
		</cfquery>
		<cfquery name="isused" datasource="#Application.web_user#">
			select cat_num from bulkloader where
			cat_num = '#q.nextnum#' and
			institution_acronym='#inst#' and
			collection_cde='#coll#'
		</cfquery>
		<cfif #len(isused.cat_num)# is 0>
			<cfset i=9999999>
			<cfset result = #q.nextnum#>
		<cfelse>
			<cfset i=#i# + 1>		
		</cfif>
</cfloop>
		
		--->
		<cfquery name="a" datasource="#Application.web_user#">
			select max(cat_num) as mc from cataloged_item where collection_id = #collID.collection_id#
		</cfquery>
		<cfquery name="q" datasource="#Application.web_user#">
				select 
				min(num) as num
			from 
				nums 
			where 
				num <= #a.mc# and
				not exists (
					select
						cat_num
					from 
						cataloged_item
					where 
						cat_num=num and
						collection_id = #collID.collection_id#
						
					)
					and not exists(
						select cat_num from bulkloader
						where to_number(cat_num) =num)
					order by num
			</cfquery>
			<cfset result = #q.num#>
		<cfreturn result>
</cffunction>
<!------------------------------------->
<cffunction name="getAccn" returntype="query">
	<cfargument name="inst" type="string" required="yes">
	<cfargument name="prefx" type="string" required="yes">
	
	<cfset y = "#dateformat(now(), "yyyy")#">
	<cfquery name="result" datasource="#Application.web_user#">
		select 
			'#y#' as accn_num_prefix,
			decode(max(accn_num),NULL,'1',max(accn_num) + 1) as nan
			from accn,trans
			where 
			accn.transaction_id=trans.transaction_id and
			institution_acronym='#inst#' and
			accn_num_prefix=
			<cfif len(#prefx#) gt 0>
				'#prefx#'
			<cfelse>
				'#y#'
			</cfif>
	</cfquery>
		<cfreturn result>
</cffunction>
<!-------------------------------------------------------------------->
<cffunction name="getLoan" returntype="query">
	<cfargument name="inst" type="string" required="yes">
	<cfset y = "#dateformat(now(), "yyyy")#">
	<cfquery name="result" datasource="#Application.web_user#">
		select 
			'#y#' as loan_num_prefix,
			decode(max(loan_num),NULL,'1',max(loan_num) + 1) as nln
			from loan,trans
			where 
			loan.transaction_id=trans.transaction_id and
			institution_acronym='#inst#' and
			loan_num_prefix='#y#'
	</cfquery>
		<cfreturn result>
</cffunction>
<!-------------------------------------------------------------------->
<cffunction name="getPreviousBox" returntype="query">
	
	<cfargument name="freezer" type="numeric" required="yes">
	<cfargument name="rack" type="numeric" required="yes">
	<cfargument name="box" type="numeric" required="yes">
	<cftry>
	<cftransaction>
	<cfif #box# is 1>
		<cfif #rack# is 1>
			<cfif #freezer# is 1>
				<cfquery name="result" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
					select 
						0 as freezer,
						0 as box,
						0 as rack
					from dual
				</cfquery>
			<cfelse>
				<cfset tf = #freezer# -1 >
				<cfquery name="pf" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
					select distinct(freezer) from 
					dgr_locator where freezer = #tf#
				</cfquery>
				<cfif #pf.recordcount# is 1>
					<cfquery name="r" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
						select max(rack) as mrack from dgr_locator where 
						freezer = #tf#
					</cfquery>
					<cfquery name="result" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
						select 
							freezer,
							rack,
							max(box) as box
						from dgr_locator where 
						freezer = #tf#
					</cfquery>
				</cfif>
			</cfif>
		</cfif>
	</cfif>
	<cfquery name="newLoc" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
	
	</cfquery>
	<cfquery name="v" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		select dgr_locator_seq.currval as currval from dual
	</cfquery>
	<cfset tv = v.currval>
	<cfquery name="result" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		select LOCATOR_ID,
			FREEZER,
			RACK,
			BOX,
			PLACE,
			NK,
			TISSUE_TYPE from 
		dgr_locator where LOCATOR_ID =#tv#		
	</cfquery>
	</cftransaction>
	<cfcatch>
		<cfquery name="result" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			select 99999999 as LOCATOR_ID from dual
		</cfquery>
	</cfcatch>
	</cftry>
		<cfreturn result>
</cffunction>


<!------------------------------------->
<cffunction name="DGRboxlookup" returntype="query">
	<cfargument name="freezer" type="numeric" required="yes">
	<cfargument name="rack" type="numeric" required="yes">
	
	<cfquery name="result" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		select box from dgr_locator where freezer = #freezer#
		and rack = #rack#
		group by box order by box
	</cfquery>
	<cfreturn result>
</cffunction>
<!------------------------------------->
<cffunction name="DGRracklookup" returntype="query">
	
	<cfargument name="freezer" type="numeric" required="yes">
	
	<cfquery name="result" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		select rack from dgr_locator where freezer = #freezer#
		group by rack order by rack
	</cfquery>
	<cfreturn result>
</cffunction>

<!------------------------------------->
<cffunction name="remNKFromPosn" returntype="string">
	
	<cfargument name="freezer" type="numeric" required="yes">
	<cfargument name="rack" type="numeric" required="yes">
	<cfargument name="box" type="numeric" required="yes">
	<cfargument name="place" type="numeric" required="yes">
	<cfargument name="tissue_type" type="string" required="yes">
	<cfargument name="nk" type="numeric" required="yes">
	<cfset result=#place#>
	<cftry>
	<cftransaction>
	<cfquery name="newLoc" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		delete from dgr_locator
		where  
			freezer=#freezer# AND
			rack= #rack# and
			box = #box# AND
			place = #place# AND
			nk = #nk# AND
			tissue_type = '#tissue_type#'
	</cfquery>
	
	</cftransaction>
	<cfcatch>
		<cfset result=999999>
	</cfcatch>
	</cftry>
		<cfreturn result>
</cffunction>
<!------------------------------------->
<cffunction name="saveNewTiss" returntype="query">
	
	<cfargument name="freezer" type="numeric" required="yes">
	<cfargument name="rack" type="numeric" required="yes">
	<cfargument name="box" type="numeric" required="yes">
	<cfargument name="place" type="numeric" required="yes">
	<cfargument name="nk" type="numeric" required="yes">
	<cfargument name="tissue_type" type="string" required="yes">
	<cftry>
		<cftransaction>
			<cfquery name="v" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				select dgr_locator_seq.nextval as nv from dual
			</cfquery>
			<cfset thisLocId = #v.nv#>
			<cfquery name="newLoc" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				insert into dgr_locator (
					LOCATOR_ID,
					FREEZER,
					RACK,
					BOX,
					PLACE,
					NK,
					TISSUE_TYPE)
				VALUES (
					#thisLocId#,
					#freezer#,
					#rack#,
					#box#,
					#place#,
					#nk#,
					'#tissue_type#')		
			</cfquery>
			<cfset result = querynew("LOCATOR_ID,FREEZER,RACK,BOX,PLACE,NK,TISSUE_TYPE")>
			<cfset temp = queryaddrow(result,1)>
			<cfset temp = QuerySetCell(result, "LOCATOR_ID", "#thisLocId#", 1)>
			<cfset temp = QuerySetCell(result, "FREEZER", "#freezer#", 1)>
			<cfset temp = QuerySetCell(result, "RACK", "#rack#", 1)>
			<cfset temp = QuerySetCell(result, "BOX", "#box#", 1)>
			<cfset temp = QuerySetCell(result, "PLACE", "#place#", 1)>
			<cfset temp = QuerySetCell(result, "NK", "#nk#", 1)>
			<cfset temp = QuerySetCell(result, "TISSUE_TYPE", "#tissue_type#", 1)>
		</cftransaction>
		<cfcatch>
			<cfset result = querynew("LOCATOR_ID,FREEZER")>
			<cfset temp = queryaddrow(result,1)>
			<cfset temp = QuerySetCell(result, "LOCATOR_ID", "99999999", 1)>
			<cfset temp = QuerySetCell(result, "FREEZER", "A query error occured: #cfcatch.Message# #cfcatch.Detail#", 1)>
		</cfcatch>
	</cftry>
		<cfreturn result>
</cffunction>
<!------------------------------------->

<cffunction name="getContacts" returntype="string">
	<cfquery name="contacts" datasource="#Application.web_user#">
		select 
			collection_contact_id,
			contact_role,
			contact_agent_id,
			agent_name contact_name
		from
			collection_contacts,
			preferred_agent_name
		where
			contact_agent_id = agent_id AND
			collection_id = #collection_id#
		ORDER BY contact_name,contact_role
	</cfquery>
		
		<cfset result = 'success'>
		<cfreturn result>
</cffunction>
<!------------------------------------->
<cffunction name="getCollInstFromCollId" returntype="string">
	<cfargument name="collid" type="numeric" required="yes">
	<cftry>
		<cfquery name="getCollId" datasource="#Application.web_user#">
			select collection_cde, institution_acronym from
			collection where collection_id = #collid#
		</cfquery>
		<cfoutput>
		<cfset result = "#getCollId.institution_acronym#|#getCollId.collection_cde#">
		</cfoutput>
	<cfcatch>
		<cfset result = "QUERY FAILED">
	</cfcatch>
	</cftry>
  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
  <cfreturn result>
</cffunction>

<!------------------------------------->
<cffunction name="bulkEditUpdate" returntype="string">
	<cfargument name="theName" type="string" required="yes">
	<cfargument name="theValue" type="string" required="yes">
	<!--- parse name out
		format is field_name__collection_object_id --->
	<cfset hPos = find("__",theName)>
	<cfset theField = left(theName,hPos-1)>
	<cfset theCollObjId = mid(theName,hPos + 2,len(theName) - hPos)>
	<cfset result="#theName#">
	<cftry>
		<cfquery name="upBulk" datasource="#Application.web_user#">
			UPDATE bulkloader SET #theField# = '#theValue#'
			WHERE collection_object_id = #theCollObjId#
		</cfquery>
	<cfcatch>
		<cfset result = "QUERY FAILED">
	</cfcatch>
	</cftry>
  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
  <cfreturn result>


<!--- update bulkloader...<cfset var MyReturn = "bla">
  <cfset var MyString = "name">
  <cfsavecontent variable="result">
    <cfoutput>
    theName #theValue#
    </cfoutput>
  </cfsavecontent>
  
  <cfset result = "#name#||#value#"> 
		<cfoutput>
		<cfset result = "#name#, result">
		</cfoutput>
		<cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
		--->
</cffunction>


<!------------------------------------->

<!------------------------------------->
<cffunction name="checkSessionExists" returntype="boolean">
	<cfif isDefined("session.name") AND session.name NEQ "">
		<cfreturn true>
	<cfelse>
		<cfreturn false>
	</cfif>
</cffunction>