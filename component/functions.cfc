<cfcomponent>
<!------------------------------------------------------->
<cffunction name="encumberThis" access="remote">
	<cfargument name="cid" type="numeric" required="yes">	
	<cfargument name="eid" type="numeric" required="yes">
	<cftry>
		<cfquery name="k" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			insert into  coll_object_encumbrance (ENCUMBRANCE_ID,COLLECTION_OBJECT_ID)
			values (#eid#,#cid#)
		</cfquery>
		<cfreturn cid>
	<cfcatch>
		<cfreturn cfcatch.message & ': ' & cfcatch.detail>
	</cfcatch>
	</cftry>
</cffunction>

<cffunction name="cloneCatalogedItem" access="remote">
	<cfargument name="collection_object_id" type="numeric" required="yes">	
	<cftry>
		<cftransaction>
			<cfset problem="">
			<cfquery name="k" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select somerandomsequence.nextval c from dual
			</cfquery>
			<cfset key=k.c>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into bulkloader (
					COLLECTION_OBJECT_ID,
					LOADED,
					ENTEREDBY,
					ACCN,
					TAXON_NAME,
					NATURE_OF_ID,
					MADE_DATE,
					IDENTIFICATION_REMARKS,
					COLLECTION_CDE,
					INSTITUTION_ACRONYM,
					COLL_OBJ_DISPOSITION,
					CONDITION,
					COLL_OBJECT_REMARKS,
					DISPOSITION_REMARKS,
					COLLECTING_EVENT_ID
				) (
					select
						#key#,
						'cloned from ' || collection || ' ' || cat_num,
						'#session.username#',
						accn_number,
						scientific_name,
						nature_of_id,
						made_date,
						IDENTIFICATION_REMARKS,
						collection.COLLECTION_CDE,
						collection.INSTITUTION_ACRONYM,
						COLL_OBJ_DISPOSITION,
						CONDITION,
						COLL_OBJECT_REMARKS,
						DISPOSITION_REMARKS,
						cataloged_item.COLLECTING_EVENT_ID
					from
						cataloged_item,
						collection,
						identification,
						coll_object,
						COLL_OBJECT_REMARK,
						accn
					where
						cataloged_item.collection_id=collection.collection_id and
						cataloged_item.ACCN_ID=accn.transaction_id and
						cataloged_item.collection_object_id=identification.collection_object_id and
						identification.accepted_id_fg=1 and
						cataloged_item.collection_object_id=coll_object.collection_object_id and
						cataloged_item.collection_object_id=COLL_OBJECT_REMARK.collection_object_id (+) and
						cataloged_item.collection_object_id = #collection_object_id#
				)
			</cfquery>
			<cfquery name="idby" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
					agent_name 
				from 
					identification,
					identification_agent,
					preferred_agent_name
				where
					identification.identification_id=identification_agent.identification_id and
					identification_agent.agent_id=preferred_agent_name.agent_id and
					identification.collection_object_id = #collection_object_id#
				order by IDENTIFIER_ORDER
			</cfquery>					
			<cfif idby.recordcount is 1>
				<cfquery name="iidby" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					update bulkloader set ID_MADE_BY_AGENT='#idby.agent_name#'
					where collection_object_id=#key#
				</cfquery>
			<cfelse>
				<cfset problem="too many identifiers: #valuelist(idby.agent_name)#">
			</cfif>	
			<cfquery name="oid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
					other_id_type,
					display_value 
				from coll_obj_other_id_num
				where collection_object_id=#collection_object_id#
			</cfquery>
			
			
			<cfif oid.recordcount gt 0>
				<cfset i=1>
				<cfset sql="update bulkloader set ">
				<cfloop query="oid">
					<cfif i lt 5>
						<cfset sql=sql & "OTHER_ID_NUM_TYPE_#i# = '#other_id_type#',
							OTHER_ID_NUM_#i#='#display_value#',">
						<cfset i=i+1>
					</cfif>
				</cfloop>
				<cfset sql=sql & ' where collection_object_id=#key#'>
				<cfset sql=replace(sql,", where"," where","all")>
				<cfquery name="ioid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					#preservesinglequotes(sql)#
				</cfquery>
			</cfif>
			<cfif oid.recordcount gt 4>
				<cfset ids="">
				<cfloop query="oid">
					<cfset ids=listappend(ids,"#other_id_type#=#display_value#",";")>
				</cfloop>
				<cfset problem="too many IDs: #ids#">
			</cfif>		
			
			<cfquery name="col" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
					agent_name,
					COLLECTOR_ROLE
				from 
					collector,
					preferred_agent_name
				where 
					collector.agent_id=preferred_agent_name.agent_id and
					collector.collection_object_id=#collection_object_id#
				order by
					COLLECTOR_ROLE,
					COLL_ORDER
			</cfquery>
			
			<cfif col.recordcount gt 0>
				<cfset i=1>
				<cfset sql="update bulkloader set ">
				<cfloop query="col">
					<cfif i lt 9>
						<cfset sql=sql & "COLLECTOR_AGENT_#i# = '#agent_name#',
							COLLECTOR_ROLE_#i#='#COLLECTOR_ROLE#',">
						<cfset i=i+1>
					</cfif>
				</cfloop>
				<cfset sql=sql & ' where collection_object_id=#key#'>
				<cfset sql=replace(sql,", where"," where","all")>
				<cfquery name="icoll" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					#preservesinglequotes(sql)#
				</cfquery>
			</cfif>
			<cfif col.recordcount gt 8>
				<cfset ids="">
				<cfloop query="oid">
					<cfset ids=listappend(ids,"#other_id_type#=#display_value#",";")>
				</cfloop>
				<cfset problem="too many collectors: #valuelist(col.agent_name)#">
			</cfif>		
			
			
			<cfquery name="part" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
					part_name,
					part_modifier,
					preserve_method,
					condition,
					p.barcode,
					p.label,
					to_char(lot_count) lot_count,
					COLL_OBJ_DISPOSITION,
					coll_object_remarks
				from
					specimen_part,
					coll_object,
					coll_object_remark,
					coll_obj_cont_hist,
					container c,
					container p
				where
					specimen_part.collection_object_id=coll_object.collection_object_id and
					specimen_part.collection_object_id=coll_object_remark.collection_object_id (+) and
					specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
					coll_obj_cont_hist.container_id=c.container_id (+) and
					c.parent_container_id=p.container_id (+) and
					specimen_part.derived_from_cat_item=#collection_object_id#
			</cfquery>
			
			<cfif part.recordcount gt 0>
				<cfset i=1>
				<cfset sql="update bulkloader set ">
				<cfloop query="part">
					<cfif i lt 13>
						<cfset sql=sql & "PART_NAME_#i# = '#part_name#',
							PART_MODIFIER_#i#='#part_modifier#',
							PRESERV_METHOD_#i#='#preserve_method#',
							PART_CONDITION_#i#='#condition#',
							PART_BARCODE_#i#='#barcode#',
							PART_CONTAINER_LABEL_#i#='#label#',
							PART_LOT_COUNT_#i#='#lot_count#',
							PART_DISPOSITION_#i#='#COLL_OBJ_DISPOSITION#',
							PART_REMARK_#i#='#coll_object_remarks#',">
						<cfset i=i+1>
					</cfif>
				</cfloop>
				<cfset sql=sql & ' where collection_object_id=#key#'>
				<cfset sql=replace(sql,", where"," where","all")>
				<cfquery name="ipart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					#preservesinglequotes(sql)#
				</cfquery>
			</cfif>
			<cfif part.recordcount gt 12>
				<cfset problem="too many part: #valuelist(part.part_name)#">
			</cfif>		
			
	
	
			<cfquery name="att" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
					ATTRIBUTE_TYPE,
					ATTRIBUTE_VALUE,
					ATTRIBUTE_UNITS,
					ATTRIBUTE_REMARK,
					agent_name,
					to_char(DETERMINED_DATE,'dd-Mon-yyyy') DETERMINED_DATE,
					DETERMINATION_METHOD
				from
					attributes,
					preferred_agent_name
				where
					attributes.DETERMINED_BY_AGENT_ID=preferred_agent_name.agent_id and				
					attributes.collection_object_id=#collection_object_id#
			</cfquery>
			<!--- attributes 1 through 6 are customizable and we can't use them here --->
			<cfif att.recordcount gt 0>
				<cfset i=7>
				<cfset sql="update bulkloader set ">
				<cfloop query="att">
					<cfif i lte 10>
						<cfset sql=sql & "ATTRIBUTE_#i# = '#ATTRIBUTE_TYPE#',
							ATTRIBUTE_VALUE_#i#='#ATTRIBUTE_VALUE#',
							ATTRIBUTE_UNITS_#i#='#ATTRIBUTE_UNITS#',
							ATTRIBUTE_REMARKS_#i#='#ATTRIBUTE_REMARK#',
							ATTRIBUTE_DATE_#i#='#DETERMINED_DATE#',
							ATTRIBUTE_DET_METH_#i#='#DETERMINATION_METHOD#',
							ATTRIBUTE_DETERMINER_#i#='#agent_name#',">
						<cfset i=i+1>
					</cfif>
				</cfloop>
				<cfset sql=sql & ' where collection_object_id=#key#'>
				<cfset sql=replace(sql,", where"," where","all")>
				<cfquery name="iatt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					#preservesinglequotes(sql)#
				</cfquery>
			</cfif>
			<cfif att.recordcount gt 4>
				<cfset problem="too many attribute: #valuelist(att.ATTRIBUTE_TYPE)#">
			</cfif>		
			<cfquery name="irel" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				update bulkloader set 
					COLL_OBJECT_REMARKS='#problem#',
					RELATIONSHIP='child record of',
					RELATED_TO_NUMBER= (
										select 
											collection.institution_acronym || ' ' || collection.collection_cde || ' ' || cat_num 
										from 
											cataloged_item,collection
										where cataloged_item.collection_id=collection.collection_id and 
										cataloged_item.collection_object_id=#collection_object_id#
										),
					RELATED_TO_NUM_TYPE='catalog number'
				where collection_object_id=#key#
			</cfquery>
		</cftransaction>
			<cfreturn "spiffy:#key#">
		<cfcatch>
			<cfreturn "fail: #cfcatch.message#">
		</cfcatch>
	</cftry>
</cffunction>
<!------------------------------------------------------->
<cffunction name="getGeologyValues" access="remote">
	<cfargument name="attribute" type="string" required="yes">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT 
			attribute_value
		FROM 
			geology_attribute_hierarchy
		WHERE 
			USABLE_VALUE_FG=1 and
			attribute='#attribute#'
		group by attribute_value
		order by attribute_value
	</cfquery>
	<cfreturn d>
</cffunction>

<!------------------------------------------------------->
<cffunction name="saveAgentRank" access="remote">
	<cfargument name="agent_id" type="numeric" required="yes">	
	<cfargument name="agent_rank" type="string" required="yes">	
	<cfargument name="remark" type="string" required="yes">
	<cfargument name="transaction_type" type="string" required="yes">
	<cfinclude template="/includes/functionLib.cfm">
	<cftry>
		<cfquery name="r" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			insert into agent_rank (
				agent_id,
				agent_rank,
				ranked_by_agent_id,
				remark,
				transaction_type
			) values (
				#agent_id#,
				'#agent_rank#',
				#session.myAgentId#,
				'#escapeQuotes(remark)#',
				'#transaction_type#'
			)
		</cfquery>
		<cfreturn agent_id>
	<cfcatch>
		<cfreturn "fail: #cfcatch.Message# #cfcatch.Detail# #cfcatch.sql#">
	</cfcatch>
	</cftry>
</cffunction>
<!------------------------------------------------------->
<cffunction name="getPubAttributes" access="remote">
	<cfargument name="attribute" type="string" required="yes">
	<cftry>
		<cfquery name="res" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select control from ctpublication_attribute where publication_attribute ='#attribute#'
		</cfquery>
		<cfif len(res.control) gt 0>
			<cfquery name="ctval" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select * from #res.control#
			</cfquery>
			<cfset cl=ctval.columnlist>
			<cfif listcontainsnocase(cl,"description")>
				<cfset cl=listdeleteat(cl,listfindnocase(cl,"description"))>
			</cfif>
			<cfif listcontainsnocase(cl,"collection_cde")>
				<cfset cl=listdeleteat(cl,listfindnocase(cl,"collection_cde"))>
			</cfif>
			<cfif listlen(cl) is 1>
				<cfquery name="return" dbtype="query">
					select #cl# as v from ctval order by #cl#
				</cfquery>
				<cfreturn return>
			<cfelse>
				<cfreturn "fail: cl is #cl#">
			</cfif>
		</cfif>
	<cfcatch>
		<cfreturn "fail: #cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn "nocontrol">
</cffunction>
<!------------------------------------------------------->
<cffunction name="kill_canned_search" access="remote">
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
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="genMD5" access="remote">
	<cfargument name="uri" type="string" required="yes">
	<cfif len(uri) is 0>
		<cfreturn ''>
	<cfelseif uri contains application.serverRootUrl>
		<cftry>
		<cfset f=replace(uri,application.serverRootUrl,application.webDirectory)>
		<cffile action="readbinary" file="#f#" variable="myBinaryFile">
		<cfset md5 = createObject("component","includes.cfc.hashBinary").hashBinary(myBinaryFile)>
		<cfreturn md5>
		<cfcatch>
			<cfreturn "">
		</cfcatch>
		</cftry>
	<cfelse>
		<cftry>
			<cfhttp url="#uri#" getAsbinary="yes" />
			<cfset md5 = createObject("component","includes.cfc.hashBinary").hashBinary(cfhttp.filecontent)>
			<cfreturn md5>
		<cfcatch>
			<cfreturn "">
		</cfcatch>
		</cftry>
	</cfif>
</cffunction>
<!-------------------------------------------->
<cffunction name="saveLocSrchPref" access="remote">
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
<!------------------------------------------->
<cffunction name="updatePartDisposition" access="remote">
	<cfargument name="part_id" type="numeric" required="yes">
	<cfargument name="disposition" type="string" required="yes">
	<cftry>
		<cfquery name="upPartDisp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			update coll_object set COLL_OBJ_DISPOSITION
			='#disposition#' where
			collection_object_id=#part_id#
		</cfquery>
		<cfset result = querynew("STATUS,PART_ID,DISPOSITION")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "status", "success", 1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "disposition", "#disposition#", 1)>
	<cfcatch>
		<cfset result = querynew("STATUS,PART_ID,DISPOSITION")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "status", "failure", 1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "disposition", "A query error occured: #cfcatch.Message# #cfcatch.Detail#", 1)>
	</cfcatch>
	</cftry>
		<cfreturn result>
