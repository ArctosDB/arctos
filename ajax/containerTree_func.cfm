<cfinclude template="/ajax/core/cfajax.cfm">

<!-------------------------------------------------------------->
<cffunction name="get_containerContents" returntype="query">
	<cfargument name="contr_id" required="yes" type="string"><!--- ID of div, just gets passed back --->
	<cftry>
		<cfquery name="result" datasource="#Application.web_user#" timeout="60">
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
			<cfset result = querynew("container_id,msg")>
			<cfset temp = queryaddrow(result,1)>
			<cfset temp = QuerySetCell(result, "container_id", "-1", 1)>
			<cfset temp = QuerySetCell(result, "msg", "A query error occured: #cfcatch.Message# #cfcatch.Detail#", 1)>
			<cfreturn result>
		</cfcatch>
	 </cftry>
 	<cfif #result.recordcount# is 0>
		<cfset result = querynew("container_id,msg")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "container_id", "-1", 1)>
		<cfset temp = QuerySetCell(result, "msg", "No records were found.", 1)>
		<cfreturn result>
	</cfif>
	<cfreturn result>
</cffunction>	
<!-------------------------------------------------------------->
<cffunction name="get_containerTree" returntype="query">
	<!---<cfargument name="cat_num" required="yes" type="string">
	<cfargument name="barcode" required="yes" type="string">
	<cfargument name="container_label" required="yes" type="string">
	<cfargument name="description" required="yes" type="string">
	<cfargument name="container_type" required="yes" type="string">
	<cfargument name="part_name" required="yes" type="string">
	<cfargument name="collection_id" required="yes" type="string">
	<cfargument name="other_id_type" required="yes" type="string">
	<cfargument name="other_id_value" required="yes" type="string">
	--->
	<cfargument name="q" type="string" required="true">
	<!--- accept a url-type argument, parse it out here --->
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
	<cfloop list="#q#" index="p" delimiters="&">
		<cfset k=listgetat(p,1,"=")>
		<cfset v=listgetat(p,2,"=")>
		<cfset variables[ k ] = v >
	</cfloop>
	
	<cfif len(#cat_num#) is 0 AND
		len(#barcode#) is 0 AND
		len(#container_label#) is 0 AND
		len(#description#) is 0 AND
		len(#container_type#) is 0 AND
		len(#part_name#) is 0 AND
		len(#collection_id#) is 0 and
		len(#other_id_type#) is 0 and
		len(#other_id_value#) is 0 and
		len(#collection_object_id#) is 0 and
		len(#loan_trans_id#) is 0 and
		len(#table_name#) is 0 and
		len(#in_container_type#) is 0
		>
		
		 <cfset result = querynew("container_id,msg")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "container_id", "-1", 1)>
		<cfset temp = QuerySetCell(result, "msg", "You must enter search criteria.", 1)>
		<cfreturn result>
	</cfif>

	<cfset sel = "SELECT container.container_id">
	<cfset frm = " FROM container ">
	<cfset whr=" where 1=1 ">
	<cfif len(#table_name#) gt 0>
		<cfif #frm# does not contain " coll_obj_cont_hist ">
			<cfset frm = "#frm# inner join coll_obj_cont_hist on (container.container_id=coll_obj_cont_hist.container_id)">
		</cfif>
		<cfif #frm# does not contain " specimen_part ">
			<cfset frm = "#frm# inner join specimen_part on (coll_obj_cont_hist.collection_object_id=specimen_part.collection_object_id)">
		</cfif>
		<cfset frm = "#frm# inner join #session.username#.#table_name# #table_name# on (#table_name#.collection_object_id=specimen_part.derived_from_cat_item)">
	</cfif>
	<cfif len(#collection_object_id#) gt 0>
		<cfif #frm# does not contain " coll_obj_cont_hist ">
			<cfset frm = "#frm# inner join coll_obj_cont_hist on (container.container_id=coll_obj_cont_hist.container_id)">
		</cfif>
		<cfif #frm# does not contain " specimen_part ">
			<cfset frm = "#frm# inner join specimen_part on (coll_obj_cont_hist.collection_object_id=specimen_part.collection_object_id)">
		</cfif>
		<cfif #frm# does not contain " cataloged_item ">
			<cfset frm = "#frm# inner join cataloged_item on (specimen_part.derived_from_cat_item=cataloged_item.collection_object_id)">
		</cfif>
		<cfset whr = "#whr# AND cataloged_item.collection_object_id IN (#collection_object_id#)">
	 </cfif>
	 
	 <cfif len(#cat_num#) gt 0>
		<cfif #frm# does not contain " coll_obj_cont_hist ">
			<cfset frm = "#frm# inner join coll_obj_cont_hist on (container.container_id=coll_obj_cont_hist.container_id)">
		</cfif>
		<cfif #frm# does not contain " specimen_part ">
			<cfset frm = "#frm# inner join specimen_part on (coll_obj_cont_hist.collection_object_id=specimen_part.collection_object_id)">
		</cfif>
		<cfif #frm# does not contain " cataloged_item ">
			<cfset frm = "#frm# inner join cataloged_item on (specimen_part.derived_from_cat_item=cataloged_item.collection_object_id)">
		</cfif>
		<cfset whr = "#whr# AND cataloged_item.cat_num IN (#cat_num#)">
	 </cfif>

	 
	<cfif len(#other_id_type#) gt 0>
		<cfif #frm# does not contain " coll_obj_cont_hist ">
			<cfset frm = "#frm# inner join coll_obj_cont_hist on (container.container_id=coll_obj_cont_hist.container_id)">
		</cfif>
		<cfif #frm# does not contain " specimen_part ">
			<cfset frm = "#frm# inner join specimen_part on (coll_obj_cont_hist.collection_object_id=specimen_part.collection_object_id)">
		</cfif>
		<cfif #frm# does not contain " cataloged_item ">
			<cfset frm = "#frm# inner join cataloged_item on (specimen_part.derived_from_cat_item=cataloged_item.collection_object_id)">
		</cfif>
		<cfif #frm# does not contain " coll_obj_other_id_num ">
			<cfset frm = "#frm# inner join coll_obj_other_id_num on (cataloged_item.collection_object_id=coll_obj_other_id_num.collection_object_id)">
		</cfif>
		<cfset whr = "#whr# AND OTHER_ID_TYPE = '#other_id_type#'">
	 </cfif>
	 <cfif len(#other_id_value#) gt 0>
		<cfif #frm# does not contain " coll_obj_cont_hist ">
			<cfset frm = "#frm# inner join coll_obj_cont_hist on (container.container_id=coll_obj_cont_hist.container_id)">
		</cfif>
		<cfif #frm# does not contain " specimen_part ">
			<cfset frm = "#frm# inner join specimen_part on (coll_obj_cont_hist.collection_object_id=specimen_part.collection_object_id)">
		</cfif>
		<cfif #frm# does not contain " cataloged_item ">
			<cfset frm = "#frm# inner join cataloged_item on (specimen_part.derived_from_cat_item=cataloged_item.collection_object_id)">
		</cfif>
		<cfif #frm# does not contain " coll_obj_other_id_num ">
			<cfset frm = "#frm# inner join coll_obj_other_id_num on (cataloged_item.collection_object_id=coll_obj_other_id_num.collection_object_id)">
		</cfif>		
		<cfset whr = "#whr# AND upper(display_value) like '#ucase(other_id_value)#'">
	 </cfif>
	 <cfif len(#barcode#) gt 0>
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
	<cfif len(#container_label#) gt 0>
		<cfset whr = "#whr# AND upper(label) like '#ucase(container_label)#'">
	 </cfif>
	  <cfif len(#description#) gt 0>
		<cfset whr = "#whr# AND upper(description) LIKE '%#ucase(description)#%'">
	 </cfif>
	  <cfif len(#container_type#) gt 0>
		<cfset whr = "#whr# AND container_type='#container_type#'">
	 </cfif>
	 
	 <cfif len(#part_name#) gt 0>
		<cfif #frm# does not contain " coll_obj_cont_hist ">
			<cfset frm = "#frm# inner join coll_obj_cont_hist on (container.container_id=coll_obj_cont_hist.container_id)">
		</cfif>
		<cfif #frm# does not contain " specimen_part ">
			<cfset frm = "#frm# inner join specimen_part on (coll_obj_cont_hist.collection_object_id=specimen_part.collection_object_id)">
		</cfif>
		<cfset whr = "#whr# AND specimen_part.part_Name='#part_Name#'">
	 </cfif>
	  <cfif len(#loan_trans_id#) gt 0>
		<cfif #frm# does not contain " coll_obj_cont_hist ">
			<cfset frm = "#frm# inner join coll_obj_cont_hist on (container.container_id=coll_obj_cont_hist.container_id)">
		</cfif>
		<cfif #frm# does not contain " specimen_part ">
			<cfset frm = "#frm# inner join specimen_part on (coll_obj_cont_hist.collection_object_id=specimen_part.collection_object_id)">
		</cfif>
		<cfif #frm# does not contain " loan_item ">
			<cfset frm = "#frm# inner join loan_item on (specimen_part.collection_object_id=loan_item.collection_object_id)">
		</cfif>
		<cfset whr = "#whr# AND loan_item.transaction_id = #loan_trans_id#">
	 </cfif>

	<cfif len(#collection_id#) gt 0>
		<cfif #frm# does not contain " coll_obj_cont_hist ">
			<cfset frm = "#frm# inner join coll_obj_cont_hist on (container.container_id=coll_obj_cont_hist.container_id)">
		</cfif>
		<cfif #frm# does not contain " specimen_part ">
			<cfset frm = "#frm# inner join specimen_part on (coll_obj_cont_hist.collection_object_id=specimen_part.collection_object_id)">
		</cfif>
		<cfif #frm# does not contain " cataloged_item ">
			<cfset frm = "#frm# inner join cataloged_item on (specimen_part.derived_from_cat_item=cataloged_item.collection_object_id)">
		</cfif>
		<cfset whr = "#whr# AND cataloged_item.collection_id = #collection_id#">
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
			 	 <cfquery name="queriedFor" datasource="#Application.uam_dbo#" timeout="60">
					#preservesinglequotes(thisSql)#
				 </cfquery>
				<cfcatch>
					<cfset result = querynew("container_id,msg")>
					<cfset temp = queryaddrow(result,1)>
					<cfset temp = QuerySetCell(result, "container_id", "-1", 1)>
					<cfset temp = QuerySetCell(result, "msg", "A query error occured: #cfcatch.Message# #cfcatch.Detail# -#thisSql#-", 1)>
					<cfreturn result>
				</cfcatch>
			 </cftry>
			
		 	<cfif #queriedFor.recordcount# is 0>
				<cfset result = querynew("container_id,msg")>
				<cfset temp = queryaddrow(result,1)>
				<cfset temp = QuerySetCell(result, "container_id", "-1", 1)>
				<cfset temp = QuerySetCell(result, "msg", "No records were found.", 1)>
				<cfreturn result>
	   		</cfif>
	   		<!---
	   		 does NOT work - removes rows that are IN container but don't CONTAIN container so
	   		 FREEZER 2
	   		 	MOUSE 1
	   		 	returns only FREEZER 2 when filter=FREEZER
	   		
	   		<cfif len(#in_container_type#) gt 0>
				<cfquery name="queriedFor" dbtype="query">
					select * from queriedFor where thepath like '%#in_container_type#%'
				</cfquery>
			</cfif>
	   		---->
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
				<cfset result = querynew("container_id,parent_container_id,label,container_type")>
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

<cffunction name="getContDetails" returntype="string">
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
			 	 <cfquery name="queriedFor" datasource="#Application.web_user#" timeout="60">
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
			 	 <cfquery name="queriedFor" datasource="#Application.web_user#" timeout="60">
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
		len(#contr_id#) is 0
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
			 	 <cfquery name="queriedFor" datasource="#Application.web_user#" timeout="60">
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
			
					<!---
					<cfset result = "#preservesinglequotes(thisSql)#">
					<cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
					<cfreturn result>
					<cfabort>
					--->

					
			 <cftry>
			 	 <cfquery name="queriedFor" datasource="#Application.web_user#" timeout="60">
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

<!-------------------------------------------------------------->

 
	 <!----
	 
	 <!----
	
	
	<cfargument name="cat_num" required="no" type="numeric">
	
	
	
	
	
	
	 
	 

	 ---->
	
	
	
 <cfif isdefined("collection_cde")>
 	<cfset whr = "#whr# AND cataloged_item.collection_cde='#collection_cde#'">
 </cfif>

 
 <cfif isdefined("Tissue_Type")>
 	<cfset whr = "#whr# AND Tissue_Type='#Tissue_Type#'">
 </cfif>
 <cfif isdefined("Part_Name")>
 	<cfset whr = "#whr# AND part_Name='#part_Name#'">
 </cfif>
 <cfif isdefined("Scientific_Name")>
 	<cfset frm = "#frm#,identification">
 	<cfset whr = "#whr# AND cataloged_item.collection_object_id = identification.collection_object_id
					AND identification.accepted_id_fg = 1 
					AND upper(Scientific_Name) like '%#ucase(Scientific_Name)#%'">
 </cfif>
 <cfif isdefined("container_label")>
 	<cfif isdefined("wildLbl") and #wildLbl# is 1>
			<cfset whr = "#whr# AND upper(label) LIKE '%#ucase(container_label)#%'">
		<cfelse>
			<cfset whr = "#whr# AND label = '#container_label#'">
	</cfif>
 
 </cfif>
 <cfif isdefined("description")>
 	<cfif isdefined("wildLbl") and #wildLbl# is 1>
			<cfset whr = "#whr# AND upper(description) LIKE '%#ucase(description)#%'">
		<cfelse>
			<cfset whr = "#whr# AND description='#description#'">
	</cfif>
	
	
 </cfif>
 <cfif isdefined("collection_object_id")>
 	<cfset whr = "#whr# AND cataloged_item.collection_object_id IN (#collection_object_id#)">
 </cfif>
 <cfif isdefined("barcode")>
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
 <cfif isdefined("container_type")>
 	<cfset whr = "#whr# AND container_type='#container_type#'">
 </cfif>
 <cfif isdefined("container_remarks")>
 <cfset whr = "#whr# AND container_remarks like '%#ucase(container_remarks)#%'">
 </cfif>
  <cfif isdefined("container_id")>
 	<cfset whr = "#whr# AND container.container_id=#container_id#">
 </cfif>
<cfif isdefined("loan_trans_id")>
 	<cfset frm = "#frm#,loan_item">
	<cfset whr = "#whr# AND loan_item.collection_object_id = specimen_part.collection_object_id	
		AND loan_item.transaction_id = #loan_trans_id#">
</cfif>
	
 <cfset sql = "#sel# #frm# #whr# ORDER BY label">
 <!----
 <cfoutput>
 #preservesinglequotes(sql)#
 </cfoutput>
 <cfflush>
 
 ---->
 <cfif #whr# is " WHERE ">
 	<!--- WAITING FOR SEARCH TERMS --->
	<cfabort>
 </cfif>
 <cfquery name="queriedFor" datasource="#Application.web_user#" timeout="60">
 	#preservesinglequotes(sql)#
 </cfquery>
</cfif>
---->