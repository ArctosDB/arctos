<cfinclude template="/includes/_header.cfm">

<!--------------------------------------------------------------------------->
<cfif #action# is "validate">
<!--- they can do several things here
	1) If they supplied a cat_num, a part, and a parent barcode:
		a) create a new part for that specimen and put it in the parent, or
		b) put existing part in new parent
	2) If they supplied a barcode and a parent barcode:
		a) move the part to the new parent
---->		
	<cfoutput>
		<cfset back = '<a href="aps.cfm?lastPart=#part_name#&lastColl=#collection_id#
			&lastParent=#parent_barcode#
			&lastCat=#oidnum#&lastType=#other_id_type#&lastNewType=#new_container_type#">Go Back</a>'>
			<!--- find the collection object ---->
		<cfif #other_id_type# is "catalog_number">
			<cfquery name="coll_obj" datasource="#Application.web_user#">
				select specimen_part.collection_object_id FROM
					cataloged_item,
					specimen_part
				WHERE
					cataloged_item.collection_object_id = specimen_part.derived_from_cat_item AND
					collection_id=#collection_id# AND
					cat_num=#oidnum# AND
					part_name='#part_name#'
			</cfquery>
		<cfelse>
			<cfquery name="coll_obj" datasource="#Application.web_user#">
				select specimen_part.collection_object_id FROM
					cataloged_item,
					specimen_part,
					coll_obj_other_id_num
				WHERE
					cataloged_item.collection_object_id = specimen_part.derived_from_cat_item AND
					cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id AND
					collection_id=#collection_id# AND
					other_id_type='#other_id_type#' AND
					other_id_num= '#oidnum#' AND
					part_name='#part_name#'
			</cfquery>
		</cfif>
		<cfif #coll_obj.recordcount# is 1>
			<!--- see if they gave a valid parent container ---->
			<cfquery name="isGoodParent" datasource="#Application.web_user#">
				select container_id from container where container_type <> 'collection object'
				and barcode='#parent_barcode#'
			</cfquery>
			<cfif #isGoodParent.recordcount# is 1>
				<!---- Find coll obj container ---->
				<cfquery name="cont" datasource="#Application.web_user#">
					select container_id FROM coll_obj_cont_hist where
					collection_object_id=#coll_obj.collection_object_id#
				</cfquery>
				<cfif #cont.recordcount# is 1>
					
					<!-----
					disable for testing
					
					---->
					<cfquery name="newparent" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
						UPDATE container SET container_type = '#new_container_type#' WHERE
						container_id=#isGoodParent.container_id#
					</cfquery>
					<cfquery name="moveIt" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
						UPDATE container SET parent_container_id = #isGoodParent.container_id# WHERE
						container_id=#cont.container_id#
					</cfquery>
					
					<cfquery name="catcollobj" datasource="#Application.web_user#">
							select distinct(derived_from_cat_item) FROM
								specimen_part
							WHERE
								collection_object_id=#coll_obj.collection_object_id#
				  </cfquery>
					
					You just put 
					<a href="/SpecimenDetail.cfm?collection_object_id=#catcollobj.derived_from_cat_item#">
					#other_id_type# #oidnum#</a>'s #part_name# 
					into container 
					<a href="/Container.cfm?barcode=#parent_barcode#&srch=container">#parent_barcode#</a>
					
				<cfelse>
					The part you tried to move doesn't exist as a container. That probably isn't your fault!
					Email <a href="mailto:fndlm@uaf.edu">dusty</a>. Now!
				</cfif>
				
			<cfelse>
				The parent barcode you entered doesn't resolve to a valid barcode, or it's a collection object.
				Barcoded containers must exist before you put things in them, and you can't put collection 
				objects into other collection objects.
			</cfif>
			
		<cfelseif #coll_obj.recordcount# is 0>
			The part you entered doesn't exist!
		<cfelse>#coll_obj.recordcount#
				The part you entered exists #coll_obj.recordcount# times. That may be good data, but this form can't
				handle it!
		</cfif>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------->
<cfif #action# is not "validateFromFile">
<cfquery name="ctCollection" datasource="#Application.web_user#">
	select collection_cde, institution_acronym, collection_id FROM collection
</cfquery>
<cfquery name="ctPartName" datasource="#Application.web_user#">
	select distinct(part_name) FROM ctspecimen_part_name