</cffunction>
<!------------------------------------------->
<cffunction name="remPartFromLoan" access="remote">
	<cfargument name="part_id" type="numeric" required="yes">
	<cfargument name="transaction_id" type="numeric" required="yes">
	<cftry>
		<cfquery name="killPart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			delete from loan_item where
			collection_object_id = #part_id# and
			transaction_id=#transaction_id#
		</cfquery>
		<cfset result = querynew("PART_ID,MESSAGE")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "message", "success", 1)>
	<cfcatch>
		<cfset result = querynew("PART_ID,MESSAGE")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "message", "A query error occured: #cfcatch.Message# #cfcatch.Detail#", 1)>
	</cfcatch>
	
	</cftry>
		<cfreturn result>
</cffunction>
<!------------------------------------------->
<cffunction name="del_remPartFromLoan" access="remote">
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
		<cfset result = querynew("PART_ID,MESSAGE")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "message", "success", 1)>
	<cfcatch>
		<cfset result = querynew("PART_ID,MESSAGE")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "message", "A query error occured: #cfcatch.Message# #cfcatch.Detail#", 1)>
	</cfcatch>	
	</cftry>
		<cfreturn result>
</cffunction>
<!------------------------------------------->
<cffunction name="updateInstructions" access="remote">
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
		<cfset result = querynew("PART_ID,MESSAGE")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "message", "success", 1)>
	<cfcatch>
		<cfset result = querynew("PART_ID,MESSAGE")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "message", "A query error occured: #cfcatch.Message# #cfcatch.Detail#", 1)>
	</cfcatch>
	
	</cftry>
		<cfreturn result>
