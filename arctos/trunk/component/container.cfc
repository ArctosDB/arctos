<cfcomponent>
<!------------------------------------------->
<cffunction name="moveContainerLocation" access="remote">
	<cfargument name="barcode" type="string" required="yes">
	<cfargument name="parent_barcode" type="string" required="yes">
	<cfargument name="newdisp" type="string" required="yes">
	<cfargument name="olddisp" type="string" required="yes">
	<cftry>
		<cfquery name="childID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select container_id,barcode,label,container_type from container where barcode = '#barcode#'
		</cfquery>
		<cfquery name="parentID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select container_id,barcode,label,container_type from container where barcode = '#parent_barcode#'
		</cfquery>
		
		<cfif #childID.recordcount# is not 1>
			<cfset result = "fail|Child container not found.">
			<cfreturn result>
		</cfif> 
		
		<cfif parentID.recordcount is not 1>
			<cfset result = "fail|Parent container not found.">
			<cfreturn result>
		</cfif>
		<cfset msg="">
		
		<cftransaction>
			<cfquery name="moveIt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update 
					container 
				set 
					parent_container_id=#parentID.container_id#
				where
					container_id = #childID.container_id#
			</cfquery>
			<cfif len(newdisp) gt 0>
				<cfquery name="childPartID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select
						specimen_part.collection_object_id,
						specimen_part.part_name,
						flat.guid,
						coll_object.coll_obj_disposition
					from
						specimen_part,
						flat,
						coll_object,
						coll_obj_cont_hist,
						container partcontainer
					where
						specimen_part.derived_from_cat_item=flat.collection_object_id and
						specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
						specimen_part.collection_object_id=coll_object.collection_object_id and
						coll_obj_cont_hist.container_id=partcontainer.container_id and
						partcontainer.parent_container_id=#childID.container_id#
				</cfquery>				
				<cfif childPartID.recordcount is not 1 or len(childPartID.collection_object_id) is 0>
					<cfset msg='no suitable child part found; disposition not updated'>
				<cfelse>
					<cfif len(olddisp) gt 0>
						<!--- only move the part of current disposition matches olddisp ---->
						<cfif olddisp is childPartID.COLL_OBJ_DISPOSITION>
							<cfset msg='updating part #childPartID.part_name# for GUID #childPartID.guid# from #childPartID.COLL_OBJ_DISPOSITION# to #newdisp#.'>
							<cfquery name="upDisp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								update coll_object set coll_obj_disposition='#newdisp#' where collection_object_id=#childPartID.collection_object_id#
							</cfquery>
						<cfelse>
							<cfset msg='#childPartID.part_name# for GUID <a target="_blank" href="/guid/#childPartID.guid#">#childPartID.guid#</a> disposition is #childPartID.COLL_OBJ_DISPOSITION# - not updating.'>
						</cfif>
					<cfelse>
						<!---- move the part no matter olddisp ---->
						<cfset msg='updating part #childPartID.part_name# for GUID <a target="_blank" href="/guid/#childPartID.guid#">#childPartID.guid#</a> from #childPartID.COLL_OBJ_DISPOSITION# to #newdisp#.'>
						<cfquery name="upDisp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							update coll_object set coll_obj_disposition='#newdisp#' where collection_object_id=#childPartID.collection_object_id#
						</cfquery>
					</cfif>
				</cfif>
			</cfif>
		</cftransaction>
		<cfset result = "success|#childID.barcode# (#childID.label#, #childID.container_type#) moved to #parentID.barcode# (#parentID.label#, #parentID.container_type#)">
		<cfif len(msg) gt 0>
			<cfset result=result & '; ' & msg>
		</cfif>
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
<!-------------------------------------------------------------->
<cffunction name="getContDetails" access="remote">
	<cfargument name="treeID" required="yes" type="string">
	<cfargument name="contr_id" required="no" type="string">
	<cfif len(#contr_id#) is 0 OR  len(#treeID#) is 0>
		<cfset result = "#treeID#||You must enter search criteria.">
		<cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
		<cfabort>
	</cfif>
	<cftry>
		<cfquery name="queriedFor" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" timeout="60">
			SELECT 
				CONTAINER_ID,
				PARENT_CONTAINER_ID,
				CONTAINER_TYPE,
				DESCRIPTION,
				PARENT_INSTALL_DATE,
				CONTAINER_REMARKS,
				label
			from container
			where container_id = #contr_id#
		</cfquery>
		<cfcatch>
			<cfset result = "#treeID#||A query error occured: #cfcatch.Message# #cfcatch.Detail# #cfcatch.sql#">
			<cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
			<cfreturn result>
			<cfabort>
		</cfcatch>
	</cftry>
	<cfif #queriedFor.recordcount# is 0>
		<cfset result = "#treeID#||No records were found.">
		<cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
		<cfabort>
   	</cfif>
	<cfset theString = '#queriedFor.CONTAINER_ID#||#queriedFor.PARENT_CONTAINER_ID#||#queriedFor.CONTAINER_TYPE#||#queriedFor.DESCRIPTION#||#queriedFor.PARENT_INSTALL_DATE#||#queriedFor.CONTAINER_REMARKS#||#queriedFor.label#'>
   	<cfset result = "#treeID#||#theString#">
   	<cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
	<cfreturn result>
</cffunction>
<!-------------------------------------------------------------->
<cffunction name="get_containerContents" access="remote">
	<cfargument name="contr_id" required="yes" type="string"><!--- ID of div, just gets passed back --->
	<cftry>
		<cfquery name="result" timeout="60" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT 
				CONTAINER_ID,
				PARENT_CONTAINER_ID,
				CONTAINER_TYPE,
				DESCRIPTION,
				PARENT_INSTALL_DATE,
				CONTAINER_REMARKS,
				label
			from container
			where parent_container_id = #contr_id#
		</cfquery>
		<cfcatch>
			<cfset result = querynew("CONTAINER_ID,MSG")>
			<cfset temp = queryaddrow(result,1)>
			<cfset temp = QuerySetCell(result, "container_id", "-1", 1)>
			<cfset temp = QuerySetCell(result, "msg", "A query error occured: #cfcatch.Message# #cfcatch.Detail#", 1)>
			<cfreturn result>
		</cfcatch>
	 </cftry>
 	<cfif #result.recordcount# is 0>
		<cfset result = querynew("CONTAINER_ID,MSG")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "container_id", "-1", 1)>
		<cfset temp = QuerySetCell(result, "msg", "No records were found.", 1)>
		<cfreturn result>
	</cfif>
	<cfreturn result>
