<cfinclude template = "includes/_header.cfm">
<!---- this is an internal use page and needs a security wrapper --->
<!--- no security --->

<cfif URL.action is "set">
<cfquery name="ctContainer_Type" datasource="#Application.web_user#">
	select container_type from ctcontainer_type order by container_type
</cfquery>
<body>


<form name="form1" method="post" action="CreateContainersForBarcodes.cfm?action=create">
   Institution Acronym:<input type="text" name="institution_acronym">
    <p>Low number in series: 
      <input type="text" name="beginBarcode">
      <br>
      High number in series: 
      <input type="text" name="endBarcode">
      <br>
      Barcode Prefix (non-numeric leading bit-include spaces if you want them) 
      <input type="text" name="prefix">
      <br>
      Barcode Suffix (non-numeric trailing bit-include spaces if you want them) 
      <input type="text" name="suffix">
	   <br>
      Label Prefix (non-numeric leading bit-include spaces if you want them) 
      <input type="text" name="label_prefix">
      <br>
      Label Suffix (non-numeric trailing bit-include spaces if you want them) 
      <input type="text" name="label_suffix">
      <br>
      Container Type: 
      <select name="container_type" size="1">
        <cfoutput query="ctContainer_Type"> 
          <option value="#ctContainer_Type.Container_Type#">#ctContainer_Type.Container_Type#</option>
        </cfoutput> 
      </select>
	  <br>
     Remarks
      <input type="text" name="remarks">
	  <cfoutput>
	    <input type="submit" value="Create Series" class="insBtn"
   onmouseover="this.className='insBtn btnhov'" onMouseOut="this.className='insBtn'">	

	  </cfoutput>
    </p>
    <p>The barcode label will be {prefix}{number}{suffix}. For example, prefix=' 
      a', number = 1, suffix=' b' will produce barcode ' a1 b'. Make sure you 
      enter <font color="#FF0000"><strong>exactly</strong></font> what the scanner 
      will read, including all spaces!</p>
   
    </form>
</cfif>
<!----------------------------------------------------------------------------------->

<!----------------------------------------------------------------------------------->
<cfif URL.action is "create">
<cfquery name="nextContainerId" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
	SELECT max((container_id) + 1) as next_id from container
</cfquery>
<cfoutput query="nextContainerID">
	<cfset newid = "#next_id#">
</cfoutput>

<cfset num = #endBarcode# - #beginBarcode#>
<cfset barcode = "#beginBarcode#">
<cfoutput>
<cfset num = #num# + 1>
<cfloop index="index" from="1" to = "#num#">
<cfquery name="AddLabels" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
	INSERT INTO container (container_id, parent_container_id, container_type, barcode, label, container_remarks,locked_position,institution_acronym)
		VALUES (#newid#, 0, '#container_type#', '#prefix##barcode##suffix#', '#label_prefix##barcode##label_suffix#','#remarks#',0,'#institution_acronym#')
</cfquery>
		<cfset num = #num# + 1>
		<cfset barcode = #barcode# + 1>
		<cfset newid = #newid# + 1>
</cfloop>	
	
	<br> The series of barcodes from #beginBarcode# to #endBarcode# have been uploaded.
	
  
	<br>
    <a href="CreateContainersForBarcodes.cfm?action=set">Load more barcodes</a></cfoutput> 
</cfif>

<cfinclude template = "includes/_footer.cfm">