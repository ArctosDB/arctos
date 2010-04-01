<cfinclude template = "includes/_header.cfm">

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



  <cfset filename = "#application.webDirectory#/temp/newbars.txt">
 <!------------------------------------------------------------------->
  <cfif #Action# is "nothing">
  <cfoutput> 
    <div align="center"><font size="+2"><strong>Add container scans</strong></font> 
    </div>
    <br>
    Duplicate scans will be ignored. 
   <cfquery name="getDump" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
   	SELECT container_id, parent_container_id, timestamp,
	get_container_barcode(container_id) child_barcode,
	get_container_barcode(parent_container_id) parent_barcode
 FROM cf_temp_container_location
	group by
	container_id, parent_container_id, timestamp 
   </cfquery>
     Upload a new file: <br>
    <cfform action="LoadBarcodes.cfm" method="post" enctype="multipart/form-data">
		<input type="hidden" name="action" value="newScans" />
      <input type="file"
   name="FiletoUpload"
   size="45">
   
      <input type="submit" 
				value="Upload this file" 
				class="savBtn"
				onmouseover="this.className='savBtn btnhov'"
				onmouseout="this.className='savBtn'">
				
				
    </cfform>
	
    <p>The current batch of scans contains the following data. Continue only 
      if this is correct and you have searched these data for strangeness (ie, 
      scans placing the museum building into a nunc tube are probably erroneous, 
      unless it is a really big nunc tube). 
	  <p>Format is <strong>parent_barcode,child_barcode,time,date</strong></p>
   

<br /><strong>Current Data:</strong>
There are #getDump.recordcount# items in the table

<input type="button" value="Load Them" onclick="document.location='checkContainerMovement.cfm';" 
	class="insBtn" onmouseover="this.className='insBtn btnhov'"
				onmouseout="this.className='insBtn'"/>
  </cfoutput> 
<br>
<font size="-1"><em>Click to open container details in new window</em></font>
<table border>
	<tr>
		<td>Parent Barcode</td>
		<td>Child Barcode</td>		
		<td>Time Stamp</td>
	</tr>

  <cfoutput query="getDump"> 
   <tr>
		
		<td>
			<a href="EditContainer.cfm?container_id=#parent_CONTAINER_ID#" target="_blank">#parent_barcode#</a>
		</td>
		<td>
			<a href="EditContainer.cfm?container_id=#container_id#" target="_blank">#child_barcode#</a>
		</td>
		<td>#timestamp#</td>
	</tr> 
	</cfoutput> 
	</table>
</cfif>  
	
<!----------------------------------------------------------------------------------------------> 	
  <cfif #action# is "newScans">
  <div style="background-color:#FF0000">
	  If you see anything here, STOP and figure out WHY. On a successful upload you will NOT see this message.