</cffunction>
<!-------------------------------------------------------------->
<cffunction name="get_containerTree" access="remote">
	<cfargument name="q" type="string" required="true">
	<!--- accept a url-type argument, parse it out here --->
	
	<cfset loan_number="">
	<cfset cat_num="">
	<cfset barcode="">
	<cfset container_label="">
	<cfset description="">
	<cfset container_type="">
	<cfset part_name="">
	<cfset collection_id="">
	<cfset other_id_type="">
	<cfset other_id_value="">
	<cfset collection_object_id="">
	<cfset loan_trans_id="">
	<cfset table_name="">
	<cfset in_container_type="">
	<cfset transaction_id="">
	<cfset container_id="">
	<cfset begin_parent_install_date="">
	<cfset end_parent_install_date="">
	<cfloop list="#q#" index="p" delimiters="&">
		<cfset k=listgetat(p,1,"=")>
		<cfset v=listgetat(p,2,"=")>
		<cfset variables[ k ] = v >
	</cfloop>
	<cfif len(loan_number) is 0 AND
		len(cat_num) is 0 AND
		len(barcode) is 0 AND
		len(container_label) is 0 AND
		len(description) is 0 AND
		len(container_type) is 0 AND
		len(part_name) is 0 AND
		len(collection_id) is 0 and
		len(other_id_type) is 0 and
		len(other_id_value) is 0 and
		len(collection_object_id) is 0 and
		len(loan_trans_id) is 0 and
		len(table_name) is 0 and
		len(in_container_type) is 0 and
		len(transaction_id) is 0 and
		len(container_id) is 0 and
		len(begin_parent_install_date) is 0 and
		len(end_parent_install_date) is 0
		>
		<cfset result = querynew("CONTAINER_ID,MSG")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "container_id", "-1", 1)>
		<cfset temp = QuerySetCell(result, "msg", "You must enter search criteria.", 1)>
		<cfreturn result>
	</cfif>

	<cfset sel = "SELECT container.container_id">
	<cfset frm = " FROM container ">
	<cfset whr=" where 1=1 ">
	<cfif len(table_name) gt 0>
		<cfif frm does not contain " coll_obj_cont_hist ">
			<cfset frm = "#frm# inner join coll_obj_cont_hist on (container.container_id=coll_obj_cont_hist.container_id)">
		</cfif>
		<cfif frm does not contain " specimen_part ">
			<cfset frm = "#frm# inner join specimen_part on (coll_obj_cont_hist.collection_object_id=specimen_part.collection_object_id)">
		</cfif>
		<cfset frm = "#frm# inner join #session.username#.#table_name# #table_name# on (#table_name#.collection_object_id=specimen_part.derived_from_cat_item)">
	</cfif>
	<cfif len(transaction_id) gt 0>
		<cfset frm = "#frm# inner join trans_container on (trans_container.container_id=container.container_id) inner join trans on (trans_container.transaction_id=trans.transaction_id)">
		<cfset whr = "#whr# AND trans.transaction_id = #transaction_id#">
	</cfif>
	<cfif len(collection_object_id) gt 0>
		<cfif frm does not contain " coll_obj_cont_hist ">
			<cfset frm = "#frm# inner join coll_obj_cont_hist on (container.container_id=coll_obj_cont_hist.container_id)">
		</cfif>
		<cfif frm does not contain " specimen_part ">
			<cfset frm = "#frm# inner join specimen_part on (coll_obj_cont_hist.collection_object_id=specimen_part.collection_object_id)">
		</cfif>
		<cfif frm does not contain " cataloged_item ">
			<cfset frm = "#frm# inner join cataloged_item on (specimen_part.derived_from_cat_item=cataloged_item.collection_object_id)">
		</cfif>
		<cfset whr = "#whr# AND cataloged_item.collection_object_id IN (#collection_object_id#)">
	 </cfif>
	 
	 <cfif len(cat_num) gt 0>
		<cfif frm does not contain " coll_obj_cont_hist ">
			<cfset frm = "#frm# inner join coll_obj_cont_hist on (container.container_id=coll_obj_cont_hist.container_id)">
		</cfif>
		<cfif frm does not contain " specimen_part ">
			<cfset frm = "#frm# inner join specimen_part on (coll_obj_cont_hist.collection_object_id=specimen_part.collection_object_id)">
		</cfif>
		<cfif frm does not contain " cataloged_item ">
			<cfset frm = "#frm# inner join cataloged_item on (specimen_part.derived_from_cat_item=cataloged_item.collection_object_id)">
		</cfif>
		<cfset whr = "#whr# AND cataloged_item.cat_num IN (#cat_num#)">
	</cfif>
	 
	<cfif len(other_id_type) gt 0>
		<cfif frm does not contain " coll_obj_cont_hist ">
			<cfset frm = "#frm# inner join coll_obj_cont_hist on (container.container_id=coll_obj_cont_hist.container_id)">
		</cfif>
		<cfif frm does not contain " specimen_part ">
			<cfset frm = "#frm# inner join specimen_part on (coll_obj_cont_hist.collection_object_id=specimen_part.collection_object_id)">
		</cfif>
		<cfif frm does not contain " cataloged_item ">
			<cfset frm = "#frm# inner join cataloged_item on (specimen_part.derived_from_cat_item=cataloged_item.collection_object_id)">
		</cfif>
		<cfif frm does not contain " coll_obj_other_id_num ">
			<cfset frm = "#frm# inner join coll_obj_other_id_num on (cataloged_item.collection_object_id=coll_obj_other_id_num.collection_object_id)">
		</cfif>
		<cfset whr = "#whr# AND OTHER_ID_TYPE = '#other_id_type#'">
	 </cfif>
	 <cfif len(other_id_value) gt 0>
		<cfif frm does not contain " coll_obj_cont_hist ">
			<cfset frm = "#frm# inner join coll_obj_cont_hist on (container.container_id=coll_obj_cont_hist.container_id)">
		</cfif>
		<cfif frm does not contain " specimen_part ">
			<cfset frm = "#frm# inner join specimen_part on (coll_obj_cont_hist.collection_object_id=specimen_part.collection_object_id)">
		</cfif>
		<cfif frm does not contain " cataloged_item ">
			<cfset frm = "#frm# inner join cataloged_item on (specimen_part.derived_from_cat_item=cataloged_item.collection_object_id)">
		</cfif>
		<cfif frm does not contain " coll_obj_other_id_num ">
			<cfset frm = "#frm# inner join coll_obj_other_id_num on (cataloged_item.collection_object_id=coll_obj_other_id_num.collection_object_id)">
		</cfif>		
		<cfset whr = "#whr# AND upper(display_value) like '#ucase(other_id_value)#'">
	 </cfif>
	 <cfif len(barcode) gt 0>
	 	<cfset bclist = "">
		<cfloop list="#barcode#" index="i">
			<cfif len(bclist) is 0>
				<cfset bclist = "'#i#'">
			<cfelse>
				<cfset bclist = "#bclist#,'#i#'">
			</cfif>
		</cfloop>
		<cfset whr = "#whr# AND barcode IN (#bclist#)">
	</cfif>
	<cfif len(container_label) gt 0>
		<cfset whr = "#whr# AND upper(label) like '#ucase(container_label)#'">
	 </cfif>
	  <cfif len(description) gt 0>
		<cfset whr = "#whr# AND upper(description) LIKE '%#ucase(description)#%'">
	 </cfif>
	  <cfif len(container_type) gt 0>
		<cfset whr = "#whr# AND container_type='#container_type#'">
	 </cfif>
	  <cfif len(begin_parent_install_date) gt 0 and len(begin_parent_install_date) gt 0>
		<cfset whr = "#whr# AND to_char(PARENT_INSTALL_DATE,'YYYY-MM-DD""T""HH24:MI:SS') >= '#begin_parent_install_date#'">
	 </cfif>
	  <cfif len(end_parent_install_date) gt 0 and len(end_parent_install_date) gt 0>
		<cfset whr = "#whr# AND to_char(PARENT_INSTALL_DATE,'YYYY-MM-DD""T""HH24:MI:SS') <= '#end_parent_install_date#'">
	 </cfif>
	 <cfif len(part_name) gt 0>
		<cfif frm does not contain " coll_obj_cont_hist ">
			<cfset frm = "#frm# inner join coll_obj_cont_hist on (container.container_id=coll_obj_cont_hist.container_id)">
		</cfif>
		<cfif frm does not contain " specimen_part ">
			<cfset frm = "#frm# inner join specimen_part on (coll_obj_cont_hist.collection_object_id=specimen_part.collection_object_id)">
		</cfif>
		<cfset whr = "#whr# AND specimen_part.part_Name='#part_Name#'">
	 </cfif>
	  <cfif len(loan_trans_id) gt 0>
		<cfif frm does not contain " coll_obj_cont_hist ">
			<cfset frm = "#frm# inner join coll_obj_cont_hist on (container.container_id=coll_obj_cont_hist.container_id)">
		</cfif>
		<cfif frm does not contain " specimen_part ">
			<cfset frm = "#frm# inner join specimen_part on (coll_obj_cont_hist.collection_object_id=specimen_part.collection_object_id)">
		</cfif>
		<cfif frm does not contain " loan_item ">
			<cfset frm = "#frm# inner join loan_item on (specimen_part.collection_object_id=loan_item.collection_object_id)">
		</cfif>
		<cfset whr = "#whr# AND loan_item.transaction_id = #loan_trans_id#">
	 </cfif>

	<cfif len(loan_number) gt 0>
		<cfif frm does not contain " coll_obj_cont_hist ">
			<cfset frm = "#frm# inner join coll_obj_cont_hist on (container.container_id=coll_obj_cont_hist.container_id)">
		</cfif>
		<cfif frm does not contain " specimen_part ">
			<cfset frm = "#frm# inner join specimen_part on (coll_obj_cont_hist.collection_object_id=specimen_part.collection_object_id)">
		</cfif>
		<cfif frm does not contain " loan_item ">
			<cfset frm = "#frm# inner join loan_item on (specimen_part.collection_object_id=loan_item.collection_object_id)">
		</cfif>
		<cfif frm does not contain " loan ">
			<cfset frm = "#frm# inner join loan on (loan_item.transaction_id=loan.transaction_id)">
		</cfif>
		<cfset whr = "#whr# AND upper(loan.loan_number) = '#ucase(loan_number)#'">
	</cfif>
	<cfif len(collection_id) gt 0>
		<cfif frm does not contain " coll_obj_cont_hist ">
			<cfset frm = "#frm# inner join coll_obj_cont_hist on (container.container_id=coll_obj_cont_hist.container_id)">
		</cfif>
		<cfif frm does not contain " specimen_part ">
			<cfset frm = "#frm# inner join specimen_part on (coll_obj_cont_hist.collection_object_id=specimen_part.collection_object_id)">
		</cfif>
		<cfif frm does not contain " cataloged_item ">
			<cfset frm = "#frm# inner join cataloged_item on (specimen_part.derived_from_cat_item=cataloged_item.collection_object_id)">
		</cfif>
		<cfset whr = "#whr# AND cataloged_item.collection_id = #collection_id#">
	 </cfif>
	 <cfif len(container_id) gt 0>
		<cfset whr = "#whr# AND container.container_id = #container_id#">
	</cfif>
	 <cfset sql = "#sel# #frm# #whr#">
	<cfset thisSql = "
				SELECT 
					CONTAINER_ID,
					nvl(PARENT_CONTAINER_ID,0) PARENT_CONTAINER_ID,
				CONTAINER_TYPE,
				DESCRIPTION,
				PARENT_INSTALL_DATE,
				CONTAINER_REMARKS,
				someRandomSequence.nextval ID,
				label,
				SYS_CONNECT_BY_PATH(container_type,':') thepath
				 from container
				start with container_id IN (
					#sql#
				)
				connect by prior parent_container_id = container_id
			">

			 <cftry>
			 	<cfquery name="queriedFor" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" timeout="60">
					#preservesinglequotes(thisSql)#
				</cfquery>
				<cfcatch>
					<cfset result = querynew("CONTAINER_ID,MSG")>
					<cfset temp = queryaddrow(result,1)>
					<cfset temp = QuerySetCell(result, "container_id", "-1", 1)>
					<cfset temp = QuerySetCell(result, "msg", "A query error occured: #cfcatch.Message# #cfcatch.Detail# -#thisSql#-", 1)>
					<cfreturn result>
				</cfcatch>
			 </cftry>
			
		 	<cfif #queriedFor.recordcount# is 0>
				<cfset result = querynew("CONTAINER_ID,MSG")>
				<cfset temp = queryaddrow(result,1)>
				<cfset temp = QuerySetCell(result, "container_id", "-1", 1)>
				<cfset temp = QuerySetCell(result, "msg", "No records were found.", 1)>
				<cfreturn result>
	   		</cfif>
	   
				 <cfquery name="ro" dbtype="query">
					select 
						CONTAINER_ID,
						PARENT_CONTAINER_ID,
						CONTAINER_TYPE,
						DESCRIPTION,
						PARENT_INSTALL_DATE,
						CONTAINER_REMARKS,
						label,
						id
					 from queriedFor
					group by
						CONTAINER_ID,
						PARENT_CONTAINER_ID,
						CONTAINER_TYPE,
						DESCRIPTION,
						PARENT_INSTALL_DATE,
						CONTAINER_REMARKS,
						label,
						id
						order by id desc
				 </cfquery>
	 			<cfset alreadyGotOne = "-1">
				<cfset i=1>
				<cfset result = querynew("CONTAINER_ID,PARENT_CONTAINER_ID,LABEL,CONTAINER_TYPE")>
	  			<cfloop query="ro">
	  				<cfif not listfind(alreadyGotOne,CONTAINER_ID)>
						<cfif #PARENT_CONTAINER_ID# is 0>
							<cfset thisParent = "container0">
						<cfelse>
							<cfset thisParent = #PARENT_CONTAINER_ID#>
						</cfif>
						<cfset temp = queryaddrow(result,1)>
						<cfset temp = QuerySetCell(result, "container_id", "#container_id#", #i#)>
						<cfset temp = QuerySetCell(result, "parent_container_id", "#thisParent#", #i#)>
						<cfset temp = QuerySetCell(result, "label", "#label#", #i#)>
						<cfset temp = QuerySetCell(result, "container_type", "#ro.container_type#", #i#)>
						<cfset alreadyGotOne = "#alreadyGotOne#,#CONTAINER_ID#">
						<cfset i=#i#+1>
					</cfif>
	  			</cfloop>
		<cfreturn result>
</cffunction>	
<!-------------------------------------------------------------->


















<!-------------------------------------------------------------->



<cffunction name="moveContainer" returntype="string">
	<cfargument name="treeID" required="yes" type="string">
	<cfargument name="id" required="yes" type="numeric">
	<cfargument name="pid" required="yes" type="numeric">
	
	
	   	<cfset result = "#treeID#||success">
	   	<cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>	



<!-------------------------------------------------------------->

<cffunction name="getContChildren" returntype="string">
	<cfargument name="treeID" required="yes" type="string">
	<cfargument name="contr_id" required="no" type="string">
	
	<!--- require some search terms --->
	<cfif len(#contr_id#) is 0 OR  len(#treeID#) is 0>
		<cfset result = "#treeID#||You must enter search criteria.">
		<cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
		<cfabort>
	</cfif>
			 <cftry>
			 	 <cfquery name="queriedFor" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" timeout="60">
					SELECT 
							CONTAINER_ID,
						PARENT_CONTAINER_ID,
						CONTAINER_TYPE,
						DESCRIPTION,
						PARENT_INSTALL_DATE,
						CONTAINER_REMARKS,
						label
						 from container
						where parent_container_id = #contr_id#
				 </cfquery>
				<cfcatch>
					<cfset result = "#treeID#||A query error occured: #cfcatch.Message# #cfcatch.Detail#">
					<cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
					<cfreturn result>
					<cfabort>
				</cfcatch>
			 </cftry>
			
		 	<cfif #queriedFor.recordcount# is 0>
				<cfset result = "#treeID#||No records were found.">
				<cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
				<cfreturn result>
				<cfabort>
	   		</cfif>
				
				 <cfset theString = ''>
	  			<cfloop query="queriedFor">
						<cfset theString = '#theString#tree_#treeID#.insertNewChild("#PARENT_CONTAINER_ID#",#CONTAINER_ID#,"#label# (#container_type#)",0,0,0,0,"",1);'>
				</cfloop>
	   	<cfset result = "#treeID#||#theString#">
	   	<cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>	

<!-------------------------------------------------------------->





<!-------------------------------------------------------------->
<cffunction name="get_containerTree_old" returntype="query">
	<cfargument name="treeID" required="yes" type="string">
	<cfargument name="srch" required="yes" type="string">
	<cfargument name="cat_num" required="yes" type="string">
	<cfargument name="barcode" required="yes" type="string">
	<cfargument name="container_label" required="yes" type="string">
	<cfargument name="description" required="yes" type="string">
	<cfargument name="container_type" required="yes" type="string">
	<cfargument name="part_name" required="yes" type="string">
	<cfargument name="collection_id" required="yes" type="string">
	<cfargument name="other_id_type" required="yes" type="string">
	<cfargument name="other_id_value" required="yes" type="string">
	<cfargument name="contr_id" required="no" type="string">
	<cfargument name="begin_parent_install_date" required="no" type="string">
	<cfargument name="end_parent_install_date" required="no" type="string">
	
	
	ppp<cfdump var=#end_parent_install_date#>
	
	<cfset sel = "
		SELECT 
			 container.container_id">
	<cfset frm = "
		 FROM
		 	container">
	<cfset whr = " WHERE ">
	<cfif #srch# is "part">
	 	<cfset frm = "#frm#,coll_obj_cont_hist,specimen_part,cataloged_item">
	 	<cfset whr = "#whr# container.container_id = coll_obj_cont_hist.container_id 
	 		AND coll_obj_cont_hist.collection_object_id = specimen_part.collection_object_id
			AND specimen_part.derived_from_cat_item = cataloged_item.collection_object_id">
	 <cfelseif #srch# is "container">
	 	<cfset frm = "#frm#,fluid_container_history">	
		<cfset whr = "#whr# container.container_id = fluid_container_history.container_id (+)">
	 </cfif>
	
	 <cfif len(cat_num) gt 0 and cat_num neq "-1">
		<cfset whr = "#whr# AND cataloged_item.cat_num IN (#cat_num#)">
	 </cfif>
	 <cfif len(#other_id_type#) gt 0 and #other_id_type# neq "-1">
		<cfset frm = "#frm#,coll_obj_other_id_num">	
		<cfset whr = "#whr# AND cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id (+)">
		<cfset whr = "#whr# AND OTHER_ID_TYPE = '#other_id_type#'">
	 </cfif>
	 <cfif len(#other_id_value#) gt 0 and #other_id_value# neq "-1">
		<cfif #frm# does not contain "coll_obj_other_id_num">
			<cfset frm = "#frm#,coll_obj_other_id_num">	
			<cfset whr = "#whr# AND cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id (+)">
		</cfif>
		<cfset whr = "#whr# AND OTHER_ID_NUM = '#other_id_value#'">
	 </cfif>
	 <cfif len(#barcode#) gt 0 and #barcode# neq "-1">
	 	<cfset bclist = "">
		<cfloop list="#barcode#" index="i">
			<cfif len(#bclist#) is 0>
				<cfset bclist = "'#i#'">
			<cfelse>
				<cfset bclist = "#bclist#,'#i#'">
			</cfif>
		</cfloop>
		<cfset whr = "#whr# AND barcode IN (#bclist#)">
	 </cfif>
	 <cfif len(#container_label#) gt 0 and #container_label# neq "-1">
		<cfset whr = "#whr# AND label = '#container_label#'">
	 </cfif>
	  <cfif len(#description#) gt 0 and #description# neq "-1">
		<cfset whr = "#whr# AND upper(description) LIKE '%#ucase(description)#%'">
	 </cfif>
	  <cfif len(#container_type#) gt 0 and #container_type# neq "-1">
		<cfset whr = "#whr# AND container_type='#container_type#'">
	 </cfif>
	 <cfif len(#part_name#) gt 0 and #part_name# neq "-1">
		<cfset whr = "#whr# AND part_Name='#part_Name#'">
	 </cfif>
	  <cfif len(#collection_id#) gt 0 and #collection_id# neq "-1">
		<cfset whr = "#whr# AND cataloged_item.collection_id = #collection_id#">
	 </cfif>
	 <cfif len(#contr_id#) gt 0 and #contr_id# neq "-1">
		<cfset whr = "#whr# AND container.container_id = #contr_id#">
	 </cfif>
	  <cfif len(begin_parent_install_date) gt 0 and len(begin_parent_install_date) gt 0>
		<cfset whr = "#whr# AND to_char(PARENT_INSTALL_DATE,'YYYY-MM-DD""T""HH24:MI:SS') >= '#begin_parent_install_date#'">
	 </cfif>
	  <cfif len(end_parent_install_date) gt 0 and len(end_parent_install_date) gt 0>
		<cfset whr = "#whr# AND to_char(PARENT_INSTALL_DATE,'YYYY-MM-DD""T""HH24:MI:SS') <= '#end_parent_install_date#'">
	 </cfif>
	 
	
	
	<!--- require some search terms --->
	<cfif len(#cat_num#) is 0 AND
		len(#barcode#) is 0 AND
		len(#container_label#) is 0 AND
		len(#description#) is 0 AND
		len(#container_type#) is 0 AND
		len(#part_name#) is 0 AND
		len(#collection_id#) is 0 and
		len(#other_id_type#) is 0 and
		len(#other_id_value#) is 0 and
		len(#contr_id#) is 0 and
		len(begin_parent_install_date) is 0 and
		len(end_parent_install_date) is 0
		>
		
		 <cfset result = querynew("treeID,container_id")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "treeID", "-1", 1)>
		<cfset temp = QuerySetCell(result, "container_id", "You must enter search criteria.", 1)>
		<cfreturn result>
		<cfabort>
	</cfif>
	
		<cfset sql = "#sel# #frm# #whr#">
		<!---
		<cfset result = querynew("treeID,container_id")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "treeID", "-1", 1)>
		<cfset temp = QuerySetCell(result,"container_id", "#sql#", 1)>
		<cfreturn result>
		<cfabort>
		--->
		<cfset thisSql = "
				SELECT 
					CONTAINER_ID,
				PARENT_CONTAINER_ID,
				CONTAINER_TYPE,
				DESCRIPTION,
				PARENT_INSTALL_DATE,
				CONTAINER_REMARKS,
				someRandomSequence.nextval ID,
				label
				 from container
				start with container_id IN (
					#sql#
				)
				connect by prior parent_container_id = container_id
			">
					
			 <cftry>
			 	 <cfquery name="queriedFor" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" timeout="60">
					#preservesinglequotes(thisSql)#
				 </cfquery>
				<cfcatch>
					<cfset result = querynew("treeID,container_id")>
					<cfset temp = queryaddrow(result,1)>
					<cfset temp = QuerySetCell(result, "treeID", "-1", 1)>
					<cfset temp = QuerySetCell(result, "container_id", "A query error occured: #cfcatch.Message# #cfcatch.Detail# -#thisSql#-", 1)>
					<cfreturn result>
					<cfabort>
				</cfcatch>
			 </cftry>
			
		 	<cfif #queriedFor.recordcount# is 0>
				<cfset result = querynew("treeID,container_id")>
				<cfset temp = queryaddrow(result,1)>
				<cfset temp = QuerySetCell(result, "treeID", "-1", 1)>
				<cfset temp = QuerySetCell(result, "container_id", "No records were found.", 1)>
				<cfreturn result>
				<cfabort>
	   		</cfif>
				 <cfquery name="ro" dbtype="query">
					select 
						CONTAINER_ID,
						PARENT_CONTAINER_ID,
						CONTAINER_TYPE,
						DESCRIPTION,
						PARENT_INSTALL_DATE,
						CONTAINER_REMARKS,
						label,
						id
					 from queriedFor
					group by
						CONTAINER_ID,
						PARENT_CONTAINER_ID,
						CONTAINER_TYPE,
						DESCRIPTION,
						PARENT_INSTALL_DATE,
						CONTAINER_REMARKS,
						label,
						id
						order by id desc
				 </cfquery>
	 			<cfset alreadyGotOne = "-1">
				<cfset i=1>
				<cfset result = querynew("treeID,container_id,parent_container_id,label,container_type")>
	  			<cfloop query="ro">
	  				<cfif not listfind(alreadyGotOne,CONTAINER_ID)>
						<cfif #PARENT_CONTAINER_ID# is 0>
							<cfset thisParent = "container0">
						<cfelse>
							<cfset thisParent = #PARENT_CONTAINER_ID#>
						</cfif>
						<cfset temp = queryaddrow(result,1)>
						<cfset temp = QuerySetCell(result, "treeID", "#treeID#", #i#)>
						<cfset temp = QuerySetCell(result, "container_id", "#container_id#", #i#)>
						<cfset temp = QuerySetCell(result, "parent_container_id", "#thisParent#", #i#)>
						<cfset temp = QuerySetCell(result, "label", "#label#", #i#)>
						<cfset temp = QuerySetCell(result, "container_type", "#ro.container_type#", #i#)>
						<!---
						<cfset theString = '#theString#tree_#treeID#.insertNewChild("#thisParent#",#CONTAINER_ID#,"#label# (#ro.CONTAINER_TYPE#)",0,0,0,0,"",1);'>
					--->
						<cfset alreadyGotOne = "#alreadyGotOne#,#CONTAINER_ID#">
						<cfset i=#i#+1>
					</cfif>
					
	  			</cfloop>
		<cfreturn result>
</cffunction>	
<!-------------------------------------------------------------->
<cffunction name="buildTreeScript" returntype="string">
	<cfargument name="treeID" required="yes" type="string">
	<cfargument name="srch" required="yes" type="string">
	<cfargument name="cat_num" required="yes" type="string">
	<cfargument name="barcode" required="yes" type="string">
	<cfargument name="container_label" required="yes" type="string">
	<cfargument name="description" required="yes" type="string">
	<cfargument name="container_type" required="yes" type="string">
	<cfargument name="part_name" required="yes" type="string">
	<cfargument name="collection_id" required="yes" type="string">
	<cfargument name="contr_id" required="no" type="string">
	
	<cfset sel = "
		SELECT 
			 container.container_id">
	<cfset frm = "
		 FROM
		 	container">
	<cfset whr = " WHERE ">
	<cfif #srch# is "part">
	 	<cfset frm = "#frm#,coll_obj_cont_hist,specimen_part,cataloged_item">
	 	<cfset whr = "#whr# container.container_id = coll_obj_cont_hist.container_id 
	 		AND coll_obj_cont_hist.collection_object_id = specimen_part.collection_object_id
			AND specimen_part.derived_from_cat_item = cataloged_item.collection_object_id">
	 <cfelseif #srch# is "container">
	 	<cfset frm = "#frm#,fluid_container_history">	
		<cfset whr = "#whr# container.container_id = fluid_container_history.container_id (+)">
	 </cfif>
	
	 <cfif len(#cat_num#) gt 0 and #cat_num# neq "-1">
		<cfset whr = "#whr# AND cataloged_item.cat_num IN (#cat_num#)">
	 </cfif>
	 <cfif len(#barcode#) gt 0 and #barcode# neq "-1">
	 	<cfset bclist = "">
		<cfloop list="#barcode#" index="i">
			<cfif len(#bclist#) is 0>
				<cfset bclist = "'#i#'">
			<cfelse>
				<cfset bclist = "#bclist#,'#i#'">
			</cfif>
		</cfloop>
		<cfset whr = "#whr# AND barcode IN (#bclist#)">
	 </cfif>
	 <cfif len(#container_label#) gt 0 and #container_label# neq "-1">
		<cfset whr = "#whr# AND label = '#container_label#'">
	 </cfif>
	  <cfif len(#description#) gt 0 and #description# neq "-1">
		<cfset whr = "#whr# AND upper(description) LIKE '%#ucase(description)#%'">
	 </cfif>
	  <cfif len(#container_type#) gt 0 and #container_type# neq "-1">
		<cfset whr = "#whr# AND container_type='#container_type#'">
	 </cfif>
	 <cfif len(#part_name#) gt 0 and #part_name# neq "-1">
		<cfset whr = "#whr# AND part_Name='#part_Name#'">
	 </cfif>
	  <cfif len(#collection_id#) gt 0 and #collection_id# neq "-1">
		<cfset whr = "#whr# AND cataloged_item.collection_id = #collection_id#">
	 </cfif>
	 <cfif len(#contr_id#) gt 0 and #contr_id# neq "-1">
		<cfset whr = "#whr# AND container.container_id = #contr_id#">
	 </cfif>
	 
	<!--- require some search terms --->
	<cfif len(#cat_num#) is 0 AND
		len(#barcode#) is 0 AND
		len(#container_label#) is 0 AND
		len(#description#) is 0 AND
		len(#container_type#) is 0 AND
		len(#part_name#) is 0 AND
		len(#collection_id#) is 0 and
		len(#container_id#) is 0
		>
		 <cfset result = "#treeID#||You must enter search criteria.">
		<cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
		<cfabort>
	</cfif>
	
		<cfset sql = "#sel# #frm# #whr#">
		<cfset thisSql = "
				SELECT 
					CONTAINER_ID,
				PARENT_CONTAINER_ID,
				CONTAINER_TYPE,
				DESCRIPTION,
				PARENT_INSTALL_DATE,
				CONTAINER_REMARKS,
				someRandomSequence.nextval ID,
				label
				 from container
				start with container_id IN (
					#sql#
				)
				connect by prior parent_container_id = container_id
			">
			
			 <cftry>
			 	 <cfquery name="queriedFor" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" timeout="60">
					#preservesinglequotes(thisSql)#
				 </cfquery>
				<cfcatch>
					<cfset result = "#treeID#||A query error occured: #cfcatch.Message# #cfcatch.Detail#">
					<cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
					<cfreturn result>
					<cfabort>
				</cfcatch>
			 </cftry>
			
		 	<cfif #queriedFor.recordcount# is 0>
				<cfset result = "#treeID#||No records were found.\#preservesinglequotes(thisSql)#">
				<cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
				<cfreturn result>
				<cfabort>
	   		</cfif>
				 <cfquery name="ro" dbtype="query">
					select CONTAINER_ID,
						PARENT_CONTAINER_ID,
						CONTAINER_TYPE,
						DESCRIPTION,
						PARENT_INSTALL_DATE,
						CONTAINER_REMARKS,
						label,
						id
					 from queriedFor
					group by
						CONTAINER_ID,
						PARENT_CONTAINER_ID,
						CONTAINER_TYPE,
						DESCRIPTION,
						PARENT_INSTALL_DATE,
						CONTAINER_REMARKS,
						label,
						id
						order by id desc
				 </cfquery>
				 <cfset theString = ''>
	 			<cfset alreadyGotOne = "-1">
	  			<cfloop query="ro">
	  				<cfif not listfind(alreadyGotOne,CONTAINER_ID)>
						<cfif #PARENT_CONTAINER_ID# is 0>
							<cfset thisParent = "container0">
						<cfelse>
							<cfset thisParent = #PARENT_CONTAINER_ID#>
						</cfif>
						<cfset theString = '#theString#tree_#treeID#.insertNewChild("#thisParent#",#CONTAINER_ID#,"#label# (#ro.CONTAINER_TYPE#)",0,0,0,0,"",1);'>
						<cfset alreadyGotOne = "#alreadyGotOne#,#CONTAINER_ID#">
					</cfif>
	  			</cfloop>
	   	<cfset result = "#treeID#||#theString#">
	   	<cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>

</cfcomponent>