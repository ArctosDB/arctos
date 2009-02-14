<cfinclude template = "includes/_header.cfm">

 <!---- this is an internal use page and needs a security wrapper --->
 <!--- no security --->
 
<table border="0" cellpadding="20" cellspacing="20">
  <tr>
    <td valign="top">
	
    <br><a href="start.cfm?action=Part"><strong>Find Parts</strong></a> 
	<br><a href="start.cfm?action=Container"><strong>Find Containers</strong></a> 
    		
	  </td>
    <td valign="top">

<!--------------------------------------------------------------------------------------->
<cfif #action# is "Part">
<cfset title="Part Search">
<font size="+1"><strong>Search for Parts:</strong></font> <br>

<form name="part" method="post" action="Container.cfm">
<input type="hidden" value="Part" name="srch">
<table border="0">
    <tr> 
      <td><div align="right">AF Number: </div></td>
      <td><input type="text" name="af_num"> <font size="-1">&nbsp;</font></td>
    </tr>
    <tr> 
      <td><div align="right">Catalog Number:</div></td>
      <td><input type="text" name="cat_num"></td>
    </tr>
	<cfquery name="collections" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select collection_cde from ctCollection_Cde order by collection_cde
	</cfquery>
	<tr><td align="right">
	<p>Collection Code:</td><td>
    <select name="collection_cde" size="1">
      <!--- this next line is hard-coded--it MUST be updated when collections are added--->
      <option value="">Any</option>
      <cfoutput query="collections"> 
        <option value="#collections.collection_cde#">#collections.collection_cde#</option>
      </cfoutput> 
    </select>
	</td></tr>
	
    <cfquery name="PartName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select distinct part_name from specimen_part ORDER BY part_name
	</cfquery>
    <tr> 
      <td><div align="right">Part:</div></td>
      <td><select name="part_name" size="1">
          <option value=""></option>
          <cfoutput query="partName"> 
            <option value="#partName.part_name#">#partName.part_name#</option>
          </cfoutput> </select></td>
    </tr>
    <tr> 
      <td><div align="right">Scientific Name:</div></td>
      <td><input type="text" name="Scientific_Name"> <font size="-1">(partial 
        match OK)</font></td>
    </tr>
    <tr> 
      <td><div align="right"> </div></td>
      <td><cfoutput>
	   <input type="reset" 
					value="Clear" 
					class="clrBtn"
					onmouseover="this.className='clrBtn btnhov'" 
					onmouseout="this.className='clrBtn'">
		<input type="button" 
					value="Grid" 
					class="lnkBtn"
					onmouseover="this.className='lnkBtn btnhov'" 
					onmouseout="this.className='lnkBtn'"
					onClick="part.treeURL.value='ContainerGrid.cfm?';submit();" >
		 <input type="button" 
					value="Locations" 
					class="lnkBtn"
					onmouseover="this.className='lnkBtn btnhov'" 
					onmouseout="this.className='lnkBtn'"
					onClick="part.treeURL.value='location_tree.cfm?';submit();">
					
		<input type="hidden" name="treeURL" value="location_tree.cfm?">
		
		</cfoutput></td>
    </tr>
  </table>
  </form>
</cfif>
<!--------------------------------------------------------------------------------------->

<!--------------------------------------------------------------------------------------->
<cfif #action# is "Container">
<cfset title="Container Search">
<font size="+1"><strong>Search for Containers:</strong></font> 
<form name="part" method="post" action="Container.cfm">
<input type="hidden" name="srch" value="Container">
<table border="0">
    <!---
	<tr> 
      <td><div align="right">AF Number: </div></td>
      <td><input type="text" name="af_num"> <font size="-1">(search by AF Num 
        for best performance)</font></td>
    </tr>
    <tr> 
      <td><div align="right">Catalog Number:</div></td>
      <td><input type="text" name="cat_num"></td>
    </tr>
	--->
	<tr> 
      <td><div align="right">Barcode:</div></td>
      <td><input type="text" name="barcode"></td>
    </tr>
    <tr> 
      <td><div align="right">Label:</div></td>
      <td><input type="text" name="container_label"> <font size="-1"> Match substrings?<input type="checkbox" name="wildLbl" value="1"></font></td>
    </tr>
    <tr> 
      <td><div align="right">Description:</div></td>
      <td><input type="text" name="description"></td>
    </tr>
	
	
	
	<tr> 
      <td><div align="right">Remarks:</div></td>
      <td><input type="text" name="container_remarks">(any substring)</td>
    </tr>
	<cfquery name="contType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
select container_type from ctContainer_Type order by container_type
</cfquery>
	
	   
   <tr> 
      <td><div align="right">Type:</div></td>
      <td><select name="container_type" size="1">
          <option value=""></option>
          <cfoutput query="contType"> 
            <option value="#contType.container_type#">#contType.container_type#</option>
          </cfoutput> </select></td>
    </tr>
	<!---
    <tr> 
      <td><div align="right">Scientific Name:</div></td>
      <td><input type="text" name="Scientific_Name"> <font size="-1">(partial 
        match OK)</font></td>
    </tr>
	--->
    <tr> 
      <td><div align="right"> </div></td>
      <td>
	  	<cfoutput>
	 <input type="reset" 
					value="Clear" 
					class="clrBtn"
					onmouseover="this.className='clrBtn btnhov'" 
					onmouseout="this.className='clrBtn'">
		<input type="button" 
					value="Grid" 
					class="lnkBtn"
					onmouseover="this.className='lnkBtn btnhov'" 
					onmouseout="this.className='lnkBtn'"
					onClick="part.treeURL.value='ContainerGrid.cfm?';submit();" >
		 <input type="button" 
					value="Tree" 
					class="lnkBtn"
					onmouseover="this.className='lnkBtn btnhov'" 
					onmouseout="this.className='lnkBtn'"					
					onClick="part.treeURL.value='location_tree.cfm?';submit();" >
					
		<input type="hidden" name="treeURL" value="location_tree.cfm?">
	 
		
       
		</cfoutput>
		</td>
    </tr>
  </table>
  </form>
<script>
	document.part.barcode.focus();
</script>
 
</cfif>



	</td>
  </tr>
</table>


 
<cfinclude template = "includes/_footer.cfm">