<body bgcolor="#FFFBF0" text="midnightblue" link="blue" vlink="midnightblue">
<!--- no security --->

<!--- allow users to manually put collection_objects into containers ---> Welcome to the manual location utility. <br>Search for containers in this window.<br>
<form name="part" method="post" action="b2c2.cfm" target="_tree">
<input type="hidden" name="srch" value="Container">
<table border="0">
     <tr> 
      <td><div align="right">Container Label:</div></td>
      <td><input type="text" name="label"> <font size="-1"> ('%' accepted as 
        &quot;match any character&quot;)</font></td>
    </tr>
    <tr> 
      <td><div align="right">Container Description:</div></td>
      <td><input type="text" name="description"></td>
    </tr>
	
	<tr> 
      <td><div align="right">Container Barcode:</div></td>
      <td><input type="text" name="barcode"></td>
    </tr>
	
	<tr> 
      <td><div align="right">Container Remarks:</div></td>
      <td><input type="text" name="container_remarks">(any substring)</td>
    </tr>
<tr> 
      <td><div align="right">Container Type:</div></td>
	  <cfquery name="contType" datasource="#Application.web_user#">
select container_type from ctContainer_Type order by container_type
</cfquery>
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
								value="Reset" 
								class="qutBtn"
								onmouseover="this.className='qutBtn btnhov'"
								onmouseout="this.className='qutBtn'">
		 <input type="submit" 
								value="Search" 
								class="schBtn"
								onmouseover="this.className='schBtn btnhov'"
								onmouseout="this.className='schBtn'">
		</cfoutput>
		</td>
    </tr>
  </table>
  </form>
  <br><a href="home.cfm" target="_top">Return home.</a>


