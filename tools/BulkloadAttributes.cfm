<!---

 CREATE OR REPLACE TRIGGER cf_temp_attributes_key                                         
 before insert  ON cf_temp_attributes  
 for each row 
    begin     
    	if :NEW.key is null then                                                                                      
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;                                
    end;                                                                                            
/
sho err
--->
<cfinclude template="/includes/_header.cfm">
<cfif #action# is "nothing">
Step 1: Upload a comma-delimited text file (csv). 
Include column headings, spelled exactly as below. 
<br><span class="likeLink" onclick="document.getElementById('template').style.display='block';">view template</span>
	<div id="template" style="display:none;">
		<label for="t">Copy the existing code and save as a .csv file</label>
		<textarea rows="2" cols="80" id="t">OTHER_ID_TYPE,OTHER_ID_NUMBER,ATTRIBUTE,ATTRIBUTE_VALUE,ATTRIBUTE_UNITS,ATTRIBUTE_DATE,ATTRIBUTE_METH,DETERMINER,REMARKS,COLLECTION_CDE,INSTITUTION_ACRONYM</textarea>
	</div> 
<p></p>




Columns in <span style="color:red">red</span> are required; others are optional:
<ul>
	<li style="color:red">COLLECTION_CDE</li>
	<li style="color:red">INSTITUTION_ACRONYM</li>
	<li style="color:red">OTHER_ID_TYPE ("catalog number" is OK)</li>
	<li style="color:red">OTHER_ID_NUMBER</li>
	<li style="color:red">ATTRIBUTE</li>
	<li style="color:red">ATTRIBUTE_VALUE</li>
	<li>ATTRIBUTE_UNITS</li>
	<li>ATTRIBUTE_DATE</li>
	<li>ATTRIBUTE_METH</li>
	<li style="color:red">DETERMINER</li>
	<li>REMARKS</li>				 
</ul>

<cfform name="atts" method="post" enctype="multipart/form-data">
			<input type="hidden" name="Action" value="getFile">
			  <input type="file"
		   name="FiletoUpload"
		   size="45">
			 <input type="submit" value="Upload this file"
		class="savBtn"
		onmouseover="this.className='savBtn btnhov'" 
		onmouseout="this.className='savBtn'">
  </cfform>

</cfif>
<!------------------------------------------------------->
<!------------------------------------------------------->

