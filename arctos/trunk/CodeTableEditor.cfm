<cfinclude template="includes/_header.cfm">
<cfif #tbl# is "CTGEOLOGY_ATTRIBUTE">
	<cflocation url="/info/geol_hierarchy.cfm">
</cfif>
<cfif not isdefined("hasDescn")>
	<cfset hasDescn="">
</cfif>
<cfif not isdefined("fld")>
	<cfset fld="">
</cfif>
<cfif not isdefined("collcde")>
	<cfset collcde="">
</cfif>
<cfquery name="ctcollcde" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select distinct collection_cde from ctcollection_cde
</cfquery>
<cfoutput>
	Edit code table #tbl#
	<cfset title = "Edit #tbl#">
	
	
<cfif #tbl# is "ctattribute_code_tables">
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
	<table border>
		<tr>
			<td>Attribute</td>
			<td>Value Code Table</td>
			<td>Units Code Table</td>
		</tr>
		<cfset i=1>
		<cfloop query="thisRec">
			<form name="att#i#" method="post" action="CodeTableEditor.cfm">
				<input type="hidden" name="action" value="ctattribute_code_tables">
				<input type="hidden" name="tbl" value="#tbl#">
				<input type="hidden" name="meth">
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
				</tr>
				<tr>
					<td colspan="3">
						<input type="button" 
							value="Save" 
							class="savBtn"
						 	onclick="att#i#.meth.value='save';submit();">	
						<input type="button" 
							value="Delete" 
							class="delBtn"
						  	onclick="att#i#.meth.value='delete';submit();">	
					</td>
				</tr>
			</form>
		<cfset i=#i#+1>
	</cfloop>
</table>
<table class="newRec" border>
	<tr>
		<td>Attribute</td>
		<td>Value Code Table</td>
		<td>Units Code Table</td>
	</tr>
	<form method="post" action="CodeTableEditor.cfm">
		<input type="hidden" name="action" value="ctattribute_code_tables">
		<input type="hidden" name="tbl" value="#tbl#">
		<input type="hidden" name="meth" value="insert">
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
		</tr>
		<tr>
			<td colspan="3">
				<input type="submit" 
					value="Create" 
					class="insBtn">	
			</td>
		</tr>
	</form>
</table>
<cfelseif #tbl# is "ctcoll_other_id_type">
<!--------------------------------------------------------------->
	<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from ctcoll_other_id_type order by other_id_type
	</cfquery>	
	<form name="newData" method="post" action="CodeTableEditor.cfm">
		<input type="hidden" name="action" value="i_ctcoll_other_id_type">
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
					<input type="button" 
						value="Quit" 
						class="qutBtn"
						onClick="document.location='CodeTableButtons.cfm';">	
				
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
						<textarea name="base_url" rows="4" cols="40">#base_url#</textarea>
					</td>				
					<td>
						<input type="button" 
							value="Save" 
							class="savBtn"
						   	onclick="#tbl##i#.action.value='u_ctcoll_other_id_type';submit();">	
		
						<input type="button" 
							value="Delete" 
							class="delBtn"
						   	onmouseover="this.className='delBtn btnhov'" 
						   	onmouseout="this.className='delBtn'"
							onclick="#tbl##i#.action.value='d_ctcoll_other_id_type';submit();">	
		
					</td>
				</form>
			</tr>
			<cfset i = #i#+1>
		</cfloop>
	</table>
<cfelseif #tbl# is "ctspecimen_part_list_order">
<!--- special section to handle  another  funky code table --->
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
	This is a special part of this application for a hinky CT. This code isn't very robust because it doesn't have to 
		be - select people are allowed here, and all they can do is make formatting ugly.
		If you are here, it's because we trust you. Don't do anything stoopid!!
		<p>
		
		
		All this application does is order part names. Nothing prevents you from making several parts the same
		order, and doing so will just cause them to not be ordered. You don't have to order things you don't care about.
		