</cfquery>
<cfquery name="ctOtherIdType" datasource="#Application.web_user#">
	select distinct(other_id_type) FROM ctcoll_other_id_type
</cfquery>
<cfparam name="part_name" default="">
<cfparam name="collection_id" default="">
<cfparam name="other_id_type" default="">
<cfparam name="oidnum" default="">
<cfparam name="parent_barcode" default="">
<cfparam name="lastNewType" default="">


<cfquery name="ctContType" datasource="#Application.web_user#">
	select container_type from ctcontainer_type
	order by container_type
</cfquery>

<p>
	This application puts collection objects into containers.
	Enter enough information to uniquely identify a collection object 
	(ie, original field number=1 probably won't work) and the barcode of the 
	container you'd like to put the object into. Scroll down to upload a file.
</p>


<table border>
	<tr>
		<td>Collection</td>
		<td>ID Type</td>
		<td>ID Number</td>
		<td>Part Name</td>
		<!----
		<td>Barcode</td>
		---->
		<td>Parent Barcode</td>
		<td>Parent Cont Type</td>
		<!----
		<td>Print Flag</td>
		---->
	</tr>
	
	<cfoutput>
	
		<form name="scans" method="post" action="aps.cfm" id="scans">
		<input type="hidden" name="action" value="validate">
		
		<tr>
				<td>
					<select name="collection_id" size="1">
						<cfset thisColl=#collection_id#>
						<cfloop query="ctCollection">
							<option 
							<cfif #thisColl# is #collection_id#> selected </cfif>value="#collection_id#">#institution_acronym# #collection_cde#</option>
						</cfloop>
					</select>
				</td>
				<td>
					<select name="other_id_type" size="1">
						<cfset thisType=#other_id_type#>
						<option value="catalog_number">Catalog Number</option>
						<cfloop query="ctOtherIdType">
							<option 
							<cfif #thisType# is #other_id_type#> selected </cfif>value="#other_id_type#">#other_id_type#</option>
						</cfloop>
					</select>
				</td>
				<td>
					<input type="text" name="oidnum" class="reqdClr" value="#oidnum#" id="oidnum">
				</td>
				<td>
					<select name="part_name" size="1">
					<cfset thisPart=#part_name#>
						<cfloop query="ctPartName">
							<option 
							<cfif #thisPart# is #part_name#> selected </cfif>
							value="#part_name#">#part_name#</option>
						</cfloop>
					</select>
				</td>
				<!----
				<td>
					<input type="text" name="barcode" value="#lastBC#">
				</td>
				---->
				<td>
					<input type="text" name="parent_barcode" value="#parent_barcode#">
				</td>
				<td>
					<select name = "new_container_type" id="new_container_type" size="1" class="reqdClr">
						<cfloop query="ctContType">
							<option <cfif #lastNewType# is #container_type#> selected></cfif>value="#container_type#">#container_type#</option>
						</cfloop>
					</select>
			
				</td>
				<!----
				<td>
					<select name="print_flag" size="1">
						<option <cfif #lastPrintFg# is 0> selected </cfif> value="0">N</option>
						<option <cfif #lastPrintFg# is 1> selected </cfif> value="1">C</option>
						<option <cfif #lastPrintFg# is 2> selected </cfif> value="2">V</option>
					</select>
				</td>
				---->
		  </tr>
			<tr>
				<td colspan="6">
					<input type="submit" value="Move it" class="savBtn"
		   onmouseover="this.className='savBtn btnhov'" onmouseout="this.className='savBtn'">
				</td>
			</tr>
		</form>
		<script>
			document.scans.oidnum.value='';
			document.scans.oidnum.focus();
		</script>
	</cfoutput>
</table>

<hr>
<strong>File Method:</strong>
<p>&nbsp;</p>
File format is:
<br>
{institution_acronym},{collection_code},{other_id_type},{other_id_number},{part_name},{barcode},{print_fg},{new_container_type}
<br>Example:
 UAM,Mamm,AF,2345,skull,123456,1
 <br>"catalog number" is a valid other_id_type.
 <br>Example: UAM,Mamm,catalog number,2345,skull,123456,0,box
 <p>
 Print Flag Values:
 <br>
 0 - nothing, remove all print flags
 <br>1 - container
<br> 2 - vial

<br />Valid Container Types:
<cfoutput query="ctContType">
	<br />#container_type#
</cfoutput>
<p>&nbsp;</p>
Upload a file:
<cfform name="getFile" method="post" action="aps.cfm" enctype="multipart/form-data">
	<input type="hidden" name="action" value="getFileData">
	 <input type="file"
		   name="FiletoUpload"
		   size="45">
	<input type="submit" value="Upload this file"
		class="savBtn"
		onmouseover="this.className='savBtn btnhov'" 
		onmouseout="this.className='savBtn'">
</cfform>
</cfif>
<!---------------------------------------------------------------------->
  <cfif #action# is "getFileData">
<cfoutput>
	<!--- put this in a temp table 
		create table cf_temp_barcode_parts (
			 KEY number not null,
			 OTHER_ID_TYPE varchar2(255),
			 OTHER_ID_NUMBER varchar2(60),
			 COLLECTION_CDE varchar2(20),
			 INSTITUTION_ACRONYM varchar2(20),
			 part_name varchar2(255),
			 barcode varchar2(255),
			 COLLECTION_OBJECT_ID number,
			 container_id number
			 );
		CREATE PUBLIC SYNONYM cf_temp_barcode_parts FOR cf_temp_barcode_parts;
		GRANT select,insert,update,delete ON cf_temp_barcode_parts to uam_update;
	---->

	<cfquery name="killOld" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		delete from cf_temp_barcode_parts
	</cfquery>
	
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	<cfset i=1>
	<cfloop index="line" list="#fileContent#" delimiters="#chr(10)#">
		<cfset sql = "">
		<cfset line = #replace(line,'#chr(9)##chr(9)#','#chr(9)#null#chr(9)#','all')#>
		<br>line:#line#
		<cfloop index="field" list="#line#" delimiters=",">
			<br>field:#field#
			<cfset field = #replace(field,"'","''","all")#>
			<cfset sql = #replace(sql,'{comma}',',','all')#>
			<cfset sql = "#sql#'#trim(replace(field,'"','','all'))#',">
		</cfloop>
	 	<cfset sql = #reverse(replace(reverse(sql),",","","first"))#>
		<cfset sql = "#i#,#sql#">
		<cfset i=#i#+1>
		<br>INSERT INTO cf_temp_barcode_parts (
				 KEY,
				 INSTITutION_ACRONYM,
				 COLLECTION_CDE,
				 OTHER_ID_TYPE,
				OTHER_ID_NUMBER,
				 part_name,
				 barcode,
				 print_fg,
				 new_container_type
				 ) 
			VALUES (
				#preservesinglequotes(sql)#
				)	
		<cfquery name="newRec"	 datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			INSERT INTO cf_temp_barcode_parts (
				 KEY,
				 INSTITutION_ACRONYM,
				 COLLECTION_CDE,
				 OTHER_ID_TYPE,
				OTHER_ID_NUMBER,
				 part_name,
				 barcode,
				 print_fg,
				 new_container_type
				 ) 
			VALUES (
				#preservesinglequotes(sql)#
				)	 			
	  </cfquery>
	
    </cfloop>
	<!----
		
	---->
	
	<cflocation url="aps.cfm?action=validateFromFile">

</cfoutput>
</cfif>
<!--------------------------------------------------------------------------->
<cfif #action# is "validateFromFile">
You should get a list of messages below. Anything in <font color="#FF0000" size="+1">red</font>
failed loading and you must deal with it.
<cfquery name="data" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
	select  KEY,
			INSTITutION_ACRONYM,
			COLLECTION_CDE,
			OTHER_ID_TYPE,
			OTHER_ID_NUMBER oidNum,
			part_name,
			barcode parent_barcode,
			print_fg,
			new_container_type
			 from cf_temp_barcode_parts
			 
</cfquery>
<cfquery name="goodContainers" datasource="#Application.web_user#">
	select new_container_type from cf_temp_barcode_parts
	where new_container_type NOT IN (
		select container_type from ctcontainer_type)
</cfquery>
<cfif #goodContainers.recordcount# gt 0>
	Bad container type (#goodContainers.new_container_type#)! Aborting...
	<cfabort>
</cfif>
	<cftransaction>
		<cfoutput>
		<cfloop query="data">
			<!--- find the collection object ---->
		<cfif #other_id_type# is "catalog number">
			<cfquery name="coll_obj" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				select specimen_part.collection_object_id FROM
					cataloged_item,
					specimen_part,
					collection
				WHERE
					cataloged_item.collection_object_id = specimen_part.derived_from_cat_item AND
					cataloged_item.collection_id = collection.collection_id AND
					collection.COLLECTION_CDE='#COLLECTION_CDE#' AND
					collection.INSTITutION_ACRONYM = '#INSTITutION_ACRONYM#' AND
					cat_num=#oidnum# AND
					part_name='#part_name#'
			</cfquery>
		<cfelse>
			<cfquery name="coll_obj" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				select specimen_part.collection_object_id FROM
					cataloged_item,
					specimen_part,
					coll_obj_other_id_num,
					collection
				WHERE
					cataloged_item.collection_object_id = specimen_part.derived_from_cat_item AND
					cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id AND
					cataloged_item.collection_id = collection.collection_id AND
					collection.COLLECTION_CDE='#COLLECTION_CDE#' AND
					collection.INSTITutION_ACRONYM = '#INSTITutION_ACRONYM#' AND
					other_id_type='#other_id_type#' AND
					other_id_num= '#oidnum#' AND
					part_name='#part_name#'
			</cfquery>
		</cfif>
		<cfif #coll_obj.recordcount# is 1>
			<!--- see if they gave a valid parent container ---->
			<cfquery name="isGoodParent" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				select container_id from container where container_type <> 'collection object'
				and barcode='#parent_barcode#'
			</cfquery>
			<cfif #isGoodParent.recordcount# is 1>
				<!---- Find coll obj container ---->
				<cfquery name="cont" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
					select container_id FROM coll_obj_cont_hist where
					collection_object_id=#coll_obj.collection_object_id#
				</cfquery>
				<cfif #cont.recordcount# is 1>
					<!-----
					disable for testing
					
						---->
						<cfquery name="flagIT" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
							update container set print_fg=#print_fg#,container_type='#NEW_CONTAINER_TYPE#'
							where container_id = #isGoodParent.container_id#						
						</cfquery>
						<cftransaction action="commit">
						
						<cfquery name="moveIt" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
							UPDATE container SET parent_container_id = #isGoodParent.container_id#
							 WHERE
							container_id=#cont.container_id#
						</cfquery>
					
						
						<cfquery name="catcollobj" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
							select distinct(derived_from_cat_item) FROM
								specimen_part
							WHERE
								collection_object_id=#coll_obj.collection_object_id#
				 		 </cfquery>
						 <br />
					You just put 
					<a href="/SpecimenDetail.cfm?collection_object_id=#catcollobj.derived_from_cat_item#">
					#other_id_type# #oidnum#</a>'s #part_name# 
					into container 
					<a href="/Container.cfm?barcode=#parent_barcode#&srch=container">#parent_barcode#</a>
					<br>
					
				<cfelse>
					<font color="##FF0000" size="+1">The part 
					(#institution_acronym# #collection_cde# #other_id_type# #oidnum# #part_name#)
					you tried to move doesn't exist as a container. That probably isn't your fault!
					Email <a href="mailto:fndlm@uaf.edu">dusty</a>. Now!</font>				  <br>
					<cftransaction action="rollback">
				</cfif>
				
			<cfelse>
				<font color="##FF0000" size="+1">The parent barcode you entered doesn't resolve to a valid barcode, or it's a collection object.
				Barcoded containers must exist before you put things in them, and you can't put collection
				 				objects into other collection objects.
								<br>
					(#institution_acronym# #collection_cde# #other_id_type# #oidnum# #part_name#)</font>	
				<cftransaction action="rollback">		
		  </cfif>
			
		<cfelseif #coll_obj.recordcount# is 0>			
			<font color="##FF0000" size="+1">The part you entered doesn't exist!
			<br>
					(#institution_acronym# #collection_cde# #other_id_type# #oidnum# #part_name#)<br></font>		
				<cftransaction action="rollback">
			<cfelse>#coll_obj.recordcount#
				<font color="##FF0000" size="+1">The part you entered exists #coll_obj.recordcount# times. That may be good data, but this form can't
				handle it!
				<br>
					(#institution_acronym# #collection_cde# #other_id_type# #oidnum# #part_name#)<br></font>		
				<cftransaction action="rollback">
		</cfif>
	</cfloop>
	</cfoutput>
	</cftransaction>
</cfif>
<!------------------------------------------------------------------->
<cfinclude template="/includes/_footer.cfm"/>