<cfinclude template="includes/_header.cfm">
<!--- no security --->
<cfset canEdit="">
<cfif #client.username# is not "gordon" AND #client.username# is not "dusty">
<cfset canEdit="no">
	Submit code table edit requests to <a href="mailto:fnghj@uaf.edu">fnghj@uaf.edu</a>.
	<P>You cannot edit these tables.</P>
<cfelse>
	<cfset canEdit="yes">
</cfif>
<!---- variables we'll use to build dynamic update query 
 Must pass in table, field name, and y/n for collection cde via URL, ie:
 
 http://hispida.museum.uaf.edu:8080/Public/CodeTableEditor.cfm?Action=CTACCN_STATUS&fld=status&collcde=n
	
<!---<
<cfset fld="#fld#">
<cfset collcde="#collcde">--->
 end vars ------------------->
<br>This is a dynamically-generated form. Collection Code, if used in this table, is on the left and the code table value is on the right. DO NOT edit any existing values without talking to Dusty first; values already used in the database MUST be manually updated whenever anything changes in the code tables.
<p>&nbsp;</p>
<cfquery name="ctcollcde" datasource="#Application.web_user#">
	select collection_cde from ctcollection_cde
</cfquery>
<cfoutput>

Edit code table #tbl#
<cfset title = "Edit #tbl#">
<cfif #tbl# is "ctattribute_code_tables">
<!--- special section to handle the one extremely funky code table --->

	<cfquery name="ctAttribute_type" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		select distinct(attribute_type) from ctAttribute_type
	</cfquery>
	<cfquery name="thisRec" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
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
   	onmouseover="this.className='savBtn btnhov'" 
   	onmouseout="this.className='savBtn'"
	onclick="att#i#.meth.value='save';submit();">	
	
	<input type="button" 
	value="Delete" 
	class="delBtn"
   	onmouseover="this.className='delBtn btnhov'" 
   	onmouseout="this.className='delBtn'"
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
	class="insBtn"
   	onmouseover="this.className='insBtn btnhov'" 
   	onmouseout="this.className='insBtn'">	
	
				</td>
			</tr>
				
				
				
				
				
			</form>
	</table>
<cfelseif #tbl# is "ctspecimen_part_list_order">
<!--- special section to handle  another  funky code table --->
<cfquery name="thisRec" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
	select * from ctspecimen_part_list_order order by
	list_order,partname
</cfquery>

<cfquery name="ctspecimen_part_name" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
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
	
	<!----
<cfelseif #tbl# is "ctcontainer_type">
<!--- special section to handle  one more  funky code table --->
This is a customized code table editor to handle container sizes. 
<cfquery name="q" datasource="#Application.web_user#">
	select * from ctcontainer_type
	order by container_size DESC
</cfquery>

<cfset maxSpacerWidth = 100>
<cfquery name="ctcontTypes" datasource="#Application.web_user#">
	select container_type from ctcontainer_type
