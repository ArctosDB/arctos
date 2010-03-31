<cfinclude template="includes/_header.cfm">
<cfquery name="ctcollcde" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select distinct collection_cde from ctcollection_cde
</cfquery>
<cfoutput>
<cfset title = "Edit Code Tables">
<cfif action is "nothing">
	<cfquery name="getCTName" datasource="uam_god">
		select 
			distinct(table_name) table_name 
		from 
			sys.user_tables 
		where 
			table_name like 'CT%'
		UNION 
			select 'CTGEOLOGY_ATTRIBUTE' table_name from dual
		 order by table_name
	</cfquery>
	<cfloop query="getCTName">
		<a href="CodeTableEditor.cfm?action=edit&tbl=#getCTName.table_name#">#getCTName.table_name#</a><br>
	</cfloop>
<cfelseif action is "edit">
	<p>
		<a href="/CodeTableEditor.cfm">Back to table list</a>
	</p>
	<cfif tbl is "CTGEOLOGY_ATTRIBUTE"><!---------------------------------------------------->
		<cflocation url="/info/geol_hierarchy.cfm" addtoken="false">
	<cfelseif tbl is "ctspecimen_part_name"><!---------------------------------------------------->
		<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				part_name,
				description,
				is_tissue
			from #tbl#
			ORDER BY
				collection_cde,part_name
		</cfquery>
		Add record:
		<table class="newRec" border="1">
			<tr>
					<th>Collection Type</th>
				<th>Part Name</th>
				<td>IsTissue</td>
					<th>Description</th>
			</tr>
			<form name="newData" method="post" action="CodeTableEditor.cfm">
				<input type="hidden" name="action" value="newValue">
				<input type="hidden" name="tbl" value="#tbl#">
				<tr>
						<td>
							<select name="collection_cde" size="1">
								<cfloop query="ctcollcde">
									<option value="#ctcollcde.collection_cde#">#ctcollcde.collection_cde#</option>
								</cfloop>
							</select>
						</td>
					<td>
						<input type="text" name="part_name">
					</td>
					<td>
						<select name="is_tissue">
							<option value="0">no</option>
							<option value="1">yes</option>
						</select>
					</td>
					
						<td>
							<textarea name="description" id="description" rows="4" cols="40"></textarea>
						</td>
					<td>
						<input type="submit" 
							value="Insert" 
							class="insBtn">	
					</td>
				</tr>
			</form>
		</table>
		<cfset i = 1>
		Edit #tbl#:
		<table border="1">
			<tr>
					<th>Collection Type</th>
				<th>part_name</th>
				<th>IsTissue</th>
					<th>Description</th>
			</tr>
			<cfloop query="q">
				<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
					<form name="#tbl##i#" method="post" action="CodeTableEditor.cfm">
						<input type="hidden" name="Action">
						<input type="hidden" name="tbl" value="#tbl#">
						<input type="hidden" name="origData" value="#q.part_name#">
							<input type="hidden" name="origcollection_cde" value="#q.collection_cde#">
							<cfset thisColl=#q.collection_cde#>
							<td>
								<select name="collection_cde" size="1">
									<cfloop query="ctcollcde">
										<option 
											<cfif #thisColl# is "#ctcollcde.collection_cde#"> selected </cfif>value="#ctcollcde.collection_cde#">#ctcollcde.collection_cde#</option>
									</cfloop>
								</select>
							</td>
						<td>
							<input type="text" name="part_name" value="#q.part_name#" size="50">
						</td>
					<td>
						<select name="is_tissue">
							<option value="0">no</option>
							<option value="1">yes</option>
						</select>
					</td>
							<td>
								<textarea name="description" rows="4" cols="40">#q.description#</textarea>
							</td>				
						<td>
							<input type="button" 
								value="Save" 
								class="savBtn"
								onclick="#tbl##i#.Action.value='saveEdit';submit();">	
							<input type="button" 
								value="Delete" 
								class="delBtn"
								onclick="#tbl##i#.Action.value='deleteValue';submit();">	
		
						</td>
					</form>
				</tr>
				<cfset i = #i#+1>
			</cfloop>
		</table>
















	<cfelseif tbl is "ctattribute_code_tables"><!---------------------------------------------------->
		<cfquery name="ctAttribute_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select distinct(attribute_type) from ctAttribute_type
		</cfquery>
		<cfquery name="thisRec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			Select * from ctattribute_code_tables
			order by attribute_type
		</cfquery>
		<cfquery name="allCTs" datasource="uam_god">
			select distinct(table_name) as tablename from sys.user_tables where table_name like 'CT%' order by table_name
		</cfquery>
		<br>Create Attribute Control
		<table class="newRec" border>
			<tr>
				<th>Attribute</th>
				<th>Value Code Table</th>
				<th>Units Code Table</th>
				<th>&nbsp;</th>
			</tr>
			<form method="post" action="CodeTableEditor.cfm">
				<input type="hidden" name="action" value="newValue">
				<input type="hidden" name="tbl" value="#tbl#">
				<tr>
					<td>				
						<select name="attribute_type" size="1">
							<option value=""></option>
							<cfloop query="ctAttribute_type">
							<option 
								value="#ctAttribute_type.attribute_type#">#ctAttribute_type.attribute_type#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<cfset thisValueTable = #thisRec.value_code_table#>
						<select name="value_code_table" size="1">
							<option value="">none</option>
							<cfloop query="allCTs">
							<option 
							value="#allCTs.tablename#">#allCTs.tablename#</option>
							</cfloop>
						</select>			
					</td>
					<td>
						<cfset thisUnitsTable = #thisRec.units_code_table#>
						<select name="units_code_table" size="1">
							<option value="">none</option>
							<cfloop query="allCTs">
							<option 
							value="#allCTs.tablename#">#allCTs.tablename#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<input type="submit" 
							value="Create" 
							class="insBtn">	
					</td>
				</tr>
			</form>
		</table>
		<br>Edit Attribute Controls
		<table border>
			<tr>
				<th>Attribute</th>
				<th>Value Code Table</th>
				<th>Units Code Table</th>
				<th>&nbsp;</th>
			</tr>
			<cfset i=1>
			<cfloop query="thisRec">
				<form name="att#i#" method="post" action="CodeTableEditor.cfm">
					<input type="hidden" name="action" value="">
					<input type="hidden" name="tbl" value="#tbl#">
					<input type="hidden" name="oldAttribute_type" value="#Attribute_type#">
					<input type="hidden" name="oldvalue_code_table" value="#value_code_table#">
					<input type="hidden" name="oldunits_code_table" value="#units_code_table#">
					<tr>
						<td>
							<cfset thisAttType = #thisRec.attribute_type#>
								<select name="attribute_type" size="1">
									<option value=""></option>
									<cfloop query="ctAttribute_type">
									<option 
												<cfif #thisAttType# is "#ctAttribute_type.attribute_type#"> selected </cfif>value="#ctAttribute_type.attribute_type#">#ctAttribute_type.attribute_type#</option>
									</cfloop>
								</select>
						</td>
						<td>
							<cfset thisValueTable = #thisRec.value_code_table#>
							<select name="value_code_table" size="1">
								<option value="">none</option>
								<cfloop query="allCTs">
								<option 
								<cfif #thisValueTable# is "#allCTs.tablename#"> selected </cfif>value="#allCTs.tablename#">#allCTs.tablename#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<cfset thisUnitsTable = #thisRec.units_code_table#>
							<select name="units_code_table" size="1">
								<option value="">none</option>
								<cfloop query="allCTs">
								<option 
								<cfif #thisUnitsTable# is "#allCTs.tablename#"> selected </cfif>value="#allCTs.tablename#">#allCTs.tablename#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<input type="button" 
								value="Save" 
								class="savBtn"
							 	onclick="att#i#.action.value='saveEdit';submit();">	
							<input type="button" 
								value="Delete" 
								class="delBtn"
							  	onclick="att#i#.action.value='deleteValue';submit();">	
						</td>
					</tr>
				</form>
			<cfset i=#i#+1>
		</cfloop>
	</table>
	<cfelseif tbl is "ctpublication_attribute"><!---------------------------------------------------->
		<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from ctpublication_attribute order by publication_attribute
		</cfquery>
		<cfquery name="allCTs" datasource="uam_god">
			select distinct(table_name) as tablename from sys.user_tables where table_name like 'CT%' order by table_name
		</cfquery>
		<form name="newData" method="post" action="CodeTableEditor.cfm">
			<input type="hidden" name="action" value="newValue">
			<input type="hidden" name="tbl" value="ctpublication_attribute">
			<table class="newRec">
				<tr>
					<th>Publication Attribute</th>
					<th>Description</th>
					<th>Control</th>
					<th></th>
				</tr>
				<tr>
					<td>
						<input type="text" name="newData" >
					</td>
					<td>
						<textarea name="description" rows="4" cols="40"></textarea>
					</td>
					<td>
						<select name="control">
							<option value=""></option>
							<cfloop query="allCTs">
								<option value="#tablename#">#tablename#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<input type="submit" 
							value="Insert" 
							class="insBtn">
					</td>
				</tr>
			</table>
		</form>
		<cfset i = 1>
		<table>
			<tr>
				<th>Type</th>
				<th>Description</th>
				<th>Control</th>
			</tr>
			<cfloop query="q">
				<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
					<form name="#tbl##i#" method="post" action="CodeTableEditor.cfm">
						<input type="hidden" name="action" value="">
						<input type="hidden" name="tbl" value="ctpublication_attribute">
						<input type="hidden" name="origData" value="#publication_attribute#">
						<td>
							<input type="text" name="publication_attribute" value="#publication_attribute#" size="50">
						</td>
						<td>
							<textarea name="description" rows="4" cols="40">#description#</textarea>
						</td>
						<td>
							<select name="control">
								<option value=""></option>
								<cfloop query="allCTs">
									<option <cfif q.control is allCTs.tablename> selected="selected" </cfif>value="#tablename#">#tablename#</option>
								</cfloop>
							</select>
						</td>				
						<td>
							<input type="button" 
								value="Save" 
								class="savBtn"
							   	onclick="#tbl##i#.action.value='saveEdit';submit();">	
							<input type="button" 
								value="Delete" 
								class="delBtn"
								onclick="#tbl##i#.action.value='deleteValue';submit();">	
			
						</td>
					</form>
				</tr>
				<cfset i = #i#+1>
			</cfloop>
		</table>
	<cfelseif tbl is "ctcoll_other_id_type"><!--------------------------------------------------------------->
		<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from ctcoll_other_id_type order by other_id_type
		</cfquery>	
		<form name="newData" method="post" action="CodeTableEditor.cfm">
			<input type="hidden" name="action" value="newValue">
			<input type="hidden" name="tbl" value="ctcoll_other_id_type">
			<table class="newRec">
				<tr>
					<th>ID Type</th>
					<th>Description</th>
					<th>Base URL</th>
					<th></th>
				</tr>
				<tr>
					<td>
						<input type="text" name="newData" >
					</td>
					<td>
						<textarea name="description" rows="4" cols="40"></textarea>
					</td>
					<td>
						<input type="text" name="base_url" size="50">
					</td>
					<td>
						<input type="submit" 
							value="Insert" 
							class="insBtn">					
					</td>
				</tr>
			</table>
		</form>
		<cfset i = 1>
		<table>
			<tr>
				<th>Type</th>
				<th>Description</th>
				<th>Base URL</th>
			</tr>
			<cfloop query="q">
				<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
					<form name="#tbl##i#" method="post" action="CodeTableEditor.cfm">
						<input type="hidden" name="action" value="">
						<input type="hidden" name="tbl" value="ctcoll_other_id_type">
						<input type="hidden" name="origData" value="#other_id_type#">
						<td>
							<input type="text" name="other_id_type" value="#other_id_type#" size="50">
						</td>
						<td>
							<textarea name="description" rows="4" cols="40">#description#</textarea>
						</td>
						<td>
							<input type="text" name="base_url" size="60" value="#base_url#">
						</td>				
						<td>
							<input type="button" 
								value="Save" 
								class="savBtn"
							   	onclick="#tbl##i#.action.value='saveEdit';submit();">	
							<input type="button" 
								value="Delete" 
								class="delBtn"
								onclick="#tbl##i#.action.value='deleteValue';submit();">	
						</td>
					</form>
				</tr>
				<cfset i = #i#+1>
			</cfloop>
		</table>
	<cfelseif tbl is "ctspecimen_part_list_order"><!--- special section to handle  another  funky code table --->
		<cfquery name="thisRec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from ctspecimen_part_list_order order by
			list_order,partname
		</cfquery>
		<cfquery name="ctspecimen_part_name" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select collection_cde, part_name partname from ctspecimen_part_name
		</cfquery>
		<cfquery name="mo" dbtype="query">
			select max(list_order) +1 maxNum from thisRec
		</cfquery>
		<p>
			This application sets the order part names appear in certain reports and forms. 
			Nothing prevents you from making several parts the same
			order, and doing so will just cause them to not be ordered. You don't have to order things you don't care about.	
		</p>
		Create part ordering
		<table class="newRec" border>
			<tr>
				<th>Part Name</th>
				<th>List Order</th>
				<th></th>
			</tr>
			<form name="newPart" method="post" action="CodeTableEditor.cfm">
				<input type="hidden" name="action" value="newValue">
				<input type="hidden" name="tbl" value="#tbl#">
				<tr>
					<td>
						<cfset thisPart = #thisRec.partname#>
						<select name="partname" size="1">
							<cfloop query="ctspecimen_part_name">
							<option 
							value="#ctspecimen_part_name.partname#">#ctspecimen_part_name.partname# (#ctspecimen_part_name.collection_cde#)</option>
							</cfloop>
						</select>
					</td>
					<cfquery name="mo" dbtype="query">
						select max(list_order) +1 maxNum from thisRec
					</cfquery>
					<td>
						<cfset thisLO = #thisRec.list_order#>
						<select name="list_order" size="1">
							<cfloop from="1" to="#mo.maxNum#" index="n">
								<option value="#n#">#n#</option>
							</cfloop>
						</select>
					</td>
					<td colspan="3">
						<input type="submit" 
							value="Create" 
							class="insBtn">	
					</td>
				</tr>
			</form>	
		</table>
		Edit part order
		<table border>
			<tr>
				<th>Part Name</th>
				<th>List Order</th>
				<th>&nbsp;</th>
			</tr>
			<cfset i=1>
			<cfloop query="thisRec">
				<form name="part#i#" method="post" action="CodeTableEditor.cfm">
					<input type="hidden" name="action" value="ctspecimen_part_list_order">
					<input type="hidden" name="tbl" value="#tbl#">
					<input type="hidden" name="oldlist_order" value="#list_order#">
					<input type="hidden" name="oldpartname" value="#partname#">
					<tr>
						<td>
							<cfset thisPart = #thisRec.partname#>
							<select name="partname" size="1">
								<cfloop query="ctspecimen_part_name">
								<option 
								<cfif #thisPart# is "#ctspecimen_part_name.partname#"> selected </cfif>value="#ctspecimen_part_name.partname#">#ctspecimen_part_name.partname#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<cfset thisLO = #thisRec.list_order#>
							<select name="list_order" size="1">
								<cfloop from="1" to="#mo.maxNum#" index="n">
									<option <cfif #thisLO# is "#n#"> selected </cfif>value="#n#">#n#</option>
								</cfloop>
							</select>
						</td>
						<td colspan="3">
							<input type="button" 
								value="Save" 
								class="savBtn"
								onclick="part#i#.action.value='saveEdit';submit();">	
							<input type="button" 
								value="Delete" 
								class="delBtn"
							 	onclick="part#i#.action.value='deleteValue';submit();">	
								
						</td>
					</tr>
				</form>
				<cfset i=#i#+1>
			</cfloop>
		</table>
	<cfelse><!---------------------------- normal CTs --------------->
		<cfquery name="getCols" datasource="uam_god">
			select column_name from sys.user_tab_columns where table_name='#tbl#'
		</cfquery>
		<cfset collcde=listfindnocase(valuelist(getCols.column_name),"collection_cde")>
		<cfset hasDescn=listfindnocase(valuelist(getCols.column_name),"description")>
		<cfquery name="f" dbtype="query">
			select column_name from getCols where lower(column_name) not in ('collection_cde','description')
		</cfquery>
		<cfset fld=f.column_name>
		<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select #fld# as data 
			<cfif collcde gt 0>
				,collection_cde
			</cfif>
			<cfif hasDescn gt 0>
				,description
			</cfif>
			from #tbl#
			ORDER BY
			<cfif collcde gt 0>
				collection_cde,
			</cfif>
			#fld#
		</cfquery>
		Add record:
		<table class="newRec" border="1">
			<tr>
				<cfif collcde gt 0>
					<th>Collection Type</th>
				</cfif>
				<th>#fld#</th>
				<cfif hasDescn gt 0>
					<th>Description</th>
				</cfif>
			</tr>
			<form name="newData" method="post" action="CodeTableEditor.cfm">
				<input type="hidden" name="collcde" value="#collcde#">
				<input type="hidden" name="action" value="newValue">
				<input type="hidden" name="tbl" value="#tbl#">
				<input type="hidden" name="hasDescn" value="#hasDescn#">
				<input type="hidden" name="fld" value="#fld#">
				<tr>
					<cfif collcde gt 0>
						<td>
							<select name="collection_cde" size="1">
								<cfloop query="ctcollcde">
									<option value="#ctcollcde.collection_cde#">#ctcollcde.collection_cde#</option>
								</cfloop>
							</select>
						</td>
					</cfif>
					<td>
						<input type="text" name="newData" >
					</td>
					
					<cfif hasDescn gt 0>
						<td>
							<textarea name="description" id="description" rows="4" cols="40"></textarea>
						</td>
					</cfif>
					<td>
						<input type="submit" 
							value="Insert" 
							class="insBtn">	
					</td>
				</tr>
			</form>
		</table>
		<cfset i = 1>
		Edit #tbl#:
		<table border="1">
			<tr>
				<cfif collcde gt 0>
					<th>Collection Type</th>
				</cfif>
				<th>#fld#</th>
				<cfif hasDescn gt 0>
					<th>Description</th>
				</cfif>
			</tr>
			<cfloop query="q">
				<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
					<form name="#tbl##i#" method="post" action="CodeTableEditor.cfm">
						<input type="hidden" name="Action">
						<input type="hidden" name="tbl" value="#tbl#">
						<input type="hidden" name="fld" value="#fld#">
						<input type="hidden" name="collcde" value="#collcde#">
						<input type="hidden" name="hasDescn" value="#hasDescn#">
						<input type="hidden" name="origData" value="#q.data#">
						<cfif collcde gt 0>
							<input type="hidden" name="origcollection_cde" value="#q.collection_cde#">
							<cfset thisColl=#q.collection_cde#>
							<td>
								<select name="collection_cde" size="1">
									<cfloop query="ctcollcde">
										<option 
											<cfif #thisColl# is "#ctcollcde.collection_cde#"> selected </cfif>value="#ctcollcde.collection_cde#">#ctcollcde.collection_cde#</option>
									</cfloop>
								</select>
							</td>
						</cfif>
						<td>
							<input type="text" name="thisField" value="#q.data#" size="50">
						</td>
						<cfif hasDescn gt 0>
							<td>
								<textarea name="description" rows="4" cols="40">#q.description#</textarea>
							</td>				
						</cfif>
						<td>
							<input type="button" 
								value="Save" 
								class="savBtn"
								onclick="#tbl##i#.Action.value='saveEdit';submit();">	
							<input type="button" 
								value="Delete" 
								class="delBtn"
								onclick="#tbl##i#.Action.value='deleteValue';submit();">	
		
						</td>
					</form>
				</tr>
				<cfset i = #i#+1>
			</cfloop>
		</table>
	</cfif>