<!------------------------------------------------------->
<cfif #action# is "getFile">
<cfoutput>
	<!--- put this in a temp table --->
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		delete from cf_temp_attributes
	</cfquery>
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	<cfset fileContent=replace(fileContent,"'","''","all")>
	<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />

	
	<cfset colNames="">
	<cfloop from="1" to ="#ArrayLen(arrResult)#" index="o">
		<cfset colVals="">
			<cfloop from="1"  to ="#ArrayLen(arrResult[o])#" index="i">
				<cfset thisBit=arrResult[o][i]>
				<cfif #o# is 1>
					<cfset colNames="#colNames#,#thisBit#">
				<cfelse>
					<cfset colVals="#colVals#,'#thisBit#'">
				</cfif>
			</cfloop>
		<cfif #o# is 1>
			<cfset colNames=replace(colNames,",","","first")>
		</cfif>	
		<cfif len(#colVals#) gt 1>
			<cfset colVals=replace(colVals,",","","first")>
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into cf_temp_attributes (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>
	<cflocation url="BulkloadAttributes.cfm?action=validate">
</cfoutput>

 
	<!---	 
		 
		 	
	<cfset i=1>
	<cfloop index="line" list="#fileContent#" delimiters="#chr(10)#">
		<cfset sql = "">
		<cfset line = #replace(line,'#chr(9)##chr(9)#','#chr(9)#null#chr(9)#','all')#>
		<br>line:#line#
		<cfloop index="field" list="#line#" delimiters="#chr(9)#">
			<br>field:#field#
			<cfset field = #replace(field,"'","''","all")#>
			<cfset sql = #replace(sql,'{comma}',',','all')#>
			<cfset sql = "#sql#'#trim(replace(field,'"','','all'))#',">
		</cfloop>
	 	<cfset sql = #reverse(replace(reverse(sql),",","","first"))#>
		<cfset sql = "#i#,#sql#">
		<cfset i=#i#+1>
		<br>INSERT INTO cf_temp_attributes (
				 KEY,
				 COLLECTION_CDE,
				 INSTITutION_ACRONYM,
				OTHER_ID_TYPE,
				OTHER_ID_NUMBER,
				 ATTRIBUTE,
				 ATTRIBUTE_VALUE,
				 ATTRIBUTE_UNITS,
				 ATTRIBUTE_DATE,
				 ATTRIBUTE_METH,
				 DETERMINER,
				 REMARKS
				 ) 
			VALUES (
				#preservesinglequotes(sql)#
				)	 
		<cfquery name="newRec"	 datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			INSERT INTO cf_temp_attributes (
				 KEY,
				 COLLECTION_CDE,
				 INSTITutION_ACRONYM,
				OTHER_ID_TYPE,
				OTHER_ID_NUMBER,
				 ATTRIBUTE,
				 ATTRIBUTE_VALUE,
				 ATTRIBUTE_UNITS,
				 ATTRIBUTE_DATE,
				 ATTRIBUTE_METH,
				 DETERMINER,
				 REMARKS
				 ) 
			VALUES (
				#preservesinglequotes(sql)#
				)	 
			
			</cfquery>
    </cfloop>
	<!----
		
	---->
	<cflocation url="BulkloadAttributes.cfm?action=validate">
--->
</cfif>
<!------------------------------------------------------->
<!------------------------------------------------------->
<cfif #action# is "validate">
<cfoutput>

	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from cf_temp_attributes
	</cfquery>
	<cfloop query="data">
		<cfif len(#other_id_type#) is 0>
			You must specify an other ID type.
			<cfabort>
		</cfif>
		<cfif len(#other_id_number#) is 0>
			You must specify an other ID number.
			<cfabort>
		</cfif>
		<cfif len(#collection_cde#) is 0>
			You must specify a collection_cde.
			<cfabort>
		</cfif>
		<cfif len(#institution_acronym#) is 0>
			You must specify a institution_acronym.
			<cfabort>
		</cfif>
		
		<cfif #other_id_type# is "catalog number">
			<cfquery name="collObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					SELECT 
						collection_object_id
					FROM
						cataloged_item,
						collection
					WHERE
						cataloged_item.collection_id = collection.collection_id and
						collection.collection_cde = '#collection_cde#' and
						collection.institution_acronym = '#institution_acronym#' and
						cat_num=#other_id_number#
				</cfquery>
			<cfelse>
				<cfquery name="collObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					SELECT 
						coll_obj_other_id_num.collection_object_id
					FROM
						coll_obj_other_id_num,
						cataloged_item,
						collection
					WHERE
						coll_obj_other_id_num.collection_object_id = cataloged_item.collection_object_id and
						cataloged_item.collection_id = collection.collection_id and
						collection.collection_cde = '#collection_cde#' and
						collection.institution_acronym = '#institution_acronym#' and
						other_id_type = '#other_id_type#' and
						display_value = '#other_id_number#'
				</cfquery>
			</cfif>
			<cfif #collObj.recordcount# is not 1>
					#data.other_id_number# #data.other_id_type# #data.collection_cde# #data.institution_acronym#
					could not be found!
					<br>The load process has aborted!
					<br>You must fix the original file and start over.
					<cfabort>
			</cfif>
			<cfquery name="insColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				UPDATE cf_temp_attributes SET collection_object_id = #collObj.collection_object_id# where
				key = #key#
			</cfquery>
			
			
			<cfif len(#attribute#) is 0>
				You must specify an attribute.
					<br>The load process has aborted!
					<br>You must fix the original file and start over.
					<cfabort>
			</cfif>
			<cfquery name="isAtt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select attribute_type from ctattribute_type where attribute_type='#attribute#'
					AND collection_cde='#collection_cde#'
			</cfquery>
			
			<cfif isAtt.recordcount is not 1>					
				<cfabort showerror="Attribute (#attribute#) 
					does not match code table values for collection #collection_cde#.">
			</cfif>	
			<!---- see if it  should be code-table controlled ---->
			<cfquery name="isValCt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				SELECT value_code_table FROM ctattribute_code_tables WHERE
				attribute_type = '#trim(attribute)#'
			</cfquery>
					<cfif isdefined("isValCt.value_code_table") and len(#isValCt.value_code_table#) gt 0>
								<br>!-- there's a code table ---
							<cfquery name="valCT" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
								select * from #isValCt.value_code_table#
							</cfquery>			
							<!---- get column names --->
							<cfquery name="getCols" datasource="uam_god">
								select column_name from sys.user_tab_columns where table_name='#ucase(isValCt.value_code_table)#'
								and column_name <> 'DESCRIPTION'
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
								<!--- if we got a collection code, rerun the query to filter ---->
								<cfif len(#collCode#) gt 0>
									<cfquery name="valCodes" dbtype="query">
										SELECT #getCols.column_name# as valCodes from valCT
										WHERE #getCols.column_name# =  '#attribute_value#'
										AND collection_cde='#collection_cde#'
									</cfquery>
								  <cfelse>
								 	<cfquery name="valCodes" dbtype="query">
										SELECT #getCols.column_name# as valCodes from valCT
										WHERE #getCols.column_name# =  '#attribute_value#'
									</cfquery>
								</cfif>
								<cfset GoodValueFlag = "">
								<cfset thisVal = #data.attribute_value#>
								<cfloop query="valCodes">
									<cfif #valCodes.valCodes# is #thisVal#>
										<cfset GoodValueFlag = "'something that's longer than nothing'">
									</cfif>
								</cfloop>
								<cfif len(#GoodValueFlag#) is 0>									
									<cfabort showerror="Attribute Value (#attribute_value#) is code table controlled and 
									does not match code table values.">
								</cfif>
							</cfif>
						
					<cfif len(#attribute_units#) gt 0>
						<cfquery name="isUnitCt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							SELECT units_code_table FROM ctattribute_code_tables WHERE
							attribute_type = '#attribute#'
						</cfquery>
						<cfif #isUnitCt.recordcount# gt 0 AND len(#isUnitCt.units_code_table#) gt 0>
							<cfquery name="unitCT" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
								select * from #isUnitCt.units_code_table#
							</cfquery>
							<!---- get column names --->
							<cfquery name="getCols" datasource="uam_god">
								select column_name from sys.user_tab_columns where table_name='#ucase(isUnitCt.units_code_table)#'
								and column_name <> 'DESCRIPTION'
							</cfquery>
							<cfset collCode = "">
							<cfset columnName = "">
							<cfloop query="getCols">
								<cfif getCols.column_name is "COLLECTION_CDE">
									<cfset collCde = "yes">
									collCde = "yes"
								  <cfelse>
									<cfset columnName = "#getCols.column_name#">
								</cfif>
							</cfloop>
							<cfif len(#collCode#) gt 0>
								<cfquery name="unitCodes" dbtype="query">
									SELECT #getCols.column_name# as unitCodes from unitCT
									WHERE collection_cde='#indiv.collection_cde#'
								</cfquery>
							  <cfelse>
								<cfquery name="unitCodes" dbtype="query">
									SELECT #getCols.column_name# as unitCodes from unitCT
								</cfquery>
							</cfif>
					<cfset thisAttUnit = #attribute_units#>
					<cfset AttUnitBsdFlag = "">
					<cfloop query="unitCodes">
						<cfif #unitCodes.unitCodes# is "#thisAttUnit#"> 
							<cfset AttUnitBsdFlag = "something">
						</cfif>
					</cfloop>
					<cfif len(#AttUnitBsdFlag#) is 0>
						<cfabort showerror="Attribute units (#attribute_units#) did not match CT values">
					</cfif>
		  			<!---- they have a valid units code table, so go back and make sure the value they 
						gave is numeric --->
					<cfif not isnumeric(#attribute_value#)>
						<cfabort showerror="Attribute Value (#attribute_value#) must be numeric for #attribute#">
					</cfif>
		  <cfelse>
							<!---- not code table controlled, leave it null for now - all units are 
							either CT controlled or NULL--->
							<!--- see if they tried to put anything in here --->
							<cfif len(#attribute_units#) gt 0>
								<cfif #attribute_units# is not "null">
									<cfabort showerror="You can't have attribute units for this attribute.">
								</cfif>
							</cfif>
					</cfif><!--- end CT check --->
				 <cfelse>
					 <!--- att val units not given, see if it should be --->
					 	<cfquery name="isUnitCt" datasource="#mcat#">
							SELECT units_code_table FROM ctattribute_code_tables WHERE
							attribute_type = '#attribute_1#'
						</cfquery>
						<cfif #isUnitCt.recordcount# gt 0 and len(#isUnitCt.units_code_table#) gt 0>
							
							<cfabort showerror="A value for Atribute Units  is required.">
						</cfif>
					</cfif>
					<cfif len(#remarks#) gt 0>
						<!---- just assign it to the local variable --->
						<cfset attributeremarks1 = "'#remarks#'">					
					</cfif>
					<cfif len(#attribute_date#) gt 0>
						<cfif isdate(#attribute_date#)>
							<cfset attributedate1 = "'#dateformat(attribute_date,"dd-mmm-yyyy")#'">
						  <cfelse>
						 	<cfabort showerror="Attribute Date (#attribute_date#) is not a date">
						 </cfif>
					  <cfelse>
					  	<cfabort showerror="Attribute Date is required.">						
					</cfif>
					<cfif len(#attribute_meth#) gt 0>
						<!---- just assign it to the local variable --->
						<cfset attributedetmeth1 = "'#attribute_meth#'">					
					</cfif>
					<cfif len(#determiner#) gt 0>
						<cfquery name="attDet1" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							SELECT agent_id FROM agent_name WHERE agent_name = '#determiner#'
						</cfquery>
						<cfif #attDet1.recordcount# is 0>
							<cfabort showerror="Attribute Determiner (#determiner#) was not found.">
						</cfif>
						<cfif #attDet1.recordcount# gt 1>
							<cfabort showerror="Attribute Determiner (#determiner#)
							 matched more than one existing agent name.">
						</cfif>
						<cfquery name="gotDet" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							UPDATE cf_temp_attributes SET determined_by_agent_id = #attDet1.agent_id#
							where key=#key#
						</cfquery>
					<cfelse>
						<cfabort showerror="Attribute Determiner 1 may not be null.">
					</cfif>
		</cfloop>
	<cflocation url="BulkloadAttributes.cfm?action=loadData">
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif #action# is "loadData">

<cfoutput>
	
		
	<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from cf_temp_attributes
	</cfquery>
	<cftransaction>
	<cfloop query="getTempData">
		<cfquery name="newAtt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		INSERT INTO attributes (
			attribute_id,
			collection_object_id,
			determined_by_agent_id,
			attribute_type,
			attribute_value
			<cfif len(#attribute_units#) gt 0>
				,attribute_units
			</cfif>
			<cfif len(#remarks#) gt 0>
				,attribute_remark
			</cfif>
			,determined_date
			<cfif len(#attribute_meth#) gt 0>
				,determination_method
			</cfif>
			)
		VALUES (
			sq_attribute_id.nextval,
			#collection_object_id#,
			#determined_by_agent_id#,
			'#attribute#'
			,'#attribute_value#'
			<cfif len(#attribute_units#) gt 0>
				,'#attribute_units#'
			</cfif>
			<cfif len(#remarks#) gt 0>
				,'#remarks#'
			</cfif>
			,'#dateformat(attribute_date,"dd-mmm-yyyy")#'
			<cfif len(#attribute_meth#) gt 0>
				,'#attribute_meth#'
			</cfif>
			)
			</cfquery>
	</cfloop>
	</cftransaction>

	Spiffy, all done.
</cfoutput>
</cfif>

<cfinclude template="/includes/_footer.cfm">