</cffunction>
<!----------------------------------------->
<cffunction name="updateLoanItemRemarks" access="remote">
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
		<cfset result = querynew("PART_ID,MESSAGE")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "message", "success", 1)>
	<cfcatch>
		<cfset result = querynew("PART_ID,MESSAGE")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "message", "A query error occured: #cfcatch.Message# #cfcatch.Detail#", 1)>
	</cfcatch>
	
	</cftry>
		<cfreturn result>
</cffunction>
<!------------------------------------------->
<cffunction name="updateCondition" access="remote">
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
		<cfset result = querynew("PART_ID,MESSAGE")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "message", "success", 1)>
	<cfcatch>
		<cfset result = querynew("PART_ID,MESSAGE")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "message", "A query error occured: #cfcatch.Message# #cfcatch.Detail#", 1)>
	</cfcatch>
	
	</cftry>
		<cfreturn result>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="moveContainer" access="remote">
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
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="getCatalogedItemCitation" access="remote">
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
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="setUserFormAccess" access="remote">
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
		<cfreturn "Error:invalid state">			 
	</cfif>
	<cfreturn "Success:#form#:#role#:#onoff#">
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="getParts" access="remote">
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
			<cfset q=queryNew("PART_NAME")>
			<cfset t = queryaddrow(q,1)>
			<cfset t = QuerySetCell(q, "PART_NAME", "Error: no_parts_found", 1)>
		</cfif>
		<cfif u.c is not 1>
			<cfset q=queryNew("PART_NAME")>
			<cfset t = queryaddrow(q,1)>
			<cfset t = QuerySetCell(q, "PART_NAME", "Error: #u.c# specimens match", 1)>
		</cfif>
	<cfcatch>
		<!---
		<cfset t = queryaddrow(theResult,1)>
		<cfset t = QuerySetCell(theResult, "collection_object_id", "-1", 1)>
		<cfset t = QuerySetCell(theResult, "typeList", "#cfcatch.detail#", 1)>
		<cfreturn theResult>
		--->
		<cfset q=queryNew("PART_NAME")>
		<cfset t = queryaddrow(q,1)>
		<cfset t = QuerySetCell(q, "PART_NAME", "Error: #cfcatch.Message# #cfcatch.detail#", 1)>
	</cfcatch>
	</cftry>
	<cfreturn q>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="getSpecimen" access="remote">
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
		<cfset q=queryNew("collection_object_id")>
		<cfset t = queryaddrow(q,1)>
		<cfset t = QuerySetCell(q, "collection_object_id", "Error: #cfcatch.Message# #cfcatch.detail#", 1)>
	</cfcatch>
	</cftry>
	<cfreturn q>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="addPartToContainer" access="remote">
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
			<cfreturn "0|#cfcatch.message# #cfcatch.detail#"> 
		</cfcatch>		
	</cftry>
	</cfoutput>	
