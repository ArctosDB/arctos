<cfinclude template="/ajax/core/cfajax.cfm">
<!------------------------------------>
<cffunction name="agent_lookup" returntype="Any">
	<cfargument name="agent_name" type="string" required="yes">
	<cfargument name="v_f" type="string" required="yes">
	<cfargument name="i_f" type="string" required="yes">
	<cfinclude template="/includes/functionLib.cfm">
	<cftry>
		<cfquery name="aid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT 
				agent_id,
				'#v_f#' v_f,
				'#i_f#' i_f,
			FROM agent_name
			WHERE upper(agent_name) LIKE ('#escapeQuotes(ucase(agent_name))#%')
			group by agent_id
		</cfquery>
		<cfif aid.recordcount is 1>
			<cfreturn aid.agent_id>
		<cfelse>
			<cfreturn -1>
		</cfif>
	<cfcatch>
			<cfreturn -2>
	</cfcatch>
	</cftry>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="saveSearch" returntype="any">
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
<cffunction name="findAccession" returntype="any">
	<cfargument name="collection_id" type="numeric" required="yes">
	<cfargument name="accn_number" type="string" required="yes">
	<cftry>
		<cfquery name="accn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT accn.TRANSACTION_ID FROM accn,trans WHERE
			accn.TRANSACTION_ID=trans.TRANSACTION_ID AND
			accn_number = '#accn_number#' 
			and collection_id = #collection_id#			
		</cfquery>
		<cfif accn.recordcount is 1 and len(accn.transaction_id) gt 0>
			<cfreturn accn.transaction_id>
		<cfelse>
			<cfreturn -1>
		</cfif>
		<cfcatch>
			<cfreturn -1>
		</cfcatch>
	</cftry>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="makePart" returntype="any">
	<cfargument name="collection_object_id" type="string" required="yes">
	<cfargument name="part_name" type="string" required="yes">
	<cfargument name="part_modifier" type="string" required="yes">
	<cfargument name="lot_count" type="string" required="yes">
	<cfargument name="preserve_method" type="string" required="yes">
	<cfargument name="coll_obj_disposition" type="string" required="yes">
	<cfargument name="condition" type="string" required="yes">
	<cfargument name="coll_object_remarks" type="string" required="yes">
	<cfargument name="barcode" type="string" required="yes">
	<cfargument name="new_container_type" type="string" required="yes">
	<cfset thisDate = dateformat(now(),"dd-mmm-yyyy")>
	<cftry>
		<cftransaction>
			<cfquery name="ccid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select sq_collection_object_id.nextval nv from dual
			</cfquery>
			<cfquery name="updateColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				INSERT INTO coll_object (
					COLLECTION_OBJECT_ID,
					COLL_OBJECT_TYPE,
					ENTERED_PERSON_ID,
					COLL_OBJECT_ENTERED_DATE,
					LAST_EDITED_PERSON_ID,
					COLL_OBJ_DISPOSITION,
					LOT_COUNT,
					CONDITION,
					FLAGS )
				VALUES (
					#ccid.nv#,
					'SP',
					#session.myAgentId#,
					'#thisDate#',
					#session.myAgentId#,
					'#COLL_OBJ_DISPOSITION#',
					#lot_count#,
					'#condition#',
					0 )		
			</cfquery>
			<cfquery name="newTiss" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				INSERT INTO specimen_part (
					  COLLECTION_OBJECT_ID,
					  PART_NAME
					  <cfif len(#PART_MODIFIER#) gt 0>
					  		,PART_MODIFIER
					  </cfif>
					  <cfif len(#PRESERVE_METHOD#) gt 0>
					  		,PRESERVE_METHOD
					  </cfif>
						,DERIVED_FROM_cat_item)
					VALUES (
						#ccid.nv#,
					  '#PART_NAME#'
					  <cfif len(#PART_MODIFIER#) gt 0>
					  		,'#PART_MODIFIER#'
					  </cfif>
					  <cfif len(#PRESERVE_METHOD#) gt 0>
					  		,'#PRESERVE_METHOD#'
					  </cfif>
						,#collection_object_id# )
			</cfquery>
			<cfif len(#coll_object_remarks#) gt 0>
				<cfquery name="newCollRem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					INSERT INTO coll_object_remark (collection_object_id, coll_object_remarks)
					VALUES (#ccid.nv#, '#coll_object_remarks#')
				</cfquery>
			</cfif>
			<cfif len(barcode) gt 0>
				<cfquery name="np" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select container_id from coll_obj_cont_hist where collection_object_id=#ccid.nv#
				</cfquery>
				<cfquery name="pc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select container_id from container where barcode='#barcode#'
				</cfquery>
				<cfquery name="m2p" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					update container set parent_container_id=#pc.container_id# where container_id=#np.container_id#
				</cfquery>
				<cfif len(new_container_type) gt 0>
					<cfquery name="uct" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						update container set container_type='#new_container_type#' where
						container_id=#pc.container_id#
					</cfquery>					
				</cfif>
			</cfif>
			<cfset q=queryNew("status,part_name,part_modifier,lot_count,preserve_method,coll_obj_disposition,condition,coll_object_remarks,barcode,new_container_type")>
			<cfset t = queryaddrow(q,1)>
			<cfset t = QuerySetCell(q, "status", "success", 1)>
			<cfset t = QuerySetCell(q, "part_name", "#part_name#", 1)>
			<cfset t = QuerySetCell(q, "part_modifier", "#part_modifier#", 1)>
			<cfset t = QuerySetCell(q, "lot_count", "#lot_count#", 1)>
			<cfset t = QuerySetCell(q, "preserve_method", "#preserve_method#", 1)>
			<cfset t = QuerySetCell(q, "coll_obj_disposition", "#coll_obj_disposition#", 1)>
			<cfset t = QuerySetCell(q, "condition", "#condition#", 1)>
			<cfset t = QuerySetCell(q, "coll_object_remarks", "#coll_object_remarks#", 1)>
			<cfset t = QuerySetCell(q, "barcode", "#barcode#", 1)>
			<cfset t = QuerySetCell(q, "new_container_type", "#new_container_type#", 1)>
		</cftransaction>
		<cfcatch>
			<cfset q=queryNew("status,msg")>
			<cfset t = queryaddrow(q,1)>
			<cfset t = QuerySetCell(q, "status", "error", 1)>
			<cfset t = QuerySetCell(q, "msg", "#cfcatch.message# #cfcatch.detail#:: #ccid.nv#", 1)>
		</cfcatch>
	</cftry>
	<cfreturn q>	
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->


<cffunction name="getSpecimen" returntype="any">
	<cfargument name="collection_id" type="string" required="yes">
	<cfargument name="other_id_type" type="string" required="yes">
	<cfargument name="oidnum" type="string" required="yes">
	<cftry>
		<cfset t="select 
				cataloged_item.collection_object_id
			from 
				cataloged_item">
		<cfset w = "where cataloged_item.collection_id=#collection_id#">
		<cfif other_id_type is not "catalog_number">
			<cfset t=t&" ,coll_obj_other_id_num">
			<cfset w=w & " and cataloged_item.collection_object_id=coll_obj_other_id_num.collection_object_id and
					coll_obj_other_id_num.other_id_type='#other_id_type#' and
					coll_obj_other_id_num.display_value='#oidnum#'">
		<cfelse>
			<cfset w=w & " and cataloged_item.cat_num=#oidnum#">
		</cfif>
		<cfset q = t & " " & w>
		<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			#preservesinglequotes(q)#
		</cfquery>
		<cfif q.recordcount is 0>
			<cfset q=queryNew("collection_object_id")>
			<cfset t = queryaddrow(q,1)>
			<cfset t = QuerySetCell(q, "collection_object_id", "Error: item_not_found", 1)>
		<cfelseif q.recordcount gt 1>
			<cfset q=queryNew("collection_object_id")>
			<cfset t = queryaddrow(q,1)>
			<cfset t = QuerySetCell(q, "collection_object_id", "Error: multiple_matches", 1)>
		</cfif>
	<cfcatch>
		<!---
		<cfset t = queryaddrow(theResult,1)>
		<cfset t = QuerySetCell(theResult, "collection_object_id", "-1", 1)>
		<cfset t = QuerySetCell(theResult, "typeList", "#cfcatch.detail#", 1)>
		<cfreturn theResult>
		--->
		<cfset q=queryNew("collection_object_id")>
		<cfset t = queryaddrow(q,1)>
		<cfset t = QuerySetCell(q, "collection_object_id", "Error: #cfcatch.Message# #cfcatch.detail#", 1)>
	</cfcatch>
	</cftry>
	<cfreturn q>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->

<cffunction name="getParts" returntype="any">
	<cfargument name="collection_id" type="string" required="yes">
	<cfargument name="other_id_type" type="string" required="yes">
	<cfargument name="oidnum" type="string" required="yes">
	<cfargument name="noBarcode" type="string" required="yes">
	<cfargument name="noSubsample" type="string" required="yes">
	<cftry>
		<cfset t="select 
				cataloged_item.collection_object_id,
				specimen_part.collection_object_id partID,
				decode(p.barcode,'0',null,p.barcode) barcode,
				decode(sampled_from_obj_id,
					null,part_name,
					part_name || ' SAMPLE') part_name,
				cat_num,
				collection,
				concatSingleOtherId(cataloged_item.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID,
				'#session.CustomOtherIdentifier#' as CustomIdType
			from 
				specimen_part,
				cataloged_item,
				collection,
				coll_obj_cont_hist,
				container c,
				container p">
		<cfset w = "where 
				specimen_part.derived_from_cat_item = cataloged_item.collection_object_id and 
				cataloged_item.collection_id=collection.collection_id and 
				specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
				coll_obj_cont_hist.container_id=c.container_id and
				c.parent_container_id=p.container_id (+) and
				cataloged_item.collection_id=#collection_id#">
		<cfif other_id_type is not "catalog_number">
			<cfset t=t&" ,coll_obj_other_id_num">
			<cfset w=w & " and cataloged_item.collection_object_id=coll_obj_other_id_num.collection_object_id and
					coll_obj_other_id_num.other_id_type='#other_id_type#' and
					coll_obj_other_id_num.display_value='#oidnum#'">
		<cfelse>
			<cfset w=w & " and cataloged_item.cat_num=#oidnum#">
		</cfif>
		<cfif noBarcode is true>
			<cfset w=w & " and (c.parent_container_id = 0 or c.parent_container_id is null or c.parent_container_id=476089)">
				<!--- 476089 is barcode 0 - our universal trashcan --->
		</cfif>
		<cfif noSubsample is true>
			<cfset w=w & " and specimen_part.SAMPLED_FROM_OBJ_ID is null">
		</cfif>
		<cfset q = t & " " & w & " order by part_name">
		<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			#preservesinglequotes(q)#
		</cfquery>
		<cfquery name="u" dbtype="query">
			select count(distinct(collection_object_id)) c from q
		</cfquery>
		<cfif q.recordcount is 0>
			<cfset q=queryNew("part_name")>
			<cfset t = queryaddrow(q,1)>
			<cfset t = QuerySetCell(q, "part_name", "Error: no_parts_found", 1)>
		</cfif>
		<cfif u.c is not 1>
			<cfset q=queryNew("part_name")>
			<cfset t = queryaddrow(q,1)>
			<cfset t = QuerySetCell(q, "part_name", "Error: #u.c# specimens match", 1)>
		</cfif>
	<cfcatch>
		<!---
		<cfset t = queryaddrow(theResult,1)>
		<cfset t = QuerySetCell(theResult, "collection_object_id", "-1", 1)>
		<cfset t = QuerySetCell(theResult, "typeList", "#cfcatch.detail#", 1)>
		<cfreturn theResult>
		--->
		<cfset q=queryNew("part_name")>
		<cfset t = queryaddrow(q,1)>
		<cfset t = QuerySetCell(q, "part_name", "Error: #cfcatch.Message# #cfcatch.detail#", 1)>
	</cfcatch>
	</cftry>
	<cfreturn q>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="getTypes" returntype="query">
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
<cffunction name="getMedia" returntype="query">
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
<cffunction name="genMD5" returntype="string">
	<cfargument name="uri" type="string" required="yes">
	<!--- for now, only deal with local things --->
	<cfif uri contains application.serverRootUrl>
		<cftry>
		<cfset f=replace(uri,application.serverRootUrl,application.webDirectory)>
		<cffile action="readbinary" file="#f#" variable="myBinaryFile">
		<cfset md5 = createObject("component","includes.cfc.hashBinary").hashBinary(myBinaryFile)>
		<cfreturn md5>
		<cfcatch>
			<cfreturn cfcatch.detail>
		</cfcatch>
		</cftry>
	<cfelse>
		<cfreturn 'bad checksum parameter: need local file'>
	</cfif>
	<cfreturn uri>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="getSetPrevSearch" returntype="string">
	<cfreturn session.schParam>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="setSchParam" returntype="string">
	<cfargument name="str" type="string" required="yes">
	<cftry>
		<cfset session.schParam = "#str#">
		<cfset result="success">
	<cfcatch>
		<cfset result = "#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="changekillRows" returntype="string">
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
<!-------------------------------------------------------------------->
<cffunction name="getCollObjByPart" returntype="query">
	<cfargument name="collection_id" type="numeric" required="yes">
	<cfargument name="other_id_type" type="string" required="yes">
	<cfargument name="oidnum" type="string" required="yes">
	<cfargument name="part_name" type="string" required="yes">
	<cfargument name="noSubsample" type="string" required="yes">
	<cfargument name="noBarcode" type="string" required="yes">
	<cfset s="select 
				cat_num,
				collection,
				collection.collection_cde,
				institution_acronym,
				scientific_name,
				specimen_part.collection_object_id
			FROM
				cataloged_item,
				specimen_part,
				collection,
				identification">
	<cfif noBarcode is "true">
		<cfset s=s & ",coll_obj_cont_hist,container sc, container pc">
	</cfif>
	<cfif #other_id_type# is not "catalog_number">
		<cfset s=s & "coll_obj_other_id_num">
	</cfif>
	<cfset s=s & " WHERE
				cataloged_item.collection_object_id = specimen_part.derived_from_cat_item AND
				cataloged_item.collection_id=collection.collection_id and
				cataloged_item.collection_object_id = identification.collection_object_id and
				accepted_id_fg=1 and
				part_name='#part_name#' and
				collection.collection_id=#collection_id#">
	<cfif #other_id_type# is not "catalog_number">
		<cfset s=s & " and cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id
				and other_id_type='#other_id_type#' AND
					display_value= '#oidnum#' ">
	<cfelse>
		<cfset s=s & " and cat_num=#oidnum#">
	</cfif>
	<cfif noSubsample is "true">
		<cfset s=s & " and SAMPLED_FROM_OBJ_ID is null">
	</cfif>
	<cfif noBarcode is "true">
		<cfset s=s & " and specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
			coll_obj_cont_hist.container_id= sc.container_id and
			sc.parent_container_id=pc.container_id (+) and
			pc.barcode is null">
	</cfif>
	
	<cfif #other_id_type# is "catalog_number">
		<cfquery name="coll_obj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			#preservesinglequotes(s)#
		</cfquery>
	<cfelse>
		<cfquery name="coll_obj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
					cat_num,
					collection,
					collection.collection_cde,
					institution_acronym,
					scientific_name,
					specimen_part.collection_object_id 
				FROM
					cataloged_item,
					specimen_part,
					coll_obj_other_id_num,
					collection,
					identification
				WHERE
					cataloged_item.collection_object_id = specimen_part.derived_from_cat_item AND
					cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id AND
					cataloged_item.collection_id=collection.collection_id and
					cataloged_item.collection_object_id = identification.collection_object_id and
					accepted_id_fg=1 and
					collection.collection_id=#collection_id# AND
					other_id_type='#other_id_type#' AND
					display_value= '#oidnum#' AND
					part_name='#part_name#'\					
					<cfif noSubsample is "true">
						and SAMPLED_FROM_OBJ_ID is null
					</cfif>
			</cfquery>
		</cfif>
		<cfreturn coll_obj>
</cffunction>

<!-------------------------------------------------------------------->
<cffunction name="getDistNoContainerPartId" returntype="query">
	<cfargument name="collection_id" type="numeric" required="yes">
	<cfargument name="other_id_type" type="string" required="yes">
	<cfargument name="oidnum" type="string" required="yes">
	<cfargument name="part_name" type="string" required="yes">
	<cfargument name="noSubsample" type="string" required="yes">	
	<cfif #other_id_type# is "catalog_number">
		<cfquery name="coll_obj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				min(specimen_part.collection_object_id)  part_id
			FROM
				cataloged_item,
				specimen_part,
				coll_obj_cont_hist,
				container
			WHERE
				cataloged_item.collection_object_id = specimen_part.derived_from_cat_item AND
				specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
				coll_obj_cont_hist.container_id=container.container_id and
				(container.parent_container_id is null or
				container.parent_container_id=0) and
				cataloged_item.collection_id=#collection_id# and
				cat_num=#oidnum# AND
				part_name='#part_name#'
				<cfif noSubsample is "true">
					and SAMPLED_FROM_OBJ_ID is null
				</cfif>
		</cfquery>
	<cfelse>
		<cfquery name="coll_obj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				min(specimen_part.collection_object_id) part_id
			FROM
				cataloged_item,
				specimen_part,
				coll_obj_other_id_num,
				coll_obj_cont_hist,
				container
			WHERE
				cataloged_item.collection_object_id = specimen_part.derived_from_cat_item AND				
				specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
				cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id AND
				coll_obj_cont_hist.container_id=container.container_id and
				(container.parent_container_id is null or
				container.parent_container_id=0) and
				cataloged_item.collection_id=#collection_id# AND
				other_id_type='#other_id_type#' AND
				display_value= '#oidnum#' AND
				part_name='#part_name#'
				<cfif noSubsample is "true">
					and SAMPLED_FROM_OBJ_ID is null
				</cfif>
		</cfquery>
	</cfif>
	<cfif coll_obj.recordcount is 1 and len(coll_obj.part_id) gt 0>
		<cfquery name="coll_obj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				cat_num,
				collection,
				collection.collection_cde,
				institution_acronym,
				scientific_name,
				#coll_obj.part_id# collection_object_id 
			FROM
				cataloged_item,
				specimen_part,
				coll_obj_other_id_num,
				collection,
				identification
			WHERE
				cataloged_item.collection_object_id = specimen_part.derived_from_cat_item AND
				cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id AND
				cataloged_item.collection_id=collection.collection_id and
				cataloged_item.collection_object_id = identification.collection_object_id and
				accepted_id_fg=1 and
				specimen_part.collection_object_id=#coll_obj.part_id#
		</cfquery>
	<cfelse>
		<cfquery name="coll_obj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				-1 cat_num
			FROM
				dual
		</cfquery>
	</cfif>
	<cfreturn coll_obj>
</cffunction>
<!-------------------------------------------->
<cffunction name="addPartToContainer" returntype="String">
	<cfargument name="collection_object_id" type="numeric" required="yes">
	<cfargument name="part_id" type="numeric" required="yes">
	<cfargument name="part_id2" type="string" required="no">
	<cfargument name="parent_barcode" type="string" required="yes">
	<cfargument name="new_container_type" type="string" required="yes">		
	<cfoutput>
	<cftry>
		<cftransaction>
			<cfquery name="isGoodParent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select container_id from container where container_type <> 'collection object'
				and barcode='#parent_barcode#'
			</cfquery>
			<cfif #isGoodParent.recordcount# is not 1>
				<cfreturn "0|Parent container (barcode #parent_barcode#) not found.">
			</cfif>
			<cfquery name="cont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select container_id FROM coll_obj_cont_hist where collection_object_id=#part_id#
			</cfquery>
			<cfif #cont.recordcount# is not 1>
				<cfreturn "0|Yikes! A part is not a container.">
			</cfif>
			<cfquery name="newparent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				UPDATE container SET container_type = '#new_container_type#' WHERE
					container_id=#isGoodParent.container_id#
			</cfquery>
			<cftransaction action="commit" />
			<cfquery name="moveIt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				UPDATE container SET parent_container_id = #isGoodParent.container_id# WHERE
				container_id=#cont.container_id#
			</cfquery>
			<cfif len(#part_id2#) gt 0>
				<cfquery name="cont2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select container_id FROM coll_obj_cont_hist where collection_object_id=#part_id2#
				</cfquery>
				<cfquery name="moveIt2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					UPDATE container SET parent_container_id = #isGoodParent.container_id# WHERE
					container_id=#cont2.container_id#
				</cfquery>
			</cfif>
		</cftransaction>
		<cfquery name="coll_obj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				cat_num,
				institution_acronym,
				collection.collection_cde,
				collection.collection,
				scientific_name,
				part_name
				<cfif len(part_id2) gt 0>
					|| (select ' and ' || part_name from specimen_part where collection_object_id=#part_id2#)
				</cfif>
				part_name
			from
				cataloged_item,
				collection,
				identification,
				specimen_part
			where
				cataloged_item.collection_object_id=specimen_part.derived_from_cat_item and
				cataloged_item.collection_object_id=identification.collection_object_id and
				accepted_id_fg=1 and
				cataloged_item.collection_id=collection.collection_id and
				specimen_part.collection_object_id=#part_id#
		</cfquery>
		<cfset r='Moved <a href="/guid/#coll_obj.institution_acronym#:#coll_obj.collection_cde#:#coll_obj.cat_num#">'>
		<cfset r="#r##coll_obj.collection# #coll_obj.cat_num#">
		<cfset r="#r#</a> (<i>#coll_obj.scientific_name#</i>) #coll_obj.part_name#">
		<cfset r="#r# to container barcode #parent_barcode# (#new_container_type#)">
		<cfreturn '1|#r#'>>
		<cfcatch>
			<cfreturn "0|#cfcatch.message# #cfcatch.detail# #cfcatch.sql#"> 
		</cfcatch>		
	</cftry>
	</cfoutput>	
</cffunction>
<!----------------------------------------------------------------->
<!-------------------------------------------->
<cffunction name="addPartToContainer_old" returntype="String">
	<cfargument name="collection_id" type="numeric" required="yes">
	<cfargument name="other_id_type" type="string" required="yes">
	<cfargument name="oidnum" type="string" required="yes">
	<cfargument name="part_name" type="string" required="yes">
	<cfargument name="part_name_2" type="string" required="yes">
	<cfargument name="parent_barcode" type="string" required="yes">
	<cfargument name="new_container_type" type="string" required="yes">
	<cfargument name="noSubsample" type="string" required="yes">
	<cfargument name="noBarcode" type="string" required="yes">
		
	<cfoutput>
	<cftry>
	<cftry>
		<cfset coll_obj=getCollObjByPart(collection_id,other_id_type,oidnum,part_name,noSubsample,noBarcode)>
		<cfif len(#part_name_2#) gt 0>
			<cfset coll_obj2=getCollObjByPart(collection_id,other_id_type,oidnum,part_name_2,noSubsample,noBarcode)>
		</cfif>
	<cfcatch>
		<cfreturn "0|#cfcatch.message#: #cfcatch.detail#">
	</cfcatch>	
	</cftry>
		<cfif #coll_obj.recordcount# gt 1>
			<!--- see if we can find a suitable uncontainerized tissue --->
			<cfset coll_obj=getDistNoContainerPartId(collection_id,other_id_type,oidnum,part_name,noBarcode)>
			<cfif not isdefined("coll_obj.collection_object_id")>
				<cfreturn "0|No uncontainerized tissue parts found #other_id_type# #oidnum# #part_name#.">
			</cfif>
		<cfelseif #coll_obj.recordcount#  is 0>
			<cfreturn "0|#coll_obj.recordcount# cataloged items matched #other_id_type# #oidnum# #part_name#.">
		</cfif>
		<cfif len(#part_name_2#) gt 0>
			<cfif coll_obj2.recordcount gt 1>
				<cfset coll_obj2=getDistNoContainerPartId(collection_id,other_id_type,oidnum,part_name_2)>
				<cfif not isdefined("coll_obj2.collection_object_id")>
					<cfreturn "0|No uncontainerized tissue parts found #other_id_type# #oidnum# #part_name_2#.">
				</cfif>		
			<cfelseif coll_obj2.recordcount is 0>
				<cfreturn "0|#coll_obj2.recordcount# cataloged items matched #other_id_type# #oidnum# #part_name#.">
			</cfif>			
		</cfif>		
		<cfquery name="isGoodParent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select container_id from container where container_type <> 'collection object'
			and barcode='#parent_barcode#'
		</cfquery>
		<cfif #isGoodParent.recordcount# is not 1>
			<cfreturn "0|Parent container (barcode #parent_barcode#) not found.">
		</cfif>
		<cfquery name="cont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select container_id FROM coll_obj_cont_hist where collection_object_id=#coll_obj.collection_object_id#
		</cfquery>
		<cfif #cont.recordcount# is not 1>
			<cfreturn "0|Yikes! A part is not a container.">
		</cfif>
		
		<cfif len(#part_name_2#) gt 0>
			<cfquery name="cont2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select container_id FROM coll_obj_cont_hist where
				collection_object_id=#coll_obj2.collection_object_id#
			</cfquery>
			<cfif #cont2.recordcount# is not 1>
				<cfreturn "0|Yikes! A part is not a container.">
			</cfif>
		</cfif>		
		<cftry>
			<cfquery name="newparent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				UPDATE container SET container_type = '#new_container_type#' WHERE
					container_id=#isGoodParent.container_id#
			</cfquery>
			<cfquery name="moveIt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				UPDATE container SET parent_container_id = #isGoodParent.container_id# WHERE
				container_id=#cont.container_id#
			</cfquery>
			<cfif len(#part_name_2#) gt 0>
				<cfquery name="moveIt2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					UPDATE container SET parent_container_id = #isGoodParent.container_id# WHERE
					container_id=#cont2.container_id#
				</cfquery>
			</cfif>
			<cfcatch>
				<cfreturn "0|#cfcatch.message#: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cfset r='Moved <a href="/SpecimenDetail.cfm?guid=#coll_obj.institution_acronym#:#coll_obj.collection_cde#:#coll_obj.cat_num#">'>
		<cfset r="#r##coll_obj.collection# #coll_obj.cat_num#">
		<cfif #other_id_type# is not "catalog_number">
			<cfset r="#r# (#other_id_type# #oidnum#)">
		</cfif>
		<cfset r="#r#</a> (<i>#coll_obj.scientific_name#</i>) #part_name#">
		<cfif len(#part_name_2#) gt 0>
			<cfset r="#r# and #part_name_2#">
		</cfif>
		<cfset r="#r# to container barcode #parent_barcode# (#new_container_type#)">
		<cfreturn '1|#r#'>
	
	<cfcatch>
		<cfset r="0|#cfcatch.message#: #cfcatch.detail#">
		<cfif isdefined("cfcatch.sql")>
			<cfset r="#r# #cfcatch.sql#">
		</cfif>
	<cfreturn r>
	</cfcatch>
	</cftry>
	</cfoutput>	
</cffunction>
<!----------------------------------------------------------------->
<cffunction name="getDocsById" returntype="xml">
	<cfargument name="id" type="string" required="yes">
	<cfinvoke 
		webservice="http://arctos.database.museum/service/documentation.cfc?wsdl"
		method="getDefinition"
		returnvariable="result">
		<cfinvokeargument name="fld" value="#id#"/>
	</cfinvoke>
	<cfreturn result>
</cffunction>
<!-------------------------------------------->
<cffunction name="saveLocSrchPref" returntype="Any">
	<cfargument name="id" type="string" required="yes">
	<cfargument name="onOff" type="numeric" required="yes">
	<cfif isdefined("session.username") and len(#session.username#) gt 0>
		<cftry>
			<cfquery name="ins" datasource="cf_dbuser">
				select LOCSRCHPREFS from cf_users
				where username='#session.username#'
			</cfquery>
			<cfset cv=valuelist(ins.LOCSRCHPREFS)>
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
				update cf_users set LOCSRCHPREFS='#nv#'
				where username='#session.username#'
			</cfquery>
			<cfset session.locSrchPrefs=nv>
			<cfcatch><!-- nada --></cfcatch>
		</cftry>
	</cfif>
	<cfreturn 1>
</cffunction>
<!-------------------------------------------->
<cffunction name="saveSpecSrchPref" returntype="Any">
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
<cffunction name="getSpecSrchPref" returntype="string">
	<cfif isdefined("session.username") and len(#session.username#) gt 0>
		<cftry>
			<cfquery name="ins" datasource="cf_dbuser">
				select specsrchprefs from cf_users
				where username='#session.username#'
			</cfquery>
				<cfreturn ins.specsrchprefs>
			<cfcatch><!-- nada --></cfcatch>
		</cftry>
	</cfif>
	<cfreturn "cookie">	
</cffunction>

<!-------------------------------------------->
<cffunction name="getSessionTimeout" returntype="string">
	<cfif isdefined("session.username") and len(#session.username#) gt 0>
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
		<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			insert into cf_form_permissions (form_path,role_name) values ('#form#','#role#')
		</cfquery>
	<cfelseif onoff is "false">
		<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
	<cfargument name="theNum" type="string" required="yes">
	<cfargument name="type" type="string" required="yes">
		
	<cfoutput>
	<cftry>
		<cfif type is "cat_num">
			<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
					cataloged_item.COLLECTION_OBJECT_ID,
					cataloged_item.cat_num,
					scientific_name
				from
					cataloged_item,
					identification
				where
					cataloged_item.collection_object_id = identification.collection_object_id AND
					accepted_id_fg=1 and
					cat_num=#theNum# and
					collection_id=#collection_id#
			</cfquery>
		<cfelse>
			<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
					cataloged_item.COLLECTION_OBJECT_ID,
					cataloged_item.cat_num,
					scientific_name
				from
					cataloged_item,
					identification,
					coll_obj_other_id_num
				where
					cataloged_item.collection_object_id = identification.collection_object_id AND
					cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id AND
					accepted_id_fg=1 and
					display_value='#theNum#' and
					other_id_type='#type#' and
					collection_id=#collection_id#
			</cfquery>
		</cfif>
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
					derived_from_cat_item
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
					,DERIVED_FROM_CAT_ITEM)
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
					,#parentData.derived_from_cat_item#)				
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
<cffunction name="getLoanPartResults" returntype="query">
	<cfargument name="transaction_id" type="numeric" required="yes">
	<cfoutput>
	<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			cataloged_item.COLLECTION_OBJECT_ID,
			specimen_part.collection_object_id partID,
			coll_object.COLL_OBJ_DISPOSITION,
			coll_object.LOT_COUNT,
			coll_object.CONDITION,
			specimen_part.PART_NAME,
			specimen_part.PART_MODIFIER,
			specimen_part.SAMPLED_FROM_OBJ_ID,
			specimen_part.PRESERVE_METHOD,
			concatEncumbrances(cataloged_item.collection_object_id) as encumbrance_action,
			loan_item.transaction_id
		from
			#session.SpecSrchTab#,
			cataloged_item,
			coll_object,
			specimen_part,
			(select * from loan_item where transaction_id = #transaction_id#) loan_item
		where
			#session.SpecSrchTab#.collection_object_id = cataloged_item.collection_object_id AND
			cataloged_item.collection_object_id = specimen_part.derived_from_cat_item AND
			specimen_part.collection_object_id = coll_object.collection_object_id and
			specimen_part.SAMPLED_FROM_OBJ_ID is null and
			specimen_part.collection_object_id = loan_item.collection_object_id (+) 
		order by
			cataloged_item.collection_object_id, specimen_part.part_name
	</cfquery>
	<cfreturn result>
	</cfoutput>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="removeItems" returntype="string">
	<cfargument name="removeList" type="string" required="yes">
	<cfoutput>
	<cfquery name="remove" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		delete from #session.SpecSrchTab# where
		collection_object_id IN (#removeList#)
	</cfquery>
	<cfreturn "spiffy">
	</cfoutput>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="getSpecResultsData" returntype="query">
	<cfargument name="startrow" type="numeric" required="yes">
	<cfargument name="numRecs" type="numeric" required="yes">
	<cfargument name="orderBy" type="string" required="yes">
	<cfset stopRow = startrow + numRecs -1>
	<!--- strip Safari idiocy --->
	<cfset orderBy=replace(orderBy,"%20"," ","all")>
	<cfset orderBy=replace(orderBy,"%2C",",","all")>
	<cftry>
		<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			Select * from (
				Select a.*, rownum rnum From (
					select * from #session.SpecSrchTab# order by #orderBy#
				) a where rownum <= #stoprow#
			) where rnum >= #startrow#
		</cfquery>
		
		<cfset collObjIdList = valuelist(result.collection_object_id)>
		<cfset session.collObjIdList=collObjIdList>
		
		<cfquery name="cols" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			 select column_name from user_tab_cols where 
			 upper(table_name)=upper('#session.SpecSrchTab#') order by internal_column_id
		</cfquery>
		<!--- return the columns we got in the query --->
		<cfset clist = result.columnList>
		<cfset t = arrayNew(1)>
		<cfset temp = queryaddcolumn(result,"columnList",t)>
		<cfset temp = QuerySetCell(result, "columnList", "#valuelist(cols.column_name)#", 1)>

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
		<cfquery name="tieRef" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="clientResultColumnList" returntype="string">
	<cfargument name="ColumnList" type="string" required="yes">
	<cfargument name="in_or_out" type="string" required="yes">
	<cfif not isdefined("session.ResultColumnList")>
		<cfset session.ResultColumnList=''>
	</cfif>
	<cfset result="OK">
	<cfif in_or_out is "in">
		<cfloop list="#ColumnList#" index="i">
		<cfif not ListFindNoCase(session.resultColumnList,i,",")>
			<cfset session.resultColumnList = ListAppend(session.resultColumnList, i,",")>
		</cfif>
		</cfloop>
	<cfelse>
		<cfloop list="#ColumnList#" index="i">
		<cfif ListFindNoCase(session.resultColumnList,i,",")>
			<cfset session.resultColumnList = ListDeleteAt(session.resultColumnList, ListFindNoCase(session.resultColumnList,i,","),",")>
		</cfif>
		</cfloop>
	</cfif>
	<cfquery name ="upDb" datasource="cf_dbuser">
		update cf_users set resultcolumnlist='#session.resultColumnList#' where
		username='#session.username#'
	</cfquery>
	<cfreturn result>
</cffunction>


<!---
<cffunction name="clientResultColumnList" returntype="string">
	<cfargument name="ColumnList" type="string" required="yes">
	<cfargument name="in_or_out" type="string" required="yes">
	<cfif not isdefined("session.ResultColumnList")>
		<cfset session.ResultColumnList=''>
	</cfif>
	<cfset crl=session.ResultColumnList>
	<cfif in_or_out is "in">
		<cfif not ListContainsNoCase(session.resultColumnList,ColumnList)>
			<cfset crl = ListAppend(session.resultColumnList, ColumnList)>
		</cfif>
	<cfelse>
		<cfif ListContainsNoCase(session.resultColumnList,ColumnList)>
			<cfset crl = ListDeleteAt(session.resultColumnList, ListFindNoCase(session.resultColumnList,ColumnList))>
		</cfif>
	</cfif>
	<cfset session.resultColumnList = crl>
	<cfquery name ="upDb" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update cf_users set resultcolumnlist='#crl#' where
		username='#session.username#'
	</cfquery>
	<cfreturn "ok">
</cffunction>

---->
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="setClientDetailLevel" returntype="string">
	<cfargument name="detail_level" type="numeric" required="yes">
	<cfargument name="map_url" type="string" required="yes">
	<cfset session.detail_level=#detail_level#>
	<cfset result="ok">
	<cfreturn "#detail_level#|#map_url#">
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="setSrchVal" returntype="string">
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
				<!--- just add it --->
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
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="changedetail_level" returntype="string">
	<cfargument name="tgt" type="numeric" required="yes">
	<cftry>
			<cfquery name="up" datasource="cf_dbuser">
				UPDATE cf_users SET
					detail_level = 
					#tgt#
				WHERE username = '#session.username#'
			</cfquery>
			<cfset session.detail_level = "#tgt#">
		<cfset result="success">
	<cfcatch>
		<cfset result = "#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="changecustomOtherIdentifier" returntype="string">
	<cfargument name="tgt" type="string" required="yes">
	<cftry>
			<cfquery name="up" datasource="cf_dbuser">
				UPDATE cf_users SET
					customOtherIdentifier = 
					<cfif len(#tgt#) gt 0>
						'#tgt#'
					<cfelse>
						NULL
					</cfif>
				WHERE username = '#session.username#'
			</cfquery>
			<cfset session.customOtherIdentifier = "#tgt#">
		<cfset result="success">
	<cfcatch>
		<cfset result = "#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="changeshowObservations" returntype="string">
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
<!------------------------------------------------------------------>
<cffunction name="changefancyCOID" returntype="string">
	<cfargument name="tgt" type="string" required="yes">
	<cftry>
			<cfquery name="up" datasource="cf_dbuser">
				UPDATE cf_users SET
					fancyCOID = 
					<cfif #tgt# is 1>
						#tgt#
					<cfelse>
						NULL
					</cfif>
				WHERE username = '#session.username#'
			</cfquery>
			<cfif #tgt# gt 0>
				<cfset session.fancyCOID = "#tgt#">
			<cfelse>
				<cfset session.fancyCOID = "">
			</cfif>
		<cfset result="success">
	<cfcatch>
		<cfset result = "#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!------------------------------------------------------------------>
<cffunction name="changeexclusive_collection_id" returntype="string">
	<cfargument name="tgt" type="string" required="yes">
		<cfinclude template="/includes/functionLib.cfm">
	<cftry>
		<cfquery name="up" datasource="cf_dbuser">
			UPDATE cf_users SET
				exclusive_collection_id = 
				<cfif #tgt# gt 0>
					#tgt#
				<cfelse>
					NULL
				</cfif>
			WHERE username = '#session.username#'
			</cfquery>
		<cfset setDbUser(tgt)>
		<cfset result="success">
	<cfcatch>
		<cfset result = "#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!------------------------------------->
<cffunction name="changeresultSort" returntype="string">
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
<!------------------------------------->
<cffunction name="changedisplayRows" returntype="string">
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
<!----------------------------------------------------------------------------------------------------------------->
 <cffunction name="saveIdentifierChange" returntype="string">
	<cfargument name="idId" type="string" required="yes">
	<cfargument name="newAgentId" type="numeric" required="yes">
	<cfargument name="identification_id" type="numeric" required="yes">
	<cfargument name="agent_id" type="numeric" required="yes">
	<cftry>
			<cfquery name="up" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
		<cftransaction>
			<cfquery name="delIdTax" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				delete from identification_taxonomy where 
				identification_id=#identification_id#
			</cfquery>
			<cfquery name="delIdA" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				delete from identification_agent where 
				identification_id=#identification_id#
			</cfquery>	
			<cfquery name="delId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
		<cfquery name="flipOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			update identification set accepted_id_fg=0
			where
			collection_object_id=#collection_object_id#
		</cfquery>
		<cfquery name="newIdentifier" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
 <cffunction name="saveNatureOfId" returntype="string">
	<cfargument name="identification_id" type="numeric" required="yes">
	<cfargument name="nature_of_id" type="string" required="yes">
	<cftry>
		<cfquery name="newIdentifier" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
		<cfquery name="newIdentifier" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
		<cfquery name="newIdentifier" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
	<cfquery name="i" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
		<cfquery name="newIdentifier" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			insert into identification_agent (IDENTIFICATION_ID,AGENT_ID,IDENTIFIER_ORDER)
			values (#id_id#,#agent_id#,#nextInLine#)
		</cfquery>
		<cfquery name="getName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
		<cfquery name="res" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
		<cfquery name="res" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
<cffunction name="updateLoanItemRemarks" returntype="query">
	<cfargument name="part_id" type="numeric" required="yes">
	<cfargument name="transaction_id" type="numeric" required="yes">
	<cfargument name="loan_item_remarks" type="string" required="yes">
	<cftry>
		<cftransaction>
			<cfquery name="upIns" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
<cffunction name="updateCondition" returntype="query">
	<cfargument name="part_id" type="numeric" required="yes">
	<cfargument name="condition" type="string" required="yes">
	<cftry>
		<cftransaction>
			<cfquery name="upIns" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				update coll_object set
				condition = '#condition#'
				where
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
			<cfquery name="upIns" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
			<cfquery name="killPart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				delete from loan_item where
				collection_object_id = #part_id# and
				transaction_id=#transaction_id#
			</cfquery>		
			<cfquery name="killPart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
		<cfquery name="killPart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
		<cfquery name="childID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select container_id,barcode,label,container_type from container where barcode = '#barcode#'
		</cfquery>
		<cfquery name="parentID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
			<cfquery name="alterTime" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				ALTER SESSION set nls_date_format = 'DD-MON-YYYY HH24:MI:SS'
			</cfquery>
			<cfquery name="moveIt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
		<cfquery name="upPartDisp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
		<cfquery name="thisID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select container_id,label from container where barcode='#barcode#'
			AND container_type = 'cryovial'		
		</cfquery>
		<cfif #thisID.recordcount# is 0>
			<cfquery name="thisID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select container_id,label from container where barcode='#barcode#'
				AND container_type = 'cryovial label'		
			</cfquery>
			<cfif #thisID.recordcount# is 1>
				<cfquery name="update" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					update container set container_type='cryovial'
					where container_id=#thisID.container_id#
				</cfquery>
				<cfset thisContainerId = #thisID.container_id#>
			</cfif>
		<cfelse>
			<cfset thisContainerId = #thisID.container_id#>	
		</cfif>
		
		<cfif len(#thisContainerId#) gt 0>
			<cfquery name="putItIn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
	
	<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from part_hierarchy 
			where part_id=#id#
		</cfquery>
		<cfreturn result>
</cffunction>

<!------------------------------------->
<cffunction name="getPartRecDet" returntype="query">
	<cfargument name="id" type="numeric" required="yes">
	<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
		<cfquery name="up" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
	
	<cfquery name="collID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select collection_id from collection where
		institution_acronym='#inst#' and
		collection_cde='#coll#'
	</cfquery>
	<!---
	<cfset i=1>
	<cfset result="">
	<cfloop condition="i lt 200">
		<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
		<cfquery name="isused" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
		<cfquery name="a" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select max(cat_num) as mc from cataloged_item where collection_id = #collID.collection_id#
		</cfquery>
		<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
	<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
	<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
				<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select 
						0 as freezer,
						0 as box,
						0 as rack
					from dual
				</cfquery>
			<cfelse>
				<cfset tf = #freezer# -1 >
				<cfquery name="pf" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select distinct(freezer) from 
					dgr_locator where freezer = #tf#
				</cfquery>
				<cfif #pf.recordcount# is 1>
					<cfquery name="r" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						select max(rack) as mrack from dgr_locator where 
						freezer = #tf#
					</cfquery>
					<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
	<cfquery name="newLoc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	
	</cfquery>
	<cfquery name="v" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select dgr_locator_seq.currval as currval from dual
	</cfquery>
	<cfset tv = v.currval>
	<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
		<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
	
	<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select box from dgr_locator where freezer = #freezer#
		and rack = #rack#
		group by box order by box
	</cfquery>
	<cfreturn result>
</cffunction>
<!------------------------------------->
<cffunction name="DGRracklookup" returntype="query">
	
	<cfargument name="freezer" type="numeric" required="yes">
	
	<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
	<cfquery name="newLoc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
			<cfquery name="v" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select dgr_locator_seq.nextval as nv from dual
			</cfquery>
			<cfset thisLocId = #v.nv#>
			<cfquery name="newLoc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
			<cftry>
				<cftransaction>
					<cfquery name="v" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						select LOCATOR_ID from dgr_locator
						where								
							FREEZER=#freezer# and
							RACK=#rack# and
							BOX=#box# and
							PLACE=#place#	
					</cfquery>
					<cfquery name="newLoc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						update dgr_locator set
							NK=#nk#,
							TISSUE_TYPE='#tissue_type#'
						where								
							FREEZER=#freezer# and
							RACK=#rack# and
							BOX=#box# and
							PLACE=#place#		
					</cfquery>
					<cfset result = querynew("LOCATOR_ID,FREEZER,RACK,BOX,PLACE,NK,TISSUE_TYPE")>
					<cfset temp = queryaddrow(result,1)>
					<cfset temp = QuerySetCell(result, "LOCATOR_ID", "#v.locator_id#", 1)>
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
		</cfcatch>
	</cftry>
		<cfreturn result>
</cffunction>
<!------------------------------------->

<cffunction name="getContacts" returntype="string">
	<cfquery name="contacts" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
		<cfquery name="getCollId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
		<cfquery name="upBulk" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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