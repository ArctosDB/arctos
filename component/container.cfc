<cfcomponent><!------------------------------------------->
<cffunction name="getEnvironment" access="remote" returnFormat="plain">
	<cfargument name="container_id" type="any" required="yes">
	<cfargument name="exclagnt" type="any" required="no" default="">
	<cfargument name="pg" type="any" required="no" default="1">
	<cfargument name="feh_ptype" type="any" required="no" default="">
	<cftry>
		<!--- if there's nothing, stop now ---->
		<cfquery name="cepc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select count(*) c from container_environment
				where
			container_id=<cfqueryparam value="#container_id#" CFSQLType='CF_SQL_FLOAT'>
		</cfquery>
		<cfif cepc.c eq 0>
			<cfreturn "<p>No environmental history recorded.</p>">
		</cfif>
		<cfparam name="rowcount" default="10">
		<cfset startrow=(pg * rowcount)-rowcount>
		<cfset stoprow=startrow + rowcount>
		<cfset pagecnt=ceiling(cepc.c/rowcount)-1>

		<script>
			jQuery(document).ready(function() {
				$( "#feh" ).submit(function( event ) {
				  event.preventDefault();
				  getContainerHistory($("#feh_container_id").val(),$("#feh_exclagnt").val(),$("#pg").val(),$("#feh_ptype").val());
				});
			});
			function feh_nextPage(){
				$("#pg").val(parseInt($("#pg").val())+1);
				$( "#feh" ).submit();
			}
			function feh_prevPage(){
				$("#pg").val(parseInt($("#pg").val())-1);
				$( "#feh" ).submit();
			}
		</script>
		<cfoutput>
			<cfquery name="container_environment" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select * from (
					Select a.*, rownum rnum From (
						select
							container_environment_id,
							check_date,
							getPreferredAgentName(checked_by_agent_id) checkedby,
							parameter_type,
							parameter_value,
							remark
						from
							container_environment
						where
							container_id=<cfqueryparam value="#container_id#" CFSQLType='CF_SQL_FLOAT'>
							<cfif isdefined("exclagnt") and len(exclagnt) gt 0>
								and getPreferredAgentName(checked_by_agent_id) != <cfqueryparam value="#exclagnt#" CFSQLType='CF_SQL_VARCHAR'>
							</cfif>
							<cfif isdefined("feh_ptype") and len(feh_ptype) gt 0>
								and parameter_type = <cfqueryparam value="#feh_ptype#" CFSQLType='CF_SQL_VARCHAR'>
							</cfif>
						order by check_date DESC
					) a where rownum <= #stoprow#
				) where rnum >=<cfqueryparam value="#startrow#" CFSQLType='CF_SQL_FLOAT'>
			</cfquery>
			<cfsavecontent variable="result">
				<!--- if there's more than one "page" only, add some stuff ---->
				<cfif pagecnt gt 1>
					<cfquery name="ctcontainer_env_parameter" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						select parameter_type from ctcontainer_env_parameter order by parameter_type
					</cfquery>
					<p>
						Viewing page #pg# of #pagecnt#
						<cfif pg gt 1>
							<span class="likeLink" onclick="feh_prevPage()">previous page</span>
						</cfif>
						<cfif pg lt pagecnt>
							<span class="likeLink" onclick="feh_nextPage()">next page</span>
						</cfif>
						<form name="feh" id="feh">
							<input type="hidden" name="container_id" id="feh_container_id" value="#container_id#">
							<input type="hidden" name="pg" id="pg" value="#pg#">
							<label for="feh_exclagnt">Exclude Agent</label>
							<input type="text" name="feh_exclagnt" id="feh_exclagnt" value="#exclagnt#">
							<label for="feh_ptype">Parameter</label>
							<select name="feh_ptype" id="feh_ptype">
								<option></option>
								<cfloop query="ctcontainer_env_parameter">
									<option <cfif feh_ptype is parameter_type>selected="selected"</cfif>value="#parameter_type#">#parameter_type#</option>
								</cfloop>
							</select>
							<br>
							<input type="submit" value="filter">
						</form>
					</p>
				</cfif>
				<table border id="contrEnviroTbl">
					<tr>
						<th>Date</th>
						<th>CheckedBy</th>
						<th>Parameter</th>
						<th>Value</th>
						<th>Remark</th>
					</tr>
					<cfloop query="container_environment">
						<tr>
							<td>#check_date#</td>
							<td>#checkedby#</td>
							<td>#parameter_type#</td>
							<td>#parameter_value#</td>
							<td>#remark#</td>
						</tr>
					</cfloop>
				</table>
			</cfsavecontent>
		</cfoutput>
	<cfcatch>
		<cfset result='an error has occurred: #cfcatch.detail#'>
		<cfsavecontent variable="result">
		<cfdump var=#cfcatch#>
		</cfsavecontent>

	</cfcatch>
	</cftry>
	<cfreturn result>



