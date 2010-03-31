<!--- hint="type=keyvalue, jsreturn=array , listdelimiter=| , delimiter='='" --->
<cfinclude template="/ajax/core/cfajax.cfm">
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
<!------------------------------------->
<cffunction name="upDispn" returntype="string" access="public">
<cfargument name="collection_object_id" type="numeric" required="yes">
<cfargument name="disposition" type="string" required="yes">

<cftry>
	
	<cftransaction>
		<cfquery name="nr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			update coll_object set  COLL_OBJ_DISPOSITION = '#disposition#'
			where collection_object_id = #collection_object_id#
		</cfquery>
		<cfset result = "success">
	</cftransaction>
<cfcatch>
	<cfset result = "A database error occured: #cfcatch.message#.">
</cfcatch>
</cftry>upDispn
	  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>
<!-------------------------------------------------------------------------->
<cffunction name="upRemarks" returntype="string" access="public">
<cfargument name="collection_object_id" type="numeric" required="yes">
<cfargument name="remark" type="string" required="yes">
<cfset remark = replace(remark,"##","####","all")>
<cftry>
	
	<cftransaction>
		<cfquery name="isThere" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select count(*) cnt from coll_object_remark
			where collection_object_id = #collection_object_id#
		</cfquery>
		<cfif #isThere.cnt# is 0>
			<cfquery name="nr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into coll_object_remark (
					collection_object_id, coll_object_remarks)
					values (#collection_object_id#,'#remark#')
			</cfquery>
		<cfelse>
			<cfquery name="nr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				update coll_object_remark 
				set coll_object_remarks = '#remark#'
				where collection_object_id = #collection_object_id#
			</cfquery>
		</cfif>
		<cfset result = "success">
	</cftransaction>
<cfcatch>
	<cfset result = "A database error occured: #cfcatch.message#.">
</cfcatch>
</cftry>upDispn
	  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>
<!-------------------------------------------------------------------------->
<cffunction name="saveNewAtt" returntype="string" access="public">
<cfargument name="collection_object_id" type="numeric" required="yes">

<cfargument name="attribute_type" type="string" required="yes">
<cfargument name="attribute_value" type="string" required="yes">

<cfargument name="attribute_units" type="string" required="yes">
<cfargument name="attribute_date" type="string" required="yes">
<cfargument name="attribute_determiner" type="string" required="yes">
<cfargument name="attribute_determiner_id" type="string" required="yes">
<cfargument name="attribute_det_meth" type="string" required="yes">
<cfargument name="attribute_remarks" type="string" required="yes">



<cftry>
	<cftransaction>
		<cfquery name="nid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select sq_attribute_id.nextval nid from dual
		</cfquery>
		
		<cfquery name="newID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			insert into attributes (
				ATTRIBUTE_ID,
				COLLECTION_OBJECT_ID,
				DETERMINED_BY_AGENT_ID,
				ATTRIBUTE_TYPE,
				ATTRIBUTE_VALUE
				<cfif len(#attribute_units#) gt 0>
					,ATTRIBUTE_UNITS
				</cfif>
				<cfif len(#attribute_remarks#) gt 0>
					,ATTRIBUTE_REMARK
				</cfif>
				<cfif len(#attribute_date#) gt 0>
					,DETERMINED_DATE
				</cfif>
				<cfif len(#attribute_det_meth#) gt 0>
					,DETERMINATION_METHOD
				</cfif>
			) values (
				#nid.nid#,
				#COLLECTION_OBJECT_ID#,
				#attribute_determiner_id#,
				'#attribute_type#',
				'#attribute_value#'
				<cfif len(#attribute_units#) gt 0>
					,'#attribute_units#'
				</cfif>
				<cfif len(#attribute_remarks#) gt 0>
					,'#attribute_remarks#'
				</cfif>
				<cfif len(#attribute_date#) gt 0>
					,'#dateformat(attribute_date,"dd-mmm-yyyy")#'
				</cfif>
				<cfif len(#attribute_det_meth#) gt 0>
					,'#attribute_det_meth#'
				</cfif>
				)			
		</cfquery>
		
		  <cfset result = "#nid.nid#|#attribute_determiner#|#attribute_determiner_id#|#attribute_type#|#attribute_value#|#attribute_units#|#attribute_remarks#|#attribute_date#|#attribute_det_meth#">
	</cftransaction>
<cfcatch>
	<cfset result = "-1|A database error occured: #cfcatch.message#.">
</cfcatch>
</cftry>


	  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>
<!-------------------------------------------------------------------------->

<cffunction name="saveNewId" returntype="string" access="public">
<cfargument name="collection_object_id" type="numeric" required="yes">
<cfargument name="taxon_id" type="numeric" required="yes">
<cfargument name="identifier_id" type="numeric" required="yes">
<cfargument name="id_date" type="string" required="yes">
<cfargument name="nature" type="string" required="yes">
<cfargument name="remark" type="string" required="yes">
<cfargument name="sciname" type="string" required="yes">
<cfargument name="identifier" type="string" required="yes">

<cftry>
	<cftransaction>
		<cfquery name="oldID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			update identification set ACCEPTED_ID_FG = 0 where 
			COLLECTION_OBJECT_ID = #collection_object_id#
		</cfquery>
		<cfquery name="newID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			insert into identification (
				IDENTIFICATION_ID,
				COLLECTION_OBJECT_ID,
				ID_MADE_BY_AGENT_ID,
				MADE_DATE,
				NATURE_OF_ID,
				ACCEPTED_ID_FG,
				TAXA_FORMULA,
				SCIENTIFIC_NAME
				<cfif len(#remark#) gt 0>
					,IDENTIFICATION_REMARKS
				</cfif>
				) values (
				sq_identification_id.nextval,
				#collection_object_id#,
				#identifier_id#,
				'#dateformat(id_date,"dd-mmm-yyyy")#',
				'#nature#',
				1,
				'A',
				'#sciname#'
				<cfif len(#remark#) gt 0>
					,'#remark#'
				</cfif>)				
		</cfquery>
		<cfquery name="idtax" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			insert into identification_taxonomy (
				IDENTIFICATION_ID,
				TAXON_NAME_ID,
				VARIABLE) values (
				sq_identification_id.currval,
				#taxon_id#,
				'A')
		</cfquery>
		<cfquery name="identification_agent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			insert into identification_agent (
				IDENTIFICATION_ID,
				AGENT_ID,
				IDENTIFIER_ORDER
			) values (
				sq_identification_id.currval,
				#identifier_id#,
				1
			)
		</cfquery>
		<cfset result = "#taxon_id#|#id_date#|#nature#|#remark#|#sciname#|#identifier#">
	</cftransaction>
<cfcatch>
	<cfset result = "-1|A database error occured: #cfcatch.message#.">
</cfcatch>
</cftry>



	  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>
<!-------------------------------------------------------------------------->
<cffunction name="newpart" returntype="string" access="public">

<cfargument name="collection_object_id" type="numeric" required="yes">

<cfargument name="part_name" type="string" required="yes">
<cfargument name="part_disposition" type="string" required="yes">
<cfargument name="part_condition" type="string" required="yes">
<cfargument name="part_count" type="string" required="yes">
<cfargument name="label" type="string" required="yes">
<cfargument name="print_fg" type="string" required="yes">
<cfargument name="part_remark" type="string" required="yes">

<cfset result = "">
<cfquery name= "getEntBy" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT distinct(agent_id) FROM agent_name WHERE agent_name = '#session.username#' 
</cfquery>

<cfif getEntBy.recordcount neq 1>
	<cfset result = "-1|Your login name has issues.">
</cfif>

<cfif len(#label#) gt 0>
	<cfquery name="nParent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select container_id,label,barcode from container where barcode='#label#'
	</cfquery>
	<cfif #nParent.recordcount# is 1 and #nParent.container_id# gt 0>
		<cfset parent_container_id = #nParent.container_id#>
		<cfset pb_label = #nParent.label#>
		<cfset pb_barcode = #nParent.barcode#>
	<cfelse>	
		<cfset result = "-1|The parent container did not exist.">
	</cfif>
<cfelse>
	<cfset parent_container_id=0>
	<cfset thisPrintFlag=0>
	<cfset pb_label = "">
	<cfset pb_barcode = "">
</cfif>	

<cfif len(#print_fg#) gt 0>
	<cfif len(#label#) is 0>
		<cfset result = "-1|You cannot specify a print flag and not a parent container.">
	<cfelse>
		<cfset thisPrintFlag=#print_fg#>
	</cfif>
<cfelse>
	<cfset thisPrintFlag=0>
</cfif>


<cfset enteredbyid = getEntBy.agent_id>
<cfset thisDate = dateformat(now(),"dd-mmm-yyyy")>

<cfif len(#result#) is 0>
<cftry>		
<cftransaction>
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
			sq_collection_object_id.nextval,
			'SP',
			#enteredbyid#,
			'#thisDate#',
			#enteredbyid#,
			'#part_disposition#',
			#part_count#,
			'#part_condition#',
			0 )
	</cfquery>
	<cfquery name="newPart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		INSERT INTO specimen_part (
			  COLLECTION_OBJECT_ID,
			  PART_NAME
				,DERIVED_FROM_cat_item )
			VALUES (
				sq_collection_object_id.currval,
			  '#PART_NAME#'
				,#collection_object_id# )
		</cfquery>
			
			<cfif len(#part_remark#) gt 0>
				<!---- new remark --->
				<cfquery name="newCollRem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					INSERT INTO coll_object_remark (collection_object_id, coll_object_remarks)
					VALUES (sq_collection_object_id.currval, '#part_remark#')
				</cfquery>
			</cfif>
			<cfif #thisPrintFlag# gt 0>
				<cfquery name="pfg" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					update container set print_fg=#thisPrintFlag#
					where container_id = #parent_container_id#
				</cfquery>
			</cfif>
	</cftransaction>
	<cfset result = "1|#PART_NAME#|#part_disposition#|#part_condition#|#part_count#|#pb_label#|#pb_barcode#|#print_fg#|#part_remark#">
	<cfcatch>
		<cfset result = '-1|A database error occurred! #cfcatch.Detail#'>
	</cfcatch>
</cftry>	
</cfif>			
		
	
				
	  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>
<!-------------------------------------------------------------------------->
<cffunction name="delPart" returntype="string" access="public">
<cfargument name="partID" type="numeric" required="yes">
<cfargument name="i" type="numeric" required="yes">
<cfset result = "#i#">
<cftry>
	<cftransaction>
		<cfquery name="delePart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			DELETE FROM specimen_part WHERE collection_object_id = #partID#
		</cfquery>
		<cfquery name="delePartCollObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			DELETE FROM coll_object WHERE collection_object_id = #partID#
		</cfquery>
		<cfquery name="delePartRemark" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			DELETE FROM coll_object_remark WHERE collection_object_id = #partID#
		</cfquery>
		<cfquery name="getContID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select container_id from coll_obj_cont_hist where
			collection_object_id = #partID#
		</cfquery>
		
		<cfquery name="deleCollCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			DELETE FROM coll_obj_cont_hist WHERE collection_object_id = #partID#
		</cfquery>
		<cfquery name="deleCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			DELETE FROM container_history WHERE container_id = #getContID.container_id#
		</cfquery>
		<cfquery name="deleCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			DELETE FROM container WHERE container_id = #getContID.container_id#
		</cfquery>
	</cftransaction>
	<cfcatch>
			<cfreturn 'A database error occured! #cfcatch.msg# #cfcatch.detail#'>
	</cfcatch>
</cftry>	

<cfreturn 'nocatch'>
			
	  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>
<!-------------------------------------------------------------------------->
<cffunction name="upPartLabel" returntype="string" access="public">
<cfargument name="partID" type="numeric" required="yes">
<cfargument name="i" type="numeric" required="yes">
<cfargument name="barcode" type="string" required="yes">


			<cftry>
				<!---- make sure it is valid ---->
				<cfquery name="isCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					SELECT
						container_id, container_type, parent_container_id,label
					FROM
						container
					WHERE
						barcode = '#barcode#'
						AND container_type <> 'collection object'
				</cfquery>
				<cfif #isCont.recordcount# is 1>
					<!--- they are using an existing unique container--->
					<cfif #isCont.container_type# is 'cryovial label'>
						update container set container_type='cryovial'
						where container_id = #isCont.container_id#
					</cfif>
					<cfquery name="thisCollCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						SELECT 
							container_id 
						FROM 
							coll_obj_cont_hist 
						WHERE 
							collection_object_id = #partID#
					</cfquery>
					<cfquery name="upPartBC" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						UPDATE 
							container
						SET
							parent_install_date = '#dateformat(now(),"dd-mmm-yyyy")#',
							parent_container_id = #isCont.container_id#
						WHERE
							container_id = #thisCollCont.container_id#
					</cfquery>
					<cfset result = "#i#|#isCont.label#|#barcode#">
				<cfelse>
					<cfset result = "Container not found.">
				</cfif>
				<cfcatch>
					<cfset result = 'A database error occured!'>
				</cfcatch>
			</cftry>	
	  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>
<!-------------------------------------------------------------------------->
<cffunction name="upPrintFg" returntype="string">
<cfargument name="partID" type="numeric" required="yes">
<cfargument name="i" type="numeric" required="yes">
<cfargument name="print_fg" type="string" required="yes">
<cfargument name="barcode" type="string" required="yes">

<cfset result = "#i#">
			<cftry>
				<!---- make sure it is valid ---->
				<cfquery name="isCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					SELECT
						container_id, container_type, parent_container_id
					FROM
						container
					WHERE
						barcode = '#barcode#'
						AND container_type <> 'collection object'
				</cfquery>
				<cfif #isCont.recordcount# is 1>
					<!--- they are using an existing unique container--->
					<cfquery name="thisCollCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						SELECT 
							container_id 
						FROM 
							coll_obj_cont_hist 
						WHERE 
							collection_object_id = #partID#
					</cfquery>
					<!--- update the label print flag --->
						<cfif len(#print_fg#) gt 0>
							<cfquery name="upPartPLF" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
								UPDATE container SET print_fg = #print_fg# WHERE
								container_id = #isCont.container_id#
							</cfquery>
						<cfelse>
							<cfquery name="upPartPLF" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
								UPDATE container SET print_fg = NULL WHERE
								container_id = #isCont.container_id#
							</cfquery>
						</cfif>
						
				<cfelse>
					<cfset result = "Container not found.">
				</cfif>
				<cfcatch>
					<cfset result = 'A database error occured!'>
				</cfcatch>
			</cftry>	
	  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------>
<cffunction name="upPartRemk" returntype="string">
<cfargument name="partID" type="numeric" required="yes">
<cfargument name="i" type="numeric" required="yes">
<cfargument name="remark" type="string" required="yes">
<cfset result = "#i#">
			<cftry>
				<!--- is there already remark? --->
				<cfquery name="t" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select count(*) as cnt from coll_object_remark
					where  collection_object_id = #partID#
				</cfquery>
				<cfif t.cnt is 0>
					<cfquery name="upid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						insert into coll_object_remark (
						collection_object_id,
						coll_object_remarks)
						values (
						#partID#,
						'#remark#')
					</cfquery>
				<cfelse>
					<cfquery name="upid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						update coll_object_remark set coll_object_remarks='#remark#'
						where collection_object_id = #partID#
					</cfquery>
				</cfif>
				
				<cfcatch>
					<cfset result = 'A database error occured!'>
				</cfcatch>
			</cftry>	
	  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------>
<cffunction name="upPartCount" returntype="string">
<cfargument name="partID" type="numeric" required="yes">
<cfargument name="i" type="numeric" required="yes">
<cfargument name="part_count" type="string" required="yes">
<cfset result = "#i#">
			<cftry>
				<cfquery name="upid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					update coll_object set lot_count=#part_count#
					where collection_object_id = #partID#
				</cfquery>
				<cfcatch>
					<cfset result = 'A database error occured!'>
				</cfcatch>
			</cftry>	
	  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------>
<cffunction name="upPartCond" returntype="string">
<cfargument name="partID" type="numeric" required="yes">
<cfargument name="i" type="numeric" required="yes">
<cfargument name="part_condition" type="string" required="yes">
<cfset result = "#i#">
			<cftry>
				<cfquery name="upid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					update coll_object set CONDITION='#part_condition#'
					where collection_object_id = #partID#
				</cfquery>
				<cfcatch>
					<cfset result = 'A database error occured!'>
				</cfcatch>
			</cftry>	
	  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------>

<cffunction name="upPartDisp" returntype="string">
<cfargument name="partID" type="numeric" required="yes">
<cfargument name="i" type="numeric" required="yes">
<cfargument name="part_disp" type="string" required="yes">
<cfset result = "#i#">
			<cftry>
				<cfquery name="upid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					update coll_object set COLL_OBJ_DISPOSITION='#part_disp#'
					where collection_object_id = #partID#
				</cfquery>
				<cfcatch>
					<cfset result = 'A database error occured!'>
				</cfcatch>
			</cftry>	
	  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------>
<cffunction name="upPartName" returntype="string">
<cfargument name="partID" type="numeric" required="yes">
<cfargument name="i" type="numeric" required="yes">
<cfargument name="part_name" type="string" required="yes">
<cfset result = "#i#">
			<cftry>
				<cfquery name="upid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					update specimen_part set part_name='#part_name#'
					where collection_object_id = #partID#
				</cfquery>
				<cfcatch>
					<cfset result = 'A database error occured!'>
				</cfcatch>
			</cftry>	
	  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------>
<cffunction name="delAtt" returntype="string">
<cfargument name="attribute_id" type="numeric" required="yes">
<cfargument name="i" type="numeric" required="yes">
	  	
			<cftry>
				<cfquery name="upatt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					delete from attributes 
					where attribute_id = #attribute_id#		 
				</cfquery>
				<cfset result = '#i#'>
			<cfcatch>
				<cfset result = 'A database error occured!'>
			</cfcatch>
			</cftry>			
	  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>
<!----------------------------------------------------------------------------------------->
<cffunction name="changeAttDetrId" returntype="string">
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
<cffunction name="changeAttDetMeth" returntype="string">
<cfargument name="attribute_id" type="numeric" required="yes">
<cfargument name="i" type="numeric" required="yes">
<cfargument name="attribute_detmeth" type="string" required="yes">
<cfset result = "#i#">
			<cftry>
				<cfset sql = "update attributes set DETERMINATION_METHOD = ">
				 <cfif len(#attribute_detmeth#) gt 0>
					 <cfset sql = "#sql# '#attribute_detmeth#'">
				<cfelse>
					 <cfset sql = "#sql# NULL">
				</cfif>
				<cfset sql = "#sql# where attribute_id = #attribute_id#	">
				<cfquery name="upid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					#preservesinglequotes(sql)#				 
				</cfquery>
				<cfcatch>
					<cfset result = 'A database error occured!'>
				</cfcatch>
			</cftry>	
	  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------>
<cffunction name="changeAttDate" returntype="string">
<cfargument name="attribute_id" type="numeric" required="yes">
<cfargument name="i" type="numeric" required="yes">
<cfargument name="attribute_date" type="string" required="yes">
<cfset result = "#i#">
			<cftry>
				<cfset sql = "update attributes set DETERMINED_DATE = ">
				 <cfif len(#attribute_date#) gt 0>
					 <cfset sql = "#sql# '#attribute_date#'">
				<cfelse>
					 <cfset sql = "#sql# NULL">
				</cfif>
				<cfset sql = "#sql# where attribute_id = #attribute_id#	">
				<cfquery name="upid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					#preservesinglequotes(sql)#				 
				</cfquery>
				<cfcatch>
					<cfset result = 'A database error occured!'>
				</cfcatch>
			</cftry>	
	  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------>
<cffunction name="changeAttRemk" returntype="string">
<cfargument name="attribute_id" type="numeric" required="yes">
<cfargument name="i" type="numeric" required="yes">
<cfargument name="attribute_remark" type="string" required="yes">
<cfset result = "#i#">
			<cftry>
				<cfset sql = "update attributes set attribute_remark = ">
				 <cfif len(#attribute_remark#) gt 0>
					 <cfset sql = "#sql# '#attribute_remark#'">
				<cfelse>
					 <cfset sql = "#sql# NULL">
				</cfif>
				<cfset sql = "#sql# where attribute_id = #attribute_id#	">
				<cfquery name="upid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					#preservesinglequotes(sql)#				 
				</cfquery>
				<cfcatch>
					<cfset result = 'A database error occured!'>
				</cfcatch>
			</cftry>	
	  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------>
<cffunction name="changeAttUnit" returntype="string">
<cfargument name="attribute_id" type="numeric" required="yes">
<cfargument name="i" type="numeric" required="yes">
<cfargument name="attribute_units" type="string" required="yes">
<cfset result = "#i#">
			<cftry>
				<cfquery name="upid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					update attributes set attribute_units
					 = '#attribute_units#'
					 where
					 attribute_id = #attribute_id#
				</cfquery>
				<cfcatch>
					<cfset result = 'A database error occured!'>
				</cfcatch>
			</cftry>			
	  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------>
<cffunction name="changeAttValue" returntype="string">
<cfargument name="attribute_id" type="numeric" required="yes">
<cfargument name="i" type="numeric" required="yes">
<cfargument name="attribute_value" type="string" required="yes">
<cfset result = "#i#">
			<cftry>
				<cfquery name="upid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					update attributes set attribute_value
					 = '#attribute_value#'
					 where
					 attribute_id = #attribute_id#
				</cfquery>
				<cfcatch>
					<cfset result = 'A database error occured!'>
				</cfcatch>
			</cftry>			
	  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------>
<cffunction name="updateidremk" returntype="string">
<cfargument name="collection_object_id" type="numeric" required="yes">
<cfargument name="remk" type="string" required="yes">
<cfset result = "success">
	
			<cftry>
				<cfquery name="upid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					update identification set IDENTIFICATION_REMARKS
					 = 
					 <cfif len(#remk#) gt 0>
					 	'#remk#'
					 <cfelse>
					 	NULL
					 </cfif>
					 where
					 accepted_id_fg=1 and
					 collection_object_id = #collection_object_id#
				</cfquery>
				<cfcatch>
					<cfset result = 'A database error occured! ID Remark has not been saved.'>
				</cfcatch>
			</cftry>			
	  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------>
<cffunction name="updateNature" returntype="string">
<cfargument name="collection_object_id" type="numeric" required="yes">
<cfargument name="noid" type="string" required="yes">
<cfset result = "success">
	
			<cftry>
				<cfquery name="upid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					update identification set nature_of_id
					 = '#noid#'
					 where
					 accepted_id_fg=1 and
					 collection_object_id = #collection_object_id#
				</cfquery>
				<cfcatch>
					<cfset result = 'A database error occured! Nature of ID has not been saved.'>
				</cfcatch>
			</cftry>			
	  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------>
<cffunction name="updateimade_date" returntype="string">
<cfargument name="collection_object_id" type="numeric" required="yes">
<cfargument name="mdate" type="string" required="yes">
<cfset result = "success">
	
			<cftry>
				<cfquery name="upid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					update identification set made_date
					 = '#mdate#'
					 where
					 accepted_id_fg=1 and
					 collection_object_id = #collection_object_id#
				</cfquery>
				<cfcatch>
					<cfset result = 'A database error occured! ID Date has not been saved.'>
				</cfcatch>
			</cftry>			
	  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------>
<cffunction name="updateid_by_id" returntype="string">
<cfargument name="collection_object_id" type="numeric" required="yes">
<cfargument name="agent_id" type="numeric" required="yes">
<cfset result = "success">
		<cfquery name="names" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select agent_name,agent_id
			from preferred_agent_name
			where agent_id = #agent_id#
		</cfquery>
		<cfquery name="idid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select identification_id
			from identification
			where collection_object_id = #collection_object_id#
			and accepted_id_fg=1
		</cfquery>
		<cfif #names.recordcount# is 0>
			<cfset result = "Nothing matched.">
		<cfelseif #names.recordcount# is 1>
			<cftry>
				<cfquery name="upid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					update identification_agent set AGENT_ID
					 = #names.agent_id#
					 where
					 identification_id=#idid.identification_id#
					 and IDENTIFIER_ORDER in (
					 	select min(IDENTIFIER_ORDER) from identification_agent
						where identification_id=#idid.identification_id#)
				</cfquery>
				<cfset result = "#names.agent_name#">
				<cfcatch>
					<cfset result = 'A database error occured! Identifier has not been saved.'>
				</cfcatch>
			</cftry>			
		<cfelse>
			<cfset result = "">
			<cfloop query="names">
				<cfset result = "#result#|#agent_name#">
			</cfloop>
		</cfif>
	  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>
<!------------------------------------------------->
<cffunction name="updateid_by" returntype="string">
<cfargument name="collection_object_id" type="numeric" required="yes">
<cfargument name="name" type="string" required="yes">
<cfset result = "success">
	<cfquery name="names" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select agent_name,agent_id
			from preferred_agent_name
			where upper(agent_name) like '%#ucase(name)#%'
		</cfquery>
		<cfquery name="idid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select identification_id
			from identification
			where collection_object_id = #collection_object_id#
			and accepted_id_fg=1
		</cfquery>
		<cfif #names.recordcount# is 0>
			<cfset result = "Nothing matched.">
		<cfelseif #names.recordcount# is 1>
			<cftry>
				<cfquery name="upid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					update identification_agent set AGENT_ID
					 = #names.agent_id#
					 where
					 identification_id=#idid.identification_id#
					 and IDENTIFIER_ORDER in (
					 	select min(IDENTIFIER_ORDER) from identification_agent
						where identification_id=#idid.identification_id#)
				</cfquery>
				<cfset result = "#names.agent_name#">
				<cfcatch>
					<cfset result = 'A database error occured! Identifier has not been saved. #cfcatch.Detail#'>
				</cfcatch>
			</cftry>			
		<cfelse>
			<cfset result = "">
			<cfloop query="names">
				<cfset result = "#result#|#agent_name#">
			</cfloop>
		</cfif>
	  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------>
<cffunction name="updateSciName" returntype="string">
<cfargument name="collection_object_id" type="numeric" required="yes">
<cfargument name="sciname" type="string" required="yes">
	<cfset result = "success">
	
		<cfquery name="isThere" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select taxon_name_id from taxonomy
			where scientific_name = '#sciname#'
		</cfquery>
		<cfif #isThere.recordcount# is 1 and len(#isThere.taxon_name_id#) gt 0>
			<cftry>
					<cfquery name="idid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						select identification_id,taxa_formula from identification where
						collection_object_id = #collection_object_id#
						and accepted_id_fg = 1		
					</cfquery>
					<cfif #idid.taxa_formula# contains 'B'>
						<cfset result = "You cannot update this scientific name. Add an identification.">
					<cfelse>
						<cfquery name="idt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							update identification_taxonomy set
							taxon_name_id = #isThere.taxon_name_id#
							where identification_id = #idid.identification_id#
						</cfquery>
					
						<cfquery name="o" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							update identification set scientific_name = '#sciname#',
							taxa_formula='A'
							where identification_id = #idid.identification_id#		
						</cfquery>
					</cfif>
					
				<cfcatch>
					<cfset result = "An unknown error occured.">
				</cfcatch>
			</cftry>
		<cfelse>
			<cfset result = "An error occured. There are #isThere.recordcount# matching names in Taxonomy.">
		</cfif>
	<!----
	
				
				
			
	---->
	  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>


<cffunction name="getAttCodeTbl" returntype="query">
	<cfargument name="attribute" type="string" required="yes">
	<cfargument name="collection_cde" type="string" required="yes">
	<cfargument name="element" type="string" required="yes">
	<cfquery name="isCtControlled" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select VALUE_CODE_TABLE,UNITS_CODE_TABLE from ctattribute_code_tables where attribute_type='#attribute#'
	</cfquery>
	<cfif #isCtControlled.recordcount# is 1>
		<!--- there's something --->
		<cfif len(#isCtControlled.VALUE_CODE_TABLE#) gt 0>
			<!--- values code table --->
			<cfquery name="getCols" datasource="uam_god">
				select column_name from sys.user_tab_columns where table_name='#ucase(isCtControlled.value_code_table)#'
				and column_name <> 'DESCRIPTION'
			</cfquery>
			<cfquery name="valCT" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select * from #isCtControlled.value_code_table#
			</cfquery>
			<cfset collCode = "">
			<cfset columnName = "">
			<cfloop query="getCols">
					<cfif getCols.column_name is "COLLECTION_CDE">
						<cfset collCode = "yes">
					  <cfelse>
						<cfset columnName = "#getCols.column_name#">
					</cfif>
			</cfloop>
			<cfif len(#collCode#) gt 0>
				<cfquery name="valCodes" dbtype="query">
					SELECT #getCols.column_name# as valCodes from valCT
					WHERE collection_cde='#collection_cde#'
				</cfquery>
			  <cfelse>
				<cfquery name="valCodes" dbtype="query">
					SELECT #getCols.column_name# as valCodes from valCT
				</cfquery>
			</cfif>
			<!---- should have valid names in valCodes, now put them in a query --->
			<cfset result = QueryNew("v")>
			<cfset newRow = QueryAddRow(result, 1)>
			<cfset temp = QuerySetCell(result, "v", "value",1)>
			<cfset newRow = QueryAddRow(result, 1)>
			<cfset temp = QuerySetCell(result, "v", "#element#",2)>
			<!--- put the valid values in the query --->
			<cfset i=3>
			<cfloop query="valCodes">
				<cfset newRow = QueryAddRow(result, 1)>
				<cfset temp = QuerySetCell(result, "v", "#valCodes#",#i#)>
				<cfset i=#i#+1>
			</cfloop>
			
		<cfelseif #isCtControlled.UNITS_CODE_TABLE# gt 0>
			<cfquery name="getCols" datasource="uam_god">
				select column_name from sys.user_tab_columns where table_name='#ucase(isCtControlled.UNITS_CODE_TABLE)#'
				and column_name <> 'DESCRIPTION'
			</cfquery>
			<cfquery name="valCT" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select * from #isCtControlled.UNITS_CODE_TABLE#
			</cfquery>
			<cfset collCode = "">
			<cfset columnName = "">
			<cfloop query="getCols">
					<cfif getCols.column_name is "COLLECTION_CDE">
						<cfset collCode = "yes">
					  <cfelse>
						<cfset columnName = "#getCols.column_name#">
					</cfif>
			</cfloop>
			<cfif len(#collCode#) gt 0>
				<cfquery name="valCodes" dbtype="query">
					SELECT #getCols.column_name# as valCodes from valCT
					WHERE collection_cde='#collection_cde#'
				</cfquery>
			  <cfelse>
				<cfquery name="valCodes" dbtype="query">
					SELECT #getCols.column_name# as valCodes from valCT
				</cfquery>
			</cfif>
			
			
			
			<cfset result = "unit - #isCtControlled.UNITS_CODE_TABLE#">
			<cfset result = QueryNew("v")>
			<cfset newRow = QueryAddRow(result, 1)>
			<cfset temp = QuerySetCell(result, "v", "units")>
			<cfset newRow = QueryAddRow(result, 1)>
			<cfset temp = QuerySetCell(result, "v", "#element#",2)>
			<cfset i=3>
			<cfloop query="valCodes">
				<cfset newRow = QueryAddRow(result, 1)>
				<cfset temp = QuerySetCell(result, "v", "#valCodes#",#i#)>
				<cfset i=#i#+1>
			</cfloop>
		<cfelse>
			<cfset result = QueryNew("v")>
			<cfset newRow = QueryAddRow(result, 1)>
			<cfset temp = QuerySetCell(result, "v", "ERROR")>
			<cfset newRow = QueryAddRow(result, 1)>
			<cfset temp = QuerySetCell(result, "v", "#element#",2)>
		</cfif>
	<cfelse>
			<cfset result = QueryNew("v")>
			<cfset newRow = QueryAddRow(result, 1)>
			<cfset temp = QuerySetCell(result, "v", "NONE")>
			<cfset newRow = QueryAddRow(result, 1)>
			<cfset temp = QuerySetCell(result, "v", "#element#",2)>
	</cfif>
	<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------->
<cffunction name="testArray" returntype="string">
<cfargument name="COLLECTION_OBJECT_ID" type="array" required="yes">
	<cfset result = #COLLECTION_OBJECT_ID#>
	
	<cferror template="/e.cfm" type="exception">
	
		<!---
		<cfargument name="theArray" type="struct" required="yes">
		<cfset result = "some result">
		<cfargument name="theArray" required="false" type="struct"/>
	
		<cftry><cfset result = theArray.aryEntries.collection_object_id>
	<cfset result = theArray.collection_object_id[1]>
		<cfcatch>
			
		</cfcatch>
	</cftry>
	
	--->
		<cfreturn result>
</cffunction>

<!----------------------->
<cffunction name="getcatNumSeq" returntype="string">
	<cfargument name="coll" type="string" required="yes">
	<cfset theSpace = find(" " ,coll)>
	<cfset inst = trim(left(coll,theSpace))>
	<cfset collcde = trim(mid(coll,theSpace,len(coll)))>
	
	
	<cfquery name="collID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select collection_id from collection where
		institution_acronym='#inst#' and
		collection_cde='#collcde#'
	</cfquery>
	<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select max(cat_num + 1) as nextnum
		from cataloged_item 
		where 
		collection_id=#collID.collection_id# 
	</cfquery>
	<cfquery name="b" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select max(to_number(cat_num) + 1) as nextnum from bulkloader
		where
		institution_acronym='#inst#' and
		collection_cde='#collcde#'
	</cfquery>
	<cfif #q.nextnum# gt #b.nextnum#>
		<cfset result = "#q.nextnum#">
	<cfelse>
		<cfset result = "#b.nextnum#">
	</cfif>
	
	<!---<cfset result = "#coll#=#inst#-#collcde#">
	--->
	
	<cfreturn result>
</cffunction>
<!----------------------->
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
	<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select min(cat_num + 1) as missingnum
		from cataloged_item t1
		where 
		collection_id=#collID.collection_id# and
		not exists (
		select cat_num
		from cataloged_item t2
		where t2.cat_num = t1.cat_num + 1
		and collection_id=#collID.collection_id#
		)
		and (cat_num + 1) not in (select decode(cat_num,null,999999999,to_number(cat_num)) as cat_num from bulkloader)
	</cfquery>
		
	<!---
		<cfif #q.recordcount# is 1>
			<cfset result = #q.missingmnum#>
		<cfelse>
			<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select max(cat_num) + 1 as nextnum from cataloged_item where
				collection_id=#coll_id#
			</cfquery>
			<cfset result = #q.nextnum#>
		</cfif>
		----->
		<cfif #q.recordcount# is 1>
			<cfset result = "#q.missingnum#">
		<cfelse>
			<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select max(cat_num) + 1 as nextnum from cataloged_item where
				collection_id=#coll_id#
			</cfquery>
			<cfset result = #q.nextnum#>
		</cfif>
		
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
			dgr_locator_seq.nextval,
			#freezer#,
			#rack#,
			#box#,
			#place#,
			#nk#,
			'#tissue_type#')		
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