<cfelseif action is "deleteValue">
	<cfif tbl is "ctpublication_attribute">
		<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			delete from ctpublication_attribute 
			where
				publication_attribute='#origData#'
		</cfquery>
	<cfelseif tbl is "ctspecimen_name_name">
		<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			delete from ctspecimen_name_name
			where
				OTHER_ID_TYPE='#origData#' and
				collection_cde='#collection_cde#'
		</cfquery>
	<cfelseif tbl is "ctcoll_other_id_type">
		<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			delete from ctcoll_other_id_type
			where
				OTHER_ID_TYPE='#origData#'
		</cfquery>
	<cfelseif tbl is "ctattribute_code_tables">
		<cfquery name="del" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			DELETE FROM ctattribute_code_tables
			WHERE
				Attribute_type = '#oldAttribute_type#' 
				<cfif len(#oldvalue_code_table#) gt 0>
					AND	value_code_table = '#oldvalue_code_table#'
				</cfif> 
				<cfif len(#oldunits_code_table#) gt 0>
					AND	units_code_table = '#oldunits_code_table#'
				</cfif> 
		</cfquery>
	<cfelseif tbl is "ctspecimen_part_list_order">
		<cfquery name="del" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			DELETE FROM ctspecimen_part_list_order
			WHERE
				partname = '#oldpartname#' AND
				list_order = '#oldlist_order#'
		</cfquery>
	<cfelse>
		<cfquery name="del" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			DELETE FROM #tbl# 
			where #fld# = '#origData#'
			<cfif isdefined("collection_cde") and len(collection_cde) gt 0>
				 AND collection_cde='#origcollection_cde#'
			</cfif>
		</cfquery>
	</cfif>
	<cflocation url="CodeTableEditor.cfm?action=edit&tbl=#tbl#" addtoken="false">
<cfelseif action is "saveEdit">
	<cfif tbl is "ctpublication_attribute">
		<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			update ctpublication_attribute set 
				publication_attribute='#publication_attribute#',
				DESCRIPTION='#description#',
				control='#control#'
			where
				publication_attribute='#origData#'
		</cfquery>
	<cfelseif tbl is "ctspecimen_name_name">
		<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			update ctspecimen_name_name set 
				part_name='#part_name#',
				DESCRIPTION='#description#',
				is_tissue=#is_tissue#
			where
				part_name='#origData#' and
				collection_cde='#origcollection_cde#'
		</cfquery>
	<cfelseif tbl is "ctcoll_other_id_type">
		<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			update ctcoll_other_id_type set 
				OTHER_ID_TYPE='#other_id_type#',
				DESCRIPTION='#description#',
				base_URL='#base_url#'
			where
				OTHER_ID_TYPE='#origData#'
		</cfquery>
	<cfelseif tbl is "ctattribute_code_tables">
		<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			UPDATE ctattribute_code_tables SET
				Attribute_type = '#Attribute_type#',
				value_code_table = '#value_code_table#',
				units_code_table = '#units_code_table#'
			WHERE
				Attribute_type = '#oldAttribute_type#' AND
				value_code_table = '#oldvalue_code_table#' AND
				units_code_table = '#oldunits_code_table#'
		</cfquery>
	<cfelseif tbl is "ctspecimen_part_list_order">
		<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			UPDATE ctspecimen_part_list_order SET
				partname = '#partname#',
				list_order = '#list_order#'
			WHERE
				partname = '#oldpartname#' AND
				list_order = '#oldlist_order#'
		</cfquery>
	<cfelse>
		<cfquery name="up" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			UPDATE #tbl# SET #fld# = '#thisField#'
			<cfif isdefined("collection_cde") and len(collection_cde) gt 0>
				,collection_cde='#collection_cde#'
			</cfif>
			<cfif isdefined("description")>
				,description='#description#'
			</cfif>
			where #fld# = '#origData#'
			<cfif isdefined("collection_cde") and len(collection_cde) gt 0>
				 AND collection_cde='#origcollection_cde#'
			</cfif>
		</cfquery>
	</cfif>
	<cflocation url="CodeTableEditor.cfm?action=edit&tbl=#tbl#" addtoken="false">
<cfelseif action is "newValue">
	<cfif tbl is "ctpublication_attribute">
		<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			insert into ctpublication_attribute (
				publication_attribute,
				DESCRIPTION,
				control
			) values (
				'#newData#',
				'#description#',
				'#control#'
			)
		</cfquery>
	
	<cfelseif tbl is "ctspecimen_name_name">
		<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			insert into ctspecimen_name_name (
				part_name,
				DESCRIPTION,
				is_tissue
			) values (
				'#part_name#',
				'#description#',
				#is_tissue#
			)
		</cfquery>
	<cfelseif tbl is "ctcoll_other_id_type">
		<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			insert into ctcoll_other_id_type (
				OTHER_ID_TYPE,
				DESCRIPTION,
				base_URL
			) values (
				'#newData#',
				'#description#',
				'#base_url#'
			)
		</cfquery>
	<cfelseif tbl is "ctattribute_code_tables">
		<cfquery name="new" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			INSERT INTO ctattribute_code_tables (
				Attribute_type
				<cfif len(#value_code_table#) gt 0>
					,value_code_table
				</cfif>
				<cfif len(#units_code_table#) gt 0>
					,units_code_table
				</cfif>
				)
			VALUES (
				'#Attribute_type#'
				<cfif len(#value_code_table#) gt 0>
					,'#value_code_table#'
				</cfif>
				<cfif len(#units_code_table#) gt 0>
					,'#units_code_table#'
				</cfif>
			)
		</cfquery>
	<cfelseif tbl is "ctspecimen_part_list_order">
		<cfquery name="new" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			INSERT INTO ctspecimen_part_list_order (
				partname,
				list_order
				)
			VALUES (
				'#partname#',
				#list_order#
			)
		</cfquery>
	<cfelse>
		<cfquery name="new" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			INSERT INTO #tbl# 
				(#fld#
				<cfif isdefined("collection_cde") and len(collection_cde) gt 0>
					 ,collection_cde
				</cfif>
				<cfif isdefined("description") and len(description) gt 0>
					 ,description
				</cfif>
				)
			VALUES 
				('#newData#'
				<cfif isdefined("collection_cde") and len(collection_cde) gt 0>
					 ,'#collection_cde#'
				</cfif>
				<cfif isdefined("description") and len(description) gt 0>
					 ,'#description#'
				</cfif>
			)
		</cfquery>
	</cfif>
	<cflocation url="CodeTableEditor.cfm?action=edit&tbl=#tbl#" addtoken="false">
</cfif>
</cfoutput>
<cfinclude template="includes/_footer.cfm">