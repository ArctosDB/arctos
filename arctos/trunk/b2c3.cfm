<!--- no security --->

<script language="JavaScript" src="includes/_overlib.js"></script>
<body bgcolor="#FFFBF0" text="midnightblue" link="blue" vlink="midnightblue">
<cfif isdefined("Action") AND #Action# is "addItem">
	<cfoutput>
	<!--- make sure we have what we need --->
	<cfif not (
		isdefined("collection_object_id") AND
		isdefined("container_id") AND
		len(#collection_object_id#) gt 0 AND
		len(#container_id#) gt 0)>
			This form receved information that it can't understand. Please select a container from the tree to try again.
			<cfabort>
		</cfif>
		<cftransaction>
			<!--- get the part's container --->
			<cfquery name="getPartCont" datasource="#Application.uam_dbo#">
				select container_id from coll_obj_cont_hist WHERE collection_object_id = #collection_object_id#
			</cfquery>
			<cfif not #getPartCont.recordcount# eq 1>
				There is a problem with the object you are trying to place. It may not have a valid container ID.
				<cfabort>
			</cfif>
			<!--- set oracle's time format to what we want --->
			<cfset loadtime = now()>
			<cfset loaddate = dateformat(#loadtime#,"dd-mmm-yyyy")>
			<cfset loadtime = dateformat(#loadtime#,"HH:mm:ss")>
			<cfset loadtime = "'#loaddate# #loadtime#'">
			<cfquery name="setTime" datasource="#Application.uam_dbo#">
				alter session set nls_date_format = 'DD-Mon-YYYY HH24:MI:SS'
			</cfquery>
			<!--- add an entry to coll_obj_cont_hist --->
			<cfset sql = "
			INSERT INTO coll_obj_cont_hist 
					(collection_object_id, container_id, installed_date, current_container_fg)
				values 
					(#collection_object_id#, #container_id#, #loadtime#, 1)">
			<cfquery name="insCollObjContHist" datasource="#Application.uam_dbo#">
				#preservesinglequotes(sql)#
			</cfquery>
			<!--- update container --->
			<cfset sql = "UPDATE container 
				SET parent_container_id=#container_id#,
				parent_install_date = #loadtime#
				where container_id=#getPartCont.container_id# ">
			<cfquery name="upCont" datasource="#Application.uam_dbo#">
				#preservesinglequotes(sql)#
			</cfquery>
			
		</cftransaction>
		<cflocation url="b2c3.cfm?cat_num=#cat_num#&part=#part#&label=#label#&container_id=#container_id#&Action=addedItem">
	</cfoutput>
	
</cfif>
<cfif isdefined("Action") AND #Action# is "addedItem">
  <cfoutput> You just put catalog number <font color="##FF00FF">#cat_num#</font>'s <font color="##FF00FF">#part#</font> into container <font color="##FF00FF">#label#</font> (ID <font color="##FF00FF">#container_id#</font>). <br>
    Continue searching to add more containers or 
    click <a href="FindContainer.cfm" target="_top">here</a> to return to the 
    Container applications. </cfoutput> 
  <cfabort>
</cfif>

<cfif isdefined("container_id")>
	<cfoutput>
		<cfquery name="cDet" datasource="#Application.web_user#">
			select * from container where container_id=#container_id#
		</cfquery>
	</cfoutput>
	<cfoutput query="cDet">

Selected container details:
<table border="1">
  <tr>
    <td>
	
	<cfform action="b2c3.cfm?action=addItem" method="post" name="partsToContainers">
					<table>
				  <tr>
					<td align="right">CONTAINER_ID&nbsp;</td>
					<td><input type="text" name="CONTAINER_ID" value="#CONTAINER_ID#" readonly="yes" class="readClr">&nbsp;</td>
				  </tr>
				  <tr>
					<td align="right">PARENT_CONTAINER_ID&nbsp;</td>
					<td><input type="text" name="PARENT_CONTAINER_ID" value="#PARENT_CONTAINER_ID#" readonly="yes" class="readClr">&nbsp;</td>
				  </tr>
				  <tr>
					<td align="right">CONTAINER_TYPE&nbsp;</td>
					<td><input type="text" name="CONTAINER_TYPE" value="#CONTAINER_TYPE#" readonly="yes" class="readClr">&nbsp;</td>
				  </tr>
				  <tr>
					<td align="right">LABEL&nbsp;</td>
					<td><input type="text" name="LABEL" value="#LABEL#" readonly="yes" class="readClr">&nbsp;</td>
				  </tr>
				  <tr>
					<td align="right">DESCRIPTION&nbsp;</td>
					<td><input type="text" name="DESCRIPTION" value="#DESCRIPTION#" readonly="yes" class="readClr">&nbsp;</td>
				  </tr>
				  <tr>
					<td align="right">PARENT_INSTALL_DATE&nbsp;</td>
					<td><input type="text" name="PARENT_INSTALL_DATE" value="#PARENT_INSTALL_DATE#" readonly="yes" class="readClr">&nbsp;</td>
				  </tr>
				  <tr>
					<td align="right">CONTAINER_REMARKS&nbsp;</td>
					<td><input type="text" name="CONTAINER_REMARKS" value="#CONTAINER_REMARKS#" readonly="yes" class="readClr">&nbsp;</td>
				  </tr>
				  <tr>
					<td align="right">BARCODE&nbsp;</td>
					<td><input type="text" name="BARCODE" value="#BARCODE#" readonly="yes" class="readClr">&nbsp;</td>
				  </tr>
				  
				  
				</table>

	</td>
  <td>
  <center>
  <br>Put this object
  <br><img src="images/right_arrow.gif">

  <br>in 

  <br>this container
  <br><img src="images/left_arrow.gif">
    <br>&nbsp;
	<cfoutput>
 <br>
  <input type="submit" 
								value="Do It" 
								class="insBtn"
								onmouseover="this.className='insBtn btnhov'"
								onmouseout="this.className='insBtn'">
 </cfoutput>
  </center>
		
	
  </td>
    <td>
	
	<table>
  <tr>
    <td align="right">Cat Num:</td>
    <td>
	
	<input type="text" name="cat_num" readonly="yes" class="readClr"></td>
  </tr>
  <tr>
    <td align="right">Item:</td>
    <td><input type="text" name="part" readonly="yes" class="readClr"></td>
  </tr>
  <tr>
   
   <input type="hidden" name="collection_object_id">
   </tr>
  <tr>
            <td align="center" colspan="2">
			<input type="button" 
								value="Pick Object" 
								class="picBtn"
								onmouseover="this.className='picBtn btnhov'"
								onmouseout="this.className='picBtn'"
								onClick="javascript: pickpart();">
								
			</td>
    
  </tr>
  </cfform>

	</cfoutput>
    
  
</table>



	 
</td>
  </tr>
</table>
		
	
        
	
                 

	
<cfelse>
	Container details will be here when you select a container in the tree.
</cfif>