</p>
	<table border>
		<tr>
			
			<td>Part Name</td>
			<td>List Order</td>
		</tr>
	<cfset i=1>
	<cfloop query="thisRec">
			<form name="part#i#" method="post" action="CodeTableEditor.cfm">
				<input type="hidden" name="action" value="ctspecimen_part_list_order">
				<input type="hidden" name="tbl" value="#tbl#">
				<input type="hidden" name="meth">
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
							<option 
					<cfif #thisLO# is "#n#"> selected </cfif>value="#n#">#n#</option>
					
						</cfloop>
					</select>
				
				</td>
			</tr>
			
				<tr>
				<td colspan="3">
				<input type="button" 
	value="Save" 
	class="savBtn"
   	onmouseover="this.className='savBtn btnhov'" 
   	onmouseout="this.className='savBtn'"
	onclick="part#i#.meth.value='save';submit();">	
	
	<input type="button" 
	value="Delete" 
	class="delBtn"
   	onmouseover="this.className='delBtn btnhov'" 
   	onmouseout="this.className='delBtn'"
	onclick="part#i#.meth.value='delete';submit();">	
	
				</td>
			</tr>
				
				
				
				
			</form>
			<cfset i=#i#+1>
	</cfloop>
	</table>
	
	
	
	<table class="newRec" border>
		<tr>
			
			<td>Collection Code</td>
			<td>Part Name</td>
			<td>List Order</td>
		</tr>
	
			<form name="newPart" method="post" action="CodeTableEditor.cfm">
				<input type="hidden" name="action" value="ctspecimen_part_list_order">
				<input type="hidden" name="tbl" value="#tbl#">
				<input type="hidden" name="meth" value="insert">
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
							<option 
					value="#n#">#n#</option>
					
						</cfloop>
					</select>
				
				</td>
			</tr>
			
				<tr>
				<td colspan="3">
				<input type="submit" 
	value="Create" 
	class="insBtn"
   	onmouseover="this.className='insBtn btnhov'" 
   	onmouseout="this.className='insBtn'">	
	
				</td>
			</tr>
				
				
				
				
			</form>
			
	</table>
<cfelse><!---------------------------- normal CTs --------------->

	<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select #fld# as data 
		<cfif #collcde# is "y">
			,collection_cde
		</cfif>
		<cfif #hasDescn# is "y">
			,description
		</cfif>
		from #tbl#
		ORDER BY
		<cfif #collcde# is "y">
			collection_cde,
		</cfif>
		#fld#
	</cfquery>
	<table class="newRec">
	<form name="newData" method="post" action="CodeTableEditor.cfm">
		<input type="hidden" name="collcde" value="#collcde#">
		<input type="hidden" name="Action" value="inst#tbl#">
		<input type="hidden" name="tbl" value="#tbl#">
		<input type="hidden" name="hasDescn" value="#hasDescn#">
		<input type="hidden" name="fld" value="#fld#">
		
		<cfif #collcde# is "y">
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
			
			<cfif #hasDescn# is "y">
				<td>
					<textarea name="description" rows="4" cols="40"></textarea>
				</td>
				
			</cfif>
			<td>
				<input type="submit" 
	value="Insert" 
	class="insBtn"
   	onmouseover="this.className='insBtn btnhov'" 
   	onmouseout="this.className='insBtn'">	
	
	<input type="button" 
	value="Quit" 
	class="qutBtn"
   	onmouseover="this.className='qutBtn btnhov'" 
   	onmouseout="this.className='qutBtn'"
	onClick="document.location='CodeTableButtons.cfm';">	
				
			</td>
			
	</form>
	</table>
	<cfset i = 1>
	<table>
	<cfloop query="q">
		<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
		<form name="#tbl##i#" method="post" action="CodeTableEditor.cfm">
			<input type="hidden" name="Action">
			<input type="hidden" name="tbl" value="#tbl#">
			<input type="hidden" name="fld" value="#fld#">
			<input type="hidden" name="collcde" value="#collcde#">
			<input type="hidden" name="hasDescn" value="#hasDescn#">
			<input type="hidden" name="origData" value="#q.data#">
			
			
			
			<cfif #collcde# is "y">
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
			
			
			<cfif #hasDescn# is "y">
			<td>
				<textarea name="description" rows="4" cols="40">#q.description#</textarea>
			</td>				
			</cfif>
			<td>
			<input type="button" 
	value="Save" 
	class="savBtn"
   	onmouseover="this.className='savBtn btnhov'" 
   	onmouseout="this.className='savBtn'"
	onclick="#tbl##i#.Action.value='save#tbl#';submit();">	
	
	<input type="button" 
	value="Delete" 
	class="delBtn"
   	onmouseover="this.className='delBtn btnhov'" 
   	onmouseout="this.className='delBtn'"
	onclick="#tbl##i#.Action.value='dele#tbl#';submit();">	
	
			</td>
		</form>
		</tr>
		<cfset i = #i#+1>
	</cfloop>
	</table>
	
	</cfif>
	</cfoutput>