</cffunction>
<!------------------------------------------------------------------>
<cffunction name="changefancyCOID" access="remote">
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
<cffunction name="changeexclusive_collection_id" access="remote">
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
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="changecustomOtherIdentifier" access="remote">
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
<!-------------------------------------------->
<cffunction name="getSpecSrchPref" access="remote">
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
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="findAccession"  access="remote">
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
<cffunction name="getSpecResultsData" access="remote">
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
		<cfset clist = result.COLUMNLIST>
		<cfset t = arrayNew(1)>
		<cfset temp = queryaddcolumn(result,"COLUMNLIST",t)>
		<cfset temp = QuerySetCell(result, "COLUMNLIST", "#valuelist(cols.column_name)#", 1)>
	<cfcatch>
			<cfset result = querynew("collection_object_id,message")>
			<cfset temp = queryaddrow(result,1)>
			<cfset temp = QuerySetCell(result, "collection_object_id", "-1", 1)>
			<cfset temp = QuerySetCell(result, "message", "#cfcatch.Message# #cfcatch.Detail#", 1)>
		</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="clientResultColumnList" access="remote">
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
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="makePart" access="remote">
	<cfargument name="collection_object_id" type="string" required="yes">
	<cfargument name="part_name" type="string" required="yes">
	<cfargument name="part_modifier" type="string" required="yes">
	<cfargument name="lot_count" type="string" required="yes">
	<cfargument name="is_tissue" type="string" required="yes">
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
						,DERIVED_FROM_cat_item,
						is_tissue )
					VALUES (
						#ccid.nv#,
					  '#PART_NAME#'
					  <cfif len(#PART_MODIFIER#) gt 0>
					  		,'#PART_MODIFIER#'
					  </cfif>
					  <cfif len(#PRESERVE_METHOD#) gt 0>
					  		,'#PRESERVE_METHOD#'
					  </cfif>
						,#collection_object_id#,
						#is_tissue# )
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
			<cfset q=queryNew("STATUS,PART_NAME,PART_MODIFIER,LOT_COUNT,IS_TISSUE,PRESERVE_METHOD,COLL_OBJ_DISPOSITION,CONDITION,COLL_OBJECT_REMARKS,BARCODE,NEW_CONTAINER_TYPE")>
			<cfset t = queryaddrow(q,1)>
			<cfset t = QuerySetCell(q, "STATUS", "success", 1)>
			<cfset t = QuerySetCell(q, "part_name", "#part_name#", 1)>
			<cfset t = QuerySetCell(q, "part_modifier", "#part_modifier#", 1)>
			<cfset t = QuerySetCell(q, "lot_count", "#lot_count#", 1)>
			<cfset t = QuerySetCell(q, "is_tissue", "#is_tissue#", 1)>
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
<cffunction name="getLoanPartResults" access="remote">
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
			specimen_part.IS_TISSUE,
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
<cffunction name="ssvar" access="remote">
	<cfargument name="startrow" type="numeric" required="yes">
	<cfargument name="maxrows" type="numeric" required="yes">
	<cfset session.maxrows=#maxrows#>
	<cfset session.startrow=#startrow#>
	<cfset result="ok">
	<cfreturn result>
</cffunction>
<!-------------------------------------------------------------------------------------------->
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
		<cfset result = "0|#cfcatch.message# #cfcatch.detail#">
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
			select  type_status || decode(count(*),1,'','(' || count(*) || ')') type_status from citation where collection_object_id=#cid# group by type_status
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
<cffunction name="changeAttDetr" access="remote">
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
	<cfargument name="idType" type="string" required="yes">
	<cfargument name="idvalue" type="numeric" required="yes">
	<cfargument name="annotation" type="string" required="yes">
	<cfinclude template="/includes/functionLib.cfm">
	<cftry>
		<cfquery name="insAnn" datasource="uam_god">
			insert into annotations (
				cf_username,
				#idType#,
				annotation
			) values (
				'#session.username#',
				#idvalue#,
				'#stripQuotes(urldecode(annotation))#'
			)
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
				<cfif idType is "collection_object_id">
					cataloged_item.collection_object_id=#idvalue#
				<cfelse>
					1=0
				</cfif>				
		</cfquery>
		<cfset mailTo = valuelist(whoTo.address)>
		<cfset mailTo=listappend(mailTo,Application.bugReportEmail,",")>
		<cfmail to="#mailTo#" from="annotation@#Application.fromEmail#" subject="Annotation Submitted" type="html">
			Arctos User #session.username# has submitted a specimen annotation. View details at
			<a href="#Application.ServerRootUrl#/info/reviewAnnotation.cfm?action=show&type=#idType#&id=#idvalue#">
			#Application.ServerRootUrl#/info/annotate.cfm?action=show&type=#idType#&id=#idvalue#
			</a>
		</cfmail>	
	<cfcatch>
		<cfset result = "A database error occured: #cfcatch.message# #cfcatch.detail#">
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