</div>
  <p></p>
  <!---
	 
		here we are<cfflush>
			--->
			 
    <cffile action="upload"
      destination="#filename#"
      nameConflict="overwrite"
      fileField="Form.FiletoUpload" />
	  
	  <!---
	move the file<cfflush>	
			--->
			
	  <cfquery name="timeFormat" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			  ALTER SESSION SET nls_date_format = 'DD-Mon-YYYY hh24:mi:ss' 
	  </cfquery>
    <!--- reload this form --->
    <!--- load into temp table ---->
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
		<cftransaction>
		<cfset error = "">
		<p>
			Fix the problems below and re-load the file to continue.
		</p>
		<table border>
			<tr>
				<td>Parent Scan</td>
				<td>Child Scan</td>				
				<td>Time Stamp</td>
				<td>Problem</td>
			</tr>
		<cfloop query="getDump">
			<tr>
				<td>#parent#</td>
				<td>#child#</td>
			<cfset thisError = "">
			<cfset timeStamp = '#dateformat(sdate,"dd-mmm-yyyy")# #timeformat(stime,"hh:mm:ss")#'>
			<td>#timeStamp#</td>
			<!---- get container IDs ---->
			<!---
			getid<cfflush>
			--->
			<cfquery name="pcid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				SELECT container_id FROM container WHERE
				barcode='#trim(parent)#'
			</cfquery>
			<!---
			
			gotid<cfflush>
			--->
				<cfif pcid.recordcount is not 1>
					<cfset thisError = 'The parent container was found 
					  #pcid.recordcount# times. <a href="EditContainer.cfm?action=newContainer&barcode=#trim(parent)#">create</a>'>
				  <cfelseif pcid.recordcount is 1>
				  	<cfset parent_container_id = #pcid.container_id#>				  
				</cfif>
				<!---
			getCID<cfflush>
			--->
			
			<cfquery name="ccid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				SELECT container_id FROM container WHERE
				barcode='#trim(child)#'
			</cfquery>
			<!---
			gotCID<cfflush>			
			--->
				<cfif ccid.recordcount is not 1>
					<cfset thisError='#thisError#; A child container was found 
					  #ccid.recordcount# times. <a href="EditContainer.cfm?action=newContainer&barcode=#trim(child)#">create</a>'>
				  <cfelseif ccid.recordcount is 1>
				  	<cfset child_container_id = #ccid.container_id#>				  
				</cfif>
				
			
			<cfif len(#thisError#) gt 0>
				<cfset error = "#error##thisError#">
				<td>#thisError#</td>
			<cfelse>
				<td>Spiffy</td>
				<!---
			
			inserting<cfflush>
			--->
				<cfquery name="onerow" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					insert into  cf_temp_container_location (
						CONTAINER_ID,
						PARENT_CONTAINER_ID,
						TIMESTAMP)
					values (
						#ccid.container_id#,
						#pcid.container_id#,
						'#timeStamp#')
				</cfquery>
				<!---
			
			inserted<cfflush>
			--->
			</cfif>
			</tr>
			<!---
			
			done one loop<cfflush>
			--->
		</cfloop>
		</cftransaction>
	
		</table>
		<cfif len(#error#) is 0>
			<cflocation url="checkContainerMovement.cfm" addtoken="no">
		<cfelse>
			-----#error#----
		</cfif>
		<p>
			Fix the problems above and re-load the file to continue.
		</p>
			
	</cfoutput>
  </cfif>
<!----------------------------------------------------------------------------------------------> 

<!----------------------------------------------------------------------------------------------> 
  
<!----------------------------------------------------------------------------------------------> 
  <cfif #action# is "update">
  disabled<cfabort>
  <!--- first, run the checker --->
  
  <cfset globalError = "">
  <cfinclude template="/checkContainerMovement.cfm"/>
  <!---- see if we got any errors ---->
  <cfif len(#globalError#) gt 0>
  	<!--- show errors and abort ---->
	The checker found errors! See the table above, and reload ALL scans. Nothing has been moved!
	<p>Click <a href="LoadBarcodes.cfm" target="_top">here</a> to load another scan batch.</p>
	<cfabort>
  </cfif>
   
    <cfoutput>
		
		 <cfquery name="timeFormat" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			  ALTER SESSION SET nls_date_format = 'DD-Mon-YYYY hh24:mi:ss' 
	  </cfquery>
		<cfquery name="getDump" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				SELECT container_id, parent_container_id, timestamp FROM cf_temp_container_location
	group by
	container_id, parent_container_id, timestamp
		</cfquery>
			  
		<cftransaction>
		<cfset i=0>
		<cfloop query="getDump">
			<!---- don't do anything if it's already been done ---->
			<cfquery name="itsThere" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select count(*) cnt from container where
				parent_container_id = #parent_container_id# and
				to_char(parent_install_date,'DD-Mon-YYYY')='#dateformat(timeStamp,"dd-mmm-yyyy")#' and
				container_id=#container_id#
			</cfquery>
			<cfif #itsThere.cnt# is 0>
				<!--- format the timestamp ---->
				<cfset ts = '#dateformat(timestamp,"dd-mmm-yyyy")# #timeformat(timestamp,"HH:mm:ss")#'>
				
						<cftry>
							<cfquery name="upCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
								UPDATE container SET
									parent_container_id = #parent_container_id#,
									parent_install_date='#ts#'
								WHERE
									container_id=#container_id#
							</cfquery>
							<cfcatch>
								<cfset sql=cfcatch.sql>
								<cfset message=cfcatch.message>
								<cfset queryError=cfcatch.queryError>
								<cf_queryError>
							</cfcatch>
						</cftry>
			</cfif>
		<cfset i=#i#+1>
		</cfloop>
		</cftransaction>  
		<p><font color="##00FF00">Successfully loaded #i# records!</font></p>
		<p><a href="LoadBarcodes.cfm?action=checkIsLoaded">Check Stats</a></p>
	</cfoutput>
</cfif>
<!----------------------------->
<cfif #action# is "checkIsLoaded">
disabled<cfabort>
<cfoutput>
	<cfquery name="howMany" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT container_id, parent_container_id, timestamp FROM cf_temp_container_location
		group by
		container_id, parent_container_id, timestamp 
	</cfquery>
	
	
	
	<cfquery name="isMatches" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			cf_temp_container_location.container_id,
			cf_temp_container_location.parent_container_id,
			to_char(cf_temp_container_location.timestamp,'DD-Mon-YYYY')
		FROM
			cf_temp_container_location,
			container
		WHERE
			cf_temp_container_location.container_id = container.container_id AND
			cf_temp_container_location.parent_container_id = container.parent_container_id AND
			to_char(cf_temp_container_location.timestamp,'DD-Mon-YYYY') = to_char(container.parent_install_date,'DD-Mon-YYYY')
		GROUP BY
			cf_temp_container_location.container_id,
			cf_temp_container_location.parent_container_id,
			to_char(cf_temp_container_location.timestamp,'DD-Mon-YYYY')			
	</cfquery>
	<br />
	There are <strong>#howMany.recordcount#</strong> unique values in table cf_temp_container_location.
	<strong>#isMatches.recordcount#</strong> of these are already loaded.
	
</cfoutput>
</cfif>
<cfinclude template = "includes/_footer.cfm">