<cfinclude template = "includes/_header.cfm">
<!---- this is an internal use page and needs a security wrapper --->
 

<CFSCRIPT>
/**
* compares one list against another to find the elements in the first list that don't exist in the second list.
*
* @param List1 Full list of delimited values.
* @param List2 Delimited list of values you want to compare to List1.
* @param Delim1 Delimiter used for List1. Default is the comma.
* @param Delim2 Delimiter used for List2. Default is the comma.
* @param Delim3 Delimiter to use for the list returned by the function. Default is the comma.
* @return Returns a delimited list of values.
* @author Rob Brooks-Bilson (rbils@amkor.com)
* @version 1.0, November 14, 2001
*/
function ListCompare(List1, List2)
{
var TempList = "";
var Delim1 = ",";
var Delim2 = ",";
var Delim3 = ",";
var i = 0;
// Handle optional arguments
switch(ArrayLen(arguments)) {
case 3:
{
Delim1 = Arguments[3];
break;
}
case 4:
{
Delim1 = Arguments[3];
Delim2 = Arguments[4];
break;
}
case 5:
{
Delim1 = Arguments[3];
Delim2 = Arguments[4];
Delim3 = Arguments[5];
break;
}
}
/* Loop through the full list, checking for the values from the partial list.
* Add any elements from the full list not found in the partial list to the
* temporary list
*/
for (i=1; i LTE ListLen(List1, "#Delim1#"); i=i+1) {
if (NOT ListFindNoCase(List2, ListGetAt(List1, i, Delim1), Delim2)){
TempList = ListAppend(TempList, ListGetAt(List1, i, Delim1), Delim3);
}
}
Return TempList;
}
</CFSCRIPT>



  <cfset filename = "/var/www/html/temp/newbars.txt">
<!----
  <cfif #Action# is "nothing">
  <cfoutput> 
    <div align="center"><font size="+2"><strong>Add container scans</strong></font> 
    </div>
    <br>
    Duplicate scans will be ignored. 
    <cfset fieldlist = "parent, child, sdate, stime">
    <cffile action="READ" file="#filename#" variable="fileContent">
    <!--- The file name should be an absolute path --->
    <!--- Creates a query from the data that was read --->
    <cfset getDump=QueryNew("#fieldlist#")>
    <!--- The field list should be a (comma-delimited string), such as "Name, Address, Phone" --->
    <cfloop index="line" list="#fileContent#" delimiters="#chr(10)#">
      <!--- chr(10) is the line feed character, so this loops over the list of lines in the file --->
      <!--- Adds a row to the query for each line of the file --->
      <cfset QueryAddRow(getDump)>
      <cfset fieldcount=0>
      <!--- Loops over each line of the file, treating it as a list and adding each element to the query --->
      <cfloop index="field" list="#line#" delimiters=",">
        <!--- Increments the field counter --->
        <cfset fieldcount = fieldcount + 1>
        <!--- Inserts the field into the query --->
        <cfset QuerySetCell(getDump,listGetAt(fieldlist,fieldcount),field)>
      </cfloop>
    </cfloop>
     Upload a new file: <br>
    <cfform action="CheckBarcodes.cfm?action=newScans" method="post" enctype="multipart/form-data">
      <input type="file"
   name="FiletoUpload"
   size="45">
   
      <input type="submit" 
				value="Upload this file" 
				class="savBtn"
				onmouseover="this.className='savBtn btnhov'"
				onmouseout="this.className='savBtn'">
				
				
    </cfform>
	
	<form action="CheckBarcodes.cfm?action=update" method="post">
      <input type="submit" 
				value="Yep, that's the right stuff. Let's do this." 
				class="savBtn"
				onmouseover="this.className='savBtn btnhov'"
				onmouseout="this.className='savBtn'">
				
				
    </form>
    <form action="start.cfm" method="get">
      <input type="submit" 
				value="I'm like so lost. Take me somewhere safe." 
				class="qutBtn"
				onmouseover="this.className='qutBtn btnhov'"
				onmouseout="this.className='qutBtn'">
				
    </form>
   
    <p>The file located at #filename# containes the following data. Continue only 
      if this is correct and you have searched these data for strangeness (ie, 
      scans placing the museum building into a nunc tube are probably erroneous, 
      unless it is a really big nunc tube). 
    <p>#filename#: 
    <p>&nbsp;</p>
  </cfoutput> <cfoutput query="getDump"> 
    <br>
    #parent#, #child#, #sdate#, #stime# </cfoutput> 
</cfif>  
	
<!----------------------------------------------------------------------------------------------> 	
  <cfif #action# is "newScans">
    <cffile action="upload"
      destination="/var/www/html/temp/newbars.txt"
      nameConflict="overwrite"
      fileField="Form.FiletoUpload">
    <!--- reload this form --->
    <cflocation url="LoadBarcodes.cfm">
  </cfif>