</cfquery>
<p><hr></p>
<cfset i=1>
<table>
<cfloop query="q">
	<form name="contSize#i#" method="post" action="CodeTableEditor.cfm">
	<input type="hidden" name="action" value="ctcontainer_type">
	<input type="hidden" name="tbl" value="#tbl#">
	<input type="hidden" name="meth">
	<input type="hidden" name="oldcontainer_type" value="#container_type#">
	<input type="hidden" name="oldcontainer_size" value="#container_size#">
	
	<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
		<td>	<!---- this image is used to
				stagger the rows according to container_size---->
				<cfif len(#container_size#) gt 0>
					<cfset thisWidth = #maxSpacerWidth# - (#container_size#)>
				<cfelse>
					<cfset thisWidth = 0>
				</cfif>
				
				#thisWidth#
				<img src="/images/black.gif" width="#thisWidth#" height="0">
			<select name="container_type" size="1">
					<cfset thisType = "#container_type#">
					<cfloop query="ctcontTypes">
							<option 
							value="#container_type#"
							<cfif #thisType# is #container_type#> selected </cfif>>#container_type#</option>
							</cfloop>
				</select>
		</td>
		<td>
			<cfset thisSize = #container_size#>
			<input type="text" name="container_size" size="6" value="#container_size#"> CM
						
		</td>
		<td>
			<td colspan="3">
				<input type="button" 
	value="Save" 
	class="savBtn"
   	onmouseover="this.className='savBtn btnhov'" 
   	onmouseout="this.className='savBtn'"
	onclick="contSize#i#.meth.value='save';submit();">	
	
	<input type="button" 
	value="Delete" 
	class="delBtn"
   	onmouseover="this.className='delBtn btnhov'" 
   	onmouseout="this.className='delBtn'"
	onclick="contSize#i#.meth.value='delete';submit();">	
	
				</td>
		</td>
	</tr>
	</form>
<cfset i=#i#+1>
</cfloop>
</table>

<table border class="newRec">

<form name="newSize" method="post" action="CodeTableEditor.cfm">
				<input type="hidden" name="action" value="ctcontainer_type">
				<input type="hidden" name="tbl" value="#tbl#">
				<input type="hidden" name="meth" value="insert">
			<tr>
				
				
				<td>
				<!--- 
					don't show things that we've already used
					First, make a list of everything that has a size
					<cfset weHaveIt = "">
				<cfloop query="q">
					<cfset wehaveIt="#weHaveIt#,#container_type#">
				</cfloop>
				<cfif not listcontains(wehaveIt,#container_type#,",")>
				</cfif>
				---->
				
				<select name="container_type" size="1">
					<cfloop query="ctcontTypes">
					
						<!--- put it in the list ---->
						<option 
						value="#container_type#">#container_type#</option>
					
					</cfloop>
				</select>
				</td>
				
				<td>
					
					<input type="text" name="container_size" size="6"> CM
						
				
				</td>
			</tr>
			
				<tr>
				<td colspan="3">
				<input type="submit" 
	value="Create" 
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
			</tr>
				
				
				
				
			</form>
---->
<cfelse><!---------------------------- normal CTs --------------->

	<cfquery name="q" datasource="#Application.web_user#">
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
<!----------------------------------->
<cfif #Action# is "ctattribute_code_tables">
<!--- no security --->
<cfoutput>
	<cfif #meth# is "save">
		<cfquery name="sav" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
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
		<cfquery name="del"  datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
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
		<cfquery name="new" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
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
		<cfquery name="sav" datasource="#Application.uam_dbo#">
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
		<cfquery name="del" datasource="#Application.uam_dbo#">
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
		<cfquery name="new" datasource="#Application.uam_dbo#">
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
<!--- no security --->
<cfoutput>
	<cfif #meth# is "save">
		<cfquery name="sav" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			UPDATE ctspecimen_part_list_order SET
				partname = '#partname#',
				list_order = '#list_order#'
			WHERE
				partname = '#oldpartname#' AND
				list_order = '#oldlist_order#'
		</cfquery>
	</cfif>
	
	<cfif #meth# is "delete">
	
	
		<cfquery name="del" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			DELETE FROM ctspecimen_part_list_order
			WHERE
				partname = '#oldpartname#' AND
				list_order = '#oldlist_order#'
		</cfquery>
	</cfif>
	
	<cfif #meth# is "insert">
		<cfquery name="new" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
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
<cfif #canEdit# is not "yes">
	No editing!
	<cfabort>
</cfif>
<!--- no security --->
<cfoutput>
<cfquery name="up" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
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
<cflocation url="CodeTableEditor.cfm?tbl=#tbl#&fld=#fld#&collcde=#collcde#&hasDescn=#hasDescn#">
		
</cfoutput>
</cfif>
<!----------------------------------->
<!----------------------------------->
<cfif #Action# is "dele#tbl#">
<!--- no security --->
<cfif #canEdit# is not "yes">
	No editing!
	<cfabort>
</cfif>
<cfoutput>
<cfquery name="del" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
	DELETE FROM #tbl# 
	where #fld# = '#origData#'
	<cfif #collcde# is "y">
		 AND collection_cde='#origcollection_cde#'
	</cfif>
	</cfquery>
	<cflocation url="CodeTableEditor.cfm?tbl=#tbl#&fld=#fld#&collcde=#collcde#&hasDescn=#hasDescn#">
</cfoutput>
</cfif>
<!----------------------------------->
<!----------------------------------->
<cfif #Action# is "inst#tbl#">
<cfif #canEdit# is not "yes">
	No editing!
	<cfabort>
</cfif>
<!--- no security --->
<cfoutput>
<cfquery name="new" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
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