</cffunction>
<!------------------------------------------->
<cffunction name="moveContainerLocation" access="remote">
	<cfargument name="barcode" type="string" required="yes">
	<cfargument name="parent_barcode" type="string" required="yes">
	<cfargument name="newdisp" type="string" required="yes">
	<cfargument name="olddisp" type="string" required="yes">
    <cfargument name="childContainerType" type="string" required="no">
    <cfargument name="parentContainerType" type="string" required="no">
	<cftry>
		<cfparam name = "msg" default = "">
		<cftransaction>
		<cfstoredproc
           datasource="user_login"
           username="#session.dbuser#"
           password="#decrypt(session.epw,session.sessionKey)#"
           procedure="moveContainerByBarcode">
             <cfprocparam cfsqltype="cf_sql_varchar" value="#barcode#">
             <cfprocparam cfsqltype="cf_sql_varchar" value="#parent_barcode#">
             <cfprocparam cfsqltype="cf_sql_varchar" value="#childContainerType#">
             <cfprocparam cfsqltype="cf_sql_varchar" value="#parentContainerType#">
         </cfstoredproc>

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
						container partcontainer,
						container partholder
					where
						specimen_part.derived_from_cat_item=flat.collection_object_id and
						specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
						specimen_part.collection_object_id=coll_object.collection_object_id and
						coll_obj_cont_hist.container_id=partcontainer.container_id and
						partcontainer.parent_container_id=partholder.container_id and
						partholder.barcode='#barcode#'
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
		<cfset result = "success|#barcode# moved to #parent_barcode#">
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
	<cfset in_barcode="">

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
		len(in_barcode) is 0 and
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
		<cfset whr = "#whr# AND cataloged_item.cat_num IN (#listqualify(cat_num,"#chr(39)#")#)">
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
	<cfif len(in_container_type) gt 0>
		<cfset whr = "#whr# AND container.parent_container_id IN (select container_id from container where container_type='#in_container_type#')">
	</cfif>
	<cfif len(in_barcode) gt 0>
		<cfset whr = "#whr# AND container.parent_container_id IN (select container_id from container where barcode IN  ( #ListQualify(in_barcode,'''')# ) " >
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
					getLastContainerEnvironment(CONTAINER_ID) lastenv,
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
						id,
						lastenv
					 from queriedFor
					group by
						CONTAINER_ID,
						PARENT_CONTAINER_ID,
						CONTAINER_TYPE,
						DESCRIPTION,
						PARENT_INSTALL_DATE,
						CONTAINER_REMARKS,
						label,
						id,
						lastenv
						order by id desc
				 </cfquery>
	 			<cfset alreadyGotOne = "-1">
				<cfset i=1>
				<cfset result = querynew("CONTAINER_ID,PARENT_CONTAINER_ID,LABEL,CONTAINER_TYPE,LASTENV")>
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
						<cfset temp = QuerySetCell(result, "lastenv", "#ro.lastenv#", #i#)>
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
</cfcomponent>