--->
<!----------------------------------------------------------------------------------------------> 

  
    <!--- get scan dump into query--->
    <cfset fieldlist = "parent, child, sdate, stime">
    <cffile action="READ" file="#filename#" variable="fileContent">
    <!--- The file name should be an absolute path --->
    <!--- Creates a query from the data that was read --->
    <cfset getDump=QueryNew("#fieldlist#")>
    <!--- The field list should be a (comma-delimited string), such as "Name, Address, Phone" --->
    <cfloop index="line" list="#fileContent#" delimiters="#chr(10)#">
      <!--- chr(10) is the line feed character, so this loops over the list of lines in the file --->
      <!--- Adds a row to the query for each line of the file --->
      <cfset QueryAddRow(getDump)>
      <cfset fieldcount=0>
      <!--- Loops over each line of the file, treating it as a list and adding each element to the query --->
      <cfloop index="field" list="#line#" delimiters=",">
        <!--- Increments the field counter --->
        <cfset fieldcount = fieldcount + 1>
        <!--- Inserts the field into the query --->
        <cfset QuerySetCell(getDump,listGetAt(fieldlist,fieldcount),field)>
      </cfloop>
    </cfloop>
    <!--- got scan dump 
	make date and time into something more useful--->
    <cfoutput>
		
		 <cfquery name="timeFormat" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			  ALTER SESSION SET nls_date_format = 'DD-Mon-YYYY hh24:mi:ss' 
	  </cfquery>
			  
	<table border>
		<tr>
			<td>Child</td>
			<td>Parent</td>
			<td>Timestamp</td>
			<td>&nbsp;</td>
		</tr>
	<cfset i=1>
		<cfloop query="getDump">
			<cfset c="">
			<cfset p="">
			<cfset t = "">
			<cfset r = "">
			
			<cfset timeStamp = '#dateformat(sdate,"dd-mmm-yyyy")# #timeformat(stime,"hh:mm:ss")#'>
			
			
			<!---- make sure stime is a time --->
			<cfif not isdate(#trim(timeStamp)#)>
				<cfset t = "A timestamp, which resolved to #trim(timeStamp)#, is not a valid
				date format.">  
			</cfif>
		 	<!---- get container IDs ---->
			<cfquery name="pcid" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				SELECT container_id FROM container WHERE
				barcode='#trim(parent)#'
			</cfquery>
			
				<cfif pcid.recordcount is not 1>
					
					<cfset p= "A parent container was found 
					  #pcid.recordcount# times.">
					 
					
				  <cfelseif pcid.recordcount is 1>
				  	<cfset parent_container_id = #pcid.container_id#>				  
				</cfif>
			<cfquery name="ccid" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				SELECT container_id FROM container WHERE
				barcode='#trim(child)#'
			</cfquery>
				<cfif ccid.recordcount is not 1>
					<cfset c="A child container was found #ccid.recordcount# times.">
					 
				  <cfelseif ccid.recordcount is 1>
				  	<cfset child_container_id = #ccid.container_id#>				  
				</cfif>
			
				
				
				<cfif len(#c#) is 0 AND len(#p#) is 0 and len(#t#) is 0>
					<tr>
						<td>#child#</td>
						<td>#parent#</td>
						<td>#timeStamp#</td>
						<td colspan="2">Spiffy</td>
					</tr>
				<cfelse>
					<tr>
						<td><font color="##FF0000">#child# - #c#</font></td>
						<td><font color="##FF0000">#parent# - #p#</font></td>
						<td><font color="##FF0000">#timeStamp# - #t#</font></td>
						<td>
						<cfif len(#c#) gt 0>
						<cfquery name="ContType" datasource="#Application.web_user#">
select container_type as ctContType from ctcontainer_type
</cfquery>
<cfquery name="FluidType" datasource="#Application.web_user#">
select fluid_type from ctFluid_Type ORDER BY fluid_type
</cfquery>

							<table border>
  
  <form name="form#i#" method="post" action="CreateContainer.cfm?&action=CreateNew" target="_createContainer">

  <tr>
          <td>Type</td>
		  <td>
            <select name="Container_Type" size="1" class="reqdClr">
			<option value=""></option>
          <cfloop query="ContType"> 
            <option 
				<cfif #ContType.ctContType# is "specimen label"> selected</cfif>
			value="#ContType.ctContType#">#ContType.ctContType#</option>
          </cfloop> </select>
		  
		  
	</td>
  </tr>
  <tr>
  	<td>Desc</td>
    <td><input name="description" type="text" value="Label for UAM Mamm #child#." size="30"></td>
  </tr>
  <tr>
  	<td>Bcde</td>
    <td><input name="barcode" type="text" value="#child#"></td>
  </tr>
  <tr>
  <td>Labl</td>
    <td><input name="label" type="text" value="UAM Mamm #child#" class="reqdClr"></td>
  </tr>
  <tr>
  	<td>Date</td>
    <td><input name="parent_install_date" type="text" value="#timestamp#"></td>
  </tr>
  <tr>
  	<td>Rmks</td>
    <td><input name="container_remarks" type="text" value=""></td>
  </tr>
  
  <tr>
   <td>&nbsp;</td>
    <td>
		 <input name="checked_date" type="hidden" value="">
		 <input type="hidden" name="Fluid_Type" value="">
		<input name="concentration" type="hidden" value="">
		<input name="fluid_remarks" type="hidden" value="">
	<input type="submit" value="Create this Container" class="insBtn"
   onmouseover="this.className='insBtn btnhov'" onmouseout="this.className='insBtn'">	

	<cfquery name="findID" datasource="#Application.web_user#">
		select collection_object_id from cataloged_item where collection_cde='Mamm' and
		cat_num=#child#
	</cfquery>
	<br><input type="button" value="Go to Parts for UA Mamm #child#" class="lnkBtn"
   onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'"
   onClick="window.open('/editParts.cfm?collection_object_id=#findID.collection_object_id#','_blank');">	
	</td>
  </tr>

 
 </form>
</table>

<cfelse>
	
	<font color="##000000">Something is broken, but I don't know how to fix it!</font> 
	                  
						</cfif><!--- end len(c) gt 0--->

						</td>
					</tr>
				
				</cfif>
		<cfset i=#i#+1>
		</cfloop>
		
		</table>  
		
	</cfoutput>

	
<cfinclude template = "includes/_footer.cfm">