<!----------------------------------->
<cfif #Action# is "i_ctcoll_other_id_type">
<cfoutput>
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
	<cflocation url="CodeTableEditor.cfm?tbl=ctcoll_other_id_type&fld=no&collcde=n&hasDescn=">
</cfoutput>
</cfif>
<!----------------------------------->
<cfif #Action# is "u_ctcoll_other_id_type">
<cfoutput>
	<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update ctcoll_other_id_type set 
			OTHER_ID_TYPE='#other_id_type#',
			DESCRIPTION='#description#',
			base_URL='#base_url#'
		where
			OTHER_ID_TYPE='#origData#'
	</cfquery>
	<cflocation url="CodeTableEditor.cfm?tbl=ctcoll_other_id_type&fld=no&collcde=n&hasDescn=">
</cfoutput>
</cfif>
<!----------------------------------->
<cfif #Action# is "d_ctcoll_other_id_type">
<cfoutput>
	<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		delete from ctcoll_other_id_type
		where
			OTHER_ID_TYPE='#origData#'
	</cfquery>
	<cflocation url="CodeTableEditor.cfm?tbl=ctcoll_other_id_type">
</cfoutput>
</cfif>
<!----------------------------------->
<cfif #Action# is "ctattribute_code_tables">
<cfoutput>
	<cfif #meth# is "save">
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
	</cfif>
	
	<cfif #meth# is "delete">
	
	DELETE FROM ctattribute_code_tables
			WHERE
				Attribute_type = '#oldAttribute_type#' 
				<cfif len(#oldvalue_code_table#) gt 0>
					AND	value_code_table = '#oldvalue_code_table#'
				</cfif> 
				
				<cfif len(#oldunits_code_table#) gt 0>
					AND	units_code_table = '#oldunits_code_table#'
				</cfif> 
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
	</cfif>
	
	<cfif #meth# is "insert">
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
	</cfif>



<cflocation url="CodeTableEditor.cfm?tbl=ctattribute_code_tables&fld=no&collcde=n&hasDescn=">

</cfoutput>
</cfif>
<!----------------------------------->
<!----
<!----------------------------------->
<cfif #Action# is "ctcontainer_type">
<!--- no security --->
<cfoutput>
	<cfif #meth# is "save">
	
		<!----
		--save--
	<cfabort>
		<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			UPDATE ctcontainer_type_size SET
				container_type = '#container_type#',
				container_size = #container_size#
			WHERE
				container_type = '#oldcontainer_type#' AND
				container_size = #oldcontainer_size#
		</cfquery>
		--->
		UPDATE ctcontainer_type SET
				container_type = '#container_type#',
				container_size = #container_size#
			WHERE
				container_type = '#oldcontainer_type#' AND
				container_size = #oldcontainer_size#
				<cfabort>
		
	</cfif>
	
	<cfif #meth# is "delete">
		<!----
		<cfquery name="del" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			DELETE FROM ctcontainer_type_size
			WHERE
				container_type = '#oldcontainer_type#' AND
				container_size = #oldcontainer_size#
		</cfquery>
		
		---->
		DELETE FROM ctcontainer_type_size
			WHERE
				container_type = '#oldcontainer_type#' AND
				container_size = #oldcontainer_size#
				<cfabort>
	</cfif>
	
	<cfif #meth# is "insert">
		INSERT INTO ctcontainer_type_size (
			container_type,
			container_size)
		VALUES (
			'#container_type#',
			#container_size#
			)
			<cfabort>
		<!----
		<cfquery name="new" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		INSERT INTO ctcontainer_type_size (
			container_type,
			container_size)
		VALUES (
			'#container_type#',
			#container_size#
			)
		</cfquery>
			--->
	</cfif>

<cflocation url="CodeTableEditor.cfm?tbl=ctcontainer_type_size&fld=no&collcde=n&hasDescn=">

<!----
--->
</cfoutput>
</cfif>
<!----------------------------------->
---->
<!----------------------------------->
<cfif #Action# is "ctspecimen_part_list_order">
<cfoutput>
	<cfif #meth# is "save">
		<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			UPDATE ctspecimen_part_list_order SET
				partname = '#partname#',
				list_order = '#list_order#'
			WHERE
				partname = '#oldpartname#' AND
				list_order = '#oldlist_order#'
		</cfquery>
	</cfif>
	
	<cfif #meth# is "delete">
	
	
		<cfquery name="del" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			DELETE FROM ctspecimen_part_list_order
			WHERE
				partname = '#oldpartname#' AND
				list_order = '#oldlist_order#'
		</cfquery>
	</cfif>
	
	<cfif #meth# is "insert">
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
	</cfif>



<cflocation url="CodeTableEditor.cfm?tbl=ctspecimen_part_list_order&fld=no&collcde=n&hasDescn=">

</cfoutput>
</cfif>
<!----------------------------------->
<!----------------------------------->
<cfif #Action# is "save#tbl#">
<cfoutput>
<cfquery name="up" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	UPDATE #tbl# SET #fld# = '#thisField#'
	<cfif #collcde# is "y">
		,collection_cde='#collection_cde#'
	</cfif>
	<cfif #hasDescn# is "y">
		,description='#description#'
	</cfif>
	where #fld# = '#origData#'
	<cfif #collcde# is "y">
		 AND collection_cde='#origcollection_cde#'
	</cfif>
</cfquery>
<cflocation url="CodeTableEditor.cfm?tbl=ctcoll_other_id_type&fld=#fld#&collcde=#collcde#&hasDescn=#hasDescn#">
		
</cfoutput>
</cfif>
<!----------------------------------->
<!----------------------------------->
<cfif #Action# is "dele#tbl#">
<cfoutput>
<cfquery name="del" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	DELETE FROM #tbl# 
	where #fld# = '#origData#'
	<cfif #collcde# is "y">
		 AND collection_cde='#origcollection_cde#'
	</cfif>
	</cfquery>
	<cflocation url="CodeTableEditor.cfm?tbl=ctcoll_other_id_type&fld=#fld#&collcde=#collcde#&hasDescn=#hasDescn#">
</cfoutput>
</cfif>
<!----------------------------------->
<!----------------------------------->
<cfif #Action# is "inst#tbl#">
<cfoutput>
<cfquery name="new" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
INSERT INTO #tbl# 
	(#fld#
	<cfif #collcde# is "y">
		 ,collection_cde
	</cfif>
	<cfif #hasDescn# is "y">
		 ,description
	</cfif>
	)
VALUES 
	('#newData#'
	<cfif #collcde# is "y">
		 ,'#collection_cde#'
	</cfif>
	<cfif #hasDescn# is "y">
		 ,'#description#'
	</cfif>
)
</cfquery>
<cflocation url="CodeTableEditor.cfm?tbl=#tbl#&fld=#fld#&collcde=#collcde#&hasDescn=#hasDescn#">
</cfoutput>
</cfif>
<!----------------------------------->

<cfinclude template="includes/_footer.cfm">
